_needs_profile_init() {
    ! grep -q '. ~/.config/k/init.sh' ~/.profile 2>/dev/null
}

_init_profile() {
    kd_step_start "init-profile" "Setting up .profile"

    if ! _needs_profile_init; then
        kd_step_skip "~/.config/k/init.sh already sourced in profile"
        return 0
    fi

    # Create .profile if it doesn't exist
    [ ! -f ~/.profile ] && echo "# POSIX compliant profile with common setup" > ~/.profile

    kd_log "Adding ~/.config/k/init.sh source line to ~/.profile"
    echo "" >> ~/.profile
    echo "# Source shell customizations from ~/.config/k/" >> ~/.profile
    echo ". ~/.config/k/init.sh" >> ~/.profile

    kd_step_end
}

_init_profile
