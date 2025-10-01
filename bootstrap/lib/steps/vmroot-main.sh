# Main flow for vmroot bootstrap
main() {
  printf "\n%s%sVM Root Bootstrap%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "Provisioning non-root user with sudo and SSH access\n\n"

  # Check config exists
  check_vmroot_config

  # Execute provisioning steps
  create_user
  configure_sudo
  setup_ssh

  # Success message
  local username=$(jq -r '.username' "$VMROOT_CONFIG_FILE")
  printf "\n%s✓ Bootstrap complete!%s\n" "$KD_GREEN" "$KD_RESET"
  printf "\nUser %s%s%s is now configured with:\n" "$KD_CYAN" "$username" "$KD_RESET"
  printf "  • Home directory\n"
  printf "  • Passwordless sudo access\n"
  printf "  • SSH keys from root\n"
  printf "\n"
}

main
