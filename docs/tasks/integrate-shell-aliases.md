# Integrate Shell Aliases

## Description

Integrate convenience shell aliases from kyldvs/dotfiles into the VM bootstrap
system. VM users should automatically receive modern command-line tool aliases
(tmux, bat, eza) that improve workflow efficiency while gracefully degrading
if tools are not installed.

## Current State

**Source Configuration:**
- Shell aliases exist in `module/dotfiles/links/zsh/.zshrc` (lines 114-118)
- Contains aliases for tmux session management, bat (cat replacement), and eza
  (ls replacement)
- Currently only available via manual dotfiles installation
- Aliases reference modern CLI tools (bat, eza) that may not be installed

**VM Bootstrap:**
- `bootstrap/vm.sh` is a stub (not yet implemented)
- No automatic alias configuration
- Users must manually add aliases after VM provisioning
- No integration with modern CLI tools

**Gap:**
- VM users don't get convenience aliases automatically
- Missing tmux session reattachment shortcut (`tt`)
- No integration with modern tools when available
- Manual configuration is inconsistent across environments

## Scope

Create a bootstrap component that appends shell aliases to ~/.zshrc with
conditional checks for required tools. Aliases only activate if their
dependencies are installed (graceful degradation). Integration happens during
VM user bootstrap, after Zsh settings are configured.

**Aliases to Configure:**
```zsh
# kyldvs/k shell-aliases
if command -v tmux >/dev/null 2>&1; then
  alias tt="(tmux ls | grep -vx attached && tmux at) || tmux"
fi
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi
if command -v eza >/dev/null 2>&1; then
  alias ls="eza -la --icons --git"
  alias lst="eza -la --icons --git --tree --level 2"
fi
```

**Implementation Requirements:**
- Create `bootstrap/lib/steps/shell-aliases.sh` component
- Append aliases to `~/.zshrc` if not already present
- Conditional checks ensure graceful degradation (no errors if tools missing)
- Idempotent operation (safe to run multiple times)
- Use marker comment for idempotency: `# kyldvs/k shell-aliases`
- Add to vm.txt manifest (when vm.sh is implemented)

**Out of Scope:**
- Installing modern CLI tools (bat, eza) - separate task/optional
- Other shell customizations (history, completion, prompt)
- Tmux installation (handled by integrate-tmux-config task)
- Non-alias configurations

## Success Criteria

- [ ] Component file created: `bootstrap/lib/steps/shell-aliases.sh`
- [ ] Aliases appended to `~/.zshrc`
- [ ] Marker comment added for idempotency check
- [ ] Conditional checks verify tool availability before aliasing
- [ ] Idempotent behavior validated (safe to run multiple times)
- [ ] Tests verify aliases present and conditional behavior
- [ ] Component follows existing bootstrap patterns
- [ ] Works correctly whether tools are installed or not

## Implementation Notes

**Component Structure:**

Follow the established pattern from existing steps like `zsh-settings.sh`:
- Function named `configure_shell_aliases` or similar
- Use `kd_step_start`, `kd_step_end`, `kd_step_skip`
- Check for marker comment to determine if already applied
- Log actions clearly

**Idempotency Strategy:**

Check for marker comment in ~/.zshrc:
```bash
# Check if already configured
if grep -qF "# kyldvs/k shell-aliases" "$HOME/.zshrc" 2>/dev/null; then
  kd_step_skip "Shell aliases already configured"
  return 0
fi
```

**Apply Configuration:**

Append aliases block to ~/.zshrc (file should exist from zsh-settings step):
```bash
# Verify .zshrc exists (should be created by zsh-settings step)
if [ ! -f "$HOME/.zshrc" ]; then
  kd_log "Creating ~/.zshrc"
  touch "$HOME/.zshrc"
  chmod 644 "$HOME/.zshrc"
fi

# Append aliases block
kd_log "Adding shell aliases with conditional checks"
cat >> "$HOME/.zshrc" << 'EOF'

# kyldvs/k shell-aliases
if command -v tmux >/dev/null 2>&1; then
  alias tt="(tmux ls | grep -vx attached && tmux at) || tmux"
fi
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi
if command -v eza >/dev/null 2>&1; then
  alias ls="eza -la --icons --git"
  alias lst="eza -la --icons --git --tree --level 2"
fi
EOF
```

**Function Implementation:**

```bash
# Configure shell aliases with conditional tool checks
configure_shell_aliases() {
  kd_step_start "shell-aliases" "Configuring shell aliases"

  # Check if already configured (idempotency)
  if grep -qF "# kyldvs/k shell-aliases" "$HOME/.zshrc" 2>/dev/null; then
    kd_step_skip "Shell aliases already configured"
    return 0
  fi

  # Verify .zshrc exists (should be created by zsh-settings step)
  if [ ! -f "$HOME/.zshrc" ]; then
    kd_log "Creating ~/.zshrc"
    touch "$HOME/.zshrc"
    chmod 644 "$HOME/.zshrc"
  fi

  # Append aliases block with conditional checks
  kd_log "Adding shell aliases with conditional checks"
  cat >> "$HOME/.zshrc" << 'EOF'

# kyldvs/k shell-aliases
if command -v tmux >/dev/null 2>&1; then
  alias tt="(tmux ls | grep -vx attached && tmux at) || tmux"
fi
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi
if command -v eza >/dev/null 2>&1; then
  alias ls="eza -la --icons --git"
  alias lst="eza -la --icons --git --tree --level 2"
fi
EOF

  kd_step_end
}
```

**Testing:**

Add assertions to `src/tests/tests/vm.test.sh` (when created):
- Verify marker comment exists: `grep "# kyldvs/k shell-aliases" ~/.zshrc`
- Verify conditional structure: `grep "command -v tmux" ~/.zshrc`
- Test idempotency: run twice, verify only one marker comment exists
- Test graceful degradation: verify no errors when tools are missing
- Optional: Test alias activation when tools are present

**Conditional Checks Explained:**

`command -v tool >/dev/null 2>&1` - POSIX-compliant tool availability check:
- Returns 0 (success) if tool exists in PATH
- Suppresses all output (>/dev/null 2>&1)
- Works in all shells (sh, bash, zsh)
- Preferred over `which` (not always available) or `type` (not POSIX)

## Dependencies

**Prerequisites:**
- Zsh installed (should be part of VM bootstrap)
- ~/.zshrc exists (created by integrate-zsh-settings component)
- vm.sh implementation (currently stub)

**Optional Tool Dependencies:**
- tmux (installed by integrate-tmux-config) - enables `tt` alias
- bat (optional, not installed by bootstrap) - enables `cat` alias
- eza (optional, not installed by bootstrap) - enables `ls`, `lst` aliases

**Execution Order:**
1. integrate-zsh-settings (creates ~/.zshrc)
2. integrate-tmux-config (optional, for `tt` alias functionality)
3. **integrate-shell-aliases** (this task, appends to ~/.zshrc)

**Blocks:**
- This task is blocked by implementation of vm.sh
- Can prepare component in advance for integration when vm.sh is ready

**Related Tasks:**
- [integrate-zsh-settings.md](./integrate-zsh-settings.md) - Prerequisite
  (creates ~/.zshrc)
- [integrate-tmux-config.md](./integrate-tmux-config.md) - Soft dependency
  (enables `tt` alias functionality)
- [vm-user-bootstrap.md](./vm-user-bootstrap.md) - Parent task for vm.sh
  implementation

## Value Proposition

**Solves Real Problems:**
- **`tt` alias**: One-command tmux reattach/create - critical for persistent
  SSH sessions in mobile workflow. Attempts to attach to first unattached
  session, falls back to creating new session.
- **`cat` → `bat`**: Syntax highlighting, line numbers, git integration when
  viewing files. Significantly improves code reading experience.
- **`ls` → `eza`**: Modern ls replacement with colors, icons, git status
  inline. Faster directory navigation and clearer visual hierarchy.
- **`lst`**: Quick 2-level tree view with eza - faster than `tree`, more
  visual than plain `ls`.

**Graceful Degradation:**
- Conditional checks prevent errors when tools are missing
- Works on minimal VM (only `tt` alias if tmux installed)
- Works on fully-equipped system (all aliases active)
- No broken aliases, no error messages
- Users can install tools later, aliases activate on next shell

**Minimal Complexity:**
- Simple file append operation
- POSIX-compliant conditional checks
- No external dependencies beyond tools themselves
- Straightforward idempotency check via marker comment
- No plugin or package manager integration needed

**Consistent Experience:**
- VM users get same convenience aliases as manual dotfiles installation
- Muscle memory transfers across environments
- Modern tools "just work" when available
- Traditional commands still work when tools are missing

## Related Files

- Source: `module/dotfiles/links/zsh/.zshrc` (lines 114-118)
- Component: `bootstrap/lib/steps/shell-aliases.sh` (to be created)
- Manifest: `bootstrap/manifests/vm.txt` (to be created)
- Target: `bootstrap/vm.sh` (currently stub)
- Tests: `src/tests/tests/vm.test.sh` (to be created)

## Priority

**Medium** - Valuable convenience improvement with minimal complexity. Not
critical infrastructure (unlike tmux or zsh settings), but significantly
improves quality of life. Should be implemented as part of vm.sh bootstrap
implementation.

## Estimated Effort

**Simple Complexity** - 30 minutes to 1 hour

- Component creation: 20-30 minutes (following established patterns)
- Testing integration: 20-30 minutes (add to vm test suite)
- Very straightforward implementation

## Related Principles

- **#2 Good Code is Useful**: Solves real usability problems with frequently
  used commands
- **#4 Good Code is Understandable**: Simple conditionals, clear alias
  definitions
- **#6 Good Code is Honest**: Aliases do exactly what they claim, conditional
  checks are transparent
- **#8 Good Code is Thorough**: Handles both tool-present and tool-absent
  cases gracefully
- **#10 As Little Code as Possible**: Minimal implementation, maximum value
