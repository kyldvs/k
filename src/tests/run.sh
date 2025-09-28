#!/usr/bin/env bash
set -euo pipefail

# Test runner for bootstrap scripts
# Usage: ./run.sh <config> [environment]
# Example: ./run.sh termux

config="${1:-}"
environment="${2:-termux}"

if [ -z "$config" ]; then
    echo "Usage: $0 <config> [environment]"
    echo "Example: $0 termux"
    exit 1
fi

bootstrap_script="../../bootstrap/${config}.sh"
if [ ! -f "$bootstrap_script" ]; then
    echo "Error: Bootstrap script $bootstrap_script not found"
    echo "Run: just bootstrap build $config"
    exit 1
fi

test_file="tests/${config}.test.sh"
if [ ! -f "$test_file" ]; then
    echo "Error: Test file $test_file not found"
    exit 1
fi

image_name="k-test-${environment}"
container_name="k-test-${config}-${environment}-$$"

echo "→ Building test image: $image_name"
cd "images/$environment"
docker build -t "$image_name" . >/dev/null 2>&1
cd ../..

cleanup() {
    echo "→ Cleaning up container: $container_name"
    docker rm -f "$container_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "→ Starting test container: $container_name"
docker run -d \
    --name "$container_name" \
    --add-host="k.local:127.0.0.1" \
    -v "$(pwd)/../../bootstrap:/var/www/bootstrap:ro" \
    "$image_name" \
    tail -f /dev/null >/dev/null

# Start simple HTTP server
echo "→ Starting HTTP server"
if [ "$environment" = "termux" ]; then
    # For Termux, skip HTTP server and copy file directly
    echo "→ Copying bootstrap script directly for Termux test"
    docker exec "$container_name" cp /var/www/bootstrap/termux.sh /tmp/bootstrap.sh
else
    # For other environments, use python3
    docker exec -d "$container_name" python3 -m http.server 80 --directory /var/www/bootstrap >/dev/null 2>&1
fi

# Wait for server to start
sleep 2

echo "→ Running test: $test_file"
docker exec -i "$container_name" bash < "$test_file"

echo "✓ Test passed: $config on $environment"
