_needs_doppler() {
    [ ! -f "$HOME/bin/doppler" ]
}

_doppler() {
    kd_step_start "doppler" "Setting up doppler wrapper"

    if ! _needs_doppler; then
        kd_step_skip "~/bin/doppler already exists"
        return 0
    fi

    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            kd_log "Creating ~/bin directory"
            mkdir -p "$HOME/bin"

            kd_log "Creating doppler wrapper script"
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
            ;;
        ubuntu|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_doppler
