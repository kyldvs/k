# Shellcheck Integration - Implementation Plan

## Prerequisites
- **Shellcheck installed**: ✅ Version 0.10.0 confirmed
- **Git repository**: ✅ Clean working directory
- **Pre-commit infrastructure**: ✅ Husky + lint-staged configured
- **Test suite**: ✅ `just test all` available

## Architecture Overview

This implementation integrates shellcheck into the existing development workflow:

### Current State
- **51 shell scripts** in repository (bootstrap lib, test files, built artifacts)
- **Pre-commit hooks**: Husky + lint-staged in `tasks/hooks/justfile`
- **Current linting**: Only ensures newline at EOF (`_ensure-newlines` recipe)
- **No CI**: `.github/` directory doesn't exist yet

### Integration Points
1. **`.shellcheckrc`**: Root-level config file (new)
2. **`tasks/hooks/justfile`**: Add shellcheck to `lint-files` recipe
3. **Bootstrap lib files**: 22 source files in `bootstrap/lib/` (sourced, no shebang)
4. **Built artifacts**: `bootstrap/{configure,termux,vmroot-configure,vmroot}.sh` (generated from manifests)
5. **Test files**: `src/tests/**/*.sh` (executable scripts with shebangs)
6. **`.github/workflows/lint.yml`**: CI integration (new)

### Key Decisions
- **Lint source files only**: Check `bootstrap/lib/**/*.sh` and `src/tests/**/*.sh`, skip built artifacts (already validated at source)
- **Suppress SC2148**: Bootstrap lib files are sourced, not executed (no shebang needed)
- **Suppress SC2034**: Variables used in sourced/concatenated contexts
- **Severity: warning**: Ignore style-only issues, focus on bugs/safety

## Task Breakdown

### Phase 1: Configuration & Baseline (30 minutes)

- [ ] **Task 1.1**: Create `.shellcheckrc` configuration file
  - Files: `.shellcheckrc` (new)
  - Dependencies: None
  - Details:
    ```bash
    # Enable all optional checks
    enable=all

    # Ignore sourced files without shebangs (bootstrap lib components)
    disable=SC2148

    # Ignore unused variables (used in sourced/concatenated scripts)
    disable=SC2034

    # Severity threshold: ignore info/style, focus on warnings/errors
    severity=warning
    ```
  - Implementation: DIRECT

- [ ] **Task 1.2**: Run baseline shellcheck audit
  - Files: All `*.sh` files
  - Dependencies: Task 1.1
  - Details: Generate violation report to understand scope
    ```bash
    find bootstrap/lib src/tests -name '*.sh' -exec shellcheck {} + > /tmp/shellcheck-baseline.txt 2>&1
    ```
  - Implementation: DIRECT

- [ ] **Task 1.3**: Categorize violations by type and severity
  - Files: `/tmp/shellcheck-baseline.txt`
  - Dependencies: Task 1.2
  - Details: Group by SC code, prioritize errors > warnings
  - Implementation: DIRECT

### Phase 2: Fix Shell Script Violations (60-90 minutes)

- [ ] **Task 2.1**: Fix SC2155 violations (declare and assign separately)
  - Files: `bootstrap/lib/utils/vmroot-validate.sh` and others with pattern
  - Dependencies: Task 1.3
  - Details: Split `local var=$(cmd)` into `local var; var=$(cmd)`
  - Example:
    ```bash
    # Before
    local parent_dir=$(dirname "$homedir")

    # After
    local parent_dir
    parent_dir=$(dirname "$homedir")
    ```
  - Implementation: DIRECT

- [ ] **Task 2.2**: Add inline suppressions for false positives
  - Files: All `bootstrap/lib/**/*.sh` files
  - Dependencies: Task 2.1
  - Details: Add `# shellcheck disable=SC####` with rationale for:
    - SC2034: Variables used in concatenated/sourced context
    - Any other justified suppressions discovered in baseline
  - Example:
    ```bash
    # shellcheck disable=SC2034  # Used by sourced scripts
    CONFIG_FILE="$HOME/.config/kyldvs/k/configure.json"
    ```
  - Implementation: DIRECT

- [ ] **Task 2.3**: Fix quote-related violations
  - Files: Various shell scripts with unquoted variables
  - Dependencies: Task 2.2
  - Details: Ensure all variable expansions are quoted: `"$var"` not `$var`
  - Implementation: DIRECT

- [ ] **Task 2.4**: Fix command substitution syntax (if any)
  - Files: Scripts using backticks
  - Dependencies: Task 2.3
  - Details: Replace `` `cmd` `` with `$(cmd)`
  - Implementation: DIRECT

- [ ] **Task 2.5**: Verify all scripts pass shellcheck
  - Files: All source files in `bootstrap/lib/` and `src/tests/`
  - Dependencies: Task 2.4
  - Details:
    ```bash
    find bootstrap/lib src/tests -name '*.sh' -exec shellcheck {} +
    ```
  - Expected: Exit code 0 (no violations)
  - Implementation: DIRECT

- [ ] **Task 2.6**: Run full test suite to validate fixes
  - Files: All test files
  - Dependencies: Task 2.5
  - Details: `just test all` must pass (no regressions)
  - Implementation: DIRECT

### Phase 3: Pre-commit Integration (30 minutes)

- [ ] **Task 3.1**: Add shellcheck recipe to `tasks/hooks/justfile`
  - Files: `tasks/hooks/justfile`
  - Dependencies: Task 2.6
  - Details: Add `_shellcheck` recipe before `_ensure-newlines`:
    ```just
    [no-cd]
    @lint-files *files:
      just hooks _shellcheck {{files}}
      just hooks _ensure-newlines {{files}}

    [no-cd]
    _shellcheck *files:
      #!/usr/bin/env bash
      shfiles=()
      for file in {{files}}; do
        if [[ "$file" == *.sh ]]; then
          shfiles+=("$file")
        fi
      done
      if [ ${#shfiles[@]} -gt 0 ]; then
        shellcheck "${shfiles[@]}"
      fi
    ```
  - Implementation: DIRECT

- [ ] **Task 3.2**: Test pre-commit hook with clean file
  - Files: Any existing shell script
  - Dependencies: Task 3.1
  - Details:
    ```bash
    echo "# Test" >> bootstrap/lib/utils/logging.sh
    git add bootstrap/lib/utils/logging.sh
    just hooks pre-commit
    git restore bootstrap/lib/utils/logging.sh
    ```
  - Expected: Hook passes, no errors
  - Implementation: DIRECT

- [ ] **Task 3.3**: Test pre-commit hook with violation
  - Files: Temporary test file
  - Dependencies: Task 3.2
  - Details: Create file with unquoted variable, stage, verify hook blocks commit
    ```bash
    echo 'cd $HOME' > /tmp/test-bad.sh
    git add /tmp/test-bad.sh
    just hooks pre-commit  # Should fail with shellcheck error
    git restore --staged /tmp/test-bad.sh
    ```
  - Expected: Hook fails with clear shellcheck error message
  - Implementation: DIRECT

- [ ] **Task 3.4**: Verify idempotency and performance
  - Files: N/A
  - Dependencies: Task 3.3
  - Details: Time pre-commit hook on clean commit (should be <5 seconds)
  - Implementation: DIRECT

### Phase 4: CI Integration (30 minutes)

- [ ] **Task 4.1**: Create `.github/workflows/` directory structure
  - Files: `.github/workflows/` (new directory)
  - Dependencies: Task 3.4
  - Details: `mkdir -p .github/workflows`
  - Implementation: DIRECT

- [ ] **Task 4.2**: Create GitHub Actions lint workflow
  - Files: `.github/workflows/lint.yml` (new)
  - Dependencies: Task 4.1
  - Details: Create workflow that runs on push/PR:
    ```yaml
    name: Lint

    on:
      push:
        branches: [main]
      pull_request:
        branches: [main]

    jobs:
      shellcheck:
        name: Shellcheck
        runs-on: ubuntu-latest
        steps:
          - name: Checkout code
            uses: actions/checkout@v4

          - name: Install shellcheck
            run: sudo apt-get update && sudo apt-get install -y shellcheck

          - name: Run shellcheck on bootstrap lib
            run: find bootstrap/lib -name '*.sh' -type f -exec shellcheck {} +

          - name: Run shellcheck on test scripts
            run: find src/tests -name '*.sh' -type f -exec shellcheck {} +
    ```
  - Implementation: DIRECT

- [ ] **Task 4.3**: Validate CI workflow syntax
  - Files: `.github/workflows/lint.yml`
  - Dependencies: Task 4.2
  - Details: Use GitHub CLI or online validator to check YAML syntax
  - Implementation: DIRECT

- [ ] **Task 4.4**: Test CI workflow locally (optional)
  - Files: N/A
  - Dependencies: Task 4.3
  - Details: Use `act` tool or wait for first push to test in real CI
  - Implementation: DIRECT (if act available) or SKIP

### Phase 5: Documentation (30 minutes)

- [ ] **Task 5.1**: Update CLAUDE.md with shellcheck workflow
  - Files: `CLAUDE.md`
  - Dependencies: Task 4.2
  - Details: Add new section after "Version Control":
    ```markdown
    ## Shellcheck Integration

    All shell scripts are linted with shellcheck to catch bugs and enforce best practices.

    ### Pre-commit
    - Shellcheck runs automatically on staged `.sh` files
    - Commit blocked if violations found
    - Fix errors or add inline suppressions with rationale

    ### Manual Linting
    ```bash
    # Lint all source scripts
    find bootstrap/lib src/tests -name '*.sh' -exec shellcheck {} +

    # Lint specific file
    shellcheck path/to/script.sh
    ```

    ### Inline Suppressions
    For false positives or justified exceptions:
    ```bash
    # shellcheck disable=SC2034  # Variable used in sourced context
    export MY_VAR="value"
    ```

    ### Common Issues
    - **SC2155**: Declare and assign separately: `local var; var=$(cmd)`
    - **SC2086**: Quote variables: `"$var"` not `$var`
    - **SC2006**: Use `$(cmd)` not `` `cmd` ``
    ```
  - Implementation: DIRECT

- [ ] **Task 5.2**: Update Quick Reference with shellcheck commands
  - Files: `CLAUDE.md`
  - Dependencies: Task 5.1
  - Details: Add to Quick Reference section:
    ```markdown
    just hooks lint-files *.sh  # Lint specific files
    shellcheck script.sh        # Direct shellcheck
    ```
  - Implementation: DIRECT

### Phase 6: Validation & Commit (15 minutes)

- [ ] **Task 6.1**: Run full test suite final validation
  - Files: All test files
  - Dependencies: Task 5.2
  - Details: `just test all` must pass
  - Implementation: DIRECT

- [ ] **Task 6.2**: Verify all success criteria met
  - Files: N/A
  - Dependencies: Task 6.1
  - Details: Check spec.md success criteria:
    - [x] Shellcheck installed and documented
    - [x] `.shellcheckrc` created
    - [x] Pre-commit hook integrated
    - [x] All scripts pass shellcheck
    - [x] GitHub Actions workflow created
    - [x] CLAUDE.md updated
    - [x] Tests pass
    - [x] Pre-commit blocking tested
  - Implementation: DIRECT

- [ ] **Task 6.3**: Commit all changes
  - Files: All modified files
  - Dependencies: Task 6.2
  - Details: `just vcs cm "feat: integrate shellcheck linting" && just vcs push`
  - Implementation: DIRECT

## Files to Create

- `.shellcheckrc` - Shellcheck configuration
- `.github/workflows/lint.yml` - CI workflow for shellcheck
- `.github/workflows/` - Directory for GitHub Actions

## Files to Modify

- `tasks/hooks/justfile` - Add `_shellcheck` recipe to `lint-files`
- `CLAUDE.md` - Document shellcheck workflow and common issues
- `bootstrap/lib/**/*.sh` - Fix violations, add suppressions (20+ files)
- `src/tests/**/*.sh` - Fix violations if any (5-10 files)

## Testing Strategy

### Unit-level Validation
- **Shellcheck baseline**: All scripts pass before pre-commit integration
- **Individual file testing**: `shellcheck path/to/file.sh` on each fixed file

### Integration Testing
- **Pre-commit hook**: Test with clean and violating commits
- **Performance**: Verify hook completes in <5 seconds for typical commits
- **Idempotency**: Multiple runs on clean code produce no changes

### End-to-End Testing
- **Full test suite**: `just test all` passes after all fixes
- **CI workflow**: Push to branch, verify GitHub Actions runs shellcheck
- **PR workflow**: Create test PR with violation, verify CI blocks merge

### Manual Verification Steps
1. Fix all shellcheck violations locally
2. Stage changes and run `just hooks pre-commit` (should pass)
3. Create intentional violation in test file
4. Run pre-commit hook (should fail with clear message)
5. Remove violation, verify hook passes
6. Push changes, verify CI runs successfully

## Risk Assessment

### Risk 1: Shellcheck false positives block valid code
- **Likelihood**: Low (suppressions available)
- **Impact**: Medium (developer friction)
- **Mitigation**:
  - Add inline suppressions with rationale
  - Update `.shellcheckrc` to disable problematic rules globally
  - Document common suppressions in CLAUDE.md

### Risk 2: Fixes break script behavior
- **Likelihood**: Low (linting doesn't change logic)
- **Impact**: High (broken bootstrap/test scripts)
- **Mitigation**:
  - Run full test suite after every batch of fixes
  - Review each fix carefully (especially quoting changes)
  - Test idempotency of bootstrap scripts in Docker

### Risk 3: Pre-commit hook too slow
- **Likelihood**: Very Low (51 files, shellcheck is fast)
- **Impact**: Medium (developer frustration)
- **Mitigation**:
  - Only lint staged files, not entire repo
  - Measure actual performance in Task 3.4
  - Consider parallel linting if needed (unlikely)

### Risk 4: Bootstrap build artifacts fail shellcheck
- **Likelihood**: Low (source files already linted)
- **Impact**: Low (can exclude from linting)
- **Mitigation**:
  - Focus linting on source files in `bootstrap/lib/`
  - Built artifacts inherit compliance from sources
  - Test build process: `just bootstrap build-all`

## Estimated Complexity

**Moderate**

**Rationale:**
- Most tasks are straightforward (config, documentation)
- Fixing violations depends on baseline audit (30-60 violations estimated)
- Pre-commit integration is well-understood (existing pattern)
- CI setup is simple (standard GitHub Actions)
- Low risk of breaking changes (tests validate)

**Time estimate validated:**
- Phase 1: 30 min (config + audit)
- Phase 2: 60-90 min (fix violations - depends on baseline)
- Phase 3: 30 min (pre-commit hook)
- Phase 4: 30 min (CI setup)
- Phase 5: 30 min (documentation)
- Phase 6: 15 min (validation)

**Total: 2.5-3.5 hours** (spec estimate: 2-3 hours)

## Implementation Strategy

### Recommended Approach: DIRECT
All tasks suitable for direct implementation:
- Small scope (1-4 files per task)
- Clear patterns from existing code
- Low complexity changes
- Rapid iteration needed for fix validation

### Task Dependencies
```
Phase 1: Sequential (1.1 → 1.2 → 1.3)
Phase 2: Sequential (2.1 → 2.2 → 2.3 → 2.4 → 2.5 → 2.6)
Phase 3: Sequential (3.1 → 3.2 → 3.3 → 3.4)
Phase 4: Sequential (4.1 → 4.2 → 4.3 → 4.4)
Phase 5: Sequential (5.1 → 5.2)
Phase 6: Sequential (6.1 → 6.2 → 6.3)
```

No opportunities for parallel work (each phase builds on previous).

## Notes

### Bootstrap Build System
- Bootstrap scripts are **concatenated from lib components** (manifests in `bootstrap/manifests/`)
- Linting source files (`bootstrap/lib/**/*.sh`) ensures built artifacts are clean
- Pre-commit hook runs `just bootstrap build-all` before linting
- Focus shellcheck on source files, not built artifacts

### Sourced vs Executable Scripts
- **Sourced files** (bootstrap/lib): No shebang, SC2148 disabled globally
- **Executable scripts** (tests, built artifacts): Have shebang, SC2148 applies

### Common Shellcheck Patterns to Fix
Based on initial audit sample:
1. **SC2155**: Declare and assign separately (multiple instances)
2. **SC2034**: Unused variable warnings (needs suppressions)
3. **SC2148**: Missing shebang (needs global disable)

### Performance Considerations
- Shellcheck on 51 files: ~1-2 seconds total
- Pre-commit only lints staged files: <1 second typical
- CI lints all files: ~2-3 seconds (acceptable)

### Future Enhancements (Out of Scope)
- Shellcheck integration in VS Code (developer preference)
- Auto-fixing with `shellcheck -f diff` (risky, manual preferred)
- Linting Justfiles (different tool needed)
