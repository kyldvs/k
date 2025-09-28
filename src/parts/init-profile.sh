_needs_profile_init() {
    # Check if .profile already exists
    [ ! -f "$HOME/.profile" ]
}

_init_profile() {
    if ! _needs_profile_init; then
        kd_step_skip "init-profile" "$HOME/.profile already exists"
        return 0
    fi

    kd_step_start "init-profile" "Setting up .profile"

    cat > "$HOME/.profile" << 'EOF'
# POSIX compliant profile with common setup
EOF

    kd_step_end "created successfully"
}

_init_profile
