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
- `pmem kb exists --id <kb-id>`
- `pmem kb status --id <kb-id>`
- `pmem wi get --id <wi-id>`
- `pmem wi exists --id <wi-id>`
- `pmem wi status --id <wi-id>`
- `pmem link list --id <entity-id>`
- `pmem sync status`
- `pmem doc show doc_workflow_repo_local_mirror_sync`

Use narrower list filters when known. For filters, check command help instead of guessing flags, especially `pmem kb list -h` and `pmem wi list -h`.

Use `exists` when an explicit entity ID is already known and the only question is whether it resolves in the current project context. Use `status` when the only needed field is the current KB or WI status. Use `get` instead when content, metadata beyond status, links, history, or writeback safety could affect the next action.

For structured entity reads, use `--fields` when supported to keep JSON small:

- `pmem kb get --id <kb-id> --json --fields status,title,summary`
- `pmem wi get --id <wi-id> --json --fields status,title,summary`

For content replacement workflows, read the current Markdown first:

- `pmem kb get --id <kb-id> --content-only`
- `pmem wi get --id <wi-id> --content-only`

Historical versions are read-only and useful for audit or recovery context:

- `pmem kb history --id <kb-id>`
- `pmem wi history --id <wi-id>`

## Common Writebacks

Writebacks are explicit workflows. Do not run them as part of routine context loading.

Durable content should be correct, accurate, and dense. Before writing with
`--content-file`, check whether the target entity, document type, template, or
surface has a size limit; keep required context, constraints, evidence, and
verification ahead of narrative padding.

Normalize runtime user-identifying local data before it enters KB, WI, sync
draft, ticket, or review-note content. Replace usernames, home directories,
device names, cloud-sync paths, absolute machine-local repo paths, temporary
paths, and runtime-only local IDs with stable placeholders such as
`<user-home>`, `<repo-root>`, `<agent-home>`, `<sync-home>`, `<tmp-dir>`,
`<project-key>`, and `<entity-id>`. Do not store secrets, tokens, raw
identifying logs, or facts that belong only in source files.

Use live help before uncommon mutations:

- `pmem kb create -h`
- `pmem kb update -h`
- `pmem wi create -h`
- `pmem wi update -h`
- `pmem sync upload -h`
- `pmem sync discard -h`
- `pmem link <type> -h`
- `pmem link update -h`

Knowledge block creation:

```sh
pmem kb create \
  --type <rfc|note> \
  --subtype <subtype> \
  --authority <canonical|supporting|historical> \
  --status <status> \
  --anchor-type <project|work_item|module|path|external> \
  --anchor-id <anchor-id> \
  --title <title> \
  --summary <summary> \
  --content-file <path>
```

Knowledge block updates patch supplied metadata fields and leave omitted fields unchanged:

```sh
pmem kb update --id <kb-id> --summary <summary>
pmem kb update --id <kb-id> --content-file <path>
```

Supplying `--content` or `--content-file` replaces the whole KB content field. It does not append to, patch, or merge Markdown.

Prefer `--content-file` for content writes, especially when a sandbox or approval hook may inspect the command string. Reserve inline `--content` for short ad hoc content where a large command payload is not a concern.

Work item creation:

```sh
pmem wi create \
  --type <task|bug|spike|test|review|doc|story|milestone|epic> \
  --status <status> \
  --priority <priority> \
  --title <title> \
  --summary <summary> \
  --content-file <path>
```

Work item updates patch supplied metadata fields and leave omitted fields unchanged:

```sh
pmem wi update --id <wi-id> --summary <summary>
pmem wi update --id <wi-id> --blocked-reason <reason>
pmem wi update --id <wi-id> --content-file <path>
```

Supplying `--content` or `--content-file` replaces the whole WI content field. It does not append to, patch, or merge Markdown.

Prefer `--content-file` for content writes, especially when a sandbox or approval hook may inspect the command string. Reserve inline `--content` for short ad hoc content where a large command payload is not a concern.

Prefer lifecycle commands over raw status updates when changing only execution state:

- `pmem wi accept --id <wi-id>` sets accepted ready work.
- `pmem wi defer --id <wi-id>` moves work to backlog.
- `pmem wi start --id <wi-id>` marks active execution.
- `pmem wi review --id <wi-id>` marks completed work awaiting review or validation.
- `pmem wi block --id <wi-id> --reason <reason>` records a blocker.
- `pmem wi complete --id <wi-id>` marks done after acceptance criteria and verification are satisfied or explicitly waived.

Use link commands for relationships that affect retrieval, planning, execution, or validation:

```sh
pmem link depends-on --src-id <entity-id> --dst-id <entity-id>
pmem link remove --src-id <entity-id> --dst-id <entity-id> --link-type <type>
```

Other typed link add commands include `blocked-by`, `constrains`, `implements`, `references`, `supersedes`, and `validates`. Use `pmem link update` only for deliberate JSON replacement or delta workflows, and verify with `pmem link list --id <entity-id>`.

When changing tags, links, authority, status, parentage, priority, or blockers, verify the resulting entity state after the command. Use `--clear-tags` only when deleting all tags is intended.

Mirror draft upload is also a writeback path for existing KB and WI records:

```sh
pmem sync status
pmem sync upload --id <entity-id>
pmem sync upload --all
pmem sync upload --id <entity-id> --force
pmem sync discard --id <entity-id>
```

Use mirror upload only after reviewing the pending draft pair for the target entity:

- `<id>.content.tmp.md`
- `<id>.metadata.tmp.json`

Prefer `pmem sync upload --id <entity-id>` for agent-driven work. Use `--all` only when `pmem sync status` and draft review show every pending draft is intentionally in scope, including drafts that may be auto-uploaded by hooks. Use `--force` only after manually reconciling a conflicted draft. Use `pmem sync discard --id <entity-id>` when a pending draft should be removed instead of uploaded.

## Command Principles

- Use noun-first commands: `pmem <resource> <operation>`.
- Use `--cwd` when invoking PMem from outside the target project repo.
- Use `--verbose` only for explicit debugging.
- Use `--quiet` only when warnings are intentionally unwanted.
- Prefer `--content-file` over inline Markdown for non-trivial writeback.
- Treat create, update, upload, discard, lifecycle, and link mutation commands as explicit writeback workflows, not default context-loading behavior.
- Use `--yes` only when an authority-changing operation is intentional and already confirmed by user intent or workflow requirements.

## Mirror And Sync

The database/local engine is the source of truth. Mirror files are generated local projections for search, reading, and draft editing.

Use `pmem sync status` before relying on mirror freshness or uploading drafts. Use `pmem sync refresh` only when the workflow intentionally refreshes the mirror.

Mirror file roles:

- `<id>.content.md` and `<id>.metadata.json`: generated canonical cache files. Read/search them; do not edit them as the source of truth.
- `<id>.content.tmp.md` and `<id>.metadata.tmp.json`: pending draft pair for upload to an existing KB or WI.
- `<id>.sync.json`: local/server comparison state. Use sync commands instead of editing it.
- product-doc mirrors: read-only.

Mirror upload applies pending `*.content.tmp.md` and `*.metadata.tmp.json` drafts for existing KB and work-item entries. It does not create entities and should not be treated as a general write mechanism. Lifecycle, authority, type, subtype, anchor, parent, priority, blocked reason, links, attribution, users, actors, project membership, and audit history require explicit PMem CLI/API operations.

Pre-push auto-upload hooks may run `pmem sync upload --all`. Check `pmem sync status` before pushing when pending mirror drafts exist, because new or edited `.tmp` draft files can become durable PMem updates through that hook path.

## Local Read-Only Fallback

Use local fallback only when PMem reads fail and a sync-home or repo-local mirror exists. Local fallback is read-only and potentially stale.

Mirror files have three roles:

- `*.metadata.json`: generated structured metadata. Search here for title, summary, tags, subtype, authority, status, anchor, and timestamps.
- `*.content.md`: generated body content. Read this only after metadata indicates the entity is relevant or when content search is required.
- `*.sync.json`: local/server comparison state. Skip this for knowledge retrieval.

Prefer structured shell processing over ad hoc text matching for metadata. Use `jq` when available, or a small script that parses JSON. If an optional helper such as `rg` or `jq` is missing, skip only the dependent local-search path and use PMem CLI reads when available.

When using local fallback, say that the context came from local mirror data and freshness could not be verified without PMem connectivity.

## Entity Meaning

- A KB is durable project knowledge with type, subtype, authority, status, anchor, content, and relationships.
- A WI is bounded execution state with scope, acceptance criteria, verification, status, dependencies, and handoff.
- Do not use KBs as scratchpads. Use WIs for task execution state and KBs for reusable project knowledge.
