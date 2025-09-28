_fake_sudo() {
    # Create fake sudo command for Termux in home/bin
    echo "Setting up fake sudo for Termux..."

    # Check if fake sudo is already installed
    if [ -f "$HOME/bin/sudo" ]; then
        echo "Fake sudo already installed, skipping"
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
