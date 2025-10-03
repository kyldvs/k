#!/usr/bin/env bash
# Git identity management via includeIf directives
# Less but better - git-native solution, no custom tooling

set -euo pipefail

# Color output
readonly KD_DF_RED='\033[0;31m'
readonly KD_DF_GREEN='\033[0;32m'
readonly KD_DF_YELLOW='\033[1;33m'
readonly KD_DF_BLUE='\033[0;34m'
readonly KD_DF_NC='\033[0m'

# Config file location
readonly KD_DF_CONFIG_FILE="${HOME}/.config/kyldvs/k/dotfiles.yml"

# Source config library
df_git_source_config() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./config.sh
  . "${script_dir}/config.sh"
}

df_git_source_config

# Check git version for includeIf support
df_git_check_version() {
  local git_version
  git_version="$(git --version | grep -oP '\d+\.\d+' | head -1)"
  local major minor
  major="$(echo "$git_version" | cut -d. -f1)"
  minor="$(echo "$git_version" | cut -d. -f2)"

  # includeIf requires git >= 2.13
  if [ "$major" -lt 2 ] || { [ "$major" -eq 2 ] && [ "$minor" -lt 13 ]; }
  then
    echo -e "${KD_DF_RED}Error: Git version $git_version too old \
(requires >= 2.13)${KD_DF_NC}" >&2
    return 1
  fi

  return 0
}

# Generate git profile config file
df_git_generate_profile_config() {
  local name="$1"
  local user="$2"
  local email="$3"
  local output_file="${HOME}/.config/git/${name}.conf"

  mkdir -p "$(dirname "$output_file")"

  cat > "$output_file" <<EOF
# Git identity for $name
[user]
  name = $user
  email = $email
EOF

  chmod 600 "$output_file"
  echo -e "${KD_DF_GREEN}Created profile config: \
$output_file${KD_DF_NC}"
}

# Check if gitconfig has our includeIf section
df_git_has_includeif_section() {
  local gitconfig="${HOME}/.gitconfig"

  [ -f "$gitconfig" ] || return 1

  grep -q "# kyldvs/k dotfiles git identity management" "$gitconfig" \
    2>/dev/null
}

# Remove old includeIf section if it exists
df_git_remove_old_includeif() {
  local gitconfig="${HOME}/.gitconfig"

  [ -f "$gitconfig" ] || return 0

  if df_git_has_includeif_section; then
    # Remove section between markers
    sed -i '/# kyldvs\/k dotfiles git identity management - START/,\
/# kyldvs\/k dotfiles git identity management - END/d' "$gitconfig"
    echo -e "${KD_DF_BLUE}Removed old git identity section${KD_DF_NC}"
  fi

  return 0
}

# Generate includeIf directives in gitconfig
df_git_generate_includeif() {
  local gitconfig="${HOME}/.gitconfig"

  df_git_check_version || return 1

  # Load config
  if ! df_config_exists; then
    echo -e "${KD_DF_RED}Error: Config file not found${KD_DF_NC}" >&2
    return 1
  fi

  df_config_validate || return 1

  # Get profile count
  local profile_count
  profile_count="$(df_config_get_git_profile_count)"

  if [ "$profile_count" -eq 0 ]; then
    echo -e "${KD_DF_YELLOW}No git profiles configured${KD_DF_NC}"
    return 0
  fi

  # Generate profile configs
  local i=0
  while [ $i -lt "$profile_count" ]; do
    local name path user email
    name="$(df_config_get_git_profile "$i" "name")"
    path="$(df_config_get_git_profile "$i" "path")"
    user="$(df_config_get_git_profile "$i" "user")"
    email="$(df_config_get_git_profile "$i" "email")"

    # Expand tilde in path
    path="${path/#\~/$HOME}"

    df_git_generate_profile_config "$name" "$user" "$email"
    ((i++))
  done

  # Remove old includeIf section
  df_git_remove_old_includeif

  # Create gitconfig if it doesn't exist
  if [ ! -f "$gitconfig" ]; then
    touch "$gitconfig"
  fi

  # Append new includeIf section
  {
    echo ""
    echo "# kyldvs/k dotfiles git identity management - START"
    echo "# This section is automatically generated. Do not edit \
manually."
    echo ""

    i=0
    while [ $i -lt "$profile_count" ]; do
      local name path
      name="$(df_config_get_git_profile "$i" "name")"
      path="$(df_config_get_git_profile "$i" "path")"

      # Expand tilde for includeIf directive
      path="${path/#\~/$HOME}"

      # includeIf requires trailing slash for directory matching
      if [[ ! "$path" =~ /$ ]]; then
        path="${path}/"
      fi

      echo "[includeIf \"gitdir:${path}\"]"
      echo "  path = ~/.config/git/${name}.conf"
      echo ""
      ((i++))
    done

    echo "# kyldvs/k dotfiles git identity management - END"
  } >> "$gitconfig"

  echo -e "${KD_DF_GREEN}Git identity management configured${KD_DF_NC}"
  echo -e "${KD_DF_BLUE}$profile_count profile(s) configured${KD_DF_NC}"

  return 0
}

# Test git identity in a directory
df_git_test_identity() {
  local test_dir="$1"

  if [ ! -d "$test_dir" ]; then
    echo -e "${KD_DF_RED}Error: Directory not found: \
$test_dir${KD_DF_NC}" >&2
    return 1
  fi

  echo -e "${KD_DF_BLUE}Testing git identity in: $test_dir${KD_DF_NC}"

  local user email
  user="$(git -C "$test_dir" config user.name 2>/dev/null || echo \
"(not set)")"
  email="$(git -C "$test_dir" config user.email 2>/dev/null || echo \
"(not set)")"

  echo "  User:  $user"
  echo "  Email: $email"

  return 0
}

# Show git identity status
df_git_show_status() {
  df_git_check_version || return 1

  echo -e "${KD_DF_BLUE}Git Identity Status:${KD_DF_NC}"
  echo ""

  # Show profiles from config
  if ! df_config_exists; then
    echo -e "${KD_DF_YELLOW}No configuration file found${KD_DF_NC}"
    return 1
  fi

  df_config_validate || return 1

  local profile_count
  profile_count="$(df_config_get_git_profile_count)"

  if [ "$profile_count" -eq 0 ]; then
    echo -e "${KD_DF_YELLOW}No git profiles configured${KD_DF_NC}"
    return 0
  fi

  echo "Configured profiles:"
  local i=0
  while [ $i -lt "$profile_count" ]; do
    local name path user email
    name="$(df_config_get_git_profile "$i" "name")"
    path="$(df_config_get_git_profile "$i" "path")"
    user="$(df_config_get_git_profile "$i" "user")"
    email="$(df_config_get_git_profile "$i" "email")"

    echo ""
    echo "  $name"
    echo "    Path:  $path"
    echo "    User:  $user"
    echo "    Email: $email"

    # Check if config file exists
    local config_file="${HOME}/.config/git/${name}.conf"
    if [ -f "$config_file" ]; then
      echo -e "    Status: ${KD_DF_GREEN}✓ Active${KD_DF_NC}"
    else
      echo -e "    Status: ${KD_DF_YELLOW}○ Not configured${KD_DF_NC}"
    fi

    ((i++))
  done

  echo ""

  # Check if includeIf section exists
  if df_git_has_includeif_section; then
    echo -e "${KD_DF_GREEN}Git includeIf directives: \
Configured${KD_DF_NC}"
  else
    echo -e "${KD_DF_YELLOW}Git includeIf directives: \
Not configured${KD_DF_NC}"
    echo "Run 'just k setup' to configure"
  fi

  return 0
}
