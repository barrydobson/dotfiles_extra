---
name: til
description: Capture a hard-won lesson from the current session as a single wiki article in the Obsidian vault at ~/vault/wiki, filed under the right topic with indexes updated. Use this whenever the user says "/til", "TIL", "save this", "capture that", "write that up", "add that to the wiki", "don't want to lose this", "remember how we fixed that", or "that took ages to work out" - and also proactively offer it whenever something transferable has just been worked out - a tool or technology understood for the first time, a process finding that holds beyond this repo, a durable behaviour that will bite again elsewhere, or a conclusion that changes how a class of problem gets approached. Offer it while the detail is still fresh, because it is gone by tomorrow. Do not use it for one-off incidents whose fix already lives in a commit, PR or ticket, and not for general note-taking, daily logs, task capture, or compiling clipped articles from raw/ (that is the compile skill).
---

# TIL

Capture one hard-won lesson, right after you learn it, as one wiki article.

Friction is the enemy. A lesson learned at 16:00 is worth writing at 16:01 and worthless by Friday, because by then the specific error string, the wrong turn you took, and the reason the obvious fix didn't work have all evaporated. So this skill is deliberately fast: gather, write one file, update two indexes, log, report. No research phase, no web lookups, no clarifying interview unless the lesson is genuinely too thin to be useful.

The vault is at `~/vault` (an Obsidian vault). The wiki lives in `~/vault/wiki`.

## 1. Work out what the lesson actually is

**If the user passed text**, that's the lesson. Use it as the spine, and enrich it from the session - the actual error message, the command that fixed it, the file paths - because a TIL that says "DNS was wrong" helps nobody, and one that quotes the exact `dial tcp: lookup ... no such host` and the `coredns` config line that caused it saves future-you an hour.

**If the user passed nothing**, mine the current conversation. Look for the thing that was hard: where you went round in circles, what the wrong assumption was, what the actual root cause turned out to be. That struggle is the value - the final one-line fix on its own is not a lesson, it's a diff.

Prefer specifics over summary throughout. Exact error strings, versions, flags, file paths, and the counter-intuitive bit. Generic advice ("check your config") is the failure mode here.

**Sanity check before writing.** The bar is transferability. Two questions settle it: would this help someone who has never seen this repo, and would it still be true in a year?

That rules out incidents, which is most of what a hard day produces. A bot re-triggering its own release, a sidecar breaking one app in preprod, a script that misfired once - those hurt, they got fixed, and the reasoning is already preserved in the commit, the PR, the ADR or the ticket. The repo remembers them. What belongs here is what survives being lifted out of that repo: a tool or technology understood for the first time, a process finding that holds generally, a durable behaviour that will bite again anywhere, a principle that changes how a class of problem gets approached.

"Stacked PRs don't survive a merge queue" is knowledge. "PR 431 got stuck" is not - and filing the second kind is how a wiki fills with things nobody ever reads again.

If what's offered is an incident, say so in one line and ask whether there's a general lesson underneath it - there often is, and it's usually the more interesting article. If it's genuinely thin, don't file it. Don't be precious though: when there's a real lesson there, write it.

## 2. Check it isn't already written

Search before creating, so you get one improving article per topic rather than four overlapping ones:

```bash
rg -il "<distinctive term>" ~/vault/wiki/
```

`rg` alone is unreliable here - the distinctive terms in a lesson are often either too common to filter or too specific to appear in an article title. Skim `wiki/_master-index.md` and the likely topic index too, since a scan of a couple of dozen one-line descriptions catches near-duplicates that a keyword search misses.

If a close article exists, extend it - add a section or bullets, and add or bump `updated: YYYY-MM-DD` in the frontmatter. Only create a new file when the lesson genuinely stands alone.

## 3. Write the article

Path: `~/vault/wiki/<topic-folder>/<Title Case Name>.md`

**Folder and tags are two separate decisions** - the wiki has more topic folders than there are canonical tags, so don't derive one from the other or you'll misfile things into a plausible-looking neighbour.

**Folder** - list what actually exists and pick the closest:

```bash
ls ~/vault/wiki/
```

For example `claude-code`, `agent-skills` and `llm-infrastructure` are real topics with articles in them, but none of the three is a canonical tag. A Claude Code lesson belongs in `claude-code/`, not in `ai-agents/`.

**Tags** - pick from this closed list, never invent one:
`index`, `openclaw`, `kubernetes`, `aws`, `gitops`, `ci-cd`, `observability`, `security`, `ai-agents`, `developer-tools`, `infrastructure`, `architecture`, `automation`, `knowledge-management`, `reference`, `kafka`, `performance`, `testing`

So a Claude Code hooks lesson lands in `wiki/claude-code/` tagged `[ai-agents]`.

**When a lesson spans several topics** - and the good ones usually do - file it under the system whose behaviour *caused* the problem, not the system that was affected. You'll come looking for it the next time that system misbehaves, not the next time you happen to be in the affected one. Use `## Related` wikilinks to reach it from the other angles.

Template:

```markdown
---
type: til
tags: [canonical-tag]
created: YYYY-MM-DD
source:
  - <URL only if a real one is relevant>
---

# <Title>

<One or two sentences: what you now know that you didn't this morning.>

## Key Takeaways

- The counter-intuitive bit, stated plainly
- The exact symptom, so future-you can grep for it
- The fix, in one line

## What Happened

<Symptom, what you tried, why it misled you. Keep it to a few bullets.>

## Fix

<Commands, config, or code. Exact.>

## Watch Out For

<Optional. The trap, adjacent gotchas, what you'd do differently.>

## Related

<Optional. [[Wikilinks]] to existing wiki articles.>
```

Notes on the template:

- `type: til` is what separates your own hard-won lessons from compiled articles clipped off the web. It's a frontmatter field rather than a tag because the vault's tag list is closed and this is metadata, not a topic.
- **Never invent a `source:` URL.** Most TILs are primary - you lived it, there is no source. Include URLs only where one genuinely applies: the GitHub issue, the PR, the doc page that was wrong, the Stack Overflow answer that finally helped. Otherwise omit the field entirely. A fabricated source is worse than no source because it sends future-you chasing a dead link.
- The `# <Title>` heading duplicates the filename, which the vault's root CLAUDE.md warns against for notes generally. Wiki articles are the deliberate exception - every existing one carries an H1, and matching them keeps the folder consistent. Keep it.
- Drop any section that would be empty. A three-line TIL that's all signal beats a padded one.
- Use `[[wikilinks]]` for anything that is or could be another vault note - this is what makes the graph work.

## 4. Update the indexes

An unlinked article is invisible to `vault-query` and to Obsidian's graph, so this step is what makes the capture actually pay off later.

**Topic index** - the file in that folder whose name is the Title Case form of the kebab-case folder name, tagged `[index, ...]`: `claude-code/Claude Code.md`, `llm-infrastructure/LLM Infrastructure.md`. Append a line:

```markdown
- [[Your Article Name]] — one-line description
```

**Master index** - `~/vault/wiki/_master-index.md`. Each topic line carries an article count, e.g. `(12 articles)`. Count the files rather than trusting the existing number - these have drifted before when articles were added without touching the indexes:

```bash
ls ~/vault/wiki/<topic-folder>/*.md | wc -l   # subtract 1 for the index file itself
```

**If no topic fits**, create the folder, a topic index tagged `[index, <tag>]`, and a new master index line. Rare - try hard to fit an existing topic first, because a wiki of one-article topics is just a folder of files.

## 5. Log it

Append to `~/vault/wiki/log.md`:

```markdown
## [YYYY-MM-DD] til | <Article Name>

- **Target**: `wiki/<topic-folder>/<Article Name>.md`
- **Action**: created | extended
```

## 6. Report back

One or two lines: what was captured, where it landed. Then get back to whatever you were doing - this skill interrupts real work, so it shouldn't linger.

Example: `Captured "CoreDNS NodeLocal Cache Stale Records" → wiki/kubernetes/, linked from [[Kubernetes]].`
