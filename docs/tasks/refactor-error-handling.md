# Refactor Error Handling

## Description

Improve error handling in bootstrap scripts to align with "Less but Better"
principle #6 (Good Code is Honest) - errors should surface immediately, not
later. Focus on retry logic for transient failures and clearer error types to
distinguish between fatal errors, warnings, and informational messages.

## Current State

**Error Handling:**
- All scripts use `set -euo pipefail` (strict mode)
- Fail-fast on any error
- `kd_error` function logs errors to stderr
- Exit codes: 0=success, 1=error, 2=usage

**Gaps:**
- No retry logic for network failures (violates principle #6)
- All errors treated equally (no distinction between fatal/warning/info)
- Limited error context for common failure scenarios
- Network operations fail immediately on transient issues

## Scope

**1. Add Retry Logic:**
Create reusable retry wrapper for transient failures:
- Automatic retry for network operations
- Configurable retry attempts and delays
- Clear logging of retry attempts
- Distinguish retryable vs fatal errors

**2. Separate Error Types:**
Extend logging utilities to support different severity levels:
- `kd_error` - Fatal errors that stop execution
- `kd_warning` - Non-fatal issues that allow continuation
- `kd_info` - Informational messages for user awareness

**3. Apply to Network Operations:**
- Doppler authentication
- Package installation (apt, pkg)
- SSH key retrieval
- Any network-dependent operations

## Success Criteria

- [ ] New file: `lib/utils/retry.sh` with retry wrapper function
- [ ] Extended: `lib/utils/logging.sh` with warning/info functions
- [ ] Network operations use retry logic automatically
- [ ] Tests validate retry behavior (success after N attempts)
- [ ] Error messages clearly indicate severity level
- [ ] No regressions in existing tests

## Implementation Notes

**New File: `lib/utils/retry.sh`**
```bash
#!/usr/bin/env bash
# Retry wrapper for transient failures

kd_retry() {
  local max_attempts="${KD_RETRY_MAX:-3}"
  local delay="${KD_RETRY_DELAY:-2}"
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    if "$@"; then
      return 0
    fi

    if [ $attempt -lt $max_attempts ]; then
      kd_log "Retry $attempt/$max_attempts in ${delay}s..."
      sleep $delay
    fi
    attempt=$((attempt + 1))
  done

  kd_error "Failed after $max_attempts attempts: $*"
  return 1
}
```

**Extend `lib/utils/logging.sh`:**
```bash
# Warning: non-fatal issues
kd_warning() {
  local message="$1"
  printf "%s⚠ WARNING:%s %s\n" "$KD_YELLOW" "$KD_RESET" "$message" >&2
}

# Info: helpful context
kd_info() {
  local message="$1"
  printf "%sℹ INFO:%s %s\n" "$KD_BLUE" "$KD_RESET" "$message"
}
```

**Apply to Network Operations:**
```bash
# Before
doppler_auth() {
  doppler configure set token "$token" --scope "$config_dir"
}

# After
doppler_auth() {
  kd_retry doppler configure set token "$token" --scope "$config_dir"
}

# Before
pkg install -y openssh git

# After
kd_retry pkg install -y openssh git
```

## Testing Strategy

**Unit Tests:**
```bash
# Test retry succeeds after failure
test_retry_succeeds() {
  local count=0
  failing_twice() {
    count=$((count + 1))
    [ $count -gt 2 ]
  }

  assert_command "kd_retry failing_twice && echo ok" "ok"
}

# Test retry fails after max attempts
test_retry_exhausted() {
  always_fail() {
    return 1
  }

  assert_command "kd_retry always_fail && echo ok || echo fail" "fail"
}
```

**Integration Tests:**
- Mock network failure scenarios
- Verify retry logic in bootstrap tests
- Test warning/info messages display correctly

## Related Principles

- **#6 Good Code is Honest**: Errors surface immediately for retryable
  operations; warnings distinguish non-fatal issues
- **#8 Good Code is Thorough**: Handle edge cases like transient network
  failures; provide clear context
- **#2 Good Code is Useful**: Retry logic solves real user problems (flaky
  networks)
- **#10 As Little Code as Possible**: Focused scope, no overengineering

## Dependencies

None - improves existing scripts

## Related Files

- `bootstrap/lib/utils/retry.sh` (new)
- `bootstrap/lib/utils/logging.sh` (extend)
- `bootstrap/lib/steps/*.sh` (apply retry to network operations)
- All manifests (add retry.sh)

## Related Tasks

- input-validation.md (complementary - both improve error handling)
- bootstrap-error-recovery.md (superseded by this task)

## Priority

**High** - Fixes principle #6 violations; solves real user problems with
network failures

## Incremental Approach

Following "Less but Better" principle #10:
1. Create retry.sh with retry wrapper
2. Add warning/info to logging.sh
3. Apply retry to Doppler operations (highest impact)
4. Add tests for retry logic
5. Apply to package installation
6. Update manifests: `just bootstrap build-all`
7. Test: `just test all`
8. Commit and push

Don't add checkpoint system, debug mode, or other features from
bootstrap-error-recovery.md. Focus on solving the immediate problem: network
operations should retry, and errors should be honest about severity.

## Estimated Effort

4-6 hours

## Notes

This task supersedes bootstrap-error-recovery.md with a more focused scope.
The original task included features like checkpoint/resume and debug mode that
may not be necessary (principle #10: as little code as possible).

Focus on the core issue: network failures should retry automatically, and
error types should be clear. If other features prove necessary, they can be
added in future tasks.
