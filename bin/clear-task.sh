#!/usr/bin/env bash

set -euo pipefail

_mrp_resolve_context || { return 1 2>/dev/null || exit 1; }

# Step 1: Switch to main branch
git checkout "$MRP_MAIN_BRANCH_NAME"

# Step 2: Clear the MRP_TASK environment variable
unset MRP_TASK

# Step 3: Rename tmux window if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "$MRP_PROJECT:$MRP_MAIN_BRANCH_NAME"
fi

echo "Cleared task. Switched to $MRP_MAIN_BRANCH_NAME branch."

