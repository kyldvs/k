#!/bin/bash

_needs_init_k() {
    [ ! -d ~/.k ]
}

_init_k() {
    kd_step_start "init-k" "Setting up ~/.k directory structure"

    if ! _needs_init_k; then
        kd_step_skip "~/.k directory already exists"
        return 0
    fi

    kd_log "Creating ~/.k directory"
    mkdir -p ~/.k

    kd_log "Creating ~/.k/init.sh loader script"
    cat > ~/.k/init.sh << 'EOF'
# ~/.k/init.sh - Loader for all shell customizations
# Sources all .sh files in ~/.k/ except init.sh itself

for f in ~/.k/*.sh; do
    [ -f "$f" ] && [ "$f" != ~/.k/init.sh ] && . "$f"
done
EOF

    kd_step_end
}

_init_k
