# Bootstrap Component Architecture

## Overview

Bootstrap scripts use a modular component system where functionality is implemented as discrete shell functions in `bootstrap/lib/steps/`, composed via manifest files, and concatenated into standalone executable scripts.

## Architecture

**Build-time composition pattern:**
1. Components define step functions in `bootstrap/lib/steps/*.sh`
2. Manifest files list components to include: `bootstrap/manifests/*.txt`
3. Build process concatenates components: `just bootstrap build [script]`
4. Generates standalone script: `bootstrap/[script].sh`

**Component structure:**
```
bootstrap/
├── lib/
│   ├── utils/           # Shared utilities
│   │   ├── header-*.sh  # Script headers with shebang, color setup
│   │   ├── colors.sh    # POSIX color definitions
│   │   ├── logging.sh   # kd_log, kd_error, kd_warning, kd_info
│   │   ├── steps.sh     # kd_step_start, kd_step_end, kd_step_skip
│   │   └── retry.sh     # kd_retry wrapper
│   └── steps/           # Step components
│       ├── git-config.sh
│       ├── ssh-keys.sh
│       └── *-main.sh    # Main flow orchestration
└── manifests/
    └── *.txt            # Component lists for each script
```

## Key Components

### Step Component Pattern

All step components follow this structure:

```sh
# Component header comment explaining purpose and settings
component_function() {
  kd_step_start "component-name" "Human-readable description"

  # Idempotency check
  if already_configured; then
    kd_step_skip "Already configured"
    return 0
  fi

  # Check prerequisites
  if ! command -v required_tool >/dev/null 2>&1; then
    kd_error "Required tool not installed"
    return 1
  fi

  # Perform work
  kd_log "Doing something"
  do_work || return 1

  kd_step_end
}
```

### Logging Functions

- `kd_step_start "name" "message"` - Begin step, increment indent
- `kd_step_end` - Complete step, show ✓, decrement indent
- `kd_step_skip "reason"` - Skip step with ○, decrement indent
- `kd_log "message"` - Log at current indent level
- `kd_error "message"` - Error to stderr with [ERROR] prefix
- `kd_warning "message"` - Warning with ⚠ prefix
- `kd_info "message"` - Info with ℹ prefix

### Main Flow Pattern

Each bootstrap script has a `*-main.sh` component that orchestrates execution:

```sh
main() {
  printf "\n%s%sScript Name%s\n" "$KD_BOLD" "$KD_CYAN" "$KD_RESET"
  printf "Description\n\n"

  # Call step components in order
  component1
  component2
  component3

  # Success message
  printf "\n%s✓ Bootstrap complete!%s\n" "$KD_GREEN" "$KD_RESET"
}

main
```

## Design Decisions

### Idempotency Strategy

Components use marker-based idempotency checks:
- Check for presence of specific configuration value
- Use unique, unlikely-to-exist-by-default markers
- Example: `merge.conflictstyle = zdiff3` for git-config
- Allows safe re-execution without destructive overwrites

**Rationale:** More robust than checking all configured values; single marker indicates complete configuration.

### POSIX Compliance

All scripts use POSIX-compliant shell constructs:
- Use `[ ]` not `[[ ]]`
- Use `$(command)` not backticks
- Avoid arrays, use variables
- Test with `#!/bin/sh`, validate with shellcheck

**Rationale:** Maximum compatibility across minimal environments (Termux, Alpine, minimal VMs).

### Build-Time Concatenation

Components are concatenated at build-time, not sourced at runtime:
- Single executable script per bootstrap target
- No filesystem dependencies during execution
- Can be downloaded and run standalone

**Rationale:** Simplifies distribution (single URL), reduces runtime failures, enables offline execution.

### Identity Preservation Pattern

When modifying user configuration, preserve existing identity values:
```sh
# Capture before modification
user_name=$(git config --global --get user.name 2>/dev/null || echo "")
user_email=$(git config --global --get user.email 2>/dev/null || echo "")

# Apply changes
apply_config

# Restore identity
if [ -n "$user_name" ]; then
  git config --global user.name "$user_name"
fi
```

**Rationale:** Configuration components should only modify their specific domain; user identity is orthogonal.

## Integration Points

### Adding New Component

1. Create `bootstrap/lib/steps/component-name.sh`
2. Define function following step pattern
3. Add to appropriate manifest: `bootstrap/manifests/script.txt`
4. Build script: `just bootstrap build script`
5. Add tests: `src/tests/tests/script.test.sh`

### Component Dependencies

Manifests define component order (dependencies implicit via ordering):
```
lib/utils/header-vm.sh
lib/utils/colors.sh
lib/utils/logging.sh
lib/utils/steps.sh
lib/steps/git-config.sh    # Depends on steps.sh being sourced first
lib/steps/vm-main.sh       # Calls git-config function
```

### Test Integration

Each bootstrap script has corresponding test infrastructure:
- Test file: `src/tests/tests/[script].test.sh`
- Docker Compose: `src/tests/docker-compose.[script].yml`
- Test runner: `src/tests/run-[script].sh`
- Just command: `just test [script]`

## Testing Approach

### Docker-Based Testing

Tests run in isolated Docker containers matching target environment:
- Ubuntu 24.04 for VM bootstrap
- Alpine for Termux/mobile bootstrap
- Mount bootstrap scripts read-only: `/var/www/bootstrap`
- Execute via bash piped to container

### Test Structure

1. Setup: Prepare test environment (mock configs, set variables)
2. Execute: Run bootstrap script
3. Validate: Assert expected outcomes (files exist, values correct)
4. Idempotency: Run again, verify skip messages
5. Cleanup: Automatic via Docker Compose down

### Assertion Helpers

Shared assertion library: `src/tests/lib/assertions.sh`
- `assert_file path` - File exists
- `assert_file_perms path mode` - Permissions correct
- Test output uses → for sections, ✓ for success, ✗ for failures

## Configuration Values

### Git Configuration Component

Applies 8 workflow settings solving specific pain points:

| Setting | Value | Purpose |
|---------|-------|---------|
| push.default | current | Eliminates "no upstream branch" errors |
| pull.ff | true | Prevents unexpected merge commits on pull |
| merge.ff | true | Fast-forward when possible |
| merge.conflictstyle | zdiff3 | Shows common ancestor in conflicts |
| init.defaultBranch | main | Modern default branch name |
| diff.algorithm | histogram | More intuitive diffs |
| log.date | iso | ISO 8601 timestamps |
| core.autocrlf | false | No automatic line ending conversion |

**Preservation:** Maintains existing user.name and user.email values.

## Future Considerations

### Potential Extensions

- Dynamic component discovery (avoid manual manifest editing)
- Component dependencies declared in component files
- Parallel execution of independent components
- Component versioning and compatibility checks

### Current Limitations

- No conditional component inclusion (all-or-nothing per manifest)
- No runtime component composition (build-time only)
- Error in one component aborts entire script (`set -e`)
- No rollback mechanism for partial failures
