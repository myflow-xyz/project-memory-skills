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

## Install The PMem Skill

Use the installer script for repeatable local installation. It installs skill files only; it does not edit Codex config, Claude Code config, `CLAUDE.md`, or hook configuration.

Codex:

```sh
scripts/install-skill.sh --agent codex
```

Claude Code user skill:

```sh
scripts/install-skill.sh --agent claude
```

Claude Code project skill:

```sh
scripts/install-skill.sh --agent claude --scope project
```

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
test -f "$codex_home/skills/pmem/SKILL.md"
```

Claude Code user skill:

```sh
test -f "$HOME/.claude/skills/pmem/SKILL.md"
```

Claude Code project skill:

```sh
test -f ".claude/skills/pmem/SKILL.md"
```

### Manual Fallback

Manual copy still works when you need to inspect or customize the install:

```sh
dest="$HOME/.codex/skills/pmem"
mkdir -p "$dest"
cp -R skills/pmem/. "$dest/"
```

For Claude Code, use `$HOME/.claude/skills/pmem` or `.claude/skills/pmem` as the destination.

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
