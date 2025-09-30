# Mobile Dev Bootstrap - Specification

## Overview
A streamlined bootstrap system for mobile AI-agent development that sets up a minimal Termux environment on Android with SSH/Mosh connectivity to a remote VM. Configuration is managed through an interactive script and Doppler secrets management.

## Goals
- Enable one-command bootstrap from fresh Termux install
- Minimize Android environment to only connection essentials
- Store SSH keys securely in Doppler, not in repo
- Support future VM provisioning via SSH commands
- Replace existing bootstrap system with configuration-driven approach

## Requirements

### Functional Requirements
- FR-1: Interactive configure script collects user-specific settings and saves to `~/.config/kyldvs/k/configure.json`
- FR-2: Bootstrap script reads configuration and sets up minimal Termux environment
- FR-3: Doppler CLI integration retrieves SSH keys for VM access
- FR-4: SSH/Mosh clients configured for seamless VM connection
- FR-5: Scripts must be curl-pipeable from GitHub for fresh environments
- FR-6: Idempotent execution - safe to run multiple times

### Non-Functional Requirements
- NFR-1: Zero git dependencies in Termux environment
- NFR-2: Minimal disk footprint in Android environment
- NFR-3: POSIX-compliant shell scripts for maximum compatibility
- NFR-4: Clear error messages for missing configuration or credentials

### Technical Requirements
- Termux environment (Android)
- Doppler for secrets management (SSH keys)
- SSH and Mosh for VM connectivity
- JSON for configuration storage
- jq for JSON parsing in scripts

## User Stories / Use Cases

**Initial Setup:**
- As a developer, I run configure script on fresh Termux install to answer setup questions once
- As a developer, I run bootstrap script to automatically configure my Termux environment using saved configuration
- As a developer, I can `ssh vm` or `mosh vm` to connect to my development VM immediately after bootstrap

**Configuration Management:**
- As a developer, my SSH keys are retrieved from Doppler, never stored in public repo
- As a developer, I can re-run configure to update settings without re-bootstrapping
- As a developer, my configuration persists at `~/.config/kyldvs/k/configure.json`

**Future VM Provisioning:**
- As a developer, I will eventually run commands via SSH to bootstrap the VM as root
- As a developer, I will eventually run commands via SSH to configure VM as my dev user (kad)

## Configuration Schema

`~/.config/kyldvs/k/configure.json`:
```json
{
  "doppler": {
    "token": "dp.st.xxx",
    "project": "main",
    "env": "prd",
    "ssh_key_public": "SSH_GH_VM_PUBLIC",
    "ssh_key_private": "SSH_GH_VM_PRIVATE"
  },
  "vm": {
    "hostname": "vm.example.com",
    "port": 22,
    "username": "kad"
  }
}
```

## Bootstrap Flow

### Phase 1: Configure (Interactive)
`bootstrap/configure.sh`:
1. Prompt for Doppler token
2. Prompt for VM hostname/IP
3. Prompt for VM SSH port (default: 22)
4. Prompt for VM username (default: kad)
5. Prompt for Doppler project (default: main)
6. Prompt for Doppler environment (default: prd)
7. Prompt for SSH key names (defaults: SSH_GH_VM_PUBLIC/PRIVATE)
8. Create `~/.config/kyldvs/k/configure.json`
9. Set appropriate permissions (600)

### Phase 2: Bootstrap Termux
`bootstrap/termux.sh`:
1. Read configuration from `~/.config/kyldvs/k/configure.json`
2. Install Termux packages: openssh, mosh-client, jq
3. Install Doppler CLI
4. Authenticate Doppler using token from config
5. Fetch SSH keys from Doppler and write to `~/.ssh/`
6. Generate SSH config for VM connection
7. Test SSH connection to VM
8. Display success message with connection commands

### Phase 3: VM Bootstrap (Future)
`bootstrap/vm.sh`:
1. SSH to VM as root
2. Run provisioning commands (user creation, sudo setup, etc.)
3. SSH to VM as dev user (kad)
4. Run user-level setup (dev tools, dotfiles, etc.)

## Success Criteria
- Fresh Termux install can be fully configured in under 5 minutes
- Single command execution for both configure and bootstrap
- SSH connection to VM succeeds after bootstrap
- Mosh connection to VM succeeds after bootstrap
- No credentials stored in repository
- Configuration persists across Termux restarts

## Constraints
- Must work on Android via Termux (limited system access)
- No git required in Termux environment
- SSH keys must never appear in public repository
- Scripts must be publicly accessible (curl-pipeable)
- Configuration file contains sensitive data (Doppler token)

## Non-Goals
- Git configuration in Termux
- Development tool installation in Termux
- VM provisioning (Phase 3 - future work)
- IDE or editor setup in Termux
- Dotfile symlinking in Termux

## Assumptions
- User has working Termux installation
- User has Doppler account with SSH keys stored
- VM is already provisioned and accessible via SSH
- Network connectivity available for package installation
- User understands basic SSH/Mosh usage

## Open Questions
- Should configure.sh validate Doppler token before saving?
- Should bootstrap.sh create SSH key backup in Doppler if none exists?
- How to handle SSH key rotation without re-running configure?
- Should Mosh require specific port configuration?
- Error recovery strategy if VM is unreachable during bootstrap?

## Migration from Existing System
- New system replaces `src/bootstrap/*.json` compilation approach
- Move from part-based compilation to config-driven execution
- Retain utility functions from `src/parts/util-functions.sh`
- Keep existing test infrastructure for validation
- Update justfile recipes to support new bootstrap flow

## File Structure
```
bootstrap/
  configure.sh      # Interactive configuration
  termux.sh        # Termux environment setup
  vm.sh            # Future: VM provisioning

~/.config/kyldvs/k/
  configure.json   # User-specific configuration (gitignored)
```
