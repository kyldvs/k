_needs_proot_distro() {
    ! command -v proot-distro >/dev/null 2>&1
}

_proot_distro_termux() {
    kd_log "Installing proot-distro"
    pkg install -y proot-distro
}

_proot_distro() {
    kd_step_start "proot-distro" "Installing proot-distro"

    if ! _needs_proot_distro; then
        kd_step_skip "proot-distro already installed"
        return 0
    fi

    kd_platform_dispatch "proot-distro"

    kd_step_end
}

_proot_distro
