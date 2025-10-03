# Refactor Error Handling and Add Retry Logic

## Description

Improve error handling to align with "Less but Better" principle #6 (Good Code is Honest). Current bootstrap scripts fail fast but don't distinguish between retryable errors (network failures) and fatal errors (misconfiguration). This creates poor user experience and violates the principle that "errors should surface immediately, not later."

## Current State

**Error Handling:**
- All scripts use `set -euo pipefail` (strict mode)
- Fail-fast on any error
- `kd_error` function logs to stderr (bootstrap/lib/utils/logging.sh:20-23)
- No retry logic for transient failures
- Network operations fail permanently on temporary issues

**Violations Identified:**
- `bootstrap/lib/steps/doppler-auth.sh:7-10` - Uses `kd_error` for instructions (not errors)
- `bootstrap/lib/steps/packages.sh:26` - `pkg install` can fail silently on network issues
- `bootstrap/lib/steps/ssh-keys.sh:28-30` - Doppler fetch fails permanently on transient errors

## Scope

**1. Separate Error Types:**
- `kd_error` - Fatal errors that stop execution
- `kd_info` - Informational messages (not errors)
- `kd_warning` - Non-fatal issues

**2. Add Retry Logic:**
- Create `lib/utils/retry.sh` with `kd_retry` function
- Wrap network operations: curl, doppler, pkg install
- Configurable retry attempts/delays via environment variables

**3. Apply to All Network Operations:**
- Doppler CLI commands (secrets get, me)
- Package installation (pkg install, apt-get)
- SSH connection tests
- Future: Git operations

## Success Criteria

- [ ] New utility functions: `kd_info`, `kd_warning`, `kd_retry`
- [ ] All network operations wrapped in `kd_retry`
- [ ] `kd_error` used only for actual errors
- [ ] Tests validate retry behavior (mock transient failures)
- [ ] Documentation updated
- [ ] No regressions in existing tests

## Implementation Notes

**New File: `lib/utils/retry.sh`**
```bash
# Retry a command with exponential backoff
kd_retry() {
  local max_attempts="${KD_RETRY_MAX:-3}"
  local delay="${KD_RETRY_DELAY:-2}"
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if "$@"; then
      return 0
    fi

    local exit_code=$?
    if [ $attempt -lt $max_attempts ]; then
      kd_warning "Command failed (attempt $attempt/$max_attempts), retrying in ${delay}s..."
      sleep $delay
      delay=$((delay * 2))  # Exponential backoff
    fi
    attempt=$((attempt + 1))
  done

  kd_error "Command failed after $max_attempts attempts: $*"
  return $exit_code
}
```

**Update: `lib/utils/logging.sh`**
```bash
# Add new logging functions
kd_info() {
  local msg="$*"
  printf "%s%s\n" "$(_kd_indent)" "$msg"
}

kd_warning() {
  local msg="$*"
  printf "%s[WARNING]%s %s\n" "$KD_YELLOW" "$KD_RESET" "$msg" >&2
}

# kd_error remains for fatal errors only
```

**Changes to Components:**
- `lib/steps/doppler-auth.sh` - Replace `kd_error` instructions with `kd_info`
- `lib/steps/packages.sh` - Wrap `pkg install` in `kd_retry`
- `lib/steps/ssh-keys.sh` - Wrap doppler commands in `kd_retry`
- `lib/steps/ssh-test.sh` - Wrap SSH test in `kd_retry`

**Manifest Updates:**
All manifests need retry.sh after logging.sh:
```
lib/utils/colors.sh
lib/utils/logging.sh
lib/utils/retry.sh      # <-- Add this line
lib/utils/steps.sh
...
```

## Testing Strategy

**Test Transient Failures:**
```bash
# src/tests/fixtures/flaky-command.sh
#!/usr/bin/env bash
# Fails first 2 times, succeeds on 3rd

STATE_FILE="/tmp/flaky-state-$$"
ATTEMPTS=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
ATTEMPTS=$((ATTEMPTS + 1))
echo "$ATTEMPTS" > "$STATE_FILE"

if [ "$ATTEMPTS" -lt 3 ]; then
  echo "Attempt $ATTEMPTS failed" >&2
  exit 1
fi

echo "Attempt $ATTEMPTS succeeded"
exit 0
```

**Add Test Case:**
```bash
# src/tests/tests/retry-logic.test.sh
#!/usr/bin/env bash
set -euo pipefail
. /lib/assertions.sh

# Test retry succeeds after transient failures
kd_retry /var/www/tests/fixtures/flaky-command.sh
assert_command "echo $?" "0"
```

## Related Principles

- **#6 Good Code is Honest**: Errors surface immediately with clear context
- **#8 Good Code is Thorough**: Handle edge cases explicitly
- **#2 Good Code is Useful**: Solve real problems (network instability)
- **#10 As Little Code as Possible**: Reusable retry utility vs duplicated logic

## Dependencies

None - improves existing code

## Related Files

- `bootstrap/lib/utils/logging.sh` (extend)
- `bootstrap/lib/utils/retry.sh` (new)
- All manifests (add retry.sh)
- All network operation steps (apply retry)

## Related Tasks

- bootstrap-error-recovery.md (supersedes part of this)
- ci-integration.md (retry makes CI more reliable)

## Priority

**High** - Directly addresses principle violations and improves reliability

## Incremental Approach

1. Create retry.sh and new logging functions
2. Update manifests to include retry.sh
3. Apply to one component (doppler-auth.sh) and test
4. Apply to remaining components
5. Rebuild all scripts: `just bootstrap build-all`
6. Run full test suite: `just test all`
7. Commit and push

## Estimated Effort

4-6 hours
