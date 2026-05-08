# Code quality

Detail for the summary in `~/.claude/CLAUDE.md`. Consult when writing or reviewing code.

## Zero warnings

Fix every warning from every tool - linters, type checkers, compilers, tests. Clean output is the baseline, not the goal.

If truly unfixable, add an inline ignore with a one-line justification. No bulk-disabling, no file-level suppressions to silence noise.

## Comments

Code should be self-documenting via naming and structure.

- No commented-out code. Delete it - git remembers.
- Comments explain WHY, never WHAT. If you need a comment to describe what a block does, refactor instead.
- No restating the task ("added for ticket X", "used by Y") - belongs in the PR.
- No multi-line docstrings on internal functions unless the contract is non-obvious.

## Error handling

- Fail fast with clear, actionable messages.
- Never swallow exceptions silently. No empty `catch` blocks.
- Include context in errors: what operation, what input, suggested fix.
- Don't validate impossible cases. Trust internal callers; validate only at system boundaries (user input, external APIs).
- No fallbacks for scenarios that can't happen.
