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

### Codex

Install the PMem skill into your Codex skills directory:

```sh
codex_home=${CODEX_HOME:-"$HOME/.codex"}
mkdir -p "$codex_home/skills/pmem"
cp -R skills/pmem/. "$codex_home/skills/pmem/"
```

Verify:

```sh
codex_home=${CODEX_HOME:-"$HOME/.codex"}
test -f "$codex_home/skills/pmem/SKILL.md"
```

Restart Codex after installing or updating skills so the skill metadata is reloaded.

### Claude Code

Install as either a user skill or project skill.

User skill:

```sh
mkdir -p "$HOME/.claude/skills/pmem"
cp -R skills/pmem/. "$HOME/.claude/skills/pmem/"
```

Project skill:

```sh
mkdir -p .claude/skills/pmem
cp -R skills/pmem/. .claude/skills/pmem/
```

Verify:

```sh
test -f "$HOME/.claude/skills/pmem/SKILL.md" || test -f ".claude/skills/pmem/SKILL.md"
```

Restart Claude Code after installing or updating skills so the skill metadata is reloaded.

## Verify PMem CLI

The PMem skill expects the `pmem` CLI to be available when PMem context is needed.

```sh
command -v pmem
pmem -H
pmem doc list
```

Use `pmem -h`, `pmem <group> -h`, and `pmem <group> <command> -h` for current CLI behavior. The skill reference intentionally avoids hardcoding large CLI catalogs because live help and PMem built-in docs are the source of truth.

## Tests

Shell script tests should use ShellSpec and live under `test/` with paths mirroring the script path from the repository root.

```sh
shellspec
```

There are no substantive script tests yet because the current published skill is documentation-only.

## License

MIT. See [LICENSE](LICENSE).
