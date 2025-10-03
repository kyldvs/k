# Main flow for VM bootstrap
main() {
  printf "\n%s%sVM Bootstrap%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "Configuring development environment\n\n"

  # Execute configuration steps
  configure_git

  # Success message
  printf "\n%s✓ Bootstrap complete!%s\n" "$KD_GREEN" "$KD_RESET"
  printf "\nDevelopment environment configured with:\n"
  printf "  • Git workflow defaults\n"
  printf "\n"
}

main
