#!/bin/bash
#
# Mock VM SSH server entrypoint
# Starts SSH server and keeps container running
#

set -euo pipefail

echo "→ Starting mock VM SSH server..."

# Ensure host keys exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    echo "  Generating SSH host keys..."
    ssh-keygen -A
fi

# Start SSH server in foreground
echo "  SSH server ready on port 22"
echo "  Accepting connections for user: testuser"

# Run sshd in debug mode for test visibility
exec /usr/sbin/sshd -D -e
