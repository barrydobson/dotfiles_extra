# Claude Guidelines

Global defaults. Project CLAUDE.md files augment.

<!-- prettier-ignore -->
@~/.claude/me.md
@~/.claude/work.md

## Writing guidelines

These apply to documentation, code comments, commit and PR messages, and replies to the user.

- Write precisely in clear, complete sentences; keep text concise and proportional to task complexity.
- Stay focused: avoid filler, repetition, over-the-top detail, and tangents the user did not ask for. Once a fact is stated, do not restate it for effect ("so the commit landed on a branch nobody was going to merge"). Do not editorialise.
- Always prefer ISO 24495-1:2023 conformant plain language over dense technical jargon: short sentences, one idea per sentence, define terms on first use.
- When reporting your own mistake, give the cause and the fix in one sentence each; no apology, no framing ("the mistake was mine"), no post-mortem.
- Never use em dashes or cataphoric teasers such as "Here's the thing" or "But there's a catch".

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

# High-risk changes (migrations, auth, refactors, breaking)

Research first, no code. State the plan - what changes, risks, rollback - and get sign-off before implementing.

## Detailed rules (load when relevant)

- **Testing** (behaviour, edges, mocks, red-green) → `~/.claude/rules/testing.md`
- **Workflow** (branches, commits, PRs) → `~/.claude/rules/workflow.md`

Read relevant file before writing tests, opening PR, committing.

## Tracer Bullets

When building features, build a tiny end-to-end slice through every layer first, seek feedback, then expand. Feedback early beats architecture on paper.

## CLI tools

| tool           | replaces | usage                                       |
| -------------- | -------- | ------------------------------------------- |
| `rg` (ripgrep) | grep     | `rg "pattern"`                              |
| `ast-grep`     | -        | `ast-grep --pattern '$FUNC($$$)' --lang py` |
| `shellcheck`   | -        | `shellcheck script.sh`                      |
| `shfmt`        | -        | `shfmt -i 2 -w script.sh`                   |
| `trash`        | rm       | `trash file` - **never `rm -rf`**           |

`ast-grep` for code structure. `rg` for literals, log messages. Always look up current stable versions when adding dependencies, CI actions, tool versions.

## Never

- **Time estimates.** Break work into testable outcomes.
- **Complex heredocs.** Use Task tool.
- **Non-idempotent setup/install scripts.**
- **State tracking files.** Detect state from system.
- **Em dashes (—).** Use hyphens.

## Gotchas

- When I merge pull requests I use squash-merge. This means that the commit history of the PR is not preserved in the main branch.

## AI & Automation Rules

- Minimize API calls. Batch where possible.
- Design for idempotency. Same input = same result.
- Add retries with exponential backoff on transient errors.
- Always validate AI output structure before using it.
- Never trust raw LLM output. Parse and validate every field.
- Prefer structured outputs (JSON schema) over free text.
- Log meaningful errors with context, not just "AI call failed".
- Ground responses in available data. Avoid hallucination by limiting scope.
