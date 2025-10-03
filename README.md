# k

kyldvs dotfiles and machine setup

## Overview

This repository provides a modular, config-driven bootstrap system for provisioning development environments across different platforms:

- **Termux/Mobile**: Setup for mobile device accessing remote VM
- **VM Root**: Provision non-root user with sudo and SSH access
- **VM User**: Configure development environment with sensible defaults

All scripts are idempotent (safe to re-run), POSIX-compliant, and config-driven via JSON files.

## Bootstrap Scripts

| Script | Purpose | Config File | Requires Root |
|--------|---------|-------------|---------------|
| `configure.sh` | Interactive Termux configuration | `~/.config/kyldvs/k/configure.json` | No |
| `termux.sh` | Termux environment bootstrap | Uses configure.json | No |
| `vmroot-configure.sh` | Interactive VM root configuration | `/root/.config/kyldvs/k/vmroot-configure.json` | Yes |
| `vmroot.sh` | Provision VM non-root user | Uses vmroot-configure.json | Yes |
| `vm.sh` | Configure VM development environment | None (applies defaults) | No |

## Termux/Mobile Setup

### Step 1: Configure (One-Time)

Creates configuration file with your VM connection details and Doppler settings.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/configure.sh)
```

**What gets configured:**
- **VM Connection**: Hostname/IP, SSH port (default 22), username (default kad)
- **Doppler Settings**: Project (default main), environment (default prd)
- **SSH Key Names**: Doppler secret names for public/private keys

**Output**: `~/.config/kyldvs/k/configure.json`

### Step 2: Bootstrap Termux

Provisions complete Termux environment for VM access.

```bash
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh
```

**What gets installed:**
- Termux properties (extra keyboard row with ESC, TAB, CTRL, ALT, arrow keys)
- Termux color scheme and font (Fira Code)
- Essential packages: `openssh`, `mosh`, `jq`
- proot-distro and Alpine Linux (for Doppler CLI)

**What gets configured:**
- Profile initialization (`~/.profile`)
- Doppler CLI installed in Alpine
- Doppler wrapper script (`~/bin/doppler`)
- SSH keys retrieved from Doppler (`~/.ssh/gh_vm`, `~/.ssh/gh_vm.pub`)
- SSH config with VM entry (`~/.ssh/config`)

**After first run**, you'll need to authenticate with Doppler:

```bash
~/bin/doppler login
```

Then re-run the bootstrap to complete SSH key setup:

```bash
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh
```

### Step 3: Connect to VM

```bash
ssh vm        # Standard SSH connection
mosh vm       # Mosh connection (better for mobile, handles roaming)
```

Agent-wrapped versions (automatic agent setup):
```bash
ssha vm       # SSH with agent
mosha vm      # Mosh with agent
```

## VM Root Provisioning

Run these commands **as root** on your VM to create and configure a non-root user.

### Step 1: Configure Root Bootstrap

Interactive configuration for user provisioning.

```bash
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot-configure.sh | sh
```

**What gets configured:**
- **Username**: User to create (default: kad)
- **Home Directory**: User's home (default: /mnt/kad)

**Output**: `/root/.config/kyldvs/k/vmroot-configure.json`

### Step 2: Provision User

Creates user with full sudo access and SSH keys.

```bash
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot.sh | sh
```

**What gets configured:**
- User account created with specified home directory
- Passwordless sudo access (`/etc/sudoers.d/vmroot-<username>`)
- SSH keys copied from root's `~/.ssh/authorized_keys` to user
- Proper ownership and permissions (700 for .ssh, 600 for keys)

**Result**: User can SSH in and use sudo without password.

## VM User Development Environment

Run as the **non-root user** on your VM to configure development environment.

```bash
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vm.sh | sh
```

**What gets configured:**

### Git Workflow Defaults (8 Settings)

| Setting | Value | Purpose |
|---------|-------|---------|
| `push.default` | `current` | Eliminates "no upstream branch" errors - pushes to same branch name |
| `pull.ff` | `true` | Prevents unexpected merge commits - fast-forward only pulls |
| `merge.ff` | `true` | Fast-forward when possible - cleaner history |
| `merge.conflictstyle` | `zdiff3` | Shows common ancestor in conflicts - easier resolution |
| `init.defaultBranch` | `main` | Modern default branch name |
| `diff.algorithm` | `histogram` | More intuitive diffs with better move detection |
| `log.date` | `iso` | ISO 8601 timestamps (YYYY-MM-DD HH:MM:SS) |
| `core.autocrlf` | `false` | No automatic line ending conversion (Unix/Linux) |

**Important**: Preserves existing `user.name` and `user.email` - only configures workflow settings.

**Idempotent**: Safe to re-run, skips if already configured.

## Complete Workflows

### Fresh Termux Setup

```bash
# 1. Configure (one-time)
bash <(curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/configure.sh)

# 2. Bootstrap Termux
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh

# 3. Authenticate with Doppler
~/bin/doppler login

# 4. Re-run bootstrap (retrieves SSH keys)
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh

# 5. Connect to VM
ssh vm  # or: mosh vm
```

### Fresh VM Setup

```bash
# As root:

# 1. Configure user provisioning
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot-configure.sh | sh

# 2. Provision user
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot.sh | sh

# As user (after SSH'ing in):

# 3. Configure development environment
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vm.sh | sh

# 4. Set Git identity (if not already set)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Key Features

- **Idempotent**: All scripts safe to re-run - skip already configured items
- **Config-driven**: JSON configuration files drive behavior, avoid repetitive prompts
- **POSIX-compliant**: Work with sh/dash/bash, minimal dependencies, no bashisms
- **Modular**: Component-based architecture with build-time composition
- **Tested**: Docker Compose-based test suite validates all functionality

## Architecture

Scripts are built from modular components in `bootstrap/lib/`:
- `utils/` - Shared utilities (logging, colors, steps, retry)
- `steps/` - Step components (ssh-keys, git-config, packages, etc.)

Manifests in `bootstrap/manifests/*.txt` define which components to include.

Build process concatenates components into standalone executables.

**Documentation**: See `docs/design/` for detailed architecture documentation:
- `bootstrap-components.md` - Component system architecture
- `bootstrap-system.md` - Overall bootstrap system design
- `vm-provisioning.md` - VM provisioning details
- `testing-infrastructure.md` - Test infrastructure

## Development

### Requirements

- `just` - Command runner
- `docker` and `docker compose` - For testing
- `shellcheck` - POSIX compliance validation (via pre-commit hooks)

### Commands

```bash
# Run all tests
just test all

# Run specific test suite
just test mobile termux
just test vmroot
just test vm

# Build bootstrap scripts from manifests
just bootstrap build-all
just bootstrap build termux  # Build specific script

# Clean test containers
just test clean

# Lint with pre-commit hooks
just hooks pre-commit

# Commit changes
just vcs cm "commit message"
just vcs push
```

### Project Structure

```
bootstrap/
├── lib/
│   ├── utils/           # Shared utilities
│   └── steps/           # Step components
├── manifests/           # Build manifests (*.txt)
└── *.sh                 # Generated scripts (built from manifests)

src/tests/
├── tests/               # Test suites (*.test.sh)
├── images/              # Docker test images
├── docker-compose.*.yml # Test configurations
└── run-*.sh             # Test runners

docs/
├── design/              # Architecture documentation
├── tasks/               # Active tasks
└── tasks-done/          # Completed tasks

tasks/                   # Justfile modules
module/                  # External modules (dotfiles, etc.)
```

## Configuration Files

### Termux Configuration

**Location**: `~/.config/kyldvs/k/configure.json`

```json
{
  "doppler": {
    "project": "main",
    "env": "prd",
    "ssh_key_public": "SSH_GH_VM_PUBLIC",
    "ssh_key_private": "SSH_GH_VM_PRIVATE"
  },
  "vm": {
    "hostname": "192.168.1.100",
    "port": 22,
    "username": "kad"
  }
}
```

### VM Root Configuration

**Location**: `/root/.config/kyldvs/k/vmroot-configure.json`

```json
{
  "username": "kad",
  "homedir": "/mnt/kad"
}
```

## Principles

This project follows "Less, but Better" design principles (see `docs/principles.md`):

- Solve real problems, not imagined ones
- Code exists to be useful, not to showcase technology
- Every line should earn its place
- Idempotency and safety over novelty
- POSIX compliance for maximum compatibility
- Build-time composition for standalone executables
- Config-driven to eliminate manual setup
- Test everything in isolated environments

## License

MIT
