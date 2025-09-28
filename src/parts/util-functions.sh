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
