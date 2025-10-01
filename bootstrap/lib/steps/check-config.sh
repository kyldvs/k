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
