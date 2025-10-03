# Modern Dotfiles System - Implementation Plan

## Prerequisites

**Required Dependencies:**
- GNU Stow (via APT)
- yq YAML parser (via binary or snap)
- Git 2.13+ (already installed from bootstrap)
- Bash 4.0+
- Just task runner (already installed)

**Environment Setup:**
- User must have completed VM bootstrap (non-root user with sudo)
- Repository checked out to `~/kyldvs/k` or similar
- Internet connectivity for package installation

**Prerequisite Knowledge:**
- Existing justfile module system
- Docker Compose test patterns
- Bootstrap component architecture
- Bash scripting with strict mode

## Architecture Overview

The dotfiles system integrates into the existing codebase as a post-bootstrap user environment management layer:

**Key Components:**
1. **Dotfiles Directory** (`dotfiles/`) - Stow-compatible directory structure at repo root
2. **Just Module** (`tasks/k/justfile`) - User-facing commands for setup/sync/packages
3. **Lib Directory** (`lib/dotfiles/`) - Bash libraries for core functionality
4. **Test Suite** (`src/tests/`) - Docker Compose tests following existing patterns

**Data Flow:**
```
User runs: just k setup
  ↓
Load config: ~/.config/kyldvs/k/dotfiles.yml
  ↓
Stow links: dotfiles/* → ~/ (symlinks)
  ↓
Generate: ~/.gitconfig includeIf directives
  ↓
Complete: Environment ready
```

**Integration Points:**
- Main `justfile` imports new `k` module via `mod k "tasks/k"`
- Test runner `tasks/test/justfile` adds dotfiles test target
- Follows existing patterns: `[no-cd]`, silent execution, strict mode bash

## Task Breakdown

### Phase 1: Foundation (Core Infrastructure)

- [ ] **Task 1.1: Create dotfiles directory structure**
  - Files: `dotfiles/`, `dotfiles/zsh/`, `dotfiles/tmux/`, `dotfiles/git/`
  - Dependencies: None
  - Details: Stow-compatible structure where each subdirectory is a "package"
  - Implementation: Create minimal directory tree, one package per config type

- [ ] **Task 1.2: Create minimal zsh dotfiles**
  - Files: `dotfiles/zsh/.zshrc`, `dotfiles/zsh/.zshenv`
  - Dependencies: Task 1.1
  - Details: Minimal, curated zsh config without plugins or frameworks
  - Implementation: Basic config with history, completion, vi mode

- [ ] **Task 1.3: Create minimal tmux dotfiles**
  - Files: `dotfiles/tmux/.tmux.conf`
  - Dependencies: Task 1.1
  - Details: Minimal tmux config with sensible defaults
  - Implementation: Basic keybindings, status line, mouse support

- [ ] **Task 1.4: Create git dotfiles stub**
  - Files: `dotfiles/git/.gitconfig`
  - Dependencies: Task 1.1
  - Details: Basic gitconfig with common settings (not includeIf yet)
  - Implementation: Core git settings (editor, colors, aliases)

- [ ] **Task 1.5: Create shell aliases dotfiles**
  - Files: `dotfiles/shell/.bash_aliases`, `dotfiles/shell/.zsh_aliases`
  - Dependencies: Task 1.1
  - Details: Common shell aliases for ls, grep, etc.
  - Implementation: Curated list of useful, non-opinionated aliases

### Phase 2: Stow Linking System

- [ ] **Task 2.1: Create stow wrapper library**
  - Files: `lib/dotfiles/stow.sh`
  - Dependencies: None
  - Details: Bash functions for stow operations (link, unlink, check conflicts)
  - Implementation: Functions: `df_stow_link()`, `df_stow_unlink()`, `df_stow_status()`

- [ ] **Task 2.2: Implement conflict detection**
  - Files: `lib/dotfiles/stow.sh` (extend)
  - Dependencies: Task 2.1
  - Details: Check for existing files before stowing, offer backup
  - Implementation: Function `df_check_conflicts()` returns list of conflicts

- [ ] **Task 2.3: Implement automatic backup on conflict**
  - Files: `lib/dotfiles/stow.sh` (extend)
  - Dependencies: Task 2.2
  - Details: Backup existing files to `~/.config/kyldvs/k/backups/`
  - Implementation: Function `df_backup_file()` creates timestamped backups

- [ ] **Task 2.4: Implement idempotency checks**
  - Files: `lib/dotfiles/stow.sh` (extend)
  - Dependencies: Task 2.1
  - Details: Detect if already stowed, skip if no changes needed
  - Implementation: Check if symlink already points to correct target

### Phase 3: YAML Configuration System

- [ ] **Task 3.1: Research and select YAML parser**
  - Files: None (research task)
  - Dependencies: None
  - Details: Evaluate yq binary, snap, or bash alternatives; choose minimal option
  - Decision: Document in `docs/plan/df-modern-dotfiles/decisions.md`

- [ ] **Task 3.2: Create YAML config loader library**
  - Files: `lib/dotfiles/config.sh`
  - Dependencies: Task 3.1
  - Details: Load and parse `~/.config/kyldvs/k/dotfiles.yml`
  - Implementation: Functions: `df_load_config()`, `df_get_git_profiles()`, `df_get_packages()`

- [ ] **Task 3.3: Create example dotfiles.yml**
  - Files: `dotfiles/config/dotfiles.yml.example`
  - Dependencies: None
  - Details: Example config with git profiles, packages, tools
  - Implementation: Well-commented example following spec schema

- [ ] **Task 3.4: Implement config validation**
  - Files: `lib/dotfiles/config.sh` (extend)
  - Dependencies: Task 3.2
  - Details: Validate YAML structure, check required fields, version
  - Implementation: Function `df_validate_config()` returns errors/warnings

- [ ] **Task 3.5: Implement graceful fallback for missing config**
  - Files: `lib/dotfiles/config.sh` (extend)
  - Dependencies: Task 3.2
  - Details: Use sensible defaults if config doesn't exist
  - Implementation: Default config in-memory, copy example on first run

### Phase 4: Git Identity Management

- [ ] **Task 4.1: Create git identity library**
  - Files: `lib/dotfiles/git-identity.sh`
  - Dependencies: Task 3.2
  - Details: Generate .gitconfig includeIf directives from YAML
  - Implementation: Functions: `df_generate_gitconfig()`, `df_generate_profile_config()`

- [ ] **Task 4.2: Implement includeIf directive generation**
  - Files: `lib/dotfiles/git-identity.sh` (extend)
  - Dependencies: Task 4.1
  - Details: Create `~/.gitconfig` with includeIf for each profile path
  - Implementation: Template-based generation, append to existing .gitconfig

- [ ] **Task 4.3: Generate per-profile git configs**
  - Files: `lib/dotfiles/git-identity.sh` (extend)
  - Dependencies: Task 4.1
  - Details: Create `~/.config/git/{profile}.conf` for each profile
  - Implementation: Each config has user.name, user.email from YAML

- [ ] **Task 4.4: Implement merge strategy for existing .gitconfig**
  - Files: `lib/dotfiles/git-identity.sh` (extend)
  - Dependencies: Task 4.2
  - Details: Preserve user's existing .gitconfig, append includeIf section
  - Implementation: Parse existing config, check for conflicts, merge safely

### Phase 5: Package Management

- [ ] **Task 5.1: Create package management library**
  - Files: `lib/dotfiles/packages.sh`
  - Dependencies: Task 3.2
  - Details: Install APT packages from YAML config
  - Implementation: Functions: `df_install_packages()`, `df_check_package_installed()`

- [ ] **Task 5.2: Implement dry-run mode**
  - Files: `lib/dotfiles/packages.sh` (extend)
  - Dependencies: Task 5.1
  - Details: Show what would be installed without actually installing
  - Implementation: Flag to skip apt install, just echo package names

- [ ] **Task 5.3: Implement package conflict detection**
  - Files: `lib/dotfiles/packages.sh` (extend)
  - Dependencies: Task 5.1
  - Details: Check if package exists in APT, warn on missing
  - Implementation: `apt-cache search` or `apt-cache show` to verify

- [ ] **Task 5.4: Add installation logging**
  - Files: `lib/dotfiles/packages.sh` (extend)
  - Dependencies: Task 5.1
  - Details: Log installed packages to `~/.config/kyldvs/k/installed-packages.log`
  - Implementation: Append package name and timestamp to log file

### Phase 6: Just Command Interface

- [ ] **Task 6.1: Create k module justfile**
  - Files: `tasks/k/justfile`
  - Dependencies: None
  - Details: New just module with user-facing commands
  - Implementation: Follow existing module pattern, `[no-cd]`, silent default

- [ ] **Task 6.2: Implement 'just k setup' command**
  - Files: `tasks/k/justfile` (extend)
  - Dependencies: Tasks 2.1, 3.2, 4.1
  - Details: Initial dotfiles setup (stow, config, git identity)
  - Implementation: Call libraries in sequence, check prerequisites

- [ ] **Task 6.3: Implement 'just k sync' command**
  - Files: `tasks/k/justfile` (extend)
  - Dependencies: Task 2.1
  - Details: Re-stow dotfiles (for manual sync if needed)
  - Implementation: Call `df_stow_link()` for all packages

- [ ] **Task 6.4: Implement 'just k install-packages' command**
  - Files: `tasks/k/justfile` (extend)
  - Dependencies: Task 5.1
  - Details: Install packages from YAML config
  - Implementation: Call `df_install_packages()`, handle sudo prompt

- [ ] **Task 6.5: Implement 'just k status' command**
  - Files: `tasks/k/justfile` (extend)
  - Dependencies: Tasks 2.1, 3.2
  - Details: Show dotfiles status (linked packages, config loaded)
  - Implementation: Call `df_stow_status()`, show config summary

- [ ] **Task 6.6: Add help text to k commands**
  - Files: `tasks/k/justfile` (extend)
  - Dependencies: Tasks 6.2-6.5
  - Details: Document each command with description attribute
  - Implementation: Add `@doc` or comments for `just --list` output

- [ ] **Task 6.7: Import k module in main justfile**
  - Files: `justfile`
  - Dependencies: Task 6.1
  - Details: Add `mod k "tasks/k"` to main justfile imports
  - Implementation: Add line after existing `mod` declarations

### Phase 7: Testing Infrastructure

- [ ] **Task 7.1: Create Docker Compose test file**
  - Files: `src/tests/docker-compose.dotfiles.yml`
  - Dependencies: None
  - Details: Docker Compose config for dotfiles testing
  - Implementation: Follow vmroot.yml pattern, mount repo and test lib

- [ ] **Task 7.2: Create test Docker image**
  - Files: `src/tests/images/dotfiles/Dockerfile`
  - Dependencies: None
  - Details: Ubuntu-based image with git, stow, yq installed
  - Implementation: Minimal image, install prerequisites

- [ ] **Task 7.3: Create dotfiles test script**
  - Files: `src/tests/tests/dotfiles.test.sh`
  - Dependencies: Task 7.2
  - Details: Main test script following vmroot.test.sh pattern
  - Implementation: Source assertions.sh, test all functionality

- [ ] **Task 7.4: Create test runner script**
  - Files: `src/tests/run-dotfiles.sh`
  - Dependencies: Tasks 7.1, 7.3
  - Details: Runner script that executes Docker Compose test
  - Implementation: Follow run-vmroot.sh pattern

- [ ] **Task 7.5: Add dotfiles target to test justfile**
  - Files: `tasks/test/justfile`
  - Dependencies: Task 7.4
  - Details: Add `dotfiles` recipe, update `all` recipe
  - Implementation: Call run-dotfiles.sh, add cleanup to clean recipe

### Phase 8: Core Test Cases

- [ ] **Task 8.1: Test fresh installation**
  - Files: `src/tests/tests/dotfiles.test.sh` (extend)
  - Dependencies: Task 7.3
  - Details: Run setup on clean system, verify all links created
  - Implementation: Assert symlinks exist, point to repo files

- [ ] **Task 8.2: Test idempotency**
  - Files: `src/tests/tests/dotfiles.test.sh` (extend)
  - Dependencies: Task 8.1
  - Details: Run setup twice, verify no errors, same result
  - Implementation: Run setup, capture state, run again, compare state

- [ ] **Task 8.3: Test git identity switching**
  - Files: `src/tests/tests/dotfiles.test.sh` (extend)
  - Dependencies: Task 4.1
  - Details: Create test git repos in profile paths, verify identity
  - Implementation: mkdir ~/work, ~/personal, check git config in each

- [ ] **Task 8.4: Test package installation**
  - Files: `src/tests/tests/dotfiles.test.sh` (extend)
  - Dependencies: Task 5.1
  - Details: Run install-packages, verify packages installed
  - Implementation: Check `dpkg -l` or `which` for installed tools

- [ ] **Task 8.5: Test conflict detection**
  - Files: `src/tests/tests/dotfiles.test.sh` (extend)
  - Dependencies: Task 2.2
  - Details: Create conflicting file, run setup, verify backup created
  - Implementation: touch ~/.zshrc, run setup, check backup exists

- [ ] **Task 8.6: Test YAML validation**
  - Files: `src/tests/tests/dotfiles.test.sh` (extend)
  - Dependencies: Task 3.4
  - Details: Test with malformed YAML, verify error handling
  - Implementation: Create invalid config, run setup, expect graceful failure

- [ ] **Task 8.7: Test sync after pull**
  - Files: `src/tests/tests/dotfiles.test.sh` (extend)
  - Dependencies: Task 8.1
  - Details: Modify dotfile in repo, verify change visible in home
  - Implementation: Stow, change repo file, check home file content matches

### Phase 9: Documentation

- [ ] **Task 9.1: Create dotfiles documentation directory**
  - Files: `docs/dotfiles/README.md`
  - Dependencies: None
  - Details: Document dotfiles system architecture and usage
  - Implementation: Architecture, commands, config schema, examples

- [ ] **Task 9.2: Document YAML configuration schema**
  - Files: `docs/dotfiles/configuration.md`
  - Dependencies: Task 3.2
  - Details: Complete YAML schema reference with examples
  - Implementation: Document each field, types, defaults, examples

- [ ] **Task 9.3: Update main CLAUDE.md**
  - Files: `CLAUDE.md`
  - Dependencies: Tasks 6.2-6.5
  - Details: Add dotfiles system section to CLAUDE.md
  - Implementation: Document k commands, architecture, testing

- [ ] **Task 9.4: Update main README.md**
  - Files: `README.md`
  - Dependencies: Tasks 6.2-6.5
  - Details: Add dotfiles usage to README
  - Implementation: Quick start section, link to detailed docs

- [ ] **Task 9.5: Create migration guide**
  - Files: `docs/dotfiles/migration.md`
  - Dependencies: None
  - Details: Guide for migrating from old integration tasks
  - Implementation: Explain what changed, how to migrate existing configs

### Phase 10: Cleanup and Polish

- [ ] **Task 10.1: Delete old integration task files**
  - Files: Delete `docs/tasks/integrate-zsh-settings.md`, `integrate-tmux-config.md`, `integrate-shell-integrations.md`, `integrate-shell-aliases.md`, `integrate-modern-cli-tools.md`
  - Dependencies: Tasks 6.2-6.5 (new system functional)
  - Details: Remove obsolete integration task documentation
  - Implementation: Git rm old task files

- [ ] **Task 10.2: Delete cleanup-dotfiles-exploration.md**
  - Files: Delete `docs/tasks/cleanup-dotfiles-exploration.md`
  - Dependencies: Task 10.1
  - Details: Remove exploration task replaced by this project
  - Implementation: Git rm exploration task file

- [ ] **Task 10.3: Add error handling to all libraries**
  - Files: All `lib/dotfiles/*.sh` files
  - Dependencies: Phase 2-5 complete
  - Details: Consistent error handling, meaningful error messages
  - Implementation: Check return codes, provide helpful errors

- [ ] **Task 10.4: Add comprehensive logging**
  - Files: All `lib/dotfiles/*.sh` files
  - Dependencies: Phase 2-5 complete
  - Details: Log all operations to `~/.config/kyldvs/k/dotfiles.log`
  - Implementation: Timestamp, operation, success/failure

- [ ] **Task 10.5: Performance optimization**
  - Files: All library files
  - Dependencies: All tests passing
  - Details: Ensure setup completes in <5 minutes
  - Implementation: Profile slow operations, optimize if needed

- [ ] **Task 10.6: Final integration testing**
  - Files: Test suite
  - Dependencies: All phases complete
  - Details: Run full test suite, verify >90% coverage
  - Implementation: Run `just test all`, fix any failures

## Files to Create

**Dotfiles:**
- `dotfiles/zsh/.zshrc` - Zsh configuration
- `dotfiles/zsh/.zshenv` - Zsh environment variables
- `dotfiles/tmux/.tmux.conf` - Tmux configuration
- `dotfiles/git/.gitconfig` - Git configuration (base)
- `dotfiles/shell/.bash_aliases` - Bash aliases
- `dotfiles/shell/.zsh_aliases` - Zsh aliases
- `dotfiles/config/dotfiles.yml.example` - Example YAML config

**Libraries:**
- `lib/dotfiles/stow.sh` - Stow wrapper functions
- `lib/dotfiles/config.sh` - YAML config loader
- `lib/dotfiles/git-identity.sh` - Git identity management
- `lib/dotfiles/packages.sh` - Package installation

**Just Commands:**
- `tasks/k/justfile` - User-facing k commands module

**Tests:**
- `src/tests/docker-compose.dotfiles.yml` - Test Docker Compose config
- `src/tests/images/dotfiles/Dockerfile` - Test Docker image
- `src/tests/tests/dotfiles.test.sh` - Test cases
- `src/tests/run-dotfiles.sh` - Test runner script

**Documentation:**
- `docs/dotfiles/README.md` - Main dotfiles documentation
- `docs/dotfiles/configuration.md` - YAML schema reference
- `docs/dotfiles/migration.md` - Migration guide
- `docs/plan/df-modern-dotfiles/decisions.md` - Design decisions

## Files to Modify

- `justfile` - Import k module
- `tasks/test/justfile` - Add dotfiles test target
- `CLAUDE.md` - Document dotfiles system
- `README.md` - Add dotfiles usage section

## Files to Delete

- `docs/tasks/integrate-zsh-settings.md`
- `docs/tasks/integrate-tmux-config.md`
- `docs/tasks/integrate-shell-integrations.md`
- `docs/tasks/integrate-shell-aliases.md`
- `docs/tasks/integrate-modern-cli-tools.md`
- `docs/tasks/cleanup-dotfiles-exploration.md`

## Testing Strategy

**Docker Compose Tests:**
Follow existing test patterns (vmroot, mobile):
- Fresh Ubuntu container
- Mount repository to `/var/www/k`
- Mount test lib and fixtures
- Run test script that executes setup commands
- Assert expected state

**Test Coverage:**
1. **Fresh Install**: Clean system → run setup → verify links
2. **Idempotency**: Run setup twice → same result
3. **Git Identity**: Create repos in profile paths → verify identity
4. **Package Install**: Run install-packages → verify installed
5. **Conflicts**: Pre-existing files → verify backup created
6. **YAML Validation**: Invalid config → graceful error
7. **Sync**: Modify repo → verify home updated

**Manual Verification:**
1. Run `just k setup` on fresh VM
2. Check `~/.zshrc` is symlink to repo
3. Create `~/work/test-repo`, check `git config user.email`
4. Modify repo zshrc, check home zshrc changed
5. Run `just k install-packages`, verify tools installed

**Performance Testing:**
- Time `just k setup` on fresh Ubuntu system
- Target: <5 minutes including package installation
- Profile with `time` command, optimize bottlenecks

## Risk Assessment

**Risk 1: YAML Parser Dependency**
- Description: yq may not be available in APT, requiring snap or binary download
- Mitigation: Add yq installation to package list, provide manual install instructions
- Severity: Medium
- Likelihood: Low

**Risk 2: Stow Conflicts with Existing Files**
- Description: Users may have existing dotfiles that conflict with stow links
- Mitigation: Implement automatic backup, provide clear conflict messages
- Severity: High
- Likelihood: High

**Risk 3: Git Identity Not Switching**
- Description: includeIf may not work due to git version, path issues, or config conflicts
- Mitigation: Validate git version ≥2.13, test path patterns, clear error messages
- Severity: Medium
- Likelihood: Medium

**Risk 4: Package Installation Requires Sudo**
- Description: Users may not have passwordless sudo, causing interactive prompt
- Mitigation: Document sudo requirement, handle password prompt gracefully
- Severity: Low
- Likelihood: High

**Risk 5: Test Environment Differs from Real System**
- Description: Docker tests may pass but real VM setup fails
- Mitigation: Keep test image close to real Ubuntu, manual testing on actual VM
- Severity: Medium
- Likelihood: Low

**Risk 6: Symlinks Break on Git Operations**
- Description: Git operations might affect symlinked dotfiles
- Mitigation: Document that repo dotfiles shouldn't be edited in home dir
- Severity: Low
- Likelihood: Low

## Implementation Sequence

**Week 1: Foundation (Phases 1-2)**
- Create dotfiles directory and content
- Implement stow wrapper library
- Basic linking functionality working

**Week 2: Configuration (Phases 3-4)**
- YAML config loading
- Git identity management
- Package installation

**Week 3: Interface & Testing (Phases 5-7)**
- Just commands
- Docker test infrastructure
- Core test cases

**Week 4: Polish (Phases 8-10)**
- Comprehensive testing
- Documentation
- Cleanup old files
- Final integration testing

## Success Metrics

**Qualitative:**
- ✅ User can run `just k setup` once and have complete environment
- ✅ Pulling repo updates dotfiles automatically (via symlinks)
- ✅ Clear, comprehensive documentation
- ✅ System requires no ongoing maintenance

**Quantitative:**
- ✅ 5 old integration tasks deleted
- ✅ Test coverage >90%
- ✅ Setup time <5 minutes
- ✅ All test cases passing
- ✅ CLAUDE.md and README.md updated

## Notes

**Parallel Work Opportunities:**
- Phases 1-2 (foundation) can proceed independently
- Phases 3-5 (config, git, packages) can be parallelized after foundation complete
- Documentation (Phase 9) can be written in parallel with implementation

**Pattern Adherence:**
- All bash scripts use strict mode: `set -euo pipefail`
- All justfile recipes use `[no-cd]` attribute
- Follow 80 character line limit
- Silent execution by default (@ prefix in recipes)
- Consistent function naming: `df_` prefix for all dotfiles functions

**Design Decisions to Document:**
- YAML parser choice (yq vs alternatives)
- Stow package organization (multiple packages vs single)
- Conflict resolution strategy (automatic backup vs interactive)
- Git identity merge strategy (append vs replace)

**Future Enhancements (Not in Scope):**
- Multi-machine sync
- Secret management integration
- Plugin managers
- Additional package managers (brew, npm, cargo)
- Shell prompt frameworks
- Editor configuration

These should only be added if they solve real problems and earn their complexity.
