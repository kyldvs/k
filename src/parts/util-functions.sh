_needs_util_functions() {
    # Always needed as utility functions
    true
}

_util_functions() {
    # POSIX compliant color definitions - only set if stdout is a tty
    if [ -t 1 ]; then
        KD_RED='\033[31m'
        KD_GREEN='\033[32m'
        KD_YELLOW='\033[33m'
        KD_BLUE='\033[34m'
        KD_CYAN='\033[36m'
        KD_GRAY='\033[90m'
        KD_RESET='\033[0m'
        KD_BOLD='\033[1m'
    else
        KD_RED=''
        KD_GREEN=''
        KD_YELLOW=''
        KD_BLUE=''
        KD_CYAN=''
        KD_GRAY=''
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

    # Format message for 60 char width - word wrap at word boundaries
    _kd_wrap() {
        local text="$1"
        local width=60
        local indent_str
        indent_str=$(_kd_indent)
        local indent_len=${#indent_str}
        local max_width=$((width - indent_len))

        echo "$text" | fold -s -w "$max_width" | while IFS= read -r line; do
            if [ -n "$line" ]; then
                printf "%s%s\n" "$indent_str" "$line"
            fi
        done
    }

    # Log functions
    kd_log() {
        local msg="$*"
        _kd_wrap "$msg"
    }

    kd_info() {
        local msg="$*"
        printf "%s[INFO]%s " "$KD_BLUE" "$KD_RESET"
        _kd_wrap "$msg" | sed "1s/^${KD_INDENT}//"
    }

    kd_warn() {
        local msg="$*"
        printf "%s[WARN]%s " "$KD_YELLOW" "$KD_RESET"
        _kd_wrap "$msg" | sed "1s/^${KD_INDENT}//"
    }

    kd_error() {
        local msg="$*"
        printf "%s[ERROR]%s " "$KD_RED" "$KD_RESET" >&2
        _kd_wrap "$msg" | sed "1s/^${KD_INDENT}//" >&2
    }

    # Step functions
    KD_CURRENT_STEP=""

    kd_step_start() {
        local step_name="$1"
        shift
        local message="$*"

        KD_CURRENT_STEP="$step_name"

        printf "%s▶%s %s%s%s" "$KD_CYAN" "$KD_RESET" "$KD_BOLD" "$step_name" "$KD_RESET"
        if [ -n "$message" ]; then
            printf ": %s" "$message"
        fi
        printf "\n"

        KD_INDENT=$((KD_INDENT + 1))
    }

    kd_step_end() {
        local message="$*"

        if [ $KD_INDENT -gt 0 ]; then
            KD_INDENT=$((KD_INDENT - 1))
        fi

        if [ -n "$KD_CURRENT_STEP" ]; then
            printf "%s✓%s %s" "$KD_GREEN" "$KD_RESET" "$KD_CURRENT_STEP"
            if [ -n "$message" ]; then
                printf ": %s" "$message"
            fi
            printf "\n"
            KD_CURRENT_STEP=""
        fi
    }

    kd_step_skip() {
        local step_name="$1"
        shift
        local reason="$*"

        printf "%s-%s %s%s%s" "$KD_GRAY" "$KD_RESET" "$KD_GRAY" "$step_name" "$KD_RESET"
        if [ -n "$reason" ]; then
            printf ": %s" "$reason"
        fi
        printf "\n"
    }
}

_util_functions
