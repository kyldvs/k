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
