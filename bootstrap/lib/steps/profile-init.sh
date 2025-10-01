# Initialize .profile with minimal config
init_profile() {
  kd_step_start "profile-init" "Initializing shell profile"

  # Create .profile if it doesn't exist
  if [ ! -f "$HOME/.profile" ]; then
    kd_log "Creating ~/.profile"
    touch "$HOME/.profile"
    chmod 644 "$HOME/.profile"
  fi

  # Create config directory if needed
  if [ ! -d "$HOME/.config/kyldvs/k" ]; then
    kd_log "Creating ~/.config/kyldvs/k directory"
    mkdir -p "$HOME/.config/kyldvs/k"
    chmod 700 "$HOME/.config/kyldvs/k"
  fi

  # Helper function to add profile line idempotently
  kd_add_profile_line() {
    local config_name="$1"
    local config_content="$2"
    local source_line="$3"

    # Check if source line already exists (idempotency)
    if grep -qF "$source_line" "$HOME/.profile" 2>/dev/null; then
      kd_log "Skipping $config_name (already in profile)"
      return 0
    fi

    # Create config file
    kd_log "Adding $config_name to profile"
    printf "%s\n" "$config_content" > "$HOME/.config/kyldvs/k/$config_name.sh"
    chmod 644 "$HOME/.config/kyldvs/k/$config_name.sh"

    # Add source line to profile
    printf "\n%s\n" "$source_line" >> "$HOME/.profile"
  }

  # Add editor config
  kd_add_profile_line \
    "kd-editor" \
    "export EDITOR=nano" \
    "[ -f ~/.config/kyldvs/k/kd-editor.sh ] && . ~/.config/kyldvs/k/kd-editor.sh"

  # Create ~/bin directory if needed
  if [ ! -d "$HOME/bin" ]; then
    kd_log "Creating ~/bin directory"
    mkdir -p "$HOME/bin"
  fi

  # Add PATH config
  kd_add_profile_line \
    "kd-path" \
    "export PATH=\"\$HOME/bin:\$PATH\"" \
    "[ -f ~/.config/kyldvs/k/kd-path.sh ] && . ~/.config/kyldvs/k/kd-path.sh"

  kd_step_end
}
