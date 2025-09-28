_needs_proot_distro() {
    ! command -v proot-distro >/dev/null 2>&1
}

_proot_distro() {
    kd_step_start "proot-distro" "Installing proot-distro"

    if ! _needs_proot_distro; then
        kd_step_skip "proot-distro already installed"
        return 0
    fi

    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            kd_log "Installing proot-distro"
            pkg install -y proot-distro
            ;;
        ubuntu|macos|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_proot_distro
