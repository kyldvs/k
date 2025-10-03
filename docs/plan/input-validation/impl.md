# Input Validation - Implementation Plan

## Prerequisites
- No external dependencies required
- Existing bootstrap build system (`just bootstrap build-all`)
- Existing test infrastructure (`just test all`)

## Architecture Overview

This implementation adds input validation to the bootstrap configuration system by:

1. **Creating a new validators module** (`lib/utils/validators.sh`) with reusable POSIX-compliant validation functions
2. **Extending prompt utilities** to validate input immediately and re-prompt on errors
3. **Integrating validators** into configuration flows for both Termux and VM root bootstrap
4. **Adding unit tests** to verify validation logic for edge cases

**Key Design Principles:**
- Validators return exit codes (0=valid, 1=invalid) for composability
- Validation happens before storing values, not after collection
- Error messages are clear and actionable (show expected format)
- All changes maintain POSIX shell compatibility
- Existing tests continue to pass (non-interactive config file usage)

**Data Flow:**
```
User Input → Prompt Function → Validator → [Valid: Store] or [Invalid: Error + Re-prompt]
```

## Task Breakdown

### Phase 1: Foundation - Validators Module
- [ ] Task 1.1: Create validators.sh with four core validation functions
  - Files: `bootstrap/lib/utils/validators.sh` (new)
  - Dependencies: None
  - Details: Implement `validate_hostname`, `validate_port`, `validate_username`, `validate_directory`
  - Each function takes single string argument, returns 0 (valid) or 1 (invalid)
  - Use POSIX-compliant regex patterns with `grep -qE`
  - Include inline comments explaining validation rules

- [ ] Task 1.2: Add validators.sh to build manifests
  - Files: `bootstrap/manifests/configure.txt`, `bootstrap/manifests/vmroot-configure.txt`
  - Dependencies: Task 1.1
  - Details: Insert `lib/utils/validators.sh` after `lib/utils/colors.sh` in both manifests

### Phase 2: Enhanced Prompt Functions
- [ ] Task 2.1: Add prompt_validated() to prompt.sh
  - Files: `bootstrap/lib/utils/prompt.sh`
  - Dependencies: Task 1.1
  - Details: New function with signature `prompt_validated(prompt_text, default_value, var_name, validator_fn, error_msg)`
  - Loops until valid input received
  - Displays custom error message on validation failure
  - Supports Ctrl-C to exit

- [ ] Task 2.2: Add vmroot_prompt_validated() to vmroot-prompt.sh
  - Files: `bootstrap/lib/utils/vmroot-prompt.sh`
  - Dependencies: Task 1.1
  - Details: Mirror structure of Task 2.1 for vmroot context
  - Same signature and behavior as `prompt_validated()`

### Phase 3: Integration with Configuration
- [ ] Task 3.1: Update configure-main.sh to use validated prompts
  - Files: `bootstrap/lib/steps/configure-main.sh`
  - Dependencies: Tasks 2.1, 1.1
  - Details: Replace existing `prompt` calls with `prompt_validated`:
    - `vm_hostname` → validate_hostname with error "Hostname must be alphanumeric with dots/hyphens (e.g., 192.168.1.1 or host.example.com)"
    - `vm_port` → validate_port with error "Port must be 1-65535"
    - `vm_username` → validate_username with error "Username must start with letter/underscore, contain only lowercase letters, digits, underscore, hyphen"
    - Doppler fields remain unvalidated (assumed correct by convention)

- [ ] Task 3.2: Update vmroot-configure-main.sh to use validated prompts
  - Files: `bootstrap/lib/steps/vmroot-configure-main.sh`
  - Dependencies: Tasks 2.2, 1.1
  - Details: Replace existing `vmroot_prompt` calls:
    - `username` → validate_username
    - `homedir` → validate_directory with error "Directory must be absolute path starting with /"

### Phase 4: Build and Initial Validation
- [ ] Task 4.1: Rebuild bootstrap scripts
  - Files: All generated bootstrap/*.sh files
  - Dependencies: All Phase 1-3 tasks
  - Details: Run `just bootstrap build-all` to regenerate scripts with new validators

- [ ] Task 4.2: Manual smoke test
  - Dependencies: Task 4.1
  - Details: Manually test configure.sh with invalid inputs:
    - Hostname: "has spaces", "host-", "-host", 300-char string
    - Port: "abc", "0", "65536", "-1"
    - Username: "UPPERCASE", "123start", "has space"
  - Verify re-prompting works and error messages are clear

### Phase 5: Testing - Unit Tests
- [ ] Task 5.1: Create validator unit tests
  - Files: `src/tests/tests/validators.test.sh` (new)
  - Dependencies: Task 1.1
  - Details: Test each validator with:
    - **validate_hostname**: valid (example.com, 192.168.1.1, host-name.example.com), invalid (empty, "-invalid", "has spaces", 254-char string)
    - **validate_port**: valid (1, 22, 65535), invalid (0, 65536, "abc", empty, "-1")
    - **validate_username**: valid (john, _user, user-name, a), invalid (empty, UPPERCASE, 123start, "has space", 33-char string)
    - **validate_directory**: valid (/home, /mnt/kad), invalid (empty, relative/path, /path;cmd, /path$var)
  - Minimum 10 test cases per validator covering boundaries and edge cases

- [ ] Task 5.2: Update test infrastructure to run validator tests
  - Files: `src/tests/justfile` (if needed)
  - Dependencies: Task 5.1
  - Details: Ensure `just test all` includes validator unit tests

- [ ] Task 5.3: Verify existing integration tests still pass
  - Files: None (verification only)
  - Dependencies: Task 4.1
  - Details: Run `just test all` and verify mobile-termux.test.sh and vmroot.test.sh pass
  - These tests use pre-created config files, so should be unaffected
  - If failures occur, investigate and fix

### Phase 6: Documentation and Finalization
- [ ] Task 6.1: Add comments to validators explaining rules
  - Files: `bootstrap/lib/utils/validators.sh`
  - Dependencies: Task 1.1
  - Details: Each function should have comment block explaining:
    - What format is valid (reference RFC/standard if applicable)
    - Examples of valid input
    - Common invalid patterns caught

- [ ] Task 6.2: Update task file with completion status
  - Files: `docs/tasks/input-validation.md`
  - Dependencies: All previous tasks
  - Details: Mark success criteria as complete

- [ ] Task 6.3: Final integration test
  - Dependencies: All previous tasks
  - Details: Run `just test all` one final time to confirm no regressions

## Files to Create
- `bootstrap/lib/utils/validators.sh` - Core validation functions (hostname, port, username, directory)
- `src/tests/tests/validators.test.sh` - Unit tests for validators

## Files to Modify
- `bootstrap/lib/utils/prompt.sh` - Add `prompt_validated()` function
- `bootstrap/lib/utils/vmroot-prompt.sh` - Add `vmroot_prompt_validated()` function
- `bootstrap/lib/steps/configure-main.sh` - Replace `prompt()` with `prompt_validated()` for vm_hostname, vm_port, vm_username
- `bootstrap/lib/steps/vmroot-configure-main.sh` - Replace `vmroot_prompt()` with `vmroot_prompt_validated()` for username, homedir
- `bootstrap/manifests/configure.txt` - Add validators.sh to build list
- `bootstrap/manifests/vmroot-configure.txt` - Add validators.sh to build list

## Testing Strategy

**Unit Tests:**
- Test each validator function independently with known valid/invalid inputs
- Cover edge cases: empty strings, boundary values, special characters, length limits
- Verify exit codes (0 for valid, 1 for invalid)

**Integration Tests:**
- Existing tests (mobile-termux, vmroot) should pass unchanged (they use config files, not interactive prompts)
- Manual testing of interactive configure.sh with various invalid inputs

**Validation Checklist:**
1. `validate_hostname`: ✓ valid hostnames, ✗ spaces, ✗ leading/trailing hyphens, ✗ too long
2. `validate_port`: ✓ 1-65535, ✗ 0, ✗ 65536, ✗ non-numeric
3. `validate_username`: ✓ POSIX usernames, ✗ uppercase, ✗ starts with digit, ✗ too long
4. `validate_directory`: ✓ absolute paths, ✗ relative, ✗ shell injection chars
5. Re-prompting: ✓ loops on invalid input, ✓ accepts valid input, ✓ shows clear errors
6. Existing tests: ✓ mobile-termux passes, ✓ vmroot passes

## Risk Assessment

**Risk 1: Breaking existing tests**
- Mitigation: Tests use pre-created config files (non-interactive), so validation won't be triggered
- Verification: Run `just test all` after each phase

**Risk 2: POSIX compatibility issues**
- Mitigation: Use only POSIX-compliant shell features (no bash-isms like `[[`, `=~`)
- Verification: Test in Alpine container (POSIX shell environment)

**Risk 3: Validator regex too strict or too loose**
- Mitigation: Start with well-documented standards (RFC 1123, POSIX username rules)
- Verification: Unit tests with real-world examples and common mistakes

**Risk 4: Poor user experience during prompting**
- Mitigation: Clear error messages that explain expected format
- Verification: Manual testing with intentionally invalid inputs

**Risk 5: Build system integration issues**
- Mitigation: Add validators.sh to manifests immediately after creation
- Verification: Run `just bootstrap build-all` and inspect generated scripts

## Implementation Notes

**Validator Implementation Pattern:**
```bash
validate_hostname() {
  local hostname="$1"

  # Check not empty
  [ -z "$hostname" ] && return 1

  # Check length
  [ ${#hostname} -gt 253 ] && return 1

  # Check format with POSIX grep
  echo "$hostname" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
}
```

**Prompt Validation Pattern:**
```bash
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

**Usage Pattern:**
```bash
# Before
prompt "VM hostname/IP" "" vm_hostname

# After
prompt_validated "VM hostname/IP" "" vm_hostname validate_hostname \
  "Hostname must be alphanumeric with dots/hyphens (e.g., 192.168.1.1)"
```

## Notes

- Keep validators simple and focused - each validates one specific format
- Error messages should be helpful, not technical (mention what's valid, not what regex failed)
- Consider IPv4 addresses as valid hostnames (they match the hostname pattern)
- Don't validate Doppler secret names - assume they're correct by convention
- Validation should feel responsive (< 100ms), no network calls or heavy processing
- Use `set -euo pipefail` in test files but not in validators (they need to return exit codes)
