# PMem CLI And Mirror Reference

Use when the PMem workflow needs CLI orientation, writeback mechanics, mirror boundaries, or local fallback rules beyond `SKILL.md`.

Live sources beat this reference:

```sh
pmem -h
pmem <group> [<command>] -h
pmem doc list
pmem doc show <doc-id-or-slug>
```

## Notation

`<entity>` = `kb` or `wi`; `<entity-id>` = matching KB/WI ID. Examples use docs shorthand, not literal shell syntax.

## Built-In Docs

Use built-in docs for current concepts, workflows, and templates.
Main kinds: `guide`, `term`, `workflow`, `template`.
Useful focused docs: `doc_term_knowledge_block`, `doc_term_work_item`.

## Reads

Use default output for agent reads. Add `--json` only for deterministic parsing; add `--fields` when supported.

```sh
pmem <entity> list
pmem <entity> [get|exists|status|history] -I <entity-id>
pmem <entity> get -I <entity-id> --content-only
pmem <entity> get -I <entity-id> --json --fields status,title,summary
pmem link list -I <entity-id>
```

Check list filters with `pmem <entity> list -h`; do not guess flags.
Use `exists` for known-ID resolution, `status` for lifecycle only, and `get` when content, metadata, links, history, or writeback safety can affect the decision.

## Writebacks

Mutations are explicit workflows, not context loading. Read the current entity before updates; verify changed state after create, update, upload, discard, lifecycle, and link mutations.

Flags: use `--cwd` outside the target repo, `--verbose` only for explicit debugging, `--quiet` only when warnings are intentionally unwanted, and `--yes` only after confirmed authority-changing intent.

```sh
pmem <entity> [create|update] -h
pmem sync [upload|discard] -h
pmem link <type> -h
pmem link update -h
```

Content rules: use `--content-file` for non-trivial content; inline `--content` only for short ad hoc text. `--content` and `--content-file` replace the whole content field, never append or merge. Include `-l "<changelog>"` for content-bearing creates and updates; treat it as required for content updates.

Durable content should be correct, accurate, dense, and within any entity, document-type, template, or target-surface size limit. Normalize local identifying data to stable placeholders such as `$REPO/`, `/tmp/`. Never store secrets, tokens, raw identifying logs, or facts that belong only in source files.

Create examples:

```sh
pmem kb create -t <principle|standard|constraint|adr|design_contract|plan|spec|record> \
  --authority <canonical|supporting|historical> \
  --anchor-type <project|work_item|module|path|external> \
  --anchor-id <anchor-id> \
  -T <title> \
  -S <summary> \
  -s <status> \
  --content-file <path> \
  -l "<changelog>"
```

```sh
pmem wi create \
  -t <task|bug|spike|test|review|doc|story|milestone|epic> \
  --priority <priority> \
  -T <title> \
  -S <summary> \
  -s <status> \
  --content-file <path> \
  -l "<changelog>"
```

Update examples:

```sh
pmem <entity> update -I <entity-id> -S <summary>
pmem <entity> update -I <entity-id> --content-file <path> -l "<changelog>"
pmem wi update -I <wi-id> --blocked-reason <reason>
```

Prefer WI lifecycle commands over raw status updates when only execution state changes:
- `pmem wi <lifecycle-command> -I <wi-id> [--reason <reason>]`
    - `defer` -> `backlog`
    - `accept` -> `todo`
    - `start` -> `in_progress`
    - `review` -> `review`
    - `block --reason <reason>` -> `blocked`
    - `complete` -> `done`

Links:

```sh
pmem link <blocked-by|constrains|depends-on|implements|references|supersedes|validates> --src-id <entity-id> --dst-id <entity-id>
pmem link remove --src-id <entity-id> --dst-id <entity-id> --link-type <type>
```

Use `pmem link update` only for deliberate JSON replacement or delta workflows. Verify links with `pmem link list -I <entity-id>`.

Sync upload is a writeback path only for pending SQLite outbox drafts from explicit PMem CLI/API input, such as existing KB/WI updates or offline WI creates. It does not import edited projection files, create KBs, or replace lifecycle, link, authority, type, anchor, parent, priority, blocker, attribution, user, actor, project-membership, or audit-history operations.

```sh
pmem sync status
pmem sync upload --id <entity-id>
pmem sync discard --id <entity-id> [-n <count>]
```

Use `sync status` first; upload only selected drafts that are in scope and not conflicted or rejected.
Use `--force` only after manually reconciling a conflicted draft.
Use `discard --id` when a pending draft should be removed instead of uploaded.

## Mirror And Fallback

Server database is the source of truth. Local SQLite owns the mirror cache, projection health, and pending outbox. Projection files are for search, reading, and review; direct edits are drift, not durable PMem input.

File roles:

- `<id>.metadata.json`: generated metadata; search title, summary, tags, type, authority, status, anchor, and timestamps.
- `<id>.content.md`: generated body content; read after metadata is relevant or content search is required.

`pmem sync refresh` is pull-only. `pmem sync status` is observe-only. `pmem sync upload` replays selected SQLite outbox rows; it does not upload projection edits.

Use local fallback only when PMem reads fail and a mirror exists. Treat fallback as read-only and possibly stale, prefer structured JSON parsing (`jq` when available), and report that freshness was not verified.
