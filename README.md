# Project Memory Skills

Project Memory Skills is a small collection of agent skills for using PMem / Project Memory in local coding workflows.

The repo is currently focused on Codex and Claude Code. Other agent compatibility is intentionally out of scope for now.

## Features

- `pmem` skill: teaches an agent when and how to load PMem knowledge blocks and explicit work items as project context.
- `prun` skill: starts an explicit agent run from PMem-backed runbooks, tickets, optional knowledge, and a message, then maintains a task-specific checklist through execution.
- PMem-oriented conventions: concise default output, live CLI help, read-only local mirror fallback, and explicit write/update workflows instead of silent memory mutation.

## Requirements

- Codex or Claude Code for the current skills.
- `pmem` CLI for PMem-backed context loading.
- ShellSpec for shell script tests.

## Repository Layout

```text
scripts/
  install-skill.sh
  install-skill.md
skills/
  pmem/
    SKILL.md
    references/cli.md
  prun/
    SKILL.md
test/
```

`prun` depends on the `pmem` skill because its runbooks, tickets, and knowledge inputs are PMem document or entity IDs.

## Install A Skill

Use the installer script for repeatable local installation. User-scope installs symlink the skill directory by default. Project-scope installs copy the skill directory by default and ask for confirmation. The script does not edit Codex config, Claude Code config, `CLAUDE.md`, or hook configuration.

Codex:

```sh
scripts/install-skill.sh --agent codex
```

Install `prun` instead of the default `pmem` skill:

```sh
scripts/install-skill.sh --agent codex --skill prun
```

Install both `pmem` and `prun` when using `prun`, because `prun` loads PMem-backed inputs through the PMem workflow.

Claude Code user skill:

```sh
scripts/install-skill.sh --agent claude
```

Claude Code project skill:

```sh
scripts/install-skill.sh --agent claude --scope project
```

Use `--yes` for non-interactive project-scope installs. Use `--mode copy` or `--mode symlink` to override the scope default.

Preview the destination without writing:

```sh
scripts/install-skill.sh --agent codex --dry-run
```

Restart the target agent after installing or updating skills so the skill metadata is reloaded.

See [scripts/install-skill.md](scripts/install-skill.md) for options, behavior, safety constraints, and test coverage.

### Verify Install

Codex:

```sh
codex_home=${CODEX_HOME:-"$HOME/.codex"}
skill=pmem # or prun
test -L "$codex_home/skills/$skill"
test -f "$codex_home/skills/$skill/SKILL.md"
```

Claude Code user skill:

```sh
skill=pmem # or prun
test -L "$HOME/.claude/skills/$skill"
test -f "$HOME/.claude/skills/$skill/SKILL.md"
```

Claude Code project skill:

```sh
skill=pmem # or prun
test ! -L ".claude/skills/$skill"
test -f ".claude/skills/$skill/SKILL.md"
```

### Manual Fallback

Manual install still works when you need to inspect or customize the install. User-scope symlink:

```sh
skill=pmem # or prun
dest_dir="$HOME/.codex/skills"
mkdir -p "$dest_dir"
ln -s "$(pwd -P)/skills/$skill" "$dest_dir/$skill"
```

Project-scope copy:

```sh
skill=pmem # or prun
dest_dir=".claude/skills/$skill"
mkdir -p "$dest_dir"
cp -R "skills/$skill/." "$dest_dir/"
```

For Claude Code, use `$HOME/.claude/skills/$skill` or `.claude/skills/$skill` as the destination.

## Verify PMem CLI

The PMem skill expects the `pmem` CLI to be available when PMem context is needed.

```sh
command -v pmem
pmem -H
pmem doc list
```

Use `pmem -h`, `pmem <group> -h`, and `pmem <group> <command> -h` for current CLI behavior. The skill reference intentionally avoids hardcoding large CLI catalogs because live help and PMem built-in docs are the source of truth.

## Tests

Shell script tests use ShellSpec and live under `test/` with paths mirroring the script path from the repository root.

```sh
shellspec
```

## License

MIT. See [LICENSE](LICENSE).
