_needs_proot_distro_doppler() {
    ! proot-distro login alpine -- command -v doppler >/dev/null 2>&1
}

_proot_distro_doppler_termux() {
    kd_log "Installing Doppler CLI in Alpine"
    proot-distro login alpine -- sh -c '
        wget -q -t3 "https://packages.doppler.com/public/cli/rsa.8004D9FF50437357.key" -O /etc/apk/keys/cli@doppler-8004D9FF50437357.rsa.pub
        echo "https://packages.doppler.com/public/cli/alpine/any-version/main" | tee -a /etc/apk/repositories
        apk add doppler
    '
}

_proot_distro_doppler() {
    kd_step_start "proot-distro-doppler" "Installing doppler in Alpine"

    if ! _needs_proot_distro_doppler; then
        kd_step_skip "doppler already installed in Alpine"
        return 0
    fi

    kd_platform_dispatch "proot-distro-doppler"

    kd_step_end
}

_proot_distro_doppler
