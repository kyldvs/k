# Modern Dotfiles System - Specification

## Overview

A unified, declarative dotfiles management system that replaces fragmented integration tasks with stow-based symbolic linking, YAML configuration, and git-native identity management. The system provides automatic environment configuration after VM bootstrap completes, enabling seamless updates when pulling repository changes.

## Goals

- Replace 5+ fragmented integration tasks with a unified, maintainable dotfiles system
- Enable automatic environment updates when pulling repository changes (via symbolic links)
- Provide declarative YAML configuration for git profiles, packages, and tools
- Establish clear separation between bootstrap phase (VM setup) and dotfiles phase (user environment)
- Deliver simple, discoverable interface via `just k` commands

## Requirements

### Functional Requirements

- FR-1: Symbolic linking system using GNU Stow that links dotfiles from repository to home directory
- FR-2: YAML configuration file (`~/.config/kyldvs/k/dotfiles.yml`) for git profiles, APT packages, and tool configurations
- FR-3: Git identity management using native `.gitconfig` includeIf directives for directory-based identity switching
- FR-4: Just command interface providing `just k setup`, `just k sync`, and `just k install-packages`
- FR-5: Automatic environment updates when repository is pulled (symlinks point to new content)
- FR-6: Conflict detection and resolution for symbolic linking
- FR-7: Idempotent operations that can be run repeatedly without side effects
- FR-8: APT package installation from YAML-defined lists
- FR-9: Dotfiles for zsh, tmux, git, shell aliases, and modern CLI tools
- FR-10: Configuration validation on load with graceful handling of missing/malformed YAML

### Non-Functional Requirements

- NFR-1: Setup completes in <5 minutes on fresh system
- NFR-2: Zero manual intervention required after initial `just k setup`
- NFR-3: Test coverage >90% of code paths via Docker Compose tests
- NFR-4: All operations follow "less but better" principle (minimal complexity)
- NFR-5: Uses boring, standard technology (stow, git includeIf, YAML, bash)
- NFR-6: Documentation is complete, clear, and includes examples
- NFR-7: System requires zero ongoing maintenance after setup

### Technical Requirements

- GNU Stow for symbolic link management
- YAML parser (yq or equivalent) for configuration loading
- Bash scripts with strict mode (`set -euo pipefail`)
- Git 2.13+ for includeIf directive support
- Just task runner for command interface
- Docker Compose for testing environment
- APT package manager (Debian/Ubuntu systems)
- Follows existing justfile patterns (`[no-cd]`, silent by default)

## User Stories / Use Cases

### Initial Setup
- As a user who has completed VM bootstrap, I want to run `just k setup` once to configure my entire environment so that I can start working immediately
- As a user, I want the system to detect and resolve symlink conflicts so that I don't lose existing configurations

### Daily Usage
- As a user, I want to `git pull` and have my dotfiles automatically updated so that I don't need to run manual sync commands
- As a user, I want git to automatically use my work identity in `~/work/` directories and my personal identity in `~/personal/` directories so that commits are correctly attributed

### Configuration Management
- As a user, I want to define my package lists in YAML so that I can install all required tools with `just k install-packages`
- As a user, I want to modify my zsh configuration in the repository and see changes immediately in my shell so that configuration updates are instant

### Maintenance
- As a maintainer, I want to run the same setup command multiple times without side effects so that the system is easy to debug and maintain
- As a maintainer, I want comprehensive Docker tests that validate all functionality so that changes don't break existing features

## Success Criteria

- All 5 old integration tasks deleted: integrate-zsh-settings.md, integrate-tmux-config.md, integrate-shell-integrations.md, integrate-shell-aliases.md, integrate-modern-cli-tools.md
- Stow-based linking system successfully links dotfiles to home directory
- YAML configuration schema defined and documented with examples
- Git identity switching works via includeIf directives (tested with 2+ profiles)
- All `just k` commands functional and documented
- Docker Compose tests pass for: fresh install, idempotency, git identity, package installation, conflict detection, YAML validation, sync after pull
- Pulling repository automatically updates dotfiles (no manual commands required)
- CLAUDE.md and README.md updated with dotfiles system documentation
- Setup time <5 minutes on fresh Ubuntu system
- System works in post-bootstrap environment (user exists, repo checked out)

## Constraints

- Must work on Debian/Ubuntu systems (APT package manager)
- Must integrate with existing justfile module system
- Must follow existing bash scripting standards (strict mode, 80 char lines)
- Must work with git 2.13+ (includeIf directive requirement)
- Cannot modify bootstrap scripts (clear phase separation)
- Limited to terminal/CLI configurations (no GUI configs)
- Must use tools available in standard repositories (no exotic dependencies)

## Non-Goals

The following are explicitly out of scope:

- Plugin managers (oh-my-zsh, tpm, etc.) - keep minimal
- Complex abstractions or custom frameworks
- Non-terminal configurations (GUI apps, desktop environments)
- System-level configuration (belongs in bootstrap phase)
- Multi-machine sync with per-machine configs (future enhancement)
- Secret management integration (future enhancement)
- Editor configuration beyond basic dotfiles (future enhancement)
- Additional package managers (brew, npm, cargo) - future enhancement
- Shell prompt frameworks (powerlevel10k, starship) - future enhancement
- Modifications to bootstrap scripts
- Windows or macOS support (Linux only)

## Assumptions

- VM bootstrap phase completed successfully (non-root user exists with sudo, SSH configured, kyldvs/k repository checked out to user home)
- User has sudo privileges for package installation
- Internet connectivity available for package installation
- APT package manager is available and functional
- Git is already installed and configured (minimal config from bootstrap)
- Repository cloned to standard location (`~/kyldvs/k` or similar)
- User running on Debian/Ubuntu-based system
- GNU Stow available via APT (if not in bootstrap, added to package list)
- yq YAML parser available via APT or alternative installation method

## Open Questions

1. **YAML Parser Selection**: Should we use yq (snap/binary), Python (requires Python), Ruby (requires Ruby), or pure bash parsing (limited)? Recommendation: yq via snap or binary for minimal dependencies.

2. **Stow Package Organization**: Should dotfiles be organized as one large stow package or multiple smaller packages (zsh, tmux, git separate)? Recommendation: Multiple packages for granular control.

3. **Conflict Resolution Strategy**: Should conflicts be resolved interactively (prompts) or automatically (backup existing files)? Recommendation: Automatic backup with logging for initial version, interactive mode for future enhancement.

4. **Package Installation Privileges**: How should we handle sudo for package installation? Prompt for password, assume passwordless sudo, or require manual sudo? Recommendation: Use sudo with password prompt, document in setup.

5. **Git Identity Precedence**: What happens if user has existing `.gitconfig` with conflicting settings? Recommendation: Merge strategy that preserves existing config, append includeIf directives.

6. **Dotfiles Source**: Should we migrate content from `module/dotfiles/` or start fresh with minimal configs? Recommendation: Start minimal, selectively migrate useful pieces.

7. **Bootstrap Integration Point**: Should bootstrap install stow and yq, or should dotfiles system handle its own dependencies? Recommendation: Document as prerequisites, add to package list for `just k install-packages`.

8. **Directory Structure**: Should dotfiles live in `dotfiles/` at repo root or `module/dotfiles/`? Recommendation: `dotfiles/` at repo root for simplicity and clarity.

## Architecture Notes

### Phase Separation

**Bootstrap Phase** (existing system, not modified):
- VM provisioning, user creation, sudo/SSH setup
- Repository checkout to user home directory
- Ends when non-root user exists with repo

**Dotfiles Phase** (new system, this project):
- Begins after bootstrap with user running `just k setup`
- Manages user environment configuration
- Handles updates via git pull (automatic via symlinks)

### Directory Structure

```
kyldvs/k/
├── dotfiles/              # Stow-compatible dotfiles (NEW)
│   ├── zsh/
│   │   └── .zshrc
│   ├── tmux/
│   │   └── .tmux.conf
│   ├── git/
│   │   └── .gitconfig
│   └── ...
├── tasks/k/justfile       # Just k commands (NEW)
├── lib/dotfiles/          # Dotfiles libraries/utilities (NEW)
├── docs/
│   └── dotfiles/          # Dotfiles documentation (NEW)
└── src/tests/
    ├── tests/dotfiles.test.sh              # Dotfiles tests (NEW)
    └── docker-compose.dotfiles.yml         # Test setup (NEW)
```

### Configuration Schema (Minimal v1)

```yaml
# ~/.config/kyldvs/k/dotfiles.yml
version: 1

git_profiles:
  - name: personal
    path: ~/personal
    user: "Kyle Davis"
    email: "kyle@example.com"

  - name: work
    path: ~/work
    user: "Kyle Davis"
    email: "kyle@work.com"

packages:
  apt:
    - zsh
    - tmux
    - git
    - curl
    - neovim
    - ripgrep
    - fzf
    - stow

tools:
  # Reserved for future tool configurations
```

### Implementation Priorities

**Phase 1: Foundation** (Must-Have)
- Stow-based linking system
- Basic just commands (setup, sync)
- Minimal dotfiles (zsh, tmux, git)
- Basic Docker tests

**Phase 2: Configuration** (Must-Have)
- YAML configuration loading
- Git identity management via includeIf
- Package installation from YAML

**Phase 3: Polish** (Should-Have)
- Comprehensive tests (idempotency, conflicts, validation)
- Complete documentation
- Edge case handling
- Cleanup old integration tasks

## Related Principles

This project embodies these "Less but Better" principles:

- **#2 Good Code is Useful**: Solves real problem (fragmented environment configuration)
- **#4 Good Code is Understandable**: Declarative YAML + standard stow is obvious
- **#5 Good Code is Unobtrusive**: After setup, system disappears (automatic updates)
- **#6 Good Code is Honest**: Uses git-native features, no magic
- **#7 Good Code is Long-lasting**: Standard tools (stow, git) outlive frameworks
- **#10 As Little Code as Possible**: Replaces multiple tasks with unified minimal system
