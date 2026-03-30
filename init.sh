# mrp-agent-scripts init
# Source this file from your shell rc file (e.g. .bashrc, .zshrc):
#   export MRP_TASKS_DIR="/home/augment/.augment/tasks"
#   source ~/Code/mrp-agent-scripts/init.sh

if [[ -z "${MRP_TASKS_DIR:-}" ]]; then
  echo "WARNING: MRP_TASKS_DIR is not set. mrp-agent-scripts commands will not work." >&2
  echo "Add 'export MRP_TASKS_DIR=\"/path/to/tasks\"' before sourcing init.sh." >&2
fi

_MRP_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$_MRP_SCRIPTS_DIR/bin:$PATH"

alias gl='glow -p -w 120'
lst() {
  if [[ $# -ge 1 ]]; then
    ls "$MRP_TASKS_DIR/$1/"
  else
    ls "$MRP_TASKS_DIR"
  fi
}

lstt() {
  echo "Task directory contents for $MRP_TASK:"
  ls "$MRP_TASKS_DIR/$MRP_TASK/"
}

glt() {
  local task file

  if [[ -n "$MRP_TASK" ]]; then
    task="$MRP_TASK"
    file="$1"
  else
    task="$1"
    file="$2"
  fi

  local path="$MRP_TASKS_DIR/$task/$file"
  if [[ ! -f "$path" ]]; then
    echo "File not found: $path" >&2
    return 0
  fi

  glow -p -w 120 "$path" || true
}

vit() {
  local task file

  if [[ -n "$MRP_TASK" ]]; then
    task="$MRP_TASK"
    file="$1"
  else
    task="$1"
    file="$2"
  fi

  local path="$MRP_TASKS_DIR/$task/$file"
  if [[ ! -f "$path" ]]; then
    echo "File not found: $path" >&2
    return 0
  fi

  vim "$path" || true
}

nt() { source new-task.sh "$1" || true; }
at() { source archive-task.sh "$@" || true; }
dt() { source delete-task.sh "$@" || true; }
rt() { source rename-task.sh "$@" || true; }
st() { source switch-task.sh "$1" || true; }
ct() { source clear-task.sh || true; }
nlt() { source linear-task.sh "$1" || true; }

