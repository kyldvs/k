# Integrate Git Configuration

## Description

Integrate sensible Git configuration defaults from kyldvs/dotfiles into the VM
bootstrap system. VM users should automatically receive well-configured Git
settings that improve day-to-day development workflow without manual
configuration.

## Current State

**Source Configuration:**
- Git config exists in `module/dotfiles/links/git/.gitconfig`
- Contains proven, useful defaults for development workflow
- Currently only available via manual dotfiles installation

**VM Bootstrap:**
- `bootstrap/vm.sh` is a stub (not yet implemented)
- No automatic git configuration setup
- Users must manually configure git after VM provisioning

**Gap:**
- VM users don't get sensible git defaults automatically
- Manual configuration is error-prone and inconsistent

## Scope

Create a bootstrap component that configures Git with sensible defaults from
the dotfiles repository. Integration happens during VM user bootstrap.

**Configuration to Apply:**
```gitconfig
[push]
  default = current          # Push current branch without explicit upstream

[pull]
  ff = true                  # Fast-forward only on pull

[merge]
  ff = true                  # Fast-forward when possible
  conflictstyle = zdiff3     # Better conflict resolution display

[init]
  defaultBranch = main       # Modern default branch name

[diff]
  algorithm = histogram      # More intuitive diffs

[log]
  date = iso                 # ISO timestamp format

[core]
  autocrlf = false           # No automatic line ending conversion
```

**Implementation Requirements:**
- Create `bootstrap/lib/steps/git-config.sh` component
- Preserve existing `user.name` and `user.email` if present
- Idempotent operation (safe to run multiple times)
- No destructive overwrites of user customizations
- Add to vm.txt manifest (when vm.sh is implemented)

## Success Criteria

- [ ] Component file created: `bootstrap/lib/steps/git-config.sh`
- [ ] Configuration applied to `~/.gitconfig`
- [ ] Existing user.name and user.email preserved
- [ ] Idempotent behavior validated
- [ ] Tests added to VM bootstrap test suite
- [ ] Component follows existing bootstrap patterns

## Implementation Notes

**Component Structure:**

Follow the established pattern from existing steps like `ssh-keys.sh`:
- Function named `configure_git` or similar
- Use `kd_step_start`, `kd_step_end`, `kd_step_skip`
- Check if configuration already applied (idempotency)
- Log actions clearly

**Idempotency Strategy:**

Check for marker comment or specific config values:
```bash
# Check if already configured
if git config --global --get merge.conflictstyle >/dev/null 2>&1; then
  kd_step_skip "Git already configured"
  return 0
fi
```

**Preserve User Identity:**

Read existing user.name and user.email before applying configuration:
```bash
# Preserve existing identity
user_name=$(git config --global --get user.name 2>/dev/null || echo "")
user_email=$(git config --global --get user.email 2>/dev/null || echo "")
```

**Apply Configuration:**

Use `git config --global` commands:
```bash
git config --global push.default current
git config --global pull.ff true
git config --global merge.ff true
git config --global merge.conflictstyle zdiff3
git config --global init.defaultBranch main
git config --global diff.algorithm histogram
git config --global log.date iso
git config --global core.autocrlf false
```

**Restore User Identity:**
```bash
# Restore user identity if it existed
if [ -n "$user_name" ]; then
  git config --global user.name "$user_name"
fi
if [ -n "$user_email" ]; then
  git config --global user.email "$user_email"
fi
```

**Testing:**
- Add assertions to `src/tests/tests/vm.test.sh` (when created)
- Verify config values applied: `git config --global --get merge.conflictstyle`
- Test idempotency: run twice, verify no errors or duplicates
- Test preservation: set user.name/email, run script, verify preserved

## Dependencies

**Prerequisites:**
- Git installed (already part of VM bootstrap)
- vm.sh implementation (currently stub)

**Blocks:**
- This task is blocked by implementation of vm.sh
- Can prepare component in advance for integration when vm.sh is ready

**Related Tasks:**
- [vm-user-bootstrap.md](./vm-user-bootstrap.md) - Parent task for vm.sh
  implementation

## Value Proposition

**Solves Real Problems:**
- `push.default = current` - No more "fatal: The current branch has no
  upstream branch" errors
- `merge.conflictstyle = zdiff3` - Significantly clearer conflict resolution
  with common ancestor context
- `diff.algorithm = histogram` - More intuitive and readable diffs
- `init.defaultBranch = main` - Aligns with GitHub and modern conventions

**Minimal Complexity:**
- Simple file writing and git commands
- No external dependencies beyond git itself
- Straightforward idempotency checks

**Consistent Environment:**
- VM users get same sensible defaults as manual dotfiles installation
- Reduces cognitive load across environments
- Prevents "why does git behave differently here?" confusion

## Related Files

- Source: `module/dotfiles/links/git/.gitconfig`
- Component: `bootstrap/lib/steps/git-config.sh` (to be created)
- Manifest: `bootstrap/manifests/vm.txt` (to be created)
- Target: `bootstrap/vm.sh` (currently stub)
- Tests: `src/tests/tests/vm.test.sh` (to be created)

## Priority

**Medium** - Valuable quality-of-life improvement, but not blocking core
functionality. Should be implemented as part of vm.sh bootstrap
implementation.

## Estimated Effort

1-2 hours (simple component following established patterns)
