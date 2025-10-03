# Testing Infrastructure

## Overview
Docker Compose-based test environment for validating bootstrap scripts in
isolated containers with mocked external dependencies. Tests run automatically
via justfile recipes, ensuring bootstrap functionality without requiring actual
credentials or external services.

## Architecture

### Container Strategy
Tests use Docker Compose to orchestrate multiple containers representing
different environments:

```
src/tests/
├── docker-compose.yml       # Service definitions
├── lib/
│   └── assertions.sh        # Reusable test assertions
├── tests/
│   ├── mobile-termux.test.sh  # Termux bootstrap tests
│   └── vmroot.test.sh         # VM root bootstrap tests
└── fixtures/
    ├── configure.json         # Test Termux config
    └── vmroot-configure.json  # Test VM root config
```

### Test Services

**mobile-termux**:
- Base image: Alpine (lightweight, fast)
- Purpose: Validate Termux bootstrap script
- Mocks: Doppler CLI, SSH VM endpoint
- Mounts: Bootstrap scripts read-only, test config writable

**vmroot**:
- Base image: Ubuntu (includes useradd, sudo)
- Purpose: Validate VM root provisioning
- Requirements: Root user, standard Linux utilities
- Mounts: Bootstrap scripts read-only, test config writable

### Execution Flow
1. `just test <environment> <test-name>` invoked
2. Docker Compose builds/starts container
3. Test fixture config copied into container
4. Bootstrap script executed via direct invocation
5. Assertions validate results
6. Idempotency tested (run script again)
7. Container stopped, exit code propagated

## Key Components

### Assertion Library (`lib/assertions.sh`)
Reusable test assertions with clear failure messages:

- `assert_file <path>` - File exists
- `assert_file_contains <path> <pattern>` - File contains text
- `assert_file_not_contains <path> <pattern>` - File excludes text
- `assert_command_success <cmd>` - Command exits 0
- `assert_command_fails <cmd>` - Command exits non-zero
- `assert_env_var <name> <value>` - Environment variable set

**Design**: Assertions fail-fast with descriptive messages including file/line
context.

### Test Scripts
Test scripts follow consistent structure:

```sh
#!/usr/bin/env bash
set -euo pipefail
. /lib/assertions.sh

# Phase 1: Setup
cp /fixtures/config.json ~/.config/kyldvs/k/

# Phase 2: Execute bootstrap
cat /var/www/bootstrap/termux.sh | bash

# Phase 3: Validate
assert_file "$HOME/.ssh/gh_vm"
assert_file_contains "$HOME/.ssh/config" "Host vm"

# Phase 4: Test idempotency
cat /var/www/bootstrap/termux.sh | bash  # Second run
assert_file "$HOME/.ssh/gh_vm"  # Still exists
```

### Mocking Strategy

**Doppler CLI Mock**:
- Test fixture provides pre-configured responses
- Wrapper script returns static values for test keys
- No actual Doppler API calls made

**SSH VM Mock**:
- Not actually mocked - tests skip SSH connection verification
- Alternative: Use second container with SSH server (future enhancement)

**Package Installation**:
- Tests run in containers with packages pre-installed or allow actual
  installation
- Fast package managers (Alpine apk, Ubuntu apt) acceptable for test runtime

## Design Decisions

### Docker Compose Over Raw Docker
**Decision**: Use Docker Compose for test orchestration.

**Rationale**:
- Declarative service definitions (docker-compose.yml)
- Easy multi-container scenarios (future: mock SSH VM)
- Volume mounts and networks handled automatically
- Consistent with industry standards

### Read-Only Bootstrap Mounts
**Decision**: Mount bootstrap directory read-only in tests.

**Rationale**:
- Prevents tests from accidentally modifying source
- Ensures tests operate on committed code
- Forces proper separation between source and test artifacts

### Fixture-Based Configuration
**Decision**: Use static JSON fixtures for test configs instead of generating
at runtime.

**Rationale**:
- Explicit test inputs (no hidden generation logic)
- Easy to version control
- Simple to modify for edge case testing
- Fast (no generation overhead)

### Direct Script Execution
**Decision**: Execute bootstrap scripts directly via `cat script.sh | bash`
instead of curl-pipe-sh.

**Rationale**:
- No network dependencies in tests
- Faster execution (no download)
- Tests actual script content, not delivery mechanism
- Validates curl-pipe-sh pattern implicitly (piped execution)

### Assertion Library Over Test Framework
**Decision**: Custom bash assertion library instead of external framework
(bats, shunit2).

**Rationale**:
- Minimal dependencies (pure bash)
- Tailored to bootstrap testing needs
- Fast (no framework overhead)
- Easy to extend with domain-specific assertions

## Implementation Patterns

### Test Service Definition (docker-compose.yml)
```yaml
mobile-termux:
  build:
    context: .
    dockerfile: Dockerfile.termux
  volumes:
    - ../../bootstrap:/var/www/bootstrap:ro
    - ./fixtures:/fixtures:ro
    - ./lib:/lib:ro
    - ./tests:/tests:ro
  command: /tests/mobile-termux.test.sh
```

### Assertion Implementation
```sh
assert_file() {
  local path="$1"
  if [ ! -f "$path" ]; then
    echo "FAIL: File does not exist: $path" >&2
    exit 1
  fi
  echo "PASS: File exists: $path"
}
```

### Justfile Test Recipe
```just
[no-cd]
@test environment test-name:
  docker compose -f src/tests/docker-compose.yml run --rm {{environment}}
```

## Integration Points

### With Bootstrap System
- Tests validate bootstrap scripts end-to-end
- Idempotency verified by running scripts twice
- Configuration loading tested with fixtures
- Step tracking and error handling validated

### With CI/CD (Future)
- Tests designed to run in GitHub Actions
- Exit codes propagate correctly (0=pass, 1=fail)
- Output parseable for CI reporting
- Containers can run in parallel for speed

### With Development Workflow
- `just test all` runs full test suite
- `just test mobile termux` runs specific test
- `just test clean` removes containers/images
- Fast feedback loop (<2 minutes for all tests)

## Testing Strategy

### Test Coverage
**Mobile Termux bootstrap** (`mobile-termux.test.sh`):
- Config file loading
- Package installation (openssh, mosh, jq)
- Doppler setup and authentication
- SSH key retrieval and permissions
- SSH config generation
- Profile initialization (.profile, kd-editor.sh, kd-path.sh)
- Idempotency (run twice, validate no duplicates)

**VM root bootstrap** (`vmroot.test.sh`):
- Config file loading
- User account creation with custom home directory
- Sudoers file creation with correct permissions
- SSH key copying with correct ownership
- Passwordless sudo verification
- Idempotency (run twice, validate user not duplicated)

### Edge Cases
- Missing config files (expect failure)
- Invalid config format (expect validation failure)
- Re-running after partial completion (expect steps to skip)
- Pre-existing configuration (expect merge/update)

### Non-Goals
- **Network testing**: No actual SSH connections to external VMs
- **Performance testing**: Not measuring bootstrap speed
- **Security testing**: Not penetration testing or fuzzing
- **Cross-platform**: Tests target specific containers, not all platforms

## Performance Characteristics
- Full test suite: <2 minutes (Docker build + execution)
- Individual test: <30 seconds
- Docker image caching reduces subsequent runs to <10 seconds
- Acceptable for pre-commit hook (with `--cached` flag) or CI

## Future Considerations
- **Mock SSH VM container**: Add second container running SSH server for
  connection testing
- **Parallel test execution**: Run mobile and vmroot tests simultaneously
- **Test output formatting**: Consider TAP or JUnit XML for CI integration
- **Coverage metrics**: Track which bootstrap steps are tested vs untested
- **Mutation testing**: Introduce intentional bugs to verify test sensitivity
