# VMRoot Test Fixes - Specification

## Overview
Fix Docker exit 255 failures in the vmroot test infrastructure to enable reliable automated testing of the VM root bootstrap process. The tests exist and validate all bootstrap functionality, but Docker environment issues prevent successful execution.

## Goals
- Eliminate Docker exit 255 errors in vmroot test execution
- Enable `just test vmroot` and `just test all` to run successfully
- Achieve CI-ready test infrastructure for GitHub Actions integration

## Requirements

### Functional Requirements
- FR-1: vmroot.test.sh executes successfully in Docker container
- FR-2: All bootstrap phases are validated (user creation, sudoers, SSH keys)
- FR-3: Idempotency tests pass (running bootstrap twice produces same result)
- FR-4: Sudo functionality tests execute correctly in container
- FR-5: Tests run through standard `just test` commands without manual intervention

### Non-Functional Requirements
- NFR-1: Tests complete within 60 seconds
- NFR-2: Tests produce clear pass/fail output with actionable error messages
- NFR-3: Test environment is reproducible across different host systems
- NFR-4: Container resources are minimal (no unnecessary privileges or capabilities)
- NFR-5: Tests are compatible with CI environments (GitHub Actions)

### Technical Requirements
- Docker and Docker Compose for test execution
- Ubuntu-based container image for VM environment simulation
- Proper container capabilities for user creation (CAP_SETUID, CAP_SETGID)
- Volume mounts providing access to bootstrap scripts and fixtures
- jq, sudo, and standard Unix utilities available in container
- Test fixtures in src/tests/fixtures/vmroot-test-config.json

## User Stories / Use Cases
- As a developer, I can run `just test vmroot` to validate vmroot bootstrap changes locally before committing
- As a CI system, I can execute `just test all` to validate all bootstrap scripts including vmroot
- As a maintainer, I can trust that passing vmroot tests guarantee bootstrap script correctness
- As a contributor, I receive clear error messages when vmroot tests fail, indicating what needs fixing

## Success Criteria
- `just test vmroot` exits with code 0 (success)
- `just test all` includes vmroot tests and passes completely
- Tests validate user creation with correct UID/GID/shell/home
- Tests validate sudoers configuration allows passwordless sudo
- Tests validate SSH public key installation in authorized_keys
- Tests validate bootstrap script idempotency (no errors on second run)
- Tests validate created user can execute sudo commands
- All test output is captured and reported clearly
- No manual Docker commands required to run tests

## Constraints
- Must use existing Docker-based test infrastructure pattern
- Cannot modify vmroot.sh or vmroot-configure.sh bootstrap scripts (they are validated as correct)
- Must maintain consistency with mobile-termux.test.sh patterns
- Container must run as root to perform user creation operations
- Host system may not support all Docker capabilities (must use minimal necessary privileges)

## Non-Goals
- Rewriting vmroot bootstrap scripts (they are correct, tests are the issue)
- Adding new bootstrap functionality or features
- Optimizing bootstrap script performance
- Creating integration tests with real VMs (Docker simulation only)
- Supporting non-Linux host systems for test execution
- Implementing test coverage reporting or metrics

## Assumptions
- Docker and Docker Compose are installed on host system
- Host kernel supports necessary container capabilities for user creation
- Bootstrap scripts (vmroot.sh, vmroot-configure.sh) are correct and functional
- Test fixtures (vmroot-test-config.json) contain valid configuration
- Exit code 255 is environment/configuration issue, not script logic error
- mobile-termux.test.sh provides working reference patterns

## Open Questions
- Does container need `privileged: true` or can it use specific capabilities?
- Is current Ubuntu base image appropriate or should we use different image?
- Are volume mount paths and permissions configured correctly?
- Does container have proper init system for process management?
- Are all required dependencies (jq, sudo) available in container?
- Is exit 255 occurring during container startup or script execution?

## Investigation Strategy
1. Reproduce issue by running `just test vmroot` and capturing full output
2. Analyze docker-compose.vmroot.yml for configuration issues
3. Compare vmroot Docker setup with working mobile-termux setup
4. Test container startup independently of test script
5. Add verbose logging to identify exact failure point
6. Test with minimal Docker configuration, then add necessary capabilities
7. Validate all volume mounts and fixture files are accessible

## Related Files
- src/tests/tests/vmroot.test.sh (test script with 132 lines)
- src/tests/docker-compose.vmroot.yml (Docker configuration)
- src/tests/run-vmroot.sh (test runner)
- src/tests/fixtures/vmroot-test-config.json (test fixtures)
- src/tests/tests/mobile-termux.test.sh (working reference)
- bootstrap/vmroot.sh (bootstrap script under test)
- bootstrap/vmroot-configure.sh (configuration script)

## Priority Rationale
**High Priority**: Blocks CI integration and prevents automated validation of vmroot bootstrap changes. Without working tests, vmroot modifications cannot be confidently deployed, reducing code quality and increasing risk of regressions.

## Estimated Effort
1-2 hours of focused debugging and configuration adjustment.
