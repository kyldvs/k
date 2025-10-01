# Display success message
show_next_steps() {
  printf "\n"
  printf "%s%s✓ Bootstrap Complete!%s\n" "$KD_BOLD" "$KD_GREEN" "$KD_RESET"
  printf "\n"
  printf "%s%sNext Steps:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  printf "  Connect to your VM using:\n"
  printf "    %sssh vm%s        - Standard SSH connection\n" "$KD_CYAN" \
    "$KD_RESET"
  printf "    %smosh vm%s       - Mosh connection (roaming)\n" "$KD_CYAN" \
    "$KD_RESET"
  printf "\n"
  printf "  Or use agent-wrapped versions:\n"
  printf "    %sssha vm%s       - SSH with automatic agent setup\n" \
    "$KD_CYAN" "$KD_RESET"
  printf "    %smosha vm%s      - Mosh with automatic agent setup\n" \
    "$KD_CYAN" "$KD_RESET"
  printf "\n"
}
