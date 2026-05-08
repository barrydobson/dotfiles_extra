# Workflow

Detail for the summary in `~/.claude/CLAUDE.md`. Consult before committing, opening PRs, or setting up a repo.

## Branch protection

- Never make changes directly on `main` / `master`. Stop and switch to a worktree.
- Parallel subagents require worktrees - each in its own directory. Never share working directories.

## Pre-commit hooks (`prek`)

- `prek install` in every repo when starting work there.
- `prek run` before committing.
- `prek auto-update --cooldown-days 7` to keep hooks current without churn.

## Before committing

1. Re-read the diff for unnecessary complexity, redundant code, unclear naming.
2. Run relevant tests - not the full suite.
3. Run linters and type checker. Fix everything.

## Commits

- Conventional prefix: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
- Imperative mood. Subject ≤72 chars.
- One logical change per commit.
- Never amend or rebase commits already pushed to a shared branch.
- Never push directly to `main` - always via branch + PR.
- Never commit secrets. `.env` is gitignored; use environment variables.

## Pull requests

- Use the repository's PR template if it has one.
- Describe what the code does now. Not discarded approaches, prior iterations, or alternatives - those belong in the commit history if anywhere.
- Plain factual language. A bug fix is a bug fix, not a "critical stability improvement."
- Avoid these words: critical, crucial, essential, significant, comprehensive, robust, elegant.

## Hooks failing during commit

If a pre-commit hook fails, the commit did not happen. Fix the underlying issue, re-stage, and create a NEW commit. Do not `--amend` (the previous commit is unrelated) and do not `--no-verify` to bypass.
