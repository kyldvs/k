#!/usr/bin/env bash
# Stow wrapper library for dotfiles management
# Less but better - simple, reliable symlink management

set -euo pipefail

# Color output for user messages
readonly KD_DF_RED='\033[0;31m'
readonly KD_DF_GREEN='\033[0;32m'
readonly KD_DF_YELLOW='\033[1;33m'
readonly KD_DF_BLUE='\033[0;34m'
readonly KD_DF_NC='\033[0m'

# Get repo root directory
df_get_repo_root() {
  git -C "${BASH_SOURCE[0]%/*}" rev-parse --show-toplevel 2>/dev/null
}

# Get dotfiles directory
df_get_dotfiles_dir() {
  local repo_root
  repo_root="$(df_get_repo_root)"
  echo "${repo_root}/dotfiles"
}

# Check if stow is installed
df_check_stow() {
  if ! command -v stow &> /dev/null; then
    echo -e "${KD_DF_RED}Error: stow is not installed${KD_DF_NC}" >&2
    echo "Install with: sudo apt install stow" >&2
    return 1
  fi
  return 0
}

# Get list of available stow packages
df_get_packages() {
  local dotfiles_dir
  dotfiles_dir="$(df_get_dotfiles_dir)"

  if [ ! -d "$dotfiles_dir" ]; then
    echo -e "${KD_DF_RED}Error: Dotfiles directory not found: \
$dotfiles_dir${KD_DF_NC}" >&2
    return 1
  fi

  # List directories in dotfiles/, excluding config dir
  find "$dotfiles_dir" -maxdepth 1 -type d ! -name dotfiles \
    ! -name config -printf '%f\n' | sort
}

# Check for conflicts before stowing
df_check_conflicts() {
  local package="$1"
  local dotfiles_dir
  local target_dir="${HOME}"
  local conflicts=()

  dotfiles_dir="$(df_get_dotfiles_dir)"

  if [ ! -d "${dotfiles_dir}/${package}" ]; then
    echo -e "${KD_DF_RED}Error: Package not found: \
$package${KD_DF_NC}" >&2
    return 1
  fi

  # Find all files that would be linked
  while IFS= read -r -d '' file; do
    local rel_path="${file#"${dotfiles_dir}"/"${package}"/}"
    local target_file="${target_dir}/${rel_path}"

    # Check if target exists and is not a symlink to our repo
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
      local real_target
      if [ -L "$target_file" ]; then
        real_target="$(readlink -f "$target_file" 2>/dev/null || echo "")"
        # Skip if already linked to our dotfiles
        if [[ "$real_target" == "${dotfiles_dir}/${package}/"* ]]; then
          continue
        fi
      fi
      conflicts+=("$target_file")
    fi
  done < <(find "${dotfiles_dir}/${package}" -type f -print0)

  if [ ${#conflicts[@]} -gt 0 ]; then
    for conflict in "${conflicts[@]}"; do
      echo "$conflict"
    done
    return 1
  fi

  return 0
}

# Backup a file before stowing
df_backup_file() {
  local file="$1"
  local backup_dir="${HOME}/.config/kyldvs/k/backups"
  local timestamp
  timestamp="$(date +%Y%m%d_%H%M%S)"
  local backup_file

  mkdir -p "$backup_dir"

  backup_file="${backup_dir}/$(basename "$file").${timestamp}"
  cp -a "$file" "$backup_file"
  echo -e "${KD_DF_BLUE}Backed up: $file -> $backup_file${KD_DF_NC}"
}

# Link a stow package
df_stow_link() {
  local package="$1"
  local dotfiles_dir
  local target_dir="${HOME}"

  df_check_stow || return 1
  dotfiles_dir="$(df_get_dotfiles_dir)"

  if [ ! -d "${dotfiles_dir}/${package}" ]; then
    echo -e "${KD_DF_RED}Error: Package not found: \
$package${KD_DF_NC}" >&2
    return 1
  fi

  # Check for conflicts
  local conflicts
  if ! conflicts="$(df_check_conflicts "$package" 2>&1)"; then
    echo -e "${KD_DF_YELLOW}Conflicts detected for package: \
$package${KD_DF_NC}"
    while IFS= read -r conflict; do
      [ -z "$conflict" ] && continue
      echo "  $conflict"
      df_backup_file "$conflict"
      rm -f "$conflict"
    done <<< "$conflicts"
  fi

  # Stow the package
  if stow -d "$dotfiles_dir" -t "$target_dir" "$package" 2>/dev/null; then
    echo -e "${KD_DF_GREEN}Linked: $package${KD_DF_NC}"
    return 0
  else
    echo -e "${KD_DF_RED}Failed to link: $package${KD_DF_NC}" >&2
    return 1
  fi
}

# Unlink a stow package
df_stow_unlink() {
  local package="$1"
  local dotfiles_dir
  local target_dir="${HOME}"

  df_check_stow || return 1
  dotfiles_dir="$(df_get_dotfiles_dir)"

  if [ ! -d "${dotfiles_dir}/${package}" ]; then
    echo -e "${KD_DF_RED}Error: Package not found: \
$package${KD_DF_NC}" >&2
    return 1
  fi

  # Unstow the package
  if stow -D -d "$dotfiles_dir" -t "$target_dir" "$package" \
    2>/dev/null; then
    echo -e "${KD_DF_GREEN}Unlinked: $package${KD_DF_NC}"
    return 0
  else
    echo -e "${KD_DF_RED}Failed to unlink: $package${KD_DF_NC}" >&2
    return 1
  fi
}

# Check status of stow packages
df_stow_status() {
  local dotfiles_dir
  local target_dir="${HOME}"

  df_check_stow || return 1
  dotfiles_dir="$(df_get_dotfiles_dir)"

  echo -e "${KD_DF_BLUE}Dotfiles Status:${KD_DF_NC}"
  echo "Repository: $dotfiles_dir"
  echo "Target: $target_dir"
  echo ""
  echo "Available packages:"

  while IFS= read -r package; do
    [ -z "$package" ] && continue

    # Check if package is linked by testing a sample file
    local linked=false
    while IFS= read -r -d '' file; do
      local rel_path="${file#"${dotfiles_dir}"/"${package}"/}"
      local target_file="${target_dir}/${rel_path}"

      if [ -L "$target_file" ]; then
        local real_target
        real_target="$(readlink -f "$target_file" 2>/dev/null || echo "")"
        if [[ "$real_target" == "${dotfiles_dir}/${package}/"* ]]; then
          linked=true
          break
        fi
      fi
    done < <(find "${dotfiles_dir}/${package}" -type f -print0 \
      2>/dev/null | head -n 1)

    if [ "$linked" = true ]; then
      echo -e "  ${KD_DF_GREEN}✓${KD_DF_NC} $package (linked)"
    else
      echo -e "  ${KD_DF_YELLOW}○${KD_DF_NC} $package (not linked)"
    fi
  done < <(df_get_packages)

  return 0
}

# Link all available packages
df_stow_link_all() {
  local failed=0

  echo -e "${KD_DF_BLUE}Linking all dotfile packages...${KD_DF_NC}"

  while IFS= read -r package; do
    [ -z "$package" ] && continue
    df_stow_link "$package" || ((failed++))
  done < <(df_get_packages)

  if [ $failed -eq 0 ]; then
    echo -e "${KD_DF_GREEN}All packages linked successfully${KD_DF_NC}"
    return 0
  else
    echo -e "${KD_DF_RED}Failed to link $failed package(s)${KD_DF_NC}" >&2
    return 1
  fi
}
