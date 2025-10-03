# Bootstrap Error Recovery

> **⚠️ SUPERSEDED:** This task has been superseded by
> [refactor-error-handling.md](./refactor-error-handling.md) which has more
> focused scope and better aligns with principles #6 (Honest) and #10 (As
> Little Code as Possible). The new task focuses on retry logic and error
> types without overengineering features like checkpoint/resume systems.

## Description

Improve error handling and recovery flows in bootstrap scripts. Currently,
scripts use `set -e` for fail-fast behavior, but could provide better user
experience with more graceful error handling, retry logic, and recovery options.

## Current State

**Error Handling:**
- All scripts use `set -euo pipefail` (strict mode)
- Fail-fast on any error
- `kd_error` function logs errors to stderr
- Exit codes: 0=success, 1=error, 2=usage

**Idempotency:**
- Scripts can be run multiple times safely
- Steps skip if already completed
- `kd_step_skip` indicates already-done work

**Gaps:**
- No retry logic for network failures
- No graceful degradation
- Limited error context/suggestions
- No checkpoint/resume functionality
- Hard to debug when things go wrong

## Scope

**Enhanced Error Reporting:**
- Capture and display error context
- Suggest fixes for common errors
- Show troubleshooting steps
- Link to documentation

**Retry Logic:**
- Automatic retry for transient failures
- Configurable retry attempts/delays
- Distinguish retryable vs fatal errors

**Recovery Options:**
- Continue on non-critical failures
- Partial completion tracking
- Resume from last successful step
- Cleanup on failure

**Debug Mode:**
- Verbose logging option
- Show all commands (`set -x`)
- Save logs to file
- Environment diagnostic info

## Success Criteria

- [ ] Network operations retry on failure
- [ ] Errors include helpful context and suggestions
- [ ] Critical vs non-critical failures distinguished
- [ ] Debug mode available via environment variable
- [ ] Tests validate error handling paths
- [ ] Documentation includes troubleshooting guide

## Implementation Notes

**Retry Wrapper Function:**
```bash
# lib/utils/retry.sh
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

**Enhanced Error Function:**
```bash
# lib/utils/logging.sh
kd_error_with_help() {
  local message="$1"
  local help_text="$2"

  printf "%s✗ ERROR:%s %s\n" "$KD_RED" "$KD_RESET" "$message" >&2
  if [ -n "$help_text" ]; then
    printf "\n%sTroubleshooting:%s\n%s\n" "$KD_YELLOW" "$KD_RESET" \
      "$help_text" >&2
  fi
}
```

**Debug Mode:**
```bash
# Enable via environment variable
if [ -n "${KD_DEBUG:-}" ]; then
  set -x
  kd_log "Debug mode enabled"
fi
```

**Apply to Network Operations:**
- Doppler authentication
- Package installation (apt, pkg)
- SSH key retrieval
- Git clone operations (future)

**Checkpoint System:**
```bash
# Track completed steps
kd_checkpoint() {
  local step="$1"
  echo "$step" >> "$HOME/.cache/kyldvs/k/bootstrap-checkpoint"
}

kd_is_complete() {
  local step="$1"
  grep -qx "$step" "$HOME/.cache/kyldvs/k/bootstrap-checkpoint" 2>/dev/null
}
```

## Examples

**Before:**
```
✗ ERROR: Failed to install packages
(script exits, no context)
```

**After:**
```
✗ ERROR: Failed to install packages after 3 attempts

Troubleshooting:
  • Check internet connectivity
  • Verify repository mirrors are accessible
  • Try running: pkg update && pkg upgrade
  • See: https://github.com/kyldvs/k/blob/main/docs/troubleshooting.md

Run with KD_DEBUG=1 for verbose output
```

## Testing Strategy

- Add error injection to tests
- Validate retry logic works
- Test checkpoint/resume functionality
- Verify error messages are helpful
- Ensure graceful degradation

## Dependencies

None - improves existing scripts

## Related Files

- bootstrap/lib/utils/logging.sh (error functions)
- bootstrap/lib/utils/steps.sh (step management)
- All bootstrap scripts (apply improvements)

## Priority

**Medium** - Improves user experience and debuggability, but not blocking core
functionality.

## Incremental Approach

Following "Less but Better":
1. Start with retry logic for network operations (highest value)
2. Add enhanced error messages for common failures
3. Implement debug mode
4. Consider checkpoint system only if needed

Don't over-engineer. Focus on solving actual problems users encounter.
