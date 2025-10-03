# Retry wrapper for transient failures
# Usage: kd_retry command [args...]
# Environment: KD_RETRY_MAX (default: 3), KD_RETRY_DELAY (default: 2)

kd_retry() {
  local max_attempts="${KD_RETRY_MAX:-3}"
  local delay="${KD_RETRY_DELAY:-2}"
  local attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    if "$@"; then
      return 0
    fi

    if [ "$attempt" -lt "$max_attempts" ]; then
      kd_log "Retry $attempt/$max_attempts in ${delay}s..."
      sleep "$delay"
    fi
    attempt=$((attempt + 1))
  done

  kd_error "Failed after $max_attempts attempts: $*"
  return 1
}
