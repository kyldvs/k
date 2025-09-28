_needs_nerdfetch() {
    ! command -v nerdfetch >/dev/null 2>&1
}

_nerdfetch_termux() {
    kd_log "Installing nerdfetch for Termux"
    curl -fsSL https://raw.githubusercontent.com/ThatOneCalculator/NerdFetch/main/nerdfetch -o /data/data/com.termux/files/usr/bin/nerdfetch
    chmod a+x /data/data/com.termux/files/usr/bin/nerdfetch
}

_nerdfetch_ubuntu() {
    return 0
}

_nerdfetch_macos() {
    return 0
}

_nerdfetch() {
    kd_step_start "nerdfetch" "Installing nerdfetch"

    if ! _needs_nerdfetch; then
        kd_step_skip "nerdfetch already installed"
        return 0
    fi

    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            _nerdfetch_termux
            ;;
        ubuntu|macos|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_nerdfetch
