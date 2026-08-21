#!/usr/bin/env python3
"""Turn Claude Code session transcripts into a compact digest for a daily note.

Reads ~/.claude/projects/*/*.jsonl (tens of MB a day) and emits a few KB of JSON.
The model never sees a raw transcript; it only writes prose over this digest.
"""
import argparse
import collections
import datetime as dt
import glob
import json
import os
import re
import subprocess
import sys

PROJECTS = os.path.expanduser("~/.claude/projects")
VAULT = os.path.expanduser("~/vault")
DAILY = os.path.join(VAULT, "Daily")

# Blocks the harness injects into the user turn. None of these were typed, and
# left in they both drown out the real prompts and inflate prompt_count, which
# in turn poisons the "did this session hurt?" signal downstream.
INJECTED = (
    "<task-notification", "<local-command", "<system-reminder", "<command-message",
    "<command-name", "<scheduled-task", "<teammate-message", "<user-prompt-submit",
    "Caveat:", "Another Claude session sent a message:",
    "[Request interrupted by user",
    "This session is being continued from a previous conversation",
    "API Error", "<budget:",
)
# A bare slash command is a harness invocation. "/til the thing I learned" is
# intent and stays; "/compact" and "/clear" on their own are not.
BARE_COMMAND = re.compile(r"^/[\w:-]+$")

# Bare assent carries no intent and describes no work, but it does inflate
# prompt_count - which is exactly the number the "did this session hurt?"
# judgement leans on. "yes" goes; "yes, do 2-5 in one PR" stays.
ASSENT = {
    "y", "n", "yes", "no", "ok", "okay", "yep", "yeah", "sure", "go", "go on",
    "do it", "carry on", "continue", "proceed", "next", "thanks", "ta", "cheers",
    "good", "great", "perfect", "nice", "done", "merged", "approved", "agreed",
}

MAX_PROMPT_CHARS = 600
MAX_PROMPTS_PER_SESSION = 40


def local_date(ts):
    """Transcript timestamps are UTC; days are lived in local time."""
    if not ts:
        return None
    try:
        return dt.datetime.fromisoformat(ts.replace("Z", "+00:00")).astimezone().date()
    except (ValueError, AttributeError):
        return None


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
        text = " ".join(
            b.get("text", "") for b in content
            if isinstance(b, dict) and b.get("type") == "text"
        )
    else:
        return None
    text = text.strip()
    if not text or text.startswith(INJECTED) or BARE_COMMAND.match(text):
        return None
    stripped = text.lower().strip(" .!,")
    if len(stripped) < 3 or stripped in ASSENT:
        return None
    return text


def new_session():
    return {
        "title": None, "cwd": None, "branches": set(), "prompts": [],
        "first": None, "last": None,
    }


def scan(days):
    """One pass over the corpus, bucketing sessions by local date.

    Scanning per-day would re-read every transcript once per day requested,
    which turns a week's backfill into seven full passes for no reason.
    """
    wanted = set(days)
    earliest = min(days)
    out = {d: {} for d in days}
    for path in glob.glob(os.path.join(PROJECTS, "*", "*.jsonl")):
        # A session active on day D cannot have been written before D.
        if dt.date.fromtimestamp(os.path.getmtime(path)) < earliest:
            continue
        meta = {}
        buckets = collections.defaultdict(new_session)
        for rec in records(path):
            sid = rec.get("sessionId") or rec.get("session_id")
            if not sid:
                continue
            m = meta.setdefault(sid, {"title": None, "cwd": None, "branches": set()})
            if rec.get("type") == "ai-title":
                m["title"] = rec.get("aiTitle")
            if rec.get("cwd"):
                m["cwd"] = rec["cwd"]
            if rec.get("gitBranch"):
                m["branches"].add(rec["gitBranch"])

            when = local_date(rec.get("timestamp"))
            if when not in wanted:
                continue
            s = buckets[(when, sid)]
            stamp = rec.get("timestamp", "")
            if stamp:
                # Bracket on every record, not just user turns: a session that
                # ends with 40 minutes of agent work would otherwise look like
                # it finished the moment the last prompt was typed.
                s["first"] = min(s["first"] or stamp, stamp)
                s["last"] = max(s["last"] or stamp, stamp)
            text = prompt_text(rec)
            if text and len(s["prompts"]) < MAX_PROMPTS_PER_SESSION:
                s["prompts"].append(text[:MAX_PROMPT_CHARS])

        for (when, sid), s in buckets.items():
            if not s["prompts"]:
                continue
            s.update(meta.get(sid, {}))
            out[when][sid] = s
    return out


def repo_root(path):
    """Main worktree for `path`.

    Resolves through the shared git dir rather than --show-toplevel, because
    worktrees each report their own toplevel - which double-counts commits and
    makes a worktree look like a separate project.
    """
    if not path or not os.path.isdir(path):
        return None
    try:
        out = subprocess.run(
            ["git", "-C", path, "rev-parse", "--path-format=absolute", "--git-common-dir"],
            capture_output=True, text=True, timeout=10,
        ).stdout.strip()
    except (OSError, subprocess.SubprocessError):
        return None
    if not out:
        return None
    return os.path.dirname(out) if os.path.basename(out) == ".git" else out


def commits(roots, day):
    """Commits authored by each repo's own configured identity on `day`."""
    found, seen = [], set()
    for root in sorted(roots):
        try:
            email = subprocess.run(
                ["git", "-C", root, "config", "user.email"],
                capture_output=True, text=True, timeout=10,
            ).stdout.strip()
            log = subprocess.run(
                ["git", "-C", root, "log", "--all", "--no-merges",
                 f"--since={day} 00:00", f"--until={day} 23:59",
                 f"--author={email}" if email else "--author=.",
                 "--pretty=%h\t%cI\t%s"],
                capture_output=True, text=True, timeout=30,
            ).stdout.strip()
        except (OSError, subprocess.SubprocessError):
            continue
        for line in filter(None, log.splitlines()):
            sha, _, rest = line.partition("\t")
            when, _, subject = rest.partition("\t")
            if sha in seen:
                continue
            seen.add(sha)
            found.append({"repo": os.path.basename(root), "sha": sha,
                          "at": when, "subject": subject})
    found.sort(key=lambda c: c["at"])
    return found


def pull_requests(roots, day):
    """PRs merged on `day`. Turns "585 has merged" from inference into fact.

    Best-effort: gh may be missing, logged out, or offline, and a daily note is
    not worth failing over.
    """
    found = []
    for root in sorted(roots):
        try:
            out = subprocess.run(
                ["gh", "pr", "list", "--state", "merged", "--author", "@me",
                 "--search", f"merged:{day.isoformat()}",
                 "--limit", "100", "--json", "number,title,mergedAt,url,headRefName"],
                cwd=root, capture_output=True, text=True, timeout=30,
            )
            prs = json.loads(out.stdout) if out.returncode == 0 and out.stdout.strip() else []
        except (OSError, subprocess.SubprocessError, json.JSONDecodeError):
            continue
        for pr in prs:
            if local_date(pr.get("mergedAt")) == day:
                found.append({"repo": os.path.basename(root), "number": pr["number"],
                              "title": pr["title"], "url": pr["url"],
                              # Joins a PR to the session that was on that branch.
                              # Without it a PR can only be matched to work by
                              # guessing from its title.
                              "branch": pr.get("headRefName")})
    return found


def known_tils():
    """Every lesson already filed, so the nudge doesn't re-suggest one.

    Not scoped to the day being written: a lesson captured last week still
    counts as captured, and a nudge that keeps resurfacing known material is
    one you learn to skip past.
    """
    out = []
    for path in glob.glob(os.path.join(VAULT, "wiki", "*", "*.md")):
        try:
            with open(path, errors="ignore") as fh:
                head = fh.read(400)
        except OSError:
            continue
        if "type: til" in head:
            out.append(os.path.splitext(os.path.basename(path))[0])
    return sorted(out)


def digest(day, sessions):
    exists, harvested, text = note_state(day)
    existing = {"path": note_path(day), "harvested": harvested,
                "text": text} if exists else None
    roots = {}
    for s in sessions.values():
        root = repo_root(s["cwd"])
        if root:
            roots[s["cwd"]] = root
    out = []
    for s in sessions.values():
        root = roots.get(s["cwd"])
        out.append({
            # basename(cwd) would call a worktree its own project.
            "project": os.path.basename(root or s["cwd"] or "?"),
            "title": s["title"],
            "branches": sorted(b for b in s["branches"] if b),
            "started": s["first"],
            "ended": s["last"],
            "prompt_count": len(s["prompts"]),
            "prompts": s["prompts"],
        })
    out.sort(key=lambda d: d["started"] or "")
    unique_roots = set(roots.values())
    return {
        "date": day.isoformat(),
        "sessions": out,
        "commits": commits(unique_roots, day),
        "merged_prs": pull_requests(unique_roots, day),
        "tils_already_captured": known_tils(),
        "existing_note": existing,
    }


def transcript_dates(cutoff):
    seen = set()
    for path in glob.glob(os.path.join(PROJECTS, "*", "*.jsonl")):
        if dt.date.fromtimestamp(os.path.getmtime(path)) < cutoff:
            continue
        for rec in records(path):
            if rec.get("type") in ("user", "assistant"):
                d = local_date(rec.get("timestamp"))
                if d and d >= cutoff:
                    seen.add(d)
    return seen


def note_path(day):
    return os.path.join(DAILY, f"{day.isoformat()}.md")


def note_state(day):
    """(exists, harvested, text) for a day's note.

    A note is only "done" once a harvest has stamped it. Treating any existing
    file as done is wrong: notes get written by hand or by an assistant part-way
    through a day, and skipping those would silently lose everything that
    happened after they were saved.
    """
    p = note_path(day)
    if not os.path.exists(p):
        return False, False, ""
    try:
        with open(p, errors="ignore") as fh:
            text = fh.read()
    except OSError:
        return True, False, ""
    head = text.split("---", 2)[1] if text.startswith("---") else ""
    return True, "harvested:" in head, text


def gaps(limit):
    """Dates with transcripts but no daily note.

    Today is excluded because it isn't finished yet. Detecting the gap from the
    filesystem rather than tracking state means a week with the laptop shut
    backfills on its own, and re-running is a no-op.
    """
    today = dt.date.today()
    cutoff = today - dt.timedelta(days=60)
    missing = sorted(d for d in transcript_dates(cutoff)
                     if d < today and not note_state(d)[1])
    return missing[-limit:]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--date", help="YYYY-MM-DD; default is every day missing a note")
    ap.add_argument("--limit", type=int, default=5,
                    help="max days to backfill in one run (default 5)")
    ap.add_argument("--list-gaps", action="store_true",
                    help="print the dates needing a note and exit")
    ap.add_argument("--force", action="store_true",
                    help="digest --date even if it already has a note")
    ap.add_argument("-o", "--out", help="write JSON here instead of stdout")
    args = ap.parse_args()

    if args.date:
        day = dt.date.fromisoformat(args.date)
        if note_state(day)[1] and not args.force:
            print(json.dumps({"days": [], "note": f"{args.date} already harvested; --force to redo"}))
            return
        days = [day]
    else:
        days = gaps(args.limit)

    if args.list_gaps:
        print(json.dumps([d.isoformat() for d in days]))
        return
    if not days:
        print(json.dumps({"days": [], "note": "no days missing a daily note"}))
        return

    found = scan(days)
    payload = {"days": [digest(d, found[d]) for d in days if found.get(d)]}
    if not payload["days"]:
        print(json.dumps({"days": [], "note": "transcripts exist but no real prompts; nothing to write"}))
        return
    text = json.dumps(payload, indent=1)
    if args.out:
        with open(args.out, "w") as fh:
            fh.write(text + "\n")
        print(json.dumps({"written": args.out, "days": [d.isoformat() for d in days],
                          "kb": round(len(text) / 1024, 1)}))
    else:
        print(text)


if __name__ == "__main__":
    main()
