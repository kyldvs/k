_needs_fake_sudo() {
    # Check if bin/sudo already exists
    [ ! -f "$HOME/bin/sudo" ]
}

_fake_sudo() {
    # Create fake sudo command for Termux in home/bin
    kd_step_start "fake-sudo" "Setting up for Termux"

    if ! _needs_fake_sudo; then
        kd_step_skip "fake-sudo" "$HOME/bin/sudo already exists"
        return 0
    fi

    # Create bin directory if it doesn't exist
    kd_log "Creating $HOME/bin directory"
    mkdir -p "$HOME/bin"

    # Create fake-sudo directory and script
    kd_log "Creating fake-sudo script"
    mkdir -p "$HOME/fake-sudo"
    cat > "$HOME/fake-sudo/sudo" << 'EOF'
#!/bin/bash
# Fake sudo for Termux - just execute the command directly
exec "$@"
EOF

    # Make it executable
    chmod +x "$HOME/fake-sudo/sudo"

    # Create symlink in bin
    ln -sf "$HOME/fake-sudo/sudo" "$HOME/bin/sudo"

    kd_step_end "installed successfully"
}

_fake_sudo
