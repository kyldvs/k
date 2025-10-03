#!/usr/bin/env bash
set -euo pipefail

# Unit tests for enhanced logging
# Tests kd_warning() and kd_info() functions

# Source utilities
. /lib/assertions.sh

# Set KD_NO_COLOR to empty string (colors enabled) before sourcing colors.sh
KD_NO_COLOR="${KD_NO_COLOR:-}"

# Source colors and logging utilities
. /var/www/bootstrap/lib/utils/colors.sh
. /var/www/bootstrap/lib/utils/logging.sh

echo "→ Testing enhanced logging functions"

# Test 1: kd_warning outputs to stderr
echo "→ Test 1: kd_warning outputs to stderr"
warning_stderr=$(kd_warning "test warning" 2>&1 >/dev/null)
if [ -n "$warning_stderr" ]; then
  echo "  ✓ Warning outputs to stderr"
else
  echo "  ✗ FAIL: Warning should output to stderr"
  exit 1
fi

if echo "$warning_stderr" | grep -q "WARNING:"; then
  echo "  ✓ Warning contains WARNING: prefix"
else
  echo "  ✗ FAIL: Expected 'WARNING:' in output"
  echo "  Output: $warning_stderr"
  exit 1
fi

if echo "$warning_stderr" | grep -q "test warning"; then
  echo "  ✓ Warning contains message"
else
  echo "  ✗ FAIL: Expected 'test warning' in output"
  exit 1
fi

# Test 2: kd_info outputs to stdout
echo "→ Test 2: kd_info outputs to stdout"
info_stdout=$(kd_info "test info" 2>/dev/null)
if [ -n "$info_stdout" ]; then
  echo "  ✓ Info outputs to stdout"
else
  echo "  ✗ FAIL: Info should output to stdout"
  exit 1
fi

if echo "$info_stdout" | grep -q "INFO:"; then
  echo "  ✓ Info contains INFO: prefix"
else
  echo "  ✗ FAIL: Expected 'INFO:' in output"
  echo "  Output: $info_stdout"
  exit 1
fi

if echo "$info_stdout" | grep -q "test info"; then
  echo "  ✓ Info contains message"
else
  echo "  ✗ FAIL: Expected 'test info' in output"
  exit 1
fi

# Test 3: kd_error still works (regression test)
echo "→ Test 3: kd_error still works (regression test)"
error_stderr=$(kd_error "test error" 2>&1 >/dev/null)
if [ -n "$error_stderr" ]; then
  echo "  ✓ Error outputs to stderr"
else
  echo "  ✗ FAIL: Error should output to stderr"
  exit 1
fi

if echo "$error_stderr" | grep -q "ERROR"; then
  echo "  ✓ Error contains ERROR prefix"
else
  echo "  ✗ FAIL: Expected 'ERROR' in output"
  echo "  Output: $error_stderr"
  exit 1
fi

# Test 4: Color codes present (if colors enabled)
echo "→ Test 4: Color codes present (if colors enabled)"
if [ -z "$KD_NO_COLOR" ]; then
  warning_raw=$(kd_warning "color test" 2>&1 >/dev/null)
  # Check for ANSI escape sequence (yellow color)
  if echo "$warning_raw" | grep -q "$(printf '\033')"; then
    echo "  ✓ Color codes present in warning"
  else
    echo "  ✗ FAIL: Expected ANSI color codes in warning"
    exit 1
  fi

  info_raw=$(kd_info "color test" 2>/dev/null)
  # Check for ANSI escape sequence (blue color)
  if echo "$info_raw" | grep -q "$(printf '\033')"; then
    echo "  ✓ Color codes present in info"
  else
    echo "  ✗ FAIL: Expected ANSI color codes in info"
    exit 1
  fi
else
  echo "  ⊘ Skipped (colors disabled)"
fi

# Test 5: Warning emoji present
echo "→ Test 5: Warning emoji present"
warning_emoji=$(kd_warning "emoji test" 2>&1 >/dev/null)
if echo "$warning_emoji" | grep -q "⚠"; then
  echo "  ✓ Warning emoji (⚠) present"
else
  echo "  ✗ FAIL: Expected warning emoji ⚠"
  exit 1
fi

# Test 6: Info emoji present
echo "→ Test 6: Info emoji present"
info_emoji=$(kd_info "emoji test" 2>/dev/null)
if echo "$info_emoji" | grep -q "ℹ"; then
  echo "  ✓ Info emoji (ℹ) present"
else
  echo "  ✗ FAIL: Expected info emoji ℹ"
  exit 1
fi

echo ""
echo "✓ All logging tests passed"
