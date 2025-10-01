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
