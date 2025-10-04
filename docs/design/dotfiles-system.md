# Dotfiles System

## Overview

A unified, declarative dotfiles management system using stow-based symbolic linking, YAML configuration, and git-native identity management. The system provides automatic environment configuration after VM bootstrap completes, replacing fragmented integration tasks with a single, maintainable approach.

## Architecture

### Phase Separation

**Bootstrap Phase** (existing system):
- VM provisioning, user creation, sudo/SSH setup
- Repository checkout to user home directory
- Ends when non-root user exists with repo

**Dotfiles Phase** (this system):
- Begins after bootstrap with user running `just k setup`
- Manages user environment configuration via symlinks
- Handles updates via git pull (automatic through symlinks)

### Component Structure

```
dotfiles/              # Stow-compatible dotfiles (repo root)
├── zsh/               # Stow package: zsh config
├── tmux/              # Stow package: tmux config
├── git/               # Stow package: git config
├── shell/             # Stow package: shell aliases
└── config/            # Example configurations

lib/dotfiles/          # Bash libraries
├── stow.sh            # Stow wrapper functions
├── config.sh          # YAML config loader
├── git-identity.sh    # Git identity management
└── packages.sh        # APT package installation

tasks/k/justfile       # User-facing just commands
```

### Data Flow

```
User: just k setup
  ↓
lib/dotfiles/config.sh: Load ~/.config/kyldvs/k/dotfiles.yml
  ↓
lib/dotfiles/stow.sh: Create symlinks (dotfiles/* → ~/)
  ↓
lib/dotfiles/git-identity.sh: Generate .gitconfig includeIf
  ↓
Complete: Environment ready
```

## Key Components

### Stow Linking System (lib/dotfiles/stow.sh)
- **Purpose**: Manages symbolic links from repo to home directory
- **Pattern**: Each subdirectory in `dotfiles/` is a "stow package"
- **Functionality**: Link, unlink, status check, conflict detection
- **Idempotency**: Checks existing symlinks before creating new ones
- **Conflict Handling**: Automatic backup to `~/.config/kyldvs/k/backups/`

### YAML Configuration (lib/dotfiles/config.sh)
- **Purpose**: Loads and validates user configuration
- **Location**: `~/.config/kyldvs/k/dotfiles.yml`
- **Parser**: yq (installed via binary for minimal dependencies)
- **Schema**: git_profiles, packages.apt, tools (reserved)
- **Validation**: Version check, YAML syntax, required fields
- **Fallback**: Creates from example if missing

### Git Identity Management (lib/dotfiles/git-identity.sh)
- **Purpose**: Directory-based git identity switching
- **Mechanism**: Native git includeIf directives (git >= 2.13)
- **Strategy**: Preserves existing .gitconfig, appends includeIf section
- **Profile Configs**: Generated in `~/.config/git/{name}.conf`
- **Safety**: Checks git version, validates paths, merges safely

### Package Management (lib/dotfiles/packages.sh)
- **Purpose**: Install APT packages from YAML config
- **Features**: Dry-run mode, conflict detection, logging
- **Installation Log**: `~/.config/kyldvs/k/installed-packages.log`
- **Privileges**: Uses sudo with password prompt

## Design Decisions

### Stow over Alternatives
- **Chosen**: GNU Stow for symlink management
- **Rationale**: Standard tool, simple model, reliable, widely available
- **Rejected**: yadm (too opinionated), chezmoi (too complex), custom scripts
- **Trade-off**: Requires stow dependency, but gains maturity and simplicity

### Multiple Stow Packages
- **Chosen**: Separate packages (zsh, tmux, git, shell)
- **Rationale**: Granular control, can selectively link/unlink
- **Alternative**: Single package with all dotfiles
- **Trade-off**: More directories, but more flexible

### Git includeIf (Native Feature)
- **Chosen**: Git's built-in includeIf directive
- **Rationale**: Git-native solution, no custom tooling needed
- **Alternative**: Custom script to modify git config
- **Trade-off**: Requires git >= 2.13, but gains native reliability

### YAML Configuration
- **Chosen**: YAML with yq parser
- **Rationale**: Human-readable, standard format, tooling available
- **Alternative**: JSON, TOML, or bash source files
- **Trade-off**: Requires yq binary, but gains readability and validation

### Automatic Conflict Backup
- **Chosen**: Automatic backup with logging
- **Rationale**: Safe default, preserves user data, non-interactive
- **Alternative**: Interactive prompts or abort on conflict
- **Trade-off**: May create unnecessary backups, but prevents data loss

## Implementation Patterns

### Function Naming Convention
All dotfiles functions use `df_` prefix:
- `df_stow_link()`, `df_stow_unlink()`, `df_stow_status()`
- `df_config_load()`, `df_config_validate()`
- `df_git_generate_includeif()`, `df_git_show_status()`
- `df_pkg_install_from_config()`, `df_pkg_show_status()`

### Bash Strict Mode
All library scripts use:
```bash
#!/usr/bin/env bash
set -euo pipefail
```

### Color Output
Consistent color scheme using readonly variables:
```bash
readonly KD_DF_RED='\033[0;31m'
readonly KD_DF_GREEN='\033[0;32m'
readonly KD_DF_YELLOW='\033[1;33m'
readonly KD_DF_BLUE='\033[0;34m'
readonly KD_DF_NC='\033[0m'
```

### Justfile Recipes
All recipes follow existing patterns:
- `[no-cd]` attribute (no directory changes)
- Silent by default (`@` prefix or `set fallback`)
- Bash recipes for complex logic (`#!/usr/bin/env bash`)
- Source libraries at start of recipe

## Integration Points

### Main Justfile
Imports k module: `mod k "tasks/k"`

### Test Infrastructure
- Docker Compose config: `src/tests/docker-compose.dotfiles.yml`
- Test runner: `src/tests/run-dotfiles.sh`
- Test script: `src/tests/tests/dotfiles.test.sh`
- Integration: `just test dotfiles` and `just test all`

### Bootstrap System
- Bootstrap ends when user exists with repo checked out
- Dotfiles begins after bootstrap (`just k setup`)
- Clear separation of concerns (system vs. user environment)

## Configuration

### YAML Schema (Version 1)

```yaml
version: 1

git_profiles:
  - name: personal          # Profile identifier
    path: ~/personal        # Directory path pattern
    user: "Name"            # Git user.name
    email: "email@host"     # Git user.email

packages:
  apt:                      # APT package list
    - package-name

tools: {}                   # Reserved for future use
```

### File Locations
- Config: `~/.config/kyldvs/k/dotfiles.yml`
- Backups: `~/.config/kyldvs/k/backups/`
- Install log: `~/.config/kyldvs/k/installed-packages.log`
- Git profiles: `~/.config/git/{name}.conf`

## Testing Approach

### Docker Compose Tests
- Ubuntu 22.04 base image
- Non-root test user with sudo
- Repository mounted to `/var/www/k`
- Comprehensive test coverage (9 test phases)

### Test Coverage
1. Fresh installation - verify `just k setup` works
2. Idempotency - run setup twice, same result
3. Git identity switching - validate includeIf directives
4. Package installation - test dry-run and actual install
5. Conflict detection - pre-existing file handling
6. YAML validation - invalid config error handling
7. Sync after pull - symlinks maintain repo link
8. Status commands - verify all status commands
9. Final state verification - all symlinks correct

### Assertion Helpers
Uses existing `/test-lib/assertions.sh`:
- `assert_file()` - verify file exists
- `assert_symlink()` - verify symlink target
- `assert_file_contains()` - verify content

## Future Considerations

### Potential Extensions (Not Currently Implemented)
- Multi-machine sync with per-machine configs
- Secret management integration
- Additional package managers (brew, npm, cargo)
- Shell prompt frameworks
- Editor configuration beyond basic dotfiles
- Plugin managers for zsh/tmux

### Extensibility Points
- `tools:` section in YAML schema reserved for future tool configs
- `.local` file support in dotfiles (e.g., `.zshrc.local`)
- Stow package model allows easy addition of new config types
- Library functions can be extended without breaking existing code

### Known Limitations
- Linux only (Debian/Ubuntu APT)
- Requires git >= 2.13 for includeIf
- Terminal/CLI configurations only (no GUI apps)
- System-level configuration belongs in bootstrap, not dotfiles

## References

- **GNU Stow**: https://www.gnu.org/software/stow/
- **Git includeIf**: https://git-scm.com/docs/git-config#_conditional_includes
- **yq**: https://github.com/mikefarah/yq
- **User Documentation**: docs/dotfiles/README.md
- **Configuration Reference**: docs/dotfiles/configuration.md
- **Migration Guide**: docs/dotfiles/migration.md
