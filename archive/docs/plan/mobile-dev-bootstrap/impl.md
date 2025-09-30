# Mobile Dev Bootstrap - Implementation Plan

## Prerequisites
- Termux installed on Android device
- Doppler account with SSH keys stored (SSH_GH_VM_PUBLIC/PRIVATE)
- VM accessible via SSH
- Network connectivity

## Architecture Overview

This implementation replaces the existing part-based compilation system with a configuration-driven approach:

**Current System:**
- JSON configs (`src/bootstrap/*.json`) list parts
- Parts (`src/parts/*.sh`) are compiled into bootstrap scripts
- Builder concatenates parts into final scripts

**New System:**
- Interactive configure script creates user config
- Bootstrap scripts read config at runtime
- No compilation step - scripts execute directly
- Reuses existing utility functions for consistency

**Key Changes:**
- `bootstrap/configure.sh` - NEW interactive configuration
- `bootstrap/termux.sh` - REPLACE with config-driven version
- `bootstrap/vm.sh` - STUB for future work
- `~/.config/kyldvs/k/configure.json` - NEW runtime configuration
- Retain `src/parts/util-functions.sh` patterns for consistency

## Task Breakdown

### Phase 1: Foundation & Configuration System
- [x] Task 1.1: Create configuration directory structure
  - Files: N/A (runtime only)
  - Dependencies: None
  - Details: Ensure `~/.config/kyldvs/k/` exists with proper permissions (700)

- [x] Task 1.2: Create interactive configure script
  - Files: `bootstrap/configure.sh`
  - Dependencies: None
  - Details: Prompts for config values (VM, Doppler project/env, SSH key names), writes JSON, sets permissions (600)
  - Implementation: POSIX shell, use printf for prompts, validate inputs
  - Pattern: Follow `util-functions.sh` style for consistency
  - Note: Does NOT prompt for Doppler token - handled via `doppler login`

- [x] Task 1.3: Add JSON schema validation helper
  - Files: `bootstrap/configure.sh` (embedded function)
  - Dependencies: Task 1.2
  - Details: Validate required fields exist before saving config

### Phase 2: Config-Driven Bootstrap Script
- [x] Task 2.1: Create new termux.sh with config loading
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 1.2
  - Details: Load config from JSON, validate presence, parse with jq
  - Implementation: Start from scratch (don't compile from parts)
  - Pattern: Use kd_step_* functions for consistency with old system

- [x] Task 2.2: Implement Termux package installation
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 2.1
  - Details: Install openssh, mosh, jq using pkg
  - Implementation: Check if packages installed before attempting install
  - Pattern: Idempotent checks similar to `_needs_*` pattern

- [x] Task 2.3: Implement Doppler CLI installation
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 2.2
  - Details: Install Doppler CLI for Termux environment
  - Implementation: Use Doppler's official install script or direct download
  - Pattern: Follow existing `doppler.sh` patterns but inline

- [x] Task 2.4: Implement Doppler authentication check
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 2.3
  - Details: Check if Doppler is authenticated, prompt user if not
  - Implementation: `doppler configure get token --plain --silent` to check auth
  - Pattern: If not authenticated, display clear message to run `doppler login` and exit
  - Message: "Please run 'doppler login' to authenticate, then re-run this script"

- [x] Task 2.5: Implement SSH key retrieval from Doppler
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 2.4
  - Details: Fetch SSH_GH_VM_PUBLIC/PRIVATE from Doppler, write to ~/.ssh/
  - Implementation: Create ~/.ssh with 700, write keys with 600/644 perms
  - Pattern: Use doppler secrets get with project/env from config

- [x] Task 2.6: Implement SSH config generation
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 2.5
  - Details: Create ~/.ssh/config with VM host entry
  - Implementation: Generate config with hostname, port, user, IdentityFile
  - Pattern: Append to existing config if present, don't overwrite

- [x] Task 2.7: Implement SSH connection test
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 2.6
  - Details: Test SSH connection to VM without actually connecting
  - Implementation: `ssh -q -o BatchMode=yes -o ConnectTimeout=5 vm exit`
  - Pattern: Non-interactive, clear error messages on failure

- [x] Task 2.8: Implement success message and next steps
  - Files: `bootstrap/termux.sh`
  - Dependencies: Task 2.7
  - Details: Display connection commands (ssha vm, mosha vm)
  - Implementation: Use colored output similar to kd_step_end pattern
  - Pattern: Follow `termux-next-steps.sh` style

### Phase 3: VM Bootstrap Stub
- [x] Task 3.1: Create vm.sh placeholder
  - Files: `bootstrap/vm.sh`
  - Dependencies: None
  - Details: Create stub with clear "future work" message
  - Implementation: Basic script structure, exits with TODO message
  - Pattern: Same header style as termux.sh

### Phase 4: Integration & Cleanup
- [x] Task 4.1: Update .gitignore for user configs
  - Files: `.gitignore`
  - Dependencies: None
  - Details: Add `~/.config/kyldvs/k/configure.json` pattern
  - Implementation: Actually add `.config/kyldvs/k/configure.json` (relative pattern)

- [x] Task 4.2: Add README documentation
  - Files: `README.md`
  - Dependencies: Tasks 1.2, 2.8
  - Details: Document curl-pipe workflow and usage examples
  - Implementation: Add "Quick Start" section with curl commands
  - Pattern: Keep minimal, focus on getting started

- [x] Task 4.3: Mark old system as deprecated
  - Files: `src/bootstrap/*.json`, `tasks/bootstrap/justfile`
  - Dependencies: None
  - Details: Add deprecation comments, keep for reference
  - Implementation: Don't delete, just comment out/mark deprecated

### Phase 5: Testing & Validation
- [ ] Task 5.1: Manual test configure.sh
  - Files: N/A (test only)
  - Dependencies: Task 1.2
  - Details: Run configure, verify JSON created with correct structure
  - Validation: Check file perms (600), valid JSON, all fields present

- [ ] Task 5.2: Manual test termux.sh with mock config
  - Files: N/A (test only)
  - Dependencies: Task 2.8
  - Details: Create test config, run bootstrap, verify each step
  - Validation: Check package installation, SSH key retrieval, config generation

- [ ] Task 5.3: Test idempotency
  - Files: N/A (test only)
  - Dependencies: Task 5.2
  - Details: Run termux.sh twice, ensure no errors or duplicate work
  - Validation: Second run should skip already-completed steps

- [ ] Task 5.4: Test error handling
  - Files: N/A (test only)
  - Dependencies: Task 5.2
  - Details: Test with invalid config, no Doppler auth, unreachable VM
  - Validation: Clear error messages, graceful failures, no partial state

- [ ] Task 5.5: Test curl-pipe workflow
  - Files: N/A (test only)
  - Dependencies: Task 5.2
  - Details: Host scripts, test `curl -fsSL <url> | bash` execution
  - Validation: Works from fresh Termux install without repo clone

## Files to Create
- `bootstrap/configure.sh` - Interactive configuration script
- `bootstrap/termux.sh` - Config-driven Termux setup (replaces compiled version)
- `bootstrap/vm.sh` - Placeholder for future VM provisioning
- `~/.config/kyldvs/k/configure.json` - Runtime user configuration (not in repo)

## Files to Modify
- `.gitignore` - Add config file pattern
- `README.md` - Add quick start documentation
- `src/bootstrap/termux.json` - Add deprecation comment
- `src/bootstrap/vm.json` - Add deprecation comment
- `tasks/bootstrap/justfile` - Add deprecation comment

## Testing Strategy

**Manual Testing (Primary):**
1. Test configure.sh in Termux
   - Run script, answer prompts
   - Verify JSON created with correct values
   - Check file permissions (600)
   - Verify jq can parse output

2. Test termux.sh in Termux
   - Create test config manually
   - Run bootstrap script
   - Verify each step executes correctly
   - Test SSH connection to VM

3. Test idempotency
   - Run termux.sh twice in succession
   - Verify no errors or duplicate work
   - Check that existing configs not overwritten

4. Test curl-pipe workflow
   - Host scripts on local server or GitHub
   - Execute via curl pipe from fresh Termux
   - Verify works without git clone

**Error Cases:**
- Missing config file
- Invalid JSON in config
- Doppler not authenticated
- Doppler secrets not found
- VM unreachable
- Insufficient permissions

**Success Criteria Validation:**
- Fresh Termux to working SSH in < 5 minutes
- Single command for configure
- Single command for bootstrap
- SSH connection succeeds
- Mosh connection succeeds
- No credentials in repo

## Risk Assessment

**Risk 1: Doppler CLI installation on Termux**
- Description: Doppler may not have official Termux support
- Mitigation: Use Alpine proot approach from existing doppler.sh, or install via npm/curl
- Fallback: Document manual Doppler setup steps

**Risk 2: SSH key format compatibility**
- Description: Doppler may store keys with formatting issues
- Mitigation: Validate key format before writing, add newlines if needed
- Fallback: Document manual key setup

**Risk 3: Doppler authentication persistence**
- Description: User may need to re-authenticate Doppler periodically
- Mitigation: Clear error messages prompting user to run `doppler login`
- Future: Document Doppler token expiration behavior

**Risk 4: Breaking existing workflows**
- Description: Replacing compilation system may break existing users
- Mitigation: Keep old system files, mark deprecated, gradual migration
- Fallback: Document migration path for existing users

**Risk 5: Curl-pipe execution environment**
- Description: Script may not have access to required tools (jq, curl)
- Mitigation: Bootstrap essential tools first, clear error messages
- Fallback: Document prerequisite installation steps

## Estimated Complexity
**Moderate**

Rationale:
- Straightforward script development (no complex logic)
- Well-defined requirements and flow
- Some uncertainty around Doppler CLI on Termux
- Testing requires actual Termux environment
- Most work is implementation, not design
- Can reuse patterns from existing codebase

Estimated time: 3-4 hours for implementation + 1-2 hours for testing

## Task Delegation Recommendations

**Direct Implementation (Recommended):**
- All tasks suitable for direct implementation
- Scope is focused (2 main scripts + 1 stub)
- Clear patterns from existing codebase
- Sequential dependencies, not parallel work

**Not Recommended:**
- Agent delegation: Scope too small, patterns clear
- Parallel agents: Tasks are sequential, not independent

## Notes

**Important Considerations:**
- Scripts must be POSIX-compliant for maximum compatibility
- Error messages should guide user to resolution
- Doppler CLI installation may require Alpine proot (see existing doppler.sh)
- SSH config should append, not replace existing configs
- Consider using `set -euo pipefail` but handle errors gracefully

**Pattern Reuse:**
- Use kd_step_start/end/skip for consistency with old system
- Follow util-functions.sh style for logging and colors
- Maintain idempotency pattern from _needs_* functions
- Use platform detection even though Termux-only for now

**Security:**
- Config file permissions: 600 (user read/write only, though no secrets stored)
- SSH private key: 600
- SSH public key: 644
- SSH directory: 700
- Config directory: 700
- Doppler authentication: Managed by Doppler CLI (uses secure token storage)

**Performance:**
- Minimize network calls (Doppler API)
- Cache Doppler secrets if possible
- Fast-fail on missing config or invalid values
- Skip already-completed steps

**Future Enhancements:**
- VM bootstrap implementation (Phase 3)
- Config encryption
- Multiple VM profiles
- SSH key rotation support
- Backup/restore configuration
