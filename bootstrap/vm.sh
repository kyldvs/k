#!/bin/bash
#
# Generated bootstrap script
# Do not edit directly - edit parts and rebuild
#

#--- init-k ---#

#!/bin/bash

_needs_init_k() {
    [ ! -d ~/.k ]
}

_init_k() {
    kd_step_start "init-k" "Setting up ~/.k directory structure"

    if ! _needs_init_k; then
        kd_step_skip "~/.k directory already exists"
        return 0
    fi

    kd_log "Creating ~/.k directory"
    mkdir -p ~/.k

    kd_log "Creating ~/.k/init.sh loader script"
    cat > ~/.k/init.sh << 'EOF'
# ~/.k/init.sh - Loader for all shell customizations
# Sources all .sh files in ~/.k/ except init.sh itself

for f in ~/.k/*.sh; do
    [ -f "$f" ] && [ "$f" != ~/.k/init.sh ] && . "$f"
done
EOF

    kd_step_end
}

_init_k

#--- /init-k ---#


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
    ! grep -q '. ~/.k/init.sh' ~/.profile 2>/dev/null
}

_init_profile() {
    kd_step_start "init-profile" "Setting up .profile"

    if ! _needs_profile_init; then
        kd_step_skip "~/.k/init.sh already sourced in profile"
        return 0
    fi

    # Create .profile if it doesn't exist
    [ ! -f ~/.profile ] && echo "# POSIX compliant profile with common setup" > ~/.profile

    kd_log "Adding ~/.k/init.sh source line to ~/.profile"
    echo "" >> ~/.profile
    echo "# Source shell customizations from ~/.k/" >> ~/.profile
    echo ". ~/.k/init.sh" >> ~/.profile

    kd_step_end
}

_init_profile

#--- /init-profile ---#


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


#--- ssh-utils ---#

#!/bin/bash

_needs_ssh_utils() {
    [ ! -f ~/.k/ssh-utils.sh ]
}

_ssh_utils() {
    kd_step_start "ssh-utils" "Add SSH agent wrapper functions"

    if ! _needs_ssh_utils; then
        kd_step_skip "SSH utilities already configured"
        return
    fi

    kd_log "Creating ~/.k/ssh-utils.sh"

    cat > ~/.k/ssh-utils.sh << 'EOF'
# SSH agent wrapper functions
ssha() {
    # Check if agent running
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval $(ssh-agent -s)
    fi
    # Check if keys loaded
    if ! ssh-add -l &>/dev/null; then
        ssh-add
    fi
    ssh "$@"
}

mosha() {
    # Same agent setup as ssha
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval $(ssh-agent -s)
    fi
    if ! ssh-add -l &>/dev/null; then
        ssh-add
    fi
    mosh "$@"
}
EOF

    kd_step_end
}

_ssh_utils

#--- /ssh-utils ---#

