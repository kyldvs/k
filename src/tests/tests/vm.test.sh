#!/usr/bin/env bash
set -euo pipefail

# Test assertions for vm bootstrap script
# This script runs inside the docker container

echo "→ Testing vm bootstrap script"

# Helper functions for assertions
assert_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "✗ FAIL: File $file does not exist"
        exit 1
    fi
    echo "✓ File exists: $file"
}

assert_symlink() {
    local link="$1"
    local target="$2"
    if [ ! -L "$link" ]; then
        echo "✗ FAIL: $link is not a symlink"
        exit 1
    fi
    local actual_target
    actual_target=$(readlink "$link")
    if [ "$actual_target" != "$target" ]; then
        echo "✗ FAIL: $link points to $actual_target, expected $target"
        exit 1
    fi
    echo "✓ Symlink correct: $link → $target"
}

assert_command() {
    local cmd="$1"
    local expected="$2"
    local actual
    if ! actual=$($cmd 2>&1); then
        echo "✗ FAIL: Command failed: $cmd"
        exit 1
    fi
    if [ "$actual" != "$expected" ]; then
        echo "✗ FAIL: Command output mismatch"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        exit 1
    fi
    echo "✓ Command output correct: $cmd"
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    if ! grep -q "$pattern" "$file" 2>/dev/null; then
        echo "✗ FAIL: File $file does not contain: $pattern"
        exit 1
    fi
    echo "✓ File contains pattern: $file"
}

assert_command_exists() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "✗ FAIL: Command $cmd not found"
        exit 1
    fi
    echo "✓ Command exists: $cmd"
}

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
