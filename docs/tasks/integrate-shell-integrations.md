# Integrate Shell Integrations

## Description

Integrate fzf and zoxide shell integrations from kyldvs/dotfiles into the VM
bootstrap system. VM users should automatically receive enhanced shell
navigation and fuzzy-finding capabilities when these tools are installed.

## Current State

**Source Configuration:**
- Shell integrations exist in `module/dotfiles/links/zsh/.zshrc` (lines
  161-164)
- Uses eval statements to enable tool-specific shell features
- Currently only available via manual dotfiles installation

**VM Bootstrap:**
- `bootstrap/vm.sh` is a stub (not yet implemented)
- No automatic shell integration setup
- Users must manually configure integrations after VM provisioning

**Gap:**
- VM users don't automatically get enhanced shell features
- Manual configuration requires knowing exact commands
- Integration is inconsistent across environments

## Scope

Create a bootstrap component that configures fzf and zoxide shell
integrations from the dotfiles repository. Integration happens during VM user
bootstrap, but only activates if the tools are installed.

**Integrations to Apply:**
```zsh
# kyldvs/k shell-integrations
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi
```

**Implementation Requirements:**
- Create `bootstrap/lib/steps/shell-integrations.sh` component
- Append integrations to `~/.zshrc` if not already present
- Graceful degradation (only integrate if tools exist)
- Idempotent operation (safe to run multiple times)
- Single marker comment for all integrations
- Add to vm.txt manifest (when vm.sh is implemented)

**Out of Scope:**
- Tool installation (handled by separate task)
- Bash shell support (Zsh only)
- Custom fzf configuration or keybindings
- Custom zoxide configuration or aliases
- Other shell integrations beyond fzf and zoxide

## Success Criteria

- [ ] Component file created: `bootstrap/lib/steps/shell-integrations.sh`
- [ ] Integrations appended to `~/.zshrc`
- [ ] Marker comment added for idempotency check
- [ ] Graceful degradation when tools not installed
- [ ] Idempotent behavior validated (safe to run multiple times)
- [ ] Tests added to VM bootstrap test suite
- [ ] Component follows existing bootstrap patterns

## Implementation Notes

**Component Structure:**

Follow the established pattern from existing steps like `zsh-settings.sh`:
- Function named `configure_shell_integrations` or similar
- Use `kd_step_start`, `kd_step_end`, `kd_step_skip`
- Check for marker comment to determine if already applied
- Log actions clearly

**Idempotency Strategy:**

Check for marker comment in ~/.zshrc:
```bash
# Check if already configured
if grep -qF "# kyldvs/k shell-integrations" "$HOME/.zshrc" 2>/dev/null; then
  kd_step_skip "Shell integrations already configured"
  return 0
fi
```

**Apply Configuration:**

Append integration block to ~/.zshrc:
```bash
# Create .zshrc if it doesn't exist
if [ ! -f "$HOME/.zshrc" ]; then
  kd_log "Creating ~/.zshrc"
  touch "$HOME/.zshrc"
  chmod 644 "$HOME/.zshrc"
fi

# Append integration block
kd_log "Adding shell integrations (fzf, zoxide)"
cat >> "$HOME/.zshrc" << 'EOF'

# kyldvs/k shell-integrations
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi
EOF
```

**Function Implementation:**

```bash
# Configure shell integrations for fzf and zoxide
configure_shell_integrations() {
  kd_step_start "shell-integrations" "Configuring shell integrations"

  # Check if already configured (idempotency)
  if grep -qF "# kyldvs/k shell-integrations" "$HOME/.zshrc" 2>/dev/null; then
    kd_step_skip "Shell integrations already configured"
    return 0
  fi

  # Create .zshrc if it doesn't exist
  if [ ! -f "$HOME/.zshrc" ]; then
    kd_log "Creating ~/.zshrc"
    touch "$HOME/.zshrc"
    chmod 644 "$HOME/.zshrc"
  fi

  # Append integration block
  kd_log "Adding shell integrations (fzf, zoxide)"
  cat >> "$HOME/.zshrc" << 'EOF'

# kyldvs/k shell-integrations
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi
EOF

  kd_step_end
}
```

**Testing:**
- Add assertions to `src/tests/tests/vm.test.sh` (when created)
- Verify marker comment exists: `grep "# kyldvs/k shell-integrations"
  ~/.zshrc`
- Test graceful degradation: run without fzf/zoxide installed, verify no
  errors
- Test with fzf: install fzf, source ~/.zshrc, verify Ctrl-R works
- Test with zoxide: install zoxide, source ~/.zshrc, verify cd enhancement
  works
- Test idempotency: run twice, verify only one marker comment exists

## Dependencies

**Prerequisites:**
- Zsh installed (should be part of VM bootstrap)
- `~/.zshrc` file exists (created by integrate-zsh-settings task)
- vm.sh implementation (currently stub)

**Optional Runtime Dependencies:**
- fzf (provides fuzzy finding, history search, file finder)
- zoxide (provides smart directory jumping)

**Blocks:**
- This task is blocked by implementation of vm.sh
- Can prepare component in advance for integration when vm.sh is ready

**Related Tasks:**
- [vm-user-bootstrap.md](./vm-user-bootstrap.md) - Parent task for vm.sh
  implementation
- [integrate-zsh-settings.md](./integrate-zsh-settings.md) - Creates
  ~/.zshrc, prerequisite for this task
- integrate-modern-cli-tools (future task) - Installs fzf and zoxide

## Value Proposition

**Solves Real Problems:**
- **fzf Integration**: Enables Ctrl-R fuzzy history search, Ctrl-T file
  finder, Alt-C directory navigation
- **zoxide Integration**: Smart directory jumping based on frecency
  (frequency + recency), replaces cd command
- **Graceful Degradation**: Integrations only activate if tools are
  installed, no errors otherwise
- **Automatic Setup**: Users get enhanced shell features automatically when
  tools are present

**Minimal Complexity:**
- Simple file append operation with conditional checks
- Two eval statements, both guarded by command existence checks
- Single marker comment for idempotency
- No configuration files or complex setup

**Enhanced Workflow:**
- **Fuzzy History Search**: Find commands quickly without remembering exact
  syntax
- **File Navigation**: Jump to files/directories without typing full paths
- **Smart cd**: Navigate to frequently-used directories with minimal typing
- **Muscle Memory Transfer**: Same keybindings and behavior as manual
  dotfiles setup

**Risk-Free Integration:**
- Tools not installed: integrations silently skip, no errors
- Tools installed later: integrations activate on next shell session
- No breaking changes to existing shell behavior
- Can be removed by deleting marker section from ~/.zshrc

## Related Files

- Source: `module/dotfiles/links/zsh/.zshrc` (lines 161-164)
- Component: `bootstrap/lib/steps/shell-integrations.sh` (to be created)
- Manifest: `bootstrap/manifests/vm.txt` (to be created)
- Target: `bootstrap/vm.sh` (currently stub)
- Tests: `src/tests/tests/vm.test.sh` (to be created)

## Priority

**Medium** - Valuable quality-of-life improvement, but optional since it
depends on tools being installed. Simple to implement and provides immediate
value when tools are present. Should be implemented as part of vm.sh
bootstrap implementation.

## Estimated Effort

30 minutes to 1 hour (simple component following established patterns,
minimal complexity)

## Related Principles

- **#2 Good Code is Useful**: Enhances shell workflow with practical
  navigation and search features
- **#4 Good Code is Understandable**: Simple append operation with clear
  conditional checks
- **#6 Good Code is Honest**: Only enables features when tools exist,
  transparent about dependencies
- **#8 Good Code is Thorough**: Handles graceful degradation, idempotency,
  file creation
- **#10 As Little Code as Possible**: Minimal implementation, two eval
  statements, one marker
