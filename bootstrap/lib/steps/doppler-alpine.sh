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
