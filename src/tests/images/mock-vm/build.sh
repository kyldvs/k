#!/usr/bin/env bash
set -euo pipefail

# Custom build script for mock-vm image
# Requires test SSH key to be present

image_name="${1:-k-test-mock-vm}"

# Verify test SSH key exists
if [ ! -f "../../fixtures/test-ssh-key.pub" ]; then
    echo "Error: Test SSH key not found at ../../fixtures/test-ssh-key.pub" >&2
    echo "Run: cd ../../fixtures && ssh-keygen -t ed25519 -f test-ssh-key -N \"\" -C \"test@k-mobile-bootstrap\"" >&2
    exit 1
fi

# Build from repo root with proper context
docker build \
    -f Dockerfile \
    -t "$image_name" \
    ../../../..
