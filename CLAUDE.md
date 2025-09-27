# `k`

dotfiles

This is the dotfiles repo for kyldvs.

## General Instructions

- Be extremely terse and concise always
- Use conventional commit style
- When writing a commit message only include a one line message, not a detailed message
- Include a newline at end of files, always
- Attempt to limit line length to 80

## Justfile Organization

- Main `justfile` contains general recipes and module imports
- Task-specific recipes organized in `tasks/*/justfile` modules
- Use `mod name "tasks/name"` to import modules in main justfile
- All module recipes use `[no-cd]` attribute to run from project root
- Module recipes accept arguments when called by external tools (e.g. lint-staged)
- Git hooks defer to just commands: `.husky/pre-commit` → `just hooks pre-commit`
