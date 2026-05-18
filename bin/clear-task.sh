#!/usr/bin/env bash

set -euo pipefail

MAIN_BRANCH="${MRP_MAIN_BRANCH_NAME:-main}"

project=$(_mrp_resolve_project) || { return 1 2>/dev/null || exit 1; }

# Step 1: Switch to main branch
git checkout "$MAIN_BRANCH"

# Step 2: Clear the MRP_TASK environment variable
unset MRP_TASK

# Step 3: Rename tmux window if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "$project:$MAIN_BRANCH"
fi

echo "Cleared task. Switched to $MAIN_BRANCH branch."

