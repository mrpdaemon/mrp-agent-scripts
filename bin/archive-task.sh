#!/usr/bin/env bash

# save shell options
__old_opts=$(set +o)

set -euo pipefail

TASKS_DIR="$MRP_TASKS_DIR"
ARCHIVE_DIR="$(dirname "$MRP_TASKS_DIR")/.archived-tasks"

if [[ $# -ge 1 ]]; then
    task_name="$1"
elif [[ -n "${MRP_TASK:-}" ]]; then
    task_name="$MRP_TASK"
else
    echo "Usage: $0 <task_name>"
    echo "Or set MRP_TASK to use the current task."
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi
task_dir="$TASKS_DIR/$task_name"
archive_dest="$ARCHIVE_DIR/$task_name"
branch_name="markp/$task_name"

# Show what will happen
echo "This will:"
echo "  - Archive task directory: $task_dir -> $archive_dest"
echo "  - Switch to main branch"
echo "  - Delete branch: $branch_name"
echo ""
read -rp "Are you sure? [y/N]: " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    eval "$__old_opts"
    unset __old_opts
    return 0 2>/dev/null || exit 0
fi

# Step 1: Archive the task directory
if [[ -d "$task_dir" ]]; then
    mkdir -p "$ARCHIVE_DIR"
    mv "$task_dir" "$archive_dest"
    echo "Archived task directory: $task_dir -> $archive_dest"
else
    echo "Task directory does not exist: $task_dir (skipping)"
fi

# Step 2: Switch to main branch
git checkout main

# Step 3: Delete the task branch
if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
    git branch -D "$branch_name"
    echo "Deleted branch: $branch_name"
else
    echo "Branch does not exist: $branch_name (skipping)"
fi

# Step 4: Clear the MRP_TASK environment variable
unset MRP_TASK

# Step 5: Rename tmux window if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "main"
fi

echo ""
echo "Task '$task_name' archived successfully."

# restore shell options
eval "$__old_opts"
unset __old_opts

