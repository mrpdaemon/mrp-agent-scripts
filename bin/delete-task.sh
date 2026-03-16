#!/usr/bin/env bash
set -euo pipefail

TASKS_DIR="$MRP_TASKS_DIR"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <task_name>"
    exit 1
fi

task_name="$1"
task_dir="$TASKS_DIR/$task_name"
branch_name="markp/$task_name"

# Show what will be deleted
echo "This will:"
echo "  - Delete task directory: $task_dir"
echo "  - Switch to main branch"
echo "  - Delete branch: $branch_name"
echo ""
read -rp "Are you sure? [y/N]: " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

# Step 1: Delete the task directory
if [[ -d "$task_dir" ]]; then
    rm -rf "$task_dir"
    echo "Deleted task directory: $task_dir"
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

echo ""
echo "Task '$task_name' deleted successfully."

