# VM Root Bootstrap - Implementation Plan

## Prerequisites
- Root access to VM (uid 0)
- Standard Linux utilities: `useradd`, `usermod`, `sudo`, `mkdir`, `cp`, `chown`, `chmod`, `visudo`
- Existing bootstrap component architecture in place
- Understanding of bootstrap build system (`just bootstrap build`)

## Architecture Overview
Extends existing bootstrap system with root-level VM provisioning:
- **New directory**: `bootstrap/vmroot/` (not needed - use existing structure)
- **New utilities**: None (reuse existing `colors.sh`, `logging.sh`, `steps.sh`)
- **New step files**: 4 step components for vmroot configuration
- **New manifests**: 2 manifest files for script generation
- **Integration**: Justfile recipes for building vmroot scripts

Key design decisions:
- Scripts run as root (validate with `[ "$(id -u)" -eq 0 ]`)
- Configuration stored at `/root/.config/kyldvs/k/vmroot-configure.json`
- Idempotent operations (safe to re-run)
- Follow existing bootstrap patterns (step functions, logging, error handling)

## Task Breakdown

### Phase 1: Create Step Components
Core implementation files for vmroot functionality.

- [ ] Task 1.1: Create vmroot configuration step
  - Files: `bootstrap/lib/steps/vmroot-configure.sh`
  - Dependencies: None
  - Details: Interactive prompts for username (default: kad) and home directory (default: /mnt/kad). Save to `/root/.config/kyldvs/k/vmroot-configure.json`. Include validation logic for empty inputs.

- [ ] Task 1.2: Create user creation step
  - Files: `bootstrap/lib/steps/vmroot-user.sh`
  - Dependencies: Task 1.1
  - Details: Read config, use `useradd --create-home --home-dir $HOMEDIR --shell /bin/bash --password '!' $USERNAME`. Check if user exists first (idempotency). Create parent directories with `mkdir -p` if needed.

- [ ] Task 1.3: Create sudoers configuration step
  - Files: `bootstrap/lib/steps/vmroot-sudo.sh`
  - Dependencies: Task 1.2
  - Details: Create `/etc/sudoers.d/vmroot-$USERNAME` with `$USERNAME ALL=(ALL) NOPASSWD:ALL`. Set permissions to 440. Validate with `visudo -cf /etc/sudoers.d/vmroot-$USERNAME`. Skip if file exists (idempotency).

- [ ] Task 1.4: Create SSH key setup step
  - Files: `bootstrap/lib/steps/vmroot-ssh.sh`
  - Dependencies: Task 1.2
  - Details: Copy `/root/.ssh/authorized_keys` to `$USER_HOME/.ssh/authorized_keys`. Create .ssh directory (700). Set file permissions (600). Set ownership (`chown -R $USERNAME:$USERNAME`). Handle missing root authorized_keys gracefully.

### Phase 2: Create Utility Components

- [ ] Task 2.1: Create vmroot-configure header
  - Files: `bootstrap/lib/utils/header-vmroot-configure.sh`
  - Dependencies: None
  - Details: Shebang, description comment, `set -e`, root user validation

- [ ] Task 2.2: Create vmroot header
  - Files: `bootstrap/lib/utils/header-vmroot.sh`
  - Dependencies: None
  - Details: Shebang, description comment, `set -e`, root user validation

- [ ] Task 2.3: Create vmroot config path utility
  - Files: `bootstrap/lib/utils/vmroot-config-path.sh`
  - Dependencies: None
  - Details: Define `VMROOT_CONFIG_FILE="/root/.config/kyldvs/k/vmroot-configure.json"`

- [ ] Task 2.4: Create vmroot validation utility
  - Files: `bootstrap/lib/utils/vmroot-validate.sh`
  - Dependencies: None
  - Details: Validate username and homedir not empty, check homedir parent is writable

- [ ] Task 2.5: Create vmroot prompt utility
  - Files: `bootstrap/lib/utils/vmroot-prompt.sh`
  - Dependencies: None
  - Details: Similar to existing `prompt.sh` but adapted for vmroot context

- [ ] Task 2.6: Create vmroot-check-config step
  - Files: `bootstrap/lib/steps/vmroot-check-config.sh`
  - Dependencies: Task 2.3
  - Details: Verify config file exists, exit with error if not found (direct user to run configure first)

- [ ] Task 2.7: Create vmroot-configure-main step
  - Files: `bootstrap/lib/steps/vmroot-configure-main.sh`
  - Dependencies: Tasks 2.4, 2.5
  - Details: Main flow for vmroot-configure.sh - prompt, validate, save JSON config

- [ ] Task 2.8: Create vmroot-main step
  - Files: `bootstrap/lib/steps/vmroot-main.sh`
  - Dependencies: Task 2.6
  - Details: Main flow for vmroot.sh - load config, call user/sudo/ssh steps in sequence

### Phase 3: Create Build Manifests

- [ ] Task 3.1: Create vmroot-configure manifest
  - Files: `bootstrap/manifests/vmroot-configure.txt`
  - Dependencies: Phase 2 complete
  - Details: List components in order: header, colors, prompt, validate, configure-main step

- [ ] Task 3.2: Create vmroot manifest
  - Files: `bootstrap/manifests/vmroot.txt`
  - Dependencies: Phase 2 complete
  - Details: List components in order: header, colors, logging, steps, config-path, check-config, user, sudo, ssh, main

### Phase 4: Update Build System

- [ ] Task 4.1: Update Justfile bootstrap recipes
  - Files: `tasks/bootstrap/justfile`
  - Dependencies: Phase 3 complete
  - Details: Add `just bootstrap build vmroot-configure` and `just bootstrap build vmroot` to `build-all` recipe

### Phase 5: Generate Bootstrap Scripts

- [ ] Task 5.1: Build vmroot-configure.sh
  - Files: `bootstrap/vmroot-configure.sh` (generated)
  - Dependencies: Tasks 3.1, 4.1
  - Details: Run `just bootstrap build vmroot-configure`

- [ ] Task 5.2: Build vmroot.sh
  - Files: `bootstrap/vmroot.sh` (generated)
  - Dependencies: Tasks 3.2, 4.1
  - Details: Run `just bootstrap build vmroot`

### Phase 6: Create Docker Test Infrastructure

- [ ] Task 6.1: Create vmroot test fixtures
  - Files: `src/tests/fixtures/vmroot-test-config.json`
  - Dependencies: None
  - Details: Sample config with test username/homedir

- [ ] Task 6.2: Create vmroot test script
  - Files: `src/tests/tests/vmroot.test.sh`
  - Dependencies: Phase 5 complete, Task 6.1
  - Details: Test both configure and provision scripts. Verify user creation, sudoers, SSH keys. Test idempotency.

- [ ] Task 6.3: Create vmroot Docker compose service
  - Files: `src/tests/docker-compose.yml`
  - Dependencies: Task 6.2
  - Details: Add `vmroot` service similar to `mobile-termux`. Use base image with `useradd`, `sudo`, etc.

- [ ] Task 6.4: Update test runner for vmroot
  - Files: `tasks/test/justfile`
  - Dependencies: Task 6.3
  - Details: Add vmroot test target to allow `just test vmroot`

### Phase 7: Testing & Validation

- [ ] Task 7.1: Run vmroot tests
  - Files: N/A (test execution)
  - Dependencies: Phase 6 complete
  - Details: Execute `just test vmroot` and verify all assertions pass

- [ ] Task 7.2: Test configure script interactively (manual)
  - Files: N/A (manual verification)
  - Dependencies: Task 5.1
  - Details: Run `bash bootstrap/vmroot-configure.sh` and verify prompts, config file creation

- [ ] Task 7.3: Test idempotency
  - Files: N/A (test execution)
  - Dependencies: Task 7.1
  - Details: Verify running vmroot.sh twice produces same result without errors

- [ ] Task 7.4: Validate against success criteria
  - Files: N/A (verification)
  - Dependencies: Tasks 7.1-7.3
  - Details: Check all success criteria from spec are met

### Phase 8: Documentation & Integration

- [ ] Task 8.1: Update CLAUDE.md with vmroot workflows
  - Files: `CLAUDE.md`
  - Dependencies: Phase 7 complete
  - Details: Add vmroot commands to Quick Reference and Workflows sections

- [ ] Task 8.2: Update bootstrap README (if exists)
  - Files: `bootstrap/README.md` (only if explicitly requested)
  - Dependencies: Phase 7 complete
  - Details: Document vmroot-configure.sh and vmroot.sh usage (SKIP unless requested)

## Files to Create

### Step Components
- `bootstrap/lib/steps/vmroot-configure.sh` - Interactive configuration logic
- `bootstrap/lib/steps/vmroot-user.sh` - User account creation
- `bootstrap/lib/steps/vmroot-sudo.sh` - Sudoers setup
- `bootstrap/lib/steps/vmroot-ssh.sh` - SSH key copying

### Utility Components
- `bootstrap/lib/utils/header-vmroot-configure.sh` - Configure script header
- `bootstrap/lib/utils/header-vmroot.sh` - Bootstrap script header
- `bootstrap/lib/utils/vmroot-config-path.sh` - Config file path constant
- `bootstrap/lib/utils/vmroot-validate.sh` - Input validation
- `bootstrap/lib/utils/vmroot-prompt.sh` - Interactive prompt helper
- `bootstrap/lib/steps/vmroot-check-config.sh` - Config existence check
- `bootstrap/lib/steps/vmroot-configure-main.sh` - Configure main flow
- `bootstrap/lib/steps/vmroot-main.sh` - Bootstrap main flow

### Build Manifests
- `bootstrap/manifests/vmroot-configure.txt` - Configure script build manifest
- `bootstrap/manifests/vmroot.txt` - Bootstrap script build manifest

### Generated Scripts
- `bootstrap/vmroot-configure.sh` - Generated interactive configuration script
- `bootstrap/vmroot.sh` - Generated VM provisioning script

### Test Infrastructure
- `src/tests/fixtures/vmroot-test-config.json` - Test configuration fixture
- `src/tests/tests/vmroot.test.sh` - Automated test script

## Files to Modify
- `tasks/bootstrap/justfile` - Add vmroot build targets to `build-all`
- `src/tests/docker-compose.yml` - Add vmroot test service
- `tasks/test/justfile` - Add vmroot test target
- `CLAUDE.md` - Document vmroot workflows

## Testing Strategy

### Unit Testing (via Docker)
- Test vmroot-configure.sh creates config correctly
- Test vmroot.sh creates user account
- Test sudoers file created with correct permissions
- Test SSH keys copied with correct ownership
- Test idempotency (running twice produces same result)
- Test error handling (missing config, invalid inputs)

### Integration Testing
- Test full workflow: configure → provision → verify access
- Verify passwordless sudo works for created user
- Verify SSH access works with root's keys

### Manual Verification Steps
1. Run `bash bootstrap/vmroot-configure.sh` as root
2. Verify config saved at `/root/.config/kyldvs/k/vmroot-configure.json`
3. Run `bash bootstrap/vmroot.sh` as root
4. Verify user exists: `id $USERNAME`
5. Verify sudoers: `sudo -l -U $USERNAME`
6. Verify SSH keys: `ls -la $USER_HOME/.ssh/authorized_keys`
7. Test sudo: `su - $USERNAME -c 'sudo whoami'` (should print "root")

## Risk Assessment

**Risk 1: Root privilege escalation**
- Description: Creating sudoers files incorrectly could compromise security
- Mitigation: Use `visudo -c` to validate syntax, set strict 440 permissions, follow sudo best practices

**Risk 2: Home directory conflicts**
- Description: Specifying non-standard home paths could cause permission issues
- Mitigation: Validate parent directory exists and is writable, use `mkdir -p`, fail fast with clear errors

**Risk 3: SSH key exposure**
- Description: Incorrect permissions on .ssh files could expose keys
- Mitigation: Set strict permissions (700 for .ssh, 600 for authorized_keys), verify ownership with chown

**Risk 4: Non-idempotent operations**
- Description: Running script multiple times could create duplicate entries or errors
- Mitigation: Check existence before creating (user, sudoers file, .ssh directory), skip if already present

**Risk 5: Missing dependencies**
- Description: Script might fail on minimal VM installations
- Mitigation: Validate root user at start, provide clear error messages for missing utilities

## Estimated Complexity
**Moderate**

Rationale:
- Straightforward logic (user creation, file copying, permission setting)
- Follows well-established bootstrap patterns
- Clear requirements with minimal ambiguity
- Main complexity is ensuring idempotency and proper error handling
- Testing requires Docker infrastructure but follows existing patterns

## Notes

### Implementation Considerations
- All scripts must validate root user (`[ "$(id -u)" -eq 0 ]`) at startup
- Use POSIX-compliant shell where possible (configure can use `/bin/bash` for advanced features)
- Follow existing logging conventions (`kd_log`, `kd_error`, `kd_step_*`)
- Maintain consistent indentation (2 spaces)
- All generated scripts should be executable (`chmod +x`)

### Security Considerations
- Never log passwords or sensitive data
- Validate all user inputs before using in commands
- Use quotes around all variable expansions
- Set minimum necessary file permissions (principle of least privilege)
- Validate sudoers syntax before activating

### Performance Considerations
- Minimal - these scripts run once per VM provisioning
- Most operations are single commands (useradd, cp, chmod)
- No network calls or expensive loops

### Edge Cases
- User already exists → Skip user creation, update sudo/SSH only
- Root has no authorized_keys → Skip SSH setup, log warning
- Home directory parent doesn't exist → Create with `mkdir -p`
- Config file missing when running vmroot.sh → Exit with clear error pointing to configure
- Running as non-root → Exit immediately with error

### Pattern Matching
- Study `bootstrap/lib/steps/profile-init.sh` for idempotent step patterns
- Study `bootstrap/lib/steps/configure-main.sh` for config creation pattern
- Study `bootstrap/manifests/*.txt` for component ordering
- Match existing header format from `header-configure.sh` and `header-termux.sh`

### Agent Delegation Recommendations
- **DIRECT implementation**: This is a straightforward task (12 new files, 4 modifications)
- **Parallel potential**: Phase 1-2 tasks could be done in parallel (step components vs utility components)
- **Test-driven**: Consider writing tests (Phase 6) early to guide implementation

### Open Questions from Spec
Decisions made for implementation:
1. **Should vmroot.sh auto-run user configure?** → No, keep separation of concerns
2. **Validate home directory parent is writable?** → Yes, fail fast in validation
3. **Support additional fields (shell, groups)?** → No, keep minimal (can extend later)
4. **Handle existing user?** → Skip user creation, update sudo/SSH only (idempotency)
