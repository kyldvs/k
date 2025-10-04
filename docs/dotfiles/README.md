# Dotfiles System

A unified, declarative dotfiles management system using GNU Stow for symbolic
linking, YAML configuration for declarative setup, and git-native includeIf
directives for directory-based identity management.

## Overview

The dotfiles system provides automatic environment configuration after VM
bootstrap completes. Changes to dotfiles in the repository are immediately
visible in your home directory via symbolic links - no manual sync required.

**Design Philosophy**: Less but better. Uses boring, standard technology
(stow, git, YAML, bash). No plugin managers, no frameworks, no magic.

## Architecture

### Components

- **GNU Stow**: Manages symbolic links from `dotfiles/` to `~/`
- **YAML Config**: Declarative configuration in
  `~/.config/kyldvs/k/dotfiles.yml`
- **Git includeIf**: Native git feature for directory-based identity switching
- **Just Commands**: Simple interface via `just k` commands

### Directory Structure

```
kyldvs/k/
├── dotfiles/              # Stow packages (linked to ~/)
│   ├── zsh/              # Zsh configuration
│   ├── tmux/             # Tmux configuration
│   ├── git/              # Git configuration
│   ├── shell/            # Shell aliases
│   └── config/           # Example configs
├── lib/dotfiles/         # Bash libraries
│   ├── stow.sh          # Stow wrapper
│   ├── config.sh        # YAML config loader
│   ├── git-identity.sh  # Git identity management
│   └── packages.sh      # Package installation
└── tasks/k/justfile     # User-facing commands
```

### How It Works

1. **Symbolic Linking**: Stow creates symlinks from `~/` to `dotfiles/`
2. **Automatic Updates**: `git pull` updates repo, symlinks show new content
3. **Git Identity**: includeIf directives switch identity based on directory
4. **Package Management**: YAML-defined package lists for `apt install`

## Quick Start

### Prerequisites

- VM bootstrap completed (non-root user, git, sudo)
- Repository checked out to home directory

### Initial Setup

```bash
# One-time setup (links dotfiles, configures git identity)
just k setup
```

This command:
- Creates `~/.config/kyldvs/k/dotfiles.yml` from example if missing
- Links all dotfile packages via stow
- Generates git includeIf directives for identity switching
- Handles conflicts by backing up existing files

### Install Packages

```bash
# Install all packages from YAML config
just k install-packages

# Dry run (see what would be installed)
just k install-packages true
```

### Check Status

```bash
# Show configuration and link status
just k status

# Show package installation status
just k packages

# Test git identity in directory
just k git-test ~/work
```

## Command Reference

### `just k setup`

Initial dotfiles setup. Idempotent - safe to run multiple times.

**What it does:**
1. Loads YAML config (creates from example if missing)
2. Links all dotfile packages via stow
3. Backs up conflicting files to `~/.config/kyldvs/k/backups/`
4. Generates git identity configs and includeIf directives

**When to run:**
- First time after VM bootstrap
- After adding new dotfile packages
- To regenerate git identity configs

### `just k sync`

Re-link dotfiles. Normally unnecessary (symlinks auto-update).

**What it does:**
- Re-runs stow linking for all packages
- Handles conflicts via backup

**When to run:**
- After manually removing symlinks
- To verify linking is correct

### `just k install-packages [dry_run]`

Install APT packages from YAML config.

**Arguments:**
- `dry_run`: Optional, set to "true" for dry run

**What it does:**
- Reads `packages.apt` from config
- Checks package availability in APT
- Installs packages via `sudo apt install`
- Logs installed packages

**When to run:**
- After modifying package list in YAML
- On new systems to install tools

### `just k status`

Show dotfiles configuration and status.

**What it shows:**
- Config file location and validation
- Git profiles configuration
- Package counts
- Stow link status for all packages
- Git identity status

### `just k packages`

Show detailed package installation status.

**What it shows:**
- Configured packages from YAML
- Installation status for each package
- Total installed/not installed counts

### `just k git-test <path>`

Test git identity in a specific directory.

**Arguments:**
- `path`: Directory to test (e.g., `~/work`)

**What it shows:**
- Git user.name and user.email for that directory
- Verifies includeIf directives are working

## Configuration Guide

### YAML Configuration File

**Location**: `~/.config/kyldvs/k/dotfiles.yml`

Created automatically from example on first `just k setup`.

**Minimal Example:**

```yaml
version: 1

git_profiles:
  - name: personal
    path: ~/personal
    user: "Your Name"
    email: "you@personal.example.com"

  - name: work
    path: ~/work
    user: "Your Name"
    email: "you@work.example.com"

packages:
  apt:
    - zsh
    - tmux
    - git
    - stow

tools: {}
```

See [configuration.md](configuration.md) for complete YAML schema reference.

### Git Identity Management

Git automatically uses the correct identity based on directory path using
native `includeIf` directives.

**How it works:**

1. Profile configs created in `~/.config/git/<profile>.conf`
2. includeIf directives appended to `~/.gitconfig`
3. Git checks directory against includeIf patterns
4. Matching profile config loaded automatically

**Example:**

```gitconfig
# ~/.gitconfig (auto-generated section)

# kyldvs/k dotfiles git identity management - START
[includeIf "gitdir:~/work/"]
  path = ~/.config/git/work.conf

[includeIf "gitdir:~/personal/"]
  path = ~/.config/git/personal.conf
# kyldvs/k dotfiles git identity management - END
```

**Testing:**

```bash
# Create test directory
mkdir -p ~/work/test-repo
cd ~/work/test-repo
git init

# Check identity
git config user.name
git config user.email

# Or use helper command
just k git-test ~/work/test-repo
```

### Adding Dotfiles

1. Create new stow package directory: `dotfiles/<package>/`
2. Add dotfiles with paths relative to `~/`:

```bash
# Example: Add neovim config
mkdir -p dotfiles/nvim/.config/nvim
echo "set number" > dotfiles/nvim/.config/nvim/init.vim
```

3. Link the package:

```bash
just k sync
```

The file appears as `~/.config/nvim/init.vim` (symlink to repo).

### Modifying Dotfiles

**Direct editing** (recommended):

```bash
# Edit in repository
vim dotfiles/zsh/.zshrc

# Changes immediately visible at ~/.zshrc (symlink)
```

**After git pull**:

```bash
# Pull changes
git pull

# Dotfiles automatically updated (symlinks point to new content)
# No manual sync required
```

## Troubleshooting

### Stow Conflicts

**Symptom**: Error during `just k setup` about existing files.

**Cause**: Existing dotfiles conflict with stow symlinks.

**Resolution**: Automatic. Conflicting files backed up to
`~/.config/kyldvs/k/backups/` with timestamp.

**Manual check**:

```bash
ls ~/.config/kyldvs/k/backups/
```

### Git Identity Not Switching

**Symptom**: Wrong identity used in repository.

**Cause**: Path doesn't match includeIf pattern, or git version too old.

**Check git version**:

```bash
git --version  # Must be >= 2.13
```

**Check includeIf directives**:

```bash
cat ~/.gitconfig | grep -A 2 includeIf
```

**Test identity**:

```bash
just k git-test ~/work/my-repo
```

**Resolution**: Ensure directory path matches configured profile path exactly.
includeIf requires trailing slash in path pattern.

### YAML Syntax Errors

**Symptom**: Error loading config file.

**Cause**: Invalid YAML syntax.

**Check syntax**:

```bash
yq eval '.' ~/.config/kyldvs/k/dotfiles.yml
```

**Resolution**: Fix YAML syntax errors. Common issues:
- Inconsistent indentation (use 2 spaces)
- Missing quotes around strings with special characters
- Incorrect list syntax (use `- item`)

### yq Not Installed

**Symptom**: Error about missing `yq` command.

**Resolution**:

```bash
# Via snap
sudo snap install yq

# Or download binary
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x yq_linux_amd64
sudo mv yq_linux_amd64 /usr/local/bin/yq
```

### Symlinks Broken After Moving Repository

**Symptom**: Dotfiles show as broken symlinks after moving repo.

**Cause**: Symlinks are absolute paths to repository location.

**Resolution**: Re-run setup in new location:

```bash
cd ~/new/repo/location
just k sync
```

### Package Installation Requires Password

**Symptom**: Prompted for sudo password during package installation.

**Cause**: Normal behavior - package installation requires sudo.

**Resolution**: Enter password. To avoid prompts, configure passwordless sudo
(already done if you used `bootstrap/vmroot.sh`).

## Comparison to Old System

**Before** (5 separate integration tasks):
- `integrate-zsh-settings.md`
- `integrate-tmux-config.md`
- `integrate-shell-integrations.md`
- `integrate-shell-aliases.md`
- `integrate-modern-cli-tools.md`

**After** (unified system):
- One command: `just k setup`
- Automatic updates via symlinks
- Declarative configuration
- Native git features

See [migration.md](migration.md) for migration guide.

## Testing

Tests validate all functionality via Docker Compose:

```bash
# Run dotfiles tests
just test dotfiles

# Or all tests
just test all
```

**Test coverage:**
- Fresh installation
- Idempotency (multiple runs)
- Git identity switching
- Package installation
- Conflict detection and backup
- YAML validation
- Sync after pull

## References

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Git includeIf Documentation](https://git-scm.com/docs/git-config#_includes)
- [yq YAML Processor](https://github.com/mikefarah/yq)
- [Configuration Schema Reference](configuration.md)
- [Migration Guide](migration.md)
