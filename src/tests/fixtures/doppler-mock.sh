#!/usr/bin/env bash
#
# Mock Doppler CLI for testing
# WARNING: Test fixture only - DO NOT use in production
#

set -euo pipefail

MOCK_TOKEN="mock-doppler-token-12345"
FIXTURES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mock doppler configure get token
if [[ "${1:-}" == "configure" ]] && [[ "${2:-}" == "get" ]] && [[ "${3:-}" == "token" ]]; then
  # Return mock token for auth checks
  echo "$MOCK_TOKEN"
  exit 0
fi

# Mock doppler secrets get
if [[ "${1:-}" == "secrets" ]] && [[ "${2:-}" == "get" ]]; then
  secret_name="${3:-}"

  case "$secret_name" in
    SSH_GH_VM_PUBLIC)
      # Return test SSH public key
      if [[ -f "$FIXTURES_DIR/test-ssh-key.pub" ]]; then
        cat "$FIXTURES_DIR/test-ssh-key.pub"
        exit 0
      else
        echo "Error: test-ssh-key.pub not found" >&2
        exit 1
      fi
      ;;
    SSH_GH_VM_PRIVATE)
      # Return test SSH private key
      if [[ -f "$FIXTURES_DIR/test-ssh-key" ]]; then
        cat "$FIXTURES_DIR/test-ssh-key"
        exit 0
      else
        echo "Error: test-ssh-key not found" >&2
        exit 1
      fi
      ;;
    *)
      echo "Error: Unknown secret: $secret_name" >&2
      exit 1
      ;;
  esac
fi

# Default help output matching real doppler
cat <<EOF
Usage:
  doppler [command]

Available Commands:
  configure   Configure Doppler CLI
  secrets     Manage secrets

Use "doppler [command] --help" for more information about a command.
EOF
exit 0
