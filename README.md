# mrp-agent-scripts
mrpdaemon's agent workflow scripts

## Setup

Add the following to your shell rc file (e.g. `~/.bashrc` or `~/.zshrc`):

```bash
export MRP_TASKS_DIR="/home/augment/.augment/tasks"
source /path/to/mrp-agent-scripts/init.sh
```

Replace `/path/to/mrp-agent-scripts` with the actual path to this repository.

### Project map

Active task directories are organized per-project: `$MRP_TASKS_DIR/<project>/<task>/`. The mapping from repo path to project name and main branch name is configured in `~/.mrp-project-map`, one entry per line as a triple of quoted CSV atoms. Multiple repo paths (e.g. git worktrees) can map to the same project name:

```
# "repo_path", "project_name", "main_branch_name"
"/home/mark/Code/mrp-agent-scripts", "agent-scripts", "main"
"/home/mark/Code/worktrees/mrp-feature", "agent-scripts", "main"
"/home/mark/Code/photo-pipeline", "photos", "master"
```

The third atom declares the project's main branch — the branch new task branches are forked from and the branch the task commands switch back to on clear/archive/delete. Each project can have a different value (e.g. `main` for newer repos, `master` for older ones).

Task commands resolve the project from `MRP_PROJECT` if set, otherwise from `git rev-parse --show-toplevel` of the current directory looked up in the map. Running a task command from an unmapped repo (with `MRP_PROJECT` unset) is an error — add the repo to `~/.mrp-project-map` first.

## Scripts

All task-creation and task-selection scripts (`new-task`, `linear-task`, `switch-task`) resolve the project from the current repo via `~/.mrp-project-map` and export `MRP_PROJECT` and `MRP_MAIN_BRANCH_NAME` alongside `MRP_TASK`. `MRP_PROJECT` represents your current project context and persists across task-clearing/archiving/deletion — it stays set until you explicitly `unset` it or `cd` to a different repo (where it'll be re-resolved when needed). `MRP_MAIN_BRANCH_NAME` is exported alongside `MRP_PROJECT` so downstream workflow tooling can read it.

- **`new-task <task_name>`** — Creates a new task: sets up `$MRP_TASKS_DIR/<project>/<task_name>/`, opens vim to write a `task.md` description, creates/checks out a `markp/<task_name>` git branch from main, exports `MRP_TASK` and `MRP_PROJECT`, and sets the tmux window title.
- **`switch-task <task_name>`** — Switches to an existing task in the current project by checking out its git branch, exporting `MRP_TASK` and `MRP_PROJECT`, and updating the tmux window title.
- **`clear-task`** — Deactivates the current task by switching to the main branch, unsetting `MRP_TASK`, and resetting the tmux window title. `MRP_PROJECT` is preserved.
- **`archive-task [task_name]`** — Archives a task (defaults to current `MRP_TASK`): moves the task directory to `$MRP_TASKS_DIR/.archived-tasks/<YYYY-MM-DD>-<project>-<task_name>/`, switches to main, deletes the task branch, and unsets `MRP_TASK`. `MRP_PROJECT` is preserved.
- **`rename-task [from-name] <to-name>`** — Renames a task (defaults to current `MRP_TASK` if only one argument given) within the current project: renames the git branch, task directory, updates `MRP_TASK`, and sets the tmux window title.
- **`delete-task [task_name]`** — Permanently deletes a task (defaults to current `MRP_TASK`): removes the task directory, switches to main, deletes the task branch, and unsets `MRP_TASK`. `MRP_PROJECT` is preserved.
