# `k`

dotfiles

This is the dotfiles repo for kyldvs.

## General Instructions

- Be extremely terse and concise always
- Include a newline at end of files, always
- Attempt to limit line length to 80

## Version Control

- Use conventional commit style
- When writing a commit message only include a one line message, not a detailed message
- Git hooks: defer to just (`.husky/pre-commit` → `just hooks pre-commit`)

## Justfile Organization

- Main `justfile`: general recipes + module imports
- Modules: `tasks/*/justfile` with `mod name "tasks/name"`
- All recipes: use `[no-cd]` attribute
- No echo by default: prefix recipe with `@`
- Bash recipes (with `#!/usr/bin/env bash`): no `@` prefix (`@` reverses behavior)

## Bootstrap System

Modular bootstrap system for compiling reusable setup scripts.

### Structure
- `src/parts/*.sh`: Individual setup components (functions)
- `src/bootstrap/*.json`: Configuration files specifying which parts to include
- `tasks/bootstrap/`: Build system and templates
- `bootstrap/*.sh`: Generated output scripts (do not edit manually)

### Adding New Parts
1. Create `src/parts/part-name.sh` with function `_part_name()`
2. Split logic: create `_needs_part_name()` function for checks
3. Use `return` not `exit` inside functions (compiled script context)
4. Bootstrap scripts must be non-interactive (no prompts, no `read`)
5. Add part name to relevant JSON config in `src/bootstrap/`
6. Rebuild with `just bootstrap build <config>`

### Commands
- `just bootstrap build termux` - Build termux.sh from termux.json
- Parts are fenced with `#--- part-name ---#` markers in output

### Part Utility Functions
- `kd_step_start "step-name" "description"` - Always call first
- `kd_step_end` - Prints "✓ done"
- `kd_step_skip "reason"` - Call after step_start if skipping
- `kd_log "message"` - Prefer messages fit within 60 char terminal
- Use tilde paths (`~/file`) not `$HOME`
- Step names use dash format (`"fake-sudo"`)

## Planning
- When planning features, include "commit and push" as final steps
