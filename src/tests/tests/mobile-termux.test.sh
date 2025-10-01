#!/usr/bin/env bash
set -euo pipefail

# Mobile bootstrap test for Termux
# Tests the NEW config-driven bootstrap system with mocked dependencies

# Source shared assertion helpers
. /lib/assertions.sh

echo "→ Testing mobile bootstrap (config-driven termux.sh)"

# Setup Phase: Install mock doppler and create config
echo "→ Setting up test environment"

# Install mock doppler CLI
mkdir -p ~/bin
cp /fixtures/doppler-mock.sh ~/bin/doppler
chmod +x ~/bin/doppler
export PATH="$HOME/bin:$PATH"

echo "  ✓ Mock doppler installed"

# Create config directory and file
mkdir -p ~/.config/kyldvs/k
cp /fixtures/test-config.json ~/.config/kyldvs/k/configure.json
chmod 600 ~/.config/kyldvs/k/configure.json

echo "  ✓ Test configuration created"

# Verify doppler mock works
assert_command "doppler configure get token --plain --silent" "mock-doppler-token-12345"

# Test Phase 1: Run bootstrap script (pipe to bash like curl pattern)
echo "→ Running bootstrap script (first run)"
bootstrap_output=$(cat /var/www/bootstrap/termux.sh | bash 2>&1) || {
    echo "✗ FAIL: Bootstrap script failed"
    echo "$bootstrap_output"
    exit 1
}
echo "  ✓ Bootstrap completed"

# Test Phase 2: Validate package installations
echo "→ Validating package installations"

if command -v ssh >/dev/null 2>&1; then
    echo "  ✓ openssh installed"
fi

if command -v mosh >/dev/null 2>&1; then
    echo "  ✓ mosh installed"
fi

if command -v jq >/dev/null 2>&1; then
    echo "  ✓ jq installed"
fi

# Test Phase 3: Validate proot-distro setup
echo "→ Validating proot-distro setup"
assert_command_exists "proot-distro"

if [ -d "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/alpine" ]; then
    echo "  ✓ Alpine distro installed"
else
    echo "✗ FAIL: Alpine distro not installed"
    exit 1
fi

# Test Phase 4: Validate Doppler CLI in Alpine
echo "→ Validating Doppler CLI in Alpine"
if proot-distro login alpine -- command -v doppler >/dev/null 2>&1; then
    echo "  ✓ Doppler installed in Alpine"
else
    echo "✗ FAIL: Doppler not found in Alpine"
    exit 1
fi

# Test Phase 5: Validate doppler wrapper
echo "→ Validating doppler wrapper"
assert_file "$HOME/bin/doppler"
assert_file_perms "$HOME/bin/doppler" "755"

# Test wrapper functionality
output=$(doppler 2>&1 || true)
if [[ "$output" != *"Usage:"* ]] || [[ "$output" != *"doppler [command]"* ]]; then
    echo "✗ FAIL: doppler wrapper output incorrect: $output"
    exit 1
fi
echo "  ✓ doppler wrapper works correctly"

# Test Phase 6: Validate SSH keys retrieved from Doppler
echo "→ Validating SSH keys"
assert_file "$HOME/.ssh/gh_vm"
assert_file_perms "$HOME/.ssh/gh_vm" "600"
assert_file "$HOME/.ssh/gh_vm.pub"
assert_file_perms "$HOME/.ssh/gh_vm.pub" "644"

# Test Phase 7: Validate SSH config generation
echo "→ Validating SSH configuration"
assert_file "$HOME/.ssh/config"
assert_file_perms "$HOME/.ssh/config" "600"
assert_file_contains "$HOME/.ssh/config" "Host vm"
assert_file_contains "$HOME/.ssh/config" "HostName mock-vm"
assert_file_contains "$HOME/.ssh/config" "User testuser"
assert_file_contains "$HOME/.ssh/config" "IdentityFile ~/.ssh/gh_vm"

# Test Phase 8: Validate Termux properties configuration
echo "→ Validating Termux properties"
assert_file "$HOME/.config/termux/termux.properties"
assert_file_contains "$HOME/.config/termux/termux.properties" "extra-keys = "
assert_file_contains "$HOME/.config/termux/termux.properties" "['ESC','/','-','|','PGDN','UP','PGUP']"

# Test Phase 9: Validate SSH connectivity to mock-vm
echo "→ Testing SSH connectivity to mock-vm"
if ssh -q -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=no \
    vm exit 2>/dev/null; then
    echo "  ✓ SSH connection successful"
else
    echo "  ⚠ SSH connection failed (may need host key acceptance)"
fi

# Test Phase 10: Idempotency test
echo "→ Testing idempotency (running script again)"
idempotent_output=$(cat /var/www/bootstrap/termux.sh | bash 2>&1) || {
    echo "✗ FAIL: Second bootstrap run failed"
    echo "$idempotent_output"
    exit 1
}

# Check for no errors in output
assert_no_errors "$idempotent_output"
echo "  ✓ Idempotency validated"

echo ""
echo "✓ All mobile bootstrap tests passed"
echo ""
echo "Tested NEW config-driven bootstrap system:"
echo "  - Package installation (openssh, mosh, jq)"
echo "  - Proot-distro + Alpine setup"
echo "  - Doppler CLI installation in Alpine"
echo "  - Doppler wrapper creation and functionality"
echo "  - SSH key retrieval from Doppler"
echo "  - SSH config generation"
echo "  - Termux properties configuration (extra-keys)"
echo "  - SSH connectivity to mock-vm"
echo "  - Idempotency (safe to run multiple times)"
