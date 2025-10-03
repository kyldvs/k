# Step functions
kd_step_start() {
  local step_name="$1"
  shift
  local message="$*"

  KD_CURRENT_STEP="$step_name"

  printf "%s→%s %s%s%s" "$KD_CYAN" "$KD_RESET" "$KD_CYAN" "$step_name" \
    "$KD_RESET"
  if [ -n "$message" ]; then
    printf ": %s" "$message"
  fi
  printf "\n"

  KD_INDENT=$((KD_INDENT + 1))
}

kd_step_end() {
  if [ "$KD_INDENT" -gt 0 ]; then
    KD_INDENT=$((KD_INDENT - 1))
  fi

  if [ -n "$KD_CURRENT_STEP" ]; then
    printf "%s✓%s %sdone%s\n" "$KD_GREEN" "$KD_RESET" "$KD_GREEN" \
      "$KD_RESET"
    KD_CURRENT_STEP=""
  fi
}

kd_step_skip() {
  local reason="$*"

  if [ "$KD_INDENT" -gt 0 ]; then
    KD_INDENT=$((KD_INDENT - 1))
  fi

  printf "  %s○%s %sskipping%s" "$KD_GRAY" "$KD_RESET" "$KD_GRAY" \
    "$KD_RESET"
  if [ -n "$reason" ]; then
    printf " %s(%s%s%s)%s" "$KD_GRAY" "$KD_RESET" "$reason" "$KD_GRAY" \
      "$KD_RESET"
  fi
  printf "\n"
  KD_CURRENT_STEP=""
}
