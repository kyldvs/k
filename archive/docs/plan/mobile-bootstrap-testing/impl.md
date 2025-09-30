# Mobile Bootstrap Testing - Implementation Plan

## Prerequisites
- Docker and Docker Compose installed locally
- Official termux/termux-docker:x86_64 image available
- Existing test infrastructure in `src/tests/`
- Bootstrap scripts implemented (`bootstrap/configure.sh`, `bootstrap/termux.sh`)
- SSH key generation tool (ssh-keygen)

## Architecture Overview

This extends the existing Docker-based test infrastructure to support the new config-driven mobile bootstrap system. Unlike the old part-based system, the mobile bootstrap requires:
- Runtime configuration file (not compiled)
- Doppler CLI integration (mocked)
- SSH connectivity to VM (mocked)
- Non-interactive execution

**Key Integration Points:**
- Reuse existing assertions library (`src/tests/lib/assertions.sh`)
- Extend Termux Dockerfile to install mock doppler
- Create new Docker Compose setup for multi-container orchestration
- Add new test runner script pattern for compose-based tests
- Integrate with existing justfile test commands

**Data Flow:**
1. Docker Compose starts termux-test + mock-vm containers
2. Test script creates config file in termux-test
3. Mock doppler wrapper installed in termux-test
4. Bootstrap script runs, fetches "secrets" from mock doppler
5. SSH keys written, config generated
6. SSH connection tested against mock-vm
7. Assertions validate all steps completed correctly

## Task Breakdown

### Phase 1: Test Fixtures & Mocks
- [ ] Task 1.1: Generate test SSH key pair
  - Files: `src/tests/fixtures/test-ssh-key`, `src/tests/fixtures/test-ssh-key.pub`
  - Dependencies: None
  - Details: Use ssh-keygen to create ed25519 key pair, no passphrase, clear naming
  - Command: `ssh-keygen -t ed25519 -f test-ssh-key -N "" -C "test@k-mobile-bootstrap"`
  - Safety: Add to .gitignore pattern, ensure not used elsewhere

- [ ] Task 1.2: Create test configuration JSON fixture
  - Files: `src/tests/fixtures/test-config.json`
  - Dependencies: None
  - Details: Static config pointing to mock-vm, uses test keys from doppler mock
  - Content: VM hostname=mock-vm, port=22, username=testuser, doppler project/env

- [ ] Task 1.3: Create doppler mock script
  - Files: `src/tests/fixtures/doppler-mock.sh`
  - Dependencies: Task 1.1
  - Details: Shell script mimicking doppler CLI behavior
  - Implements: `configure get token`, `secrets get SSH_GH_VM_PUBLIC/PRIVATE`
  - Returns: Test SSH keys from fixtures, mock token for auth checks

- [ ] Task 1.4: Update .gitignore for test fixtures
  - Files: `.gitignore`
  - Dependencies: Task 1.1
  - Details: Ignore test SSH keys (src/tests/fixtures/test-ssh-key*)
  - Pattern: Safety guard against committing test keys

### Phase 2: Mock VM Container
- [ ] Task 2.1: Create mock-vm Dockerfile
  - Files: `src/tests/images/mock-vm/Dockerfile`
  - Dependencies: Task 1.1
  - Details: Alpine-based SSH server accepting test keys
  - Installs: openssh-server, bash
  - Creates: testuser with authorized_keys from test-ssh-key.pub

- [ ] Task 2.2: Create mock-vm entrypoint script
  - Files: `src/tests/images/mock-vm/entrypoint.sh`
  - Dependencies: Task 2.1
  - Details: Start sshd, configure logging, keep container running
  - Logs: SSH connection attempts for test validation
  - Configures: PermitRootLogin no, PubkeyAuthentication yes

- [ ] Task 2.3: Create mock-vm build script
  - Files: `src/tests/images/mock-vm/build.sh`
  - Dependencies: Task 2.1
  - Details: Custom build handling SSH key injection
  - Pattern: Follow existing build.sh pattern from termux/vm images

### Phase 3: Termux Test Container Updates
- [ ] Task 3.1: Update Termux Dockerfile for mobile testing
  - Files: `src/tests/images/termux/Dockerfile`
  - Dependencies: Task 1.3
  - Details: Copy doppler mock to /fixtures, make executable
  - No installation yet - done at test runtime for flexibility

- [ ] Task 3.2: Add assertion helper for file permissions
  - Files: `src/tests/lib/assertions.sh`
  - Dependencies: None
  - Details: Add `assert_file_perms()` function for checking 600/644/700
  - Implementation: Use stat to check permissions, fail with clear message

- [ ] Task 3.3: Add assertion helper for command success
  - Files: `src/tests/lib/assertions.sh`
  - Dependencies: None
  - Details: Add `assert_command_succeeds()` for testing SSH connectivity
  - Implementation: Run command, check exit code 0, ignore output

- [ ] Task 3.4: Add assertion helper for error detection
  - Files: `src/tests/lib/assertions.sh`
  - Dependencies: None
  - Details: Add `assert_no_errors()` for idempotency validation
  - Implementation: Check output for "ERROR" keyword, fail if found

### Phase 4: Docker Compose Configuration
- [ ] Task 4.1: Create Docker Compose file for mobile tests
  - Files: `src/tests/docker-compose.mobile.yml`
  - Dependencies: Tasks 2.1, 3.1
  - Details: Define termux-test and mock-vm services with networking
  - Networks: Create shared network for container communication
  - Volumes: Mount bootstrap scripts read-only, mount test libs

- [ ] Task 4.2: Configure service dependencies and health checks
  - Files: `src/tests/docker-compose.mobile.yml`
  - Dependencies: Task 4.1
  - Details: Ensure mock-vm starts before termux-test runs tests
  - Health checks: SSH port 22 on mock-vm, accept builtin on termux-test

### Phase 5: Test Implementation
- [ ] Task 5.1: Create mobile-termux test script (happy path)
  - Files: `src/tests/tests/mobile-termux.test.sh`
  - Dependencies: Tasks 1.2, 1.3, 3.2, 3.3, 3.4
  - Details: Test successful bootstrap flow with all assertions
  - Steps: Setup config, install mock doppler, run bootstrap, validate
  - Assertions: Packages, config file, SSH keys, SSH config, connectivity

- [ ] Task 5.2: Add idempotency test
  - Files: `src/tests/tests/mobile-termux.test.sh`
  - Dependencies: Task 5.1
  - Details: Run bootstrap twice, ensure no errors or duplicate work
  - Assertions: Second run completes successfully, files unchanged

- [ ] Task 5.3: Create error test cases script
  - Files: `src/tests/tests/mobile-termux-errors.test.sh`
  - Dependencies: Task 5.1
  - Details: Test error handling for various failure scenarios
  - Test cases: Missing config, invalid JSON, doppler auth failure
  - Note: VM unreachable test requires stopping mock-vm mid-test

### Phase 6: Test Orchestration
- [ ] Task 6.1: Create mobile test runner script
  - Files: `src/tests/run-mobile.sh`
  - Dependencies: Tasks 4.1, 5.1
  - Details: Orchestrate Docker Compose lifecycle for mobile tests
  - Functions: Build images, start compose, run tests, cleanup
  - Pattern: Similar to run.sh but uses docker-compose commands

- [ ] Task 6.2: Add proper cleanup and error handling
  - Files: `src/tests/run-mobile.sh`
  - Dependencies: Task 6.1
  - Details: Trap EXIT to cleanup compose stack, remove volumes
  - Safety: Always cleanup even on failure, clear error messages

- [ ] Task 6.3: Add test output formatting
  - Files: `src/tests/run-mobile.sh`
  - Dependencies: Task 6.1
  - Details: Echo step progress, capture and display test output
  - Pattern: Match existing run.sh output style

### Phase 7: Justfile Integration
- [ ] Task 7.1: Add mobile test recipes
  - Files: `tasks/test/justfile`
  - Dependencies: Task 6.1
  - Details: Add `mobile` recipe calling run-mobile.sh
  - Recipe: `mobile platform="termux"` with platform parameter

- [ ] Task 7.2: Update all recipe to include mobile tests
  - Files: `tasks/test/justfile`
  - Dependencies: Task 7.1
  - Details: Add `just test mobile termux` to all test suite
  - Conditional: Only if docker-compose.mobile.yml exists (future-proof)

- [ ] Task 7.3: Add mobile-specific clean recipe
  - Files: `tasks/test/justfile`
  - Dependencies: Task 7.1
  - Details: Clean up mobile test containers and volumes
  - Command: `docker-compose -f src/tests/docker-compose.mobile.yml down -v`

### Phase 8: Testing & Validation
- [ ] Task 8.1: Test mock-vm container independently
  - Files: N/A (manual test)
  - Dependencies: Task 2.2
  - Details: Build and run mock-vm, verify SSH server starts
  - Validation: SSH connection succeeds with test key, logs connections

- [ ] Task 8.2: Test doppler mock independently
  - Files: N/A (manual test)
  - Dependencies: Task 1.3
  - Details: Run doppler-mock.sh, verify correct output
  - Validation: Returns test keys, handles auth checks correctly

- [ ] Task 8.3: Run full mobile test suite
  - Files: N/A (integration test)
  - Dependencies: Tasks 5.1, 5.2, 6.1
  - Details: Execute `just test mobile termux` end-to-end
  - Validation: All assertions pass, idempotency verified, cleanup succeeds

- [ ] Task 8.4: Test error cases
  - Files: N/A (integration test)
  - Dependencies: Task 5.3
  - Details: Run error test script, verify failures caught correctly
  - Validation: Each error case fails gracefully with clear message

- [ ] Task 8.5: Verify no host filesystem modifications
  - Files: N/A (safety check)
  - Dependencies: Task 8.3
  - Details: Ensure tests don't modify host machine
  - Validation: Check ~/.ssh, ~/.config, ~/bin unchanged on host

## Files to Create

### Test Fixtures
- `src/tests/fixtures/test-ssh-key` - Test SSH private key (ed25519)
- `src/tests/fixtures/test-ssh-key.pub` - Test SSH public key
- `src/tests/fixtures/test-config.json` - Non-interactive test configuration
- `src/tests/fixtures/doppler-mock.sh` - Mock Doppler CLI implementation

### Mock VM Container
- `src/tests/images/mock-vm/Dockerfile` - Alpine SSH server container
- `src/tests/images/mock-vm/entrypoint.sh` - SSH server startup script
- `src/tests/images/mock-vm/build.sh` - Custom build script for SSH keys

### Test Scripts
- `src/tests/tests/mobile-termux.test.sh` - Main mobile bootstrap test
- `src/tests/tests/mobile-termux-errors.test.sh` - Error case tests
- `src/tests/run-mobile.sh` - Docker Compose test orchestration
- `src/tests/docker-compose.mobile.yml` - Multi-container test setup

## Files to Modify

### Test Infrastructure
- `src/tests/images/termux/Dockerfile` - Add doppler mock to fixtures
- `src/tests/lib/assertions.sh` - Add permission, success, error assertions
- `tasks/test/justfile` - Add mobile test recipes and integration

### Safety & Documentation
- `.gitignore` - Ignore test SSH keys (src/tests/fixtures/test-ssh-key*)

## Testing Strategy

### Manual Component Testing
1. **Mock Doppler Validation:**
   - Run doppler-mock.sh directly
   - Verify `configure get token` returns mock token
   - Verify `secrets get` returns test SSH keys
   - Test error modes (missing args, invalid secrets)

2. **Mock VM Validation:**
   - Build mock-vm image independently
   - Start container, check SSH server running
   - Test SSH connection with test key
   - Verify logs capture connection attempts

3. **Compose Orchestration:**
   - Start compose stack manually
   - Verify both containers running
   - Test network connectivity (termux-test → mock-vm)
   - Validate volume mounts (bootstrap scripts accessible)

### Integration Testing
1. **Happy Path:**
   - Run `just test mobile termux`
   - Verify all assertions pass
   - Check bootstrap script completes successfully
   - Validate SSH connectivity to mock-vm

2. **Idempotency:**
   - Run bootstrap twice in same container
   - Verify second run skips completed steps
   - Ensure no errors or warnings
   - Validate files not overwritten

3. **Error Cases:**
   - Test missing config file scenario
   - Test invalid JSON in config
   - Test doppler auth failure
   - Test VM unreachable (stop mock-vm)

4. **Safety Validation:**
   - Run tests multiple times
   - Verify host ~/.ssh unchanged
   - Verify host ~/.config unchanged
   - Verify no test keys on host

### Performance & Reliability
- Measure test execution time (target < 5 minutes)
- Run tests 10x to check for flakiness
- Test parallel execution (multiple test runs simultaneously)
- Verify cleanup always succeeds (even on failure)

## Risk Assessment

**Risk 1: Docker Compose networking complexity**
- **Description:** Container-to-container networking may fail or be flaky
- **Mitigation:** Use explicit network definitions, health checks, connection retries
- **Fallback:** Add debug logging, netcat tests for connectivity verification

**Risk 2: Termux Docker image limitations**
- **Description:** Official image may not support all features needed by bootstrap
- **Mitigation:** Test each bootstrap feature in isolation first
- **Fallback:** Document known limitations, skip unsupported features in tests

**Risk 3: SSH server configuration in Alpine**
- **Description:** Alpine SSH setup may differ from production Ubuntu
- **Mitigation:** Use minimal SSH config, focus on key-based auth only
- **Fallback:** Switch to Ubuntu-based mock-vm if needed

**Risk 4: Mock doppler diverging from real behavior**
- **Description:** Real doppler CLI may have features mock doesn't implement
- **Mitigation:** Keep mock minimal, only implement used commands
- **Fallback:** Periodic manual testing with real doppler to catch divergence

**Risk 5: Test SSH keys accidentally committed**
- **Description:** Test keys in fixtures could be committed to repo
- **Mitigation:** .gitignore entries, clear naming, pre-commit hooks
- **Likelihood:** Very Low (with proper .gitignore)

**Risk 6: Bootstrap script changes breaking tests**
- **Description:** Changes to bootstrap/termux.sh may require test updates
- **Mitigation:** Keep assertions focused on outcomes not implementation
- **Fallback:** Update tests promptly when bootstrap changes

## Estimated Complexity
**Moderate**

Rationale:
- Docker Compose adds complexity but is well-documented
- Most patterns already exist in current test infrastructure
- Mocking is straightforward (shell scripts, not complex services)
- Test assertions follow existing patterns
- Main challenge is orchestration, not individual components
- First implementation will be iterative but not difficult

Estimated time:
- Phase 1-4 (Setup): 2 hours
- Phase 5 (Tests): 2 hours
- Phase 6-7 (Integration): 1 hour
- Phase 8 (Validation): 1 hour
- **Total: 6 hours implementation + 2 hours testing/refinement**

## Task Delegation Recommendations

**Direct Implementation (Recommended):**
- All tasks suitable for direct implementation
- Sequential dependencies, not parallel work
- Clear patterns from existing test infrastructure
- Small, focused components (fixtures, scripts, configs)

**Not Recommended:**
- Agent delegation: Scope is manageable, patterns clear
- Parallel agents: Tasks are sequential (fixtures → containers → tests)

**Suggested Approach:**
1. Implement Phase 1-2 (fixtures + mock-vm) together
2. Test mock-vm independently before proceeding
3. Implement Phase 3-4 (termux updates + compose)
4. Implement Phase 5-6 (tests + orchestration)
5. Implement Phase 7-8 (justfile + validation) together

## Notes

### Important Considerations

**Doppler Mock Behavior:**
- Mock only implements commands used by bootstrap script
- Returns static test keys (no actual API calls)
- Auth check always succeeds in happy path tests
- Error mode toggled via environment variable for error tests

**SSH Key Security:**
- Test keys MUST have clear naming (test-ssh-key*)
- MUST be in .gitignore
- MUST NOT be used for any real systems
- Include header comment warning about test-only usage

**Container Networking:**
- Use explicit Docker network in compose file
- Mock-vm accessible as "mock-vm" hostname from termux-test
- No ports exposed to host (internal only)
- Health checks ensure services ready before tests run

**Test Isolation:**
- Each test run uses fresh containers
- No state persists between runs
- Cleanup always executed (trap EXIT)
- Parallel runs use unique container names ($$)

**Bootstrap Script Compatibility:**
- Tests use same bootstrap scripts as production
- No test-specific branches in bootstrap code
- Config file determines test vs production behavior
- Mock doppler transparent to bootstrap script

### Pattern Reuse

**From Existing Tests:**
- Assertion library pattern (assertions.sh)
- Bash server for HTTP file serving (bash-server.sh)
- Docker build wrapper pattern (build.sh)
- Cleanup trap pattern (run.sh)
- User switching for Termux (run.sh)

**New Patterns Introduced:**
- Docker Compose for multi-container tests
- Mock service injection via volume mounts
- SSH connectivity testing in containers
- Runtime config generation in tests

### Performance Optimization

**Fast Feedback:**
- Skip expensive operations in mock doppler (no API calls)
- Use Alpine for mock-vm (smaller, faster)
- Cache Docker images (don't rebuild every run)
- Parallel assertion checks where possible

**Minimize Build Time:**
- Reuse Termux image without rebuilding
- Only rebuild mock-vm when Dockerfile changes
- Use Docker layer caching effectively
- Keep Dockerfiles simple and fast

### Future Enhancements

**Phase 9 (Future):**
- Add Ubuntu VM bootstrap testing (reuse mock-vm pattern)
- Add mosh connectivity testing
- Add configure.sh interactivity testing (expect/script)
- Add performance benchmarking
- Add CI/CD GitHub Actions workflow
- Add test coverage reporting

**Extensibility:**
- Mock-vm can support both Alpine and Ubuntu modes
- Doppler mock can be extended for new commands
- Test assertions library grows with new checks
- Docker Compose pattern supports additional services
