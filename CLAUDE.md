# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository

## Repository Info

**`kyldvs/k`** - kyldvs dotfiles

## Core Principles

### Simplicity First
- **Keep it simple** - avoid complexity unless absolutely necessary
- **Single responsibility** - each component does one thing well
- **Explicit over implicit** - clear intent in code and configuration
- **Fail fast** - validate early, error clearly
- **DRY** - reuse through functions and modules

### Code Style
- **Be extremely terse and concise always**
- 80 char line limit (readability > density)
- Newline at EOF
- No trailing whitespace
- Consistent indentation (2 spaces for shell, configs)
- POSIX-compliant shell when possible
- Variable naming: `KD_*` for globals, lowercase for locals

### File Management
- **NEVER create unnecessary files**
- **ALWAYS prefer editing existing over creating new**
- No proactive documentation - only on explicit request
- Keep directory structure flat and obvious

## Quick Reference

```bash
just test all            # Run all tests
just test mobile termux  # Run mobile termux tests
just test vmroot         # Run vmroot tests
just vcs cm "msg"        # Commit with message
just vcs push            # Push to remote
just bootstrap build-all # Build all bootstrap scripts
```

## Architecture Overview

```
.
├── bootstrap/           # Config-driven bootstrap scripts
├── src/tests/          # Docker-based mobile test infrastructure
├── tasks/             # Justfile modules
└── justfile           # Main entry point
```

## Version Control

### Commit Workflow
- **ALWAYS** use: `just vcs cm "commit message"` then `just vcs push`
- Or combine: `just vcs cm "msg" && just vcs push`
- Never use raw git commands for commits
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Single-line messages only
- Atomic commits - one logical change per commit

### Git Hooks
- Pre-commit: `just hooks pre-commit`
- Managed through Husky
- Auto-runs linting, tests before commit

## Justfile System

### Design Principles
- Modular organization via `mod` imports
- All recipes use `[no-cd]` - explicit paths only
- Silent by default (`@` prefix)
- Bash recipes inverse (`#!/usr/bin/env bash`)

### Module Structure
```
justfile              # Main recipes + imports
tasks/*/justfile     # Module-specific recipes
```

### Writing Recipes
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

## Bootstrap System

Config-driven bootstrap for mobile development environments.

### Architecture
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

### Scripts
- `bootstrap/configure.sh` - Interactive setup, creates `~/.config/kyldvs/k/configure.json`
- `bootstrap/termux.sh` - Minimal Termux environment with SSH/Mosh to VM
- `bootstrap/vmroot-configure.sh` - VM root config, creates `/root/.config/kyldvs/k/vmroot-configure.json`
- `bootstrap/vmroot.sh` - VM root bootstrap, provisions non-root user with sudo/SSH
- `bootstrap/vm.sh` - Future VM provisioning (stub)

### Key Functions
- `kd_step_start/end/skip` - Step logging
- `kd_log/error` - Output helpers

### Usage
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

## Testing

Docker Compose-based mobile tests validate bootstrap scripts with mocked dependencies.

```bash
# Run tests
just test all            # Run all tests (mobile + vmroot)
just test mobile termux  # Explicit mobile test
just test vmroot         # VM root bootstrap test
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

## Development Practices

### Error Handling
- Set strict mode: `set -euo pipefail`
- Validate inputs early
- Meaningful error messages
- Exit codes: 0=success, 1=error, 2=usage

### Debugging
```bash
# Disable colors for logs
export KD_NO_COLOR=1

# Run mobile tests
just test mobile termux
```

### Performance
- Minimize subprocess spawning
- Cache expensive operations
- Batch file operations
- Use native shell features when possible

### Security
- Never commit secrets/credentials
- Validate all user input
- Use quotes around variables
- Prefer absolute paths
- Check file permissions

### Agent Delegation
**When to use agents:**
- Complex features with intricate business logic
- Parallel tasks (2+ independent changes)
- Large code investigations
- Implementing multi-step plans

**When to work directly:**
- Small scope (1-4 files)
- Active debugging (rapid iteration)
- Quick fixes

**Agent prompt structure:**
- Specify files to read for patterns
- List target files to modify
- Define boundaries with other tasks
- Provide expected output format

**For parallel work:**
- Implement shared dependencies first (types, interfaces)
- Launch agents with clear boundaries
- Use specialized agents (backend-developer, frontend-ui-developer)

### Code Standards
- Study neighboring files first - patterns emerge from existing code
- Extend existing components - leverage what works before creating new
- Match established conventions - consistency trumps personal preference
- Use precise types - research actual types instead of `any`
- Fail fast with clear errors - early failures prevent hidden bugs
- Edit over create - modify existing files to maintain structure
- Code speaks for itself - comments only when explicitly requested

## Workflows

### Modify Bootstrap Scripts
1. Edit component files in `bootstrap/lib/utils/` or `bootstrap/lib/steps/`
2. Run `just bootstrap build-all` to regenerate scripts
3. `just test all`
4. `just vcs cm "fix|refactor: description" && just vcs push`

### Add Mobile Test Assertions
1. Update `src/tests/tests/mobile-termux.test.sh`
2. Add new assertions using `src/tests/lib/assertions.sh`
3. `just test mobile termux`
4. `just vcs cm "test: description" && just vcs push`

### Bootstrap VM with Root User
1. On VM as root: `curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot-configure.sh | sh`
2. Answer prompts (username, homedir)
3. Run bootstrap: `curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot.sh | sh`
4. Verify: `su - <username> -c 'sudo whoami'` (should print "root")
