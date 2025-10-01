# Modular Bootstrap System - Implementation Plan

## Prerequisites
- just command runner installed
- Existing test infrastructure functional (`just test all` passing)
- Shell scripting knowledge (POSIX sh)

## Architecture Overview

Current state: `configure.sh` (154 lines) and `termux.sh` (528 lines) have significant duplication in utility functions (logging, steps, colors). The `vm.sh` script is a stub and will duplicate these patterns when implemented.

Modular architecture:
```
bootstrap/
├── lib/                    # Shared components (new)
│   ├── utils/             # Core utilities
│   │   ├── header.sh      # Shebang, set -e
│   │   ├── colors.sh      # Color definitions
│   │   ├── logging.sh     # kd_log, kd_error
│   │   ├── steps.sh       # kd_step_start/end/skip
│   │   └── platform.sh    # Platform detection (future)
│   └── steps/             # Installation steps
│       ├── config.sh      # Config file handling
│       ├── packages.sh    # Package installation
│       ├── ssh.sh         # SSH key setup
│       └── doppler.sh     # Doppler CLI setup
├── manifests/             # Build manifests (new)
│   ├── configure.txt      # Component list for configure.sh
│   └── termux.txt         # Component list for termux.sh
├── configure.sh           # Generated (committed)
└── termux.sh              # Generated (committed)
```

Build process: `just bootstrap build` reads manifests, concatenates components, writes output files.

Integration: Generated scripts remain curl-pipe-sh compatible. Tests run against final output files.

## Task Breakdown

### Phase 1: Build System Foundation
- [ ] Task 1.1: Create build system recipe
  - Files: `justfile`, `tasks/bootstrap/justfile`
  - Dependencies: None
  - Details: Add `mod bootstrap "tasks/bootstrap"` to main justfile, create bootstrap module with `build` recipe that concatenates files based on manifest

- [ ] Task 1.2: Create directory structure
  - Files: Create `bootstrap/lib/utils/`, `bootstrap/lib/steps/`, `bootstrap/manifests/`
  - Dependencies: None
  - Details: Simple mkdir operations, no code changes

- [ ] Task 1.3: Implement concatenation logic
  - Files: `tasks/bootstrap/justfile`
  - Dependencies: Task 1.1, Task 1.2
  - Details: Recipe reads manifest line-by-line, concatenates component files, writes to output with executable permissions

### Phase 2: Extract Utilities (configure.sh)
- [ ] Task 2.1: Extract header component
  - Files: `bootstrap/lib/utils/header.sh`
  - Dependencies: Task 1.2
  - Details: Lines 1-7 from configure.sh (shebang, comments, set -e)

- [ ] Task 2.2: Extract color definitions
  - Files: `bootstrap/lib/utils/colors.sh`
  - Dependencies: Task 1.2
  - Details: Lines 9-24 from configure.sh (POSIX color definitions with KD_NO_COLOR check)

- [ ] Task 2.3: Extract prompt function
  - Files: `bootstrap/lib/utils/prompt.sh`
  - Dependencies: Task 1.2
  - Details: Lines 30-49 from configure.sh (prompt helper function)

- [ ] Task 2.4: Extract validation function
  - Files: `bootstrap/lib/utils/validate.sh`
  - Dependencies: Task 1.2
  - Details: Lines 51-85 from configure.sh (validate_config function)

- [ ] Task 2.5: Extract configure main logic
  - Files: `bootstrap/lib/steps/configure-main.sh`
  - Dependencies: Task 1.2
  - Details: Lines 87-153 from configure.sh (main configuration flow, config writes)

- [ ] Task 2.6: Create configure manifest
  - Files: `bootstrap/manifests/configure.txt`
  - Dependencies: Tasks 2.1-2.5
  - Details: List components in order: header.sh, colors.sh, prompt.sh, validate.sh, configure-main.sh

- [ ] Task 2.7: Build and validate configure.sh
  - Files: `bootstrap/configure.sh` (regenerated)
  - Dependencies: Task 1.3, Task 2.6
  - Details: Run `just bootstrap build configure`, manually test output matches original behavior

### Phase 3: Extract Utilities (termux.sh)
- [ ] Task 3.1: Extract logging functions (termux)
  - Files: `bootstrap/lib/utils/logging.sh`
  - Dependencies: Task 1.2
  - Details: Lines 36-54 from termux.sh (_kd_indent, kd_log, kd_error), ensure compatible with configure.sh if overlap exists

- [ ] Task 3.2: Extract step management functions
  - Files: `bootstrap/lib/utils/steps.sh`
  - Dependencies: Task 1.2
  - Details: Lines 32-101 from termux.sh (KD_INDENT, KD_CURRENT_STEP, kd_step_start/end/skip)

### Phase 4: Extract Installation Steps (termux.sh)
- [ ] Task 4.1: Extract config check step
  - Files: `bootstrap/lib/steps/check-config.sh`
  - Dependencies: Task 1.2
  - Details: Lines 103-121 from termux.sh (check_config function)

- [ ] Task 4.2: Extract Termux properties step
  - Files: `bootstrap/lib/steps/termux-properties.sh`
  - Dependencies: Task 1.2
  - Details: Lines 123-163 from termux.sh (configure_termux_properties function)

- [ ] Task 4.3: Extract Termux colors step
  - Files: `bootstrap/lib/steps/termux-colors.sh`
  - Dependencies: Task 1.2
  - Details: Lines 165-225 from termux.sh (configure_termux_colors function)

- [ ] Task 4.4: Extract Termux font step
  - Files: `bootstrap/lib/steps/termux-font.sh`
  - Dependencies: Task 1.2
  - Details: Lines 227-266 from termux.sh (configure_termux_font function)

- [ ] Task 4.5: Extract package installation step
  - Files: `bootstrap/lib/steps/packages.sh`
  - Dependencies: Task 1.2
  - Details: Lines 268-296 from termux.sh (install_packages function)

- [ ] Task 4.6: Extract proot-distro step
  - Files: `bootstrap/lib/steps/proot-distro.sh`
  - Dependencies: Task 1.2
  - Details: Lines 298-311 from termux.sh (install_proot_distro function)

- [ ] Task 4.7: Extract Alpine installation step
  - Files: `bootstrap/lib/steps/alpine.sh`
  - Dependencies: Task 1.2
  - Details: Lines 313-326 from termux.sh (install_alpine function)

- [ ] Task 4.8: Extract Doppler Alpine step
  - Files: `bootstrap/lib/steps/doppler-alpine.sh`
  - Dependencies: Task 1.2
  - Details: Lines 328-345 from termux.sh (install_doppler_alpine function)

- [ ] Task 4.9: Extract Doppler wrapper step
  - Files: `bootstrap/lib/steps/doppler-wrapper.sh`
  - Dependencies: Task 1.2
  - Details: Lines 347-373 from termux.sh (create_doppler_wrapper function)

- [ ] Task 4.10: Extract Doppler auth check step
  - Files: `bootstrap/lib/steps/doppler-auth.sh`
  - Dependencies: Task 1.2
  - Details: Lines 375-392 from termux.sh (check_doppler_auth function)

- [ ] Task 4.11: Extract SSH key retrieval step
  - Files: `bootstrap/lib/steps/ssh-keys.sh`
  - Dependencies: Task 1.2
  - Details: Lines 394-434 from termux.sh (retrieve_ssh_keys function)

- [ ] Task 4.12: Extract SSH config generation step
  - Files: `bootstrap/lib/steps/ssh-config.sh`
  - Dependencies: Task 1.2
  - Details: Lines 436-471 from termux.sh (generate_ssh_config function)

- [ ] Task 4.13: Extract SSH connection test step
  - Files: `bootstrap/lib/steps/ssh-test.sh`
  - Dependencies: Task 1.2
  - Details: Lines 473-487 from termux.sh (test_ssh_connection function)

- [ ] Task 4.14: Extract success message step
  - Files: `bootstrap/lib/steps/next-steps.sh`
  - Dependencies: Task 1.2
  - Details: Lines 489-507 from termux.sh (show_next_steps function)

- [ ] Task 4.15: Extract termux main function
  - Files: `bootstrap/lib/steps/termux-main.sh`
  - Dependencies: Task 1.2
  - Details: Lines 509-527 from termux.sh (main function orchestration)

### Phase 5: Create Termux Manifest and Build
- [ ] Task 5.1: Create termux manifest
  - Files: `bootstrap/manifests/termux.txt`
  - Dependencies: Tasks 3.1-3.2, Tasks 4.1-4.15
  - Details: List components in dependency order: header, colors, logging, steps, config-var, all step functions, termux-main

- [ ] Task 5.2: Add CONFIG_FILE constant component
  - Files: `bootstrap/lib/utils/config-path.sh`
  - Dependencies: Task 1.2
  - Details: Lines 103-104 from termux.sh (CONFIG_FILE definition), shared by multiple steps

- [ ] Task 5.3: Build and validate termux.sh
  - Files: `bootstrap/configure.sh` (regenerated)
  - Dependencies: Task 1.3, Task 5.1, Task 5.2
  - Details: Run `just bootstrap build termux`, manually test output matches original behavior

### Phase 6: Testing & Validation
- [ ] Task 6.1: Run full test suite
  - Files: N/A (validation only)
  - Dependencies: Task 2.7, Task 5.3
  - Details: `just test all` must pass with identical behavior to before refactor

- [ ] Task 6.2: Manual validation - configure.sh
  - Files: N/A (validation only)
  - Dependencies: Task 6.1
  - Details: Run generated configure.sh interactively, verify config file creation, JSON format, permissions

- [ ] Task 6.3: Manual validation - termux.sh curl installation
  - Files: N/A (validation only)
  - Dependencies: Task 6.1
  - Details: Test `cat bootstrap/termux.sh | sh` pattern to ensure single-file compatibility

### Phase 7: Documentation and Cleanup
- [ ] Task 7.1: Update CLAUDE.md
  - Files: `CLAUDE.md`
  - Dependencies: Task 6.3
  - Details: Add build system documentation, component structure, update bootstrap workflow section

- [ ] Task 7.2: Add build to pre-commit workflow (optional)
  - Files: `tasks/hooks/justfile` (if implementing)
  - Dependencies: Task 6.3
  - Details: Consider adding `just bootstrap build` to pre-commit hook to keep generated files in sync

## Files to Create

### Build System
- `tasks/bootstrap/justfile` - Build recipes and concatenation logic

### Utility Components
- `bootstrap/lib/utils/header.sh` - Script header (shebang, set -e)
- `bootstrap/lib/utils/colors.sh` - Color definitions (KD_*)
- `bootstrap/lib/utils/logging.sh` - Logging functions (kd_log, kd_error)
- `bootstrap/lib/utils/steps.sh` - Step management (kd_step_start/end/skip)
- `bootstrap/lib/utils/prompt.sh` - Interactive prompt helper (configure only)
- `bootstrap/lib/utils/validate.sh` - Input validation (configure only)
- `bootstrap/lib/utils/config-path.sh` - CONFIG_FILE constant
- `bootstrap/lib/utils/platform.sh` - Platform detection (future use)

### Step Components (configure.sh)
- `bootstrap/lib/steps/configure-main.sh` - Main configuration logic

### Step Components (termux.sh)
- `bootstrap/lib/steps/check-config.sh` - Config file validation
- `bootstrap/lib/steps/termux-properties.sh` - Termux extra-keys setup
- `bootstrap/lib/steps/termux-colors.sh` - Termux color scheme
- `bootstrap/lib/steps/termux-font.sh` - Termux font installation
- `bootstrap/lib/steps/packages.sh` - Package installation (openssh, mosh, jq)
- `bootstrap/lib/steps/proot-distro.sh` - Proot-distro setup
- `bootstrap/lib/steps/alpine.sh` - Alpine Linux installation
- `bootstrap/lib/steps/doppler-alpine.sh` - Doppler CLI in Alpine
- `bootstrap/lib/steps/doppler-wrapper.sh` - Doppler wrapper script
- `bootstrap/lib/steps/doppler-auth.sh` - Doppler authentication check
- `bootstrap/lib/steps/ssh-keys.sh` - SSH key retrieval from Doppler
- `bootstrap/lib/steps/ssh-config.sh` - SSH config generation
- `bootstrap/lib/steps/ssh-test.sh` - SSH connection test
- `bootstrap/lib/steps/next-steps.sh` - Success message and next steps
- `bootstrap/lib/steps/termux-main.sh` - Main orchestration function

### Manifests
- `bootstrap/manifests/configure.txt` - Component list for configure.sh
- `bootstrap/manifests/termux.txt` - Component list for termux.sh

## Files to Modify
- `justfile` - Add `mod bootstrap "tasks/bootstrap"`
- `CLAUDE.md` - Document new build system and component structure

## Files to Regenerate
- `bootstrap/configure.sh` - Built from manifest (committed to git)
- `bootstrap/termux.sh` - Built from manifest (committed to git)

## Testing Strategy

### Automated Testing
- Integration tests: `just test all` must pass identically before and after
- Focus on `just test mobile termux` since that validates termux.sh behavior
- No test file modifications required (tests run against final generated scripts)

### Manual Verification
1. Run `just bootstrap build` to generate both scripts
2. Execute generated `bootstrap/configure.sh` interactively
3. Verify JSON config file created correctly
4. Execute generated `bootstrap/termux.sh` in test environment
5. Test curl-pipe-sh pattern: `cat bootstrap/termux.sh | sh`
6. Compare side-by-side output of old vs new scripts
7. Verify idempotency (run scripts twice, second run should skip steps)

### Edge Cases
- Empty lines in manifests (should ignore)
- Comments in manifests (consider `#` prefix support)
- Missing component files (should error clearly)
- Component file permissions (should inherit from source)
- KD_NO_COLOR environment variable (test both with/without)

## Risk Assessment

### Risk 1: Line-by-line concatenation breaks context
**Mitigation**:
- Extract complete functions, not partial blocks
- Test concatenated output for syntax errors
- Add blank line between components to avoid accidental merging

### Risk 2: Variable scope issues across components
**Mitigation**:
- Keep global variables (KD_*) in dedicated components
- Document component dependencies in manifest order
- Test final script for undefined variable errors

### Risk 3: Test failures due to behavioral changes
**Mitigation**:
- Start with configure.sh (simpler, no tests)
- Manually validate before running tests
- Extract exact code, no refactoring during extraction
- Keep original files until tests pass

### Risk 4: Manifest maintenance burden
**Mitigation**:
- Simple line-delimited format (no complex syntax)
- Clear naming conventions for discoverability
- Document in CLAUDE.md
- Consider pre-commit hook to auto-rebuild

### Risk 5: Curl-pipe-sh compatibility lost
**Mitigation**:
- Commit generated files to git (not gitignored)
- Test raw GitHub URL installation
- Ensure no external dependencies in concatenation
- Validate single-file self-containment

## Estimated Complexity
**Moderate**

Rationale:
- Straightforward extraction and concatenation logic
- No complex templating or variable substitution
- Small codebase (680 total lines to modularize)
- Well-defined boundaries (functions are atomic units)
- Existing test coverage validates correctness
- Main complexity: ensuring perfect behavioral preservation during extraction

Time estimate: 3-4 hours total
- Phase 1: 30min (build system)
- Phase 2: 30min (configure.sh extraction)
- Phase 3-4: 90min (termux.sh extraction)
- Phase 5: 30min (manifests and build)
- Phase 6: 30min (testing and validation)
- Phase 7: 15min (documentation)

## Notes

### Implementation Order
Execute phases sequentially. Complete configure.sh first (simpler, no dependencies) to validate build system before tackling termux.sh.

### Component Extraction Rules
1. Extract complete functions only (preserve `function_name() { ... }` boundaries)
2. Include all comments and whitespace within function body
3. Add single blank line between concatenated components
4. Preserve exact indentation and line structure
5. No refactoring during extraction (DRY improvements happen after tests pass)

### Manifest Ordering Rules
Components must appear in dependency order:
1. Header (shebang, set -e)
2. Colors (used by logging)
3. Logging (used by steps)
4. Steps (used by installation functions)
5. Constants (CONFIG_FILE, etc.)
6. Installation step functions (order doesn't matter if self-contained)
7. Main function (calls all steps in execution order)

### Future Enhancements (Out of Scope)
- Platform detection functions in `lib/utils/platform.sh` (stub created for future)
- VM script modularization (when vm.sh implemented)
- Component-level unit tests (deferred until proven necessary)
- Build watch mode or automatic rebuilds (manual just command sufficient)
- Manifest includes or nested manifests (YAGNI)

### Code Style Preservation
- Maintain 80 char line limit where possible
- Preserve POSIX compliance (no bashisms in sh scripts)
- Keep `kd_*` function naming convention
- Maintain existing comment style and density
- No emoji additions (per CLAUDE.md guidelines)

### Agent Delegation Assessment
**Recommendation: Direct implementation**

Reasoning:
- Small scope (20-30 component files, each <50 lines)
- Mechanical extraction work (copy-paste with boundaries)
- Sequential dependencies (can't parallelize extractions)
- Need tight control over exact code preservation
- Single developer can complete in one session
- Fast iteration for testing and validation
