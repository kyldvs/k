# Input Validation - Specification

## Overview
Add immediate input validation to bootstrap configuration prompts to catch formatting errors (invalid hostnames, ports, usernames) at input time rather than during later SSH connection attempts. This enforces the "Good Code is Thorough" and "errors surface immediately" principles.

## Goals
- Catch invalid configuration input immediately during prompting
- Provide clear, actionable error messages for invalid input
- Prevent confusing late-stage SSH connection failures from malformed config
- Maintain POSIX shell compliance and simplicity

## Requirements

### Functional Requirements
- FR-1: Validate hostname format according to RFC 1123 (alphanumeric, hyphens, dots; max 253 chars; no leading/trailing hyphens or dots)
- FR-2: Validate port numbers as integers in range 1-65535
- FR-3: Validate usernames against POSIX rules (lowercase, digits, underscore, hyphen; start with letter or underscore; max 32 chars)
- FR-4: Validate directory paths as absolute paths with no shell injection characters
- FR-5: Re-prompt user on invalid input with clear error message
- FR-6: Continue prompting until valid input provided
- FR-7: Support default values that are pre-validated

### Non-Functional Requirements
- NFR-1: Validators must be POSIX-compliant shell functions
- NFR-2: Validation logic must be reusable across all prompt functions
- NFR-3: Error messages must clearly state what is invalid and what format is expected
- NFR-4: Validation must not significantly slow down the prompt experience (< 100ms per validation)

### Technical Requirements
- New file: `bootstrap/lib/utils/validators.sh` containing validation functions
- Modify: `bootstrap/lib/utils/prompt.sh` to add `prompt_validated()` function
- Modify: `bootstrap/lib/utils/vmroot-prompt.sh` to add `vmroot_prompt_validated()` function
- Update: `bootstrap/lib/steps/configure-main.sh` to use validated prompts
- Update: `bootstrap/lib/steps/vmroot-configure-main.sh` to use validated prompts
- Update: `bootstrap/manifests/configure.txt` to include validators.sh
- Update: `bootstrap/manifests/vmroot-configure.txt` to include validators.sh

## User Stories / Use Cases
- As a user configuring bootstrap, I want to be told immediately when I enter an invalid hostname (e.g., "my host" with space) so that I can correct it before it causes SSH failures
- As a user, I want clear error messages that explain what format is expected (e.g., "Port must be 1-65535") so I can provide valid input
- As a user, I can accept default values by pressing Enter, knowing defaults are already validated
- As a developer, I can reuse validation functions across different configuration scripts without duplicating logic

## Success Criteria
- All four validators (hostname, port, username, directory) correctly identify valid and invalid inputs per specifications
- Invalid input triggers re-prompt with helpful error message in all configuration flows
- Unit tests cover at least 10 edge cases per validator (empty, boundary values, special characters, length limits)
- Existing integration tests (mobile-termux, vmroot) continue to pass without modification
- Configuration scripts successfully reject and re-prompt for: hostname with spaces, port "abc", port 99999, username with uppercase, username starting with digit

## Constraints
- Must maintain POSIX shell compatibility (no bash-isms)
- Cannot use external dependencies beyond standard Unix utilities (grep, etc.)
- Must work in minimal environments (Termux, Alpine containers)
- Validation regex patterns must be simple enough to understand and maintain
- Cannot break existing test infrastructure

## Non-Goals
- Validating that hostname is resolvable or port is reachable (connectivity testing)
- Preventing adversarial or malicious input (focus on catching typos and format mistakes)
- Validating semantic correctness (e.g., whether a username actually exists on target system)
- Providing auto-completion or suggestions for valid values
- Multi-language error messages (English only)

## Assumptions
- Users are configuring bootstrap in good faith (not attempting injection attacks)
- Configuration files are stored in secure locations with appropriate permissions
- Interactive prompts are used in terminal environments (not automated/headless scenarios)
- Doppler secret names do not require validation (assumed correct by convention)

## Open Questions
- Should IPv4/IPv6 addresses be validated differently than hostnames? (Decision: treat as valid hostnames if they match IP regex)
- Should port validation warn on privileged ports (< 1024)? (Decision: no, allow all 1-65535 without warnings)
- Should username validation be stricter than POSIX (e.g., disallow hyphens)? (Decision: follow POSIX portable username rules strictly)
- Should directory validation check for existence? (Decision: no, only validate format to avoid side effects)
