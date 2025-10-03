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
  # shellcheck disable=SC2086  # Intentional word splitting for multiple packages
  kd_retry pkg install -y $packages_needed

  kd_step_end
}
