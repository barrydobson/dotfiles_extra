# Parallel Agent Refactoring Pattern

**Extracted:** 2026-01-26
**Context:** Large-scale codebase refactoring with multiple independent work areas

## Problem

When refactoring a large codebase (e.g., replacing an architecture pattern across many files), sequential implementation is slow and blocks on each step. A configuration system refactor that touches 15+ files across cmd/, internal/server/, and controllers/ would take 6-9 days sequentially but could be done much faster with parallel execution.

## Solution

Use a 3-phase approach with parallel agent execution in Phase 2:

### Phase 1: Foundation (Sequential)
- Build the new system completely
- Write comprehensive tests
- Ensure it's battle-tested before integration
- **Gate:** All foundation tests must pass before Phase 2

### Phase 2: Parallel Implementation (5+ agents simultaneously)
- Divide work by **file sets** (not by feature) to avoid conflicts
- Each agent works on disjoint files:
  - Agent 1: Entry points (cmd/)
  - Agent 2: Server core (internal/server/server.go, telemetry/)
  - Agent 3: Controller group A (helmfile, kustomize)
  - Agent 4: Controller group B (backstage, oras)
  - Agent 5: Remaining files + verification
- Each agent tests their changes independently
- File system coordinates final state (overlaps are fine)

### Phase 3: Cleanup (Sequential)
- Delete old implementation files
- Run full test suite
- Update documentation
- Final verification

## Key Principles

1. **No migration needed if deployment can wait** - Simplifies drastically
2. **Foundation must be solid** - Phase 2 depends on it
3. **Disjoint file sets** - Prevents merge conflicts
4. **Each agent tests** - Catch issues early
5. **Final integration test** - Verify everything together

## Example

Configuration refactoring from interface-based to struct-based:

**Phase 1 (1 day):**
- Create types.go, loader.go, validate.go, errors.go
- Write 44 tests covering all scenarios
- Achieve 84% coverage on new code

**Phase 2 (parallel, ~1 day wall-clock):**
```bash
# Launch 5 agents simultaneously
/task agent=1 Update cmd/root.go and cmd/start.go
/task agent=2 Update server and telemetry
/task agent=3 Update helmfile and kustomize controllers
/task agent=4 Update backstage and oras controllers
/task agent=5 Update remaining controllers and verify
```

**Phase 3 (0.5 days):**
- Delete 6 old files
- Run make test (634 tests passing)
- Update documentation

**Result:** 2.5 days instead of 6-9 days (3x speedup)

## When to Use

Triggers:
- Refactoring touches 10+ files across multiple directories
- Work can be divided into independent file sets
- No deployment deadline forces incremental migration
- Foundation can be built and tested independently
- Changes are systematic (same pattern repeated)

Don't use when:
- Changes are highly interdependent (can't parallelize)
- Must maintain backward compatibility during transition
- Work areas overlap significantly
- Exploratory refactoring (don't know the solution yet)

## Success Metrics

- All tests passing after each phase
- No compilation errors
- Wall-clock time < 50% of sequential estimate
- Test coverage maintained or improved
- Documentation updated

## Common Pitfalls

1. **Starting Phase 2 before Phase 1 is solid** → Foundation bugs multiply across agents
2. **Overlapping file assignments** → Merge conflicts and wasted work
3. **No agent-level testing** → Integration failures discovered too late
4. **Skipping Phase 3** → Technical debt and confusion for next developer

## Related Patterns

- Test-Driven Refactoring (write tests for new system first)
- Strangler Fig Pattern (but without the gradual migration)
- Big Bang Rewrite (but with safety nets via testing)
