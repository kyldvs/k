#!/bin/bash
#
# Generated bootstrap script
# Do not edit directly - edit parts and rebuild
#

#--- fake-sudo ---#

_needs_fake_sudo() {
    # Check if bin/sudo already exists
    [ ! -f "$HOME/bin/sudo" ]
}

_fake_sudo() {
    # Create fake sudo command for Termux in home/bin
    echo "Setting up fake sudo for Termux..."

    if ! _needs_fake_sudo; then
        echo "$HOME/bin/sudo exists, skipping"
        return 0
    fi

    # Create bin directory if it doesn't exist
    mkdir -p "$HOME/bin"

    # Create fake-sudo directory and script
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

    echo "Fake sudo installed successfully"
}

_fake_sudo

#--- /fake-sudo ---#

