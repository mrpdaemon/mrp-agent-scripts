# mrp-agent-scripts
mrpdaemon's agent workflow scripts

## Setup

Add the following to your shell rc file (e.g. `~/.bashrc` or `~/.zshrc`):

```bash
export MRP_TASKS_DIR="/home/augment/.augment/tasks"
source /path/to/mrp-agent-scripts/init.sh
```

Replace `/path/to/mrp-agent-scripts` with the actual path to this repository.

Optionally, if your repository's default branch is not `main`, set:

```bash
export MRP_MAIN_BRANCH_NAME="master"  # or whatever your default branch is
```

## Scripts

- **`new-task <task_name>`** — Creates a new task: sets up a task directory, opens vim to write a `task.md` description, creates/checks out a `markp/<task_name>` git branch from main, exports `MRP_TASK`, and sets the tmux window title.
- **`switch-task <task_name>`** — Switches to an existing task by checking out its git branch, exporting `MRP_TASK`, and updating the tmux window title.
- **`clear-task`** — Deactivates the current task by switching to the main branch, unsetting `MRP_TASK`, and resetting the tmux window title.
- **`archive-task [task_name]`** — Archives a task (defaults to current `MRP_TASK`): moves the task directory to `.archived-tasks/` with a date prefix, switches to main, and deletes the task branch.
- **`rename-task [from-name] <to-name>`** — Renames a task (defaults to current `MRP_TASK` if only one argument given): renames the git branch, task directory, updates `MRP_TASK`, and sets the tmux window title.
- **`delete-task [task_name]`** — Permanently deletes a task (defaults to current `MRP_TASK`): removes the task directory, switches to main, and deletes the task branch.
