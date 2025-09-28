_needs_profile_init() {
    # Check if .profile already exists
    [ ! -f "$HOME/.profile" ]
}

_init_profile() {
    echo "Setting up .profile..."

    if ! _needs_profile_init; then
        echo "$HOME/.profile exists, skipping"
        return 0
    fi

    cat > "$HOME/.profile" << 'EOF'
# POSIX compliant profile with common setup
EOF

    echo ".profile created successfully"
}

_init_profile
