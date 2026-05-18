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

_mrp_project_for_repo() {
  local repo_path="$1"
  local map_file="$HOME/.mrp-project-map"
  [[ -r "$map_file" ]] || return 1
  local line
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*\"([^\"]+)\"[[:space:]]*,[[:space:]]*\"([^\"]+)\"[[:space:]]*,[[:space:]]*\"([^\"]+)\"[[:space:]]*$ ]] || continue
    if [[ "${BASH_REMATCH[1]}" == "$repo_path" ]]; then
      echo "${BASH_REMATCH[2]}|${BASH_REMATCH[3]}"
      return 0
    fi
  done < "$map_file"
  return 1
}

_mrp_main_branch_for_project() {
  local project="$1"
  local map_file="$HOME/.mrp-project-map"
  [[ -r "$map_file" ]] || return 1
  local line
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*\"([^\"]+)\"[[:space:]]*,[[:space:]]*\"([^\"]+)\"[[:space:]]*,[[:space:]]*\"([^\"]+)\"[[:space:]]*$ ]] || continue
    if [[ "${BASH_REMATCH[2]}" == "$project" ]]; then
      echo "${BASH_REMATCH[3]}"
      return 0
    fi
  done < "$map_file"
  return 1
}

_mrp_resolve_context() {
  if [[ -n "${MRP_PROJECT:-}" && -n "${MRP_MAIN_BRANCH_NAME:-}" ]]; then
    return 0
  fi

  if [[ -n "${MRP_PROJECT:-}" ]]; then
    local main_branch
    main_branch=$(_mrp_main_branch_for_project "$MRP_PROJECT") || {
      echo "Error: project '$MRP_PROJECT' is not in ~/.mrp-project-map." >&2
      return 1
    }
    export MRP_MAIN_BRANCH_NAME="$main_branch"
    return 0
  fi

  local repo_path
  repo_path=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Error: not in a git repo and MRP_PROJECT is not set." >&2
    echo "Run from inside a mapped repo, or set MRP_PROJECT." >&2
    return 1
  }
  local info
  info=$(_mrp_project_for_repo "$repo_path") || {
    echo "Error: repo '$repo_path' is not in ~/.mrp-project-map." >&2
    echo "Add a line like: \"$repo_path\", \"<project_name>\", \"<main_branch>\"" >&2
    return 1
  }
  export MRP_PROJECT="${info%%|*}"
  export MRP_MAIN_BRANCH_NAME="${info##*|}"
}

tasks() {
  if [[ -z "${MRP_TASKS_DIR:-}" ]]; then
    echo "MRP_TASKS_DIR is not set." >&2
    return 1
  fi

  _mrp_resolve_context || return 1

  local entry base prefix
  for entry in "$MRP_TASKS_DIR/$MRP_PROJECT"/*/; do
    [[ -d "$entry" ]] || continue
    base="${entry%/}"
    base="${base##*/}"

    if [[ -n "$MRP_TASK" ]]; then
      if [[ "$base" == "$MRP_TASK" ]]; then
        prefix="(*) "
      else
        prefix="    "
      fi
      echo "${prefix}${base}"
    else
      echo "$base"
    fi
  done
}

lst() {
  if [[ -z "${MRP_TASKS_DIR:-}" ]]; then
    echo "MRP_TASKS_DIR is not set." >&2
    return 1
  fi

  _mrp_resolve_context || return 1

  if [[ -n "$MRP_TASK" ]]; then
    echo "Task directory contents for $MRP_TASK:"
    ls "$MRP_TASKS_DIR/$MRP_PROJECT/$MRP_TASK/"
  elif [[ $# -ge 1 ]]; then
    ls "$MRP_TASKS_DIR/$MRP_PROJECT/$1/"
  else
    ls "$MRP_TASKS_DIR/$MRP_PROJECT/"
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

  _mrp_resolve_context || return 1

  local path="$MRP_TASKS_DIR/$MRP_PROJECT/$task/$file"
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

  _mrp_resolve_context || return 1

  local task_dir="$MRP_TASKS_DIR/$MRP_PROJECT/$task"
  local path="$task_dir/$file"
  if [[ ! -f "$path" && ! -d "$task_dir" ]]; then
    echo "Task not found: $task_dir" >&2
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

  _mrp_resolve_context || return 1

  local path="$MRP_TASKS_DIR/$MRP_PROJECT/$task/$file"
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

  _mrp_resolve_context 2>/dev/null || return 0

  local target_dir entry base
  if [[ -n "$MRP_TASK" ]]; then
    [[ $COMP_CWORD -eq 1 ]] || return 0
    target_dir="$MRP_TASKS_DIR/$MRP_PROJECT/$MRP_TASK"
  else
    if [[ $COMP_CWORD -eq 1 ]]; then
      for entry in "$MRP_TASKS_DIR/$MRP_PROJECT"/*/; do
        [[ -d "$entry" ]] || continue
        base="${entry%/}"
        base="${base##*/}"
        if [[ -z "$cur" || "$base" == "$cur"* ]]; then
          COMPREPLY+=( "$base" )
        fi
      done
      return 0
    elif [[ $COMP_CWORD -eq 2 ]]; then
      target_dir="$MRP_TASKS_DIR/$MRP_PROJECT/${COMP_WORDS[1]}"
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

  _mrp_resolve_context 2>/dev/null || return 0

  local cur="${COMP_WORDS[COMP_CWORD]}"
  local entry base
  for entry in "$MRP_TASKS_DIR/$MRP_PROJECT"/*/; do
    [[ -d "$entry" ]] || continue
    base="${entry%/}"
    base="${base##*/}"
    if [[ -z "$cur" || "$base" == "$cur"* ]]; then
      COMPREPLY+=( "$base" )
    fi
  done
}

complete -o filenames -F _mrp_complete_task_files glt vit rmt
complete -o filenames -F _mrp_complete_task_names st rt dt at
