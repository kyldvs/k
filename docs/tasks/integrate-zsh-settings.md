# Integrate Zsh Settings

## Description

Integrate sensible Zsh history and completion settings from kyldvs/dotfiles
into the VM bootstrap system. VM users should automatically receive
well-configured Zsh settings that improve command-line workflow without
requiring plugin dependencies.

## Current State

**Source Configuration:**
- Zsh settings exist in `module/dotfiles/links/zsh/.zshrc`
- Contains proven history management and completion defaults
- Currently only available via manual dotfiles installation
- Source file includes plugin-dependent features (zinit, fzf-tab, etc.)

**VM Bootstrap:**
- `bootstrap/vm.sh` is a stub (not yet implemented)
- No automatic Zsh configuration setup
- Users must manually configure Zsh after VM provisioning

**Gap:**
- VM users don't get sensible Zsh defaults automatically
- Manual configuration is error-prone and inconsistent
- History and completion behavior differs across environments

## Scope

Create a bootstrap component that configures Zsh with sensible history and
completion settings from the dotfiles repository. Integration happens during VM
user bootstrap.

**Configuration to Apply:**
```zsh
# kyldvs/k zsh-settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt NO_BEEP

autoload -Uz compinit && compinit
_comp_options+=(globdots)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
```

**Implementation Requirements:**
- Create `bootstrap/lib/steps/zsh-settings.sh` component
- Append settings to `~/.zshrc` if not already present
- Idempotent operation (safe to run multiple times)
- No plugin dependencies (works with vanilla Zsh)
- Add to vm.txt manifest (when vm.sh is implemented)

**Out of Scope:**
- Plugin installation (zinit, fzf-tab, powerlevel10k)
- fpath modification for custom completions
- fzf-tab styling (requires fzf-tab plugin)
- Zsh prompt configuration
- Aliases or other shell customizations

## Success Criteria

- [ ] Component file created: `bootstrap/lib/steps/zsh-settings.sh`
- [ ] Settings appended to `~/.zshrc`
- [ ] Marker comment added for idempotency check
- [ ] Idempotent behavior validated (safe to run multiple times)
- [ ] Tests added to VM bootstrap test suite
- [ ] Component follows existing bootstrap patterns
- [ ] No plugin dependencies required

## Implementation Notes

**Component Structure:**

Follow the established pattern from existing steps like `profile-init.sh`:
- Function named `configure_zsh_settings` or similar
- Use `kd_step_start`, `kd_step_end`, `kd_step_skip`
- Check for marker comment to determine if already applied
- Log actions clearly

**Idempotency Strategy:**

Check for marker comment in ~/.zshrc:
```bash
# Check if already configured
if grep -qF "# kyldvs/k zsh-settings" "$HOME/.zshrc" 2>/dev/null; then
  kd_step_skip "Zsh settings already configured"
  return 0
fi
```

**Apply Configuration:**

Append entire block to ~/.zshrc:
```bash
# Create .zshrc if it doesn't exist
if [ ! -f "$HOME/.zshrc" ]; then
  kd_log "Creating ~/.zshrc"
  touch "$HOME/.zshrc"
  chmod 644 "$HOME/.zshrc"
fi

# Append settings block
kd_log "Adding Zsh history and completion settings"
cat >> "$HOME/.zshrc" << 'EOF'

# kyldvs/k zsh-settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt NO_BEEP

autoload -Uz compinit && compinit
_comp_options+=(globdots)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
EOF
```

**Function Implementation:**

```bash
# Configure Zsh history and completion settings
configure_zsh_settings() {
  kd_step_start "zsh-settings" "Configuring Zsh settings"

  # Check if already configured (idempotency)
  if grep -qF "# kyldvs/k zsh-settings" "$HOME/.zshrc" 2>/dev/null; then
    kd_step_skip "Zsh settings already configured"
    return 0
  fi

  # Create .zshrc if it doesn't exist
  if [ ! -f "$HOME/.zshrc" ]; then
    kd_log "Creating ~/.zshrc"
    touch "$HOME/.zshrc"
    chmod 644 "$HOME/.zshrc"
  fi

  # Append settings block
  kd_log "Adding Zsh history and completion settings"
  cat >> "$HOME/.zshrc" << 'EOF'

# kyldvs/k zsh-settings
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt NO_BEEP

autoload -Uz compinit && compinit
_comp_options+=(globdots)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
EOF

  kd_step_end
}
```

**Testing:**
- Add assertions to `src/tests/tests/vm.test.sh` (when created)
- Verify marker comment exists: `grep "# kyldvs/k zsh-settings" ~/.zshrc`
- Verify HISTSIZE set: `zsh -c 'source ~/.zshrc && echo $HISTSIZE'`
- Test idempotency: run twice, verify only one marker comment exists
- Test completion: verify `compinit` loads without errors

## Dependencies

**Prerequisites:**
- Zsh installed (should be part of VM bootstrap)
- vm.sh implementation (currently stub)

**Blocks:**
- This task is blocked by implementation of vm.sh
- Can prepare component in advance for integration when vm.sh is ready

**Related Tasks:**
- [vm-user-bootstrap.md](./vm-user-bootstrap.md) - Parent task for vm.sh
  implementation

## Value Proposition

**Solves Real Problems:**
- **History Management**: 5000-line history with duplicate erasure prevents
  cluttered command history
- **History Sharing**: `sharehistory` enables history across multiple shell
  sessions
- **Ignore Duplicates**: Multiple options ensure clean, useful history
- **Case-Insensitive Completion**: `m:{a-z}={A-Za-z}` allows typing lowercase
  for any case
- **Glob Dots**: `globdots` enables completion of hidden files/directories
- **No Beep**: Eliminates annoying terminal beeps

**Minimal Complexity:**
- Simple file append operation
- No external dependencies beyond Zsh itself
- No plugin installation or management
- Straightforward idempotency check via marker comment

**Consistent Environment:**
- VM users get same sensible defaults as manual dotfiles installation
- Reduces cognitive load across environments
- Prevents "why does completion work differently here?" confusion

**No Plugin Dependencies:**
- Works with vanilla Zsh installation
- Faster bootstrap (no plugin downloads)
- Fewer moving parts, more reliable
- Future-proof (no plugin compatibility issues)

## Related Files

- Source: `module/dotfiles/links/zsh/.zshrc` (lines 88-106)
- Component: `bootstrap/lib/steps/zsh-settings.sh` (to be created)
- Manifest: `bootstrap/manifests/vm.txt` (to be created)
- Target: `bootstrap/vm.sh` (currently stub)
- Tests: `src/tests/tests/vm.test.sh` (to be created)

## Priority

**High** - Valuable quality-of-life improvement with minimal complexity. Simple
to implement and provides immediate value. Should be implemented as part of
vm.sh bootstrap implementation.

## Estimated Effort

1 hour (simple component following established patterns, minimal complexity)

## Related Principles

- **#2 Good Code is Useful**: Solves real command-line usability problems
- **#4 Good Code is Understandable**: Simple append operation, clear marker
  comment
- **#6 Good Code is Honest**: Settings do exactly what they say (history and
  completion)
- **#8 Good Code is Thorough**: Handles idempotency, file creation, proper
  permissions
- **#10 As Little Code as Possible**: Minimal implementation, no unnecessary
  abstractions
