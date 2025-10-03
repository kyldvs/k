# Refactor Error Handling - Specification

## Overview
Improve error handling in bootstrap scripts by adding retry logic for transient network failures and distinguishing between fatal errors, warnings, and informational messages. This aligns with the "Less but Better" principle #6 (Good Code is Honest) - errors should surface immediately with appropriate context and severity.

## Goals
- Enable automatic retry for transient network failures to improve reliability
- Distinguish between fatal errors, warnings, and informational messages for clearer user feedback
- Maintain existing fail-fast behavior for non-retryable errors
- Provide clear, contextual error messages that indicate severity and retry status

## Requirements

### Functional Requirements
- FR-1: Network operations automatically retry on transient failures (up to 3 attempts by default)
- FR-2: Fatal errors stop execution immediately and display as errors
- FR-3: Non-fatal issues display as warnings and allow script continuation
- FR-4: Informational messages provide context without indicating problems
- FR-5: Retry attempts log progress clearly (e.g., "Retry 1/3 in 2s...")
- FR-6: Failed retries display clear error messages indicating exhaustion

### Non-Functional Requirements
- NFR-1: Retry logic adds minimal execution time overhead (2 second default delay between attempts)
- NFR-2: Error output maintains existing stderr routing for errors/warnings
- NFR-3: All changes maintain backwards compatibility with existing strict mode (`set -euo pipefail`)
- NFR-4: No external dependencies introduced - pure bash implementation

### Technical Requirements
- Create new utility file: `bootstrap/lib/utils/retry.sh`
- Extend existing file: `bootstrap/lib/utils/logging.sh`
- Apply retry logic to network operations in: `bootstrap/lib/steps/*.sh`
- Update all build manifests to include retry.sh
- Environment variables for configuration: `KD_RETRY_MAX` (default: 3), `KD_RETRY_DELAY` (default: 2)

## User Stories / Use Cases
- As a user running bootstrap on flaky network, I want network operations to retry automatically so that transient failures don't stop installation
- As a user viewing bootstrap output, I want to distinguish between fatal errors and warnings so that I understand severity
- As a developer debugging bootstrap failures, I want clear retry logging so that I can identify network vs code issues
- As a user with stable network, I want retry logic to be transparent so that successful operations don't show unnecessary messages

## Success Criteria
- New file `bootstrap/lib/utils/retry.sh` exists with `kd_retry()` function
- `bootstrap/lib/utils/logging.sh` extended with `kd_warning()` and `kd_info()` functions
- Network operations (Doppler auth, package installation, SSH operations) use `kd_retry` wrapper
- Tests validate retry succeeds after N failures (unit test)
- Tests validate retry fails after max attempts exhausted (unit test)
- Integration tests pass without regression: `just test all`
- Error messages clearly indicate severity level with visual markers (✗ ERROR, ⚠ WARNING, ℹ INFO)
- Built scripts updated: `just bootstrap build-all` completes successfully

## Constraints
- Must maintain existing error handling behavior: `set -euo pipefail` and fail-fast semantics
- Cannot introduce new external dependencies or tools
- Must work in both Termux (Android) and VM (Ubuntu) environments
- Retry logic must be opt-in per operation (not global)
- Color codes must match existing style: red for errors, yellow for warnings, blue for info

## Non-Goals
- Checkpoint/resume system for long-running scripts (deferred to future task if needed)
- Debug mode or verbose logging flags (not required for core problem)
- Automatic detection of retryable vs non-retryable errors (explicit wrapper usage)
- Retry logic for non-network operations (focus on network failures only)
- Configuration file for retry settings (environment variables sufficient)

## Assumptions
- Network failures are transient and retry-able within a short timeframe (2-6 seconds)
- 3 retry attempts with 2 second delays is sufficient for most network issues
- Users can override retry settings via environment variables if needed
- Existing test infrastructure (Docker Compose) can simulate retry scenarios
- Color support is available in target environments (Termux, VM)

## Open Questions
None - task specification is comprehensive and implementation approach is clear.
