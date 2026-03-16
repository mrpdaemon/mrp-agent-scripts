#!/usr/bin/env bash

# save shell options
__old_opts=$(set +o)

set -euo pipefail

# Step 1: Switch to main branch
git checkout main

# Step 2: Clear the MRP_TASK environment variable
unset MRP_TASK

# Step 3: Rename tmux window if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "main"
fi

echo "Cleared task. Switched to main branch."

# restore shell options
eval "$__old_opts"
unset __old_opts

