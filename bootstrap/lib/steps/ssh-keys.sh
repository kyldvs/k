# Retrieve SSH keys from Doppler
retrieve_ssh_keys() {
  kd_step_start "ssh-keys" "Retrieving SSH keys from Doppler"

  # Parse config
  doppler_project=$(jq -r '.doppler.project' "$CONFIG_FILE")
  doppler_env=$(jq -r '.doppler.env' "$CONFIG_FILE")
  ssh_key_public=$(jq -r '.doppler.ssh_key_public' "$CONFIG_FILE")
  ssh_key_private=$(jq -r '.doppler.ssh_key_private' "$CONFIG_FILE")

  # Create .ssh directory
  if [ ! -d "$HOME/.ssh" ]; then
    kd_log "Creating ~/.ssh directory"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
  fi

  # Check if keys already exist
  if [ -f "$HOME/.ssh/gh_vm" ] && [ -f "$HOME/.ssh/gh_vm.pub" ]; then
    kd_step_skip "SSH keys already exist"
    return 0
  fi

  kd_log "Fetching keys from Doppler ($doppler_project/$doppler_env)"

  # Fetch private key
  kd_log "Fetching private key: $ssh_key_private"
  "$HOME/bin/doppler" secrets get "$ssh_key_private" --plain \
    --project "$doppler_project" --config "$doppler_env" \
    > "$HOME/.ssh/gh_vm"
  chmod 600 "$HOME/.ssh/gh_vm"

  # Fetch public key
  kd_log "Fetching public key: $ssh_key_public"
  "$HOME/bin/doppler" secrets get "$ssh_key_public" --plain \
    --project "$doppler_project" --config "$doppler_env" \
    > "$HOME/.ssh/gh_vm.pub"
  chmod 644 "$HOME/.ssh/gh_vm.pub"

  kd_step_end
}
