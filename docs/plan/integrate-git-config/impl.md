# Integrate Git Configuration - Implementation Plan

## Prerequisites

- Git installed (already provided by VM bootstrap)
- Access to bootstrap directory structure
- Understanding of POSIX shell scripting
- Familiarity with git config commands

## Architecture Overview

This component integrates into the existing bootstrap system as a modular step
component. It follows the established pattern used by other step components
like `ssh-keys.sh`:

**Key Integration Points:**
- Component: `bootstrap/lib/steps/git-config.sh`
- Manifest: `bootstrap/manifests/vm.txt` (to be created when vm.sh is
  implemented)
- Utilities: Uses `kd_step_start`, `kd_step_end`, `kd_step_skip` from
  `lib/utils/steps.sh`
- Tests: `src/tests/tests/vm.test.sh` (to be created as part of vm.sh
  implementation)

**Data Flow:**
1. vm.sh sources git-config.sh component
2. Component checks for existing configuration (idempotency)
3. Preserves user.name and user.email if present
4. Applies 8 workflow configuration settings
5. Restores user identity
6. Logs success or skip status

## Task Breakdown

### Phase 1: Foundation (DIRECT)

- [ ] Task 1.1: Create git-config.sh component
  - Files: `bootstrap/lib/steps/git-config.sh`
  - Dependencies: None
  - Details: Implement `configure_git` function following established pattern
    from ssh-keys.sh. Include comprehensive header comment explaining each
    configuration setting's purpose and value proposition.

### Phase 2: Core Implementation (DIRECT)

- [ ] Task 2.1: Implement idempotency check
  - Files: `bootstrap/lib/steps/git-config.sh`
  - Dependencies: Task 1.1
  - Details: Check if `merge.conflictstyle` is already set to `zdiff3` as
    marker that configuration has been applied. Use `kd_step_skip` if found.

- [ ] Task 2.2: Implement user identity preservation
  - Files: `bootstrap/lib/steps/git-config.sh`
  - Dependencies: Task 1.1
  - Details: Read existing `user.name` and `user.email` before applying config,
    store in variables for restoration after.

- [ ] Task 2.3: Apply 8 Git configuration settings
  - Files: `bootstrap/lib/steps/git-config.sh`
  - Dependencies: Task 2.2
  - Details: Use `git config --global` to set:
    - push.default = current
    - pull.ff = true
    - merge.ff = true
    - merge.conflictstyle = zdiff3
    - init.defaultBranch = main
    - diff.algorithm = histogram
    - log.date = iso
    - core.autocrlf = false

- [ ] Task 2.4: Restore user identity
  - Files: `bootstrap/lib/steps/git-config.sh`
  - Dependencies: Task 2.3
  - Details: Re-apply user.name and user.email if they existed before
    configuration.

- [ ] Task 2.5: Add error handling
  - Files: `bootstrap/lib/steps/git-config.sh`
  - Dependencies: Task 2.4
  - Details: Check git command availability, handle config failures gracefully,
    use appropriate exit codes.

### Phase 3: Integration Preparation (DIRECT)

- [ ] Task 3.1: Create vm.txt manifest
  - Files: `bootstrap/manifests/vm.txt`
  - Dependencies: Task 2.5
  - Details: Create manifest following pattern from termux.txt and vmroot.txt.
    Include header, utilities, and git-config step. This will be used when
    vm.sh is fully implemented.

- [ ] Task 3.2: Document integration in vm.sh stub
  - Files: `bootstrap/vm.sh`
  - Dependencies: Task 3.1
  - Details: Update stub comments to reference git-config component as planned
    feature. Do not implement full vm.sh (out of scope).

### Phase 4: Testing & Validation (DIRECT)

- [ ] Task 4.1: Create vm.test.sh test file
  - Files: `src/tests/tests/vm.test.sh`
  - Dependencies: Task 3.1
  - Details: Create test file following pattern from vmroot.test.sh. Initially
    test only git-config component since vm.sh is stub.

- [ ] Task 4.2: Add git-config test assertions
  - Files: `src/tests/tests/vm.test.sh`
  - Dependencies: Task 4.1
  - Details: Add test phases:
    - Setup: Set initial user.name and user.email
    - Run: Source git-config.sh and call configure_git
    - Validate: Check all 8 config values using `git config --global --get`
    - Validate: Check user.name and user.email preserved
    - Idempotency: Run again, verify skip message
    - Cleanup: Verify no errors or warnings

- [ ] Task 4.3: Add test fixtures
  - Files: `src/tests/fixtures/vm-test-config.json` (if needed)
  - Dependencies: Task 4.2
  - Details: Add any required test fixtures following existing patterns.

- [ ] Task 4.4: Update test runner justfile
  - Files: `src/tests/justfile`
  - Dependencies: Task 4.3
  - Details: Add `just test vm` command following pattern from `just test
    vmroot`.

- [ ] Task 4.5: Run tests and validate
  - Files: N/A (command execution)
  - Dependencies: Task 4.4
  - Details: Execute `just test vm`, verify all assertions pass, fix any
    failures.

### Phase 5: Build System Integration (DIRECT)

- [ ] Task 5.1: Update bootstrap build to include vm.sh
  - Files: `src/build/justfile`, `src/build/build-bootstrap.sh`
  - Dependencies: Task 4.5
  - Details: Add vm.sh to build manifest and builder. Follow pattern from
    termux.sh and vmroot.sh builds. This enables `just bootstrap build vm`.

- [ ] Task 5.2: Build vm.sh script
  - Files: `bootstrap/vm.sh` (generated)
  - Dependencies: Task 5.1
  - Details: Run `just bootstrap build vm` to generate vm.sh from manifest.
    Verify git-config component included correctly.

- [ ] Task 5.3: Validate generated script
  - Files: N/A (verification)
  - Dependencies: Task 5.2
  - Details: Inspect generated bootstrap/vm.sh, verify git-config.sh content
    present, check for syntax errors.

## Files to Create

- `bootstrap/lib/steps/git-config.sh` - Git configuration component (main
  deliverable)
- `bootstrap/manifests/vm.txt` - VM bootstrap manifest including git-config
  step
- `src/tests/tests/vm.test.sh` - Test suite for VM bootstrap (initially just
  git-config)
- `src/tests/fixtures/vm-test-config.json` - Test fixtures (if needed for VM
  tests)

## Files to Modify

- `bootstrap/vm.sh` - Update stub comments to reference git-config (minimal
  change, real implementation later)
- `src/tests/justfile` - Add `test vm` recipe
- `src/build/justfile` - Add vm build target
- `src/build/build-bootstrap.sh` - Include vm.sh in build process

## Testing Strategy

**Unit Testing (Component Level):**
- Test git-config.sh in isolation via vm.test.sh
- Verify all 8 config values applied correctly
- Test user identity preservation
- Test idempotency (second run skips)
- Test error handling (git not installed, config failures)

**Integration Testing:**
- Currently limited since vm.sh is stub
- Tests run via Docker Compose: `just test vm`
- Uses Ubuntu container with Git installed
- Assertions validate config file contents and git command output

**Manual Verification Steps:**
1. Run `just bootstrap build vm` to generate script
2. Inspect `bootstrap/vm.sh` for git-config.sh inclusion
3. Run `just test vm` and verify all tests pass
4. Shellcheck validation via pre-commit hooks
5. Review test output for proper logging (→, ✓, ○ symbols)

**Edge Cases to Test:**
- User with no existing .gitconfig
- User with existing .gitconfig but no user.name/email
- User with existing .gitconfig including user.name/email
- Running twice (idempotency)
- Git not installed (should fail gracefully with clear error)

## Risk Assessment

**Risk 1: Git version compatibility**
- Description: Different Git versions may not support all config options
  (especially zdiff3)
- Mitigation: Target Ubuntu 24.04 LTS which has Git 2.43+. Add version check
  if needed.
- Impact: Low (zdiff3 available in Git 2.35+, Ubuntu 24.04 has 2.43+)

**Risk 2: Overwriting user customizations**
- Description: User may have existing Git config we shouldn't overwrite
- Mitigation: Only set the 8 specific values, preserve everything else
  including user identity. Document which settings are applied.
- Impact: Low (surgical approach preserves user customizations)

**Risk 3: vm.sh not yet implemented**
- Description: Cannot test full integration until vm.sh is complete
- Mitigation: Test component in isolation, create manifest/structure for easy
  integration later. Ensure component is standalone and testable.
- Impact: Low (component design allows standalone testing)

**Risk 4: POSIX compliance**
- Description: Shell script must work across different shells
- Mitigation: Use POSIX-compliant constructs, avoid bashisms, test with sh not
  bash. Pre-commit shellcheck validation.
- Impact: Low (existing patterns are POSIX-compliant)

**Risk 5: Config file corruption**
- Description: git config commands might fail partway through
- Mitigation: git config is atomic per-setting. Idempotency check prevents
  partial re-application. Test error scenarios.
- Impact: Low (git config is robust, and we check before applying)

## Notes

**Implementation Considerations:**

1. **Idempotency Strategy:** Use `merge.conflictstyle` as marker since it's
   unlikely to be set by users, and we set it to a specific value (zdiff3).
   More robust than checking for all 8 values.

2. **POSIX Compliance:** Must work with `/bin/sh`, not just bash:
   - Use `[ ]` not `[[ ]]`
   - Use `$(command)` not backticks
   - Avoid arrays, use variables
   - Test with `shellcheck` for POSIX compliance

3. **Logging Pattern:** Follow existing step functions exactly:
   ```sh
   kd_step_start "git-config" "Configuring Git with sensible defaults"
   kd_log "Applying configuration setting: push.default = current"
   kd_step_end
   ```

4. **Error Handling:** Check if git is installed at start:
   ```sh
   if ! command -v git >/dev/null 2>&1; then
     kd_error "Git is not installed"
     return 1
   fi
   ```

5. **Performance:** All operations are local git config commands, execution
   time will be under 100ms typically.

6. **Security:** No sensitive data involved. Config settings are public
   workflow preferences.

7. **Future Enhancements (Out of Scope):**
   - Allow users to override settings via config file
   - Sync additional settings from dotfiles repo
   - Configure Git aliases
   - Setup commit signing

**Why These 8 Settings:**

Each setting solves a specific pain point:
- `push.default = current` - Eliminates "no upstream branch" errors
- `pull.ff = true` - Prevents unexpected merge commits on pull
- `merge.ff = true` - Fast-forward when possible, cleaner history
- `merge.conflictstyle = zdiff3` - Shows common ancestor context in conflicts
- `init.defaultBranch = main` - Modern convention, matches GitHub
- `diff.algorithm = histogram` - More intuitive diffs, better move detection
- `log.date = iso` - Consistent, parseable timestamp format
- `core.autocrlf = false` - Prevents line ending issues on Linux/Unix

**Component Design Rationale:**

Following "Less but Better" principle:
- Single responsibility: Configure Git workflow settings only
- Minimal complexity: Simple shell functions, no external dependencies
- Clear boundaries: Doesn't touch identity, aliases, or credentials
- Idempotent: Safe to run multiple times
- Observable: Clear logging at each step
- Testable: Isolated component can be tested independently
