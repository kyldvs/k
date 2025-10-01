#!/bin/sh
#
# VM root bootstrap script
# Provisions non-root user with sudo access and SSH keys
#

set -e

# Validate running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] This script must be run as root" >&2
  exit 1
fi
