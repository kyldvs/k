# `k` - kyldvs dotfiles

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

### File Management
- **NEVER create unnecessary files**
- **ALWAYS prefer editing existing over creating new**
- No proactive documentation - only on explicit request
- Keep directory structure flat and obvious

## Quick Reference

```bash
# Most used commands
just bootstrap build       # Build all bootstrap scripts
just test all             # Test all configurations
just vcs acp "msg"        # Add, commit, push (ALWAYS use this)

# Development cycle
just bootstrap build && just test all && just vcs acp "feat: xyz"
```

## Architecture Overview

```
.
├── bootstrap/           # Generated scripts (DO NOT EDIT)
├── src/
│   ├── bootstrap/      # JSON configs defining which parts
│   ├── parts/         # Reusable shell functions
│   └── tests/         # Docker-based test infrastructure
├── tasks/             # Justfile modules
└── justfile           # Main entry point
```

## Version Control

### Commit Workflow
- **ALWAYS** use: `just vcs acp "commit message"`
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

### Overview
Modular compilation system for environment setup scripts.

### Components
- **Parts**: Individual setup functions (`src/parts/*.sh`)
- **Configs**: JSON files listing parts (`src/bootstrap/*.json`)
- **Builder**: Compiles parts into scripts (`tasks/bootstrap/`)
- **Output**: Generated scripts (`bootstrap/*.sh`)

### Creating Parts

#### Structure Requirements
```bash
# src/parts/example.sh

# Idempotency check (required)
_needs_example() {
    # Return 0 if needed, 1 if already done
    [ ! -f ~/.example_installed ]
}

# Implementation (required)
_example() {
    kd_step_start "example" "Installing example"

    # Your logic here
    touch ~/.example_installed

    kd_step_end
}
```

#### Best Practices
- Use `return` not `exit` (runs in compiled context)
- Non-interactive only (no prompts/read)
- Idempotent - safe to run multiple times
- Use utility functions for logging
- Validate prerequisites first
- Clean error messages

#### Utility Functions
```bash
kd_step_start "name" "description"  # Begin step
kd_step_end                         # Complete step
kd_step_skip "reason"              # Skip with explanation
kd_log "message"                   # Indented output
kd_info/warn/error "msg"           # Colored messages
```

### Building & Testing
```bash
just bootstrap build         # Compile all configs
just bootstrap build-one vm  # Single config
just test config termux      # Test specific
just test all               # Full test suite
```

## Testing Infrastructure

### Docker-Based Testing
- Isolated environments per config
- Idempotency verification
- Network server for bootstrap delivery

### Test Structure
```
src/tests/
├── run.sh              # Test orchestrator
├── images/            # Docker environments
├── tests/             # Test scripts
└── fixtures/          # Test assets
```

### Writing Tests
```bash
# src/tests/tests/example.test.sh
test_example() {
    # Arrange
    setup_environment

    # Act
    run_bootstrap

    # Assert
    verify_idempotency
    check_installation
}
```

### Platform-Specific Issues

#### Termux
- DNS resolution requires ulimit fix
- User switching: root for DNS, system for pkg
- Custom build script in `src/tests/images/termux/build.sh`

## Development Practices

### Error Handling
- Set strict mode: `set -euo pipefail`
- Validate inputs early
- Meaningful error messages
- Exit codes: 0=success, 1=error, 2=usage

### Debugging
```bash
# Enable debug output
export KD_DEBUG=1

# Disable colors for logs
export KD_NO_COLOR=1

# Test single component
just test config termux
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

## Workflow Patterns

### Adding New Feature
1. Create part in `src/parts/feature.sh`
2. Add to config `src/bootstrap/config.json`
3. Build: `just bootstrap build`
4. Test: `just test config <name>`
5. Commit: `just vcs acp "feat: add feature"`

### Fixing Bugs
1. Reproduce in test environment
2. Fix in `src/parts/`
3. Verify: `just test all`
4. Commit: `just vcs acp "fix: description"`

### Refactoring
1. Make changes
2. Run full test suite
3. Verify idempotency
4. Commit: `just vcs acp "refactor: description"`

## Important Reminders

- **Simplicity > Cleverness** - maintainable code wins
- **Test everything** - especially idempotency
- **Document intent** - why, not what
- **Fail gracefully** - helpful error messages
- **Stay consistent** - follow established patterns
