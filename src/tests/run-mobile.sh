#!/usr/bin/env bash
set -euo pipefail

# Mobile bootstrap test runner using Docker Compose
# Usage: ./run-mobile.sh [platform]
# Example: ./run-mobile.sh termux

platform="${1:-termux}"

if [ "$platform" != "termux" ]; then
    echo "Error: Only 'termux' platform supported currently"
    exit 1
fi

test_file="tests/mobile-${platform}.test.sh"
if [ ! -f "$test_file" ]; then
    echo "Error: Test file $test_file not found"
    exit 1
fi

compose_file="docker-compose.mobile.yml"
if [ ! -f "$compose_file" ]; then
    echo "Error: Docker Compose file $compose_file not found"
    exit 1
fi

project_name="k-mobile-test"

cleanup() {
    local exit_code=$?
    echo "→ Cleaning up Docker Compose stack"
    docker-compose -f "$compose_file" -p "$project_name" down -v >/dev/null 2>&1 || true
    exit $exit_code
}
trap cleanup EXIT INT TERM

echo "→ Building Docker images"
if ! docker-compose -f "$compose_file" -p "$project_name" build 2>&1 | grep -E "(Building|Successfully built|ERROR)"; then
    echo "✗ Build failed"
    exit 1
fi

echo "→ Starting Docker Compose services"
if ! docker-compose -f "$compose_file" -p "$project_name" up -d 2>&1 | grep -E "(Creating|Starting|Started|ERROR)"; then
    echo "✗ Failed to start services"
    exit 1
fi

# Wait for services to be healthy
echo "→ Waiting for services to be ready"
max_wait=30
waited=0
while [ $waited -lt $max_wait ]; do
    if docker-compose -f "$compose_file" -p "$project_name" ps | grep -q "healthy"; then
        break
    fi
    sleep 2
    waited=$((waited + 2))
done

if [ $waited -ge $max_wait ]; then
    echo "✗ Services did not become healthy in time"
    docker-compose -f "$compose_file" -p "$project_name" ps
    exit 1
fi

echo "  ✓ Services ready"

# Start bash HTTP server in termux-test container
echo "→ Starting bash HTTP server"
if ! docker-compose -f "$compose_file" -p "$project_name" exec -d -u system termux-test bash -c "cd / && BIND_ADDRESS=0.0.0.0 HTTP_PORT=80 /fixtures/bash-server.sh /fixtures/server-config.sh" >/dev/null 2>&1; then
    echo "✗ HTTP server start failed"
    exit 1
fi

# Wait for server to start
sleep 3

# Verify server is running
if ! docker-compose -f "$compose_file" -p "$project_name" exec -u system termux-test curl -s -f http://localhost:80/ >/dev/null 2>&1; then
    echo "✗ HTTP server not responding"
    exit 1
fi

echo "  ✓ HTTP server running"

# Run test in termux-test container
echo "→ Running test: $test_file"
if ! test_output=$(timeout 600 docker-compose -f "$compose_file" -p "$project_name" exec -T -u system termux-test bash < "$test_file" 2>&1); then
    echo "✗ Test failed:"
    echo "$test_output"
    exit 1
fi

echo "$test_output"
echo ""
echo "✓ Test passed: mobile-$platform"
