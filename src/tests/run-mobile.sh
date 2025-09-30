#!/usr/bin/env bash
set -euo pipefail

# Mobile bootstrap test runner using Docker Compose
# Usage: src/tests/run-mobile.sh [platform]
# Example: src/tests/run-mobile.sh termux
# IMPORTANT: Run from repo root

platform="${1:-termux}"

if [ "$platform" != "termux" ]; then
    echo "Error: Only 'termux' platform supported currently"
    exit 1
fi

test_file="src/tests/tests/mobile-${platform}.test.sh"
if [ ! -f "$test_file" ]; then
    echo "Error: Test file $test_file not found"
    exit 1
fi

compose_file="src/tests/docker-compose.mobile.yml"
if [ ! -f "$compose_file" ]; then
    echo "Error: Docker Compose file $compose_file not found"
    exit 1
fi

project_name="k-mobile-test"

cleanup() {
    local exit_code=$?
    echo "→ Cleaning up Docker Compose stack"
    docker compose -f "$compose_file" -p "$project_name" down -v >/dev/null 2>&1 || true
    exit $exit_code
}
trap cleanup EXIT INT TERM

echo "→ Building Docker images"
build_output=$(docker compose -f "$compose_file" -p "$project_name" build 2>&1)
build_status=$?
if [ $build_status -ne 0 ]; then
    echo "✗ Build failed"
    echo "$build_output" | tail -20
    exit 1
fi
echo "  ✓ Images built"

echo "→ Starting Docker Compose services"
start_output=$(docker compose -f "$compose_file" -p "$project_name" up -d 2>&1)
start_status=$?
if [ $start_status -ne 0 ]; then
    echo "✗ Failed to start services"
    echo "$start_output" | tail -20
    exit 1
fi
echo "  ✓ Services started"

# Wait for services to be healthy
echo "→ Waiting for services to be ready"
max_wait=30
waited=0
while [ $waited -lt $max_wait ]; do
    if docker compose -f "$compose_file" -p "$project_name" ps | grep -q "healthy"; then
        break
    fi
    sleep 2
    waited=$((waited + 2))
done

if [ $waited -ge $max_wait ]; then
    echo "✗ Services did not become healthy in time"
    docker compose -f "$compose_file" -p "$project_name" ps
    exit 1
fi

echo "  ✓ Services ready"

# Run test in termux-test container
echo "→ Running test: $test_file"
if ! test_output=$(timeout 600 docker compose -f "$compose_file" -p "$project_name" exec -T -u system termux-test bash < "$test_file" 2>&1); then
    echo "✗ Test failed:"
    echo "$test_output"
    exit 1
fi

echo "$test_output"
echo ""
echo "✓ Test passed: mobile-$platform"
