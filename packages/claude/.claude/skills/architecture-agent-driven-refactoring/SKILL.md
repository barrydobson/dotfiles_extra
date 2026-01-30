---
name: architecture-agent-driven-refactoring
description: After completing a code refactoring, use the architecture agent to perform a comprehensive review that goes beyond what tests can catch.
---

# Architecture-Agent-Driven Refactoring Review

**Extracted:** 2026-01-27
**Context:** After completing a code refactoring, use the architecture agent to perform a comprehensive review that goes beyond what tests can catch.

## Problem

When refactoring code, passing tests only verify that functionality is preserved. They don't catch:

- Duplicate logic in different forms
- Missing tests for new code
- Circular dependency risks
- Dead code that should be removed
- Architectural inconsistencies
- Hidden coupling or future maintenance issues

## Solution

After completing a refactoring and verifying tests pass, launch the architecture agent to review the changes:

```markdown
Use Task tool with subagent_type="architect" to review:

1. List all files created/modified
2. Explain what changed (consolidation, splitting, new abstractions)
3. Request analysis of:
   - Architecture quality
   - Code organization
   - Potential issues (dependencies, coupling)
   - Completeness (missed opportunities)
   - Best practices
   - Testability
   - Future maintenance concerns

Ask for specific feedback with code examples, and request critical analysis even if tests pass.
```

## Example

```
## Changes Made
- Created: internal/oras/strata_client.go (consolidated)
- Modified: detection/oci.go (removed duplicate)
- Created: detection/factory.go (factory pattern)

## Review Criteria
Analyze:
1. Architecture Quality - Is factory pattern well-designed?
2. Potential Issues - Any hidden coupling or circular dependencies?
3. Completeness - Are there missed opportunities?
4. Testability - Has testability improved?
```

## When to Use

**Trigger conditions:**

- After completing non-trivial refactoring (>3 files changed)
- After introducing new abstractions (factories, consolidated types)
- After removing duplicate code
- Before considering refactoring "complete"
- When you want validation beyond passing tests

**Especially important when:**

- Moving code between packages
- Creating shared implementations
- Changing architectural patterns
- Consolidating duplicates

## Expected Benefits

The architect agent will identify:

- **Critical issues**: Broken patterns that tests don't catch (e.g., routing logic that returns empty structs)
- **Missing tests**: New code without test coverage
- **Future problems**: Circular dependency risks, hidden coupling
- **Cleanup opportunities**: Dead code, stale comments
- **Best practices**: Go conventions, naming improvements

## Follow-up

After architect review:

1. Create tasks for critical issues
2. Fix high-priority problems immediately
3. Document medium/low priority items for future work
4. Re-run tests after fixes
5. Consider second architect review if major changes made
