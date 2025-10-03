#!/usr/bin/env bash
set -euo pipefail

# Unit tests for retry logic
# Tests the kd_retry function with various failure scenarios

# Source utilities
. /lib/assertions.sh

# Source colors for kd_error
KD_RED=$(printf '\033[31m')
KD_RESET=$(printf '\033[0m')

# Source retry and logging utilities
. /var/www/bootstrap/lib/utils/logging.sh
. /var/www/bootstrap/lib/utils/retry.sh

echo "→ Testing retry logic"

# Test 1: Command succeeds immediately
echo "→ Test 1: Command succeeds immediately"
success_count=0
always_succeed() {
  success_count=$((success_count + 1))
  return 0
}

if kd_retry always_succeed >/dev/null 2>&1; then
  echo "  ✓ Command succeeded"
else
  echo "  ✗ FAIL: Command should have succeeded"
  exit 1
fi

if [ "$success_count" -eq 1 ]; then
  echo "  ✓ Called exactly once (no retries needed)"
else
  echo "  ✗ FAIL: Called $success_count times, expected 1"
  exit 1
fi

# Test 2: Command succeeds after 2 failures
echo "→ Test 2: Command succeeds after 2 failures"
attempt_count=0
fail_twice() {
  attempt_count=$((attempt_count + 1))
  [ "$attempt_count" -gt 2 ]
}

# Set minimal delay for faster tests
KD_RETRY_DELAY=0 attempt_count=0
if kd_retry fail_twice >/dev/null 2>&1; then
  echo "  ✓ Command succeeded after retries"
else
  echo "  ✗ FAIL: Command should have succeeded after 2 failures"
  exit 1
fi

if [ "$attempt_count" -eq 3 ]; then
  echo "  ✓ Retried correct number of times (3 attempts total)"
else
  echo "  ✗ FAIL: Attempted $attempt_count times, expected 3"
  exit 1
fi

# Test 3: Command fails after max attempts
echo "→ Test 3: Command fails after max attempts"
fail_count=0
always_fail() {
  fail_count=$((fail_count + 1))
  return 1
}

KD_RETRY_DELAY=0 fail_count=0
if kd_retry always_fail >/dev/null 2>&1; then
  echo "  ✗ FAIL: Command should have failed"
  exit 1
else
  echo "  ✓ Command failed as expected"
fi

if [ "$fail_count" -eq 3 ]; then
  echo "  ✓ Exhausted all retry attempts (3 attempts)"
else
  echo "  ✗ FAIL: Attempted $fail_count times, expected 3"
  exit 1
fi

# Test 4: Custom retry configuration
echo "→ Test 4: Custom retry configuration (KD_RETRY_MAX=5)"
custom_count=0
fail_four_times() {
  custom_count=$((custom_count + 1))
  [ "$custom_count" -gt 4 ]
}

KD_RETRY_MAX=5 KD_RETRY_DELAY=0 custom_count=0
if kd_retry fail_four_times >/dev/null 2>&1; then
  echo "  ✓ Command succeeded with custom max attempts"
else
  echo "  ✗ FAIL: Command should have succeeded with 5 max attempts"
  exit 1
fi

if [ "$custom_count" -eq 5 ]; then
  echo "  ✓ Respected KD_RETRY_MAX=5"
else
  echo "  ✗ FAIL: Attempted $custom_count times, expected 5"
  exit 1
fi

# Test 5: Verify retry logging output
echo "→ Test 5: Verify retry logging output"
log_test_count=0
fail_once() {
  log_test_count=$((log_test_count + 1))
  [ "$log_test_count" -gt 1 ]
}

KD_RETRY_MAX=3 KD_RETRY_DELAY=0 log_test_count=0
output=$(kd_retry fail_once 2>&1)
if echo "$output" | grep -q "Retry 1/3"; then
  echo "  ✓ Retry message logged correctly"
else
  echo "  ✗ FAIL: Expected 'Retry 1/3' in output"
  echo "  Output: $output"
  exit 1
fi

echo ""
echo "✓ All retry logic tests passed"
