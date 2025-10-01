# POSIX compliant color definitions - always enable unless KD_NO_COLOR is set
if [ -z "$KD_NO_COLOR" ]; then
  KD_RED=$(printf '\033[31m')
  KD_GREEN=$(printf '\033[32m')
  KD_YELLOW=$(printf '\033[33m')
  KD_BLUE=$(printf '\033[34m')
  KD_CYAN=$(printf '\033[36m')
  KD_GRAY=$(printf '\033[90m')
  KD_WHITE=$(printf '\033[97m')
  KD_RESET=$(printf '\033[0m')
  KD_BOLD=$(printf '\033[1m')
else
  KD_RED=''
  KD_GREEN=''
  KD_YELLOW=''
  KD_BLUE=''
  KD_CYAN=''
  KD_GRAY=''
  KD_WHITE=''
  KD_RESET=''
  KD_BOLD=''
fi
