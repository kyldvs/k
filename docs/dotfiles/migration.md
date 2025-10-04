# Migration Guide

Guide for migrating from old integration tasks to the unified dotfiles system.

## Overview

The dotfiles system replaces 5 fragmented integration tasks with a unified,
maintainable system using standard tools (GNU Stow, git includeIf, YAML).

## What Changed

### Old System (Pre-Dotfiles)

**Separate Tasks**:
1. `integrate-zsh-settings.md` - Manual zsh config copying
2. `integrate-tmux-config.md` - Manual tmux config copying
3. `integrate-shell-integrations.md` - Shell integration setup
4. `integrate-shell-aliases.md` - Alias file copying
5. `integrate-modern-cli-tools.md` - Tool installation guide

**Characteristics**:
- Manual file copying required
- No automatic updates after git pull
- No declarative configuration
- Each tool configured separately
- Documentation scattered across files

### New System (Dotfiles)

**Unified System**:
- Single command: `just k setup`
- Automatic updates via symbolic links
- Declarative YAML configuration
- Git-native identity management
- Comprehensive testing

**Characteristics**:
- Stow-based symbolic linking
- Zero manual copying
- Pull = instant update
- One config file for all settings
- Single source of truth

## Migration Steps

### 1. Install Prerequisites

```bash
# Install stow (if not already installed)
sudo apt install stow

# Install yq for YAML parsing
sudo snap install yq
# Or download binary: https://github.com/mikefarah/yq/releases
```

### 2. Backup Existing Dotfiles

```bash
# Create backup directory
mkdir -p ~/dotfiles-backup-$(date +%Y%m%d)

# Backup existing files
cp ~/.zshrc ~/dotfiles-backup-*/
cp ~/.zshenv ~/dotfiles-backup-*/
cp ~/.tmux.conf ~/dotfiles-backup-*/
cp ~/.gitconfig ~/dotfiles-backup-*/
cp ~/.bash_aliases ~/dotfiles-backup-*/
cp ~/.zsh_aliases ~/dotfiles-backup-*/

# Note: Conflicts handled automatically by dotfiles system
# but manual backup provides safety
```

### 3. Run Initial Setup

```bash
# Navigate to repository
cd ~/kyldvs/k

# Run setup (creates config, links dotfiles, sets up git identity)
just k setup
```

**What happens**:
1. Config created at `~/.config/kyldvs/k/dotfiles.yml` from example
2. Existing dotfiles backed up to `~/.config/kyldvs/k/backups/`
3. New dotfiles linked via stow
4. Git includeIf directives configured

### 4. Customize Configuration

```bash
# Edit config file
vim ~/.config/kyldvs/k/dotfiles.yml
```

**Update git profiles**:

```yaml
git_profiles:
  - name: personal
    path: ~/personal          # Your personal projects directory
    user: "Your Name"
    email: "your@email.com"

  - name: work
    path: ~/work              # Your work projects directory
    user: "Your Name"
    email: "your@work-email.com"
```

**Update package list** (optional):

```yaml
packages:
  apt:
    - zsh
    - tmux
    # Add any additional packages you need
```

### 5. Apply Configuration

```bash
# Apply changes (regenerates git configs)
just k setup

# Install packages from config
just k install-packages
```

### 6. Verify Migration

```bash
# Check status
just k status

# Verify symlinks created
ls -la ~/ | grep ' -> '

# Test git identity
mkdir -p ~/work/test-repo
cd ~/work/test-repo
git init
git config user.email  # Should show work email
```

### 7. Migrate Custom Settings

If you had custom settings in old dotfiles, merge them into new files:

```bash
# Example: Merge custom zsh settings
cd ~/kyldvs/k
vim dotfiles/zsh/.zshrc

# Add your custom settings to the new file
# Changes immediately visible at ~/.zshrc (symlink)
```

### 8. Clean Up Old Files

```bash
# Old dotfiles now replaced by symlinks
# Backups saved in ~/.config/kyldvs/k/backups/

# Remove old backup directory after verifying everything works
# rm -rf ~/dotfiles-backup-YYYYMMDD
```

## Task Mapping

### integrate-zsh-settings.md → Dotfiles System

**Old Process**:
1. Copy `module/dotfiles/.zshrc` to `~/.zshrc`
2. Manually update after changes

**New Process**:
1. Run `just k setup` (once)
2. Edit `dotfiles/zsh/.zshrc` in repo
3. Changes instantly visible at `~/.zshrc` (symlink)

**Migration**:
- Automatic during `just k setup`
- No manual action required
- Custom settings: edit `dotfiles/zsh/.zshrc`

---

### integrate-tmux-config.md → Dotfiles System

**Old Process**:
1. Copy `module/dotfiles/.tmux.conf` to `~/.tmux.conf`
2. Manually update after changes

**New Process**:
1. Run `just k setup` (once)
2. Edit `dotfiles/tmux/.tmux.conf` in repo
3. Changes instantly visible at `~/.tmux.conf` (symlink)

**Migration**:
- Automatic during `just k setup`
- No manual action required
- Custom settings: edit `dotfiles/tmux/.tmux.conf`

---

### integrate-shell-aliases.md → Dotfiles System

**Old Process**:
1. Copy alias files to `~/.bash_aliases`, `~/.zsh_aliases`
2. Source in shell config

**New Process**:
1. Run `just k setup` (once)
2. Edit `dotfiles/shell/.bash_aliases` or `dotfiles/shell/.zsh_aliases`
3. Changes instantly visible (symlink)

**Migration**:
- Automatic during `just k setup`
- Shell configs already source these files
- Custom aliases: edit files in `dotfiles/shell/`

---

### integrate-modern-cli-tools.md → Dotfiles System

**Old Process**:
1. Manually install each tool: `sudo apt install ripgrep fd-find ...`
2. Repeat for each new tool

**New Process**:
1. Add tools to `~/.config/kyldvs/k/dotfiles.yml`:
   ```yaml
   packages:
     apt:
       - ripgrep
       - fd-find
       - fzf
   ```
2. Run `just k install-packages`

**Migration**:
- Edit YAML config to add desired tools
- Run `just k install-packages`
- Tools installed in one command

---

### integrate-shell-integrations.md → Dotfiles System

**Old Process**:
- Various shell integration steps
- Manual configuration

**New Process**:
- Integrated into dotfiles
- Shell configs in `dotfiles/zsh/` and `dotfiles/shell/`
- FZF and other integrations configured in dotfiles

**Migration**:
- Review `dotfiles/zsh/.zshrc` for integrations
- Add any missing integrations to dotfiles

## Common Migration Issues

### Issue: Existing .zshrc Has Custom Settings

**Symptom**: Your custom settings lost after migration.

**Solution**:
1. Check backup: `~/.config/kyldvs/k/backups/.zshrc.*`
2. Copy custom settings from backup
3. Paste into `dotfiles/zsh/.zshrc` in repository
4. Commit changes

### Issue: Git Identity Not Switching

**Symptom**: Wrong email in commits after migration.

**Solution**:
1. Check config: `vim ~/.config/kyldvs/k/dotfiles.yml`
2. Verify paths match your directory structure
3. Re-run setup: `just k setup`
4. Test: `just k git-test ~/work`

### Issue: Missing Aliases

**Symptom**: Previously working aliases don't work.

**Solution**:
1. Check if shell sources aliases:
   - Bash: `~/.bashrc` should source `~/.bash_aliases`
   - Zsh: `~/.zshrc` should source `~/.zsh_aliases`
2. Repository dotfiles already configure this
3. Restart shell: `exec zsh` or `exec bash`

### Issue: Package Installation Fails

**Symptom**: Some packages fail to install.

**Solution**:
1. Check package name: `apt search <package>`
2. Update package list: `sudo apt update`
3. Try manual install: `sudo apt install <package>`
4. Remove problematic package from YAML temporarily

### Issue: Symlinks Appear Broken

**Symptom**: Dotfiles show as broken symlinks.

**Solution**:
1. Verify repository location hasn't changed
2. Check symlink target: `ls -la ~/.zshrc`
3. If moved repo, re-run: `just k sync`

## Verification Checklist

After migration, verify:

- [ ] `just k status` shows all packages linked
- [ ] `ls -la ~/` shows symlinks to repo files
- [ ] Zsh loads without errors: `exec zsh`
- [ ] Tmux loads without errors: `tmux`
- [ ] Git identity switches in work directory: `just k git-test ~/work`
- [ ] Aliases work: try common aliases like `ll`, `la`
- [ ] Modern CLI tools installed: `which rg`, `which fzf`
- [ ] Configuration file exists: `~/.config/kyldvs/k/dotfiles.yml`

## Rollback

If migration causes issues, rollback:

```bash
# Unlink all dotfiles
cd ~/kyldvs/k
for pkg in dotfiles/*; do
  [ -d "$pkg" ] || continue
  pkg_name=$(basename "$pkg")
  [ "$pkg_name" = "config" ] && continue
  stow -D -d dotfiles -t ~/ "$pkg_name"
done

# Restore from backup
cp ~/.config/kyldvs/k/backups/.zshrc.* ~/.zshrc
cp ~/.config/kyldvs/k/backups/.tmux.conf.* ~/.tmux.conf
# etc.

# Restart shell
exec zsh
```

## Benefits After Migration

**Before**:
- Manual copying required
- Updates need manual sync
- Multiple task files to track
- No declarative config
- Inconsistent setup

**After**:
- One-time setup: `just k setup`
- Updates automatic via symlinks
- Single command interface
- YAML configuration
- Consistent, tested setup

## Getting Help

Issues after migration:

1. Check status: `just k status`
2. View backups: `ls ~/.config/kyldvs/k/backups/`
3. Review docs: `docs/dotfiles/README.md`
4. Check troubleshooting: `docs/dotfiles/README.md#troubleshooting`

## Future Enhancements

The dotfiles system is designed for extension:

- **Multi-machine configs**: Per-machine YAML configs (future)
- **Secret management**: Integration with Doppler (future)
- **Editor configs**: Neovim, Emacs dotfiles (future)
- **Additional package managers**: npm, cargo, pip (future)

These will be added as needed, following "less but better" principle.

## References

- [Dotfiles System Documentation](README.md)
- [Configuration Schema](configuration.md)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
