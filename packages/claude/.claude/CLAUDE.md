# Claude Guidelines

Global defaults. Project CLAUDE.md files augment these.

@CLAUDE.local.md

## How to talk to me

- Call out bad ideas, unreasonable expectations, and mistakes - I depend on it.
- Never be agreeable to be nice. I need honest technical judgement.
- Skip flattery. No "You're absolutely right", no "Great question!". Respond directly.
- Use `/vault-query` when my personal knowledge base is relevant.
- Prefer Parallel AI (`parallel-web-search` skill) over `WebSearch` for web searches.

## Think before coding

State assumptions. If uncertain, ask. If multiple interpretations exist, present them - don't pick silently. If a simpler approach exists, say so.

## Simplicity first

Minimum code that solves the problem. Nothing speculative.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- 200 lines that could be 50 → rewrite as 50.

Test: would a senior engineer say this is overcomplicated?

## Surgical changes

Touch only what you must. Every changed line should trace to the request.

- Don't improve adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style even if you'd do it differently.
- Notice unrelated dead code → mention it, don't delete.
- Remove imports/variables your changes orphaned. Leave pre-existing dead code alone.

## Goal-driven execution

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, make them pass"
- "Fix the bug" → "Write a test that reproduces it, make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step work, state a plan with verification for each step. Strong success criteria let you loop independently; weak criteria ("make it work") require constant clarification.

## Code quality

### Zero warnings

Fix every warning from every tool - linters, type checkers, compilers, tests. If truly unfixable, add inline ignore with justification. Clean output is the baseline, not the goal.

### Comments

Code should be self-documenting. No commented-out code - delete it. If you need a comment to explain WHAT, refactor instead. Comments are for WHY.

### Error handling

- Fail fast with clear, actionable messages
- Never swallow exceptions silently
- Include context: what operation, what input, suggested fix

### Testing

**Test behaviour, not implementation.** A refactor that breaks tests but not code means the tests were wrong.

**Test edges and errors, not just happy path.** Empty inputs, boundaries, malformed data, missing files, network failures - bugs live at edges.

**Mock boundaries, not logic.** Only mock slow things (network, filesystem), non-deterministic things (time, randomness), or external services.

**Verify tests catch failures.** Break the code, confirm test fails, fix.

## Development

Always look up current stable versions - never assume from memory - when adding dependencies, CI actions, or tool versions.

### CLI tools

| tool | replaces | usage |
| ---- | -------- | ----- |
| `rg` (ripgrep) | grep | `rg "pattern"` |
| `ast-grep` | - | `ast-grep --pattern '$FUNC($$$)' --lang py` |
| `shellcheck` | - | `shellcheck script.sh` |
| `shfmt` | - | `shfmt -i 2 -w script.sh` |
| `wt` | git worktree | `wt switch branch` |
| `trash` | rm | `trash file` - **never `rm -rf`** |
| `prek` | pre-commit | `prek run` |

Prefer `ast-grep` for code structure (function calls, class definitions, imports). Ripgrep for literal strings and log messages.

## Workflow

- If we are on the main/master branch and making changes, stop. Use worktrees. Our default place for git worktrees is in the `.worktrees` directory at the repo root.

**Before committing:**

1. Re-read changes for unnecessary complexity, redundant code, unclear naming
2. Run relevant tests - not the full suite
3. Run linters and type checker - fix everything

**Commits:**

- Conventional: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`
- Imperative mood, ≤72 char subject, one logical change per commit
- Never amend/rebase commits pushed to shared branches
- Never push directly to main - branches and PRs
- Never commit secrets - `.env` (gitignored) and environment variables

**Hooks and worktrees:**

- `prek install` in every repo. `prek run` before committing. `prek auto-update --cooldown-days 7`.
- Parallel subagents require worktrees - each in its own `wt switch <branch>`, never share working directories.

**Pull requests:**

If the repository supports PR templates, use them.
Describe what the code does now - not discarded approaches, prior iterations, or alternatives. Plain factual language. A bug fix is a bug fix, not a "critical stability improvement." Avoid: critical, crucial, essential, significant, comprehensive, robust, elegant.

## Never

- **Time estimates.** Inherently unreliable; encourages speed over quality. Break work into testable outcomes instead.
- **Complex heredocs.** Use the Task tool.
- **Non-idempotent scripts.** All setup/install scripts must be safely re-runnable.
- **State tracking files.** Detect state from the system directly.
- **`rm -rf`.** Use `trash`.
- **Committing without explicit request.**
- **Proactive file creation.**
- **Em dashes (—).** Use hyphens (-) instead.
