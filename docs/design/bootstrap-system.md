# Bootstrap System

## Overview
A modular, config-driven bootstrap system for provisioning mobile development
environments. Scripts are built from reusable components and concatenated into
self-contained files compatible with curl-pipe-sh installation, enabling
one-command setup from fresh environments.

## Architecture

### Component-Based Build System
Bootstrap scripts are assembled from modular components rather than maintained
as monolithic files:

```
bootstrap/
├── lib/
│   ├── utils/          # Core utilities (colors, logging, steps)
│   └── steps/          # Installation steps (packages, ssh, doppler)
├── manifests/          # Build manifests (list of components)
│   ├── configure.txt
│   ├── termux.txt
│   ├── vmroot-configure.txt
│   └── vmroot.txt
├── configure.sh        # Generated (committed)
├── termux.sh           # Generated (committed)
├── vmroot-configure.sh # Generated (committed)
└── vmroot.sh           # Generated (committed)
```

Build command: `just bootstrap build <script-name>` or `build-all`

### Configuration Management
Bootstrap separated into two phases:

1. **Interactive Configuration** (`configure.sh`, `vmroot-configure.sh`)
   - Prompts for environment-specific settings
   - Validates inputs before saving
   - Stores config as JSON at `~/.config/kyldvs/k/<name>-configure.json`

2. **Non-Interactive Bootstrap** (`termux.sh`, `vmroot.sh`)
   - Reads saved configuration
   - Idempotent execution (safe to run multiple times)
   - Steps track completion and skip if already done

## Key Components

### Utility Components (`bootstrap/lib/utils/`)
- **colors.sh**: POSIX-compliant color definitions with `KD_NO_COLOR` support
- **logging.sh**: `kd_log()`, `kd_error()` output functions
- **steps.sh**: Step tracking with `kd_step_start/end/skip`
- **prompt.sh**: Interactive input helpers with defaults
- **validate.sh**: Input validation functions
- **config-path.sh**: Shared config file path constants
- **header-*.sh**: Script headers with shebang and strict mode

### Step Components (`bootstrap/lib/steps/`)
Each step is a self-contained function for a specific installation task:
- Package installation (Termux packages, Alpine proot-distro)
- Doppler CLI setup (Alpine-based, wrapper script)
- SSH configuration (key retrieval, config generation, connection test)
- Profile initialization (editor, PATH setup)
- Main orchestration (calls steps in sequence)

### Profile Initialization
Minimal shell configuration added to `.profile` for immediate usability:
- Sets `EDITOR=nano` via `~/.config/kyldvs/k/kd-editor.sh`
- Adds `~/bin` to PATH via `~/.config/kyldvs/k/kd-path.sh`
- Idempotent: checks for existing source lines before appending
- Source line format: `[ -f ~/.config/kyldvs/k/foo.sh ] && . ~/.config/kyldvs/k/foo.sh`

## Design Decisions

### Component Concatenation vs Runtime Sourcing
**Decision**: Concatenate components at build time into single scripts.

**Rationale**:
- Maintains curl-pipe-sh compatibility (single file, no dependencies)
- Reduces runtime complexity (no dynamic sourcing)
- Enables offline installation (no network after initial download)
- Trade-off: Requires rebuild when components change

### Configuration Storage Format
**Decision**: JSON files in `~/.config/kyldvs/k/`

**Rationale**:
- Structured data with clear schema
- Easy parsing with `jq` (already required dependency)
- Standard location following XDG conventions
- Human-readable for debugging

### Idempotency Strategy
**Decision**: Each step checks for completion markers before executing.

**Patterns**:
- File existence: `[ -f /path ] && skip`
- Content check: `grep -qF "text" file && skip`
- Command success: `which cmd >/dev/null 2>&1 && skip`

**Rationale**:
- Safe to re-run bootstrap after failures
- No duplicate installations or config entries
- Clear step-by-step progress tracking

### Secrets Management
**Decision**: Doppler CLI retrieves secrets at bootstrap time.

**Rationale**:
- Never store credentials in repository
- Centralized secret management
- Supports rotation without code changes
- Interactive `doppler login` keeps tokens secure

## Implementation Patterns

### Step Function Template
```sh
setup_component() {
  kd_step_start "Setting up component"

  if [ -f /marker/file ]; then
    kd_step_skip "Already configured"
    return 0
  fi

  # Installation logic here
  command1
  command2

  kd_step_end "Component configured"
}
```

### Build Process
1. Read manifest file (e.g., `termux.txt`)
2. Concatenate listed components in order
3. Write to output file (e.g., `termux.sh`)
4. Set executable permissions
5. Commit to git (enables GitHub raw URLs)

### Component Ordering Rules
Components must appear in dependency order:
1. Header (shebang, strict mode)
2. Colors (used by logging)
3. Logging (used by steps)
4. Steps (used by installation functions)
5. Constants (config paths, etc.)
6. Installation step functions
7. Main function (orchestrates execution)

## Integration Points

### With Doppler
- Bootstrap installs Doppler CLI via Alpine proot-distro
- Wrapper script (`~/bin/doppler`) provides transparent access
- SSH keys retrieved via `doppler secrets get`
- Credentials never stored in repository

### With Shell Environment
- Profile initialization adds minimal config to `.profile`
- Config files sourced from `~/.config/kyldvs/k/`
- File existence checks prevent errors if configs deleted
- Compatible with future zsh/VM setup (non-conflicting)

### With Test System
- Tests mount bootstrap directory read-only
- Mock Doppler responses with test fixtures
- Validate idempotency by running scripts twice
- Docker isolation prevents host contamination

## Configuration Schemas

### Termux Configuration (`configure.json`)
```json
{
  "doppler": {
    "project": "main",
    "env": "prd",
    "ssh_key_public": "SSH_GH_VM_PUBLIC",
    "ssh_key_private": "SSH_GH_VM_PRIVATE"
  },
  "vm": {
    "hostname": "vm.example.com",
    "port": 22,
    "username": "kad"
  }
}
```

### VM Root Configuration (`vmroot-configure.json`)
```json
{
  "username": "kad",
  "homedir": "/mnt/kad"
}
```

## Testing Approach
- Docker-based integration tests for complete bootstrap flows
- Idempotency validated by running scripts twice
- Mock external dependencies (Doppler, SSH VM)
- Assertions verify file creation, permissions, config content
- See testing-infrastructure.md for details

## Future Considerations
- **User-level VM bootstrap** (`vm.sh`): Currently stub, will provision
  development tools and dotfiles after root bootstrap
- **Platform detection**: `lib/utils/platform.sh` reserved for future
  multi-platform support beyond Termux/Ubuntu
- **Component-level testing**: Currently rely on integration tests; consider
  unit tests if complexity increases
