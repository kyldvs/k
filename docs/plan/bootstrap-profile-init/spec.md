# Bootstrap Profile Init - Specification

## Overview
A minimal, idempotent .profile initialization system for bootstrap scripts that adds single-line entries for basic shell configuration. Each step copies config files to ~/.config/kyldvs/k/ and adds sourcing lines to .profile, using grep to detect existing entries for idempotency.

## Goals
- Provide minimal shell environment setup during bootstrap
- Ensure idempotent additions to .profile (safe to run multiple times)
- Support modular sourcing of config files with safety checks
- Set basic editor and PATH for immediate usability

## Requirements

### Functional Requirements
- FR-1: Copy config files (e.g., kd-editor.sh, kd-path.sh) to ~/.config/kyldvs/k/
- FR-2: Add single-line sourcing entries to ~/.profile with existence checks
- FR-3: Check if source line exists in .profile (not file existence) for idempotency
- FR-4: Set EDITOR environment variable to nano via kd-editor.sh
- FR-5: Extend PATH with ~/bin via kd-path.sh
- FR-6: Each sourcing line format: `[ -f ~/.config/kyldvs/k/foo.sh ] && . ~/.config/kyldvs/k/foo.sh`

### Non-Functional Requirements
- NFR-1: All additions must be idempotent (no duplicates in .profile)
- NFR-2: Safe to run repeatedly without side effects
- NFR-3: Minimal complexity - no over-engineering for future VM setup
- NFR-4: POSIX shell compatible where possible

### Technical Requirements
- Bootstrap step functions in bootstrap/lib/steps/
- Config file templates in bootstrap/lib/configs/ (or similar)
- Idempotency check: `grep -qF 'source line' ~/.profile`
- File existence checks in sourced lines: `[ -f /path ] && . /path`
- Integration with existing bootstrap build system (just bootstrap build-all)
- Test coverage in mobile-termux.test.sh

## User Stories / Use Cases
- As a Termux user, I want nano set as my editor immediately after bootstrap
- As a bootstrap script, I can safely add config sourcing lines without duplicating
- As a developer, I can run bootstrap multiple times without adding duplicate lines to .profile
- As a user, I want ~/bin in my PATH for custom scripts post-bootstrap

## Success Criteria
- .profile contains single-line entries for each config component
- Running bootstrap twice produces identical .profile (idempotent)
- Editor is set to nano and persists across sessions
- ~/bin is in PATH and usable immediately
- File existence checks in sourcing lines prevent errors if configs deleted
- Mobile tests pass with .profile validation

## Constraints
- Must work in minimal Termux shell environment (sh/bash)
- No dependencies on advanced tools (keep it simple)
- Single-line entries only (no multi-line blocks)
- Must coexist with future zsh/VM setup (non-conflicting)

## Non-Goals
- Complete shell configuration (that's for VM/zsh later)
- Interactive prompts about profile setup
- Migration of existing .profile configurations
- Support for shells other than sh/bash (zsh comes later)
- Complex profile management or templating systems
- Backup/restore of .profile
- Modifying existing .profile lines (append only)

## Assumptions
- .profile is the appropriate file for Termux (not .bash_profile)
- User has write access to ~/.profile
- ~/.config/kyldvs/k/ directory exists (created by configure step)
- Basic shell utilities (grep, test) are available

## Open Questions
- Should PATH additions include other directories beyond ~/bin? (e.g., ~/.local/bin)
- Should we create ~/bin if it doesn't exist as part of the PATH step?
- Where should config file templates live? (bootstrap/lib/configs/ or inline in steps?)
