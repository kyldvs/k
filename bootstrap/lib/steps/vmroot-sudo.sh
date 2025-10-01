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
