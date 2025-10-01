# Test SSH connection
test_ssh_connection() {
  kd_step_start "ssh-test" "Testing SSH connection to VM"

  kd_log "Attempting connection to vm..."
  if ssh -q -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
    vm exit 2>/dev/null; then
    kd_log "Connection successful!"
  else
    kd_log "Connection test failed (this is expected on first run)"
    kd_log "You may need to manually accept the host key on first connect"
  fi

  kd_step_end
}
