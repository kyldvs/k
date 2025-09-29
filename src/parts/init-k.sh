#!/bin/bash

_needs_init_k() {
    # Check if init.sh has the expected content
    ! grep -q 'for f in ~/.config/k/\*.sh' ~/.config/k/init.sh 2>/dev/null
}

_init_k() {
    kd_step_start "init-k" "Setting up ~/.config/k directory structure"

    if ! _needs_init_k; then
        kd_step_skip "~/.config/k directory already exists"
        return 0
    fi

    kd_log "Creating ~/.config/k directory"
    mkdir -p ~/.config/k

    kd_log "Creating ~/.config/k/init.sh loader script"
    cat > ~/.config/k/init.sh << 'EOF'
# ~/.config/k/init.sh - Loader for all shell customizations
# Sources all .sh files in ~/.config/k/ except init.sh itself

for f in ~/.config/k/*.sh; do
    [ -f "$f" ] && [ "$f" != ~/.config/k/init.sh ] && . "$f"
done
EOF

    kd_step_end
}

_init_k
