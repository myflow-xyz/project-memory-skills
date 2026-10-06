# PMem CLI Reference

Common examples for the methods in `SKILL.md`. Use live help and built-in docs for other operations, accepted values, and options. Replace angle-bracket placeholders before running commands.

## Help And Output

```sh
pmem -h
pmem <group> [<command>] -h
pmem doc list
pmem doc show <doc-id-or-slug>
pmem doc show doc_term_work_item
pmem doc show doc_term_knowledge_block
```

`doc show` accepts a doc ID or slug from the list. Select the template matching the intended KB or WI type, then adapt it to the actual content; omit irrelevant sections and example text.

## Notation

`<entity>` = `kb` or `wi`; `<entity-id>` = matching KB/WI ID. Examples use docs shorthand, not literal shell syntax.

## Built-In Docs

Use built-in docs for current concepts, workflows, and content templates. Main kinds are `guide`, `term`, `workflow`, and `template`. Common starting points:

## Reads

Use ordinary output by default. Narrow requests with applicable filters and request only required metadata fields where supported. Use JSON only when required by the command or consumer, or preferred by the user. The current `kb get` command requires `--json` with `--fields`; `kb list` does not support `--fields`. Check the relevant command's help before using other combinations.

```sh
pmem <entity> list
pmem <entity> [get|exists|status|history] -I <entity-id>
pmem <entity> get -I <entity-id> --content-only
pmem <entity> get -I <entity-id> --json --fields status,title,summary
pmem link list -I <entity-id>
```

## Anchor Selection

| Type | Use |
| --- | --- |
| `project` | Shared principles, constraints, architecture, and cross-module guidance; ID is the project alias. |
| `module` | Reusable subsystem knowledge, including test and verification guidance; use an existing durable capability ID from the module index or KB metadata. |
| `path` | Rules about a specific file or directory itself; ID is a repo-relative path. Avoid using it merely because knowledge is implemented there. |
| `work_item` | Bounded task findings or evidence; ID is the work item public ID. |
| `external` | Knowledge scoped to an identifiable external source recorded in content or metadata; use a stable source identifier, not a topic name alone. |

Prefer module anchors when knowledge should survive directory changes. Keep reusable contracts module-scoped after their originating tickets close and preserve provenance through links. An anchor-only update must preserve content, authority, and lifecycle state.

## Discovery And Reads

Commands use the repo's project binding. `--project-id <project-id>` selects the owning PMem project when needed. Anchor filters select guidance within that project: `<project-key>` is its alias, and `<module-id>` is an existing module anchor ID.

```sh
pmem kb list -s active --anchor-type project --anchor-id <project-key>
pmem kb list -s active --anchor-type module --anchor-id <module-id>
pmem entity search "<task topic>" --source remote --corpus kb -s active --anchor-type module --anchor-id <module-id>
```

Use applicable type, authority, tag, and topic filters to narrow discovery while retaining required project guidance. Follow list cursors or Search offsets when more results are needed. Anchor-filtered Search requires the remote source; local Search rejects anchor filters. If no module ID is known, search the bound project's KBs without anchor filters and inspect matching metadata to resolve existing anchors.

Review candidate metadata before loading a body. Compact default reads can omit summaries and other needed metadata:

```sh
pmem kb get -I <kb-id> --json --fields title,summary,authority,status
```

Add fields such as `anchor_type,anchor_id` only when needed. Keep `content` out of metadata projections. Once a KB is selected, read its body separately:

```sh
pmem kb get -I <kb-id> --content-only
```

Use `--content-only` without `--fields` or `--json`. For known IDs, use `exists` or `status` when sufficient. For WIs already in scope, the same distinction applies between metadata checks and content reads:

```sh
pmem wi status -I <wi-id>
pmem wi get -I <wi-id> --content-only
```

## Common Writes

Run mutations only within the authorization described in `SKILL.md`. Use `--yes` only when the guarded mutation is already authorized.

### Create KBs And WIs

Choose proper type, authority, lifecycle state, priority, and anchor deliberately using the built-in docs. Supply a reviewed content file and concise change message. These examples show the common creation fields:

```sh
pmem kb create \
  -t <principle|standard|constraint|adr|design_contract|plan|spec|record> \
  --authority <canonical|supporting|historical> \
  --anchor-type <project|work_item|module|path|external> \
  --anchor-id <anchor-id> \
  -T "<title>" \
  -S "<summary>" \
  -s <status> \
  --content-file <path/content.md> \
  -l "<changelog>"
```

```sh
pmem wi create \
  -t <task|bug|spike|test|review|doc|story|milestone|epic> \
  --priority <priority> \
  -T "<title>" \
  -S "<summary>" \
  -s <status> \
  --content-file <path/content.md> \
  -l "<changelog>"
```

Add `--parent-id <wi-id>` when the new WI belongs to an existing parent. Use the returned entity ID to verify the saved metadata and read the body separately with `--content-only`.

### Update Content

Before updating, inspect the current fields being changed and metadata that affects safety. For a content update, read the existing body separately and prepare the complete replacement in a file. `--content-file` replaces the whole body; include a concise change message and verify the persisted content afterward:

```sh
pmem <entity> update -I <entity-id> -S "<summary>"
pmem wi update -I <wi-id> --blocked-reason "<reason>"
pmem kb update -I <kb-id> --content-file <path/replacement.md> -l "<change-message>"
pmem kb update -I <kb-id> --anchor-type module --anchor-id <module-id>
pmem kb get -I <kb-id> --content-only
```

The same content-file and change-message pattern applies to `pmem wi update`. Check help for metadata-only updates and their supported fields.

### WI Lifecycle Commands

For state-only changes, prefer the corresponding lifecycle command:

| Command | Resulting status |
| --- | --- |
| `pmem wi defer -I <wi-id>` | `backlog` |
| `pmem wi accept -I <wi-id>` | `todo` |
| `pmem wi start -I <wi-id>` | `in_progress` |
| `pmem wi review -I <wi-id>` | `review` |
| `pmem wi block -I <wi-id> --reason "<reason>"` | `blocked` |
| `pmem wi complete -I <wi-id>` | `done` |

Choose the intended transition and verify its result:

```sh
pmem wi status -I <wi-id>
```

## Links

Common typed commands are `references`, `implements`, `validates`, `depends-on`, `blocked-by`, `constrains`, and `supersedes`. Choose the relationship and its direction deliberately: `--src-id` is the source and `--dst-id` is the target. For example, add a reference and verify it:

```sh
pmem link <link-type> --src-id <source-entity-id> --dst-id <target-entity-id>
```

To remove an explicitly selected relationship, provide the exact source, target, and type:

```sh
pmem link remove --src-id <source-id> --dst-id <target-id> --link-type <link-type>
pmem link list -I <source-id>
```

Use `pmem link update` only for a deliberate, reviewed link-set replacement or delta. Consult its help for supported input options and verify the resulting links afterward.

## Mirrors And Drafts

When mirror discovery needs fresh data and the API is available, refresh and inspect the reported project/cache location:

```sh
pmem sync refresh
pmem sync status --local
```

Use the reported `project_id` and `cache_root` rather than guessing paths. KB projections live under `kb/<type>/` and WI projections under `wi/<type>/` within the cache root. Files are paired by entity ID:

| File | Read purpose |
| --- | --- |
| `<id>.metadata.json` | Title, summary, type, status, tags, update time, and entity-specific fields such as KB authority/anchor or WI priority. Inspect these first for relevance and state. |
| `<id>.content.md` | Full Markdown body. Read after selecting relevant metadata or when body search is necessary. |

These files are read-only projections, not writeback inputs. If live reads fail, local fallback is read-only and its freshness must be reported as unverified. See `pmem doc show doc_workflow_local_mirror_sync` for current cache and draft behavior.

Upload only reviewed, authorized pending drafts created through explicit PMem writes. Check status first and select the intended draft or entity; stop for conflicts or rejected drafts:

```sh
pmem sync status
pmem sync upload --id <entity-id-or-draft-id>
```

Refresh pulls data; upload replays pending drafts. Neither operation imports direct edits to mirror files. Consult help for other sync operations.
