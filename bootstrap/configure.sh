#!/bin/sh
#
# Interactive configuration script for k bootstrap system
# Creates ~/.config/kyldvs/k/configure.json with user settings
#

set -e

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

# Indentation tracking
KD_INDENT=0
KD_CURRENT_STEP=""

# Get current indentation string
_kd_indent() {
  i=0
  while [ $i -lt $KD_INDENT ]; do
    printf "  "
    i=$((i + 1))
  done
}

# Log functions
kd_log() {
  local msg="$*"
  printf "%s%s\n" "$(_kd_indent)" "$msg"
}

kd_error() {
  local msg="$*"
  printf "%s[ERROR]%s %s\n" "$KD_RED" "$KD_RESET" "$msg" >&2
}

kd_warning() {
  local msg="$*"
  printf "%s⚠ WARNING:%s %s\n" "$KD_YELLOW" "$KD_RESET" "$msg" >&2
}

kd_info() {
  local msg="$*"
  printf "%sℹ INFO:%s %s\n" "$KD_BLUE" "$KD_RESET" "$msg"
}

# Retry wrapper for transient failures
# Usage: kd_retry command [args...]
# Environment: KD_RETRY_MAX (default: 3), KD_RETRY_DELAY (default: 2)

kd_retry() {
  local max_attempts="${KD_RETRY_MAX:-3}"
  local delay="${KD_RETRY_DELAY:-2}"
  local attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    if "$@"; then
      return 0
    fi

    if [ "$attempt" -lt "$max_attempts" ]; then
      kd_log "Retry $attempt/$max_attempts in ${delay}s..."
      sleep "$delay"
    fi
    attempt=$((attempt + 1))
  done

  kd_error "Failed after $max_attempts attempts: $*"
  return 1
}

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

#!/usr/bin/env sh
# Configuration file path
CONFIG_DIR="$HOME/.config/kyldvs/k"
CONFIG_FILE="$CONFIG_DIR/configure.json"

# Prompt helper function
prompt() {
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

# Validated prompt helper function
# Loops until valid input is received
prompt_validated() {
  local prompt_text="$1"
  local default_value="$2"
  local var_name="$3"
  local validator="$4"
  local error_msg="$5"

  while true; do
    # Get user input using standard prompt
    prompt "$prompt_text" "$default_value" "$var_name"
    eval "value=\$$var_name"

    # Validate input
    if $validator "$value"; then
      return 0
    fi

    # Show error and re-prompt
    printf "%s✗ Invalid input:%s %s\n" "$KD_RED" "$KD_RESET" "$error_msg"
  done
}

# Validation function
validate_config() {
  local vm_hostname="$1"
  local vm_port="$2"
  local vm_username="$3"
  local doppler_project="$4"
  local doppler_env="$5"

  if [ -z "$vm_hostname" ]; then
    printf "%s[ERROR]%s VM hostname is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$vm_port" ]; then
    printf "%s[ERROR]%s VM port is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$vm_username" ]; then
    printf "%s[ERROR]%s VM username is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$doppler_project" ]; then
    printf "%s[ERROR]%s Doppler project is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$doppler_env" ]; then
    printf "%s[ERROR]%s Doppler environment is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  return 0
}

#!/usr/bin/env sh
# Main configuration flow
main() {
  printf "\n%s%sConfiguration Setup%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "This script will configure your k bootstrap system.\n\n"

  # VM Configuration
  printf "%s%sVM Configuration:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  prompt_validated "VM hostname/IP" "" vm_hostname validate_hostname \
    "Hostname must be alphanumeric with dots/hyphens (e.g., 192.168.1.1 or host.example.com)"
  prompt_validated "VM SSH port" "22" vm_port validate_port \
    "Port must be 1-65535"
  prompt_validated "VM username" "kad" vm_username validate_username \
    "Username must start with letter/underscore, contain only lowercase letters, digits, underscore, hyphen"

  printf "\n"

  # Doppler Configuration
  printf "%s%sDoppler Configuration:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  prompt "Doppler project" "main" doppler_project
  prompt "Doppler environment" "prd" doppler_env
  prompt "SSH public key name in Doppler" "SSH_GH_VM_PUBLIC" ssh_key_public
  prompt "SSH private key name in Doppler" "SSH_GH_VM_PRIVATE" ssh_key_private

  printf "\n"

  # Validate inputs
  if ! validate_config "$vm_hostname" "$vm_port" "$vm_username" \
                      "$doppler_project" "$doppler_env"; then
    exit 1
  fi

  # Create config directory
  printf "%s→%s Creating config directory...\n" "$KD_CYAN" "$KD_RESET"
  mkdir -p "$CONFIG_DIR"
  chmod 700 "$CONFIG_DIR"

  # Write JSON config
  printf "%s→%s Writing configuration to %s...\n" "$KD_CYAN" "$KD_RESET" \
    "$CONFIG_FILE"

  cat > "$CONFIG_FILE" <<EOF
{
  "doppler": {
    "project": "$doppler_project",
    "env": "$doppler_env",
    "ssh_key_public": "$ssh_key_public",
    "ssh_key_private": "$ssh_key_private"
  },
  "vm": {
    "hostname": "$vm_hostname",
    "port": $vm_port,
    "username": "$vm_username"
  }
}
EOF

  chmod 600 "$CONFIG_FILE"

  printf "%s✓%s Configuration saved successfully!\n\n" "$KD_GREEN" "$KD_RESET"

  # Display next steps
  printf "%s%sNext Steps:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  printf "  1. Run the bootstrap script for your platform:\n"
  printf "     Termux: %sbash bootstrap/termux.sh%s\n" "$KD_CYAN" "$KD_RESET"
  printf "     VM: %sbash bootstrap/vm.sh%s (coming soon)\n" \
    "$KD_CYAN" "$KD_RESET"
  printf "\n"
}

main

