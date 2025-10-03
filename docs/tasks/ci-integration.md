# CI Integration

## Description

Add GitHub Actions for automated testing of bootstrap scripts. Currently tests
run locally via `just test all`, but CI integration would catch regressions
early and validate changes across different environments.

## Current State

**Testing Infrastructure:**
- Docker-based tests exist (mobile-termux, vmroot)
- `just test all` runs test suite
- Tests validate bootstrap script behavior
- No automated CI/CD pipeline

**Repository:**
- GitHub repository: kyldvs/k
- Pre-commit hooks via Husky
- Commitlint for commit message validation
- No .github/workflows/ directory

## Scope

**GitHub Actions Workflow:**
- Run tests on push/pull request
- Test on multiple platforms/environments
- Cache Docker layers for speed
- Report test results
- Fail PR if tests fail

**Test Coverage:**
- Mobile Termux bootstrap tests
- VMRoot bootstrap tests
- Future: VM user bootstrap tests
- Future: Integration tests

**Additional CI Tasks:**
- Lint shell scripts (shellcheck)
- Validate manifest files
- Check for TODO/FIXME comments
- Verify documentation is current

## Success Criteria

- [ ] GitHub Actions workflow created
- [ ] Tests run automatically on push/PR
- [ ] Test results visible in GitHub UI
- [ ] Docker layer caching configured
- [ ] CI passes for current main branch
- [ ] Documentation includes CI badge

## Implementation Notes

**Workflow File:**
```yaml
# .github/workflows/test.yml
name: Test Bootstrap Scripts

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Run mobile tests
        run: just test mobile termux

      - name: Run vmroot tests
        run: just test vmroot

      - name: Cleanup
        if: always()
        run: just test clean
```

**Shellcheck Integration:**
```yaml
      - name: Install shellcheck
        run: sudo apt-get install -y shellcheck

      - name: Lint bootstrap scripts
        run: find bootstrap/lib -name '*.sh' -exec shellcheck {} +
```

**Caching Strategy:**
```yaml
      - name: Cache Docker layers
        uses: actions/cache@v3
        with:
          path: /tmp/.buildx-cache
          key: ${{ runner.os }}-buildx-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-buildx-
```

**Badge for README:**
```markdown
[![Tests](https://github.com/kyldvs/k/actions/workflows/test.yml/badge.svg)](https://github.com/kyldvs/k/actions/workflows/test.yml)
```

## Testing Strategy

1. Create workflow file
2. Test on feature branch first
3. Verify tests run and pass
4. Optimize for speed (caching)
5. Merge to main

## Considerations

**Performance:**
- Docker layer caching critical for speed
- Parallel test execution if possible
- Timeout limits (GitHub Actions: 6 hours max)

**Cost:**
- GitHub Actions free for public repos (2000 min/month)
- Monitor usage if it grows

**Security:**
- No secrets needed for current tests
- Future: Doppler token for integration tests (use GitHub secrets)

**Test Reliability:**
- Must address vmroot test exit 255 issue first
- Flaky tests will block PRs
- Consider retry logic for transient failures

## Dependencies

- Working test suite (vmroot-test-fixes task)
- Docker available in CI environment
- Just command runner

## Related Files

- .github/workflows/test.yml (to be created)
- tasks/test/justfile (test commands)
- src/tests/ (test infrastructure)
- README.md (for badge)

## Related Tasks

- vmroot-test-fixes (blocker - must fix before CI)
- bootstrap-error-recovery (retry logic helps CI reliability)

## Priority

**Medium** - Valuable for code quality, but not blocking development.

## Incremental Approach

Phase 1: Basic workflow
- Run existing tests
- Report pass/fail

Phase 2: Enhancements
- Add shellcheck linting
- Optimize caching
- Matrix testing (multiple environments)

Phase 3: Advanced
- Integration tests with real VMs
- Performance benchmarks
- Scheduled runs (nightly)

Following "Less but Better": Start simple, add complexity only when needed.
