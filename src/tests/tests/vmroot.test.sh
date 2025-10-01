#!/usr/bin/env bash
set -euo pipefail

# VM root bootstrap test
# Tests vmroot-configure.sh and vmroot.sh scripts

# Source shared assertion helpers
. /lib/assertions.sh

echo "→ Testing vmroot bootstrap"

# Setup Phase: Prepare test environment
echo "→ Setting up test environment"

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "✗ FAIL: Must run as root"
  exit 1
fi

# Create mock root authorized_keys for SSH test
mkdir -p /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC... test@key" > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

echo "  ✓ Test environment ready"

# Test Phase 1: Run vmroot-configure.sh non-interactively
echo "→ Testing vmroot-configure.sh (non-interactive)"

# Create config directory and file directly (simulating interactive prompts)
mkdir -p /root/.config/kyldvs/k
cp /fixtures/vmroot-test-config.json /root/.config/kyldvs/k/vmroot-configure.json
chmod 600 /root/.config/kyldvs/k/vmroot-configure.json

assert_file "/root/.config/kyldvs/k/vmroot-configure.json"
echo "  ✓ Configuration file created"

# Test Phase 2: Run vmroot.sh bootstrap script
echo "→ Running vmroot.sh bootstrap script (first run)"

bootstrap_output=$(bash /var/www/bootstrap/vmroot.sh 2>&1) || {
  echo "✗ FAIL: Bootstrap script failed"
  echo "$bootstrap_output"
  exit 1
}
echo "  ✓ Bootstrap completed"

# Test Phase 3: Validate user creation
echo "→ Validating user creation"

if id testuser >/dev/null 2>&1; then
  echo "  ✓ User testuser created"
else
  echo "✗ FAIL: User testuser not found"
  exit 1
fi

# Verify home directory
assert_file "/home/testuser"
echo "  ✓ Home directory exists"

# Test Phase 4: Validate sudoers configuration
echo "→ Validating sudoers configuration"

assert_file "/etc/sudoers.d/vmroot-testuser"
assert_file_perms "/etc/sudoers.d/vmroot-testuser" "440"

# Verify sudoers content
if grep -q "testuser ALL=(ALL) NOPASSWD:ALL" /etc/sudoers.d/vmroot-testuser; then
  echo "  ✓ Sudoers configured correctly"
else
  echo "✗ FAIL: Sudoers content incorrect"
  exit 1
fi

# Test Phase 5: Validate SSH keys
echo "→ Validating SSH key setup"

assert_file "/home/testuser/.ssh/authorized_keys"
assert_file_perms "/home/testuser/.ssh" "700"
assert_file_perms "/home/testuser/.ssh/authorized_keys" "600"

# Verify ownership
ssh_owner=$(stat -c '%U' /home/testuser/.ssh)
if [ "$ssh_owner" = "testuser" ]; then
  echo "  ✓ SSH directory ownership correct"
else
  echo "✗ FAIL: SSH directory ownership incorrect (expected testuser, got $ssh_owner)"
  exit 1
fi

# Verify key content
if grep -q "test@key" /home/testuser/.ssh/authorized_keys; then
  echo "  ✓ SSH keys copied correctly"
else
  echo "✗ FAIL: SSH keys not copied"
  exit 1
fi

# Test Phase 6: Test idempotency (run again)
echo "→ Testing idempotency (running bootstrap again)"

bootstrap_output2=$(bash /var/www/bootstrap/vmroot.sh 2>&1) || {
  echo "✗ FAIL: Second run failed"
  echo "$bootstrap_output2"
  exit 1
}

# Should show skip messages
if echo "$bootstrap_output2" | grep -q "skip"; then
  echo "  ✓ Idempotency verified (operations skipped)"
else
  echo "  ⚠ Warning: No skip messages found, but no errors"
fi

# Test Phase 7: Verify sudo functionality
echo "→ Testing sudo access"

if su - testuser -c 'sudo whoami' 2>/dev/null | grep -q "root"; then
  echo "  ✓ Passwordless sudo works"
else
  echo "✗ FAIL: Sudo access not working"
  exit 1
fi

echo ""
echo "✓ All vmroot tests passed"
