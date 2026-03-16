#!/usr/bin/env bash

# save shell options
__old_opts=$(set +o)

set -euo pipefail

TASKS_DIR="$MRP_TASKS_DIR"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <task_name>"
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi

task_name="$1"
task_dir="$TASKS_DIR/$task_name"
branch_name="markp/$task_name"

# Step 1: Validate the task directory exists
if [[ ! -d "$task_dir" ]]; then
    echo "Error: Task directory does not exist: $task_dir"
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi

# Step 2: Checkout the task branch
git checkout "$branch_name"

# Step 3: Export the MRP_TASK environment variable
export MRP_TASK="$task_name"

# Step 4: Set tmux window title if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "$task_name"
fi

echo "Switched to task '$task_name'."

# restore shell options
eval "$__old_opts"
unset __old_opts
