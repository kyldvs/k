#!/bin/sh
#
# Interactive configuration script for VM root bootstrap
# Creates /root/.config/kyldvs/k/vmroot-configure.json with user settings
#

set -e

# Validate running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] This script must be run as root" >&2
  exit 1
fi

# POSIX compliant color definitions - always enable unless KD_NO_COLOR is set
if [ -z "$KD_NO_COLOR" ]; then
  KD_RED=$(printf '\033[31m')
  KD_GREEN=$(printf '\033[32m')
  KD_YELLOW=$(printf '\033[33m')
  KD_BLUE=$(printf '\033[34m')
  KD_CYAN=$(printf '\033[36m')
  KD_GRAY=$(printf '\033[90m')
  KD_WHITE=$(printf '\033[97m')
  KD_RESET=$(printf '\033[0m')
  KD_BOLD=$(printf '\033[1m')
else
  KD_RED=''
  KD_GREEN=''
  KD_YELLOW=''
  KD_BLUE=''
  KD_CYAN=''
  KD_GRAY=''
  KD_WHITE=''
  KD_RESET=''
  KD_BOLD=''
fi

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

# Configuration file path for vmroot
VMROOT_CONFIG_DIR="/root/.config/kyldvs/k"
VMROOT_CONFIG_FILE="$VMROOT_CONFIG_DIR/vmroot-configure.json"

#!/usr/bin/env sh
# Prompt helper function for vmroot
vmroot_prompt() {
  local prompt_text="$1"
  local default_value="$2"
  local var_name="$3"

  if [ -n "$default_value" ]; then
    printf "%s%s%s [%s]: " "$KD_CYAN" "$prompt_text" "$KD_RESET" "$default_value"
  else
    printf "%s%s%s: " "$KD_CYAN" "$prompt_text" "$KD_RESET"
  fi

  read -r value

  if [ -z "$value" ] && [ -n "$default_value" ]; then
    value="$default_value"
  fi

  eval "$var_name=\"\$value\""
}

# Validated prompt helper function for vmroot
# Loops until valid input is received
vmroot_prompt_validated() {
  local prompt_text="$1"
  local default_value="$2"
  local var_name="$3"
  local validator="$4"
  local error_msg="$5"

  while true; do
    # Get user input using standard prompt
    vmroot_prompt "$prompt_text" "$default_value" "$var_name"
    eval "value=\$$var_name"

    # Validate input
    if $validator "$value"; then
      return 0
    fi

    # Show error and re-prompt
    printf "%s✗ Invalid input:%s %s\n" "$KD_RED" "$KD_RESET" "$error_msg"
  done
}

# Validation function for vmroot configuration
validate_vmroot_config() {
  local username="$1"
  local homedir="$2"

  if [ -z "$username" ]; then
    printf "%s[ERROR]%s Username is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$homedir" ]; then
    printf "%s[ERROR]%s Home directory is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  # Validate home directory parent is writable
  local parent_dir
  parent_dir=$(dirname "$homedir")
  if [ ! -d "$parent_dir" ] && [ ! -w "$(dirname "$parent_dir")" ]; then
    printf "%s[ERROR]%s Home directory parent is not writable: %s\n" \
      "$KD_RED" "$KD_RESET" "$parent_dir" >&2
    return 1
  fi

  return 0
}

#!/usr/bin/env sh
# Main configuration flow for vmroot
main() {
  printf "\n%s%sVM Root Bootstrap Configuration%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "This script will configure VM root provisioning.\n\n"

  # Prompt for configuration
  printf "%s%sUser Configuration:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  vmroot_prompt_validated "Username" "kad" username validate_username \
    "Username must start with letter/underscore, contain only lowercase letters, digits, underscore, hyphen"
  vmroot_prompt_validated "Home directory" "/mnt/kad" homedir validate_directory \
    "Directory must be absolute path starting with /"

  printf "\n"

  # Validate inputs
  if ! validate_vmroot_config "$username" "$homedir"; then
    exit 1
  fi

  # Create config directory
  printf "%s→%s Creating config directory...\n" "$KD_CYAN" "$KD_RESET"
  mkdir -p "$VMROOT_CONFIG_DIR"
  chmod 700 "$VMROOT_CONFIG_DIR"

  # Write JSON config
  printf "%s→%s Writing configuration to %s...\n" "$KD_CYAN" "$KD_RESET" \
    "$VMROOT_CONFIG_FILE"

  cat > "$VMROOT_CONFIG_FILE" <<EOF
{
  "username": "$username",
  "homedir": "$homedir"
}
EOF

  chmod 600 "$VMROOT_CONFIG_FILE"

  printf "%s✓%s Configuration saved successfully!\n\n" "$KD_GREEN" "$KD_RESET"

  # Display next steps
  printf "%s%sNext Steps:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  printf "  1. Run the VM root bootstrap script:\n"
  printf "     %sbash bootstrap/vmroot.sh%s\n" "$KD_CYAN" "$KD_RESET"
  printf "\n"
}

main

