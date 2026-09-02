#!/usr/bin/env python3
"""Digest this project's Claude Code session transcripts down to typed prompts.

Reads ~/.claude/projects/<encoded cwd>/*.jsonl (tens of MB) and emits tens of KB
of JSON at the default window. The model never sees a raw transcript.
"""
import argparse
import datetime as dt
import glob
import json
import os
import re
import subprocess
import tempfile

PROJECTS = os.path.expanduser("~/.claude/projects")

# Blocks the harness injects into the user turn. None of these were typed, and
# left in they drown out the real prompts.
INJECTED = (
    "<task-notification", "<local-command", "<system-reminder", "<command-message",
    "<command-name", "<scheduled-task", "<teammate-message", "<user-prompt-submit",
    "Caveat:", "Another Claude session sent a message:",
    "[Request interrupted by user",
    "This session is being continued from a previous conversation",
    "API Error", "<budget:",
)
BARE_COMMAND = re.compile(r"^/[\w:-]+$")
ASSENT = {
    "y", "n", "yes", "no", "ok", "okay", "yep", "yeah", "sure", "go", "go on",
    "do it", "carry on", "continue", "proceed", "next", "thanks", "ta", "cheers",
    "good", "great", "perfect", "nice", "done", "merged", "approved", "agreed",
}
MAX_PROMPT_CHARS = 700
MAX_PROMPTS_PER_SESSION = 60
# Interactive sessions record entrypoint "cli". Anything SDK-driven is an agent
# talking to itself - a memory observer, a plugin's own run - and its "prompts"
# are machine-generated walls of text that swamp the typed ones. A denylist
# rather than an allowlist, so an entrypoint we've never seen still gets read.
AGENT_ENTRYPOINTS = ("sdk-",)


def encode(path):
    return re.sub(r"[^a-zA-Z0-9]", "-", path)


def repo_root(path):
    """Main worktree for `path`, so a worktree's sessions count as this project."""
    try:
        out = subprocess.run(
            ["git", "-C", path, "rev-parse", "--path-format=absolute", "--git-common-dir"],
            capture_output=True, text=True, timeout=10,
        ).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return path
    if not out:
        return path
    return os.path.dirname(out) if os.path.basename(out) == ".git" else out


def under(root, d):
    """Is transcript dir `d` really this project's?

    `encode` maps every separator to "-", so prefix-matching the encoded root
    also matches a sibling repo: `<root>-archive` encodes to exactly what a
    subdirectory of `<root>` would. Transcripts record their own `cwd`, so ask
    them, and fall back to trusting the prefix only when none of them say.
    """
    if os.path.basename(d) == encode(root):
        return True
    for path in sorted(glob.glob(os.path.join(d, "*.jsonl")),
                       key=os.path.getmtime, reverse=True)[:3]:
        for i, rec in enumerate(records(path)):
            cwd = rec.get("cwd")
            if cwd:
                return cwd == root or cwd.startswith(root + os.sep)
            if i > 50:
                break
    return True


def project_dirs(root):
    """Transcript dirs for `root` itself plus anything under it (worktrees, subdirs)."""
    prefix = encode(root)
    return [d for d in glob.glob(os.path.join(PROJECTS, "*"))
            if os.path.isdir(d) and (os.path.basename(d) == prefix
                                     or os.path.basename(d).startswith(prefix + "-"))
            and under(root, d)]


def records(path):
    with open(path, errors="ignore") as fh:
        for line in fh:
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue


def prompt_text(rec):
    """Return the typed text of a user turn, or None if it isn't one."""
    if rec.get("type") != "user" or rec.get("isSidechain") or rec.get("isMeta"):
        return None
    if rec.get("toolUseResult"):
        return None
    content = rec.get("message", {}).get("content")
    if isinstance(content, str):
        text = content
    elif isinstance(content, list):
        text = " ".join(b.get("text", "") for b in content
                        if isinstance(b, dict) and b.get("type") == "text")
    else:
        return None
    text = text.strip()
    if not text or text.startswith(INJECTED) or BARE_COMMAND.match(text):
        return None
    stripped = text.lower().strip(" .!,")
    if len(stripped) < 3 or stripped in ASSENT:
        return None
    return text


def session(path):
    out = {"file": os.path.basename(path), "title": None, "branches": set(),
           "started": None, "ended": None, "prompts": [], "total_prompts": 0}
    for rec in records(path):
        if rec.get("type") == "ai-title":
            out["title"] = rec.get("aiTitle")
        if rec.get("gitBranch"):
            out["branches"].add(rec["gitBranch"])
        stamp = rec.get("timestamp") or ""
        if stamp:
            out["started"] = min(out["started"] or stamp, stamp)
            out["ended"] = max(out["ended"] or stamp, stamp)
        text = prompt_text(rec)
        if text:
            out["total_prompts"] += 1
            if len(out["prompts"]) < MAX_PROMPTS_PER_SESSION:
                out["prompts"].append(text[:MAX_PROMPT_CHARS])
    out["branches"] = sorted(out["branches"])
    return out


def interactive(path):
    """Was this session a person at a terminal, rather than an agent?

    Worth doing before anything else, because the agent transcripts dwarf the
    real ones: any repo whose tree holds an agent's session store picks up
    thousands of them, all of it noise, and reading them is most of the cost.
    """
    for i, rec in enumerate(records(path)):
        ep = rec.get("entrypoint")
        if ep:
            return not ep.startswith(AGENT_ENTRYPOINTS)
        if i >= 50:
            break
    return True


def in_window(sess, since):
    """Did this session end on or after `since`?

    mtime is the cheap prefilter for which files to open, but it moves when a
    session is resumed and it is rewritten wholesale by a restore from backup.
    The parsed end timestamp is the one that describes the work.
    """
    return not since or (sess.get("ended") or "")[:10] >= since


def stray_dirs(found, memory_dir):
    """Memory directories other than the one that gets written to.

    `memories` looks in every transcript dir for the repo, but only one of them
    is `memory_dir`; a memory sitting in any of the others is loaded by nothing.
    """
    want = os.path.relpath(memory_dir, PROJECTS)
    return sorted({os.path.dirname(m["file"]) for m in found
                   if os.path.dirname(m["file"]) != want})


def memories(root):
    """Memories already written for this project, so nothing gets re-suggested."""
    out = []
    for d in project_dirs(root):
        for path in sorted(glob.glob(os.path.join(d, "memory", "*.md"))):
            with open(path, errors="ignore") as fh:
                head = fh.read(600)
            desc = re.search(r"^description:\s*(.+)$", head, re.M)
            out.append({"file": os.path.relpath(path, PROJECTS),
                        "description": desc.group(1).strip() if desc else ""})
    return out


def selfcheck():
    def user(text, **kw):
        return dict(type="user", message={"content": text}, **kw)
    assert prompt_text(user("stow the claude package")) == "stow the claude package"
    assert prompt_text(user("<system-reminder>noise</system-reminder>")) is None
    assert prompt_text(user("/compact")) is None
    assert prompt_text(user("/til worktrees and merge queues")) is not None
    assert prompt_text(user("yes")) is None
    assert prompt_text(user("real", isSidechain=True)) is None
    assert prompt_text(user("result", toolUseResult={"x": 1})) is None
    assert prompt_text({"type": "assistant", "message": {"content": "hi"}}) is None
    assert prompt_text(dict(type="user", message={"content": [
        {"type": "text", "text": "fix the alias"}, {"type": "tool_result", "content": "x"}]}))
    assert encode("/Users/b/_git/b/dotfiles") == "-Users-b--git-b-dotfiles"
    assert in_window({"ended": "2026-09-02T10:00:00Z"}, "2026-08-01")
    assert not in_window({"ended": "2026-07-30T10:00:00Z"}, "2026-08-01")
    assert in_window({"ended": None}, None)
    assert not in_window({"ended": None}, "2026-08-01")
    assert stray_dirs([{"file": "proj/memory/a.md"}, {"file": "other/memory/b.md"}],
                      os.path.join(PROJECTS, "proj", "memory")) == ["other/memory"]
    with tempfile.TemporaryDirectory() as tmp:
        def transcript(*recs):
            p = os.path.join(tmp, "s.jsonl")
            with open(p, "w") as fh:
                fh.write("".join(json.dumps(r) + "\n" for r in recs))
            return p
        assert interactive(transcript({"type": "x"}, {"entrypoint": "cli"}))
        assert not interactive(transcript({"entrypoint": "sdk-cli"}))
        assert not interactive(transcript({"entrypoint": "sdk-ts"}))
        assert interactive(transcript({"type": "x"})), "no entrypoint: read it anyway"
    with tempfile.TemporaryDirectory() as tmp:
        sib = os.path.join(tmp, encode("/r/repo-archive"))
        os.makedirs(sib)
        for cwd, want in (("/r/repo-archive", False), ("/r/repo/sub", True)):
            with open(os.path.join(sib, "s.jsonl"), "w") as fh:
                fh.write(json.dumps({"type": "user", "cwd": cwd}) + "\n")
            assert under("/r/repo", sib) is want, cwd
    print("selfcheck ok")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--cwd", default=os.getcwd(), help="project to analyse (default: cwd)")
    ap.add_argument("--since", help="YYYY-MM-DD; skip sessions that ended earlier")
    ap.add_argument("--limit", type=int, default=200,
                    help="max sessions, most recent first (default 200)")
    ap.add_argument("-o", "--out", help="write JSON here instead of stdout")
    ap.add_argument("--selfcheck", action="store_true", help="run assertions and exit")
    args = ap.parse_args()

    if args.selfcheck:
        selfcheck()
        return

    root = repo_root(args.cwd)
    dirs = project_dirs(root)
    files = sorted((f for d in dirs for f in glob.glob(os.path.join(d, "*.jsonl"))),
                   key=os.path.getmtime, reverse=True)
    if args.since:
        cutoff = dt.date.fromisoformat(args.since)
        files = [f for f in files
                 if dt.date.fromtimestamp(os.path.getmtime(f)) >= cutoff]
    in_window_files = files
    files = [f for f in in_window_files if interactive(f)]

    opened = files[:args.limit]
    parsed = [session(f) for f in opened]
    with_prompts = [s for s in parsed if s["prompts"]]
    sessions = [s for s in with_prompts if in_window(s, args.since)]
    sessions.sort(key=lambda s: s["started"] or "")
    memory_dir = os.path.join(PROJECTS, encode(root), "memory")
    existing = memories(root)
    payload = {
        "project": root,
        "transcript_dirs": [os.path.basename(d) for d in dirs],
        "sessions_found": len(files),
        "sessions_agent_driven": len(in_window_files) - len(files),
        "sessions_read": len(sessions),
        "sessions_beyond_limit": len(files) - len(opened),
        "sessions_empty": len(parsed) - len(with_prompts),
        "sessions_outside_window": len(with_prompts) - len(sessions),
        "existing_memories": existing,
        "memory_dir": memory_dir,
        "stray_memory_dirs": stray_dirs(existing, memory_dir),
        "sessions": sessions,
    }
    text = json.dumps(payload, indent=1)
    if args.out:
        with open(args.out, "w") as fh:
            fh.write(text + "\n")
        print(json.dumps({"written": args.out, "sessions": len(sessions),
                          "kb": round(len(text) / 1024, 1)}))
    else:
        print(text)


if __name__ == "__main__":
    main()
