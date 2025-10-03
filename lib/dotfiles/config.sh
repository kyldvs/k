#!/usr/bin/env bash
# YAML configuration loader for dotfiles
# Less but better - simple config loading with yq

set -euo pipefail

# Color output
readonly KD_DF_RED='\033[0;31m'
readonly KD_DF_GREEN='\033[0;32m'
readonly KD_DF_YELLOW='\033[1;33m'
readonly KD_DF_BLUE='\033[0;34m'
readonly KD_DF_NC='\033[0m'

# Config file location
readonly KD_DF_CONFIG_FILE="${HOME}/.config/kyldvs/k/dotfiles.yml"

# Get repo root directory
df_config_get_repo_root() {
  git -C "${BASH_SOURCE[0]%/*}" rev-parse --show-toplevel 2>/dev/null
}

# Check if yq is installed
df_check_yq() {
  if ! command -v yq &> /dev/null; then
    echo -e "${KD_DF_RED}Error: yq is not installed${KD_DF_NC}" >&2
    echo "Install with: sudo snap install yq" >&2
    echo "Or download from: https://github.com/mikefarah/yq" >&2
    return 1
  fi
  return 0
}

# Check if config file exists
df_config_exists() {
  [ -f "$KD_DF_CONFIG_FILE" ]
}

# Create default config from example
df_config_create_default() {
  local repo_root
  local example_file
  local config_dir

  repo_root="$(df_config_get_repo_root)"
  example_file="${repo_root}/dotfiles/config/dotfiles.yml.example"
  config_dir="$(dirname "$KD_DF_CONFIG_FILE")"

  if [ ! -f "$example_file" ]; then
    echo -e "${KD_DF_RED}Error: Example config not found: \
$example_file${KD_DF_NC}" >&2
    return 1
  fi

  mkdir -p "$config_dir"
  cp "$example_file" "$KD_DF_CONFIG_FILE"
  chmod 600 "$KD_DF_CONFIG_FILE"

  echo -e "${KD_DF_GREEN}Created config file: \
$KD_DF_CONFIG_FILE${KD_DF_NC}"
  echo -e "${KD_DF_YELLOW}Please edit this file to customize your \
configuration${KD_DF_NC}"

  return 0
}

# Validate config file
df_config_validate() {
  local config_file="${1:-$KD_DF_CONFIG_FILE}"

  df_check_yq || return 1

  if [ ! -f "$config_file" ]; then
    echo -e "${KD_DF_RED}Error: Config file not found: \
$config_file${KD_DF_NC}" >&2
    return 1
  fi

  # Check if valid YAML
  if ! yq eval '.' "$config_file" &> /dev/null; then
    echo -e "${KD_DF_RED}Error: Invalid YAML in config file${KD_DF_NC}" \
      >&2
    return 1
  fi

  # Check version field
  local version
  version="$(yq eval '.version' "$config_file" 2>/dev/null || echo "")"
  if [ "$version" != "1" ]; then
    echo -e "${KD_DF_YELLOW}Warning: Unexpected config version: \
$version (expected: 1)${KD_DF_NC}" >&2
  fi

  return 0
}

# Load config file
df_config_load() {
  if ! df_config_exists; then
    echo -e "${KD_DF_YELLOW}Config file not found, creating from \
example...${KD_DF_NC}"
    df_config_create_default || return 1
  fi

  df_config_validate || return 1

  echo -e "${KD_DF_GREEN}Config loaded: $KD_DF_CONFIG_FILE${KD_DF_NC}"
  return 0
}

# Get git profiles from config
df_config_get_git_profiles() {
  local config_file="${1:-$KD_DF_CONFIG_FILE}"

  df_check_yq || return 1

  if [ ! -f "$config_file" ]; then
    return 1
  fi

  # Output as JSON for easier parsing
  yq eval '.git_profiles // []' -o=json "$config_file" 2>/dev/null
}

# Get git profile count
df_config_get_git_profile_count() {
  local config_file="${1:-$KD_DF_CONFIG_FILE}"

  df_check_yq || return 1

  if [ ! -f "$config_file" ]; then
    echo "0"
    return 0
  fi

  yq eval '.git_profiles | length' "$config_file" 2>/dev/null || echo "0"
}

# Get git profile by index
df_config_get_git_profile() {
  local index="$1"
  local field="$2"
  local config_file="${3:-$KD_DF_CONFIG_FILE}"

  df_check_yq || return 1

  if [ ! -f "$config_file" ]; then
    return 1
  fi

  yq eval ".git_profiles[$index].$field" "$config_file" 2>/dev/null
}

# Get APT packages from config
df_config_get_apt_packages() {
  local config_file="${1:-$KD_DF_CONFIG_FILE}"

  df_check_yq || return 1

  if [ ! -f "$config_file" ]; then
    return 1
  fi

  # Output one package per line
  yq eval '.packages.apt[]' "$config_file" 2>/dev/null
}

# Check if config has APT packages
df_config_has_apt_packages() {
  local config_file="${1:-$KD_DF_CONFIG_FILE}"

  df_check_yq || return 1

  if [ ! -f "$config_file" ]; then
    return 1
  fi

  local count
  count="$(yq eval '.packages.apt | length' "$config_file" \
    2>/dev/null || echo "0")"

  [ "$count" -gt 0 ]
}

# Show config summary
df_config_show() {
  local config_file="${1:-$KD_DF_CONFIG_FILE}"

  if ! df_config_exists; then
    echo -e "${KD_DF_YELLOW}No configuration file found${KD_DF_NC}"
    echo "Run 'just k setup' to create one"
    return 1
  fi

  df_config_validate "$config_file" || return 1

  echo -e "${KD_DF_BLUE}Configuration Summary:${KD_DF_NC}"
  echo "File: $config_file"
  echo ""

  # Git profiles
  local profile_count
  profile_count="$(df_config_get_git_profile_count "$config_file")"
  echo "Git profiles: $profile_count"
  if [ "$profile_count" -gt 0 ]; then
    local i=0
    while [ $i -lt "$profile_count" ]; do
      local name path user email
      name="$(df_config_get_git_profile "$i" "name" "$config_file")"
      path="$(df_config_get_git_profile "$i" "path" "$config_file")"
      user="$(df_config_get_git_profile "$i" "user" "$config_file")"
      email="$(df_config_get_git_profile "$i" "email" "$config_file")"
      echo "  - $name: $path"
      echo "    $user <$email>"
      ((i++))
    done
  fi
  echo ""

  # Packages
  if df_config_has_apt_packages "$config_file"; then
    local pkg_count
    pkg_count="$(yq eval '.packages.apt | length' "$config_file")"
    echo "APT packages: $pkg_count"
  else
    echo "APT packages: 0"
  fi

  return 0
}
