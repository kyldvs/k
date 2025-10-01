# Modular Bootstrap System - Specification

## Overview
A modular component system for bootstrap scripts that eliminates duplication across configure.sh, termux.sh, and vm.sh by extracting shared logic into reusable files. Components are concatenated at build time into single self-contained scripts that use runtime platform detection.

## Goals
- Eliminate duplication across bootstrap scripts through shared components
- Maintain single self-contained file output for curl-pipe-sh installation
- Preserve all existing behavior, naming conventions, and idempotency
- Support platform-specific implementations (Termux vs Ubuntu) via runtime detection

## Requirements

### Functional Requirements
- FR-1: Extract shared utility functions (logging, error handling, step management) into reusable components
- FR-2: Extract installation steps (git, ssh, doppler, etc.) into modular components with platform-specific variants
- FR-3: Build system concatenates components into final bootstrap scripts (configure.sh, termux.sh, vm.sh)
- FR-4: Runtime platform detection selects appropriate implementation paths
- FR-5: Generated scripts remain self-contained single files compatible with curl-pipe-sh
- FR-6: All existing script behavior preserved (idempotency, error handling, output formatting)

### Non-Functional Requirements
- NFR-1: Build process must be fast (<1s for all scripts)
- NFR-2: Generated scripts maintain 80 char line limit where feasible
- NFR-3: Component files use clear naming for discoverability
- NFR-4: No runtime dependencies beyond existing requirements

### Technical Requirements
- Simple shell script concatenation (no templating engines)
- Components organized in `bootstrap/lib/` or similar directory structure
- Build command: `just bootstrap build` (or integrated into existing workflows)
- Support two platforms: Termux (Android) and Ubuntu VM
- Preserve `kd_*` function naming conventions
- POSIX-compliant shell where possible
- Runtime detection using shared utility functions

## User Stories / Use Cases
- As a maintainer, I can modify shared logging functions once and have changes apply to all bootstrap scripts
- As a maintainer, I can add a new installation step by creating a component with platform variants
- As a developer, I can build all bootstrap scripts with a single just command
- As an end user, I can still install via `curl -fsSL url | sh` without noticing any changes

## Success Criteria
- Zero functional regressions: `just test all` passes identically before and after
- Duplication reduced: shared functions exist in exactly one place
- Step-level reuse: common installation steps (git, ssh, doppler) are modular components
- Build command produces byte-identical behavior (output may differ, behavior must not)
- Component files are small (<100 lines each where possible)

## Technical Design

### Directory Structure
```
bootstrap/
├── lib/
│   ├── utils/
│   │   ├── logging.sh       # kd_log, kd_error
│   │   ├── steps.sh         # kd_step_start/end/skip
│   │   └── platform.sh      # kd_detect_platform, kd_is_termux, etc.
│   ├── steps/
│   │   ├── git.sh           # Common git setup
│   │   ├── git.termux.sh    # Termux-specific git (if needed)
│   │   ├── git.ubuntu.sh    # Ubuntu-specific git (if needed)
│   │   ├── ssh.sh
│   │   ├── doppler.sh
│   │   └── ...
│   └── headers/
│       └── common.sh        # Shebang, set -euo pipefail, etc.
├── manifests/
│   ├── configure.manifest   # List of components for configure.sh
│   ├── termux.manifest      # List of components for termux.sh
│   └── vm.manifest          # List of components for vm.sh
├── configure.sh             # Generated (git-ignored or committed)
├── termux.sh                # Generated
└── vm.sh                    # Generated
```

### Component Selection Patterns

**Shared utilities** (used by all):
```bash
# bootstrap/lib/utils/logging.sh
kd_log() { ... }
kd_error() { ... }
```

**Platform-agnostic steps**:
```bash
# bootstrap/lib/steps/ssh-keygen.sh
kd_setup_ssh_keys() {
  # Works same on all platforms
}
```

**Platform-specific steps**:
```bash
# bootstrap/lib/steps/doppler.sh
kd_install_doppler() {
  if kd_is_termux; then
    # Termux implementation
  else
    # Ubuntu implementation
  fi
}
```

### Build Process
1. Read manifest file (e.g., `termux.manifest`)
2. Concatenate listed component files in order
3. Write to output file (e.g., `termux.sh`)
4. Set executable permissions

### Manifest Format
Simple line-delimited list of component paths:
```
lib/headers/common.sh
lib/utils/platform.sh
lib/utils/logging.sh
lib/utils/steps.sh
lib/steps/git.sh
lib/steps/ssh.sh
lib/steps/doppler.sh
```

## Constraints
- Must maintain curl-pipe-sh compatibility (single self-contained file)
- No external dependencies at runtime (concatenated script is standalone)
- Generated files may be committed to git for easy access via raw URLs
- Build step optional for development (can edit generated files directly if needed)

## Non-Goals
- Multi-platform package management abstraction (keep platform-specific implementations explicit)
- Configuration file templating or variable substitution (use runtime logic)
- Source maps or debugging of original component locations
- Hot reloading or watch mode for build process
- Support for platforms beyond Termux and Ubuntu VM

## Assumptions
- Developers have just installed and can run build commands
- Build happens on developer machine before commit (or via CI)
- Component files are small enough to concatenate without performance issues
- Existing test infrastructure can test generated scripts without modification

## Open Questions
- Should generated scripts be committed to git or git-ignored and built on-demand?
  - Recommendation: Commit them for easy curl-pipe-sh access via raw GitHub URLs
- Should build happen automatically via git hooks or manual just command?
  - Recommendation: Manual initially, add to pre-commit hook later if needed
- How to handle component-level testing if needed in future?
  - Recommendation: Defer until proven necessary, rely on integration tests for now
