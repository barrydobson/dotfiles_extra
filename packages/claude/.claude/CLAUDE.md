# Claude Guidelines

Global defaults. Project CLAUDE.md files augment.

@~/vault/Context/me.md

## How to talk to me

- Call out bad ideas, unreasonable expectations, mistakes - depend on it.
- Never agreeable to be nice. Honest technical judgement.
- Skip flattery. No "You're absolutely right", no "Great question!". Respond direct.
- Use `/vault-query` when personal knowledge base relevant.
- Prefer `tvly` CLI and Tavily skills (`tavily-search`, `tavily-extract`, `tavily-crawl`, `tavily-map`, `tavily-research`, `tavily-dynamic-search`) over `WebSearch`. Use `tavily-research` instead of dedicated web research agent.

## Think before coding

State assumptions. Uncertain? Ask. Multiple interpretations? Present - no silent pick. Simpler approach? Say so.

## Scope discipline

Touch only what request requires. Every changed line traces to task.

- No features, abstractions, configurability, error handling beyond ask.
- No refactor, reformat, improve adjacent code. Match existing style.
- Unrelated dead code → mention, no delete. Remove only what changes orphaned.
- 200 lines could be 50 → write 50.

Senior-engineer test: look overcomplicated?

## Goal-driven execution

Convert tasks to verifiable goals. "Fix bug" → "Write failing test, make pass." Multi-step work: state plan with verification per step.

## Detailed rules (load when relevant)

- **Code quality** (warnings, comments, error handling) → `~/.claude/rules/code-quality.md`
- **Testing** (behaviour, edges, mocks, red-green) → `~/.claude/rules/testing.md`
- **Workflow** (branches, prek, commits, PRs) → `~/.claude/rules/workflow.md`

Read relevant file before writing tests, opening PR, committing.

## CLI tools

| tool | replaces | usage |
| ---- | -------- | ----- |
| `rg` (ripgrep) | grep | `rg "pattern"` |
| `ast-grep` | - | `ast-grep --pattern '$FUNC($$$)' --lang py` |
| `shellcheck` | - | `shellcheck script.sh` |
| `shfmt` | - | `shfmt -i 2 -w script.sh` |
| `wt` | git worktree | `wt switch branch` |
| `trash` | rm | `trash file` - **never `rm -rf`** |
| `prek` | pre-commit | `prek run` |

`ast-grep` for code structure. `rg` for literals, log messages. Always look up current stable versions when adding dependencies, CI actions, tool versions.

## Never

- **Time estimates.** Break work into testable outcomes.
- **Complex heredocs.** Use Task tool.
- **Non-idempotent setup/install scripts.**
- **State tracking files.** Detect state from system.
- **`rm -rf`.** Use `trash`.
- **Commit without explicit request.**
- **Proactive file creation.**
- **Em dashes (—).** Use hyphens.