#!/usr/bin/env bash
set -euo pipefail

# Custom build script for Ubuntu Docker image

image_name="${1:-ubuntu-test}"

# Build Docker image
# Build context is repo root, specify dockerfile path
docker build \
    -f Dockerfile \
    -t "$image_name" \
    ../../../..
