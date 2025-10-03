# Input Validation for Bootstrap Configuration

## Description

Add input validation to bootstrap configuration prompts to align with "Less but Better" principle #8 (Good Code is Thorough). Current prompt functions accept any string input without validation, leading to confusing errors later when invalid configuration is used.

## Current State

**Prompt Functions:**
- `bootstrap/lib/utils/prompt.sh` - Terminal configuration prompts
- `bootstrap/lib/utils/vmroot-prompt.sh` - VM root configuration prompts
- Accept any user input without validation
- Store directly to JSON config files

**Validation:**
- `bootstrap/lib/utils/validate.sh` - Validates config after collection
- `bootstrap/lib/utils/vmroot-validate.sh` - Validates vmroot config
- Only checks for empty strings, not format/validity

**Problems:**
- Invalid hostnames accepted (e.g., spaces, special chars)
- Invalid ports accepted (e.g., "abc", 99999)
- Invalid usernames accepted (e.g., root@host, special chars)
- Errors surface later during SSH connection, not at input time
- Violates "errors surface immediately" principle

## Scope

**1. Add Validation Utilities:**
Create reusable validators in `lib/utils/validators.sh`:
- `validate_hostname` - RFC 1123 hostname format
- `validate_port` - Integer 1-65535
- `validate_username` - POSIX username rules
- `validate_not_empty` - Non-empty string
- `validate_directory` - Valid directory path format

**2. Integrate with Prompts:**
- Validate immediately after user input
- Re-prompt on invalid input with helpful error message
- Loop until valid input provided or user cancels

**3. Apply to All Configuration:**
- Termux configure.sh prompts
- VM root configure prompts
- Any future configuration scripts

## Success Criteria

- [ ] New file: `lib/utils/validators.sh` with validation functions
- [ ] All prompt functions validate input immediately
- [ ] Invalid input shows clear error and re-prompts
- [ ] Tests validate edge cases (empty, invalid formats, boundary values)
- [ ] Documentation includes valid input formats
- [ ] No regressions in existing tests

## Implementation Notes

**New File: `lib/utils/validators.sh`**
```bash
# Validate hostname (RFC 1123)
validate_hostname() {
  local hostname="$1"

  # Check not empty
  if [ -z "$hostname" ]; then
    return 1
  fi

  # Check length (max 253 chars)
  if [ ${#hostname} -gt 253 ]; then
    return 1
  fi

  # Check format: alphanumeric, dots, hyphens
  # No leading/trailing dots or hyphens
  if ! echo "$hostname" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'; then
    return 1
  fi

  return 0
}

# Validate port (1-65535)
validate_port() {
  local port="$1"

  # Check is integer
  if ! echo "$port" | grep -qE '^[0-9]+$'; then
    return 1
  fi

  # Check range
  if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    return 1
  fi

  return 0
}

# Validate username (POSIX portable)
validate_username() {
  local username="$1"

  # Check not empty
  if [ -z "$username" ]; then
    return 1
  fi

  # Check length (max 32 chars)
  if [ ${#username} -gt 32 ]; then
    return 1
  fi

  # Check format: lowercase, digits, underscore, hyphen
  # Must start with lowercase letter or underscore
  if ! echo "$username" | grep -qE '^[a-z_][a-z0-9_-]*$'; then
    return 1
  fi

  return 0
}

# Validate directory path
validate_directory() {
  local dir="$1"

  # Check not empty
  if [ -z "$dir" ]; then
    return 1
  fi

  # Check starts with /
  if [ "${dir#/}" = "$dir" ]; then
    return 1
  fi

  # Check no special chars (basic safety)
  if echo "$dir" | grep -qE '[<>|;&$`]'; then
    return 1
  fi

  return 0
}
```

**Update Prompt Function:**
```bash
# Enhanced prompt with validation
prompt_validated() {
  local prompt_text="$1"
  local default_value="$2"
  local var_name="$3"
  local validator="$4"  # Function name to validate input

  while true; do
    # Show prompt
    if [ -n "$default_value" ]; then
      printf "%s%s%s [%s]: " "$KD_CYAN" "$prompt_text" "$KD_RESET" "$default_value"
    else
      printf "%s%s%s: " "$KD_CYAN" "$prompt_text" "$KD_RESET"
    fi

    # Read input
    read -r value

    # Use default if empty
    if [ -z "$value" ] && [ -n "$default_value" ]; then
      value="$default_value"
    fi

    # Validate
    if $validator "$value"; then
      eval "$var_name='$value'"
      return 0
    else
      kd_warning "Invalid input. Please try again."
    fi
  done
}
```

**Update configure-main.sh:**
```bash
# Before
prompt "VM hostname (e.g., 192.168.1.100)" "" "vm_hostname"

# After
prompt_validated "VM hostname (e.g., 192.168.1.100)" "" "vm_hostname" "validate_hostname"
```

## Testing Strategy

**Unit Tests for Validators:**
```bash
# Test valid hostnames
assert_command "validate_hostname 'example.com' && echo ok" "ok"
assert_command "validate_hostname '192.168.1.1' && echo ok" "ok"
assert_command "validate_hostname 'host-name.example.com' && echo ok" "ok"

# Test invalid hostnames
assert_command "validate_hostname '' && echo ok || echo fail" "fail"
assert_command "validate_hostname '-invalid.com' && echo ok || echo fail" "fail"
assert_command "validate_hostname 'has spaces.com' && echo ok || echo fail" "fail"

# Test valid ports
assert_command "validate_port '22' && echo ok" "ok"
assert_command "validate_port '65535' && echo ok" "ok"

# Test invalid ports
assert_command "validate_port '0' && echo ok || echo fail" "fail"
assert_command "validate_port '65536' && echo ok || echo fail" "fail"
assert_command "validate_port 'abc' && echo ok || echo fail" "fail"

# Test valid usernames
assert_command "validate_username 'john' && echo ok" "ok"
assert_command "validate_username '_user' && echo ok" "ok"
assert_command "validate_username 'user-name' && echo ok" "ok"

# Test invalid usernames
assert_command "validate_username '' && echo ok || echo fail" "fail"
assert_command "validate_username 'UPPERCASE' && echo ok || echo fail" "fail"
assert_command "validate_username '123user' && echo ok || echo fail" "fail"
assert_command "validate_username 'has space' && echo ok || echo fail" "fail"
```

**Integration Tests:**
Create mock interactive test that provides invalid then valid input:
```bash
# Simulate user input: invalid, then valid
echo -e "invalid port\n22\n" | bash configure.sh
```

## Related Principles

- **#8 Good Code is Thorough**: Handle edge cases explicitly, validate inputs
- **#6 Good Code is Honest**: Errors surface immediately at input time
- **#4 Good Code is Understandable**: Clear validation errors help users
- **#2 Good Code is Useful**: Prevents frustrating late-stage errors

## Dependencies

None - improves existing code

## Related Files

- `bootstrap/lib/utils/validators.sh` (new)
- `bootstrap/lib/utils/prompt.sh` (extend)
- `bootstrap/lib/utils/vmroot-prompt.sh` (extend)
- `bootstrap/lib/steps/configure-main.sh` (apply validators)
- `bootstrap/lib/steps/vmroot-configure-main.sh` (apply validators)
- All manifests (add validators.sh)

## Related Tasks

- refactor-error-handling.md (complementary - both improve error handling)

## Priority

**Medium** - Improves user experience and catches errors early, but not blocking

## Dependencies

None - improves existing code

## Incremental Approach

1. Create validators.sh with core validation functions
2. Add unit tests for validators
3. Update one prompt function (configure.sh) to use validation
4. Test interactively
5. Apply to remaining prompt functions
6. Update manifests
7. Rebuild: `just bootstrap build-all`
8. Test: `just test all`
9. Commit and push

## Estimated Effort

2-3 hours

## Notes

Keep validators simple and POSIX-compliant. Avoid overengineering. Focus on catching common mistakes (typos, wrong format) not adversarial input.
