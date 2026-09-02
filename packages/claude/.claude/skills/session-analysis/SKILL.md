---
name: session-analysis
description: Analyse this project's own Claude Code session transcripts from ~/.claude/projects and report on them. Use when the user runs "/session-analysis <mode>", or asks what has been learnt across sessions in this repo, what is worth remembering long term, what they keep re-explaining, or how past sessions in this project have gone. Modes are named arguments - "dream" reviews the history and proposes the memories worth promoting into the long-term memory bank, and is the first stage of dream. Do not use for writing daily notes (that is daily-log) or capturing a single fresh lesson (that is til).
---

# Session analysis

Read the session transcripts Claude Code has saved for the current project and answer a question about them. The mode argument picks the question.

Transcripts live in `~/.claude/projects/<encoded cwd>/*.jsonl`, one file per session, and hold every tool call and result - tens of megabytes. Never read them raw. `scripts/harvest.py` reduces the corpus to the prompts the user actually typed, which is a much smaller thing than the file sizes suggest: on the repo this was built against, the whole of it - every interactive session over six months, 124 prompts across 54 sessions - came to 34 KB. Expect to read the digest whole.

## 1. Harvest

```bash
python3 <skill-dir>/scripts/harvest.py -o <scratchpad>/digest.json
```

Then read `<scratchpad>/digest.json`. Use `/tmp` only if the session has no scratchpad directory. A caller that passed a window (`--since`, `--limit`) wants those flags added here.

Harvesting is this skill's job in the `/dream` cycle. `improve-memory` is handed the digest rather than producing its own, so the candidates and the dedupe pass that checks them always come from the same sample.

The script resolves the current directory to its main worktree and picks up every transcript directory under it, so worktree and subdirectory sessions count as the same project.

Options:

- `--limit N` - most recent N sessions, default 200. Typed prompts are short and there are far fewer of them than the session count implies, so the default usually is the entire history rather than a sample of it. Don't assume it binds: read `sessions_beyond_limit`, and only reach for `jq` slicing if that is non-zero and the digest has genuinely got big.
- `--since YYYY-MM-DD` - skip sessions older than a date. mtime picks which files to open and the parsed end timestamp decides what counts, so a session resumed or restored from backup long after the fact gets opened and then reported under `sessions_outside_window` instead of passing as recent. `--limit` still orders by mtime, so a wholesale restore of the transcript directory does scramble what "most recent" means - worth saying out loud if the counts look impossible.
- `--cwd PATH` - analyse a different project.

Sessions an agent started are dropped before any of them is read. Claude Code records an `entrypoint` per session, and anything SDK-driven - a memory observer, a plugin's own runs, a headless script - is an agent prompting itself, in walls of generated text that bury the real prompts. There are usually far more of these than real sessions: any repo with an agent's session store inside its tree carries thousands, and on this one they were 1731 sessions of 1792 and 48 MB of 48.3. The dropped count comes back as `sessions_agent_driven` so it stays visible, and the filter is a denylist on `sdk-`, so an interactive entrypoint nobody has seen yet keeps being read rather than silently vanishing.

What comes back per session: `title` (Claude Code's own session title), `started`/`ended`, `branches`, `prompts` (truncated to 700 chars, capped at 60 per session) and `total_prompts` so you can see when a session was truncated. Plus `existing_memories` and `memory_dir` for the project, and `stray_memory_dirs` - transcript directories for this repo that hold memory files outside `memory_dir`, which nothing loads.

Sessions with no typed prompts are dropped, and harness-injected blocks, bare slash commands and bare assent ("yes", "ok", "do it") are filtered out - they are noise and they inflate prompt counts.

Report honestly what the digest covers, using the counts the digest gives you rather than subtracting them yourself: `sessions_read` of `sessions_found`, `sessions_beyond_limit` never opened, `sessions_empty` opened but holding no typed prompts, `sessions_outside_window` opened but older than `--since`, `sessions_agent_driven` skipped as not human, plus the date range. Don't present a windowed sample as the whole history, and with `--since` say that the counts describe the window rather than the repo.

## 2. Modes

No mode given: use `dream`. It is the only one, so asking would be a choice between one option. Add the question back when a second mode exists.

### `dream`

Consolidate the history into the memories worth keeping. Produce candidates only - writing them is somebody else's step.

Read for the things that a fresh session would have to be told again:

- **Preferences and corrections** - where the user pushed back, re-explained, or said "no, do it this way". These are the highest-value memories, because each one is a mistake that will otherwise repeat. Capture the *why*, not just the rule.
- **Standing constraints** - things about the environment, tooling or process that hold beyond one task.
- **Project intent** - goals and decisions not derivable from the code or git history. Convert relative dates ("last week") to absolute.
- **Repeated friction** - the same explanation given in three separate sessions is a memory that should have existed.

Reject anything that: the repo already records (structure, past fixes, git history, CLAUDE.md, the rules under `~/.claude/rules/`), only mattered to one conversation, or is already covered by `existing_memories`. Say when something is already covered rather than proposing it again.

Then output, most valuable first, no more than about ten candidates:

- The proposed `name` (kebab-case slug) and memory `type` (`user`, `feedback`, `project`, `reference`).
- The fact itself in one or two lines - specific enough to act on, with the why for `feedback` and `project`.
- The evidence: which sessions it came from, and how many times it recurred.
- Whether it holds for **anyone who clones this repo**, or only for this person on this machine. `improve-memory` promotes the first kind into checked-in project context and leaves the second in the personal memory bank, so calling it here saves it guessing - and the promotion is most of the value of the cycle.

Finish with the near-misses in one line each - things that recurred but are too thin or too repo-local to file.

Then hand over, which depends on who called:

- **Another skill invoked this one** - the candidates are the return value. Carry straight on with the caller's next step; the candidate list is never the end of the run.
- **The user ran it directly** - offer to write the accepted ones into `memory_dir` with the `MEMORY.md` pointer, or to run `/dream` for the full reconcile.

### Adding a mode

One `###` section under Modes, named after the argument, saying what to read the digest for and what to output. The harvester is mode-agnostic; don't extend it unless a mode needs a field the digest doesn't carry.
