#!/usr/bin/env bash

# Configuration for bash-server.sh
# Defines the runner function that serves files from /var/www/bootstrap

runner() {
    local file="/var/www/bootstrap${REQUEST_PATH}"

    # Serve file if it exists
    if [ -f "$file" ]; then
        cat "$file"
    else
        # Return 404 for missing files
        echo "404 Not Found: ${REQUEST_PATH}"
    fi
}
