# Dotfiles Configuration Schema

Complete YAML schema reference for `~/.config/kyldvs/k/dotfiles.yml`.

## Overview

The configuration file uses YAML format and follows a simple, flat structure.
All fields are optional except `version`.

**Location**: `~/.config/kyldvs/k/dotfiles.yml`

**Auto-generated**: Created from example on first `just k setup` if missing.

## Schema Version 1

### Root Structure

```yaml
version: 1              # Required: Schema version (currently only 1)
git_profiles: []        # Optional: List of git identity profiles
packages:               # Optional: Package lists by manager
  apt: []              # Optional: APT package list
tools: {}               # Optional: Reserved for future tool configs
```

## Field Reference

### `version`

**Type**: Integer

**Required**: Yes

**Description**: Configuration schema version. Currently only version 1 is
supported.

**Example**:

```yaml
version: 1
```

**Validation**:
- Must be present
- Must equal 1
- Warning if missing or not 1

---

### `git_profiles`

**Type**: List of objects

**Required**: No

**Description**: Git identity profiles for directory-based identity switching
using git's native includeIf feature.

**Schema**:

```yaml
git_profiles:
  - name: string       # Profile identifier (alphanumeric, no spaces)
    path: string       # Directory path (supports ~/ for home)
    user: string       # Git user.name
    email: string      # Git user.email
```

**Field Details**:

- **`name`**: Profile identifier used for config file naming. Must be unique
  within config. Alphanumeric, hyphens, underscores allowed.

- **`path`**: Directory path where this identity applies. Tilde (`~`)
  automatically expanded to `$HOME`. Git applies identity to this directory
  and all subdirectories. **Important**: includeIf requires trailing slash
  internally (added automatically).

- **`user`**: Git user name (git config user.name). Displayed in commits.

- **`email`**: Git email (git config user.email). Displayed in commits and
  used by services like GitHub for commit attribution.

**Minimal Example**:

```yaml
git_profiles:
  - name: personal
    path: ~/personal
    user: "Kyle Davis"
    email: "kyle@personal.example.com"
```

**Multiple Profiles Example**:

```yaml
git_profiles:
  - name: personal
    path: ~/personal
    user: "Kyle Davis"
    email: "kyle@personal.example.com"

  - name: work
    path: ~/work
    user: "Kyle Davis"
    email: "kyle@company.com"

  - name: oss
    path: ~/opensource
    user: "Kyle Davis"
    email: "kyle@opensource.example.com"
```

**Generated Files**:

For each profile, two files are created:

1. **Profile config**: `~/.config/git/<name>.conf`

   ```gitconfig
   # Git identity for personal
   [user]
     name = Kyle Davis
     email = kyle@personal.example.com
   ```

2. **includeIf directive** (appended to `~/.gitconfig`):

   ```gitconfig
   [includeIf "gitdir:~/personal/"]
     path = ~/.config/git/personal.conf
   ```

**Behavior**:

- Git checks current directory against all includeIf patterns
- First match wins (order matters if paths overlap)
- Identity applies to directory and all subdirectories
- No match uses default identity from main `~/.gitconfig`

**Edge Cases**:

- **Overlapping paths**: If `~/work` and `~/work/client` both have profiles,
  Git uses the first match in includeIf order. Configure most specific paths
  first in YAML.

- **Symbolic links**: Git follows symlinks, so identity based on real path.

- **Submodules**: Each submodule uses identity based on its path.

**Testing**:

```bash
# Create test directory
mkdir -p ~/work/test-repo
cd ~/work/test-repo
git init

# Check identity
just k git-test ~/work/test-repo
```

---

### `packages`

**Type**: Object with package manager keys

**Required**: No

**Description**: Package lists organized by package manager. Currently only
`apt` is supported.

**Schema**:

```yaml
packages:
  apt: []              # List of APT package names
```

---

### `packages.apt`

**Type**: List of strings

**Required**: No

**Description**: List of package names to install via APT (Debian/Ubuntu).

**Element Type**: String (APT package name)

**Example**:

```yaml
packages:
  apt:
    - zsh              # Z shell
    - tmux             # Terminal multiplexer
    - git              # Version control
    - stow             # Symlink manager (required for dotfiles)
    - neovim           # Modern vim
    - ripgrep          # Fast grep alternative
    - fd-find          # Fast find alternative
    - fzf              # Fuzzy finder
    - bat              # Cat with syntax highlighting
    - htop             # Process viewer
    - tree             # Directory tree viewer
    - jq               # JSON processor
```

**Installation**:

```bash
# Install all packages
just k install-packages

# Dry run (see what would be installed)
just k install-packages true
```

**Behavior**:

- Packages installed via `sudo apt install <package>`
- Skips already installed packages
- Warns on package not found in APT
- Logs installed packages to
  `~/.config/kyldvs/k/installed-packages.log`

**Package Name Format**:

- Use exact APT package name (e.g., `fd-find` not `fd`)
- Check package name with `apt search <name>`
- Some tools have different package names than binary names

**Common Package Names**:

| Tool | Package Name | Binary Name | Notes |
|------|-------------|-------------|-------|
| fd | `fd-find` | `fdfind` | Debian/Ubuntu rename |
| bat | `bat` | `batcat` | Debian/Ubuntu rename |
| ripgrep | `ripgrep` | `rg` | Same on all distros |
| neovim | `neovim` | `nvim` | Same on all distros |

**Package Categories**:

Common package types to consider:

- **Required**: `stow` (for dotfiles system)
- **Shell**: `zsh`, `bash`, `fish`
- **Multiplexer**: `tmux`, `screen`
- **Editor**: `neovim`, `vim`, `emacs`
- **VCS**: `git`, `mercurial`
- **Search**: `ripgrep`, `fd-find`, `fzf`
- **Display**: `bat`, `tree`, `htop`
- **Network**: `curl`, `wget`, `mosh`, `openssh-client`
- **Process**: `jq`, `yq`, `jless`
- **Build**: `build-essential`, `cmake`, `pkg-config`

**Validation**:

Package names are validated before installation:

```bash
# Check if package exists
apt-cache show <package> &> /dev/null
```

If package not found:

```
Warning: Package not found in APT: <package>
```

Installation continues for valid packages.

---

### `tools`

**Type**: Object

**Required**: No

**Description**: Reserved for future tool-specific configurations. Currently
unused.

**Example**:

```yaml
tools: {}
```

**Future Use Cases**:

- Shell-specific settings
- Editor plugins
- Language version managers
- Custom tool configurations

**Current Behavior**: Empty object. No validation or processing.

## Complete Example

```yaml
version: 1

# Git identity profiles
git_profiles:
  - name: personal
    path: ~/personal
    user: "Kyle Davis"
    email: "kyle@personal.example.com"

  - name: work
    path: ~/work
    user: "Kyle Davis"
    email: "kyle@company.com"

  - name: opensource
    path: ~/oss
    user: "kyldvs"
    email: "kyle@opensource.example.com"

# APT packages
packages:
  apt:
    # Core utilities
    - zsh
    - tmux
    - git
    - curl
    - wget
    - stow             # Required for dotfiles

    # Modern CLI tools
    - neovim
    - ripgrep          # rg - fast grep
    - fd-find          # fdfind - fast find
    - fzf              # Fuzzy finder
    - bat              # batcat - cat with highlighting
    - htop             # Process viewer
    - tree             # Directory tree
    - jq               # JSON processor

    # Development
    - build-essential
    - python3
    - python3-pip
    - nodejs
    - npm

# Reserved for future use
tools: {}
```

## Validation

Configuration is validated on load:

**Required Checks**:
- File is valid YAML
- `version` field exists and equals 1

**Optional Checks**:
- Git profiles have all required fields
- Profile names are unique
- Paths are valid (exist or can be created)

**Warning Conditions**:
- Unexpected version number
- Empty git_profiles list
- Empty packages.apt list
- Unknown root-level keys

**Validation Command**:

```bash
# Validate config
just k status

# Or manually
yq eval '.' ~/.config/kyldvs/k/dotfiles.yml
```

## Schema Evolution

Future schema versions will:

- Maintain backward compatibility where possible
- Use `version` field for breaking changes
- Provide migration tools for major version bumps

Current version: 1

## Default Values

If config file missing, system creates from example:

**Source**: `dotfiles/config/dotfiles.yml.example`

**Destination**: `~/.config/kyldvs/k/dotfiles.yml`

**Permissions**: `600` (user read/write only)

## File Location

**Standard**: `~/.config/kyldvs/k/dotfiles.yml`

**Rationale**:
- Follows XDG Base Directory specification
- Isolated from system configs
- User-specific (not in dotfiles repo)
- Same directory as bootstrap configs

## Manual Editing

Safe to manually edit configuration file:

1. Edit file: `vim ~/.config/kyldvs/k/dotfiles.yml`
2. Validate: `just k status`
3. Apply changes: `just k setup`

Changes take effect on next `just k setup` or relevant command.

## Environment Variable Expansion

**Supported**: Tilde (`~`) expansion for home directory

**Not Supported**:
- Environment variable expansion (e.g., `$HOME`)
- Command substitution
- Glob patterns

**Example**:

```yaml
git_profiles:
  - name: work
    path: ~/work           # ✓ Supported
    # path: $HOME/work    # ✗ Not supported
    # path: ${HOME}/work  # ✗ Not supported
```

Use `~/` for all home directory references.

## References

- [YAML Specification](https://yaml.org/spec/1.2/spec.html)
- [yq Documentation](https://mikefarah.gitbook.io/yq/)
- [Git Config includeIf](https://git-scm.com/docs/git-config#_includes)
- [Main Dotfiles Documentation](README.md)
