# Check if vmroot config exists
check_vmroot_config() {
  kd_step_start "config" "Loading configuration"

  if [ ! -f "$VMROOT_CONFIG_FILE" ]; then
    kd_error "Configuration file not found: $VMROOT_CONFIG_FILE"
    kd_error "Please run bootstrap/vmroot-configure.sh first"
    exit 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    kd_error "jq is required but not installed"
    exit 1
  fi

  kd_step_end
}
