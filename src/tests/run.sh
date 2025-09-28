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

# Check if custom build script exists
if [ -f "build.sh" ]; then
    echo "  Using custom build script"
    ./build.sh "$image_name" >/dev/null 2>&1
else
    docker build -t "$image_name" . >/dev/null 2>&1
fi

cd ../..

cleanup() {
    echo "→ Cleaning up container: $container_name"
    docker rm -f "$container_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "→ Starting test container: $container_name"
if [ "$environment" = "termux" ]; then
    # For Termux, use ulimit to prevent dnsmasq hang at runtime
    # Use sleep instead of tail to keep entrypoint working properly
    docker run -d \
        --name "$container_name" \
        --add-host="k.local:127.0.0.1" \
        --ulimit nofile=65536:65536 \
        -v "$(pwd)/../../bootstrap:/var/www/bootstrap:ro" \
        "$image_name" \
        sleep infinity >/dev/null
else
    docker run -d \
        --name "$container_name" \
        --add-host="k.local:127.0.0.1" \
        -v "$(pwd)/../../bootstrap:/var/www/bootstrap:ro" \
        "$image_name" \
        tail -f /dev/null >/dev/null
fi

# Install Python if needed (for environments like Termux)
if [ "$environment" = "termux" ]; then
    echo "→ Installing Python in container (this may take a minute)"
    docker exec --user system "$container_name" bash -c "command -v python3 >/dev/null 2>&1 || (pkg update -y && pkg install -y python3)" >/dev/null 2>&1
fi

# Start simple HTTP server
echo "→ Starting HTTP server"
if [ "$environment" = "termux" ]; then
    docker exec -d --user system "$container_name" python3 -m http.server 80 --directory /var/www/bootstrap >/dev/null 2>&1
else
    docker exec -d "$container_name" python3 -m http.server 80 --directory /var/www/bootstrap >/dev/null 2>&1
fi

# Wait for server to start
sleep 2

echo "→ Running test: $test_file"
if [ "$environment" = "termux" ]; then
    docker exec -i --user system "$container_name" bash < "$test_file"
else
    docker exec -i "$container_name" bash < "$test_file"
fi

echo "✓ Test passed: $config on $environment"
