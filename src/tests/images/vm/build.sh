#!/usr/bin/env bash
set -euo pipefail

# Custom build script for Ubuntu Docker image

image_name="${1:-ubuntu-test}"

# Build with network=host for DNS resolution and ulimit for reliability
# Build context is repo root, specify dockerfile path
docker build \
    --network=host \
    --ulimit nofile=65536:65536 \
    -f Dockerfile \
    -t "$image_name" \
    ../../../..
