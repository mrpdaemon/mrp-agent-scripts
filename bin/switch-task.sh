#!/usr/bin/env bash
set -euo pipefail

TASKS_DIR="$HOME/.augment/tasks"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <task_name>"
    exit 1
fi

task_name="$1"
task_dir="$TASKS_DIR/$task_name"
branch_name="markp/$task_name"

# Step 1: Validate the task directory exists
if [[ ! -d "$task_dir" ]]; then
    echo "Error: Task directory does not exist: $task_dir"
    exit 1
fi

# Step 2: Checkout the task branch
git checkout "$branch_name"

# Step 3: Export the MRP_TASK environment variable
export MRP_TASK="$task_name"

echo "Switched to task '$task_name'."

