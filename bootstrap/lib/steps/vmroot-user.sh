# Create user account
create_user() {
  kd_step_start "user" "Creating user account"

  # Read config
  local username
  username=$(jq -r '.username' "$VMROOT_CONFIG_FILE")
  local homedir
  homedir=$(jq -r '.homedir' "$VMROOT_CONFIG_FILE")

  # Check if user already exists (idempotency)
  if id "$username" >/dev/null 2>&1; then
    kd_log "User $username already exists, skipping user creation"
    kd_step_skip "user already exists"
    return 0
  fi

  # Create parent directory if needed
  local parent_dir
  parent_dir=$(dirname "$homedir")
  if [ ! -d "$parent_dir" ]; then
    kd_log "Creating parent directory: $parent_dir"
    mkdir -p "$parent_dir"
  fi

  # Create user with specified home directory
  kd_log "Creating user: $username (home: $homedir)"
  useradd --create-home --home-dir "$homedir" --shell /bin/bash --password '!' "$username"

  kd_step_end
}
