# PMem CLI And Mirror Reference

Use this reference when the PMem workflow needs command orientation, mirror boundaries, or local fallback rules beyond the main skill body.

The current CLI can change faster than this skill. Prefer live help for exact flags and current behavior:

- `pmem -h`
- `pmem <group> -h`
- `pmem <group> <command> -h`
- `pmem doc list`
- `pmem doc show <doc-id-or-slug>`

## Built-In Docs

PMem includes built-in docs that clarify product concepts, entity semantics, workflows, and templates. Use `pmem doc list` to discover current docs and `pmem doc show <doc-id-or-slug>` to load one focused doc.

Main doc kinds:

- `guide`: product or entity overview and intended usage
- `term`: canonical vocabulary and entity semantics
- `workflow`: procedural guidance for PMem operations
- `template`: content scaffolds for KBs, WIs, and related records

## Common Reads

Use default PMem output for agent-facing reads. Add `--json` only when deterministic parsing or a helper script needs structured output.

Most common context reads:

- `pmem kb list`
- `pmem kb get --id <kb-id>`
- `pmem wi get --id <wi-id>`
- `pmem link list --id <entity-id>`
- `pmem sync status`

Use narrower list filters when known. For filters, check command help instead of guessing flags, especially `pmem kb list -h` and `pmem wi list -h`.

For structured entity reads, use `--fields` when supported to keep JSON small:

- `pmem kb get --id <kb-id> --json --fields status,title,summary`
- `pmem wi get --id <wi-id> --json --fields status,title,summary`

## Command Principles

- Use noun-first commands: `pmem <resource> <operation>`.
- Use `--cwd` when invoking PMem from outside the target project repo.
- Use `--verbose` only for explicit debugging.
- Use `--quiet` only when warnings are intentionally unwanted.
- Prefer `--content-file` over inline Markdown for non-trivial writeback, but remember the v1 skill does not write by default.
- Treat create, update, upload, discard, lifecycle, and link mutation commands as explicit writeback workflows, not default context-loading behavior.

## Mirror And Sync

The database/local engine is the source of truth. Mirror files are generated local projections for search, reading, and draft editing.

Use `pmem sync status` before relying on mirror freshness. Use `pmem sync refresh` only when the workflow intentionally refreshes the mirror.

Mirror upload does not create entities and should not be treated as a general write mechanism. Lifecycle, authority, type, subtype, anchor, parent, priority, blocked reason, links, attribution, users, actors, project membership, and audit history require explicit PMem CLI/API operations.

## Local Read-Only Fallback

Use local fallback only when PMem reads fail and a sync-home or repo-local mirror exists. Local fallback is read-only and potentially stale.

Mirror files have three roles:

- `*.metadata.json`: structured metadata. Search here for title, summary, tags, subtype, authority, status, anchor, and timestamps.
- `*.content.md`: body content. Read this only after metadata indicates the entity is relevant or when content search is required.
- `*.sync.json`: local/server comparison state. Skip this for knowledge retrieval.

Prefer structured shell processing over ad hoc text matching for metadata. Use `jq` when available, or a small script that parses JSON. If an optional helper such as `rg` or `jq` is missing, skip only the dependent local-search path and use PMem CLI reads when available.

When using local fallback, say that the context came from local mirror data and freshness could not be verified without PMem connectivity.

## Entity Meaning

- A KB is durable project knowledge with type, subtype, authority, status, anchor, content, and relationships.
- A WI is bounded execution state with scope, acceptance criteria, verification, status, dependencies, and handoff.
- Do not use KBs as scratchpads. Use WIs for task execution state and KBs for reusable project knowledge.
