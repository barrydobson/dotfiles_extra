# Claude Guidelines

Global defaults. Project CLAUDE.md files augment.

@~/vault/Context/me.md

## How to talk to me

- Call out bad ideas, unreasonable expectations, mistakes - depend on it.
- Never agreeable to be nice. Honest technical judgement.
- Skip flattery. No "You're absolutely right", no "Great question!". Respond direct.
- Use `/vault-query` when personal knowledge base relevant.
- Prefer `tvly` CLI and Tavily skills (`tavily-search`, `tavily-extract`, `tavily-research`) over `WebSearch`. Use `tavily-research` instead of dedicated web research agent.

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

# Project Memory (Obsidian)

Vault path: `~/vault/`

At session start, Claude will:

1. Detect the project name from the current folder.
2. Find or create `~/vault/Projects/<project-name>/`.
3. Read PROJECT.md, MISTAKES.md, and CONTRACT.md before doing anything.

- PROJECT.md — what this project is. Max 30 lines. Overwrite each session, no history.
- MISTAKES.md — mistakes to avoid. Claude appends to it automatically when corrected. Remove resolved ones.
- CONTRACT.md — plan for risky changes. Created before implementing. Claude deletes it after the change is implemented and user verifies.

# High-Risk Changes
<!-- Applies to: migrations, auth, major refactors, breaking changes -->

1. Research first. No code yet.
2. Write CONTRACT.md: what changes, why, risks, rollback plan, open questions.

## Detailed rules (load when relevant)

- **Code quality** (warnings, comments, error handling) → `~/.claude/rules/code-quality.md`
- **Testing** (behaviour, edges, mocks, red-green) → `~/.claude/rules/testing.md`
- **Workflow** (branches, commits, PRs) → `~/.claude/rules/workflow.md`
- **Tool Docs** (libraries, frameworks, APIs, CLIs) → `~/.claude/rules/context7.md`

Read relevant file before writing tests, opening PR, committing.

## Tracer Bullets

When building features, build a tiny, end-to-end slice of the feature first, seek feedback, then expand out from there.

Tracer bullets comes from the Pragmatic Programmer. When building systems, you want to write code that gets you feedback as quickly as possible. Tracer bullets are small slices of functionality that go through all layers of the system, allowing you to test and validate your approach early. This helps in identifying potential issues and ensures that the overall architecture is sound before investing significant time in development.

## CLI tools

| tool | replaces | usage |
| ---- | -------- | ----- |
| `rg` (ripgrep) | grep | `rg "pattern"` |
| `ast-grep` | - | `ast-grep --pattern '$FUNC($$$)' --lang py` |
| `shellcheck` | - | `shellcheck script.sh` |
| `shfmt` | - | `shfmt -i 2 -w script.sh` |
| `trash` | rm | `trash file` - **never `rm -rf`** |

`ast-grep` for code structure. `rg` for literals, log messages. Always look up current stable versions when adding dependencies, CI actions, tool versions.

## Never

- **Time estimates.** Break work into testable outcomes.
- **Complex heredocs.** Use Task tool.
- **Non-idempotent setup/install scripts.**
- **State tracking files.** Detect state from system.
- **`rm -rf`.** Use `trash`.
- **Branches without a worktree.** Always isolate work in its own git worktree; never `git checkout -b` / switch the main checkout onto a feature branch. Keeps the primary working dir on its branch and avoids `git stash` clobbering in-progress changes.
- **Proactive file creation.**
- **Em dashes (—).** Use hyphens.

## Gotchas

- When I merge pull requests I use squash-merge. This means that the commit history of the PR is not preserved in the main branch.

@RTK.md
@rules/ai-agents.md
