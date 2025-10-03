# Integrate Tmux Configuration

## Description

Integrate minimal Tmux configuration from kyldvs/dotfiles into the VM
bootstrap system. VM users should automatically receive a well-configured Tmux
environment that supports persistent SSH sessions and improves terminal
multiplexing workflow.

## Current State

**Source Configuration:**
- Tmux config exists in `module/dotfiles/links/tmux/.config/tmux/tmux.conf`
- Contains sensible defaults and plugin configuration
- Currently only available via manual dotfiles installation

**VM Bootstrap:**
- `bootstrap/vm.sh` is a stub (not yet implemented)
- No automatic tmux installation or configuration
- Users must manually install and configure tmux after VM provisioning

**Gap:**
- VM users don't get tmux automatically installed or configured
- Missing persistent session support for Termux SSH connections
- Manual configuration is inconsistent across environments

## Scope

Create a bootstrap component that installs Tmux and applies minimal
configuration (core settings only, no plugins). Integration happens during VM
user bootstrap.

**Configuration to Apply:**
```tmux
# Mouse support
set -g mouse on

# Set prefix to Ctrl-Space
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

# Ctrl-j/k to move windows
bind -n C-j previous-window
bind -n C-k next-window

# Start windows and panes at 1, not 0
set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on

# Open panes/windows in current directory
bind '"' split-window -v -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
```

**Implementation Requirements:**
- Install tmux package via apt-get
- Create `bootstrap/lib/steps/tmux-config.sh` component
- Write config to `~/.config/tmux/tmux.conf` (XDG standard path)
- Idempotent operation (safe to run multiple times)
- No plugins (minimal config only)
- Add to vm.txt manifest (when vm.sh is implemented)

## Success Criteria

- [ ] Component file created: `bootstrap/lib/steps/tmux-config.sh`
- [ ] Tmux package installed via apt-get
- [ ] Configuration written to `~/.config/tmux/tmux.conf`
- [ ] Config directory created with proper permissions
- [ ] Idempotent behavior validated
- [ ] Tests verify tmux binary and config file existence
- [ ] Component follows existing bootstrap patterns

## Implementation Notes

**Component Structure:**

Follow the established pattern from existing steps like `ssh-keys.sh`:
- Function named `configure_tmux` or similar
- Use `kd_step_start`, `kd_step_end`, `kd_step_skip`
- Check if configuration already applied (idempotency)
- Log actions clearly

**Package Installation:**

Install tmux using apt-get (assumes Debian/Ubuntu VM):
```bash
kd_log "Installing tmux package"
sudo apt-get update -qq
sudo apt-get install -y tmux
```

**Idempotency Strategy:**

Check if tmux is installed and config exists:
```bash
# Check if already configured
if [ -f "$HOME/.config/tmux/tmux.conf" ]; then
  kd_step_skip "Tmux already configured"
  return 0
fi
```

**Create Config Directory:**

Ensure XDG config directory exists:
```bash
kd_log "Creating ~/.config/tmux directory"
mkdir -p "$HOME/.config/tmux"
```

**Write Configuration:**

Write minimal config without plugins:
```bash
kd_log "Writing tmux configuration"
cat > "$HOME/.config/tmux/tmux.conf" <<'EOF'
# Mouse support
set -g mouse on

# Set prefix to Ctrl-Space
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

# Ctrl-j/k to move windows
bind -n C-j previous-window
bind -n C-k next-window

# Start windows and panes at 1, not 0
set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on

# Open panes/windows in current directory
bind '"' split-window -v -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
EOF
```

**Testing:**

Add assertions to `src/tests/tests/vm.test.sh` (when created):
- Verify tmux binary exists: `command -v tmux`
- Verify config file exists: `assert_file "$HOME/.config/tmux/tmux.conf"`
- Verify config contains key settings: `grep "mouse on"`
- Test idempotency: run twice, verify no errors
- Optional: Test key bindings if time permits

## Dependencies

**Prerequisites:**
- apt-get package manager (Debian/Ubuntu VM)
- User with sudo access (created by vmroot.sh)
- vm.sh implementation (currently stub)

**Blocks:**
- This task is blocked by implementation of vm.sh
- Can prepare component in advance for integration when vm.sh is ready

**Related Tasks:**
- [vm-user-bootstrap.md](./vm-user-bootstrap.md) - Parent task for vm.sh
  implementation

## Value Proposition

**Solves Real Problems:**
- Persistent SSH sessions from Termux to VM (critical for mobile workflow)
- `mouse on` - Enables mouse scrolling and pane selection (essential for
  mobile terminal use)
- `prefix C-Space` - More ergonomic than default C-b
- `C-j/C-k` navigation - Faster window switching without prefix key
- `base-index 1` - Window numbering matches keyboard layout
- New panes/windows in current directory - Reduces navigation friction

**Minimal Complexity:**
- Simple package installation and file writing
- No external dependencies beyond apt-get and tmux
- No plugins to manage or update
- Straightforward idempotency checks

**Mobile Development Workflow:**
- Tmux is essential for Termux SSH sessions
- Disconnects don't lose work state
- Multiple shells in single SSH connection
- Better resource usage than multiple SSH sessions

**Consistent Environment:**
- VM users get same tmux experience as manual dotfiles installation
- Reduces cognitive load across environments
- Prevents "why does tmux behave differently here?" confusion

## Related Files

- Source: `module/dotfiles/links/tmux/.config/tmux/tmux.conf`
- Component: `bootstrap/lib/steps/tmux-config.sh` (to be created)
- Manifest: `bootstrap/manifests/vm.txt` (to be created)
- Target: `bootstrap/vm.sh` (currently stub)
- Tests: `src/tests/tests/vm.test.sh` (to be created)

## Priority

**High** - Tmux is critical infrastructure for persistent SSH sessions in the
Termux to VM workflow. Without it, mobile development workflow is significantly
degraded. Should be implemented as part of vm.sh bootstrap implementation.

## Estimated Effort

**Moderate Complexity** - 2-3 hours

- Component creation: 1 hour (following established patterns)
- Testing integration: 1 hour (add to vm test suite)
- Documentation updates: 30 minutes

## Related Principles

- **#2 Good Code is Useful**: Solves the real problem of session persistence
  for mobile development workflow
- **#10 As Little Code as Possible**: Minimal config, no plugins, essential
  settings only
- **#5 Good Code is Unobtrusive**: Tmux should be invisible infrastructure
  that just works
- **#6 Good Code is Honest**: Configuration does exactly what it says, no
  hidden complexity
- **#8 Good Code is Thorough**: Handles the complete use case from package
  installation to configuration
