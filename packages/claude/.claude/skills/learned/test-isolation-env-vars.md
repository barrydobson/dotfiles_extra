# Test Isolation for Environment Variables

**Extracted:** 2026-01-26
**Context:** Go tests failing due to environment variable pollution from developer's shell

## Problem

Tests for configuration loading fail intermittently or produce unexpected results because:
1. Developer has `STRATA_API_*` environment variables set in their shell
2. CI environment has different environment variables
3. Tests interfere with each other by setting env vars
4. Test expectations don't match actual config loaded from environment

**Example failure:**
```
Expected: port=8181 (default)
Actual:   port=8080 (from STRATA_API_PORT in shell)
```

## Solution

Create a test helper that clears all environment variables matching your prefix before each test:

```go
// testhelpers_test.go
package config

import (
    "os"
    "strings"
    "testing"
)

// clearStrataEnvVars removes all STRATA_API_ environment variables
// to ensure test isolation.
func clearStrataEnvVars(t *testing.T) {
    t.Helper()
    for _, env := range os.Environ() {
        if strings.HasPrefix(env, "STRATA_API_") {
            parts := strings.SplitN(env, "=", 2)
            if len(parts) > 0 {
                os.Unsetenv(parts[0])
            }
        }
    }
}
```

**Usage in tests:**
```go
func TestLoad_DefaultsOnly(t *testing.T) {
    clearStrataEnvVars(t) // Clear any interfering env vars

    cfg, err := Load("")
    require.NoError(t, err)

    // Now we can trust these assertions
    assert.Equal(t, 8181, cfg.Port)
    assert.Equal(t, "info", cfg.LogLevel)
}
```

## Key Points

1. **Call at start of every config test** - Don't assume clean environment
2. **Use t.Helper()** - Stack traces point to test, not helper
3. **Handle all env vars with prefix** - Don't hardcode variable names
4. **Put in *_test.go file** - Shared across test files in package
5. **Document why it exists** - Future developers will wonder

## Alternative Approaches

**Option 1: Test-scoped env vars (more complex but safer)**
```go
func withCleanEnv(t *testing.T, fn func()) {
    t.Helper()
    // Save current env
    originalEnv := os.Environ()

    // Clear prefix
    clearStrataEnvVars(t)

    // Run test
    fn()

    // Restore (if needed, but usually t.Cleanup is better)
    t.Cleanup(func() {
        // Restore logic
    })
}
```

**Option 2: Docker-based tests (overkill for most cases)**
- Run tests in clean container
- Slower but guarantees isolation

## When to Use

Triggers:
- Config loading tests failing on developer machines but passing in CI
- Tests pass individually but fail when run together
- Test results depend on order of execution
- "Works on my machine" syndrome with config tests
- Configuration loaded from environment variables

Required for:
- Any package that loads configuration from env vars
- Integration tests that set environment variables
- Tests verifying precedence (defaults < file < env)

## Detection

Signs you need this:
```bash
# Test passes in isolation
go test -run TestLoad_DefaultsOnly
PASS

# Test fails in suite
go test ./...
FAIL: Expected 8181, got 8080
```

## Related Patterns

- Test fixtures and cleanup
- Test helpers with t.Helper()
- CI/CD environment isolation
- Configuration testing strategies
