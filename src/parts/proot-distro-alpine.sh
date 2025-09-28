_needs_proot_distro_alpine() {
    ! proot-distro list --installed 2>/dev/null | grep -q "alpine"
}

_proot_distro_alpine() {
    kd_step_start "proot-distro-alpine" "Installing Alpine distro"

    if ! _needs_proot_distro_alpine; then
        kd_step_skip "Alpine already installed"
        return 0
    fi

    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            kd_log "Installing Alpine Linux via proot-distro"
            proot-distro install alpine
            ;;
        ubuntu|macos|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_proot_distro_alpine
