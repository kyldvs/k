#!/usr/bin/env bash
set -euo pipefail

# Dotfiles test runner using Docker Compose
# Usage: src/tests/run-dotfiles.sh
# IMPORTANT: Run from repo root

test_file="src/tests/tests/dotfiles.test.sh"
if [ ! -f "$test_file" ]; then
    echo "Error: Test file $test_file not found"
    exit 1
fi

compose_file="src/tests/docker-compose.dotfiles.yml"
if [ ! -f "$compose_file" ]; then
    echo "Error: Docker Compose file $compose_file not found"
    exit 1
fi

project_name="k-dotfiles-test"

cleanup() {
    local exit_code=$?
    echo "→ Cleaning up Docker Compose stack"
    docker compose -f "$compose_file" -p "$project_name" down -v \
      >/dev/null 2>&1 || true
    exit $exit_code
}
trap cleanup EXIT INT TERM

echo "→ Building Docker images"
build_output=$(docker compose -f "$compose_file" -p "$project_name" \
  build 2>&1)
build_status=$?
if [ $build_status -ne 0 ]; then
    echo "✗ Build failed"
    echo "$build_output" | tail -20
    exit 1
fi
echo "  ✓ Images built"

echo "→ Starting Docker Compose services"
start_output=$(docker compose -f "$compose_file" -p "$project_name" \
  up -d 2>&1)
start_status=$?
if [ $start_status -ne 0 ]; then
    echo "✗ Failed to start services"
    echo "$start_output" | tail -20
    exit 1
fi
echo "  ✓ Services started"

# Wait for container to be ready
echo "→ Waiting for container to be ready"
sleep 2
echo "  ✓ Container ready"

# Run test in dotfiles-test container as testuser
echo "→ Running test: $test_file"
if ! test_output=$(timeout 120 docker compose -f "$compose_file" \
  -p "$project_name" exec -T dotfiles-test bash < "$test_file" 2>&1); then
    echo "✗ Test failed:"
    echo "$test_output"
    exit 1
fi

echo "$test_output"
echo ""
echo "✓ Test passed: dotfiles"
