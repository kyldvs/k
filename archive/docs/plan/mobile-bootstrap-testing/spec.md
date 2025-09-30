# Mobile Bootstrap Testing - Specification

## Overview
Automated Docker-based testing environment for the new config-driven mobile bootstrap system (`bootstrap/termux.sh` and `bootstrap/configure.sh`). Tests run in isolated containers using the official Termux Docker image with mocked dependencies (Doppler, SSH VM) to validate bootstrap functionality without requiring actual credentials or external services.

## Goals
- Test mobile bootstrap scripts in isolated Docker environment
- Validate idempotency (safe to run multiple times)
- Test error handling (missing config, failed auth, unreachable VM)
- Prevent accidental execution on local machine (safety)
- Support future Ubuntu VM testing via Docker Compose

## Requirements

### Functional Requirements
- FR-1: Run `bootstrap/termux.sh` in official Termux Docker container
- FR-2: Provide non-interactive config without prompts
- FR-3: Mock Doppler CLI and secrets retrieval
- FR-4: Mock SSH VM endpoint for connectivity tests
- FR-5: Assert successful package installation (openssh, mosh, jq)
- FR-6: Assert SSH keys written to ~/.ssh/ with correct permissions
- FR-7: Assert SSH config generated correctly
- FR-8: Test idempotency by running bootstrap twice
- FR-9: Test error cases (missing config, invalid values)
- FR-10: Never execute bootstrap scripts on host machine

### Non-Functional Requirements
- NFR-1: Tests complete in < 5 minutes
- NFR-2: Deterministic results (no flakiness)
- NFR-3: Clean up containers/images after tests
- NFR-4: Clear failure messages with actionable errors

### Technical Requirements
- Use official `termux/termux-docker:x86_64` image
- Docker Compose for multi-container orchestration (Termux + mock VM)
- Reuse existing test infrastructure patterns (`src/tests/`)
- Mock Doppler using shell wrapper or test fixture
- Mock VM using simple SSH server container
- Integrate with existing `just test` command structure

## User Stories / Use Cases
- As a developer, I can run `just test mobile termux` to validate Termux bootstrap locally
- As a developer, I receive clear error messages when tests fail with specific assertion violations
- As a developer, I can test new bootstrap changes without risking my local environment
- As a CI system, I can run tests in parallel without conflicts using isolated containers

## Success Criteria
- Tests run successfully in Docker without external dependencies
- Idempotency verified (second run skips completed steps)
- All error cases caught and reported clearly
- No modifications to host machine filesystem
- Test coverage matches implementation plan Phase 5 tasks
- Integration with `just test` command structure

## Constraints
- Must not execute bootstrap scripts on host machine
- Cannot use real Doppler credentials in tests
- Cannot require external VM access
- Must work in CI/CD environments (GitHub Actions)
- Limited by Docker container permissions (no true root on Termux)

## Architecture

### Container Strategy
```
docker-compose.yml
├── termux-test (test subject)
│   ├── Official termux/termux-docker image
│   ├── Mocked doppler CLI wrapper
│   ├── Pre-configured test config file
│   └── Bootstrap scripts mounted read-only
└── mock-vm (test dependency)
    ├── Alpine/Ubuntu with SSH server
    ├── Accepts connections from termux-test
    └── Validates SSH key authentication
```

### Test Flow
1. Start Docker Compose (termux-test + mock-vm)
2. Generate test config in termux-test container
3. Install mock doppler wrapper returning test SSH keys
4. Run bootstrap/termux.sh in termux-test
5. Assert package installation, SSH setup, config generation
6. Test SSH connection to mock-vm succeeds
7. Run bootstrap/termux.sh again (idempotency)
8. Assert no errors, no duplicate work
9. Test error cases with invalid configs
10. Clean up containers

### Mocking Strategy

**Doppler Mock:**
- Shell script wrapper at ~/bin/doppler
- Returns pre-defined SSH key fixtures for `secrets get`
- Returns success for `configure get token`
- Fails appropriately for auth tests

**VM Mock:**
- Lightweight SSH server (dropbear or openssh)
- Accepts test SSH keys
- Logs connection attempts for validation
- Accessible from termux-test via Docker network

## Implementation Plan

### File Structure
```
src/tests/
├── docker-compose.mobile.yml         # NEW: Multi-container orchestration
├── images/
│   ├── termux/
│   │   └── Dockerfile                # MODIFY: Add doppler mock setup
│   └── mock-vm/
│       ├── Dockerfile                # NEW: SSH server image
│       └── entrypoint.sh             # NEW: Start SSH, log connections
├── fixtures/
│   ├── doppler-mock.sh               # NEW: Mock doppler CLI
│   ├── test-config.json              # NEW: Non-interactive config
│   ├── test-ssh-key                  # NEW: Test SSH private key
│   └── test-ssh-key.pub              # NEW: Test SSH public key
├── tests/
│   └── mobile-termux.test.sh         # NEW: Mobile bootstrap assertions
└── run-mobile.sh                     # NEW: Test orchestration script
```

### Test Assertions
```bash
# Package installation
assert_command_exists "jq"
assert_command_exists "ssh"
assert_command_exists "mosh-server"

# Config loading
assert_file "$HOME/.config/kyldvs/k/configure.json"
assert_file_contains "$HOME/.config/kyldvs/k/configure.json" "mock-vm"

# Doppler wrapper
assert_file "$HOME/bin/doppler"
assert_command "doppler configure get token --plain --silent" "mock-token"

# SSH key setup
assert_file "$HOME/.ssh/id_ed25519"
assert_file_perms "$HOME/.ssh/id_ed25519" "600"
assert_file "$HOME/.ssh/id_ed25519.pub"
assert_file_perms "$HOME/.ssh/id_ed25519.pub" "644"

# SSH config
assert_file "$HOME/.ssh/config"
assert_file_contains "$HOME/.ssh/config" "Host vm"
assert_file_contains "$HOME/.ssh/config" "HostName mock-vm"

# SSH connectivity (to mock-vm)
assert_command_succeeds "ssh -o BatchMode=yes -o ConnectTimeout=5 vm exit"

# Idempotency (run again, no errors)
bootstrap_output=$(curl -fsSL http://k.local/termux.sh | bash 2>&1)
assert_no_errors "$bootstrap_output"
```

### Error Test Cases
```bash
# Test 1: Missing config file
rm -f ~/.config/kyldvs/k/configure.json
assert_bootstrap_fails "Configuration file not found"

# Test 2: Invalid JSON in config
echo "invalid json" > ~/.config/kyldvs/k/configure.json
assert_bootstrap_fails "Invalid JSON"

# Test 3: Doppler not authenticated
unset DOPPLER_TOKEN
mock_doppler_auth_failure
assert_bootstrap_fails "doppler login"

# Test 4: VM unreachable
stop_mock_vm_container
assert_bootstrap_fails "SSH connection failed"

# Test 5: Invalid SSH keys
mock_doppler_invalid_keys
assert_bootstrap_fails "Invalid SSH key format"
```

## Integration with Existing System

### Justfile Integration
```just
# tasks/test/justfile

[no-cd]
mobile platform="termux":
  @echo "Testing mobile bootstrap on {{platform}}..."
  @cd src/tests && ./run-mobile.sh {{platform}}

[no-cd]
mobile-termux:
  just test mobile termux

[no-cd]
all:
  # Existing tests...
  just test mobile termux
```

### Safety Guards
- Run exclusively in Docker (check for container env)
- Mount bootstrap scripts read-only
- No volume mounts to host directories
- Clear warnings in script headers
- CI/CD validation before merge

## Non-Goals
- Testing actual Doppler API integration (unit test only)
- Testing real VM provisioning (mocked only)
- Testing on physical Android devices (Docker only)
- Performance benchmarking (functional tests only)
- Testing configure.sh interactivity (use pre-generated config)

## Assumptions
- Official Termux Docker image accurately represents Termux environment
- Mock SSH server sufficient for connectivity validation
- Doppler CLI behavior can be adequately mocked
- Docker available in development and CI environments
- Test fixtures (SSH keys) don't need rotation

## Open Questions
- Q1: Should we test configure.sh interactivity with expect/script?
  - **Decision Needed**: Likely no, use pre-generated config for speed
- Q2: How to handle Termux DNS quirks in Docker?
  - **Existing Solution**: ulimit nofile fix from current tests
- Q3: Should mock-vm run both Alpine and Ubuntu for future VM bootstrap?
  - **Decision**: Start with Alpine only, add Ubuntu later
- Q4: Where to store test SSH keys (fixtures or generate per-run)?
  - **Decision Needed**: Fixtures for speed, ensure not used elsewhere
- Q5: Should we test mosh connectivity in addition to SSH?
  - **Decision Needed**: SSH priority, mosh if time permits

## Testing Strategy Summary

**Approach:** Integration tests in isolated Docker environment with mocked external dependencies.

**Key Principle:** Never run bootstrap scripts on host machine - Docker only.

**Test Pyramid:**
1. Unit: Mocks verify correct behavior (doppler wrapper, config parsing)
2. Integration: Full bootstrap flow with mocked dependencies
3. E2E: Not applicable (would require real Termux device)

**CI/CD Integration:**
- Run on every PR to mobile bootstrap changes
- Run nightly for regression detection
- Block merge on test failures
- Publish test reports/artifacts

## Risk Assessment

**Risk 1: Termux Docker image divergence from real Termux**
- **Impact:** High - tests pass but real Termux fails
- **Mitigation:** Periodic manual testing on real device, document known differences
- **Likelihood:** Medium

**Risk 2: Mock complexity equals or exceeds real dependencies**
- **Impact:** Medium - wasted effort, maintenance burden
- **Mitigation:** Keep mocks minimal, shell wrappers only, no complex services
- **Likelihood:** Low

**Risk 3: Flaky tests due to timing or networking**
- **Impact:** High - CI blocks merges unnecessarily
- **Mitigation:** Explicit waits, health checks, retry logic
- **Likelihood:** Medium

**Risk 4: Test fixtures (SSH keys) mistakenly used in production**
- **Impact:** Critical - security vulnerability
- **Mitigation:** Clear naming (test-*), comments, separate directory, .gitignore
- **Likelihood:** Very Low

## Estimated Complexity
**Moderate to High**

Rationale:
- Docker Compose multi-container setup adds complexity
- Mocking Doppler requires understanding CLI behavior
- SSH connectivity testing needs careful networking
- Idempotency and error cases require thorough coverage
- Integration with existing test infrastructure
- First implementation will inform future VM tests

Estimated time: 4-6 hours for implementation + 2-3 hours for testing and refinement

## Dependencies
- Docker and Docker Compose installed
- Official termux/termux-docker image available
- Existing test infrastructure (assertions.sh, bash-server.sh)
- Bootstrap scripts in place (configure.sh, termux.sh)

## Success Validation
- [ ] `just test mobile termux` runs successfully
- [ ] All assertions pass (packages, SSH, config, connectivity)
- [ ] Idempotency verified (second run clean)
- [ ] Error cases caught with clear messages
- [ ] No modifications to host filesystem
- [ ] Tests complete in < 5 minutes
- [ ] CI/CD integration documented and working
