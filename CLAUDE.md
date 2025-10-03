# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository

## Repository Info

- Name: `kyldvs/k`
- Desc: kyldvs dotfiles and machine setup

## Principles

# Less but Better

Software engineering principles inspired by Dieter Rams' design philosophy: "Weniger, aber besser" (Less, but better).

Good design is not about adding features—it's about removing everything that doesn't serve a purpose. Every line of code is a liability. Every abstraction is a cost. The best solution is the one that solves the problem with the least complexity.

### 1. Good Code is Innovative

Innovation means solving problems in new ways, not using new technology for its own sake.

- Choose boring technology for boring problems
- Innovate only where it creates clear value
- Let constraints drive creative solutions
- Question "the way we've always done it"
- Measure innovation by outcomes, not novelty

### 2. Good Code is Useful

Code exists to solve problems. If it doesn't make the product more useful, it doesn't belong.

- Solve real problems, not imagined ones
- Build what users need, not what you want to build
- Validate assumptions before implementing
- Delete features that aren't used
- Optimize for the common case

### 3. Good Code is Aesthetic

Code is read far more than written. Aesthetic code is pleasant to read and reveals its intent.

- Consistent formatting and naming
- Symmetry and patterns over exceptions
- Whitespace and structure aid comprehension
- Beauty emerges from constraint, not decoration
- If it looks wrong, it probably is wrong

### 4. Good Code is Understandable

Clarity is not optional. Code should be obvious at a glance.

- Names reveal intent and domain concepts
- Functions do one thing at the right level of abstraction
- Control flow is linear and predictable
- Clever is the enemy of clear
- Complexity should be unavoidable, not accidental

### 5. Good Code is Unobtrusive

Good abstractions fade into the background, letting you focus on the problem domain.

- Don't force users to learn your framework
- Convention over configuration
- Sensible defaults for 90% of cases
- Power for the 10% who need it
- Infrastructure should be invisible when it works

### 6. Good Code is Honest

Code should be exactly what it appears to be. No surprises, no hidden behavior.

- Functions do what their names say
- Types reflect actual constraints
- Errors surface immediately, not later
- No action at a distance
- Performance characteristics match intuition

### 7. Good Code is Long-lasting

Code should age gracefully. Write for maintainers, not just for now.

- Dependencies are minimized and justified
- Standards outlive frameworks
- Fundamental patterns over temporary trends
- Documentation explains why, not what
- Backwards compatibility is a feature

### 8. Good Code is Thorough

Quality is in the details. Incomplete work creates friction for everyone who follows.

- Handle edge cases explicitly
- Validate inputs, assert invariants
- Test behavior, not implementation
- Logging for debugging, metrics for monitoring
- Every detail serves a purpose

### 9. Good Code is Sustainable

Software development is a marathon. Optimize for the long term.

- Technical debt is tracked and addressed
- Build time is a feature
- Cognitive load is minimized
- Energy and resources are conserved
- Team happiness enables sustainability

### 10. Good Code is as Little Code as Possible

The best code is no code. The second best is less code.

- Delete more than you add
- Reuse before writing
- Compose instead of building from scratch
- Solve the actual problem, not the general case
- When in doubt, do less

---

**Less, but better.** This is not about minimalism for its own sake—it's about respecting the people who will read, maintain, and live with your code. Every line should earn its place. Every abstraction should pay for its complexity. Every feature should solve a real problem.

If you can't explain why it needs to exist, it probably doesn't.

## Command Execution

- **Working Directory**: All commands run from repository root
- **Never cd**: Avoid changing directories
- **Use just**: All codebase operations (test, lint, build, etc.) must be executed via `just` recipes
- **Implementation**: Prefer implementing logic directly in justfile recipes; create standalone bash scripts only when necessary, but always invoke them through `just`

## Tasks System

- Task files in `docs/tasks/` document planned work
- Move completed tasks to `docs/tasks-done/`
- Each task includes scope, success criteria, and implementation notes

## Current Priorities

Tasks are prioritized to align with "Less but Better" principles.

### High Priority

1. **refactor-error-handling** - Fix principle #6 violations (honesty)
   - Add retry logic for network operations
   - Separate error types (error, warning, info)
   - Wrap Doppler, pkg install, SSH operations in retry wrapper
   - Est: 4-6 hours

2. **vmroot-test-fixes** - Blocks CI integration
   - Fix exit 255 issue in vmroot tests
   - Required before enabling automated CI
   - Est: 1-2 hours

### Medium Priority

3. **shellcheck-integration** - Automated code quality (quick win)
   - Quick to implement, high value for principle #9 (sustainability)
   - Pre-commit hook + CI integration
   - Est: 2-3 hours

4. **input-validation** - Improve principle #8 (thoroughness)
   - Validate user inputs immediately at prompt time
   - Add validators: hostname, port, username, directory
   - Est: 2-3 hours

5. **ci-integration** - Automated testing in GitHub Actions
   - GitHub Actions workflow for automated test runs
   - Depends on: vmroot-test-fixes
   - Est: 2-3 hours

### Low Priority

6. **vm-user-bootstrap** - Complete VM setup
   - Implement vm.sh (nvm, zsh, pnpm, corepack, tools)
   - Large feature, non-urgent
   - Est: 8-10 hours

7. **vm-mosh-server** - Mosh server setup on VM
   - Configure mosh-server for Termux → VM connection
   - Est: 2-3 hours

8. **termux-keyboard-config** - Keyboard layout configuration
   - Custom keyboard layouts for Termux
   - Est: 1-2 hours

9. **task-management-cleanup** - Organizational hygiene
   - Archive completed work, update task priorities
   - Meta-work, improves maintainability
   - Est: 1 hour

### Completed

- bootstrap-profile-init (see archive/docs/plan/)
- modular-bootstrap (see archive/docs/plan/)
- vm-root-bootstrap (see archive/docs/plan/)

### Recommended Order

1. shellcheck-integration (quick win, unblocks quality automation)
2. refactor-error-handling (high value, fixes principle violations)
3. input-validation (complements error handling)
4. vmroot-test-fixes (unblocks CI)
5. ci-integration (enables continuous quality)
6. vm-user-bootstrap (completes the stack)
7. Other features as needed

## Code Style

- 80 char line limit (readability > density)
- Newline at EOF
- No trailing whitespace
- Consistent indentation (2 spaces for shell, configs)
- POSIX-compliant shell when possible
- Variable naming: `KD_*` for globals, lowercase for locals

## Quick Reference

```bash
just test all            # Run all tests
just test mobile termux  # Run mobile termux tests
just test vmroot         # Run vmroot tests
just vcs cm "msg"        # Commit with message
just vcs push            # Push to remote
just bootstrap build-all # Build all bootstrap scripts
shellcheck script.sh     # Lint shell script
```

## Architecture Overview

```
.
├── bootstrap/           # Config-driven bootstrap scripts
├── src/tests/          # Docker-based mobile test infrastructure
├── tasks/             # Justfile modules
└── justfile           # Main entry point
```

## Version Control

### Commit Workflow
- **ALWAYS** use: `just vcs cm "commit message"` then `just vcs push`
- Or combine: `just vcs cm "msg" && just vcs push`
- Never use raw git commands for commits
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`
- Single-line messages only
- Atomic commits - one logical change per commit

### Git Hooks
- Pre-commit: `just hooks pre-commit`
- Managed through Husky
- Auto-runs linting, tests before commit

## Shellcheck Integration

All shell scripts are linted with shellcheck to catch bugs and enforce best practices.

### Pre-commit
- Shellcheck runs automatically on staged `.sh` files
- Commit blocked if violations found
- Fix errors or add inline suppressions with rationale

### Manual Linting
```bash
# Lint all source scripts
find bootstrap/lib src/tests -name '*.sh' -exec shellcheck {} +

# Lint specific file
shellcheck path/to/script.sh
```

### Inline Suppressions
For false positives or justified exceptions:
```bash
# shellcheck disable=SC2034  # Variable used in sourced context
export MY_VAR="value"
```

### Common Issues
- **SC2155**: Declare and assign separately: `local var; var=$(cmd)`
- **SC2086**: Quote variables: `"$var"` not `$var`
- **SC2006**: Use `$(cmd)` not `` `cmd` ``

## Justfile System

**The justfile is the sole entrypoint for all codebase operations.** All management, testing, linting, building, and deployment commands must be implemented and executed through just recipes.

### Design Principles
- Modular organization via `mod` imports
- All recipes use `[no-cd]` - explicit paths only
- Silent by default (`@` prefix)
- Bash recipes inverse (`#!/usr/bin/env bash`)

### Module Structure
```
justfile              # Main recipes + imports
tasks/*/justfile     # Module-specific recipes
```

### Writing Recipes
```just
[no-cd]               # Required on all recipes
@recipe-name param:   # Silent execution
  command {{param}}

[no-cd]
script-recipe:        # Verbose bash script
  #!/usr/bin/env bash
  set -euo pipefail   # Always use strict mode
  echo "Visible output"
```

## Bootstrap System

Config-driven bootstrap for mobile development environments.

### Architecture
Bootstrap scripts are built from modular components:
```
bootstrap/
├── lib/                   # Reusable components
│   ├── utils/            # Core utilities (colors, logging, steps)
│   └── steps/            # Installation steps
├── manifests/            # Build manifests
│   ├── configure.txt     # Component list for configure.sh
│   └── termux.txt        # Component list for termux.sh
├── configure.sh          # Generated (committed)
└── termux.sh             # Generated (committed)
```

Build system concatenates components based on manifests:
```bash
just bootstrap build configure  # Build configure.sh
just bootstrap build termux     # Build termux.sh
just bootstrap build-all        # Build all scripts
```

### Scripts
- `bootstrap/configure.sh` - Interactive setup, creates `~/.config/kyldvs/k/configure.json`
- `bootstrap/termux.sh` - Minimal Termux environment with SSH/Mosh to VM
- `bootstrap/vmroot-configure.sh` - VM root config, creates `/root/.config/kyldvs/k/vmroot-configure.json`
- `bootstrap/vmroot.sh` - VM root bootstrap, provisions non-root user with sudo/SSH
- `bootstrap/vm.sh` - Future VM provisioning (stub)

### Key Functions
- `kd_step_start/end/skip` - Step logging
- `kd_log/error` - Output helpers

### Usage
```bash
# One-time configuration (Termux)
bash <(curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/configure.sh)

# Bootstrap Termux environment
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/termux.sh | sh

# Configure VM root bootstrap (run as root on VM)
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot-configure.sh | sh

# Bootstrap VM root user (run as root on VM)
curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot.sh | sh
```

## Testing

Docker Compose-based mobile tests validate bootstrap scripts with mocked dependencies.

```bash
# Run tests
just test all            # Run all tests (mobile + vmroot)
just test mobile termux  # Explicit mobile test
just test vmroot         # VM root bootstrap test
just test clean          # Cleanup containers/images

# Test structure
# src/tests/tests/mobile-termux.test.sh
#!/usr/bin/env bash
set -euo pipefail
. /lib/assertions.sh
cat /var/www/bootstrap/termux.sh | bash  # Run via direct mount
assert_file "$HOME/.ssh/gh_vm"           # Verify
cat /var/www/bootstrap/termux.sh | bash  # Idempotency
```

## Development Practices

### Shell Scripts
- Set strict mode: `set -euo pipefail`
- Exit codes: 0=success, 1=error, 2=usage
- Minimize subprocess spawning
- Use quotes around variables
- Prefer absolute paths

### Debugging
```bash
# Disable colors for logs
export KD_NO_COLOR=1

# Run mobile tests
just test mobile termux
```

### Security
- Never commit secrets/credentials
- Check file permissions before operations

### Agent Delegation
**When to use agents:**
- Complex features with intricate business logic
- Parallel tasks (2+ independent changes)
- Large code investigations
- Implementing multi-step plans

**When to work directly:**
- Small scope (1-4 files)
- Active debugging (rapid iteration)
- Quick fixes

**Agent prompt structure:**
- Specify files to read for patterns
- List target files to modify
- Define boundaries with other tasks
- Provide expected output format

**For parallel work:**
- Implement shared dependencies first (types, interfaces)
- Launch agents with clear boundaries
- Use specialized agents (backend-developer, frontend-ui-developer)

### Repository Patterns
- Study neighboring files first - patterns emerge from existing code
- Use precise types - research actual types instead of `any`

## Workflows

### Modify Bootstrap Scripts
1. Edit component files in `bootstrap/lib/utils/` or `bootstrap/lib/steps/`
2. Run `just bootstrap build-all` to regenerate scripts
3. `just test all`
4. `just vcs cm "fix|refactor: description" && just vcs push`

### Add Mobile Test Assertions
1. Update `src/tests/tests/mobile-termux.test.sh`
2. Add new assertions using `src/tests/lib/assertions.sh`
3. `just test mobile termux`
4. `just vcs cm "test: description" && just vcs push`

### Bootstrap VM with Root User
1. On VM as root: `curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot-configure.sh | sh`
2. Answer prompts (username, homedir)
3. Run bootstrap: `curl -fsSL https://raw.githubusercontent.com/kyldvs/k/main/bootstrap/vmroot.sh | sh`
4. Verify: `su - <username> -c 'sudo whoami'` (should print "root")
