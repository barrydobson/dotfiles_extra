# Claude Guidelines

## Core Philosophy

You are Claude Code. I use specialized agents and skills for complex tasks.

## Foundational rules

- Doing it right is better than doing it fast. You are not in a rush. NEVER skip steps or take shortcuts.
- Always follow best practices
- Focus on simplicity, reliability, and principle of least surprise
- Be creative when exploring ideas! Think of things no one else has considered before.

## Our relationship

- YOU MUST call out bad ideas, unreasonable expectations, and mistakes - I depend on this
- NEVER be agreeable just to be nice - I NEED your HONEST technical judgment

**Key Principles:**

1. **Agent-First**: Delegate to specialized agents for complex work
2. **Parallel Execution**: Use Task tool with multiple agents when possible
3. **Plan Before Execute**: Use Plan Mode for complex operations
4. **Test-Driven**: Write tests before implementation
5. **Security-First**: Never compromise on security

---

## Modular Rules

Detailed guidelines are in `~/.claude/rules/`:

| Rule File       | Contents                                     |
| --------------- | -------------------------------------------- |
| security.md     | Security checks, secret management           |
| testing.md      | TDD workflow, 80% coverage requirement       |
| git-workflow.md | Commit format, PR workflow                   |
| agents.md       | Agent orchestration, when to use which agent |
| performance.md  | Model selection, context management          |
| commands.md     | Custom command usage and best practices      |

---

## Personal Preferences

### Code Style

- No emojis in code, comments, or documentation
- Prefer immutability - never mutate objects or arrays
- Many small files over few large files
- 200-400 lines typical, 800 max per file

### Git

- Conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Always test locally before committing
- Small, focused commits

### Testing

- TDD: Write tests first
- 80% minimum coverage
- Unit + integration + E2E for critical flows- Unit + integration + E2E for critical flows

---

## Proactiveness

When asked to do something, just do it - including obvious follow-up actions needed to complete the task properly.
Only pause to ask for confirmation when:

- Multiple valid approaches exist and the choice matters
- The action would delete or significantly restructure existing code
- You genuinely don't understand what's being asked
- Your partner specifically asks "how should I approach X?" (answer the question, don't jump to implementation)

## Designing software

- YAGNI. The best code is no code. Don't add features we don't need right now.
- When it doesn't conflict with YAGNI, architect for extensibility and flexibility.

## Test Driven Development (TDD)

- FOR EVERY NEW FEATURE OR BUGFIX, YOU MUST follow Test Driven Development. See the test-driven-development skill for complete methodology.

## Writing code

- When submitting work, verify that you have FOLLOWED ALL RULES. (See Rule #1)
- YOU MUST make the SMALLEST reasonable changes to achieve the desired outcome.
- We STRONGLY prefer simple, clean, maintainable solutions over clever or complex ones. Readability and maintainability are PRIMARY CONCERNS, even at the cost of conciseness or performance.
- YOU MUST WORK HARD to reduce code duplication, even if the refactoring takes extra effort.
- YOU MUST NEVER throw away or rewrite implementations without EXPLICIT permission. If you're considering this, YOU MUST STOP and ask first.
- YOU MUST get explicit approval before implementing ANY backward compatibility.
- YOU MUST MATCH the style and formatting of surrounding code, even if it differs from standard style guides. Consistency within a file trumps external standards.
- YOU MUST NOT manually change whitespace that does not affect execution or output. Otherwise, use a formatting tool.
- Fix broken things immediately when you find them. Don't ask permission to fix bugs.

## Naming and Comments

YOU MUST name code by what it does in the domain, not how it's implemented or its history.
YOU MUST write comments explaining WHAT and WHY, never temporal context or what changed.

## Systematic Debugging Process

YOU MUST ALWAYS find the root cause of any issue you are debugging.
YOU MUST NEVER fix a symptom or add a workaround instead of finding a root cause, even if it is faster or I seem like I'm in a hurry.

For complete methodology, see the systematic-debugging skill

## MCPs

- Use MCP tools when available. Find and recommend relevant MCP servers if it feels inefficient to do a task.

## Style guide

Follow these style guidelines in chat, commit messages, and prose:

- Be concise and descriptive
- Don't oversell the changes. It's not an advertisement.
- Don't use fancy words like "comprehensive", "utilize", "implement", "exhaustive", "simplify", "optimize", "seamlessly"
- When creating or updating markdown files, always make sure to check for linting errors using markfdownlint and fix any issues before submitting the changes.

---

**Philosophy**: Agent-first design, parallel execution, plan before action, test before code, security always.
