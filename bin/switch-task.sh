#!/usr/bin/env bash

set -euo pipefail

TASKS_DIR="$MRP_TASKS_DIR"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <task_name>"
    return 1 2>/dev/null || exit 1
fi

task_name="$1"

project=$(_mrp_resolve_project) || { return 1 2>/dev/null || exit 1; }

task_dir="$TASKS_DIR/$project/$task_name"
branch_name="markp/$task_name"

# Step 1: Validate the task directory exists
if [[ ! -d "$task_dir" ]]; then
    echo "Error: Task directory does not exist: $task_dir"
    return 1 2>/dev/null || exit 1
fi

# Step 2: Checkout the task branch
git checkout "$branch_name"

# Step 3: Export the MRP_TASK and MRP_PROJECT environment variables
export MRP_TASK="$task_name"
export MRP_PROJECT="$project"

# Step 4: Set tmux window title if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "$project:$task_name"
fi

echo "Switched to task '$task_name'."
