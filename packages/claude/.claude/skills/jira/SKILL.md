---
name: jira
description: Work with Jira issues via the `acli` CLI - view, search (JQL), create, edit, comment, transition status and link issues. Use whenever viewing, creating, editing or transitioning a Jira issue/ticket, or working with a Jira issue key (e.g. `PROJ-123`).
---

# Working with Jira via `acli`

`acli` is the Atlassian CLI. It drives Jira Cloud from the terminal,
authenticated as the current user (OAuth) against the configured site. Issue
keys are `<PROJECT>-<n>` (e.g. `PI-1288`). Verify access before relying on it:

```sh
acli jira workitem view <KEY>
```

Placeholders below (`<KEY>`, `<PROJECT>`, status names) are filled from the
issue you're working on and the target project's workflow.

## Operations

| Operation           | Command                                                                                                    |
| ------------------- | ---------------------------------------------------------------------------------------------------------- |
| View one item       | `acli jira workitem view <KEY> --fields "*all" --json`                                                     |
| View comments only  | `acli jira workitem view <KEY> --fields comment --json`                                                    |
| Search (JQL)        | `acli jira workitem search --jql "project = <PROJECT> AND status = 'In Progress'" --json`                  |
| Create              | `acli jira workitem create --project <PROJECT> --type Task --summary "..." --description "..."`            |
| Edit description    | `acli jira workitem edit --key <KEY> --description "..." --yes`                                             |
| Edit labels         | `acli jira workitem edit --key <KEY> --labels "a,b" --yes` (or `--remove-labels "a"`)                       |
| Assign              | `acli jira workitem assign --key <KEY> --assignee @me`                                                     |
| Transition status   | `acli jira workitem transition --key <KEY> --status "In Progress"`                                         |
| Comment             | `acli jira workitem comment create --key <KEY> --body "..."` (or `--body-file body.json` for ADF)           |
| Link issues         | `acli jira workitem link create --in <blocker> --out <blocked> --type Blocks --yes` (see gotcha below)      |
| List links          | `acli jira workitem link list --key <KEY>`                                                                  |
| Link type names     | `acli jira workitem link type`                                                                             |

Most write commands take `--yes` to skip the confirmation prompt and `--json`
for machine-readable output. `create` and `edit` also accept `--from-json` /
`--generate-json` to work from a full work-item JSON definition.

## Status names are exact

`--status` strings are case- and punctuation-exact: `Ready For Agent` (capital
`F`), `Won't Fix` (apostrophe), `Done (Complete)` (parenthesised). A mismatch
fails with `No allowed transitions found`. Jira has no separate "close" -
moving to a `Done`-category status closes the item. Only transitions allowed
from the item's current status will work; list the valid targets by viewing the
item's workflow if a transition is rejected.

## Dependencies and links

Record hard dependencies with `Blocks` links so blocked work reads as blocked:

```sh
# "PI-1288 blocks PI-1290" -> PI-1290 shows "is blocked by PI-1288"
acli jira workitem link create --in <blocker> --out <blocked> --type Blocks --yes
```

**`acli` reverses `--in`/`--out` for `Blocks`.** Despite the flag names, the
**blocker** goes in `--in` and the **blocked** item goes in `--out`. Getting
this backwards silently shows ready work as blocked and vice versa - always
verify after creating by viewing the _blocked_ item and confirming it reads "is
blocked by" the right key:

```sh
acli jira workitem view <blocked> --fields issuelinks --json \
  | jq -r '.fields.issuelinks[] | select(.type.name=="Blocks") |
      if .inwardIssue then "\(.inwardIssue.key) blocks <blocked>"
      else "<blocked> blocks \(.outwardIssue.key)" end'
```

Encode only _hard_ blockers, and skip transitive links a chain already implies.

**External (e.g. GitHub) dependencies.** `acli` only links items _within_ Jira.
To record a dependency on something outside Jira, add a comment with the full
URL stating the relationship and keep the item back until the upstream work
resolves.

## Bodies are ADF, not Markdown

Jira descriptions and comments are **ADF** (a JSON document tree). `acli`
accepts a body as plain text or ADF; anything else is stored verbatim, so
`**bold**`, `## heading`, `- bullet` and `| a | b |` render as those raw
characters.

- A bare, unformatted one-liner can go through `--description "..."` /
  `--body "..."` as-is.
- **Any formatting** (headings, lists, bold, code, links, tables) must be ADF.

To author formatted bodies, use the sibling **`jira-adf` skill**: write the body
in Markdown, convert it to an ADF JSON file, then pass the file to `acli`:

```sh
acli jira workitem edit --key <KEY> --description-file body.json --yes
acli jira workitem comment create --key <KEY> --body-file body.json
```

If you can't convert to ADF, fall back to plain-text bodies for unformatted
content, or hand-author the ADF JSON (`acli jira workitem edit --generate-json`
prints a skeleton).
