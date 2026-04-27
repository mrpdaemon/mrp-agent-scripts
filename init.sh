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
  if [[ -z "${MRP_TASKS_DIR:-}" ]]; then
    echo "MRP_TASKS_DIR is not set." >&2
    return 1
  fi

  if [[ -n "$MRP_TASK" ]]; then
    echo "Task directory contents for $MRP_TASK:"
    ls "$MRP_TASKS_DIR/$MRP_TASK/"
  elif [[ $# -ge 1 ]]; then
    ls "$MRP_TASKS_DIR/$1/"
  else
    ls "$MRP_TASKS_DIR"
  fi
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

  vi "$path" || true
}

rmt() {
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

  rm "$path" || true
}

nt()  { local -; source new-task.sh    "$1"  || true; }
at()  { local -; source archive-task.sh "$@" || true; }
dt()  { local -; source delete-task.sh  "$@" || true; }
rt()  { local -; source rename-task.sh  "$@" || true; }
st()  { local -; source switch-task.sh  "$1" || true; }
ct()  { local -; source clear-task.sh         || true; }
nlt() { local -; source linear-task.sh  "$1" || true; }

_mrp_complete_task_files() {
  COMPREPLY=()
  local cur="${COMP_WORDS[COMP_CWORD]}"

  [[ -z "$MRP_TASKS_DIR" ]] && return 0

  local target_dir entry base
  if [[ -n "$MRP_TASK" ]]; then
    [[ $COMP_CWORD -eq 1 ]] || return 0
    target_dir="$MRP_TASKS_DIR/$MRP_TASK"
  else
    if [[ $COMP_CWORD -eq 1 ]]; then
      for entry in "$MRP_TASKS_DIR"/*/; do
        [[ -d "$entry" ]] || continue
        base="${entry%/}"
        base="${base##*/}"
        if [[ -z "$cur" || "$base" == "$cur"* ]]; then
          COMPREPLY+=( "$base" )
        fi
      done
      return 0
    elif [[ $COMP_CWORD -eq 2 ]]; then
      target_dir="$MRP_TASKS_DIR/${COMP_WORDS[1]}"
    else
      return 0
    fi
  fi

  [[ -d "$target_dir" ]] || return 0
  for entry in "$target_dir"/*; do
    [[ -e "$entry" ]] || continue
    base="${entry##*/}"
    if [[ -z "$cur" || "$base" == "$cur"* ]]; then
      COMPREPLY+=( "$base" )
    fi
  done
}

_mrp_complete_task_names() {
  COMPREPLY=()
  [[ $COMP_CWORD -eq 1 ]] || return 0
  [[ -z "$MRP_TASKS_DIR" ]] && return 0

  local cur="${COMP_WORDS[COMP_CWORD]}"
  local entry base
  for entry in "$MRP_TASKS_DIR"/*/; do
    [[ -d "$entry" ]] || continue
    base="${entry%/}"
    base="${base##*/}"
    [[ "$base" == ".archived-tasks" ]] && continue
    if [[ -z "$cur" || "$base" == "$cur"* ]]; then
      COMPREPLY+=( "$base" )
    fi
  done
}

complete -o filenames -F _mrp_complete_task_files glt vit rmt
complete -o filenames -F _mrp_complete_task_names st rt dt at
