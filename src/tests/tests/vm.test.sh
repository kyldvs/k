#!/usr/bin/env bash
set -euo pipefail

# Test assertions for vm bootstrap script
# This script runs inside the docker container

# Source shared assertion helpers
. /lib/assertions.sh

echo "→ Testing vm bootstrap script"

# Test 1: Run the bootstrap script
echo "→ Running bootstrap script"
curl -fsSL http://k.local/vm.sh | bash

# Test 2: Check fake-sudo setup
echo "→ Testing fake-sudo setup"
assert_file "$HOME/bin/sudo"
assert_symlink "$HOME/bin/sudo" "$HOME/fake-sudo/sudo"
assert_file "$HOME/fake-sudo/sudo"

# Test 3: Check profile initialization
echo "→ Testing profile initialization"
assert_file "$HOME/.profile"
assert_file_contains "$HOME/.profile" "POSIX"

# Test 4: Test sudo command works
echo "→ Testing sudo command functionality"
export PATH="$HOME/bin:$PATH"
assert_command "sudo echo test" "test"

# Test 5: Check mosh installation
echo "→ Testing mosh installation"
assert_command_exists "mosh"

# Test 6: Check ssh-utils setup
echo "→ Testing ssh-utils setup"
assert_file "$HOME/.config/k/ssh-utils.sh"
assert_file_contains "$HOME/.config/k/ssh-utils.sh" "ssha()"
assert_file_contains "$HOME/.config/k/ssh-utils.sh" "mosha()"

# Test 7: Check .config/k directory structure
echo "→ Testing .config/k directory structure"
assert_file "$HOME/.config/k/ssh-utils.sh"

# Test 8: Idempotency test - run again
echo "→ Testing idempotency (running script again)"
curl -fsSL http://k.local/vm.sh | bash
assert_file "$HOME/bin/sudo"
assert_symlink "$HOME/bin/sudo" "$HOME/fake-sudo/sudo"
assert_file "$HOME/.config/k/ssh-utils.sh"

echo "✓ All vm bootstrap tests passed"
