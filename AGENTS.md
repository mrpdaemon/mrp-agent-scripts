# Agent instructions

## Keep README.md in sync

Update `README.md` whenever you:

- Add a new command (script in `bin/` or shell function in `init.sh` that users invoke).
- Make material changes to an existing command — anything user-visible, including:
  - Arguments, flags, or invocation patterns.
  - Behavior, side effects, or the files/directories the command reads or writes.
  - Environment variables the command sets, reads, or unsets.
  - Git operations (branch creation/checkout/deletion) or tmux integration.
- Change the directory layout under `$MRP_TASKS_DIR`, the archive naming scheme, or the project-map format.

Skip the README update for purely internal refactors that don't change user-visible behavior (renaming an internal helper, restructuring a script without altering its contract, etc.).
