# Generate SSH config
generate_ssh_config() {
  kd_step_start "ssh-config" "Generating SSH configuration"

  vm_hostname=$(jq -r '.vm.hostname' "$CONFIG_FILE")
  vm_port=$(jq -r '.vm.port' "$CONFIG_FILE")
  vm_username=$(jq -r '.vm.username' "$CONFIG_FILE")

  # Check if config already has vm entry
  if [ -f "$HOME/.ssh/config" ] && grep -q "^Host vm$" "$HOME/.ssh/config"
  then
    kd_step_skip "SSH config already has vm entry"
    return 0
  fi

  kd_log "Adding VM entry to ~/.ssh/config"

  # Create config if it doesn't exist
  touch "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"

  # Append VM config
  cat >> "$HOME/.ssh/config" <<EOF

# k bootstrap - VM connection
Host vm
  HostName $vm_hostname
  Port $vm_port
  User $vm_username
  IdentityFile ~/.ssh/gh_vm
  ServerAliveInterval 60
  ServerAliveCountMax 3
EOF

  kd_step_end
}
