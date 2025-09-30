#!/bin/sh
#
# Interactive configuration script for k bootstrap system
# Creates ~/.config/kyldvs/k/configure.json with user settings
#

set -e

# POSIX compliant color definitions
if [ -z "$KD_NO_COLOR" ]; then
  KD_CYAN=$(printf '\033[36m')
  KD_GREEN=$(printf '\033[32m')
  KD_YELLOW=$(printf '\033[33m')
  KD_RED=$(printf '\033[31m')
  KD_RESET=$(printf '\033[0m')
  KD_BOLD=$(printf '\033[1m')
else
  KD_CYAN=''
  KD_GREEN=''
  KD_YELLOW=''
  KD_RED=''
  KD_RESET=''
  KD_BOLD=''
fi

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

# Main configuration flow
main() {
  printf "\n%s%sConfiguration Setup%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "This script will configure your k bootstrap system.\n\n"

  # VM Configuration
  printf "%s%sVM Configuration:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  prompt "VM hostname/IP" "" vm_hostname
  prompt "VM SSH port" "22" vm_port
  prompt "VM username" "kad" vm_username

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
