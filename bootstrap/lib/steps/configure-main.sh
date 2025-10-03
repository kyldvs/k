#!/usr/bin/env sh
# Main configuration flow
main() {
  printf "\n%s%sConfiguration Setup%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "This script will configure your k bootstrap system.\n\n"

  # VM Configuration
  printf "%s%sVM Configuration:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  prompt_validated "VM hostname/IP" "" vm_hostname validate_hostname \
    "Hostname must be alphanumeric with dots/hyphens (e.g., 192.168.1.1 or host.example.com)"
  prompt_validated "VM SSH port" "22" vm_port validate_port \
    "Port must be 1-65535"
  prompt_validated "VM username" "kad" vm_username validate_username \
    "Username must start with letter/underscore, contain only lowercase letters, digits, underscore, hyphen"

  printf "\n"

  # Doppler Configuration
  printf "%s%sDoppler Configuration:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  prompt "Doppler project" "main" doppler_project
  prompt "Doppler environment" "prd" doppler_env
  prompt "SSH public key name in Doppler" "SSH_GH_VM_PUBLIC" ssh_key_public
  prompt "SSH private key name in Doppler" "SSH_GH_VM_PRIVATE" ssh_key_private

  printf "\n"

  # Validate inputs
  if ! validate_config "$vm_hostname" "$vm_port" "$vm_username" \
                      "$doppler_project" "$doppler_env"; then
    exit 1
  fi

  # Create config directory
  printf "%s→%s Creating config directory...\n" "$KD_CYAN" "$KD_RESET"
  mkdir -p "$CONFIG_DIR"
  chmod 700 "$CONFIG_DIR"

  # Write JSON config
  printf "%s→%s Writing configuration to %s...\n" "$KD_CYAN" "$KD_RESET" \
    "$CONFIG_FILE"

  cat > "$CONFIG_FILE" <<EOF
{
  "doppler": {
    "project": "$doppler_project",
    "env": "$doppler_env",
    "ssh_key_public": "$ssh_key_public",
    "ssh_key_private": "$ssh_key_private"
  },
  "vm": {
    "hostname": "$vm_hostname",
    "port": $vm_port,
    "username": "$vm_username"
  }
}
EOF

  chmod 600 "$CONFIG_FILE"

  printf "%s✓%s Configuration saved successfully!\n\n" "$KD_GREEN" "$KD_RESET"

  # Display next steps
  printf "%s%sNext Steps:%s\n" "$KD_BOLD" "$KD_YELLOW" "$KD_RESET"
  printf "  1. Run the bootstrap script for your platform:\n"
  printf "     Termux: %sbash bootstrap/termux.sh%s\n" "$KD_CYAN" "$KD_RESET"
  printf "     VM: %sbash bootstrap/vm.sh%s (coming soon)\n" \
    "$KD_CYAN" "$KD_RESET"
  printf "\n"
}

main
