#!/usr/bin/env bash

# save shell options
__old_opts=$(set +o)

set -euo pipefail

TASKS_DIR="$MRP_TASKS_DIR"

if [[ $# -lt 1 ]] || [[ -z "${1:-}" ]]; then
    echo "Usage: new-task <task_name>"
    eval "$__old_opts"
    unset __old_opts
    return 1 2>/dev/null || exit 1
fi

task_name="$1"
task_dir="$TASKS_DIR/$task_name"
task_file="$task_dir/task.md"

# Step 1: Create the task directory
mkdir -p "$task_dir"

# Step 2: Handle existing task.md
if [[ -f "$task_file" ]]; then
    echo "task.md already exists for '$task_name'."
    echo ""
    echo "  1) Overwrite"
    echo "  2) Append"
    echo ""
    read -rp "Choose [1/2]: " choice
    case "$choice" in
        1)
            mode="overwrite"
            ;;
        2)
            mode="append"
            ;;
        *)
            echo "Invalid choice. Aborting."
            eval "$__old_opts"
            unset __old_opts
            return 1 2>/dev/null || exit 1
            ;;
    esac
else
    mode="overwrite"
fi

# Step 3: Open vim for the user to write the description
tmpfile=$(mktemp /tmp/new-task-XXXXXX.md)

if [[ "$mode" == "append" ]]; then
    # Pre-populate with existing content so the user can see it
    cp "$task_file" "$tmpfile"
fi

vim "$tmpfile"

# Step 4: Write the result
if [[ "$mode" == "append" ]]; then
    cp "$tmpfile" "$task_file"
else
    cp "$tmpfile" "$task_file"
fi

rm -f "$tmpfile"

# Step 5: Confirm
echo ""
echo "=== $task_file ==="
cat "$task_file"
echo ""
echo "Task '$task_name' created successfully."

# Step 6: Checkout or create the git branch
branch_name="markp/$task_name"

if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
    echo "Branch '$branch_name' already exists. Checking out..."
    git checkout "$branch_name"
else
    echo "Creating branch '$branch_name' from main..."
    git checkout -b "$branch_name" main
fi

# Step 7: Export the MRP_TASK environment variable
export MRP_TASK="$task_name"

# Step 8: Set tmux window title if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "$task_name"
fi

# restore shell options
eval "$__old_opts"
unset __old_opts
