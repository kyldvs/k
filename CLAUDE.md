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
