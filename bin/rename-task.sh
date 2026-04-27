#!/usr/bin/env bash

set -euo pipefail

TASKS_DIR="$MRP_TASKS_DIR"

if [[ $# -eq 2 ]]; then
    from_name="$1"
    to_name="$2"
elif [[ $# -eq 1 ]]; then
    if [[ -z "${MRP_TASK:-}" ]]; then
        echo "Error: MRP_TASK is not set. Provide both from-name and to-name, or switch to a task first."
        return 1 2>/dev/null || exit 1
    fi
    from_name="$MRP_TASK"
    to_name="$1"
else
    echo "Usage: $0 <to-name>          (renames current task)"
    echo "       $0 <from-name> <to-name>"
    return 1 2>/dev/null || exit 1
fi

from_dir="$TASKS_DIR/$from_name"
to_dir="$TASKS_DIR/$to_name"
from_branch="markp/$from_name"
to_branch="markp/$to_name"

# Validate source task directory exists
if [[ ! -d "$from_dir" ]]; then
    echo "Error: Task directory does not exist: $from_dir"
    return 1 2>/dev/null || exit 1
fi

# Validate destination doesn't already exist
if [[ -d "$to_dir" ]]; then
    echo "Error: Task directory already exists: $to_dir"
    return 1 2>/dev/null || exit 1
fi

# Validate source branch exists
if ! git rev-parse --verify "$from_branch" >/dev/null 2>&1; then
    echo "Error: Branch does not exist: $from_branch"
    return 1 2>/dev/null || exit 1
fi

# Validate destination branch doesn't already exist
if git rev-parse --verify "$to_branch" >/dev/null 2>&1; then
    echo "Error: Branch already exists: $to_branch"
    return 1 2>/dev/null || exit 1
fi

# Show what will be renamed
echo "This will:"
echo "  - Rename task directory: $from_dir -> $to_dir"
echo "  - Rename branch: $from_branch -> $to_branch"
echo "  - Update MRP_TASK to: $to_name"
echo ""
read -rp "Are you sure? [y/N]: " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    return 0 2>/dev/null || exit 0
fi

# Step 1: Rename the git branch
git branch -m "$from_branch" "$to_branch"
echo "Renamed branch: $from_branch -> $to_branch"

# Step 2: Checkout the renamed branch (in case we weren't on it)
git checkout "$to_branch"

# Step 3: Rename the task directory
mv "$from_dir" "$to_dir"
echo "Renamed task directory: $from_dir -> $to_dir"

# Step 4: Update the MRP_TASK environment variable
export MRP_TASK="$to_name"

# Step 5: Rename tmux window if running under tmux
if [[ -n "${TMUX:-}" ]]; then
    tmux rename-window "$to_name"
fi

echo ""
echo "Task '$from_name' renamed to '$to_name' successfully."

