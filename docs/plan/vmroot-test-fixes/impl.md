# VMRoot Test Fixes - Implementation Plan

## Prerequisites
- Docker and Docker Compose installed and running
- Access to existing test infrastructure in src/tests/
- Working knowledge of Docker container capabilities and permissions
- Familiarity with Ubuntu-based container environments

## Architecture Overview

The vmroot test infrastructure mirrors the mobile test pattern with key differences:
- **Container runs as root** to create non-root users (vs. mobile tests that run as non-root)
- **No networking required** (vs. mobile tests that need mock-vm SSH connectivity)
- **Simpler Docker setup** with single container (vs. mobile tests with two-container setup)

Current structure:
```
src/tests/
├── docker-compose.vmroot.yml       # Docker Compose config (16 lines)
├── run-vmroot.sh                   # Test runner script (66 lines)
├── tests/vmroot.test.sh            # Test script (132 lines)
├── images/vmroot/Dockerfile        # Container image (18 lines)
└── fixtures/vmroot-test-config.json # Test configuration
```

The issue is exit code 255, which typically indicates:
1. Container startup failure
2. Command not found in container
3. Permission/capability issues
4. Volume mount problems

## Root Cause Analysis

Comparing vmroot (broken) vs mobile (working) Docker Compose configs:

**vmroot (16 lines):**
- Uses `sleep infinity` implicit in CMD
- Single container, no networks
- No command override specified

**mobile (41 lines):**
- Explicit `command: sleep infinity`
- Two-container setup with networking
- Health checks for dependencies

**Key difference**: The vmroot container may not be staying alive, or the test runner may be trying to execute before the container is properly initialized.

## Task Breakdown

### Phase 1: Reproduce and Diagnose (DIRECT)
Reproduce the exact failure to understand the root cause.

- [ ] Task 1.1: Run failing test and capture full output
  - Files: N/A (diagnostic only)
  - Dependencies: None
  - Command: `just test vmroot 2>&1 | tee /tmp/vmroot-test-output.log`
  - Details: Capture complete error output including Docker logs, exit codes, and any stderr messages

- [ ] Task 1.2: Verify Dockerfile builds successfully
  - Files: `src/tests/images/vmroot/Dockerfile`
  - Dependencies: None
  - Command: `docker build -f src/tests/images/vmroot/Dockerfile -t k-test-vmroot .`
  - Details: Ensure the base image builds without errors

- [ ] Task 1.3: Test container startup independently
  - Files: `src/tests/docker-compose.vmroot.yml`
  - Dependencies: Task 1.2
  - Command: `docker compose -f src/tests/docker-compose.vmroot.yml up -d && docker ps`
  - Details: Verify container starts and stays running

- [ ] Task 1.4: Test manual script execution in container
  - Files: `src/tests/tests/vmroot.test.sh`
  - Dependencies: Task 1.3
  - Command: `docker exec k-test-vmroot bash < src/tests/tests/vmroot.test.sh`
  - Details: Execute test script manually to isolate runner vs. container issues

### Phase 2: Fix Docker Configuration (DIRECT)
Apply necessary fixes to Docker Compose and Dockerfile based on diagnosis.

- [ ] Task 2.1: Add explicit command to docker-compose.vmroot.yml
  - Files: `src/tests/docker-compose.vmroot.yml`
  - Dependencies: Phase 1 complete
  - Details: Add `command: sleep infinity` to keep container alive, matching mobile test pattern

- [ ] Task 2.2: Add container capabilities if needed
  - Files: `src/tests/docker-compose.vmroot.yml`
  - Dependencies: Task 2.1
  - Details: Add `cap_add: [SYS_ADMIN]` or specific capabilities (CAP_SETUID, CAP_SETGID) if user creation fails without privileges. Start with minimal capabilities and add only if necessary.

- [ ] Task 2.3: Verify volume mounts are accessible
  - Files: `src/tests/docker-compose.vmroot.yml`
  - Dependencies: Task 2.1
  - Details: Ensure /var/www/bootstrap, /test-lib, and /fixtures are mounted correctly and readable in container

### Phase 3: Fix Test Runner (DIRECT)
Update run-vmroot.sh to handle container execution correctly.

- [ ] Task 3.1: Add container readiness verification
  - Files: `src/tests/run-vmroot.sh`
  - Dependencies: Phase 2 complete
  - Details: Replace fixed `sleep 2` with actual container health check or status verification

- [ ] Task 3.2: Fix exec command for proper input handling
  - Files: `src/tests/run-vmroot.sh`
  - Dependencies: Task 3.1
  - Details: The current `docker compose exec -T vmroot-test bash < "$test_file"` may have issues. Consider using `docker compose exec -T vmroot-test bash /test-lib/../tests/vmroot.test.sh` or copying test file into container.

- [ ] Task 3.3: Add verbose error handling
  - Files: `src/tests/run-vmroot.sh`
  - Dependencies: Task 3.2
  - Details: Capture and display Docker logs on failure for debugging

### Phase 4: Enhance Test Script (DIRECT)
Add debugging output and improve error messages.

- [ ] Task 4.1: Add verbose mode to test script
  - Files: `src/tests/tests/vmroot.test.sh`
  - Dependencies: Phase 3 complete
  - Details: Add `set -x` conditional debugging and more detailed progress messages

- [ ] Task 4.2: Verify all dependencies available
  - Files: `src/tests/tests/vmroot.test.sh`
  - Dependencies: Task 4.1
  - Details: Add checks at start of test for jq, sudo, bash, and other required tools

### Phase 5: Testing & Validation (DIRECT)
Verify all success criteria are met.

- [ ] Task 5.1: Run `just test vmroot` successfully
  - Files: N/A (validation only)
  - Dependencies: Phase 4 complete
  - Details: Execute full test suite and verify exit code 0

- [ ] Task 5.2: Run `just test all` successfully
  - Files: N/A (validation only)
  - Dependencies: Task 5.1
  - Details: Execute both mobile and vmroot tests together

- [ ] Task 5.3: Verify all test phases pass
  - Files: N/A (validation only)
  - Dependencies: Task 5.2
  - Details: Confirm user creation, sudoers, SSH keys, idempotency, and sudo functionality all validate correctly

- [ ] Task 5.4: Test cleanup works correctly
  - Files: N/A (validation only)
  - Dependencies: Task 5.3
  - Details: Run `just test clean` and verify all containers/images are removed

### Phase 6: Documentation & Commit (DIRECT)
Document changes and commit fixes.

- [ ] Task 6.1: Add comments to Docker configuration
  - Files: `src/tests/docker-compose.vmroot.yml`, `src/tests/images/vmroot/Dockerfile`
  - Dependencies: Phase 5 complete
  - Details: Explain any non-obvious configuration choices (capabilities, command, etc.)

- [ ] Task 6.2: Commit all fixes
  - Files: All modified files
  - Dependencies: Task 6.1
  - Command: `just vcs cm "fix: resolve vmroot test Docker exit 255 issues" && just vcs push`
  - Details: Single atomic commit with all fixes

## Files to Create
None - all required files exist.

## Files to Modify

**High Probability (will definitely need changes):**
- `src/tests/docker-compose.vmroot.yml` - Add explicit command, possibly capabilities
- `src/tests/run-vmroot.sh` - Improve container readiness check and exec command

**Medium Probability (may need changes):**
- `src/tests/images/vmroot/Dockerfile` - May need additional packages or configuration
- `src/tests/tests/vmroot.test.sh` - May need debugging output or dependency checks

**Low Probability (unlikely to need changes):**
- `src/tests/fixtures/vmroot-test-config.json` - Configuration appears correct
- `bootstrap/vmroot.sh` - Script is validated as working (per constraints)
- `bootstrap/vmroot-configure.sh` - Script is validated as working (per constraints)

## Testing Strategy

**Iterative testing approach:**
1. Test after each phase completion
2. Use `just test clean` between attempts to ensure clean state
3. Capture full output for each test run
4. Compare behavior with working mobile tests

**Manual verification steps:**
1. Build succeeds without errors
2. Container starts and stays running
3. Test script executes without exit 255
4. All 7 test phases complete successfully
5. Output is clear and informative
6. Cleanup removes all test artifacts

**Success validation:**
```bash
# Must all succeed with exit code 0
just test clean
just test vmroot
just test all
just test clean
```

## Risk Assessment

**Risk 1: Container needs privileged mode**
- **Impact**: Security concern, broader access than necessary
- **Mitigation**: Try specific capabilities first (CAP_SETUID, CAP_SETGID). Only use `privileged: true` as last resort.
- **Likelihood**: Low - user creation should work with specific capabilities

**Risk 2: Test script input method incompatible with Docker exec**
- **Impact**: Test script never executes, continues to exit 255
- **Mitigation**: Try multiple approaches: stdin redirect, mounted script execution, copied script
- **Likelihood**: High - this is a likely root cause based on comparison with mobile tests

**Risk 3: Volume mount permissions prevent script access**
- **Impact**: Bootstrap scripts or fixtures not readable in container
- **Mitigation**: Verify mounts with `docker exec` ls commands, adjust mount options if needed
- **Likelihood**: Medium - different permissions between host and container

**Risk 4: Init system or process reaping issues**
- **Impact**: Orphaned processes or container shutdown during tests
- **Mitigation**: Use `--init` flag or install tini in Dockerfile if needed
- **Likelihood**: Low - Ubuntu image should handle basic process management

## Implementation Notes

**Critical Insights from Code Analysis:**

1. **Docker Compose Difference**: Mobile tests use explicit `command: sleep infinity`, vmroot does not. This may cause container to exit immediately.

2. **Test Execution Method**: run-vmroot.sh uses `bash < "$test_file"` (stdin redirect) while mobile tests can use direct script execution because test lives in mounted volume.

3. **Container Environment**: Mobile tests run as non-root user (u0_a640) in Termux simulation. Vmroot tests must run as actual root to create users, requiring different security context.

4. **Working Reference**: mobile-termux.test.sh (223 lines) provides excellent pattern for test structure, assertions, and idempotency checking.

5. **Assertion Library**: Both tests use shared `/test-lib/assertions.sh` or `/lib/assertions.sh` for consistent validation patterns.

**Most Likely Fix:**
The exit 255 is almost certainly caused by missing `command: sleep infinity` in docker-compose.vmroot.yml. The container is likely exiting immediately after startup, and the test runner is trying to exec into a dead or dying container.

**Secondary Likely Fix:**
The test execution method `bash < "$test_file"` may need to be changed to execute the mounted script directly: `bash /test-lib/../tests/vmroot.test.sh` or by mounting the tests directory differently.

## Notes

- Follow principle #10: "Good Code is as Little Code as Possible" - make minimal changes
- Follow principle #8: "Good Code is Thorough" - validate all test phases work correctly
- Follow principle #6: "Good Code is Honest" - error messages should clearly indicate what failed
- The vmroot bootstrap scripts (vmroot.sh, vmroot-configure.sh) are correct and must not be modified
- Test fixtures are minimal but sufficient for validation
- Pattern consistency with mobile tests is important for maintainability
- CI compatibility means no interactive prompts or manual intervention required
