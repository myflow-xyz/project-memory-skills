# Project Memory Skills

Project Memory Skills is a small collection of agent skills for using PMem / Project Memory in local coding workflows.

The repo is currently focused on Codex and Claude Code. Other agent compatibility is intentionally out of scope for now.

## Features

- `pmem` skill: teaches an agent when and how to load PMem knowledge blocks and explicit work items as project context.
- PMem-oriented conventions: concise default output, live CLI help, read-only local mirror fallback, and explicit writeback instead of silent memory mutation.

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

`skills/prun/SKILL.md` is currently a placeholder.

## Install Skills

Use the installer script for repeatable local installation. It installs skill files only; it does not edit Codex config, Claude Code config, `CLAUDE.md`, or hook configuration.

### Codex User Skill

Install the PMem skill into your Codex skills directory:

```sh
scripts/install-skill.sh --agent codex
```

Verify:

```sh
codex_home=${CODEX_HOME:-"$HOME/.codex"}
test -f "$codex_home/skills/pmem/SKILL.md"
```

Restart Codex after installing or updating skills so the skill metadata is reloaded.

### Claude Code User Skill

Install the PMem skill into your Claude Code user skills directory:

```sh
scripts/install-skill.sh --agent claude
```

Verify:

```sh
test -f "$HOME/.claude/skills/pmem/SKILL.md"
```

Restart Claude Code after installing or updating skills so the skill metadata is reloaded.

### Claude Code Project Skill

Install the PMem skill for the current repository:

```sh
scripts/install-skill.sh --agent claude --scope project
```

Verify:

```sh
test -f ".claude/skills/pmem/SKILL.md"
```

Restart Claude Code after installing or updating skills so the skill metadata is reloaded.

Use `scripts/install-skill.sh --dry-run` to preview the destination before writing. See [scripts/install-skill.md](scripts/install-skill.md) for options, behavior, safety constraints, and test coverage.

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
