# Shellcheck Integration - Specification

## Overview
Integrate shellcheck static analysis into the development workflow to automatically enforce shell scripting best practices, catch potential bugs early, and improve code sustainability. This tool will run as part of pre-commit hooks and CI pipelines to ensure all shell scripts meet quality standards.

## Goals
- Automate shell script quality checks to reduce manual review burden
- Catch common shell scripting bugs (unquoted variables, unsafe practices) before they reach production
- Enforce POSIX-compliance and best practices across ~45 shell scripts
- Integrate quality gates into pre-commit hooks and CI workflow
- Align with "Less but Better" principles #8 (Thorough) and #9 (Sustainable)

## Requirements

### Functional Requirements
- FR-1: Shellcheck must lint all `.sh` files in the repository
- FR-2: Pre-commit hook must run shellcheck on staged shell scripts and block commits with errors
- FR-3: Developers can suppress specific warnings with inline comments and rationale
- FR-4: CI pipeline must run shellcheck on all shell scripts and fail PRs with violations
- FR-5: Configuration file (`.shellcheckrc`) must define project-wide linting rules

### Non-Functional Requirements
- NFR-1: Linting must complete in <5 seconds for typical pre-commit operations (1-3 files)
- NFR-2: Zero false positives blocking commits (suppressions available for edge cases)
- NFR-3: All existing tests must continue to pass after fixes applied
- NFR-4: Clear error messages guide developers to fix issues

### Technical Requirements
- Shellcheck installed as development dependency (not runtime)
- `.shellcheckrc` configuration file with severity threshold: warning or higher
- Integration with existing Husky + lint-staged pre-commit infrastructure
- GitHub Actions workflow for CI integration
- Support for inline suppressions: `# shellcheck disable=SC####`

## User Stories / Use Cases

**As a developer**, I want shellcheck to run automatically on commit so that I catch scripting errors before pushing code.

**As a maintainer**, I want CI to validate shell scripts so that PRs with linting violations are automatically rejected.

**As a contributor**, I want clear error messages from shellcheck so that I understand what needs to be fixed and why.

**As a code reviewer**, I want consistent code quality so that I can focus on logic rather than style and safety issues.

## Success Criteria

- [ ] Shellcheck installed and documented in README or CLAUDE.md
- [ ] `.shellcheckrc` configuration file created with project rules
- [ ] Pre-commit hook runs shellcheck on staged `.sh` files via lint-staged
- [ ] All 45+ existing shell scripts pass shellcheck or have documented suppressions
- [ ] GitHub Actions workflow includes shellcheck job that fails on violations
- [ ] CLAUDE.md updated with linting workflow documentation
- [ ] All existing tests pass (`just test all`)
- [ ] Manual testing confirms pre-commit hook blocks bad commits

## Constraints

- **POSIX Compliance**: Prefer POSIX-compliant patterns, but allow bash-specific features where necessary (Alpine uses bash)
- **No Breaking Changes**: Fixes must not alter script behavior or break existing tests
- **Inline Suppressions**: Allowed for externally-sourced variables (SC2154) and non-constant sources (SC1090), but must include comment explaining rationale
- **Development-Only**: Shellcheck is a development tool and not required in production/runtime environments (Termux, VM)

## Implementation Phases

### Phase 1: Install and Configure (0.5 hours)
1. Document shellcheck installation for macOS, Ubuntu/Debian, Termux
2. Create `.shellcheckrc` with baseline rules:
   - `enable=all` (enable optional checks)
   - `severity=warning` (ignore style-only issues)
   - `disable=SC1090,SC2154` (common suppressions for sourced scripts)
3. Test shellcheck manually on sample scripts

### Phase 2: Fix Existing Violations (1-1.5 hours)
1. Run shellcheck on all shell scripts: `find . -name '*.sh' -exec shellcheck {} +`
2. Categorize violations: errors vs warnings vs suppressible
3. Fix common issues:
   - Quote variables: `cd "$HOME/bin"` not `cd $HOME/bin`
   - Remove useless cats: `grep pattern file` not `cat file | grep pattern`
   - Use modern command substitution: `$(cmd)` not `` `cmd` ``
   - POSIX test syntax: `[ -f "$file" ]` not `[[ -f "$file" ]]` (where applicable)
4. Add inline suppressions with rationale for edge cases
5. Verify all tests still pass: `just test all`

### Phase 3: Pre-commit Integration (0.5 hours)
1. Update `tasks/hooks/justfile` to add shellcheck to `lint-files` recipe
2. Configure lint-staged in `package.json` to run shellcheck on `*.sh` files
3. Test pre-commit hook locally:
   - Make breaking change to shell script
   - Stage file and attempt commit
   - Verify hook blocks commit with clear error
4. Test idempotency: clean commits pass through quickly

### Phase 4: CI Integration (0.5 hours)
1. Create `.github/workflows/lint.yml` with shellcheck job
2. Install shellcheck in CI: `apt-get install shellcheck`
3. Run shellcheck on all scripts: `find . -name '*.sh' -exec shellcheck {} +`
4. Test CI by creating PR with intentional violation
5. Verify CI fails and provides clear feedback

### Phase 5: Documentation (0.5 hours)
1. Update CLAUDE.md with shellcheck workflow
2. Document how to suppress warnings with inline comments
3. Add troubleshooting section for common issues
4. Update "Quick Reference" with shellcheck commands

## Non-Goals

Explicitly out of scope:
- **Linting non-shell scripts**: Justfiles, Dockerfiles, or other config files
- **Retroactive fixing of old commits**: Only current HEAD matters
- **Style-only violations**: Focus on bugs/safety, not cosmetic issues
- **Strict POSIX enforcement**: Allow bash-specific features where beneficial
- **Automated fixing**: Developers fix issues manually (no `shellcheck --fix`)

## Assumptions

- Developers have or can install shellcheck locally (documented in README)
- Husky and lint-staged infrastructure already works (validated in codebase)
- GitHub Actions can install shellcheck via apt-get (standard Ubuntu runner)
- Existing shell scripts follow strict mode: `set -euo pipefail`
- Pre-commit hooks have <10 second tolerance for developer workflow

## Open Questions

- **Q1**: Should we enforce shellcheck on bootstrap build artifacts (`configure.sh`, `termux.sh`, etc.) or only source files in `bootstrap/lib/`?
  - **Decision Needed**: If build artifacts, ensure build process preserves shellcheck compliance

- **Q2**: What severity threshold: `error`, `warning`, `info`, or `style`?
  - **Recommendation**: Start with `warning` to focus on real issues, exclude style nitpicks

- **Q3**: Should CI run shellcheck on all files or only changed files?
  - **Recommendation**: All files (fast enough for 45 scripts, prevents regression)

## Related Files

**New Files:**
- `.shellcheckrc` (shellcheck configuration)
- `.github/workflows/lint.yml` (CI workflow)

**Modified Files:**
- `tasks/hooks/justfile` (add shellcheck to lint-files)
- `CLAUDE.md` (document linting workflow)
- All `bootstrap/lib/**/*.sh` and test files (fix violations)

## Dependencies

- **Shellcheck**: Static analysis tool (external dependency)
- **Husky + lint-staged**: Pre-commit infrastructure (already installed)
- **GitHub Actions**: CI platform (available)
- **Just**: Task runner (already in use)

## Related Tasks

- **ci-integration.md**: GitHub Actions workflow depends on shellcheck being ready
- **refactor-error-handling.md**: Shellcheck may surface error handling bugs
- **vmroot-test-fixes.md**: Tests must pass before/after shellcheck fixes

## Priority

**Medium** - Quick to implement (2-3 hours), high value for code sustainability and automated quality checks. Aligns with "Less but Better" principle #9 (Good Code is Sustainable).

## Estimated Effort

**2-3 hours total** assuming minimal violations requiring manual fixes.

## Risk Assessment

**Low Risk:**
- Non-invasive: linting doesn't change runtime behavior
- Incremental: can fix violations file-by-file
- Reversible: can disable shellcheck if issues arise
- Well-tested: existing test suite validates fixes

**Mitigation:**
- Run full test suite after every batch of fixes
- Use inline suppressions for false positives
- Document all suppressions with rationale
