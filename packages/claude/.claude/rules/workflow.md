# Workflow

Detail for the summary in `~/.claude/CLAUDE.md`. Consult before committing, opening PRs, or setting up a repo.

## Branch protection

- Ticket/feature work on shared repos: worktree, never on `main`/`master`. Small doc/config edits and solo repos: `main` is fine. Unsure? Ask.
- Parallel subagents require worktrees - each in its own directory. Never share working directories.
- Create worktrees in the projects `.claude/worktrees` directory. This keeps them out of the way and makes it easy to find them later.

## Before committing

1. Re-read the diff for unnecessary complexity, redundant code, unclear naming.
2. Run relevant tests - not the full suite.
3. Run linters and type checker. Fix everything.

Unless the repo's CLAUDE.md says that hooks already run them.

## Commits

- Conventional prefix: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`.
- Imperative mood. Subject ≤72 chars.
- One logical change per commit.
- Never amend or rebase commits already pushed to a shared branch.
- Never push directly to `main` - always via branch + PR Unless the repo's CLAUDE.md says otherwise
- Never commit secrets. `.env` is gitignored; use environment variables.

## Pull requests

- Use the repository's PR template if it has one.
- Describe what the code does now. Not discarded approaches, prior iterations, or alternatives - those belong in the commit history if anywhere.
- Plain factual language. A bug fix is a bug fix, not a "critical stability improvement."
- Avoid these words: critical, crucial, essential, significant, comprehensive, robust, elegant.

## Hooks failing during commit

If a pre-commit hook fails, the commit did not happen. Fix the underlying issue, re-stage, and create a NEW commit. Do not `--amend` (the previous commit is unrelated) and do not `--no-verify` to bypass.
