---
name: dream
description: Consolidate this project's memory - settle the last overview, mine the session transcripts, reconcile and restructure. --mode full (default), or apply-fixes to only apply what you approved.
disable-model-invocation: true
---

# Dream

Sleep on the sessions and wake up with better memory. Orchestrates two skills:

1. `session-analysis` in `dream` mode - mines this project's transcripts for candidate memories.
2. `improve-memory` - folds them into the existing memory, reconciles, restructures, writes the overview.

This skill adds the bit neither has: continuity between runs. A cycle that keeps re-proposing the same five things because nobody applied last week's overview is worse than not running.

## Paths

| What | Where |
| --- | --- |
| Current overview | `memory-improvement-overview.md` (project root) |
| Archived overviews | `.claude/dream/overview-YYYY-MM-DD.md` |
| Run log | `.claude/dream/run-log.md` |

The run log is history, not truth. Whether an item is approved or applied is read off the checkbox in the overview - `[ ]` pending, `[x]` approved, `[x] ... (applied YYYY-MM-DD)` done, `[-]` rejected. Delete the log and the next run still behaves correctly, it just can't say when the last one was. Never infer applied-ness from the log alone.

Append-only, for the same reason: a line records what a run did at the time it ran. When a later correction changes the counts, the correction belongs in the overview and in the next line, never in a past one.

Add `.claude/dream/` to `.gitignore` before writing anything into it, creating the file if the repo has none. The overview is `improve-memory`'s to ignore.

## 1. Settle the last overview first

Read `memory-improvement-overview.md` if it exists, then decide from its state - not from the log:

- **Reviewed** - it has at least one `[x]` or `[-]`, or its mtime is later than the timestamp of the run-log line that wrote it (the user edited it by hand). Invoke the `improve-memory` skill in `apply` mode against the overview, and record what it applied. Applying the ticked items here by hand would run them without its guardrails - the tick-approves-only-that-item rule, the stale-target check, the uncommitted-diff report.
- **Untouched** - no ticks, no edits. Don't apply anything and don't re-derive it from scratch. Carry every `[ ]` item forward into the new overview, keeping its wording and its number, and add a `(pending since YYYY-MM-DD, run N)` marker to the line, so the count lives on the item rather than in the log. At run 3 the item has been put to the user three times without a decision: move it to the rejected section instead of asking a fourth time.
- **Missing** - first run. Skip straight to step 2.

Archive the old file to `.claude/dream/overview-YYYY-MM-DD.md` before the new one is written, so a rewrite never loses a decision the user made.

## 2. Analyse only what changed

In `full` mode, invoke the `session-analysis` skill in `dream` mode, passing the window as its argument. `session-analysis` owns the harvester; never run `harvest.py` from here.

- First run, or no log: plain `dream`. The default window of 200 sessions is the whole history for most repos, and a full sweep costs tens of KB, so there is nothing to be gained by sampling.
- Run log has a previous run: `dream --since <last run date>`. This narrows the read so that what is *new* since the last pass stands out, not because the wider read is expensive. When the previous run left items unresolved, prefer the wider window anyway - those items need re-judging against the same evidence everything else is judged against.

Either way, read `sessions_beyond_limit` from the digest. Non-zero means the history is larger than the window, and the window wants raising: a memory pass that cannot see half the history will keep re-proposing the things it cannot see.

Report the window honestly in the overview - "39 sessions since 2026-08-14", not "your history".

Step 2 is done when the candidates are in hand and step 3 is running. The candidate list is working material, not a deliverable: printing it and handing back to the user leaves the cycle half-finished, which is the one failure this skill exists to prevent.

The single early exit: nothing new turned up and no items were carried forward. Then say so, log the run, and stop - a no-op run should cost one line of output, not a rewritten overview.

## 3. Reconcile

Invoke the `improve-memory` skill with the candidates, the digest path and the carried-forward items. It owns the merging, the contradiction pass, the restructure proposal, the overview format and the auto-apply rules - don't second-guess any of that here. It refuses to run without an analysis handed to it, by design: it must never start a transcript sweep of its own alongside step 2's.

Pass the carried-forward items with their original numbers and their `(pending since ...)` markers, so a duplicate new candidate merges into the existing entry instead of the same fact appearing twice under two numbers.

## 4. Log the run

Append one line, and create the file with a `# Dream run log` heading if it doesn't exist:

```bash
mkdir -p .claude/dream
printf -- '- %s | %s | %s | applied %s | pending %s | %s\n' \
  "$(date -u +%Y-%m-%dT%H:%MZ)" "<mode>" "<window>" \
  "<applied>" "<pending>" "<archived overview, or 'none'>" >> .claude/dream/run-log.md
```

Every `<...>` is a value from this run. `<window>` is the digest's own counts ("158 of 342 sessions, 2026-06-25 to 2026-09-02"), and `<archived overview>` is `none` on a first run, because there was nothing to archive.

## Modes

`--mode full` (default) - steps 1 to 4.

`--mode apply-fixes` - step 1 and step 4 only: hand the overview to `improve-memory` in `apply` mode, then log what it applied. No transcript reading, no new proposals, no rewritten overview. Use it for the second half of the loop, after a review. If there is nothing ticked, say exactly that and change nothing - don't fall through to a full analysis, because that isn't what was asked for.

Unknown mode: say what the valid modes are and stop.

## Stop conditions

- No git repo: auto memory is keyed off the repo root, so say so and stop.
- Overview has unresolved conflicts from the previous run (the "needing a decision" section is non-empty and unedited): surface them first and ask, before adding more proposals on top.
