---
name: vault-query
description: Query the wiki knowledge base and optionally save results. Use when the user asks a question about topics covered in the wiki, wants to search the knowledge base, asks "what do we know about X", or wants to generate a report from wiki content. Also trigger when the user wants to save a conversation insight as a wiki article.
---

# Wiki Query

Answer questions by navigating the wiki's hierarchical indexes, reading relevant articles, and synthesizing an answer with citations.

## Location of wiki

The wiki is located in an Obsidian vault at `~/vault`

## Execution model

Handle queries directly (no subagent needed — queries are conversational and benefit from back-and-forth with the user).

## How to query

### 1. Navigate the indexes

Read `wiki/_master-index.md` to identify which topics are relevant to the question. Then read those topics' index files to find specific articles. Read the articles that are most likely to contain the answer.

Don't read everything — be targeted. The index hierarchy exists to avoid full scans.

### 2. Synthesize the answer

Combine information from the articles into a coherent answer. Always cite sources using `[[wikilinks]]` so the user can drill into the underlying articles.

If the answer requires information from multiple topics, explicitly note which articles contributed to each part of the synthesis.

If the wiki doesn't have enough information to fully answer the question, say so clearly — identify what's covered and what's missing. Suggest whether the gap could be filled by:

- A web search for new source material
- Compiling existing raw files that might cover the topic
- Creating a new article to capture the user's own knowledge

### 3. Offer to save

After answering, if the synthesis produced something valuable (a comparison, an analysis, a connection between topics that wasn't previously documented), offer to save it. There are two options:

**As a wiki article** — if the answer represents durable knowledge that will be useful in future queries. Save it in the appropriate topic folder following the standard article format. Use only canonical tags from CLAUDE.md — do not invent new tags. Update the topic index and master index.

**As an output file** — if the answer is more situational (a one-off comparison, a report for a specific purpose). Save to `output/YYYY-MM-DD-descriptive-name.md` with frontmatter:

```yaml
---
tags: [output, topic-tag]
created: YYYY-MM-DD
query: "the original question"
---
```

If the user declines to save, that's fine — not every answer needs to be persisted.

### 4. Log the query

Append an entry to `wiki/log.md`:

```markdown
## [YYYY-MM-DD] query | Brief description of the question

- **Articles consulted**: [[Article 1]], [[Article 2]], ...
- **Result**: answered / partial (gap identified) / saved as wiki article / saved as output
```

## Output formats

The default output is inline markdown in the conversation. But if the user asks for a specific format, support:

- **Table** — comparison or structured data as a markdown table
- **Report** — longer-form analysis saved to `output/`
- **Article** — distilled into wiki article format for filing
