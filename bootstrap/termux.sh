#!/bin/sh
#
# Config-driven bootstrap script for Termux environment
# Reads configuration from ~/.config/kyldvs/k/configure.json
#

set -e

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

# Configuration
CONFIG_FILE="$HOME/.config/kyldvs/k/configure.json"

# Check if config exists
check_config() {
  kd_step_start "config" "Loading configuration"

  if [ ! -f "$CONFIG_FILE" ]; then
    kd_error "Configuration file not found: $CONFIG_FILE"
    kd_error "Please run bootstrap/configure.sh first"
    exit 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    kd_log "jq not installed, will install shortly"
  fi

  kd_step_end
}

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

# Install Termux packages
install_packages() {
  kd_step_start "packages" "Installing essential packages"

  # Check which packages are already installed
  local packages_needed=""

  if ! command -v ssh >/dev/null 2>&1; then
    packages_needed="$packages_needed openssh"
  fi

  if ! command -v mosh >/dev/null 2>&1; then
    packages_needed="$packages_needed mosh"
  fi

  if ! command -v jq >/dev/null 2>&1; then
    packages_needed="$packages_needed jq"
  fi

  if [ -z "$packages_needed" ]; then
    kd_step_skip "all packages already installed"
    return 0
  fi

  kd_log "Installing:$packages_needed"
  pkg install -y $packages_needed

  kd_step_end
}

# Install proot-distro for Doppler CLI
install_proot_distro() {
  kd_step_start "proot-distro" "Setting up proot-distro"

  if ! command -v proot-distro >/dev/null 2>&1; then
    kd_log "Installing proot-distro"
    pkg install -y proot-distro
  else
    kd_log "proot-distro already installed"
  fi

  kd_step_end
}

# Install Alpine Linux via proot-distro
install_alpine() {
  kd_step_start "alpine" "Installing Alpine Linux"

  if [ -d "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/alpine" ]; then
    kd_step_skip "Alpine already installed"
    return 0
  fi

  kd_log "Installing Alpine Linux (this may take a few minutes)"
  proot-distro install alpine

  kd_step_end
}

# Install Doppler CLI in Alpine
install_doppler_alpine() {
  kd_step_start "doppler-cli" "Installing Doppler CLI in Alpine"

  if proot-distro login alpine -- command -v doppler >/dev/null 2>&1; then
    kd_step_skip "Doppler already installed in Alpine"
    return 0
  fi

  kd_log "Installing Doppler CLI"
  proot-distro login alpine -- sh -c '
    wget -q -t3 "https://packages.doppler.com/public/cli/rsa.8004D9FF50437357.key" -O /etc/apk/keys/cli@doppler-8004D9FF50437357.rsa.pub
    echo "https://packages.doppler.com/public/cli/alpine/any-version/main" | tee -a /etc/apk/repositories
    apk add doppler
  '

  kd_step_end
}

# Create Doppler wrapper script
create_doppler_wrapper() {
  kd_step_start "doppler-wrapper" "Creating Doppler wrapper"

  if [ -f "$HOME/bin/doppler" ]; then
    kd_step_skip "wrapper already exists"
    return 0
  fi

  kd_log "Creating ~/bin directory"
  mkdir -p "$HOME/bin"

  kd_log "Creating wrapper script"
  cat > "$HOME/bin/doppler" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
# Run Doppler inside Alpine proot, in the current directory, forwarding args
set -e
proot-distro login alpine -- sh -lc '
  cd "$PWD"
  exec doppler "$@"
' doppler "$@"
EOF

  chmod +x "$HOME/bin/doppler"

  kd_step_end
}

# Check Doppler authentication
check_doppler_auth() {
  kd_step_start "doppler-auth" "Checking Doppler authentication"

  if ! "$HOME/bin/doppler" configure get token --plain --silent >/dev/null 2>&1
  then
    kd_log ""
    kd_error "Doppler is not authenticated"
    kd_error ""
    kd_error "Please run the following command to authenticate:"
    kd_error "  ~/bin/doppler login"
    kd_error ""
    kd_error "Then re-run this script"
    exit 1
  fi

  kd_log "Authenticated"
  kd_step_end
}

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

# Test SSH connection
test_ssh_connection() {
  kd_step_start "ssh-test" "Testing SSH connection to VM"

  kd_log "Attempting connection to vm..."
  if ssh -q -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
    vm exit 2>/dev/null; then
    kd_log "Connection successful!"
  else
    kd_log "Connection test failed (this is expected on first run)"
    kd_log "You may need to manually accept the host key on first connect"
  fi

  kd_step_end
}

# Display success message
show_next_steps() {
  printf "\n"
  printf "%s%s✓ Bootstrap Complete!%s\n" "$KD_BOLD" "$KD_GREEN" "$KD_RESET"
  printf "\n"
  printf "%s%sNext Steps:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  printf "  Connect to your VM using:\n"
  printf "    %sssh vm%s        - Standard SSH connection\n" "$KD_CYAN" \
    "$KD_RESET"
  printf "    %smosh vm%s       - Mosh connection (roaming)\n" "$KD_CYAN" \
    "$KD_RESET"
  printf "\n"
  printf "  Or use agent-wrapped versions:\n"
  printf "    %sssha vm%s       - SSH with automatic agent setup\n" \
    "$KD_CYAN" "$KD_RESET"
  printf "    %smosha vm%s      - Mosh with automatic agent setup\n" \
    "$KD_CYAN" "$KD_RESET"
  printf "\n"
}

# Main execution
main() {
  check_config
  configure_termux_properties
  configure_termux_colors
  configure_termux_font
  install_packages
  install_proot_distro
  install_alpine
  install_doppler_alpine
  create_doppler_wrapper
  check_doppler_auth
  retrieve_ssh_keys
  generate_ssh_config
  test_ssh_connection
  show_next_steps
}

main
