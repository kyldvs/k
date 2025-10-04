# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Repository Info

- Name: `kyldvs/k`
- Desc: kyldvs dotfiles and machine setup

# Principles

## Less but Better

Software engineering principles inspired by Dieter Rams' design philosophy: "Weniger, aber besser" (Less, but better).

Good design is not about adding features—it's about removing everything that doesn't serve a purpose. Every line of code is a liability. Every abstraction is a cost. The best solution is the one that solves the problem with the least complexity.

### 1. Good Code is Innovative

Innovation means solving problems in new ways, not using new technology for its own sake.

- Choose boring technology for boring problems
- Innovate only where it creates clear value
- Let constraints drive creative solutions
- Question "the way we've always done it"
- Measure innovation by outcomes, not novelty

### 2. Good Code is Useful

Code exists to solve problems. If it doesn't make the product more useful, it doesn't belong.

- Solve real problems, not imagined ones
- Build what users need, not what you want to build
- Validate assumptions before implementing
- Delete features that aren't used
- Optimize for the common case

### 3. Good Code is Aesthetic

Code is read far more than written. Aesthetic code is pleasant to read and reveals its intent.

- Consistent formatting and naming
- Symmetry and patterns over exceptions
- Whitespace and structure aid comprehension
- Beauty emerges from constraint, not decoration
- If it looks wrong, it probably is wrong

### 4. Good Code is Understandable

Clarity is not optional. Code should be obvious at a glance.

- Names reveal intent and domain concepts
- Functions do one thing at the right level of abstraction
- Control flow is linear and predictable
- Clever is the enemy of clear
- Complexity should be unavoidable, not accidental

### 5. Good Code is Unobtrusive

Good abstractions fade into the background, letting you focus on the problem domain.

- Don't force users to learn your framework
- Convention over configuration
- Sensible defaults for 90% of cases
- Power for the 10% who need it
- Infrastructure should be invisible when it works

### 6. Good Code is Honest

Code should be exactly what it appears to be. No surprises, no hidden behavior.

- Functions do what their names say
- Types reflect actual constraints
- Errors surface immediately, not later
- No action at a distance
- Performance characteristics match intuition

### 7. Good Code is Long-lasting

Code should age gracefully. Write for maintainers, not just for now.

- Dependencies are minimized and justified
- Standards outlive frameworks
- Fundamental patterns over temporary trends
- Documentation explains why, not what
- Backwards compatibility is a feature

### 8. Good Code is Thorough

Quality is in the details. Incomplete work creates friction for everyone who follows.

- Handle edge cases explicitly
- Validate inputs, assert invariants
- Test behavior, not implementation
- Logging for debugging, metrics for monitoring
- Every detail serves a purpose

### 9. Good Code is Sustainable

Software development is a marathon. Optimize for the long term.

- Technical debt is tracked and addressed
- Build time is a feature
- Cognitive load is minimized
- Energy and resources are conserved
- Team happiness enables sustainability

### 10. Good Code is as Little Code as Possible

The best code is no code. The second best is less code.

- Delete more than you add
- Reuse before writing
- Compose instead of building from scratch
- Solve the actual problem, not the general case
- When in doubt, do less

---

**Less, but better.** This is not about minimalism for its own sake—it's about respecting the people who will read, maintain, and live with your code. Every line should earn its place. Every abstraction should pay for its complexity. Every feature should solve a real problem.

If you can't explain why it needs to exist, it probably doesn't.

# Command Execution

- **Working Directory**: All commands run from repository root
- **Never cd**: Avoid changing directories
- **Use just**: All codebase operations (test, lint, build, etc.) must be executed via `just` recipes
- **Implementation**: Prefer implementing logic directly in justfile recipes; create standalone bash scripts only when necessary, but always invoke them through `just`

# Code Style

- 80 char line limit (readability > density)
- Newline at EOF
- No trailing whitespace
- Consistent indentation (2 spaces for shell, configs)
- POSIX-compliant shell when possible
- Variable naming: `KD_*` for globals, lowercase for locals

# Version Control

## Commit Workflow
- **ALWAYS** use: `just vcs cm "commit message"` then `just vcs push`
- Or combine: `just vcs cm "msg" && just vcs push`
- Never use raw git commands for commits
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Single-line messages only
- Atomic commits - one logical change per commit

## Git Hooks
- Pre-commit: `just hooks pre-commit`
- Managed through Husky
- Auto-runs linting, tests before commit

# Justfile System

**The justfile is the sole entrypoint for all codebase operations.** All management, testing, linting, building, and deployment commands must be implemented and executed through just recipes.

## Design Principles
- Modular organization via `mod` imports
- All recipes use `[no-cd]` - explicit paths only
- Silent by default (`@` prefix)
- Bash recipes inverse (`#!/usr/bin/env bash`)

## Module Structure
```
justfile              # Main recipes + imports
tasks/*/justfile     # Module-specific recipes
```

## Writing Recipes
```just
[no-cd]               # Required on all recipes
@recipe-name param:   # Silent execution
  command {{param}}

[no-cd]
script-recipe:        # Verbose bash script
  #!/usr/bin/env bash
  set -euo pipefail   # Always use strict mode
  echo "Visible output"
```

# Bootstrap System

Config-driven bootstrap for mobile development environments.

## Architecture
Bootstrap scripts are built from modular components:
```
bootstrap/
├── lib/                   # Reusable components
│   ├── utils/            # Core utilities (colors, logging, steps)
│   └── steps/            # Installation steps
├── manifests/            # Build manifests
│   ├── configure.txt     # Component list for configure.sh
│   └── termux.txt        # Component list for termux.sh
├── configure.sh          # Generated (committed)
└── termux.sh             # Generated (committed)
```

Build system concatenates components based on manifests:
```bash
just bootstrap build configure  # Build configure.sh
just bootstrap build termux     # Build termux.sh
just bootstrap build-all        # Build all scripts
```

## Scripts
- `bootstrap/configure.sh` - Interactive setup, creates `~/.config/kyldvs/k/configure.json`
- `bootstrap/termux.sh` - Minimal Termux environment with SSH/Mosh to VM
- `bootstrap/vmroot-configure.sh` - VM root config, creates `/root/.config/kyldvs/k/vmroot-configure.json`
- `bootstrap/vmroot.sh` - VM root bootstrap, provisions non-root user with sudo/SSH
- `bootstrap/vm.sh` - Future VM provisioning (stub)

## Key Functions
- `kd_step_start/end/skip` - Step logging
- `kd_log/error` - Output helpers

## Usage

### Bootstrap Scripts

```bash
# One-time configuration (Termux)
bash <(curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/configure.sh)

# Bootstrap Termux environment
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh

# Configure VM root bootstrap (run as root on VM)
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot-configure.sh | sh

# Bootstrap VM root user (run as root on VM)
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot.sh | sh
```

### Dotfiles System

After VM bootstrap, configure user environment with dotfiles:

```bash
# Initial setup (one-time, links dotfiles, configures git identity)
just k setup

# Install packages from YAML config
just k install-packages

# Check status
just k status
```

# Dotfiles System

Config-driven user environment management with GNU Stow.

## Architecture
Dotfiles system provides post-bootstrap user configuration:
```
dotfiles/              # Stow packages (linked to ~/)
├── zsh/              # Zsh configuration
├── tmux/             # Tmux configuration
├── git/              # Git base configuration
├── shell/            # Shell aliases
└── config/           # Example configs

lib/dotfiles/         # Bash libraries
├── stow.sh          # Symlink management
├── config.sh        # YAML config loader
├── git-identity.sh  # Git identity via includeIf
└── packages.sh      # Package installation

tasks/k/justfile     # User-facing commands
```

## Commands
```bash
just k setup               # Initial setup (stow, git identity)
just k sync                # Re-link dotfiles
just k install-packages    # Install APT packages from YAML
just k status              # Show config and link status
just k packages            # Show package status
just k git-test <path>     # Test git identity in directory
```

## Configuration
**File**: `~/.config/kyldvs/k/dotfiles.yml`

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
    - stow
    - ripgrep

tools: {}
```

## Git Identity Management
Uses git-native includeIf directives for directory-based identity switching:

1. Profile configs: `~/.config/git/<profile>.conf`
2. includeIf directives appended to `~/.gitconfig`
3. Git automatically switches identity by directory

No custom tooling - pure git features (requires git >= 2.13).

## Key Features
- **Stow-based linking**: Symlinks from `dotfiles/` to `~/`
- **Automatic updates**: `git pull` instantly updates dotfiles via symlinks
- **YAML configuration**: Declarative setup for git profiles and packages
- **Git-native identity**: includeIf directives, no custom scripts
- **Conflict handling**: Backs up existing files to `~/.config/kyldvs/k/backups/`
- **Idempotent**: Safe to re-run all commands

## Testing
Docker Compose tests validate all functionality:

```bash
just test dotfiles    # Run dotfiles tests
```

Coverage: fresh install, idempotency, git identity, packages, conflicts, YAML validation, sync after pull.

## Documentation
- `docs/dotfiles/README.md` - Complete user guide
- `docs/dotfiles/configuration.md` - YAML schema reference
- `docs/dotfiles/migration.md` - Migration from old tasks

# Testing

Docker Compose-based tests validate bootstrap and dotfiles with mocked dependencies.

```bash
# Run tests
just test all            # Run all tests (mobile + vmroot + dotfiles)
just test mobile termux  # Explicit mobile test
just test vmroot         # VM root bootstrap test
just test dotfiles       # Dotfiles system test
just test clean          # Cleanup containers/images

# Test structure
# src/tests/tests/mobile-termux.test.sh
#!/usr/bin/env bash
set -euo pipefail
. /lib/assertions.sh
cat /var/www/bootstrap/termux.sh | bash  # Run via direct mount
assert_file "$HOME/.ssh/gh_vm"           # Verify
cat /var/www/bootstrap/termux.sh | bash  # Idempotency
```

# Development Practices

## Shell Scripts
- Set strict mode: `set -euo pipefail`
- Exit codes: 0=success, 1=error, 2=usage
- Minimize subprocess spawning
- Use quotes around variables
- Prefer absolute paths
