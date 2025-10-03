# VM Provisioning System

## Overview
Root-level VM bootstrap system that creates configured user accounts with SSH
keys and passwordless sudo access. Designed for provisioning fresh VMs before
transitioning to user-level development environment setup.

## Architecture

### Two-Phase Approach
VM provisioning follows the same configuration-then-bootstrap pattern as the
mobile system:

1. **Configuration Phase** (`vmroot-configure.sh`)
   - Interactive prompts for username and home directory
   - Stores config at `/root/.config/kyldvs/k/vmroot-configure.json`
   - Validates inputs (non-empty, parent directory writable)

2. **Provisioning Phase** (`vmroot.sh`)
   - Reads saved configuration
   - Creates user account with specified home directory
   - Configures passwordless sudo
   - Copies root's SSH keys to new user
   - Idempotent execution

### Execution Context
- **Must run as root** (uid 0) - validated at script start
- **Configuration scope**: Single user per VM (non-goal: multi-user)
- **Security model**: SSH keys only, no password authentication

## Key Components

### User Creation (`vmroot-user.sh`)
Creates user account with custom home directory:

```sh
useradd --create-home --home-dir "$HOMEDIR" \
        --shell /bin/bash --password '!' "$USERNAME"
```

**Design decisions**:
- Locked password (`!`) since SSH keys handle authentication
- Explicit shell (`/bin/bash`) for consistency
- Parent directory created with `mkdir -p` if needed
- Idempotent: skips if user exists, updates config only

### Sudoers Configuration (`vmroot-sudo.sh`)
Enables passwordless sudo via drop-in file:

**File**: `/etc/sudoers.d/vmroot-$USERNAME`
**Content**: `$USERNAME ALL=(ALL) NOPASSWD:ALL`
**Permissions**: 440 (required by sudo)

**Validation**:
- Syntax checked with `visudo -cf /path/to/file` before activation
- Fails fast if validation errors occur

**Security rationale**: Passwordless sudo enables seamless automation while
maintaining SSH key-based access control at the VM boundary.

### SSH Key Distribution (`vmroot-ssh.sh`)
Copies root's authorized keys to new user:

1. Copy `/root/.ssh/authorized_keys` → `$USER_HOME/.ssh/authorized_keys`
2. Set directory permissions: 700 (`.ssh/`)
3. Set file permissions: 600 (`authorized_keys`)
4. Set ownership: `chown -R $USERNAME:$USERNAME $USER_HOME/.ssh/`

**Graceful degradation**: Skips SSH setup if root has no authorized_keys,
logs warning instead of failing.

### Configuration Schema
```json
{
  "username": "kad",
  "homedir": "/mnt/kad"
}
```

**Validation rules**:
- Username: non-empty (useradd handles format validation)
- Home directory: non-empty, parent must be writable
- No advanced validation (shell, groups) - kept minimal

## Design Decisions

### Root-Only Execution
**Decision**: Scripts validate root user at startup and exit if not root.

**Rationale**:
- User creation requires root privileges
- Sudoers configuration requires root access
- Prevents accidental permission errors mid-execution
- Clear error message: "This script must be run as root"

### Configuration Storage Location
**Decision**: Store config in `/root/.config/kyldvs/k/`

**Rationale**:
- Consistent with user-level config pattern
- Root's home directory is appropriate for root-scoped config
- Survives across provisioning runs
- XDG-style path convention

### Custom Home Directories
**Decision**: Support arbitrary home directory paths (not just `/home/$USER`)

**Rationale**:
- Enables non-standard mounts (e.g., `/mnt/kad`)
- Useful for VMs with separate data volumes
- Validated at configuration time (parent must exist/be writable)

### Idempotency Strategy
**Patterns used**:
- User exists: `id "$USERNAME" >/dev/null 2>&1 && skip`
- Sudoers file exists: `[ -f /etc/sudoers.d/vmroot-$USERNAME ] && skip`
- SSH keys exist: `[ -f "$USER_HOME/.ssh/authorized_keys" ] && skip`

**Updates on re-run**:
- User creation skipped, but sudo/SSH config updated if missing
- Allows recovering from partial failures

### Separation from User Bootstrap
**Decision**: VM root bootstrap does NOT automatically run user-level
configuration.

**Rationale**:
- Clear separation of concerns (root vs user operations)
- Allows testing root provisioning independently
- User may want to configure before running user bootstrap
- Explicit transition: user SSHs in and runs their own bootstrap

## Implementation Patterns

### Root Validation Pattern
```sh
if [ "$(id -u)" -ne 0 ]; then
  kd_error "This script must be run as root"
  exit 1
fi
```

### Safe Sudoers Creation
```sh
SUDOERS_FILE="/etc/sudoers.d/vmroot-$USERNAME"
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"
chmod 440 "$SUDOERS_FILE"

if ! visudo -cf "$SUDOERS_FILE"; then
  kd_error "Invalid sudoers syntax"
  rm "$SUDOERS_FILE"
  exit 1
fi
```

### Directory Creation with Parents
```sh
parent_dir=$(dirname "$homedir")
if [ ! -d "$parent_dir" ]; then
  mkdir -p "$parent_dir" || exit 1
fi
```

## Integration Points

### With Mobile Bootstrap
**Connection flow**:
1. Mobile (Termux) environment bootstrapped first
2. SSH connection established from mobile to VM root
3. VM root bootstrap run via SSH (curl-pipe-sh pattern)
4. User SSHs to VM as new user
5. User runs user-level bootstrap (future: `vm.sh`)

### With User Environment
**Transition point**: After root bootstrap completes, user can:
- SSH into VM using same keys: `ssh $USERNAME@vm`
- Run sudo commands without password: `sudo apt update`
- Clone dotfiles and run user-level setup
- Future: Run `vm.sh` bootstrap for development tools

### With Test System
- Tests run in Docker containers with Ubuntu base image
- Test validates: user creation, sudo access, SSH key permissions
- Idempotency checked by running vmroot.sh twice
- See testing-infrastructure.md for details

## Security Considerations

### SSH Key Security
- Keys copied with strict permissions (600)
- Directory permissions enforce access control (700)
- Ownership set correctly to prevent privilege escalation
- No keys stored in repository (copied from runtime environment)

### Sudoers Security
- Syntax validation prevents breaking sudo
- File permissions (440) prevent unauthorized modification
- Drop-in files isolated from main sudoers config
- User-specific files enable granular removal if needed

### Password Policy
- Locked passwords (`!`) prevent password-based authentication
- SSH keys as sole authentication method
- Aligns with security best practice for automated environments

## Testing Approach
- Docker tests with Ubuntu base image (includes useradd, sudo, ssh)
- Validates user creation with custom home directories
- Verifies passwordless sudo: `su - $USERNAME -c 'sudo whoami'`
- Checks SSH key permissions and ownership
- Tests idempotency across multiple runs

## Future Considerations
- **Multi-user support**: Currently single-user per VM, could extend config
  schema to support array of users
- **Group management**: Could add user to specific groups beyond primary group
- **Shell selection**: Hardcoded to bash, could make configurable
- **Firewall rules**: Not handled, assumes VM-level network config managed
  separately
- **User-level bootstrap integration**: Future `vm.sh` script will handle
  development environment setup after root provisioning
