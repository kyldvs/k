# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository

## Repository Info

**`k`** - kyldvs dotfiles

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
just bootstrap build      # Compile parts into bootstrap scripts
just test all            # Test all configs
just vcs cm "msg"        # Commit with message
just vcs push            # Push to remote
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

Modular compilation: `src/parts/*.sh` → `just bootstrap build` → `bootstrap/*.sh`

### Part Structure
```bash
# src/parts/example.sh
_needs_example() { [ ! -f ~/.done ]; }  # Idempotency
_example_termux() { pkg install -y example; }  # Platform-specific
_example() {
    kd_step_start "example" "Installing"
    ! _needs_example && { kd_step_skip "done"; return 0; }
    kd_platform_dispatch "example"
    kd_step_end
}
_example  # Self-execute
```

### Key Functions
- `kd_step_start/end/skip` - Step logging
- `kd_log/info/warn/error` - Output helpers
- `kd_platform_dispatch "name"` - Calls `_name_<platform>` automatically
- `kd_get_platform` - Returns: termux, ubuntu, unknown

### Commands
```bash
just bootstrap build          # Compile all
just bootstrap build-one vm   # Single config
just test all                # Full suite
```

## Testing

Docker-based tests validate correctness and idempotency using `src/tests/lib/assertions.sh`.

```bash
# src/tests/tests/example.test.sh
#!/usr/bin/env bash
set -euo pipefail
. /lib/assertions.sh
curl -fsSL http://k.local/example.sh | bash  # Run
assert_file "/path/to/file"                  # Verify
curl -fsSL http://k.local/example.sh | bash  # Idempotency
```

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

### Add Feature
1. Create `src/parts/feature.sh` with structure template
2. Add to `src/bootstrap/*.json`
3. `just bootstrap build && just test all`
4. `just vcs cm "feat: description" && just vcs push`

### Add Platform
1. Add `kd_is_<platform>()` to util-functions.sh
2. Update `kd_get_platform()` return value
3. Add `_<part>_<platform>()` implementations
4. Platform dispatch auto-routes to new functions

### Fix/Refactor
1. Edit `src/parts/*.sh`
2. `just bootstrap build && just test all`
3. `just vcs cm "fix|refactor: description" && just vcs push`
