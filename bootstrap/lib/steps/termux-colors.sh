# Configure Termux colors
configure_termux_colors() {
  kd_step_start "termux-colors" "Configuring Termux colors"

  local termux_dir="$HOME/.termux"
  local colors_file="$termux_dir/colors.properties"

  # Create directory if it doesn't exist
  if [ ! -d "$termux_dir" ]; then
    kd_log "Creating ~/.termux directory"
    mkdir -p "$termux_dir"
  fi

  # Check if colors already configured
  if [ -f "$colors_file" ]; then
    kd_step_skip "colors already configured"
    return 0
  fi

  kd_log "Configuring base16-monokai-256 color scheme"

  # Write colors configuration
  cat > "$colors_file" <<'EOF'
# https://github.com/chriskempson/base16-xresources/blob/master/xresources/base16-monokai-256.Xresources
foreground=   #f8f8f2
background=   #272822
cursor=  #f8f8f2

color0=       #272822
color1=       #f92672
color2=       #a6e22e
color3=       #f4bf75
color4=       #66d9ef
color5=       #ae81ff
color6=       #a1efe4
color7=       #f8f8f2

color8=       #75715e
color9=       #f92672
color10=      #a6e22e
color11=      #f4bf75
color12=      #66d9ef
color13=      #ae81ff
color14=      #a1efe4
color15=      #f9f8f5

color16=      #fd971f
color17=      #cc6633
color18=      #383830
color19=      #49483e
color20=      #a59f85
color21=      #f5f4f1
EOF

  if command -v termux-reload-settings >/dev/null 2>&1; then
    kd_log "Reloading Termux settings"
    termux-reload-settings 2>/dev/null || true
  fi

  kd_step_end
}
