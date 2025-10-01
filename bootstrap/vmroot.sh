#!/bin/sh
#
# VM root bootstrap script
# Provisions non-root user with sudo access and SSH keys
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

# Step functions
kd_step_start() {
  local step_name="$1"
  shift
  local message="$*"

  KD_CURRENT_STEP="$step_name"

  printf "%s→%s %s%s%s" "$KD_CYAN" "$KD_RESET" "$KD_CYAN" "$step_name" \
    "$KD_RESET"
  if [ -n "$message" ]; then
    printf ": %s" "$message"
  fi
  printf "\n"

  KD_INDENT=$((KD_INDENT + 1))
}

kd_step_end() {
  if [ $KD_INDENT -gt 0 ]; then
    KD_INDENT=$((KD_INDENT - 1))
  fi

  if [ -n "$KD_CURRENT_STEP" ]; then
    printf "%s✓%s %sdone%s\n" "$KD_GREEN" "$KD_RESET" "$KD_GREEN" \
      "$KD_RESET"
    KD_CURRENT_STEP=""
  fi
}

kd_step_skip() {
  local reason="$*"

  if [ $KD_INDENT -gt 0 ]; then
    KD_INDENT=$((KD_INDENT - 1))
  fi

  printf "  %s○%s %sskipping%s" "$KD_GRAY" "$KD_RESET" "$KD_GRAY" \
    "$KD_RESET"
  if [ -n "$reason" ]; then
    printf " %s(%s%s%s)%s" "$KD_GRAY" "$KD_RESET" "$reason" "$KD_GRAY" \
      "$KD_RESET"
  fi
  printf "\n"
  KD_CURRENT_STEP=""
}

# Configuration file path for vmroot
VMROOT_CONFIG_DIR="/root/.config/kyldvs/k"
VMROOT_CONFIG_FILE="$VMROOT_CONFIG_DIR/vmroot-configure.json"

# Check if vmroot config exists
check_vmroot_config() {
  kd_step_start "config" "Loading configuration"

  if [ ! -f "$VMROOT_CONFIG_FILE" ]; then
    kd_error "Configuration file not found: $VMROOT_CONFIG_FILE"
    kd_error "Please run bootstrap/vmroot-configure.sh first"
    exit 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    kd_error "jq is required but not installed"
    exit 1
  fi

  kd_step_end
}

# Create user account
create_user() {
  kd_step_start "user" "Creating user account"

  # Read config
  local username=$(jq -r '.username' "$VMROOT_CONFIG_FILE")
  local homedir=$(jq -r '.homedir' "$VMROOT_CONFIG_FILE")

  # Check if user already exists (idempotency)
  if id "$username" >/dev/null 2>&1; then
    kd_log "User $username already exists, skipping user creation"
    kd_step_skip "user already exists"
    return 0
  fi

  # Create parent directory if needed
  local parent_dir=$(dirname "$homedir")
  if [ ! -d "$parent_dir" ]; then
    kd_log "Creating parent directory: $parent_dir"
    mkdir -p "$parent_dir"
  fi

  # Create user with specified home directory
  kd_log "Creating user: $username (home: $homedir)"
  useradd --create-home --home-dir "$homedir" --shell /bin/bash --password '!' "$username"

  kd_step_end
}

# Configure passwordless sudo
configure_sudo() {
  kd_step_start "sudo" "Configuring passwordless sudo"

  # Read config
  local username=$(jq -r '.username' "$VMROOT_CONFIG_FILE")
  local sudoers_file="/etc/sudoers.d/vmroot-$username"

  # Check if sudoers file already exists (idempotency)
  if [ -f "$sudoers_file" ]; then
    kd_log "Sudoers file already exists, skipping"
    kd_step_skip "sudoers already configured"
    return 0
  fi

  # Create sudoers file
  kd_log "Creating sudoers file: $sudoers_file"
  echo "$username ALL=(ALL) NOPASSWD:ALL" > "$sudoers_file"

  # Set strict permissions
  chmod 440 "$sudoers_file"

  # Validate syntax
  if ! visudo -cf "$sudoers_file" >/dev/null 2>&1; then
    kd_error "Invalid sudoers syntax, removing file"
    rm -f "$sudoers_file"
    exit 1
  fi

  kd_step_end
}

# Setup SSH keys
setup_ssh() {
  kd_step_start "ssh" "Setting up SSH keys"

  # Read config
  local username=$(jq -r '.username' "$VMROOT_CONFIG_FILE")
  local homedir=$(jq -r '.homedir' "$VMROOT_CONFIG_FILE")
  local ssh_dir="$homedir/.ssh"
  local auth_keys="$ssh_dir/authorized_keys"

  # Check if root has authorized_keys
  if [ ! -f /root/.ssh/authorized_keys ]; then
    kd_log "No authorized_keys found for root, skipping SSH setup"
    kd_step_skip "no root authorized_keys"
    return 0
  fi

  # Check if SSH already configured (idempotency)
  if [ -f "$auth_keys" ]; then
    kd_log "SSH keys already configured, skipping"
    kd_step_skip "ssh already configured"
    return 0
  fi

  # Create .ssh directory
  kd_log "Creating .ssh directory: $ssh_dir"
  mkdir -p "$ssh_dir"
  chmod 700 "$ssh_dir"

  # Copy authorized_keys
  kd_log "Copying authorized_keys from root"
  cp /root/.ssh/authorized_keys "$auth_keys"
  chmod 600 "$auth_keys"

  # Set ownership
  kd_log "Setting ownership to $username"
  chown -R "$username:$username" "$ssh_dir"

  kd_step_end
}

# Main flow for vmroot bootstrap
main() {
  printf "\n%s%sVM Root Bootstrap%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "Provisioning non-root user with sudo and SSH access\n\n"

  # Check config exists
  check_vmroot_config

  # Execute provisioning steps
  create_user
  configure_sudo
  setup_ssh

  # Success message
  local username=$(jq -r '.username' "$VMROOT_CONFIG_FILE")
  printf "\n%s✓ Bootstrap complete!%s\n" "$KD_GREEN" "$KD_RESET"
  printf "\nUser %s%s%s is now configured with:\n" "$KD_CYAN" "$username" "$KD_RESET"
  printf "  • Home directory\n"
  printf "  • Passwordless sudo access\n"
  printf "  • SSH keys from root\n"
  printf "\n"
}

main

