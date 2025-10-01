# Create Doppler wrapper script
create_doppler_wrapper() {
  kd_step_start "doppler-wrapper" "Creating Doppler wrapper"

  if [ -f "$HOME/bin/doppler" ]; then
    kd_step_skip "wrapper already exists"
    return 0
  fi

  kd_log "Creating ~/bin directory"
  mkdir -p "$HOME/bin"

  kd_log "Creating wrapper script"
  cat > "$HOME/bin/doppler" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
# Run Doppler inside Alpine proot, in the current directory, forwarding args
set -e
proot-distro login alpine -- sh -lc '
  cd "$PWD"
  exec doppler "$@"
' doppler "$@"
EOF

  chmod +x "$HOME/bin/doppler"

  kd_step_end
}
