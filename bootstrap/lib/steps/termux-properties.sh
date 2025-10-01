# Configure Termux properties
configure_termux_properties() {
  kd_step_start "termux-properties" "Configuring Termux properties"

  local termux_config_dir="$HOME/.config/termux"
  local termux_properties="$termux_config_dir/termux.properties"

  # Create config directory if it doesn't exist
  if [ ! -d "$termux_config_dir" ]; then
    kd_log "Creating ~/.config/termux directory"
    mkdir -p "$termux_config_dir"
  fi

  # Check if extra-keys already configured
  if [ -f "$termux_properties" ] && grep -q "^extra-keys = " "$termux_properties"
  then
    kd_step_skip "extra-keys already configured"
    return 0
  fi

  kd_log "Configuring extra-keys"

  # Append extra-keys configuration
  cat >> "$termux_properties" <<'EOF'

###############
# Extra keys
###############

### Two rows with more keys
extra-keys = [['ESC','/','-','|','PGDN','UP','PGUP'], \
              ['TAB','CTRL','ALT','SHIFT','LEFT','DOWN','RIGHT']]
EOF

  if command -v termux-reload-settings >/dev/null 2>&1; then
    kd_log "Reloading Termux settings"
    termux-reload-settings 2>/dev/null || true
  fi

  kd_step_end
}
