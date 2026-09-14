---
name: weekly-review
description: Review the week just ended and promote its daily notes into the slower vault layers
---

/assistant weekly review

**Review the week that just ended**, Monday to Sunday, not the current week. This runs Monday morning after `daily-log` has written Friday's and the weekend's notes, so the previous week is complete and every daily note exists. Do not review the day this runs on.

The point of this run is promotion, step 8 in the skill. The review prose is secondary. Nothing else in the vault sweeps the slower layers, so if promotion does not happen here, the daily notes accumulate and everything above them goes stale.

Read the previous week's `Worklog/` notes, then move what has held up:

- Project context, status, a decision inside one project → `Projects/{name}/`
- Durable behaviour of one system → `Systems/{repo}.md`, as a bullet under `## Notes`
- A transferable lesson with no single system → `/til`
- A choice about tooling, workflow or the vault → `Decisions/YYYY-MM-DD-{title}.md`
- A repo linked more than once with no note yet → create `Systems/{repo}.md`

`DailyNews/` gets the same treatment. Read the week's briefings and write the `## From the Briefings` section: the threads that ran across more than one day, and anything touching a live project or a `Systems/` note. If this run is the first review of a new month, also compile the month just gone into `wiki/daily-briefings/{Month YYYY} AI and DevOps Trends.md`. The skill has the full procedure.

Work through every unresolved `> [!question] Worth a /til?` callout in that week's notes. Each one is either promoted or explicitly dismissed with a reason. That backlog reached three months once before.

**Never change a project's `status:` unless the week's notes say the project finished.** A status is a claim about the world, and `Projects.base` filters the Active view on it, so a wrong value hides live work. If a project looks done but the notes do not say so, write that in the review and leave the frontmatter alone.

**Only link to notes that exist, and never with a path.** `[[ec2-local-llm-dev-box/README]]` does not resolve; `[[ec2-local-llm-dev-box]]` or backticks do. See Rule 1 in the root `CLAUDE.md`.

Two rules:

- Leave anything still a one-off in the daily note. The test is whether it held up over the week, not whether it felt significant on the day.
- Stay inside the evidence. If a daily note records a question but never its answer, do not promote it and do not invent the resolution. Say it is still open.

Report what was promoted and where, and list anything left open.