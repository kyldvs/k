# VM Root Bootstrap - Specification

## Overview
A bootstrap system for provisioning fresh VMs from root account, creating a configured user account with proper permissions, SSH access, and sudo privileges. This extends the existing bootstrap architecture to handle VM setup before transitioning to user-level configuration.

## Goals
- Automate initial VM provisioning from root account
- Create standardized user accounts with configurable home directories
- Enable passwordless operations (SSH and sudo) for seamless workflow
- Maintain consistency with existing bootstrap architecture

## Requirements

### Functional Requirements
- FR-1: Interactive configuration script that prompts for username (default: kad) and home directory path (default: /mnt/kad)
- FR-2: Non-interactive bootstrap script that provisions VM using saved configuration
- FR-3: Create user account with configured home directory
- FR-4: Add user to sudoers with passwordless sudo access
- FR-5: Copy root's authorized SSH keys to new user for passwordless SSH access
- FR-6: Store configuration in `~/.config/kyldvs/k/vmroot-configure.json` (root's home)
- FR-7: Support idempotent execution - safe to run multiple times

### Non-Functional Requirements
- NFR-1: Must run as root user (validate at script start)
- NFR-2: Fail fast with clear error messages for misconfigurations
- NFR-3: Follow POSIX-compliant shell practices where possible
- NFR-4: Match existing bootstrap conventions (logging, colors, step tracking)

### Technical Requirements
- Use existing bootstrap component architecture (`bootstrap/lib/`)
- Generate scripts from manifests (`bootstrap/manifests/vmroot-configure.txt`, `vmroot.txt`)
- Reuse existing utilities (`utils/colors.sh`, `utils/logging.sh`, `utils/steps.sh`)
- Scripts must be standalone (no external dependencies beyond coreutils)
- Support both interactive TTY and non-interactive execution

## User Stories / Use Cases
- As a VM owner, I want to run one command as root to configure my preferences so that subsequent provisioning is automated
- As a VM owner, I want to run one command as root to provision a fresh VM so that my user account is ready with SSH and sudo access
- As a developer, I want the root bootstrap to integrate with existing user-level bootstrap so that I can seamlessly transition from VM setup to user environment setup
- As a developer, I want idempotent scripts so that I can safely re-run provisioning without errors

## Success Criteria
- `vmroot/configure.sh` successfully prompts for and saves configuration
- `vmroot.sh` creates user account with specified home directory
- User can SSH into VM using same keys that work for root
- User can run sudo commands without password prompt
- Scripts pass mobile-style Docker tests validating all functionality
- Running scripts multiple times produces same result (idempotent)
- Configuration persists at `~/.config/kyldvs/k/vmroot-configure.json` (root's home)

## Technical Design

### User Creation Approach
- Use `useradd` with `--create-home` and `--home-dir` flags
- Non-interactive: use `--password` with locked password (`!`) since SSH keys handle auth
- Set shell to `/bin/bash` explicitly
- Create home directory parents if needed (`mkdir -p`)

### SSH Key Setup
- Copy `/root/.ssh/authorized_keys` to `$USER_HOME/.ssh/authorized_keys`
- Set proper ownership and permissions (700 for .ssh, 600 for authorized_keys)
- Handle case where root has no authorized_keys (skip SSH setup)

### Sudoers Configuration
- Create `/etc/sudoers.d/vmroot-$USERNAME` file
- Content: `$USERNAME ALL=(ALL) NOPASSWD:ALL`
- Set file permissions to 440 (required by sudo)
- Validate syntax with `visudo -c` before activating

### Configuration Schema
```json
{
  "username": "kad",
  "homedir": "/mnt/kad"
}
```

### Bootstrap Components Needed
New step files:
- `bootstrap/lib/steps/vmroot-configure.sh` - interactive prompts
- `bootstrap/lib/steps/vmroot-user.sh` - user creation logic
- `bootstrap/lib/steps/vmroot-sudo.sh` - sudoers configuration
- `bootstrap/lib/steps/vmroot-ssh.sh` - SSH key setup

New manifests:
- `bootstrap/manifests/vmroot-configure.txt`
- `bootstrap/manifests/vmroot.txt`

### Script Generation
```bash
just bootstrap build vmroot-configure  # Build vmroot/configure.sh
just bootstrap build vmroot            # Build vmroot.sh
```

## Constraints
- Must run as root (uid 0) - scripts validate at startup
- Requires standard Linux utilities: useradd, usermod, sudo, mkdir, cp, chown, chmod
- Home directory path must be valid and writable
- Username must follow Linux username conventions (no validation beyond useradd defaults)

## Non-Goals
- Will NOT configure VM networking, storage, or system-level packages
- Will NOT install dotfiles or user-level tools (that's handled by user bootstrap)
- Will NOT support Windows or non-Linux VMs
- Will NOT manage user passwords (rely on SSH keys only)
- Will NOT support multiple users (single user per VM assumed)

## Assumptions
- VM has root SSH access configured
- VM is Debian/Ubuntu-based (useradd, sudo available)
- Root has authorized_keys set up (or SSH setup is skipped)
- Bootstrap scripts can be downloaded via curl (same as existing bootstrap)
- Target home directory parent exists or can be created

## Open Questions
- Should vmroot.sh automatically run user-level configure.sh for the new user? (Suggested: No - keep separation of concerns)
- Should we validate that home directory parent is writable before proceeding? (Suggested: Yes - fail fast)
- Should configuration support additional fields (shell, groups)? (Suggested: No - keep minimal, extend later if needed)
- How to handle existing user with same name? (Suggested: Skip user creation, update sudo/SSH only)
