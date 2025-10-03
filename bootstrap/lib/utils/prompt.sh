#!/usr/bin/env sh
# Configuration file path
CONFIG_DIR="$HOME/.config/kyldvs/k"
CONFIG_FILE="$CONFIG_DIR/configure.json"

# Prompt helper function
prompt() {
  local prompt_text="$1"
  local default_value="$2"
  local var_name="$3"

  if [ -n "$default_value" ]; then
    printf "%s%s%s [%s]: " "$KD_CYAN" "$prompt_text" "$KD_RESET" "$default_value"
  else
    printf "%s%s%s: " "$KD_CYAN" "$prompt_text" "$KD_RESET"
  fi

  read -r value

  if [ -z "$value" ] && [ -n "$default_value" ]; then
    value="$default_value"
  fi

  eval "$var_name=\"\$value\""
}

# Validated prompt helper function
# Loops until valid input is received
prompt_validated() {
  local prompt_text="$1"
  local default_value="$2"
  local var_name="$3"
  local validator="$4"
  local error_msg="$5"

  while true; do
    # Get user input using standard prompt
    prompt "$prompt_text" "$default_value" "$var_name"
    eval "value=\$$var_name"

    # Validate input
    if $validator "$value"; then
      return 0
    fi

    # Show error and re-prompt
    printf "%s✗ Invalid input:%s %s\n" "$KD_RED" "$KD_RESET" "$error_msg"
  done
}
