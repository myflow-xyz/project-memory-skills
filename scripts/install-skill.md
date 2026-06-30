# `scripts/install-skill.sh`

## Purpose

Install or update PMem skills for the currently supported agents: Codex and Claude Code.

The script exists to replace fragile manual install snippets with a small, repeatable workflow that validates inputs, prints the destination before writing, and refuses to overwrite unmanaged existing skill paths.

## Behavior

- Installs the entire `skills/<skill>/` directory tree into the selected agent skill directory, including supporting references or scripts.
- Defaults to symlink mode for user scope.
- Defaults to copy mode for project scope.
- Supports explicit `--mode copy|symlink` overrides.
- Defaults to `--skill pmem`.
- Supports installing implemented skills under `skills/<skill>/`, including `pmem` and `prun`.
- Requires `--agent codex` or `--agent claude`.
- Defaults to user scope.
- Supports Claude Code project scope with `--scope project`.
- Requires confirmation for project-scope writes unless `--yes` is provided.
- Does not edit Codex config, Claude Code config, `CLAUDE.md`, or hook configuration.
- Treats an existing symlink to the same source skill directory as already managed.
- Treats an existing marked copy destination as managed in copy mode.
- Migrates between managed symlink and copy installs when the selected mode changes.
- Treats unmanaged directories, files, or symlinks to other locations as conflicts and fails before mutation.
- Re-running the same command verifies or refreshes the managed destination.

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

Non-interactive project-scope install:

```sh
scripts/install-skill.sh --agent claude --scope project --yes
```

Dry run:

```sh
scripts/install-skill.sh --agent codex --dry-run
```

Install `prun`:

```sh
scripts/install-skill.sh --agent codex --skill prun
```

Force copy mode:

```sh
scripts/install-skill.sh --agent codex --skill prun --mode copy
```

Force symlink mode:

```sh
scripts/install-skill.sh --agent claude --scope project --skill prun --mode symlink --yes
```

Explicit destination:

```sh
scripts/install-skill.sh --agent claude --skill prun --dest /path/to/skills/prun
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
- `ln`
- `mkdir`
- `rm`

The script checks each required command with `command <name>` and fails before mutation when one is missing.

## Recommendations

- Use `--dry-run` before installing into a real agent home.
- Prefer default destinations unless testing or installing into a custom agent home.
- Prefer default install modes unless you have a specific portability or live-editing reason.
- Restart the target agent after installation so skill metadata is reloaded.
- Use project scope for Claude Code only when the skill should be local to the current repository.

## Limitations

- Only Codex and Claude Code are supported.
- Codex project-scope install is unsupported.
- User-scope symlink installs read live files from this repository.
- Project-scope copy installs are snapshots and must be rerun to pick up source changes.
- Moving or deleting this repository breaks existing symlink installs until they are recreated.
- Migrating an older marked copy destination removes that managed copy; the old marker does not preserve user edits inside managed files.

## Security Concerns

- The script writes only the selected destination and creates only required parent directories.
- Existing unmanaged destinations fail closed to avoid overwriting user-managed files.
- Symlink-installed agents read whatever the source skill directory contains after installation.
- Project-scope writes require interactive confirmation or `--yes`.
- No network access is used.
- No shell profile, global config, hook config, or agent config is edited.
- A malicious or incorrect `--dest` can still point at an unintended local path, so review the printed destination before confirming real installs.

## Future Improvement Backlog

- Add an explicit conflict resolution mode after the first installer is proven in use.
- Add explicit relink support if moving a trusted checkout becomes common.
- Add support for additional skills only after those skills are ready for public installation.
- Add hook installation separately, with config mutation owned by hook-specific scripts.

## Test Coverage Summary

ShellSpec coverage lives in `test/scripts/install-skill_spec.sh`.

Covered behavior:

- User-scope default symlink install.
- Codex user install for `prun`.
- Nested files under the selected skill directory.
- Project-scope default copy install.
- Explicit copy and symlink modes.
- Migration between older managed copy and symlink installs.
- Project-scope confirmation requirement.
- Dry run without mutation.
- Verbose output.
- Missing required agent argument.
- Missing dependency detection.
- Existing unmanaged destination conflict.
- Managed destination update.
