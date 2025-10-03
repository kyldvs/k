# Bootstrap Input Validation

## Overview
Input validation system for bootstrap configuration prompts that catches formatting errors immediately at input time rather than during later SSH connection attempts. Implements validated prompt functions that re-prompt users on invalid input with clear error messages.

## Architecture
The validation system consists of three layers:

1. **Validators** (`bootstrap/lib/utils/validators.sh`) - POSIX-compliant validation functions
2. **Validated Prompts** (`prompt.sh`, `vmroot-prompt.sh`) - Prompt wrappers that integrate validation
3. **Configuration Integration** (`configure-main.sh`, `vmroot-configure-main.sh`) - Apply validators to user-facing prompts

**Data Flow:**
```
User Input → prompt_validated() → validator() → [valid: store] or [invalid: error + re-prompt]
```

## Key Components

### Validators (`bootstrap/lib/utils/validators.sh`)
Four reusable validation functions, each returns exit code 0 (valid) or 1 (invalid):

- **validate_hostname**: RFC 1123 hostname format (alphanumeric, dots, hyphens; max 253 chars; no leading/trailing hyphens or dots)
- **validate_port**: Integer in range 1-65535
- **validate_username**: POSIX portable username rules (lowercase, digits, underscore, hyphen; starts with letter or underscore; max 32 chars)
- **validate_directory**: Absolute paths without shell injection characters (;&$`<>|)

### Validated Prompt Functions
- **prompt_validated()**: Takes validator function and error message, loops until valid input received
- **vmroot_prompt_validated()**: Mirror implementation for vmroot context

Signature: `prompt_validated(prompt_text, default_value, var_name, validator_fn, error_msg)`

## Design Decisions

### POSIX Compliance Over Bash Features
- **Decision**: Use POSIX sh (`#!/usr/bin/env sh`) with standard utilities only
- **Rationale**: Maximum compatibility across Termux, Alpine, and minimal environments
- **Trade-off**: Cannot use bash-isms like `[[` or `=~`, but gains universal portability

### Validators as Exit Codes
- **Decision**: Validators return 0/1 exit codes rather than printing output
- **Rationale**: Composable, testable, and follows Unix philosophy
- **Pattern**: Enables chaining with `&&` and `||` operators

### Validation Timing
- **Decision**: Validate immediately after each input, not after collecting all values
- **Rationale**: Fast feedback loop - users fix errors immediately while context is fresh
- **Impact**: Existing tests unaffected (they use pre-created config files, bypassing interactive prompts)

### Error Message Design
- **Decision**: Error messages describe valid format, not what failed validation
- **Example**: "Hostname must be alphanumeric with dots/hyphens (e.g., 192.168.1.1)" not "Hostname failed regex validation"
- **Rationale**: User-friendly, actionable guidance for fixing input

## Implementation Patterns

### Validator Pattern
```sh
validate_field() {
  local input="$1"

  # Check not empty
  [ -z "$input" ] && return 1

  # Check length/bounds
  [ ${#input} -gt MAX ] && return 1

  # Check format with POSIX grep
  echo "$input" | grep -qE 'regex_pattern'
}
```

### Validated Prompt Pattern
```sh
prompt_validated() {
  local prompt_text="$1"
  local default_value="$2"
  local var_name="$3"
  local validator="$4"
  local error_msg="$5"

  while true; do
    prompt "$prompt_text" "$default_value" "$var_name"
    eval "value=\$$var_name"

    if $validator "$value"; then
      return 0
    fi

    printf "%s✗ Invalid input:%s %s\n" "$KD_RED" "$KD_RESET" "$error_msg"
  done
}
```

### Usage Pattern
```sh
# Before
prompt "VM hostname/IP" "" vm_hostname

# After
prompt_validated "VM hostname/IP" "" vm_hostname validate_hostname \
  "Hostname must be alphanumeric with dots/hyphens (e.g., 192.168.1.1)"
```

## Integration Points

### Bootstrap Build System
- Validators added to manifests: `configure.txt`, `vmroot-configure.txt`
- Build script concatenates components into final bootstrap scripts
- Each component maintains its own shebang for standalone linting

### Test Infrastructure
- Validator unit tests: `src/tests/tests/validators.test.sh`
- Test helper functions: `test_valid()`, `test_invalid()`
- Docker volume mount: `/tests` directory for containerized test execution

## Testing Approach

### Unit Testing
- Each validator tested with 15+ cases (valid inputs, invalid inputs, edge cases, boundaries)
- Helper functions simplify test writing: `test_valid validator "input"`, `test_invalid validator "input"`
- Exit codes verified for correctness

### Integration Testing
- Existing tests (mobile-termux, vmroot) validate no regressions
- Tests use pre-created config files (non-interactive), so validation is not triggered
- Zero impact on CI/CD pipelines

## Configuration

### Validator Standards
- **Hostnames**: RFC 1123 format
- **Ports**: Full range 1-65535 (no warnings for privileged ports)
- **Usernames**: POSIX portable username specification
- **Directories**: Basic shell injection prevention (not comprehensive security validation)

### Fields NOT Validated
- Doppler secret names (assumed correct by convention)
- SSH key content (validated by SSH itself)
- Network connectivity (out of scope)

## Future Considerations

### Potential Enhancements
- IPv6 address validation (currently treated as valid hostnames if matching pattern)
- Custom validator composition (e.g., "hostname OR special value 'localhost'")
- Validator error codes with detailed failure reasons
- Optional warnings vs hard failures (e.g., using privileged ports)

### Known Limitations
- Validators check format, not semantic correctness (e.g., hostname may be well-formed but not resolve)
- Shell injection prevention is basic pattern matching, not comprehensive security validation
- No connectivity or reachability testing

### Extension Pattern
To add new validators:
1. Add validation function to `bootstrap/lib/utils/validators.sh`
2. Follow naming convention: `validate_<field_name>`
3. Return 0 for valid, 1 for invalid
4. Add comprehensive unit tests
5. Use with `prompt_validated()` in configuration scripts
