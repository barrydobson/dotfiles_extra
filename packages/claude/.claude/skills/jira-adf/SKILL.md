---
name: jira-adf
description: Convert Markdown to Atlassian Document Format (ADF) for Jira ticket bodies. Use whenever creating or editing a Jira issue/PRD description or a comment via acli that needs formatting (headings, lists, bold, code, links, tables) - Jira stores anything that is not ADF as literal text, so plain Markdown renders with raw ** and # characters.
---

# Jira ADF bodies

Jira Cloud descriptions and comments are **ADF** (Atlassian Document Format - a JSON
document tree), not Markdown and not Wiki Markup. `acli` accepts a body as plain text
or ADF; anything else is stored verbatim, so `**bold**`, `## heading`, `- bullet` and
`| a | b |` show up as those raw characters. Author in Markdown, convert to ADF, pass
the JSON to `acli`.

## Convert

`tools/md2adf.mjs` is a self-contained bundle - it needs Node but **no**
`npm install` and no `node_modules`. It reads a Markdown file (or stdin) and
writes ADF JSON to stdout. Run it by absolute path from anywhere. `$SKILL_DIR`
is this skill's base directory, printed at launch:

```sh
node "$SKILL_DIR/tools/md2adf.mjs" brief.md > body.json
# or pipe:
cat brief.md | node "$SKILL_DIR/tools/md2adf.mjs" > body.json
```

## The three patterns

Create / edit a description take `--description-file`; comments take `--body-adf`.

```sh
# 1. Create a work item with a formatted description
node "$SKILL_DIR/tools/md2adf.mjs" brief.md > body.json
acli jira workitem create --project PI --type Story --label development-metrics \
  --parent PI-<epic> --summary "..." --description-file body.json

# 2. Edit an existing description
acli jira workitem edit --key PI-<n> --description-file body.json --yes

# 3. Update (or create) a comment
acli jira workitem comment update --key PI-<n> --id <commentId> --body-adf body.json
acli jira workitem comment create --key PI-<n> --body-file body.json   # body-file accepts ADF
```

A bare one-line body with no formatting can skip conversion and use `--description "..."`
or `--body "..."` directly.

## Notes

- This skill only converts Markdown to ADF and shows the acli patterns. Ticket workflow
  (labels, parent, transitions, any disclaimer text) is out of scope - handle that
  separately and add such text to the Markdown source before converting.
- marklassian covers headings, lists, tables, code blocks, blockquotes, bold/italic/code
  and links. If a body needs an ADF node it does not emit (e.g. panels, status lozenges),
  hand-edit the JSON or extend the converter.
- **Separate blocks with a blank line.** A single newline is a Markdown soft break, so
  consecutive lines collapse into one paragraph and marklassian drops the break entirely -
  `**Category:** x\n**Summary:** y` renders as `xSummary:` glued together in Jira. Put a
  blank line between logical lines (or make them a bullet list) to keep them as separate blocks.
