# Install proot-distro for Doppler CLI
install_proot_distro() {
  kd_step_start "proot-distro" "Setting up proot-distro"

  if command -v proot-distro >/dev/null 2>&1; then
    kd_step_skip "proot-distro already installed"
    return 0
  fi

  kd_log "Installing proot-distro"
  pkg install -y proot-distro

  kd_step_end
}
