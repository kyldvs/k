# `k` - kyldvs dotfiles

Project uses Claude Code with specialized agents and workflows (`.claude/`).

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
# Most used commands
just bootstrap build       # Build all bootstrap scripts
just test all             # Test all configurations
just vcs acp "msg"        # Add, commit, push (ALWAYS use this)

# Development cycle
just bootstrap build && just test all && just vcs acp "feat: xyz"
```

## Claude Code Workflows

Specialized agents, commands, and output styles in `.claude/` directory.

### Available Agents
- **code-finder** / **code-finder-advanced** - Locate code patterns
- **implementor** - Precise implementation tasks
- **root-cause-analyzer** - Systematic bug diagnosis
- **backend-developer** / **frontend-ui-developer** - Domain-specific dev
- **library-docs-writer** - Documentation generation

### Available Commands
- `/better-init` - Create/improve CLAUDE.md
- `/orchestrate` - Multi-agent orchestration mode
- `/git` - Documentation & commit workflows
- `/fix-build` - Systematic build error fixing
- `/research/deep` - Asymmetric research methodology
- `/execute/implement-plan` - Structured plan implementation

### Output Styles
- **main** - Senior developer approach with agent delegation
- **planning** - Strategic planning methodology
- **deep-research** - Evidence-based research mode

See `.claude/README.md` for details.

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

# Platform-specific implementations (optional)
_example_termux() {
    # Termux-specific logic
    pkg install -y example
}

_example_ubuntu() {
    # Ubuntu-specific logic
    apt-get install -y example
}

# Main implementation (required)
_example() {
    kd_step_start "example" "Installing example"

    if ! _needs_example; then
        kd_step_skip "example already installed"
        return 0
    fi

    # Use platform dispatch for multi-platform support
    kd_platform_dispatch "example"

    kd_step_end
}

# Self-execution (required)
_example
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
# Step management
kd_step_start "name" "description"  # Begin step
kd_step_end                         # Complete step
kd_step_skip "reason"              # Skip with explanation

# Logging
kd_log "message"                   # Indented output
kd_info/warn/error "msg"           # Colored messages

# Platform detection
kd_get_platform                    # Returns: termux, ubuntu, unknown
kd_is_termux                       # Check if running on Termux
kd_is_ubuntu                       # Check if running on Ubuntu

# Platform dispatch (convention over configuration)
kd_platform_dispatch "function"    # Calls _function_<platform>
                                   # Auto-detects platform and dispatches
```

### Building & Testing
```bash
just bootstrap build         # Compile all configs
just bootstrap build-one vm  # Single config
just test config termux      # Test specific
just test all               # Full test suite
```

### Platform Dispatch Pattern

The codebase uses **convention over configuration** for platform-specific
implementations. Instead of verbose case statements, use `kd_platform_dispatch`:

```bash
# OLD pattern (verbose, repetitive)
_example() {
    platform=$(kd_get_platform)
    case "$platform" in
        termux)
            _example_termux
            ;;
        ubuntu)
            _example_ubuntu
            ;;
        *)
            kd_step_skip "platform not supported"
            ;;
    esac
}

# NEW pattern (DRY, convention-based)
_example() {
    kd_platform_dispatch "example"
    # Automatically calls _example_termux or _example_ubuntu
}
```

**Benefits:**
- Eliminates repetitive case statements
- Makes adding new platforms easier (just add `_name_platform` function)
- Reduces boilerplate by ~10 lines per part
- Self-documenting through naming convention

## Testing Infrastructure

### Docker-Based Testing
- Isolated environments per config
- Idempotency verification
- Network server for bootstrap delivery

### Test Structure
```
src/tests/
├── run.sh              # Test orchestrator
├── lib/               # Shared test utilities
│   └── assertions.sh  # Common assertion helpers
├── images/            # Docker environments
├── tests/             # Test scripts
└── fixtures/          # Test assets
```

### Writing Tests
```bash
# src/tests/tests/example.test.sh
#!/usr/bin/env bash
set -euo pipefail

# Source shared assertion helpers
. /lib/assertions.sh

echo "→ Testing example bootstrap script"

# Test 1: Run bootstrap
curl -fsSL http://k.local/example.sh | bash

# Test 2: Verify installation
assert_file "/path/to/installed/file"
assert_command "example --version" "1.0.0"
assert_file_contains "$HOME/.config" "example"

# Test 3: Idempotency
curl -fsSL http://k.local/example.sh | bash
```

### Test Assertion Helpers
```bash
assert_file "/path/to/file"              # File exists
assert_symlink "link" "target"           # Symlink correct
assert_command "cmd" "expected output"   # Command output matches
assert_file_contains "file" "pattern"    # File contains pattern
assert_command_exists "command"          # Command in PATH
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

## Workflow Patterns

### Adding New Feature
1. Create part in `src/parts/feature.sh` following structure template
2. Add platform-specific implementations (`_feature_termux`, etc.)
3. Add to config `src/bootstrap/config.json`
4. Build: `just bootstrap build`
5. Test: `just test config <name>`
6. Commit: `just vcs acp "feat: add feature"`

### Adding New Platform
1. Add platform detection to `kd_is_<platform>()` in util-functions.sh
2. Update `kd_get_platform()` to return platform name
3. Add `_<part>_<platform>()` implementations for needed parts
4. Platform dispatch will automatically route to new implementations

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
