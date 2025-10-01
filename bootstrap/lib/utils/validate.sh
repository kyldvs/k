# Validation function
validate_config() {
  local vm_hostname="$1"
  local vm_port="$2"
  local vm_username="$3"
  local doppler_project="$4"
  local doppler_env="$5"

  if [ -z "$vm_hostname" ]; then
    printf "%s[ERROR]%s VM hostname is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$vm_port" ]; then
    printf "%s[ERROR]%s VM port is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$vm_username" ]; then
    printf "%s[ERROR]%s VM username is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$doppler_project" ]; then
    printf "%s[ERROR]%s Doppler project is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$doppler_env" ]; then
    printf "%s[ERROR]%s Doppler environment is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  return 0
}
