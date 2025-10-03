# Integrate Modern CLI Tools

## Description

Install modern command-line tools from kyldvs/dotfiles into the VM bootstrap
system. VM users should automatically receive productivity-enhancing CLI tools
that improve terminal workflow without requiring manual installation.

## Current State

**Source Configuration:**
- Tool list exists in `module/dotfiles/src/homebrew/recipes.txt`
- Contains proven, high-value terminal utilities
- Currently only installed via manual dotfiles setup with Homebrew

**VM Bootstrap:**
- `bootstrap/vm.sh` is a stub (not yet implemented)
- No automatic CLI tool installation
- Users must manually install tools after VM provisioning

**Gap:**
- VM users don't get modern CLI tools automatically
- Manual installation is tedious and inconsistent
- Workflow efficiency differs between manual dotfiles and VM environments

## Scope

Create a bootstrap component that installs modern CLI tools using apt-get.
Only install tools available in default Ubuntu/Debian repositories.
Integration happens during VM user bootstrap.

**Tools to Install (apt available):**
- `bat` - Syntax-highlighted cat with Git integration
- `fd-find` - Modern find alternative (fast, user-friendly syntax)
- `fzf` - Fuzzy finder for interactive filtering
- `ripgrep` - Fast recursive grep alternative
- `jq` - JSON processor and formatter
- `neovim` - Modern vim-compatible editor
- `htop` - Interactive process viewer

**Tools Requiring Manual Install (document only):**
- `eza` - Modern ls replacement (requires external repo or cargo)
- `zoxide` - Smart cd with frecency algorithm (requires external repo or cargo)
- `btop` - Modern resource monitor (may need external repo)
- `lazygit` - Terminal UI for git (requires external repo)

**Implementation Requirements:**
- Create `bootstrap/lib/steps/modern-cli-tools.sh` component
- Use apt-get to install available tools
- Check if tools already installed before attempting install
- Idempotent operation (safe to run multiple times)
- Add to vm.txt manifest (when vm.sh is implemented)

**Out of Scope:**
- Shell integrations (separate task: integrate-shell-integrations)
- Tool configuration files
- Plugin installation for editors
- Building from source or adding external repositories
- Installing non-apt tools (eza, zoxide, btop, lazygit)

## Success Criteria

- [ ] Component file created: `bootstrap/lib/steps/modern-cli-tools.sh`
- [ ] All apt-available tools installed successfully
- [ ] Idempotent behavior validated (checks before installing)
- [ ] Tests verify tool binaries exist
- [ ] Component follows existing bootstrap patterns
- [ ] Documentation includes manual install notes for non-apt tools

## Implementation Notes

**Component Structure:**

Follow the established pattern from existing steps:
- Function named `install_modern_cli_tools` or similar
- Use `kd_step_start`, `kd_step_end`, `kd_step_skip`
- Check each tool individually for idempotency
- Log actions clearly

**Package Installation:**

Install tools using apt-get (assumes Debian/Ubuntu VM):
```bash
# Update package index
kd_log "Updating package index"
sudo apt-get update -qq

# Install tools
kd_log "Installing bat (syntax-highlighted cat)"
sudo apt-get install -y bat

kd_log "Installing fd-find (modern find)"
sudo apt-get install -y fd-find

kd_log "Installing fzf (fuzzy finder)"
sudo apt-get install -y fzf

kd_log "Installing ripgrep (fast grep)"
sudo apt-get install -y ripgrep

kd_log "Installing jq (JSON processor)"
sudo apt-get install -y jq

kd_log "Installing neovim (modern vim)"
sudo apt-get install -y neovim

kd_log "Installing htop (process viewer)"
sudo apt-get install -y htop
```

**Idempotency Strategy:**

Check if tools already installed before attempting installation:
```bash
# Check if all tools already installed
all_installed=true
for tool in bat fdfind fzf rg jq nvim htop; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    all_installed=false
    break
  fi
done

if [ "$all_installed" = true ]; then
  kd_step_skip "Modern CLI tools already installed"
  return 0
fi
```

**Note on fd-find:**

The package name is `fd-find` but the binary is installed as `fdfind` on
Debian/Ubuntu (to avoid conflicts with another package). Users can create a
symlink if desired:
```bash
ln -s $(which fdfind) ~/.local/bin/fd
```

This symlink creation is out of scope for this task (could be added to shell
integration task if needed).

**Function Implementation:**

```bash
# Install modern CLI tools
install_modern_cli_tools() {
  kd_step_start "modern-cli-tools" "Installing modern CLI tools"

  # Check if all tools already installed (idempotency)
  all_installed=true
  for tool in bat fdfind fzf rg jq nvim htop; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      all_installed=false
      break
    fi
  done

  if [ "$all_installed" = true ]; then
    kd_step_skip "Modern CLI tools already installed"
    return 0
  fi

  # Update package index
  kd_log "Updating package index"
  sudo apt-get update -qq

  # Install tools if not present
  if ! command -v bat >/dev/null 2>&1; then
    kd_log "Installing bat (syntax-highlighted cat)"
    sudo apt-get install -y bat
  fi

  if ! command -v fdfind >/dev/null 2>&1; then
    kd_log "Installing fd-find (modern find)"
    sudo apt-get install -y fd-find
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    kd_log "Installing fzf (fuzzy finder)"
    sudo apt-get install -y fzf
  fi

  if ! command -v rg >/dev/null 2>&1; then
    kd_log "Installing ripgrep (fast grep)"
    sudo apt-get install -y ripgrep
  fi

  if ! command -v jq >/dev/null 2>&1; then
    kd_log "Installing jq (JSON processor)"
    sudo apt-get install -y jq
  fi

  if ! command -v nvim >/dev/null 2>&1; then
    kd_log "Installing neovim (modern vim)"
    sudo apt-get install -y neovim
  fi

  if ! command -v htop >/dev/null 2>&1; then
    kd_log "Installing htop (process viewer)"
    sudo apt-get install -y htop
  fi

  kd_step_end
}
```

**Testing:**

Add assertions to `src/tests/tests/vm.test.sh` (when created):
- Verify each tool binary exists: `command -v bat`, `command -v fdfind`, etc.
- Verify tools are functional: `bat --version`, `jq --version`, etc.
- Test idempotency: run twice, verify no errors and no redundant installs
- Verify apt-get succeeds without manual intervention

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
- Future task: integrate-shell-integrations (for fzf key bindings, etc.)

## Value Proposition

**Solves Real Problems:**
- `bat` - Syntax highlighting makes reading code/config files significantly
  easier
- `fd` - Faster and more intuitive file finding compared to GNU find
- `fzf` - Interactive filtering dramatically improves workflow efficiency
- `ripgrep` - 10-100x faster than grep for code searching
- `jq` - Essential for working with JSON APIs and config files
- `neovim` - Modern vim with better defaults and LSP support
- `htop` - Significantly better UX than plain top for process management

**Minimal Complexity:**
- Standard apt-get installation (well-tested, reliable)
- No external repositories to configure
- No custom build processes
- Straightforward idempotency checks

**Consistent Environment:**
- VM users get similar tooling to manual dotfiles installation
- Reduces cognitive load across environments
- Increases productivity in terminal workflows

**Practical Approach:**
- Only installs tools available in default repositories
- Avoids complexity of external repos or building from source
- Documents manual install process for advanced tools
- Balances value vs. complexity

## Manual Install Documentation

For tools not available in default apt repositories, users can install manually:

**eza (modern ls):**
```bash
# Via cargo (requires Rust)
cargo install eza
```

**zoxide (smart cd):**
```bash
# Via cargo (requires Rust)
cargo install zoxide
```

**btop (modern top):**
```bash
# May be available in Ubuntu 22.04+ default repos
sudo apt-get install btop

# Otherwise, download from GitHub releases
wget https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz
tar -xjf btop-x86_64-linux-musl.tbz
sudo cp btop/bin/btop /usr/local/bin/
```

**lazygit (git TUI):**
```bash
# Add lazygit PPA
sudo add-apt-repository ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install lazygit
```

These manual installations are intentionally out of scope to maintain
simplicity and avoid external repository dependencies.

## Related Files

- Source: `module/dotfiles/src/homebrew/recipes.txt`
- Component: `bootstrap/lib/steps/modern-cli-tools.sh` (to be created)
- Manifest: `bootstrap/manifests/vm.txt` (to be created)
- Target: `bootstrap/vm.sh` (currently stub)
- Tests: `src/tests/tests/vm.test.sh` (to be created)

## Priority

**Medium** - Valuable productivity improvement, but not blocking core
functionality. Should be implemented as part of vm.sh bootstrap implementation.

## Estimated Effort

**Moderate Complexity** - 2-3 hours

- Component creation: 1-1.5 hours (following established patterns, multiple
  tools)
- Testing integration: 1 hour (add to vm test suite, verify each tool)
- Documentation: 30 minutes (manual install notes)

## Related Principles

- **#2 Good Code is Useful**: Installs high-value tools that solve real
  productivity problems
- **#4 Good Code is Understandable**: Simple apt-get installation, clear tool
  purposes
- **#8 Good Code is Thorough**: Handles idempotency, checks each tool
  individually
- **#10 As Little Code as Possible**: Only installs apt-available tools,
  avoids complexity
- **#1 Good Code is Innovative**: Uses modern alternatives that genuinely
  improve workflow (not technology for technology's sake)
