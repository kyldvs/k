# Modern Dotfiles System

## Description

Implement a modern, declarative dotfiles system that replaces fragmented
integration tasks with a unified, maintainable approach. The system uses
stow-based symbolic linking, YAML configuration, and git-native identity
management to provide automatic environment configuration after VM bootstrap
completes.

## Current State

**Fragmented Approach:**
- Multiple integration tasks exist (integrate-zsh-settings.md, integrate-tmux-
  config.md, etc.)
- Each task handles one aspect of environment configuration
- Configuration embedded in bootstrap components
- No unified configuration file
- Manual commands required after pulling repo updates

**Bootstrap System:**
- Bootstrap phases end when non-root user exists with repo checked out
- No post-bootstrap dotfiles management
- Gap: pulling repo does not automatically update user environment

**Existing Files:**
- `module/dotfiles/` - cloned kyldvs/dotfiles repository
- Multiple `docs/tasks/integrate-*.md` - fragmented integration tasks
- Bootstrap components in `bootstrap/lib/steps/`

## Objective

Create a "less but better" dotfiles system that:

1. **Replaces fragmented tasks** with unified configuration
2. **Separates concerns** between bootstrap (VM setup) and dotfiles (user env)
3. **Enables automatic updates** via git pull without manual commands
4. **Uses declarative YAML** for all configuration (git profiles, packages,
   tools)
5. **Leverages boring technology** (stow, git includeIf, standard shell)
6. **Provides simple interface** via `just k ...` commands

## Scope

**Architecture:**
- Bootstrap phase: Ends when non-root user exists with `kyldvs/k` checked out
- Dotfiles phase: Begins after bootstrap, manages user environment
- Clear separation: Bootstrap = VM setup, Dotfiles = User configuration

**Core Components:**

1. **Symbolic Linking System** (stow-based)
   - Links dotfiles from repo to home directory
   - Automatic updates when repo pulled
   - Conflict detection and resolution

2. **YAML Configuration** (`~/.config/kyldvs/k/dotfiles.yml`)
   - Git profiles for directory-based identity switching
   - APT package lists
   - Tool configurations
   - Minimal, focused schema

3. **Git Identity Management**
   - Native `.gitconfig` includeIf directives
   - No custom tooling
   - Git-native solution for boring problem

4. **Just Command Interface** (`just k ...`)
   - `just k setup` - Initial dotfiles setup
   - `just k sync` - Sync after git pull
   - `just k install-packages` - Install from YAML package lists
   - User-facing, discoverable commands

**Configuration Coverage:**
- Zsh settings and configuration
- Tmux configuration
- Git identity management
- Shell aliases
- Modern CLI tools configuration
- APT package management
- Other standard terminal tools

**Out of Scope:**
- Plugin managers (keep minimal)
- Complex abstractions
- Non-terminal configurations
- System-level configuration (belongs in bootstrap)

## Success Criteria

- [ ] Stow-based linking system implemented and tested
- [ ] YAML configuration schema defined and documented
- [ ] Git identity management via includeIf working
- [ ] `just k ...` commands created and functional
- [ ] Docker Compose tests validate all functionality
- [ ] Pulling repo automatically updates dotfiles (via stow links)
- [ ] Old integration tasks deleted
- [ ] Documentation complete (README, CLAUDE.md updated)
- [ ] Idempotent operations (safe to run repeatedly)

## Subtasks

All subtasks prefixed with `df-` for dotfiles system:

### Phase 1: Research and Design

**df-research**
- Research modern dotfiles approaches (stow, yadm, chezmoi, etc.)
- Document tradeoffs and recommendation
- Focus on simplicity and maintainability
- Outcome: Design decision document

**df-yaml-schema**
- Design minimal YAML configuration schema
- Define structure for git profiles, packages, tools
- Follow "less but better" principle
- Outcome: Schema specification document

**df-cleanup-old-tasks**
- Delete obsolete integration task files:
  - `integrate-zsh-settings.md`
  - `integrate-tmux-config.md`
  - `integrate-shell-integrations.md`
  - `integrate-shell-aliases.md`
  - `integrate-modern-cli-tools.md`
- Remove related bootstrap components if no longer needed
- Document what was replaced and why
- Outcome: Clean task directory

### Phase 2: Core Implementation

**df-stow-linking**
- Implement stow-based symbolic linking system
- Handle dotfiles directory structure (e.g., `dotfiles/zsh/.zshrc`)
- Detect and resolve conflicts
- Support unstow/restow operations
- Outcome: Working linking system

**df-yaml-config**
- Implement YAML configuration loading
- Create example dotfiles.yml with sensible defaults
- Validate configuration on load
- Handle missing or malformed config gracefully
- Outcome: Configuration system working

**df-git-identity**
- Implement git identity management via includeIf
- Generate .gitconfig from YAML profiles
- Support directory-based identity switching
- Test with multiple profiles (work, personal, etc.)
- Outcome: Git identity switching working

**df-package-management**
- Implement APT package installation from YAML lists
- Handle package conflicts and missing packages
- Provide dry-run mode
- Log installation results
- Outcome: Package management working

### Phase 3: User Interface

**df-just-commands**
- Create `just k setup` - initial setup
- Create `just k sync` - sync after pull
- Create `just k install-packages` - install packages
- Add help text and documentation
- Follow existing justfile patterns
- Outcome: User commands functional

**df-dotfiles-content**
- Migrate useful configurations from module/dotfiles/
- Create minimal, curated dotfiles (zsh, tmux, git, etc.)
- Organize in stow-compatible directory structure
- Remove unnecessary complexity
- Outcome: Dotfiles ready for linking

### Phase 4: Testing and Documentation

**df-docker-tests**
- Create Docker Compose test setup
- Test dotfiles installation on fresh system
- Test idempotency (run twice, verify same result)
- Test git identity switching
- Test package installation
- Validate link conflicts handled correctly
- Outcome: Comprehensive test coverage

**df-documentation**
- Update CLAUDE.md with dotfiles system
- Update README with usage instructions
- Document YAML schema
- Add examples and common workflows
- Document relationship to bootstrap system
- Outcome: Complete documentation

## Implementation Notes

**YAML Configuration Example:**

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

tools:
  # Future: Additional tool configurations
```

**Directory Structure:**

```
kyldvs/k/
├── dotfiles/           # Stow-compatible dotfiles
│   ├── zsh/
│   │   └── .zshrc
│   ├── tmux/
│   │   └── .tmux.conf
│   ├── git/
│   │   └── .gitconfig
│   └── ...
├── tasks/k/justfile   # just k ... commands
└── docs/
    └── dotfiles/      # Dotfiles documentation
```

**Stow Usage:**

```bash
# Initial setup
stow -d /path/to/kyldvs/k/dotfiles -t ~ zsh tmux git

# After git pull, links automatically point to new content (no restow needed)

# To remove links
stow -D -d /path/to/kyldvs/k/dotfiles -t ~ zsh tmux git
```

**Git Identity with includeIf:**

```gitconfig
# ~/.gitconfig (generated from YAML)
[includeIf "gitdir:~/personal/"]
  path = ~/.config/git/personal.conf

[includeIf "gitdir:~/work/"]
  path = ~/.config/git/work.conf
```

**Just Commands Pattern:**

```just
# tasks/k/justfile
mod k

[no-cd]
@k-setup:
  echo "Setting up dotfiles..."
  # Implementation

[no-cd]
@k-sync:
  echo "Syncing dotfiles..."
  # Implementation
```

**Testing Strategy:**

```bash
# Docker Compose test
just test dotfiles

# Test structure similar to existing tests
src/tests/tests/dotfiles.test.sh
src/tests/docker-compose.dotfiles.yml
```

## Dependencies

**Prerequisites:**
- VM bootstrap complete (user exists, repo checked out)
- Stow installed (add to bootstrap or package list)
- YAML parser (yq or equivalent)

**Blocks:**
- No blocking dependencies
- Can be implemented independently
- Replaces but does not depend on integration tasks

**Related:**
- Bootstrap system (separate phase)
- Existing integration tasks (will be replaced)

## Related Files

**To Be Created:**
- `dotfiles/` - Stow-compatible dotfiles directory
- `tasks/k/justfile` - Just commands for dotfiles
- `docs/dotfiles/` - Dotfiles documentation
- `src/tests/tests/dotfiles.test.sh` - Tests
- `src/tests/docker-compose.dotfiles.yml` - Test setup

**To Be Modified:**
- `CLAUDE.md` - Add dotfiles system documentation
- `README.md` - Add usage instructions
- `justfile` - Import k module

**To Be Deleted:**
- `docs/tasks/integrate-zsh-settings.md`
- `docs/tasks/integrate-tmux-config.md`
- `docs/tasks/integrate-shell-integrations.md`
- `docs/tasks/integrate-shell-aliases.md`
- `docs/tasks/integrate-modern-cli-tools.md`
- `docs/tasks/cleanup-dotfiles-exploration.md` (replaced by this)
- Potentially `module/dotfiles/` after migration complete

## Priority

**High** - Consolidates fragmented work into coherent system. Unblocks user
environment configuration and establishes foundation for future improvements.
High value-to-complexity ratio.

## Estimated Effort

**Total: 16-20 hours**

Breakdown by phase:
- Research and Design: 3-4 hours
- Core Implementation: 6-8 hours
- User Interface: 2-3 hours
- Testing and Documentation: 5-6 hours

Phased approach allows incremental progress and early validation.

## Related Principles

- **#1 Good Code is Innovative**: Solves environment configuration problem in
  new way for this repo
- **#2 Good Code is Useful**: Directly solves real problem (environment setup
  and maintenance)
- **#4 Good Code is Understandable**: Declarative YAML + stow is clear and
  obvious
- **#5 Good Code is Unobtrusive**: After setup, system fades into background
  (automatic updates)
- **#6 Good Code is Honest**: Git-native includeIf does exactly what it says
- **#7 Good Code is Long-lasting**: Standard tools (stow, git) outlive custom
  frameworks
- **#10 As Little Code as Possible**: Replaces multiple fragmented tasks with
  unified minimal system

## Value Proposition

**Solves Real Problems:**
- Environment configuration currently manual and fragmented
- No automatic updates when pulling repo changes
- Multiple integration tasks create cognitive overhead
- Git identity management handled inconsistently

**Minimal Complexity:**
- Stow: standard, well-understood tool
- YAML: simple, human-readable configuration
- Git includeIf: native git feature, no custom code
- Just commands: consistent with existing patterns

**Consistent Environment:**
- Pulling repo automatically updates dotfiles (via symlinks)
- Single source of truth for configuration
- Predictable, repeatable setup
- Works across all environments (Termux, VM, local)

**Maintainable Long-term:**
- Standard tools survive trends
- Clear separation of concerns (bootstrap vs dotfiles)
- Easy to understand and modify
- Self-documenting via YAML configuration

## Bootstrap Integration

**Clear Phase Separation:**

Bootstrap Phase (Current):
- VM provisioning (vmroot.sh)
- User creation with sudo/SSH
- Repo checkout to user home directory
- Ends here

Dotfiles Phase (New):
- User runs `just k setup` (one-time)
- Stow links dotfiles from repo to home
- Future pulls automatically update environment
- User configuration, not system setup

**Workflow:**

```bash
# 1. Bootstrap VM (run as root)
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot.sh | sh

# 2. Login as user (bootstrap created this user)
ssh user@vm

# 3. Setup dotfiles (one-time, user runs this)
just k setup

# 4. Future updates (automatic via stow symlinks)
git pull  # Dotfiles automatically updated through symlinks
```

## Testing Approach

**Docker Compose Tests:**

Follow existing test patterns:
- Fresh container simulates new environment
- Mount repo into container
- Run dotfiles setup
- Assert files linked correctly
- Assert git identity switching works
- Assert package installation succeeds
- Test idempotency (run twice, same result)

**Test Cases:**

1. Fresh installation
2. Idempotent operations (run setup twice)
3. Git identity switching (multiple profiles)
4. Package installation (handle missing packages)
5. Link conflict detection
6. Configuration validation (malformed YAML)
7. Sync after git pull

**Integration with Existing Tests:**

```bash
just test all         # Runs all tests (mobile, vmroot, dotfiles)
just test dotfiles    # Run only dotfiles tests
just test clean       # Cleanup
```

## Incremental Implementation

**Phase 1: Foundation (4-6 hours)**
- Research modern approaches
- Design YAML schema
- Delete old integration tasks
- Basic stow implementation

**Phase 2: Core Features (6-8 hours)**
- YAML configuration loading
- Git identity management
- Package management
- Dotfiles content migration

**Phase 3: Polish (6-8 hours)**
- Just commands
- Docker tests
- Documentation
- Edge case handling

Each phase delivers incremental value. Early phases can be used even before
complete implementation. Allows validation and course correction.

## Future Enhancements

**Not in Initial Scope** (document for future consideration):

- Multi-machine sync (different configs per machine)
- Secret management integration (Doppler, etc.)
- Plugin manager integration (if justified)
- Shell prompt configuration (powerlevel10k, starship, etc.)
- Editor configuration (neovim, vim, etc.)
- Additional package managers (brew, npm, cargo, etc.)

These should only be added if they solve real problems and earn their
complexity. Default: keep minimal.

## Questions to Resolve During Implementation

1. **Stow vs Alternatives**: Validate stow is best choice (vs yadm, chezmoi)
2. **YAML Parser**: Which tool? (yq, python, ruby)
3. **Conflict Resolution**: Interactive or automatic?
4. **Package Installation**: Sudo required? How to handle?
5. **Dotfiles Organization**: Flat or nested stow packages?
6. **Git Identity**: Additional includeIf patterns needed?

Document answers in design decision log as implementation progresses.

## Success Metrics

**Qualitative:**
- User can setup environment with single command
- Pulling repo updates dotfiles automatically
- Configuration clearly documented and understandable
- System requires no ongoing maintenance

**Quantitative:**
- Old integration tasks deleted (5 tasks)
- Test coverage >90% of code paths
- Setup time <5 minutes on fresh system
- Documentation complete (schema, usage, examples)

## Related Tasks

**Replaces:**
- integrate-zsh-settings.md
- integrate-tmux-config.md
- integrate-shell-integrations.md
- integrate-shell-aliases.md
- integrate-modern-cli-tools.md
- cleanup-dotfiles-exploration.md

**Related:**
- vm-user-bootstrap.md - Bootstrap phase ends, dotfiles begins
- bootstrap-error-recovery.md - Error handling patterns

**Future:**
- CI integration - Test dotfiles setup in CI
- Documentation improvements - Keep docs current
