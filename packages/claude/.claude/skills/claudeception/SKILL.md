---
name: claudeception
description: |
  Use when: (1) /claudeception command to review session learnings, (2) user says "save this
  as a skill" or "extract a skill from this", (3) user asks "what did we learn?", (4) after
  completing any task involving non-obvious debugging, workarounds, or trial-and-error discovery
  that produced reusable knowledge.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - Skill
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# Claudeception

A continuous learning system that extracts reusable knowledge from work sessions and codifies it into Claude Code skills, enabling autonomous improvement over time.

## Core Principle: Skill Extraction

Continuously evaluate whether current work contains extractable knowledge worth preserving. Be selective—not every task produces a skill.

## When to Extract a Skill

Extract a skill when encountering:

| Type                       | Description                                                             |
| -------------------------- | ----------------------------------------------------------------------- |
| **Non-obvious Solutions**  | Debugging techniques or workarounds requiring significant investigation |
| **Project Patterns**       | Codebase-specific conventions not documented elsewhere                  |
| **Tool Integration**       | Undocumented ways to use tools, libraries, or APIs                      |
| **Error Resolution**       | Misleading error messages with non-obvious root causes                  |
| **Workflow Optimizations** | Multi-step processes that can be streamlined                            |

## When NOT to Extract a Skill

**Don't extract when:**

- Solution is in official documentation (link to it instead)
- One-off fix unlikely to recur
- Standard practice well-known to developers
- Project-specific config that belongs in CLAUDE.md
- Mechanical constraint enforceable by code (automate it instead)

**Red flags you're over-extracting:**

- "This might be useful someday" - Extract when needed, not speculatively
- "I'll document everything I learned" - Focus on non-obvious insights only
- "Better to have it than not" - Skills have maintenance cost; be selective

**Common mistake:** Extracting knowledge that's easily found via web search or official docs. Skills should capture what documentation DOESN'T cover well.

## Quality Criteria

Before extracting, verify the knowledge meets these criteria:

- **Reusable**: Will this help with future tasks? (Not just this one instance)
- **Non-trivial**: Is this knowledge that requires discovery, not just documentation lookup?
- **Specific**: Can you describe the exact trigger conditions and solution?
- **Verified**: Has this solution actually worked, not just theoretically?

## Extraction Process

### Step 1: Identify the Knowledge

Analyze what was learned:

- What was the problem?
- What was non-obvious about the solution?
- What are the exact trigger conditions (error messages, symptoms)?

### Step 2: Research Best Practices

For technology-specific topics, search the web for current best practices before creating the skill. See `resources/research-workflow.md` for detailed search strategies.

Skip searching for project-specific internal patterns or stable programming concepts.

### Step 3: Structure the Skill

**CRITICAL - CSO (Claude Search Optimization):**
The description field determines whether Claude finds and loads your skill.

- Start with "Use when:" to focus on triggers
- Include specific symptoms, error messages, contexts
- NEVER summarize what the skill does or its workflow
- Keep under 500 characters

**Why this matters:** Testing revealed that descriptions summarizing workflow cause Claude to follow the description instead of reading the full skill. A description saying "validates and creates files" caused Claude to skip the skill body entirely.

Use the template in `resources/skill-template.md`. Key sections:

```markdown
---
name: [descriptive-kebab-case-name]
description: |
  Use when: (1) [specific trigger condition], (2) [symptom or error message],
  (3) [context that signals this skill applies]. Include keywords users would
  naturally say. NEVER summarize what the skill does - only when to use it.
---

# Skill Name

## Overview

## When to Use

## When NOT to Use

## Solution

## Quick Reference

## Common Mistakes

## Verification

## Notes

## References
```

### Step 4: Write Effective Descriptions

The description field is critical for skill discovery. Include:

- **Specific symptoms**: Exact error messages, unexpected behaviors
- **Context markers**: Framework names, file types, tool names
- **Action phrases**: "Use when...", "Helps with...", "Solves..."

**Good example:**

```yaml
description: |
  Fix for "ENOENT: no such file or directory" in monorepo npm scripts.
  Use when: (1) npm run fails with ENOENT in workspace, (2) paths work
  in root but not packages. Covers Lerna, Turborepo, npm workspaces.
```

### Step 5: Apply CSO (Claude Search Optimization)

**Why CSO matters:** Claude reads skill descriptions to decide which skills to load. Poor descriptions = skills never found.

**The Critical Rule:**

> Description = WHEN to use, NOT WHAT it does

**CSO Violation Examples:**

| Bad (summarizes workflow)                  | Good (triggers only)                                 |
| ------------------------------------------ | ---------------------------------------------------- |
| "Validates tokens and handles auth errors" | "Use when auth fails with 401/403 or token expired"  |
| "Creates skills from session learnings"    | "Use when task required non-obvious investigation"   |
| "Runs tests and reports coverage"          | "Use when tests fail unexpectedly or coverage drops" |

**Why this matters:** Testing revealed that when descriptions summarize workflow, Claude may follow the description instead of reading the full skill. The skill body becomes documentation Claude skips.

**Keyword Coverage:**
Include words Claude would search for:

- Error messages: "ENOENT", "401 Unauthorized", "timeout"
- Symptoms: "flaky", "hangs", "silent failure"
- Tools/frameworks: "Next.js", "Prisma", "Jest"
- Synonyms: "timeout/hang/freeze", "auth/authentication/login"

**Token Efficiency:**

- Keep SKILL.md under 500 lines
- Move heavy reference material to separate files
- Use cross-references instead of duplicating content

### Step 6: Save the Skill

Save new skills to the appropriate location:

- **Project-specific skills**: `.claude/skills/[skill-name]/SKILL.md`
- **User-wide skills**: `~/.claude/skills/[skill-name]/SKILL.md`

Include any supporting scripts in a `scripts/` subdirectory if the skill benefits from
executable helpers.

## Retrospective Mode

When `/claudeception` is invoked at the end of a session:

1. **Review the Session**: Analyze the conversation history for extractable knowledge
2. **Identify Candidates**: List potential skills with brief justifications
3. **Prioritize**: Focus on the highest-value, most reusable knowledge
4. **Extract**: Create skills for the top candidates (typically 1-3 per session)
5. **Summarize**: Report what skills were created and why

## Automatic Triggers

Invoke this skill immediately after completing a task when ANY apply:

- Solution required >10 minutes of investigation not found in docs
- Fixed an error where the message was misleading
- Found a workaround requiring experimentation
- Discovered project-specific setup differing from standard patterns
- Tried multiple approaches before finding what worked

## Explicit Invocation

Also invoke when:

- User runs `/claudeception` to review the session
- User says "save this as a skill" or similar
- User asks "what did we learn?"

## Self-Check After Each Task

After completing any significant task, ask yourself:

- "Did I just spend meaningful time investigating something?"
- "Would future-me benefit from having this documented?"
- "Was the solution non-obvious from documentation alone?"

If yes to any, invoke this skill immediately.

## Common Mistakes

### Mistake 1: Over-extraction

**Problem:** Extracting every solution, creating maintenance burden
**Fix:** Apply quality gates strictly - reusable AND non-trivial AND verified

### Mistake 2: Vague descriptions

**Problem:** "Helps with React problems" won't surface when needed
**Fix:** Include specific triggers, error messages, symptoms

### Mistake 3: Workflow summaries in description

**Problem:** Claude follows description instead of reading skill body
**Fix:** Description contains ONLY trigger conditions, never workflow

### Mistake 4: Unsupported frontmatter fields

**Problem:** Adding author/version/date fields that Claude ignores
**Fix:** Only use `name`, `description`, and supported fields like `allowed-tools`

### Rationalization Table

| Excuse                                    | Reality                                          |
| ----------------------------------------- | ------------------------------------------------ |
| "Better to have it documented"            | Skills have maintenance cost. Be selective.      |
| "This might be useful someday"            | Extract when needed, not speculatively.          |
| "I'll be thorough and add all fields"     | Extra fields are ignored. Follow spec exactly.   |
| "Description should explain what it does" | Description is for discovery, not documentation. |
| "Official docs are too long to read"      | Skills complement docs, don't replace them.      |

## Additional Resources

### Reference Files

Consult these for detailed guidance:

| File                               | Contents                                      |
| ---------------------------------- | --------------------------------------------- |
| `resources/skill-template.md`      | Complete skill template with checklist        |
| `resources/research-workflow.md`   | Web research strategies and citation format   |
| `resources/quality-guidelines.md`  | Quality gates, anti-patterns, skill lifecycle |
| `resources/research-references.md` | Academic background (Voyager, CASCADE, etc.)  |

### Working Examples

Real extracted skills in `examples/`:

- `nextjs-server-side-error-debugging/` — Server-side error debugging
- `typescript-circular-dependency/` — Import cycle resolution

Study these as models for effective skill structure.
