#!/usr/bin/env bash
# Shared test assertion helpers

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
