# Shellcheck Integration and Linting

## Description

Integrate shellcheck static analysis to align with "Less but Better" principle #9 (Good Code is Sustainable) and #8 (Good Code is Thorough). Static analysis catches bugs early, enforces best practices, and reduces cognitive load for maintainers.

## Current State

**Linting:**
- No automated shell script linting
- Code quality relies on manual review
- Potential bugs (unquoted variables, unsafe practices) can slip through
- No pre-commit enforcement

**Code Quality:**
- Scripts follow strict mode: `set -euo pipefail`
- Consistent style (2-space indent, KD_ prefix)
- POSIX-compliant where possible
- BUT: No automated verification of best practices

**Existing Hooks:**
- Husky configured for pre-commit hooks
- `just hooks pre-commit` exists (tasks/hooks/justfile)
- No shellcheck currently integrated

## Scope

**1. Install and Configure Shellcheck:**
- Add shellcheck to development dependencies
- Document installation for contributors
- Configure shellcheck rules (.shellcheckrc)

**2. Pre-commit Integration:**
- Add shellcheck to pre-commit hook
- Lint all .sh files before commit
- Fail commit if shellcheck errors found
- Allow specific warnings to be disabled with inline comments

**3. Fix Existing Issues:**
- Run shellcheck on all bootstrap scripts
- Fix or suppress violations
- Document any suppressions with rationale

**4. CI Integration:**
- Add shellcheck to GitHub Actions workflow
- Lint all shell scripts in CI
- Fail PR if linting errors

## Success Criteria

- [ ] Shellcheck installed and configured
- [ ] `.shellcheckrc` file with project rules
- [ ] Pre-commit hook runs shellcheck on modified .sh files
- [ ] All existing scripts pass shellcheck (or have documented suppressions)
- [ ] CI workflow includes shellcheck step
- [ ] Documentation updated with linting instructions
- [ ] No regressions in existing tests

## Implementation Notes

**Install Shellcheck:**
```bash
# macOS
brew install shellcheck

# Ubuntu/Debian
apt-get install shellcheck

# Termux
pkg install shellcheck
```

**Create `.shellcheckrc`:**
```bash
# .shellcheckrc - Shellcheck configuration

# Enable all optional checks
enable=all

# Disable specific checks if needed
# SC1090: Can't follow non-constant source
disable=SC1090

# SC2154: Variables sourced externally
disable=SC2154

# Severity threshold (error, warning, info, style)
severity=warning
```

**Update Pre-commit Hook:**
```bash
# tasks/hooks/justfile

[no-cd]
pre-commit:
  #!/usr/bin/env bash
  set -euo pipefail

  echo "Running pre-commit checks..."

  # Lint shell scripts
  echo "Running shellcheck..."
  files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)

  if [ -n "$files" ]; then
    if ! echo "$files" | xargs shellcheck; then
      echo "Shellcheck failed. Please fix errors before committing."
      exit 1
    fi
  fi

  echo "Pre-commit checks passed!"
```

**Common Issues to Fix:**

1. **Unquoted Variables:**
```bash
# Before
cd $HOME/bin

# After
cd "$HOME/bin"
```

2. **Useless Cat:**
```bash
# Before
cat file.txt | grep pattern

# After
grep pattern file.txt
```

3. **[ vs [[ in POSIX:**
```bash
# Before (bash-specific)
if [[ -f "$file" ]]; then

# After (POSIX)
if [ -f "$file" ]; then
```

4. **Command Substitution:**
```bash
# Before (deprecated)
var=`command`

# After (modern)
var=$(command)
```

**Inline Suppressions (when needed):**
```bash
# shellcheck disable=SC2034  # Variable used in sourced script
export KD_VERSION="1.0.0"
```

**CI Integration (GitHub Actions):**
```yaml
# .github/workflows/lint.yml
name: Lint

on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install shellcheck
        run: sudo apt-get install -y shellcheck

      - name: Lint shell scripts
        run: find . -name '*.sh' -type f -exec shellcheck {} +
```

## Testing Strategy

**Manual Testing:**
```bash
# Lint all bootstrap scripts
find bootstrap/lib -name '*.sh' -exec shellcheck {} +

# Lint specific file
shellcheck bootstrap/termux.sh

# Check with different severity
shellcheck --severity=style bootstrap/lib/utils/logging.sh
```

**Pre-commit Test:**
```bash
# Make a change to a shell script
echo "# Test comment" >> bootstrap/lib/utils/logging.sh

# Stage the change
git add bootstrap/lib/utils/logging.sh

# Trigger pre-commit hook
just hooks pre-commit

# Should lint the staged file
```

**CI Test:**
- Create PR with shell script change
- Verify CI runs shellcheck
- Verify CI fails on linting errors

## Related Principles

- **#9 Good Code is Sustainable**: Automated quality checks reduce maintenance burden
- **#8 Good Code is Thorough**: Catch edge cases and bugs early
- **#4 Good Code is Understandable**: Enforced best practices improve clarity
- **#6 Good Code is Honest**: Detect potential issues before they become bugs

## Dependencies

- Shellcheck installed (development dependency)
- Existing pre-commit hook infrastructure (Husky)
- GitHub Actions (for CI integration, see ci-integration.md)

## Related Files

- `.shellcheckrc` (new)
- `tasks/hooks/justfile` (update pre-commit recipe)
- `.github/workflows/lint.yml` (new, CI integration)
- All `.sh` files (fix violations)
- `CLAUDE.md` (document linting workflow)

## Related Tasks

- ci-integration.md (CI includes shellcheck)
- refactor-error-handling.md (shellcheck may find error handling issues)

## Priority

**Medium** - Quick to implement, high value for sustainability

## Incremental Approach

1. Install shellcheck locally
2. Create .shellcheckrc with baseline rules
3. Run shellcheck on all scripts, document violations
4. Fix critical violations (errors)
5. Suppress or fix warnings with rationale
6. Integrate into pre-commit hook
7. Test pre-commit hook locally
8. Update CLAUDE.md with linting instructions
9. Commit and push (CI integration follows separately)

## Estimated Effort

2-3 hours (assuming minimal violations to fix)

## Notes

**Philosophy:**
- Shellcheck is a tool, not a dictator
- Suppress rules when needed, but document why
- Focus on catching real bugs, not style nitpicks
- POSIX compliance preferred but not mandatory (Alpine uses bash)
- "Less but Better" applies to tooling: shellcheck adds value with minimal cost
