_needs_mosh() {
    ! command -v mosh >/dev/null 2>&1
}

_mosh_termux() {
    kd_log "Installing mosh for Termux"
    pkg install -y mosh
}

_mosh_ubuntu() {
    kd_log "Installing mosh for Ubuntu"
    if command -v sudo >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y mosh
    else
        apt-get update && apt-get install -y mosh
    fi
}


_mosh() {
    kd_step_start "mosh" "Installing mosh"

    if ! _needs_mosh; then
        kd_step_skip "mosh already installed"
        return 0
    fi

    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            _mosh_termux
            ;;
        ubuntu)
            _mosh_ubuntu
            ;;
        *)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_mosh
