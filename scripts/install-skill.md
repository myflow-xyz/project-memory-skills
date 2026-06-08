# `scripts/install-skill.sh`

## Purpose

Install or update PMem skills for the currently supported agents: Codex and Claude Code.

The script exists to replace fragile manual copy snippets with a small, repeatable workflow that validates inputs, prints the destination before writing, and refuses to overwrite unmanaged existing skill directories.

## Behavior

- Installs files from `skills/<skill>/` into the selected agent skill directory.
- Defaults to `--skill pmem`.
- Requires `--agent codex` or `--agent claude`.
- Defaults to user scope.
- Supports Claude Code project scope with `--scope project`.
- Does not edit Codex config, Claude Code config, `CLAUDE.md`, or hook configuration.
- Writes a `.pmem-skills-install` marker file into destinations it manages.
- Treats an existing destination without the marker as a conflict and fails before copying.
- Re-running the same command updates a marked destination.
- Leaves extra files in a marked destination alone; it does not delete files removed from the source skill.

## Usage

Codex user skill:

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

Dry run:

```sh
scripts/install-skill.sh --agent codex --dry-run
```

Explicit destination:

```sh
scripts/install-skill.sh --agent claude --dest /path/to/skills/pmem
```

Verbose output:

```sh
scripts/install-skill.sh --agent codex --verbose
PMEM_SKILLS_VERBOSE=1 scripts/install-skill.sh --agent codex
```

## Default Destinations

- Codex user scope: `${CODEX_HOME:-$HOME/.codex}/skills/<skill>`
- Claude Code user scope: `$HOME/.claude/skills/<skill>`
- Claude Code project scope: `.claude/skills/<skill>`

`--dest` overrides the default destination and must point at the exact skill directory, not the parent `skills/` directory.

## Dependencies

Required commands:

- `cp`
- `mkdir`

The script checks each required command with `command <name>` and fails before mutation when one is missing.

## Recommendations

- Use `--dry-run` before installing into a real agent home.
- Prefer default destinations unless testing or installing into a custom agent home.
- Restart the target agent after installation so skill metadata is reloaded.
- Use project scope for Claude Code only when the skill should be local to the current repository.

## Limitations

- Only Codex and Claude Code are supported.
- Only `pmem` is expected to be useful until other skill directories are implemented.
- Codex project-scope install is unsupported.
- The script does not remove stale files from a managed destination.
- The marker proves the destination was created by this script; it does not preserve user edits inside managed files.

## Security Concerns

- The script writes only to the selected destination and creates only required directories.
- Existing unmanaged destinations fail closed to avoid overwriting user-managed files.
- No network access is used.
- No shell profile, global config, hook config, or agent config is edited.
- A malicious or incorrect `--dest` can still point at an unintended local path, so review the printed destination before confirming real installs.

## Future Improvement Backlog

- Add an explicit conflict resolution mode after the first installer is proven in use.
- Add checksum-aware updates if preserving user edits inside managed files becomes necessary.
- Add support for additional skills only after those skills are ready for public installation.
- Add hook installation separately, with config mutation owned by hook-specific scripts.

## Test Coverage Summary

ShellSpec coverage lives in `test/scripts/install-skill_spec.sh`.

Covered behavior:

- Codex user install.
- Claude Code user install.
- Claude Code project install.
- Dry run without mutation.
- Verbose output.
- Missing required agent argument.
- Missing dependency detection.
- Existing unmanaged destination conflict.
- Managed destination update.
