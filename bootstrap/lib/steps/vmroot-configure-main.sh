#!/usr/bin/env sh
# Main configuration flow for vmroot
main() {
  printf "\n%s%sVM Root Bootstrap Configuration%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "This script will configure VM root provisioning.\n\n"

  # Prompt for configuration
  printf "%s%sUser Configuration:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  vmroot_prompt_validated "Username" "kad" username validate_username \
    "Username must start with letter/underscore, contain only lowercase letters, digits, underscore, hyphen"
  vmroot_prompt_validated "Home directory" "/mnt/kad" homedir validate_directory \
    "Directory must be absolute path starting with /"

  printf "\n"

  # Validate inputs
  if ! validate_vmroot_config "$username" "$homedir"; then
    exit 1
  fi

  # Create config directory
  printf "%s→%s Creating config directory...\n" "$KD_CYAN" "$KD_RESET"
  mkdir -p "$VMROOT_CONFIG_DIR"
  chmod 700 "$VMROOT_CONFIG_DIR"

  # Write JSON config
  printf "%s→%s Writing configuration to %s...\n" "$KD_CYAN" "$KD_RESET" \
    "$VMROOT_CONFIG_FILE"

  cat > "$VMROOT_CONFIG_FILE" <<EOF
{
  "username": "$username",
  "homedir": "$homedir"
}
EOF

  chmod 600 "$VMROOT_CONFIG_FILE"

  printf "%s✓%s Configuration saved successfully!\n\n" "$KD_GREEN" "$KD_RESET"

  # Display next steps
  printf "%s%sNext Steps:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  printf "  1. Run the VM root bootstrap script:\n"
  printf "     %sbash bootstrap/vmroot.sh%s\n" "$KD_CYAN" "$KD_RESET"
  printf "\n"
}

main
