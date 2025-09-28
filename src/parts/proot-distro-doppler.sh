_needs_proot_distro_doppler() {
    ! proot-distro login alpine -- command -v doppler >/dev/null 2>&1
}

_proot_distro_doppler() {
    kd_step_start "proot-distro-doppler" "Installing doppler in Alpine"

    if ! _needs_proot_distro_doppler; then
        kd_step_skip "doppler already installed in Alpine"
        return 0
    fi

    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            kd_log "Installing dummy doppler in Alpine"
            proot-distro login alpine -- sh -c '
                echo "#!/bin/sh" > /usr/local/bin/doppler
                echo "echo \"hello doppler\"" >> /usr/local/bin/doppler
                chmod +x /usr/local/bin/doppler
            '
            ;;
        ubuntu|macos|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_proot_distro_doppler
