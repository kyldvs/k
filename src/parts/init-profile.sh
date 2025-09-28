_needs_profile_init() {
    # Check if .profile already exists
    [ ! -f "$HOME/.profile" ]
}

_init_profile() {
    echo "Setting up .profile..."

    if ! _needs_profile_init; then
        printf "Y/n to overwrite ~/.profile? "
        read -r response
        case "$response" in
            [Yy]|"") ;;
            *) echo "Skipping .profile creation"; return 0 ;;
        esac
    fi

    cat > "$HOME/.profile" << 'EOF'
# Generated profile for shell configuration

export EDITOR=nano
EOF

    echo ".profile created successfully"
}

_init_profile
