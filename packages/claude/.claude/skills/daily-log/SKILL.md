---
name: daily-log
description: Write the vault's Daily/YYYY-MM-DD.md notes by harvesting Claude Code session transcripts and git commits, backfilling every day that is missing one. Use when the user says "/daily-log", "write up yesterday", "what did I do yesterday", "catch up the daily notes", "backfill my daily notes", or when a scheduled morning routine invokes it. Runs unattended and is safe to re-run - it only writes days that have no note yet. Do not use for the outward-looking tech news briefing (that is daily-briefing) or for capturing a single lesson (that is til).
---

# Daily Log

Reconstruct what happened on a working day from evidence already on disk, and write it up as a daily note.

This exists because asking an agent to journal as it goes does not work - the instruction always loses to the task in front of it. Everything needed is already recorded: Claude Code writes a full JSONL transcript per session, and git records what actually shipped. So nobody has to remember anything; the day just gets reconstructed afterwards.

## 1. Harvest

Write the digest to a file rather than letting it land in the conversation - a five-day backfill is a few hundred KB and you want the context for writing, not for JSON:

```bash
HARVEST=~/.claude/skills/daily-log/scripts/harvest.py
python3 "$HARVEST" -o /tmp/daily-digest.json
```

With no arguments it finds every date that has transcripts but no `~/vault/Daily/YYYY-MM-DD.md` and digests up to 5 of them (`--limit N` to change). Today is excluded - it isn't finished yet. Days whose transcripts hold no real prompts are dropped rather than given an empty note.

```bash
python3 "$HARVEST" --list-gaps                # just the dates
python3 "$HARVEST" --date 2026-08-19 -o /tmp/d.json   # one day; refuses if a note exists, --force overrides
```

Never read the raw `.jsonl` files yourself. A working day is tens of megabytes and the script exists to turn that into a few KB; going direct will blow the context and tell you nothing extra.

Each day gives you:

- `sessions` - in chronological order by `started`. `title` is Claude Code's own generated session title, `prompts` are what was actually typed with harness noise stripped, `started`/`ended` bracket every record in the session (not just typed turns, so the span reflects real elapsed time including long agent runs), `project` resolves through worktrees to the real repo, `branches` shows what was in play.
- `commits` - what shipped, timestamped, authored by each repo's own configured identity, deduplicated across worktrees.
- `merged_prs` - PRs merged that day with numbers, titles, URLs and the branch each came from. Prompts refer to PRs constantly ("585 has merged"); this is what turns those references into facts you can cite.

**Link every PR reference.** `merged_prs` carries a `url` - use it. A bare "PR 585" or "eleven PRs merged" is a dead end six months later, when the number means nothing and finding it means trawling GitHub by hand. Internal vault notes get `[[wikilinks]]`; GitHub is external, so it gets markdown links:

- A specific PR: `[#585](https://github.com/TheTote/strata-api/pull/585)` - take the URL straight from `merged_prs`.
- Several named PRs: link each number individually rather than lumping them into one link.
- An aggregate with no numbers ("eleven PRs merged", "the backlog cleared"): link the phrase to that repo's merged-PR list filtered to the day, which you can build from any PR URL for that repo - `[eleven PRs](https://github.com/TheTote/dev-metrics/pulls?q=is%3Apr+merged%3A2026-08-05)`. Better still, name the PRs if there are only a few.

Commit SHAs are worth the same treatment where a strand hangs off one commit, using the repo path from a PR URL: `[6243a27](https://github.com/TheTote/strata-api/commit/6243a27)`.

**Join a PR to a session on `branch`, not on the title.** A PR's `branch` and a session's `branches` match exactly, which makes the attribution a fact rather than a guess. Matching on how similar a PR title sounds to a prompt reads convincingly and is wrong often enough to matter. Where no branch matches, attribute nothing - say the PR merged that day and leave it there.
- `tils_already_captured` - every lesson already filed, so the nudge doesn't re-suggest known material.
- `existing_note` - present only when a note for that day already exists but has never been harvested, with its full `text`. See "merging" below.

If there are no gaps, say so in one line and stop. Silence is the correct output for a day off.

## 2. Write the note

One file per day at `~/vault/Daily/YYYY-MM-DD.md`.

```markdown
---
type: daily
date: YYYY-MM-DD
harvested: <today's date>
---

## <What the work was, as a heading>

<A few sentences on what was worked on and what came of it, with [[wikilinks]].>

## <Next strand of work>

...
```

Group by strand of work, not by session - one piece of work often spans several sessions and several repos, and the point of the note is to jog your memory in six months, not to inventory tool invocations. Lead with the substantial strands; a day with two real threads and six bits of admin should read that way.

**The `harvested:` stamp is what stops the work being redone.** A day counts as finished only once a note carries it, which is why the harvester ignores the mere existence of a file. Notes get written by hand or by `/assistant` part-way through a day, and treating those as complete would silently discard everything that happened afterwards - which on a normal day is most of it.

**Merging.** When `existing_note` is present, someone already wrote something for that day and you are adding to their work, not replacing it. Keep every word they wrote: it came from a person who was there, which is better evidence than anything reconstructible from a transcript. Fold in only the strands the evidence shows they missed, and where the note already covers a strand, leave it alone rather than restating it from the digest. Then stamp `harvested:` and leave the rest of the frontmatter as you found it.

Match the existing notes in `Daily/` for tone and shape: prose in sentences, `[[wikilinks]]` woven in for every project, repo and note reference, and callouts where they earn their place - `> [!important]` for a decision or a position landed on, `> [!todo]` for what is still outstanding, `> [!warning]` for something that broke or is blocked.

**Stay inside the evidence.** The digest holds what was *asked*, plus what was *committed and merged*. It contains not one word of what Claude replied, so unless a commit or PR says so you cannot know whether an approach worked, what the root cause turned out to be, or how anything resolved.

**A prompt is an instruction, not a receipt.** This is the trap, and it is effortless to fall into because prompts are written in the imperative. "Raise both PRs and create Jira tickets", "kill the watcher", "clean up the worktrees" are things that were *asked for* at the moment the session ended. Whether any of them happened is not in the digest. Check `commits` and `merged_prs`; if the outcome isn't there, write that the session closed on those instructions, not that the work was done.

The same trap in a subtler form: **branch names are not achievements.** A session listing `fix/watcher-scope-analyses-to-pod-hash` tells you a branch existed. It does not tell you the fix worked, merged, or was even written. Quote branch names as branch names, or cite the PR if one is in `merged_prs`.

Prompts are the strongest signal of intent - literally the day's instructions in your own words. Commits and merged PRs are the strongest signal of outcome. A strand with both is one you can describe confidently; a strand with only prompts gets described as work in progress.

## 3. The TIL nudge

Close the note by pointing at anything worth keeping that never got written up. This is the retrospective safety net for the [[til]] skill - in the moment you are usually too deep in the problem to stop and file it.

**The bar is transferability, not pain.** This is the distinction that decides everything else, and getting it wrong fills the wiki with rubbish. Plenty of things hurt for an afternoon and are worth nothing a month later: a bot re-triggering its own release, a service mesh sidecar breaking one app in preprod, a script that misbehaved once. Those are incidents. They were specific to one repo on one day, they are already fixed, and the reasoning is preserved in the commit, the PR, the ADR or the ticket. The repo remembers them, so the wiki does not need to.

What belongs in a personal knowledge base is what survives being lifted out of that repo and that week:

- **A tool or technology met for the first time** and now understood well enough to use again - what it's for, why it was chosen over the alternatives, how it actually behaves.
- **A process or workflow finding** - that some way of working does or doesn't hold up. "Stacked PRs don't survive a merge queue" is knowledge about GitHub; "PR 431 got stuck" is not.
- **Durable behaviour of a tool** that will bite again anywhere it's used - a version changing its semantics, a default that isn't what you'd assume, an interaction between two tools.
- **A principle that changes how you'd approach a class of problem** - typically something that turned out differently from what you expected.

Two questions settle it. Would this help someone who has never seen this repo? Would it still be true in a year? If the honest answer to either is no, leave it out.

Finding the candidates - wording first, because a real lesson sounds like one:

- Questions about *why* something behaves as it does, rather than instructions to build something
- Encountering something unfamiliar: evaluating options, "how does X work", "what's the difference between"
- A conclusion drawn about an approach rather than about a bug - the tell is that it generalises

Session shape is weak corroboration only. A long `started`/`ended` span against few prompts suggests deep digging. `prompt_count` is the weakest signal of all and cuts both ways: short steering prompts are the normal working mode here, so a high count usually means a productive run, not distress. Never nominate on session shape alone - a long painful session is most often just a long painful incident.

Skip anything in `tils_already_captured`, and anything already written up as an ADR or design doc that day. Suggest at most two, and expect most days to yield none - real learning is not a daily occurrence, and a nudge that fires every day is one you learn to skip within a week. An empty section is a correct answer; leave it out entirely.

```markdown
> [!question] Worth a `/til`?
> - **<the transferable thing>** - <why it holds outside this repo, in one line>
```

Lead with the knowledge, not the session. "Kustomize 5.8 changed namespace resolution for Helm-generated resources" is worth filing; "the Kustomize session was painful" is not.

## 4. Report

One line per day written, plus the nudges. Example:

`Wrote Daily/2026-08-19.md and Daily/2026-08-20.md. Flagged 2 possible TILs (Valkey connection pooling, Kargo promotion stalling).`
