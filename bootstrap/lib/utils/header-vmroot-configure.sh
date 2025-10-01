#!/bin/sh
#
# Interactive configuration script for VM root bootstrap
# Creates /root/.config/kyldvs/k/vmroot-configure.json with user settings
#

set -e

# Validate running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "[ERROR] This script must be run as root" >&2
  exit 1
fi
