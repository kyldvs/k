#!/bin/bash

_needs_ssh_utils() {
    grep -q "ssha()" ~/.profile 2>/dev/null
}

_ssh_utils() {
    kd_step_start "ssh-utils" "Add SSH agent wrapper functions"

    if _needs_ssh_utils; then
        kd_step_skip "SSH utilities already configured"
        return
    fi

    kd_log "Adding SSH agent wrapper functions to ~/.profile"

    cat >> ~/.profile << 'EOF'

# SSH agent wrapper functions
ssha() {
    # Check if agent running
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval $(ssh-agent -s)
    fi
    # Check if keys loaded
    if ! ssh-add -l &>/dev/null; then
        ssh-add
    fi
    ssh "$@"
}

mosha() {
    # Same agent setup as ssha
    if [ -z "$SSH_AUTH_SOCK" ]; then
        eval $(ssh-agent -s)
    fi
    if ! ssh-add -l &>/dev/null; then
        ssh-add
    fi
    mosh "$@"
}
EOF

    kd_step_end
}
