#!/bin/bash
#
# Generated bootstrap script
# Do not edit directly - edit parts and rebuild
#

#--- util-functions ---#

_needs_util_functions() {
    # Always needed as utility functions
    true
}

_util_functions() {
    # POSIX compliant color definitions - always enable unless KD_NO_COLOR is set
    if [ -z "$KD_NO_COLOR" ]; then
        # Use printf to generate actual escape characters
        KD_RED=$(printf '\033[31m')
        KD_GREEN=$(printf '\033[32m')
        KD_YELLOW=$(printf '\033[33m')
        KD_BLUE=$(printf '\033[34m')
        KD_CYAN=$(printf '\033[36m')
        KD_GRAY=$(printf '\033[90m')
        KD_WHITE=$(printf '\033[97m')
        KD_RESET=$(printf '\033[0m')
        KD_BOLD=$(printf '\033[1m')
    else
        KD_RED=''
        KD_GREEN=''
        KD_YELLOW=''
        KD_BLUE=''
        KD_CYAN=''
        KD_GRAY=''
        KD_WHITE=''
        KD_RESET=''
        KD_BOLD=''
    fi

    # Indentation tracking
    KD_INDENT=0

    # Get current indentation string
    _kd_indent() {
        i=0
        while [ $i -lt $KD_INDENT ]; do
            printf "  "
            i=$((i + 1))
        done
    }


    # Log functions
    kd_log() {
        local msg="$*"
        printf "%s%s\n" "$(_kd_indent)" "$msg"
    }

    kd_info() {
        local msg="$*"
        printf "%s[INFO]%s %s\n" "$KD_BLUE" "$KD_RESET" "$msg"
    }

    kd_warn() {
        local msg="$*"
        printf "%s[WARN]%s %s\n" "$KD_YELLOW" "$KD_RESET" "$msg"
    }

    kd_error() {
        local msg="$*"
        printf "%s[ERROR]%s %s\n" "$KD_RED" "$KD_RESET" "$msg" >&2
    }

    # Platform detection functions
    kd_is_termux() {
        # Multiple checks for robust Termux detection
        [ -d "/data/data/com.termux" ] || \
        [ -n "${PREFIX:-}" ] && [ "$PREFIX" = "/data/data/com.termux/files/usr" ] || \
        [ -f "/system/bin/app_process" ]
    }

    kd_is_ubuntu() {
        [ -f /etc/os-release ] && grep -q "Ubuntu" /etc/os-release
    }


    kd_get_platform() {
        if kd_is_termux; then
            echo "termux"
        elif kd_is_ubuntu; then
            echo "ubuntu"
        else
            echo "unknown"
        fi
    }

    # Cross-environment pattern functions
    _for_termux() {
        if kd_is_termux; then
            "$@"
        fi
    }

    _for_ubuntu() {
        if kd_is_ubuntu; then
            "$@"
        fi
    }


    # Step functions
    KD_CURRENT_STEP=""

    kd_step_start() {
        local step_name="$1"
        shift
        local message="$*"

        KD_CURRENT_STEP="$step_name"

        printf "%s→%s %s%s%s" "$KD_CYAN" "$KD_RESET" "$KD_CYAN" "$step_name" "$KD_RESET"
        if [ -n "$message" ]; then
            printf ": %s" "$message"
        fi
        printf "\n"

        KD_INDENT=$((KD_INDENT + 1))
    }

    kd_step_end() {
        if [ $KD_INDENT -gt 0 ]; then
            KD_INDENT=$((KD_INDENT - 1))
        fi

        if [ -n "$KD_CURRENT_STEP" ]; then
            printf "%s✓%s %sdone%s\n" "$KD_GREEN" "$KD_RESET" "$KD_GREEN" "$KD_RESET"
            KD_CURRENT_STEP=""
        fi
    }

    kd_step_skip() {
        local reason="$*"

        if [ $KD_INDENT -gt 0 ]; then
            KD_INDENT=$((KD_INDENT - 1))
        fi

        printf "  %s○%s %sskipping%s" "$KD_GRAY" "$KD_RESET" "$KD_GRAY" "$KD_RESET"
        if [ -n "$reason" ]; then
            printf " %s(%s%s%s)%s" "$KD_GRAY" "$KD_RESET" "$reason" "$KD_GRAY" "$KD_RESET"
        fi
        printf "\n"
        KD_CURRENT_STEP=""
    }
}

_util_functions

#--- /util-functions ---#


#--- fake-sudo ---#

_needs_fake_sudo() {
    # Check if bin/sudo already exists
    [ ! -f "$HOME/bin/sudo" ]
}

_fake_sudo() {
    # Create fake sudo command for Termux in home/bin
    kd_step_start "fake-sudo" "Setting up for Termux"

    if ! _needs_fake_sudo; then
        kd_step_skip "~/bin/sudo already exists"
        return 0
    fi

    # Create bin directory if it doesn't exist
    kd_log "Creating ~/bin directory"
    mkdir -p "$HOME/bin"

    # Create fake-sudo directory and script
    kd_log "Creating fake-sudo script"
    mkdir -p "$HOME/fake-sudo"
    cat > "$HOME/fake-sudo/sudo" << 'EOF'
#!/bin/bash
# Fake sudo for Termux - just execute the command directly
exec "$@"
EOF

    # Make it executable
    chmod +x "$HOME/fake-sudo/sudo"

    # Create symlink in bin
    ln -sf "$HOME/fake-sudo/sudo" "$HOME/bin/sudo"

    kd_step_end
}

_fake_sudo

#--- /fake-sudo ---#


#--- init-profile ---#

_needs_profile_init() {
    # Check if .profile already exists
    [ ! -f "$HOME/.profile" ]
}

_init_profile() {
    kd_step_start "init-profile" "Setting up .profile"

    if ! _needs_profile_init; then
        kd_step_skip "~/.profile already exists"
        return 0
    fi

    cat > "$HOME/.profile" << 'EOF'
# POSIX compliant profile with common setup
EOF

    kd_step_end
}

_init_profile

#--- /init-profile ---#


#--- nerdfetch ---#

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
        ubuntu|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_nerdfetch

#--- /nerdfetch ---#


#--- mosh ---#

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

#--- /mosh ---#


#--- proot-distro ---#

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
        ubuntu|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_proot_distro

#--- /proot-distro ---#


#--- proot-distro-alpine ---#

_needs_proot_distro_alpine() {
    [ ! -d "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/alpine" ]
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
        ubuntu|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_proot_distro_alpine

#--- /proot-distro-alpine ---#


#--- proot-distro-doppler ---#

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
            kd_log "Installing Doppler CLI in Alpine"
            proot-distro login alpine -- sh -c '
                wget -q -t3 "https://packages.doppler.com/public/cli/rsa.8004D9FF50437357.key" -O /etc/apk/keys/cli@doppler-8004D9FF50437357.rsa.pub
                echo "https://packages.doppler.com/public/cli/alpine/any-version/main" | tee -a /etc/apk/repositories
                apk add doppler
            '
            ;;
        ubuntu|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_proot_distro_doppler

#--- /proot-distro-doppler ---#


#--- doppler ---#

_needs_doppler() {
    [ ! -f "$HOME/bin/doppler" ]
}

_doppler() {
    kd_step_start "doppler" "Setting up doppler wrapper"

    if ! _needs_doppler; then
        kd_step_skip "~/bin/doppler already exists"
        return 0
    fi

    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            kd_log "Creating ~/bin directory"
            mkdir -p "$HOME/bin"

            kd_log "Creating doppler wrapper script"
            cat > "$HOME/bin/doppler" << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
# Run Doppler inside Alpine proot, in the current directory, forwarding args
set -e
proot-distro login alpine -- sh -lc '
  cd "$PWD"
  exec doppler "$@"
' doppler "$@"
EOF

            chmod +x "$HOME/bin/doppler"
            ;;
        ubuntu|*)
            kd_step_skip "platform $platform not supported"
            return 0
            ;;
    esac

    kd_step_end
}

_doppler

#--- /doppler ---#


#--- termux-next-steps ---#

_needs_termux_next_steps() {
    # Always run to show next steps
    true
}

_termux_next_steps() {
    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            printf "\n"
            printf "%s%s%s Next Steps:%s\n" "$KD_BOLD" "$KD_YELLOW" "🚀" "$KD_RESET"
            printf "   Run %sdoppler login%s to authenticate with Doppler\n" "$KD_CYAN" "$KD_RESET"
            printf "   Then continue with your bootstrap process\n"
            ;;
        ubuntu|*)
            # Do nothing for other platforms
            return 0
            ;;
    esac
}

_termux_next_steps

#--- /termux-next-steps ---#

