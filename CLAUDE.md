# `k` - kyldvs dotfiles

## Quick Reference

### Most Used Commands
```bash
just bootstrap build        # Build all bootstrap scripts
just test all              # Test all configurations
just vcs acp "msg"         # Add, commit, push (prefer over git)
```

## General Instructions

- **Be extremely terse and concise always**
- Include newline at end of files
- Limit line length to 80 chars
- No unnecessary files - prefer editing existing over creating new

## Version Control

### Git Workflow
- **ALWAYS** use: `just vcs acp "commit message"`
- Conventional commit style (feat:, fix:, docs:, etc.)
- One-line commit messages only
- Git hooks handled by just (`.husky/pre-commit` → `just hooks pre-commit`)

## Justfile Organization

### Structure
- Main `justfile`: general recipes + module imports
- Modules: `tasks/*/justfile` with `mod name "tasks/name"`

### Recipe Rules
- All recipes: use `[no-cd]` attribute
- Silent by default: prefix with `@`
- Bash recipes: no `@` prefix (reverses behavior)

## Bootstrap System

Modular system for compiling reusable setup scripts.

### Directory Structure
```
src/parts/*.sh          # Individual components (functions)
src/bootstrap/*.json    # Configs specifying which parts
tasks/bootstrap/        # Build system and templates
bootstrap/*.sh          # Generated scripts (DO NOT EDIT)
```

### Creating Parts
1. Create `src/parts/part-name.sh` with `_part_name()` function
2. Add `_needs_part_name()` for idempotency checks
3. Use `return` not `exit` (compiled context)
4. Must be non-interactive (no prompts/read)
5. Add to JSON config in `src/bootstrap/`
6. Build: `just bootstrap build`

### Part Functions
```bash
kd_step_start "name" "desc"  # Start step (always first)
kd_step_end                   # Complete step
kd_step_skip "reason"         # Skip with reason
kd_log "message"              # Indented output
```
- Use `~/path` not `$HOME/path`
- Step names: dash-case (`"fake-sudo"`)

## Testing System

Docker-based testing for bootstrap scripts.

### Commands
```bash
just test all              # Test all configs
just test config termux    # Test specific config
just test clean           # Clean containers
```

### Custom Build Scripts
- Create `src/tests/images/{env}/build.sh` for custom Docker build
- Automatically used if present
- Example: Termux uses ulimit workaround

### Termux-Specific Issues
- DNS fails due to dnsmasq file descriptor bug
- Fix: `--ulimit nofile=65536:65536` flag
- Container needs root for DNS, but pkg needs system user
- Use `--user system` with docker exec commands

### Test Requirements
- Python HTTP server for bootstrap delivery
- Tests must verify idempotency
- Use absolute paths in symlinks

## Development Workflow

### Standard Flow
1. `just bootstrap build` - Build scripts
2. `just test all` - Run tests
3. `just vcs acp "feat: description"` - Commit & push

### Planning Tasks
- Always include final step: `just vcs acp`
- Use TodoWrite tool for complex multi-step tasks
