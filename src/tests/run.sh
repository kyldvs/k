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

# Find available port
get_random_port() {
    local port
    while true; do
        port=$((8000 + RANDOM % 1000))
        if ! nc -z localhost $port 2>/dev/null; then
            echo $port
            return
        fi
    done
}

HTTP_PORT=$(get_random_port)

echo "→ Building test image: $image_name"
cd "images/$environment"

# Check if custom build script exists
if [ -f "build.sh" ]; then
    echo "  Using custom build script"
    if ! build_output=$(./build.sh "$image_name" 2>&1); then
        echo "✗ Build failed:"
        echo "$build_output"
        exit 1
    fi
else
    if ! build_output=$(docker build -t "$image_name" . 2>&1); then
        echo "✗ Build failed:"
        echo "$build_output"
        exit 1
    fi
fi

cd ../..

cleanup() {
    local exit_code=$?
    echo "→ Cleaning up container: $container_name"
    docker rm -f "$container_name" >/dev/null 2>&1 || true
    exit $exit_code
}
trap cleanup EXIT INT TERM

echo "→ Starting test container: $container_name"
if [ "$environment" = "termux" ]; then
    # For Termux, use ulimit to prevent dnsmasq hang at runtime
    # Use sleep instead of tail to keep entrypoint working properly
    if ! container_output=$(docker run -d \
        --name "$container_name" \
        --add-host="k.local:127.0.0.1" \
        -p $HTTP_PORT:80 \
        --ulimit nofile=65536:65536 \
        -v "$(pwd)/../../bootstrap:/var/www/bootstrap:ro" \
        "$image_name" \
        sleep infinity 2>&1); then
        echo "✗ Container start failed:"
        echo "$container_output"
        exit 1
    fi
else
    if ! container_output=$(docker run -d \
        --name "$container_name" \
        --add-host="k.local:127.0.0.1" \
        -p $HTTP_PORT:80 \
        -v "$(pwd)/../../bootstrap:/var/www/bootstrap:ro" \
        "$image_name" \
        tail -f /dev/null 2>&1); then
        echo "✗ Container start failed:"
        echo "$container_output"
        exit 1
    fi
fi

# No Python installation needed - using bash HTTP server

# Start bash HTTP server
echo "→ Starting bash HTTP server"
if [ "$environment" = "termux" ]; then
    if ! server_output=$(docker exec -d --user system "$container_name" bash -c "cd / && BIND_ADDRESS=0.0.0.0 HTTP_PORT=80 /fixtures/bash-server.sh /fixtures/server-config.sh" 2>&1); then
        echo "✗ HTTP server start failed:"
        echo "$server_output"
        exit 1
    fi
else
    if ! server_output=$(docker exec -d "$container_name" bash -c "cd / && BIND_ADDRESS=0.0.0.0 HTTP_PORT=80 /fixtures/bash-server.sh /fixtures/server-config.sh" 2>&1); then
        echo "✗ HTTP server start failed:"
        echo "$server_output"
        exit 1
    fi
fi

# Wait for server to start and verify it's running
sleep 3
echo "→ Verifying bash HTTP server"
if [ "$environment" = "termux" ]; then
    if ! docker exec --user system "$container_name" curl -s -f http://localhost:80/ >/dev/null 2>&1; then
        echo "✗ HTTP server not responding"
        # Show server process status
        docker exec --user system "$container_name" ps aux | grep bash-server || true
        exit 1
    fi
else
    if ! docker exec "$container_name" curl -s -f http://localhost:80/ >/dev/null 2>&1; then
        echo "✗ HTTP server not responding"
        docker exec "$container_name" ps aux | grep bash-server || true
        exit 1
    fi
fi

echo "→ Running test: $test_file"
if [ "$environment" = "termux" ]; then
    if ! test_output=$(timeout 600 docker exec -i --user system "$container_name" bash < "$test_file" 2>&1); then
        echo "✗ Test failed:"
        echo "$test_output"
        exit 1
    fi
else
    if ! test_output=$(timeout 600 docker exec -i "$container_name" bash < "$test_file" 2>&1); then
        echo "✗ Test failed:"
        echo "$test_output"
        exit 1
    fi
fi

echo "✓ Test passed: $config on $environment"
