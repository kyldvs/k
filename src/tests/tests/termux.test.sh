#!/usr/bin/env bash
set -euo pipefail

# Test assertions for termux bootstrap script
# This script runs inside the docker container

echo "→ Testing termux bootstrap script"

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

# Test 1: Run the bootstrap script
echo "→ Running bootstrap script"
curl -fsSL http://k.local/termux.sh | bash

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

# Test 5: Check nerdfetch installation
echo "→ Testing nerdfetch installation"
assert_file "/data/data/com.termux/files/usr/bin/nerdfetch"
if [ ! -x "/data/data/com.termux/files/usr/bin/nerdfetch" ]; then
    echo "✗ FAIL: nerdfetch is not executable"
    exit 1
fi
echo "✓ nerdfetch is executable"

# Test 6: Check proot-distro installation
echo "→ Testing proot-distro installation"
if ! command -v proot-distro >/dev/null 2>&1; then
    echo "✗ FAIL: proot-distro command not found"
    exit 1
fi
echo "✓ proot-distro is installed"

# Test 7: Check Alpine distro installation
echo "→ Testing Alpine distro installation"
if ! ls -la /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ | grep -q "alpine"; then
    echo "✗ FAIL: Alpine distro not installed"
    echo "Installed distributions:"
    ls -la /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ 2>/dev/null || true
    proot-distro list 2>/dev/null || true
    exit 1
fi
echo "✓ Alpine distro is installed"

# Test 8: Check doppler wrapper
echo "→ Testing doppler wrapper"
assert_file "$HOME/bin/doppler"
if [ ! -x "$HOME/bin/doppler" ]; then
    echo "✗ FAIL: doppler wrapper is not executable"
    exit 1
fi
echo "✓ doppler wrapper is executable"

# Test 9: Check doppler in Alpine
echo "→ Testing doppler in Alpine"
if ! proot-distro login alpine -- command -v doppler >/dev/null 2>&1; then
    echo "✗ FAIL: doppler not found in Alpine"
    exit 1
fi
echo "✓ doppler is installed in Alpine"

# Test 10: Test doppler wrapper functionality
echo "→ Testing doppler wrapper functionality"
export PATH="$HOME/bin:$PATH"
output=$(doppler 2>&1 || true)
if [[ "$output" != *"hello doppler"* ]]; then
    echo "✗ FAIL: doppler wrapper output incorrect: $output"
    exit 1
fi
echo "✓ doppler wrapper works correctly"

# Test 11: Idempotency test - run again
echo "→ Testing idempotency (running script again)"
curl -fsSL http://k.local/termux.sh | bash
assert_file "$HOME/bin/sudo"
assert_symlink "$HOME/bin/sudo" "$HOME/fake-sudo/sudo"
assert_file "$HOME/bin/doppler"

echo "✓ All termux bootstrap tests passed"
