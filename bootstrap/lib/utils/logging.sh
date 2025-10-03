# Indentation tracking
KD_INDENT=0
KD_CURRENT_STEP=""

# Get current indentation string
_kd_indent() {
  i=0
  while [ $i -lt $KD_INDENT ]; do
    printf "  "
    i=$((i + 1))
  done
}

# Log functions
kd_log() {
  local msg="$*"
  printf "%s%s\n" "$(_kd_indent)" "$msg"
}

kd_error() {
  local msg="$*"
  printf "%s[ERROR]%s %s\n" "$KD_RED" "$KD_RESET" "$msg" >&2
}

kd_warning() {
  local msg="$*"
  printf "%s⚠ WARNING:%s %s\n" "$KD_YELLOW" "$KD_RESET" "$msg" >&2
}

kd_info() {
  local msg="$*"
  printf "%sℹ INFO:%s %s\n" "$KD_BLUE" "$KD_RESET" "$msg"
}
