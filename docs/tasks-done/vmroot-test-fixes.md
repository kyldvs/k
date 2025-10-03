# VMRoot Test Fixes

## Description

Fix Docker exit 255 issues in vmroot test infrastructure. Tests exist and
validate the vmroot bootstrap script, but encounter environment-specific Docker
issues that prevent reliable execution.

## Current State

From docs/plan/vm-root-bootstrap/status.md:
- vmroot.test.sh exists and covers all bootstrap phases
- Docker Compose setup exists (docker-compose.vmroot.yml)
- Tests encounter "env-specific exit 255 issues"
- Core functionality verified through script inspection and manual build
- Status notes: "Ready for real VM testing"

Test file: src/tests/tests/vmroot.test.sh (132 lines)
- Validates user creation
- Validates sudoers configuration
- Validates SSH key setup
- Tests idempotency
- Tests sudo functionality

## Problem

Exit code 255 typically indicates:
- Docker container startup/initialization failure
- Script execution environment issues
- Permission/capability problems in containerized environment
- Network or resource constraints

## Success Criteria

- [ ] vmroot tests run successfully in Docker
- [ ] `just test vmroot` completes without errors
- [ ] `just test all` includes vmroot tests and passes
- [ ] Tests validate all bootstrap functionality
- [ ] Idempotency tests pass
- [ ] CI-ready (can run in GitHub Actions)

## Investigation Steps

1. **Reproduce the issue:**
   - Run `just test vmroot`
   - Capture full error output and logs
   - Identify exact failure point

2. **Analyze Docker environment:**
   - Review docker-compose.vmroot.yml configuration
   - Check container capabilities and privileges
   - Verify volume mounts and permissions
   - Test with different base images if needed

3. **Debug test script:**
   - Add verbose logging to vmroot.test.sh
   - Test individual phases in isolation
   - Verify mock fixtures are correct

4. **Compare with working tests:**
   - Review mobile-termux.test.sh (working)
   - Identify architectural differences
   - Apply successful patterns

## Implementation Notes

**Files to Review:**
- src/tests/tests/vmroot.test.sh
- src/tests/docker-compose.vmroot.yml
- src/tests/run-vmroot.sh
- src/tests/fixtures/vmroot-test-config.json

**Potential Solutions:**
- Add `privileged: true` to Docker Compose if needed for user creation
- Adjust Docker image (currently Ubuntu-based)
- Fix volume mount paths
- Update test fixtures
- Add debugging output
- Verify jq, sudo, and other dependencies available in container

**Docker Compose Considerations:**
- Container needs to run as root to create users
- Must have sudo installed
- Needs proper init system or process management
- May need specific capabilities (CAP_SETUID, CAP_SETGID)

## Dependencies

- Docker and Docker Compose installed
- Working vmroot.sh and vmroot-configure.sh scripts
- Test fixtures in src/tests/fixtures/

## Related Files

- src/tests/tests/vmroot.test.sh
- src/tests/docker-compose.vmroot.yml
- src/tests/run-vmroot.sh
- src/tests/tests/mobile-termux.test.sh (working reference)
- bootstrap/vmroot.sh
- bootstrap/vmroot-configure.sh

## Priority

**High** - Blocks CI integration and automated testing infrastructure.

## Estimated Effort

1-2 hours

## Related Principles

- **#8 Good Code is Thorough**: Tests validate all functionality and edge
  cases; fixing tests ensures thoroughness
- **#9 Good Code is Sustainable**: Reliable automated tests enable long-term
  maintainability
- **#2 Good Code is Useful**: Working tests are essential for confident
  development

## References

- docs/plan/vm-root-bootstrap/status.md (notes exit 255 issue)
- Docker exit codes: 255 typically means command not found or init failure
