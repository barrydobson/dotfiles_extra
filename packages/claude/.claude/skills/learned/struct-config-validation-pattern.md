# Struct-Based Configuration with Validation Pattern

**Extracted:** 2026-01-26
**Context:** Replacing interface-based configuration with simple, validated structs

## Problem

Traditional configuration patterns in Go often lead to:
1. **Interface bloat** - 40+ getter methods that just return fields
2. **Duplicate defaults** - YAML strings AND constructor functions
3. **Late validation** - Errors discovered at runtime, not startup
4. **Complex testing** - Need interface mocks and implementations
5. **Unclear hierarchy** - Flat getters hide relationships between config sections

## Solution

Use struct tags for defaults and validation with direct field access:

### Architecture

```go
// 1. Define config structure with nested domains
type Config struct {
    // Core settings
    Port        int    `koanf:"port"      default:"8181"  validate:"min=1,max=65535"`
    LogLevel    string `koanf:"log-level" default:"info"   validate:"oneof=debug info warn error"`
    Environment string `koanf:"environment" default:"development"`

    // Nested domain configs
    Cache        CacheConfig        `koanf:"cache"`
    OTEL         OTELConfig         `koanf:"otel"`
    Integrations IntegrationsConfig `koanf:"integrations"`
}

type CacheConfig struct {
    Type    string `koanf:"type" default:"none" validate:"oneof=none memory redis memcached"`
    Address string `koanf:"address" default:""`
}

// 2. Single loader function with validation
func Load(configFile string) (*Config, error) {
    cfg := &Config{}

    // Apply struct tag defaults
    if err := defaults.Set(cfg); err != nil {
        return nil, err
    }

    // Load file and env vars (using koanf or similar)
    // ... loading logic ...

    // Validate before returning
    if err := cfg.Validate(); err != nil {
        return nil, err
    }

    return cfg, nil
}

// 3. Validation with clear errors
func (c *Config) Validate() error {
    // Struct tag validation
    if err := validate.Struct(c); err != nil {
        return formatErrors(err)
    }

    // Cross-field validation
    if c.Cache.Type == "redis" && c.Cache.Address == "" {
        return errors.New("cache.address required when type is redis")
    }

    return nil
}
```

### Usage

**Before (interface-based):**
```go
// Complex initialization
globalOpts := config.NewGlobalOptions()
k.Unmarshal("", globalOpts)
globalImpl := config.NewGlobalImpl(globalOpts)
apiOpts := config.NewAPIOptions()
k.Unmarshal("", apiOpts)
apiImpl := config.NewAPIImpl(globalImpl, apiOpts)

// Getter method calls
port := cfg.GetPort()
cacheType := cfg.GetCacheType()
otelEnabled := cfg.IsOTELEnabled()
backstageURL := cfg.GetBackstageBaseURL()
```

**After (struct-based):**
```go
// Simple loading
cfg, err := config.Load("config.yaml")
if err != nil {
    log.Fatal(err) // Clear validation errors on startup
}

// Direct field access
port := cfg.Port
cacheType := cfg.Cache.Type
otelEnabled := cfg.OTEL.Enabled
backstageURL := cfg.Backstage.BaseURL
```

## Required Libraries

```bash
go get github.com/go-playground/validator/v10  # Validation
go get github.com/creasty/defaults             # Struct tag defaults
```

## Key Benefits

1. **Single source of truth** - Defaults only in struct tags
2. **Early validation** - Fail fast on startup with clear errors
3. **Clear hierarchy** - `cfg.Cache.Type` shows relationships
4. **No interface boilerplate** - 40+ methods eliminated
5. **Simple testing** - Direct struct initialization
6. **Self-documenting** - Struct tags show constraints

## Testing

**Before (interface mocking):**
```go
cfg := config.NewAPIImpl(
    config.NewGlobalImpl(config.NewGlobalOptions()),
    &config.APIOptions{},
)
```

**After (simple struct):**
```go
cfg := &config.Config{
    Cache: config.CacheConfig{
        Type: "redis",
        Address: "localhost:6379",
    },
}
```

## Validation Error Messages

Clear, actionable errors:
```
configuration validation failed:
  - cache.address is required when cache.type is 'redis'
  - port: must be at least 1
  - log-level: must be one of: debug info warn error
```

## Environment Variable Mapping

Use transform functions for nested configs:

```go
// STRATA_API_CACHE__TYPE=redis
// STRATA_API_OTEL__LOG__ENABLED=true

func transformEnvKey(key string, value string) (string, any) {
    key = strings.TrimPrefix(key, "STRATA_API_")
    key = strings.ToLower(key)
    key = strings.ReplaceAll(key, "__", ".")  // Nesting
    key = strings.ReplaceAll(key, "_", "-")   // Dashes
    return key, value
}
```

## When to Use

Triggers:
- Config system has 10+ options across multiple domains
- Using interfaces just to return field values
- Defaults duplicated in multiple places
- Want early validation with clear errors
- Testing requires complex mocking

Don't use when:
- Need to swap implementations at runtime (keep interfaces)
- Config changes frequently at runtime (hot reload)
- Extremely simple config (5 fields, no validation needed)

## Migration Strategy

1. **Create new system alongside old** - Don't break existing code
2. **Write comprehensive tests** - 80%+ coverage on new config
3. **Update consumers in parallel** - Use multiple agents/PRs
4. **Delete old system** - Once all consumers migrated
5. **Update documentation** - Show new patterns

## File Structure

```
internal/config/
├── types.go          # Config structs with tags
├── loader.go         # Load() function
├── validate.go       # Validation logic
├── errors.go         # Custom error types
├── types_test.go     # Test defaults
├── loader_test.go    # Test loading
├── validate_test.go  # Test validation
└── integration_test.go # End-to-end tests
```

## Common Pitfalls

1. **Forgetting validation** - Always call `Validate()` after loading
2. **Complex nested validation** - Keep cross-field checks simple
3. **Poor error messages** - Format validator errors for humans
4. **Testing with real env vars** - Clear environment in tests
5. **No default values** - Use struct tags, not Go zero values

## Metrics

Typical improvements:
- **80% less config code** (remove interfaces, getters, wrappers)
- **40-80% better test coverage** (simpler to test)
- **90% simpler test setup** (direct struct initialization)
- **100% fewer mocking libs** (no interfaces to mock)

## Related Patterns

- Validation on construction (fail fast)
- Builder pattern (but simpler with struct tags)
- Options pattern (functional options)
- Configuration as Code
