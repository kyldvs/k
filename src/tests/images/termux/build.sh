#!/usr/bin/env bash
set -euo pipefail

# Custom build script for Termux Docker image
# Addresses dnsmasq file descriptor bug that causes DNS failures

image_name="${1:-termux-test}"

# Build with ulimit to prevent dnsmasq hang during build
# Use network=host to leverage host's DNS resolution
# Build context is repo root, specify dockerfile path
docker build \
    --network=host \
    --ulimit nofile=65536:65536 \
    -f Dockerfile \
    -t "$image_name" \
    ../../../..
