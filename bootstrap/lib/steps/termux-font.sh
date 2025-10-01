# Configure Termux font
configure_termux_font() {
  kd_step_start "termux-font" "Configuring Termux font"

  local termux_dir="$HOME/.termux"
  local font_file="$termux_dir/font.ttf"

  # Create directory if it doesn't exist
  if [ ! -d "$termux_dir" ]; then
    kd_log "Creating ~/.termux directory"
    mkdir -p "$termux_dir"
  fi

  # Check if font already installed
  if [ -f "$font_file" ]; then
    kd_step_skip "font already installed"
    return 0
  fi

  kd_log "Downloading JetBrains Mono Nerd Font"

  # Download font from GitHub
  local font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$font_url" -o "$font_file"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$font_url" -O "$font_file"
  else
    kd_error "Neither curl nor wget available"
    exit 1
  fi

  if command -v termux-reload-settings >/dev/null 2>&1; then
    kd_log "Reloading Termux settings"
    termux-reload-settings 2>/dev/null || true
  fi

  kd_step_end
}
