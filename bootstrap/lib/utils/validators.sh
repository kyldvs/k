#!/usr/bin/env sh
# Input validation functions for bootstrap configuration
# All validators return 0 (valid) or 1 (invalid)

# Validate hostname format (RFC 1123)
# Valid: alphanumeric, dots, hyphens; max 253 chars
# Must start/end with alphanumeric (no leading/trailing hyphens or dots)
# Examples: example.com, 192.168.1.1, host-name.example.com
validate_hostname() {
  local hostname="$1"

  # Check not empty
  [ -z "$hostname" ] && return 1

  # Check length (max 253 chars per RFC 1123)
  [ ${#hostname} -gt 253 ] && return 1

  # Check format: alphanumeric with dots/hyphens
  # Each label max 63 chars, must start/end with alphanumeric
  echo "$hostname" | grep -qE '^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
}

# Validate port number (1-65535)
# Valid: integer in range 1-65535
# Examples: 22, 8080, 65535
validate_port() {
  local port="$1"

  # Check not empty
  [ -z "$port" ] && return 1

  # Check is integer (only digits)
  echo "$port" | grep -qE '^[0-9]+$' || return 1

  # Check range (1-65535)
  [ "$port" -ge 1 ] && [ "$port" -le 65535 ]
}

# Validate username (POSIX portable username rules)
# Valid: lowercase letters, digits, underscore, hyphen; max 32 chars
# Must start with lowercase letter or underscore
# Examples: john, _user, user-name, kad123
validate_username() {
  local username="$1"

  # Check not empty
  [ -z "$username" ] && return 1

  # Check length (max 32 chars per POSIX)
  [ ${#username} -gt 32 ] && return 1

  # Check format: start with letter or underscore, then alphanumeric/_/-
  echo "$username" | grep -qE '^[a-z_][a-z0-9_-]*$'
}

# Validate directory path
# Valid: absolute path starting with /, no shell injection chars
# Examples: /home, /mnt/kad, /usr/local/bin
validate_directory() {
  local dir="$1"

  # Check not empty
  [ -z "$dir" ] && return 1

  # Check starts with / (absolute path)
  case "$dir" in
    /*) ;;
    *) return 1 ;;
  esac

  # Check no shell injection characters
  echo "$dir" | grep -qE '[<>|;&$`]' && return 1

  return 0
}
