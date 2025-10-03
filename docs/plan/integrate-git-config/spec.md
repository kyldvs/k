# Integrate Git Configuration - Specification

## Overview

Create a bootstrap component that automatically configures Git with sensible
defaults during VM user provisioning. This eliminates manual Git configuration,
reduces errors, and ensures consistent development environment across all VM
instances.

## Goals

- Provide automatic Git configuration with proven defaults during VM bootstrap
- Preserve user identity (user.name, user.email) while applying workflow
  settings
- Enable idempotent execution that's safe to run multiple times
- Eliminate manual Git configuration steps for VM users

## Requirements

### Functional Requirements

- FR-1: Apply 8 specific Git configuration settings to user's global config:
  - push.default = current
  - pull.ff = true
  - merge.ff = true
  - merge.conflictstyle = zdiff3
  - init.defaultBranch = main
  - diff.algorithm = histogram
  - log.date = iso
  - core.autocrlf = false
- FR-2: Preserve existing user.name and user.email values if present
- FR-3: Skip configuration if already applied (idempotent behavior)
- FR-4: Log all actions using established logging functions (kd_step_start,
  kd_step_end, kd_step_skip)
- FR-5: Exit with code 0 on success, non-zero on failure

### Non-Functional Requirements

- NFR-1: Execution time under 1 second on typical VM hardware
- NFR-2: No network dependencies (all operations local)
- NFR-3: POSIX-compliant shell script (no bashisms)
- NFR-4: Safe to run multiple times without side effects
- NFR-5: Clear error messages if Git not installed or operations fail

### Technical Requirements

- Must be implemented as `bootstrap/lib/steps/git-config.sh`
- Must follow established bootstrap component patterns (see ssh-keys.sh)
- Must use `git config --global` commands for all settings
- Must integrate with vm.txt manifest (when vm.sh is implemented)
- Must include test coverage in VM bootstrap test suite
- Requires Git to be installed (dependency already satisfied by VM bootstrap)

## User Stories / Use Cases

- As a VM user, I want Git configured automatically so that I don't encounter
  "no upstream branch" errors when pushing
- As a VM user, I want better conflict resolution display (zdiff3) so that
  merge conflicts are easier to understand
- As a VM user, I want consistent Git behavior across all VMs so that I don't
  need to remember which environment I'm in
- As a developer re-running bootstrap, I want the script to skip if already
  configured so that I don't get errors or duplicated config
- As a user with existing Git identity, I want my user.name and user.email
  preserved so that my commits are properly attributed

## Success Criteria

- File `bootstrap/lib/steps/git-config.sh` created following component patterns
- All 8 configuration values correctly written to ~/.gitconfig
- Existing user.name and user.email values preserved after configuration
- Running twice produces "already configured" skip message on second run
- Test assertions added to vm.test.sh validating:
  - All config values present and correct
  - Idempotency (no errors on second run)
  - User identity preservation
- Component added to vm.txt manifest
- Documentation in component comments explains each setting's purpose

## Constraints

- Cannot implement full integration until vm.sh is implemented (currently stub)
- Must not overwrite user customizations beyond the 8 specified settings
- Must work with Git versions available in Ubuntu 24.04 LTS
- Cannot require interactive prompts (must be fully automated)

## Non-Goals

Explicitly out of scope:
- Setting up Git credential helpers or authentication
- Configuring Git aliases or advanced workflows
- Installing Git (already part of VM bootstrap)
- Syncing settings from remote configuration source
- Interactive configuration prompts or customization
- Setting user.name or user.email (user's responsibility)
- Configuring commit signing or GPG keys

## Assumptions

- Git is installed before this component runs
- User has write access to ~/.gitconfig
- ~/.gitconfig follows standard Git config file format
- Git config commands exit with code 0 on success
- The 8 configuration values are appropriate for all VM users
- VM bootstrap runs with sufficient permissions for file operations

## Open Questions

None - task description provides complete implementation guidance.
