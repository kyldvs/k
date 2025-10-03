# Check Doppler authentication
check_doppler_auth() {
  kd_step_start "doppler-auth" "Checking Doppler authentication"

  if ! kd_retry "$HOME/bin/doppler" me >/dev/null 2>&1; then
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
