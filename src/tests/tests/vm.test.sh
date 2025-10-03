#!/usr/bin/env bash
set -euo pipefail

# VM bootstrap test
# Tests vm.sh script with focus on git-config component

# Source shared assertion helpers
. /test-lib/assertions.sh

echo "→ Testing VM bootstrap"

# Setup Phase: Prepare test environment
echo "→ Setting up test environment"

# Ensure HOME is set
if [ -z "${HOME:-}" ]; then
  export HOME="/root"
fi

# Set up Git with existing user identity to test preservation
git config --global user.name "Test User"
git config --global user.email "test@example.com"

echo "  ✓ Test environment ready"
echo "  ✓ Existing Git identity set (user.name, user.email)"

# Test Phase 1: Run vm.sh bootstrap script
echo "→ Running vm.sh bootstrap script (first run)"

bootstrap_output=$(bash /var/www/bootstrap/vm.sh 2>&1) || {
  echo "✗ FAIL: Bootstrap script failed"
  echo "$bootstrap_output"
  exit 1
}
echo "  ✓ Bootstrap completed"

# Test Phase 2: Validate Git configuration applied
echo "→ Validating Git configuration"

# Check all 8 configuration values
echo "  → Checking push.default"
push_default=$(git config --global --get push.default)
if [ "$push_default" = "current" ]; then
  echo "    ✓ push.default = current"
else
  echo "✗ FAIL: push.default = $push_default (expected: current)"
  exit 1
fi

echo "  → Checking pull.ff"
pull_ff=$(git config --global --get pull.ff)
if [ "$pull_ff" = "true" ]; then
  echo "    ✓ pull.ff = true"
else
  echo "✗ FAIL: pull.ff = $pull_ff (expected: true)"
  exit 1
fi

echo "  → Checking merge.ff"
merge_ff=$(git config --global --get merge.ff)
if [ "$merge_ff" = "true" ]; then
  echo "    ✓ merge.ff = true"
else
  echo "✗ FAIL: merge.ff = $merge_ff (expected: true)"
  exit 1
fi

echo "  → Checking merge.conflictstyle"
merge_conflictstyle=$(git config --global --get merge.conflictstyle)
if [ "$merge_conflictstyle" = "zdiff3" ]; then
  echo "    ✓ merge.conflictstyle = zdiff3"
else
  echo "✗ FAIL: merge.conflictstyle = $merge_conflictstyle (expected: zdiff3)"
  exit 1
fi

echo "  → Checking init.defaultBranch"
init_defaultBranch=$(git config --global --get init.defaultBranch)
if [ "$init_defaultBranch" = "main" ]; then
  echo "    ✓ init.defaultBranch = main"
else
  echo "✗ FAIL: init.defaultBranch = $init_defaultBranch (expected: main)"
  exit 1
fi

echo "  → Checking diff.algorithm"
diff_algorithm=$(git config --global --get diff.algorithm)
if [ "$diff_algorithm" = "histogram" ]; then
  echo "    ✓ diff.algorithm = histogram"
else
  echo "✗ FAIL: diff.algorithm = $diff_algorithm (expected: histogram)"
  exit 1
fi

echo "  → Checking log.date"
log_date=$(git config --global --get log.date)
if [ "$log_date" = "iso" ]; then
  echo "    ✓ log.date = iso"
else
  echo "✗ FAIL: log.date = $log_date (expected: iso)"
  exit 1
fi

echo "  → Checking core.autocrlf"
core_autocrlf=$(git config --global --get core.autocrlf)
if [ "$core_autocrlf" = "false" ]; then
  echo "    ✓ core.autocrlf = false"
else
  echo "✗ FAIL: core.autocrlf = $core_autocrlf (expected: false)"
  exit 1
fi

echo "  ✓ All 8 Git configuration settings correct"

# Test Phase 3: Validate user identity preserved
echo "→ Validating user identity preservation"

user_name=$(git config --global --get user.name)
if [ "$user_name" = "Test User" ]; then
  echo "  ✓ user.name preserved (Test User)"
else
  echo "✗ FAIL: user.name = $user_name (expected: Test User)"
  exit 1
fi

user_email=$(git config --global --get user.email)
if [ "$user_email" = "test@example.com" ]; then
  echo "  ✓ user.email preserved (test@example.com)"
else
  echo "✗ FAIL: user.email = $user_email (expected: test@example.com)"
  exit 1
fi

# Test Phase 4: Test idempotency (run again)
echo "→ Testing idempotency (running bootstrap again)"

bootstrap_output2=$(bash /var/www/bootstrap/vm.sh 2>&1) || {
  echo "✗ FAIL: Second run failed"
  echo "$bootstrap_output2"
  exit 1
}

# Should show skip message
if echo "$bootstrap_output2" | grep -q "skip"; then
  echo "  ✓ Idempotency verified (operations skipped)"
else
  echo "  ⚠ Warning: No skip messages found, but no errors"
fi

# Verify configuration still correct after second run
echo "  → Verifying configuration unchanged"
merge_conflictstyle2=$(git config --global --get merge.conflictstyle)
if [ "$merge_conflictstyle2" = "zdiff3" ]; then
  echo "  ✓ Configuration unchanged after second run"
else
  echo "✗ FAIL: Configuration changed after second run"
  exit 1
fi

echo ""
echo "✓ All VM tests passed"
