#!/usr/bin/env bash
# Package management for dotfiles
# Less but better - simple APT package installation

set -euo pipefail

# Color output
readonly KD_DF_RED='\033[0;31m'
readonly KD_DF_GREEN='\033[0;32m'
readonly KD_DF_YELLOW='\033[1;33m'
readonly KD_DF_BLUE='\033[0;34m'
readonly KD_DF_NC='\033[0m'

# Config file location
readonly KD_DF_CONFIG_FILE="${HOME}/.config/kyldvs/k/dotfiles.yml"
readonly KD_DF_INSTALL_LOG="${HOME}/.config/kyldvs/k/installed-packages.log"

# Source config library
df_pkg_source_config() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./config.sh
  . "${script_dir}/config.sh"
}

df_pkg_source_config

# Check if package is installed
df_pkg_is_installed() {
  local package="$1"
  dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# Check if package exists in APT
df_pkg_exists() {
  local package="$1"
  apt-cache show "$package" &> /dev/null
}

# Log installed package
df_pkg_log_install() {
  local package="$1"
  local timestamp
  timestamp="$(date -Iseconds)"

  mkdir -p "$(dirname "$KD_DF_INSTALL_LOG")"
  echo "$timestamp $package" >> "$KD_DF_INSTALL_LOG"
}

# Update APT cache
df_pkg_update_cache() {
  echo -e "${KD_DF_BLUE}Updating APT cache...${KD_DF_NC}"
  if sudo apt-get update &> /dev/null; then
    echo -e "${KD_DF_GREEN}APT cache updated${KD_DF_NC}"
    return 0
  else
    echo -e "${KD_DF_RED}Failed to update APT cache${KD_DF_NC}" >&2
    return 1
  fi
}

# Install a single package
df_pkg_install_one() {
  local package="$1"
  local dry_run="${2:-false}"

  # Check if already installed
  if df_pkg_is_installed "$package"; then
    echo -e "${KD_DF_GREEN}✓${KD_DF_NC} $package (already installed)"
    return 0
  fi

  # Check if package exists
  if ! df_pkg_exists "$package"; then
    echo -e "${KD_DF_RED}✗${KD_DF_NC} $package (not found in APT)"
    return 1
  fi

  if [ "$dry_run" = "true" ]; then
    echo -e "${KD_DF_BLUE}→${KD_DF_NC} $package (would install)"
    return 0
  fi

  # Install package
  echo -e "${KD_DF_BLUE}→${KD_DF_NC} Installing $package..."
  if sudo apt-get install -y "$package" &> /dev/null; then
    echo -e "${KD_DF_GREEN}✓${KD_DF_NC} $package (installed)"
    df_pkg_log_install "$package"
    return 0
  else
    echo -e "${KD_DF_RED}✗${KD_DF_NC} $package (failed to install)"
    return 1
  fi
}

# Install packages from config
df_pkg_install_from_config() {
  local dry_run="${1:-false}"

  # Load config
  if ! df_config_exists; then
    echo -e "${KD_DF_RED}Error: Config file not found${KD_DF_NC}" >&2
    return 1
  fi

  df_config_validate || return 1

  # Check if any packages defined
  if ! df_config_has_apt_packages; then
    echo -e "${KD_DF_YELLOW}No APT packages defined in config${KD_DF_NC}"
    return 0
  fi

  if [ "$dry_run" = "true" ]; then
    echo -e "${KD_DF_BLUE}Dry run - showing what would be \
installed:${KD_DF_NC}"
    echo ""
  else
    echo -e "${KD_DF_BLUE}Installing packages from \
config...${KD_DF_NC}"
    echo ""
    df_pkg_update_cache || return 1
    echo ""
  fi

  # Install each package
  local total=0
  local installed=0
  local failed=0
  local skipped=0

  while IFS= read -r package; do
    [ -z "$package" ] && continue
    ((total++))

    if df_pkg_install_one "$package" "$dry_run"; then
      if df_pkg_is_installed "$package"; then
        ((installed++))
      else
        ((skipped++))
      fi
    else
      ((failed++))
    fi
  done < <(df_config_get_apt_packages)

  echo ""
  echo -e "${KD_DF_BLUE}Summary:${KD_DF_NC}"
  echo "  Total packages: $total"

  if [ "$dry_run" = "true" ]; then
    echo "  Would install: $total"
  else
    echo "  Installed: $installed"
    echo "  Already installed: $skipped"
    if [ $failed -gt 0 ]; then
      echo -e "  ${KD_DF_RED}Failed: $failed${KD_DF_NC}"
    fi
  fi

  if [ $failed -gt 0 ]; then
    return 1
  fi

  return 0
}

# Show package status
df_pkg_show_status() {
  if ! df_config_exists; then
    echo -e "${KD_DF_YELLOW}No configuration file found${KD_DF_NC}"
    return 1
  fi

  df_config_validate || return 1

  echo -e "${KD_DF_BLUE}Package Status:${KD_DF_NC}"
  echo ""

  if ! df_config_has_apt_packages; then
    echo -e "${KD_DF_YELLOW}No APT packages defined in config${KD_DF_NC}"
    return 0
  fi

  local total=0
  local installed=0

  while IFS= read -r package; do
    [ -z "$package" ] && continue
    ((total++))

    if df_pkg_is_installed "$package"; then
      echo -e "  ${KD_DF_GREEN}✓${KD_DF_NC} $package"
      ((installed++))
    else
      echo -e "  ${KD_DF_YELLOW}○${KD_DF_NC} $package (not installed)"
    fi
  done < <(df_config_get_apt_packages)

  echo ""
  echo "Installed: $installed / $total"

  return 0
}

# Show installation log
df_pkg_show_log() {
  if [ ! -f "$KD_DF_INSTALL_LOG" ]; then
    echo -e "${KD_DF_YELLOW}No installation log found${KD_DF_NC}"
    return 0
  fi

  echo -e "${KD_DF_BLUE}Installation Log:${KD_DF_NC}"
  echo "File: $KD_DF_INSTALL_LOG"
  echo ""

  cat "$KD_DF_INSTALL_LOG"

  return 0
}
