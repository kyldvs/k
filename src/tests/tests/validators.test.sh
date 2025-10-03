#!/usr/bin/env bash
set -euo pipefail

# Validator unit tests
# Tests all four validation functions with valid/invalid inputs

# Source validators from built script
. /var/www/bootstrap/lib/utils/validators.sh

echo "→ Testing input validators"

# Helper function to test valid inputs
test_valid() {
  local validator="$1"
  local input="$2"
  if ! $validator "$input"; then
    echo "  ✗ FAIL: '$input' should be valid for $validator"
    exit 1
  fi
  echo "  ✓ Valid: $input"
}

# Helper function to test invalid inputs
test_invalid() {
  local validator="$1"
  local input="$2"
  if $validator "$input"; then
    echo "  ✗ FAIL: '$input' should be invalid for $validator"
    exit 1
  fi
  echo "  ✓ Invalid: $input"
}

# ============================================================================
# validate_hostname tests
# ============================================================================
echo "→ Testing validate_hostname"

# Valid hostnames
test_valid validate_hostname "example.com"
test_valid validate_hostname "192.168.1.1"
test_valid validate_hostname "host-name.example.com"
test_valid validate_hostname "a"
test_valid validate_hostname "a.b"
test_valid validate_hostname "localhost"
test_valid validate_hostname "test123.example-site.com"

# Invalid hostnames
test_invalid validate_hostname ""
test_invalid validate_hostname "-invalid.com"
test_invalid validate_hostname "invalid-.com"
test_invalid validate_hostname ".invalid.com"
test_invalid validate_hostname "invalid.com."
test_invalid validate_hostname "has spaces.com"
test_invalid validate_hostname "test@example.com"
test_invalid validate_hostname "test_host.com"

# Too long hostname
long_hostname=$(printf 'a%.0s' {1..254})
test_invalid validate_hostname "$long_hostname"

echo "  ✓ validate_hostname tests passed"

# ============================================================================
# validate_port tests
# ============================================================================
echo "→ Testing validate_port"

# Valid ports
test_valid validate_port "1"
test_valid validate_port "22"
test_valid validate_port "80"
test_valid validate_port "8080"
test_valid validate_port "65535"

# Invalid ports
test_invalid validate_port ""
test_invalid validate_port "abc"
test_invalid validate_port "22abc"
test_invalid validate_port "port22"
test_invalid validate_port "0"
test_invalid validate_port "-1"
test_invalid validate_port "65536"
test_invalid validate_port "99999"
test_invalid validate_port "22.5"

echo "  ✓ validate_port tests passed"

# ============================================================================
# validate_username tests
# ============================================================================
echo "→ Testing validate_username"

# Valid usernames
test_valid validate_username "john"
test_valid validate_username "_user"
test_valid validate_username "user-name"
test_valid validate_username "a"
test_valid validate_username "kad"
test_valid validate_username "user123"
test_valid validate_username "test_user"

# Invalid usernames
test_invalid validate_username ""
test_invalid validate_username "UPPERCASE"
test_invalid validate_username "John"
test_invalid validate_username "123user"
test_invalid validate_username "has space"
test_invalid validate_username "user@host"
test_invalid validate_username "user.name"
test_invalid validate_username "-user"

# Too long username
long_username=$(printf 'a%.0s' {1..33})
test_invalid validate_username "$long_username"

echo "  ✓ validate_username tests passed"

# ============================================================================
# validate_directory tests
# ============================================================================
echo "→ Testing validate_directory"

# Valid directories
test_valid validate_directory "/home"
test_valid validate_directory "/mnt/kad"
test_valid validate_directory "/usr/local/bin"
test_valid validate_directory "/"
test_valid validate_directory "/path/with-hyphens"
test_valid validate_directory "/path/with_underscores"

# Invalid directories
test_invalid validate_directory ""
test_invalid validate_directory "relative/path"
test_invalid validate_directory "./current"
test_invalid validate_directory "../parent"
test_invalid validate_directory "/path;cmd"
test_invalid validate_directory "/path|cmd"
test_invalid validate_directory "/path&cmd"
# shellcheck disable=SC2016
test_invalid validate_directory '/path$var'
# shellcheck disable=SC2016
test_invalid validate_directory '/path`cmd`'
test_invalid validate_directory "/path<file"
test_invalid validate_directory "/path>file"

echo "  ✓ validate_directory tests passed"

echo ""
echo "✓ All validator tests passed"
echo ""
echo "Tested 4 validators with 60+ test cases:"
echo "  - validate_hostname: RFC 1123 hostname format"
echo "  - validate_port: Integer 1-65535"
echo "  - validate_username: POSIX portable username rules"
echo "  - validate_directory: Absolute paths without injection chars"
