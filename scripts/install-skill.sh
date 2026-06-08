#!/bin/sh
set -eu

program=${0##*/}
managed_by=pmem-skills
marker_name=.pmem-skills-install

agent=
scope=
skill=pmem
dest=
dry_run=0
verbose=${PMEM_SKILLS_VERBOSE:-0}

usage() {
  printf '%s\n' \
    "Usage: $program --agent codex|claude [--skill pmem] [--scope user|project] [--dest PATH] [--dry-run] [--verbose]" \
    "" \
    "Install or update a PMem skill for a supported agent." \
    "" \
    "Options:" \
    "  --agent NAME       Required. Supported values: codex, claude." \
    "  --skill NAME       Skill to install. Default: pmem." \
    "  --scope SCOPE      Install scope. Codex supports user. Claude supports user and project. Default: user." \
    "  --dest PATH        Exact destination skill directory. Overrides the default destination." \
    "  --dry-run          Print the planned action without writing files." \
    "  --verbose          Print source, scope, and destination details." \
    "  -h, --help         Show this help."
}

fail() {
  printf '%s: %s\n' "$program" "$*" >&2
  exit 1
}

need_arg() {
  [ $# -ge 2 ] || fail "$1 requires a value"
}

need_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    fail "missing required command '$1'. Install '$1' and retry."
  fi
}

is_verbose() {
  case "$verbose" in
  1 | true | TRUE | yes | YES | on | ON) return 0 ;;
  *) return 1 ;;
  esac
}

while [ $# -gt 0 ]; do
  case "$1" in
  --agent)
    need_arg "$1" "$@"
    agent=$2
    shift 2
    ;;
  --agent=*)
    agent=${1#*=}
    shift
    ;;
  --skill)
    need_arg "$1" "$@"
    skill=$2
    shift 2
    ;;
  --skill=*)
    skill=${1#*=}
    shift
    ;;
  --scope)
    need_arg "$1" "$@"
    scope=$2
    shift 2
    ;;
  --scope=*)
    scope=${1#*=}
    shift
    ;;
  --dest)
    need_arg "$1" "$@"
    dest=$2
    shift 2
    ;;
  --dest=*)
    dest=${1#*=}
    shift
    ;;
  --dry-run)
    dry_run=1
    shift
    ;;
  --verbose)
    verbose=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    fail "unknown argument: $1"
    ;;
  esac
done

[ -n "$agent" ] || fail "missing --agent. Use --agent codex or --agent claude."

case "$agent" in
codex | claude) ;;
*) fail "unsupported agent '$agent'. Supported agents: codex, claude." ;;
esac

case "$skill" in
'' | *[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-]*)
  fail "invalid skill '$skill'. Use only letters, numbers, underscore, and hyphen."
  ;;
esac

if [ -z "$scope" ]; then
  scope=user
fi

case "$agent:$scope" in
codex:user | claude:user | claude:project) ;;
codex:project) fail "Codex project-scope skill installation is not supported in this script." ;;
*) fail "unsupported scope '$scope' for agent '$agent'." ;;
esac

need_command cp
need_command mkdir

script_dir=${0%/*}
if [ "$script_dir" = "$0" ]; then
  script_dir=.
fi

repo_root=$(unset CDPATH && cd "$script_dir/.." && command pwd -P) || fail "could not resolve repository root"
source_dir=$repo_root/skills/$skill

[ -d "$source_dir" ] || fail "skill '$skill' not found at $source_dir"
[ -f "$source_dir/SKILL.md" ] || fail "skill '$skill' is missing SKILL.md at $source_dir"

if [ -z "$dest" ]; then
  case "$agent:$scope" in
  codex:user)
    codex_home=${CODEX_HOME:-}
    if [ -z "$codex_home" ]; then
      [ -n "${HOME:-}" ] || fail "HOME is not set and CODEX_HOME was not provided."
      codex_home=$HOME/.codex
    fi
    dest=$codex_home/skills/$skill
    ;;
  claude:user)
    [ -n "${HOME:-}" ] || fail "HOME is not set. Use --dest to provide an explicit Claude Code skill destination."
    claude_home=$HOME/.claude
    dest=$claude_home/skills/$skill
    ;;
  claude:project)
    dest=.claude/skills/$skill
    ;;
  esac
fi

[ -n "$dest" ] || fail "empty destination path"

marker=$dest/$marker_name
action=install

if [ -e "$dest" ] && [ ! -d "$dest" ]; then
  fail "destination exists but is not a directory: $dest"
fi

if [ -d "$dest" ]; then
  action=update
  [ -f "$marker" ] || fail "destination exists but is not managed by $managed_by: $dest. Choose a different --dest or move the directory explicitly."

  marker_managed_by=
  marker_agent=
  marker_scope=
  marker_skill=
  while IFS='=' read -r key value; do
    case "$key" in
    managed_by) marker_managed_by=$value ;;
    agent) marker_agent=$value ;;
    scope) marker_scope=$value ;;
    skill) marker_skill=$value ;;
    esac
  done <"$marker"

  [ "$marker_managed_by" = "$managed_by" ] || fail "destination marker is not managed by $managed_by: $marker"
  [ "$marker_agent" = "$agent" ] || fail "destination marker agent '$marker_agent' does not match requested agent '$agent'"
  [ "$marker_scope" = "$scope" ] || fail "destination marker scope '$marker_scope' does not match requested scope '$scope'"
  [ "$marker_skill" = "$skill" ] || fail "destination marker skill '$marker_skill' does not match requested skill '$skill'"
fi

if [ "$dry_run" -eq 1 ]; then
  printf 'dry-run action=%s agent=%s scope=%s skill=%s dest=%s\n' "$action" "$agent" "$scope" "$skill" "$dest"
  if is_verbose; then
    printf 'source=%s scope=%s\n' "$source_dir" "$scope"
  fi
  exit 0
fi

printf 'action=%s agent=%s scope=%s skill=%s dest=%s\n' "$action" "$agent" "$scope" "$skill" "$dest"
if is_verbose; then
  printf 'source=%s scope=%s\n' "$source_dir" "$scope"
fi

command mkdir -p "$dest"
{
  printf 'managed_by=%s\n' "$managed_by"
  printf 'agent=%s\n' "$agent"
  printf 'scope=%s\n' "$scope"
  printf 'skill=%s\n' "$skill"
} >"$marker"
command cp -R "$source_dir/." "$dest/" || fail "failed to copy skill files from $source_dir to $dest"

printf 'ok\n'
