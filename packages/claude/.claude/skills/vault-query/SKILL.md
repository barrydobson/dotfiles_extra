---
name: vault-query
description: Query the wiki knowledge base and optionally save results. Use when the user asks a question about topics covered in the wiki, wants to search the knowledge base, asks "what do we know about X", or wants to generate a report from wiki content. Also trigger when the user wants to save a conversation insight as a wiki article.
---

# Wiki Query

Answer questions by navigating the wiki's hierarchical indexes, reading relevant articles, and synthesizing an answer with citations.

## Where the wiki is

The wiki lives in an Obsidian vault at `~/vault`, and this skill is user-level so the question usually gets asked from somewhere else entirely. **Every path below is absolute against `~/vault`** - relative paths only work in the minority case where the vault happens to be the working directory, and they fail silently the rest of the time by finding nothing and looking like an empty wiki.

If a read or write to `~/vault` is refused, `permissions.additionalDirectories` in `~/.claude/settings.json` is missing `~/vault`. Say so rather than answering from memory as though the wiki were empty.

## Execution model

Handle queries directly (no subagent needed — queries are conversational and benefit from back-and-forth with the user).

## How to query

### 1. Navigate the indexes

Read `~/vault/wiki/_master-index.md` to identify which topics are relevant to the question. Each topic folder holds a hub note named after the topic (`~/vault/wiki/kafka/Kafka.md`, `~/vault/wiki/gitops/GitOps.md`) listing every article in that folder with a one-line description. Read the hub notes for the relevant topics, then the articles most likely to contain the answer.

Don't read everything — be targeted. The index hierarchy exists to avoid full scans.

### 2. Synthesize the answer

Combine information from the articles into a coherent answer. Always cite sources using `[[wikilinks]]` so the user can drill into the underlying articles.

If the answer requires information from multiple topics, explicitly note which articles contributed to each part of the synthesis.

If the wiki doesn't have enough information to fully answer the question, say so clearly — identify what's covered and what's missing. Suggest whether the gap could be filled by:

- A web search for new source material
- Compiling existing raw files that might cover the topic
- Creating a new article to capture the user's own knowledge

### 3. Offer to save

After answering, if the synthesis produced something durable — a comparison, an analysis, a connection between topics that wasn't previously documented — offer to save it as a wiki article in the appropriate topic folder.

Read `~/vault/wiki/CLAUDE.md` first. It holds the article format and the closed canonical tag list, and from outside the vault it does not load on its own. Never invent a tag. Then update the topic hub note, and the master index only if you added a whole new topic.

If the answer was situational rather than durable, don't save it. The vault has no home for one-off reports, and filing them anyway is how a wiki fills with things nobody reads again. Answering well in the conversation is the whole job most of the time.

### 4. Log the query

Never edit the log by hand. `wiki/log.md` is a pointer, not the log itself; the real log is `wiki/logs/<year>.md`, and the script picks the right year file, creates it on rollover, and always appends in the same direction:

```bash
~/vault/.claude/scripts/wiki-log.sh query "<brief description of the question>" <<'BODY'
- **Articles consulted**: [[Article 1]], [[Article 2]], ...
- **Result**: answered | partial (gap identified) | saved as wiki article
BODY
```

Writing the entry by hand is what broke this log before: "append an entry" is ambiguous once a file has entries at both ends, so they drifted to both.

## Output formats

The default output is inline markdown in the conversation. If the user asks for something specific, support:

- **Table** — comparison or structured data as a markdown table
- **Article** — distilled into wiki article format and filed, as in step 3
