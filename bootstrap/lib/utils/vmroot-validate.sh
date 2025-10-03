# Validation function for vmroot configuration
validate_vmroot_config() {
  local username="$1"
  local homedir="$2"

  if [ -z "$username" ]; then
    printf "%s[ERROR]%s Username is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  if [ -z "$homedir" ]; then
    printf "%s[ERROR]%s Home directory is required\n" "$KD_RED" "$KD_RESET" >&2
    return 1
  fi

  # Validate home directory parent is writable
  local parent_dir
  parent_dir=$(dirname "$homedir")
  if [ ! -d "$parent_dir" ] && [ ! -w "$(dirname "$parent_dir")" ]; then
    printf "%s[ERROR]%s Home directory parent is not writable: %s\n" \
      "$KD_RED" "$KD_RESET" "$parent_dir" >&2
    return 1
  fi

  return 0
}
