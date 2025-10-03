# Setup SSH keys
setup_ssh() {
  kd_step_start "ssh" "Setting up SSH keys"

  # Read config
  local username
  username=$(jq -r '.username' "$VMROOT_CONFIG_FILE")
  local homedir
  homedir=$(jq -r '.homedir' "$VMROOT_CONFIG_FILE")
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
