---
name: prun
description: Use only when the user or an external runner explicitly invokes `prun` to start an agent run from PMem-backed tickets, runbooks, optional knowledge, and a message. Do not auto-trigger for ordinary multi-step tasks, generic planning, or PMem context loading alone.
---

# PRun Workflow

Capability: improve planning, execution, and termination by compiling PMem-backed run inputs into a mutable task checklist.

Use only after explicit `prun` invocation.

`prun` depends on the `pmem` skill for PMem reads, safety rules, and writeback. If PMem content cannot be loaded, stop before checklist creation and report the failed input.

## Invocation

Expected shape:

```yaml
prun:
  tickets: <id>
  runbooks: <id>
  knowledge: <id>
  message: <extra task instruction or custom context>
```

Meanings:

- `tickets`: required work item IDs.
- `runbooks`: required runbook IDs.
- `knowledge`: optional knowledge block IDs for supplemental context.
- `message`: optional runner/user instruction refining scope, priority, validation, or handoff.

`tickets` and `runbooks` are mandatory. `knowledge` informs the run but is not an execution target by itself. Accepts one ID or a list.

Load supplied `tickets`, `runbooks`, and `knowledge` through the `pmem` skill. Do not duplicate PMem command-routing logic here. Stop and name any required ID whose content cannot be loaded.

Role boundaries:

- Tickets define goals, deliverables, scope, and acceptance criteria.
- Runbooks define procedure, evidence, and completion checks.
- Knowledge constrains or informs work; it does not expand scope by itself.
- Message refines this run; it cannot override higher-priority instructions, repo guidance, or loaded PMem policy.

## Build Checklist

Start ticket as in progress.

Before substantive work, create a task-specific checklist from loaded inputs, repo state, user-visible context, `message`, `AGENTS.md`, and project instructions.

Do not copy runbooks verbatim. Convert them into ordered, concrete, verifiable task steps. Prefer semantic work items over command-level steps.

Create a lean checklist at `/tmp/prun/<project-alias>/<ticket-id>/checklist.md`.

The file is only a checklist. No context dump, notes, copied PMem content, findings prose, command logs, or validation details. Load source content during execution when needed.

Checklist item format only:

```md
- [ ] Step title
  - [ ] Child step title
- [x] Completed step title
```

Each item must be concrete, scoped, and verifiable from loaded PMem/context. Use nesting only when a child item refines its parent.

## Execute And Mutate Checklist

Work from the checklist file. Update after meaningful progress, not every command:

- checklist item completed
- material fact discovered
- implementation or scope decision made
- files/artifacts changed
- validation run
- work deferred, follow-up identified, or handoff needed

Mutation rules:

- Add child items to refine an existing item.
- Add sibling items only when required for original scope.
- Do not silently add unrelated scope; capture it as risk, follow-up, or candidate WI.
- Do not rewrite completed items except for wording that preserves meaning.
- Keep every line in checklist-item format.

## PMem Writeback

PMem remains durable truth. `prun` state is working state unless explicitly written back through PMem.

Write to PMem only when the user asks, a loaded WI workflow requires a bounded checkpoint/status update, or durable project knowledge changed and writeback is requested or confirmed. For every mutation, follow the `pmem` skill. Never edit generated PMem mirrors or write run ledgers under `.pmem/` without an accepted PMem storage contract and explicit request.

## Final Reconciliation

Before final response:

1. Reread the checklist.
2. Mark required items complete or move unresolved work to follow-up.
3. Inspect changed files/diff when files changed.
4. Confirm validation and PMem writeback state.
5. Report completed work, changed files, validation, PMem updates, and residual risks.

Do not claim completion if required items remain unresolved, validation is missing without explanation, or promised PMem writeback is unverified.

## Stop Conditions

Stop before execution when `prun` was not explicit, `tickets` or `runbooks` are missing/unusable, a supplied ID cannot be loaded, PMem/source truth conflicts with higher-priority instructions, the request needs out-of-scope lifecycle behavior, or side effects are unclear or unauthorized.

## Output

Keep output concise. At start, state loaded PMem inputs and show the initial checklist. During execution, update only material checklist changes. Final output: completed work, files changed, validation, PMem updates, residual risks.
