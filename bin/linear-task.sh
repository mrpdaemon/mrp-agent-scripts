#!/usr/bin/env bash

# save shell options
__old_opts=$(set +o)

set -euo pipefail

TASKS_DIR="$MRP_TASKS_DIR"

if [[ $# -lt 1 ]] || [[ -z "${1:-}" ]]; then
    echo "Usage: linear-task <issue-id>"
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi

issue_id="$1"

# Step 1: Run auggie to create the task from the linear issue
auggie "/dev-workflow@mrp-auggie-plugins:linear-task $issue_id"

# Step 2: Read the task name from the output file
task_name_file="/tmp/linear-task-name.md"
if [[ ! -f "$task_name_file" ]]; then
    echo "Error: $task_name_file not found. auggie may have failed."
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi

task_name=$(cat "$task_name_file")

# Step 3: Verify the task directory and task.md exist
task_dir="$TASKS_DIR/$task_name"
task_file="$task_dir/task.md"

if [[ ! -d "$task_dir" ]]; then
    echo "Error: Task directory '$task_dir' does not exist."
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi

if [[ ! -f "$task_file" ]]; then
    echo "Error: Task file '$task_file' does not exist."
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi

echo ""
echo "Task '$task_name' created from Linear issue '$issue_id'."

# Step 4: Checkout or create the git branch
branch_name="markp/$task_name"

if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
    echo "Branch '$branch_name' already exists. Checking out..."
    git checkout "$branch_name"
else
    echo "Creating branch '$branch_name' from main..."
    git checkout -b "$branch_name" main
fi

# Step 5: Export the MRP_TASK environment variable
export MRP_TASK="$task_name"

# Step 6: Set tmux window title if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "$task_name"
fi

# restore shell options
eval "$__old_opts"
unset __old_opts

