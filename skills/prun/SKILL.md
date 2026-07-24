---
name: prun
description: Use only when the user or an external runner explicitly invokes `prun` to start an agent run from PMem-backed work tickets and runbooks, plus optional test tickets, knowledge, and a message. Do not auto-trigger for ordinary multi-step tasks, generic planning, or PMem context loading alone.
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
  tests: <id>
  knowledge: <id>
  message: <extra task instruction or custom context>
```

Meanings:

- `tickets`: required work item IDs.
- `runbooks`: required runbook IDs.
- `tests`: optional test work item IDs whose verification work is required for this run.
- `knowledge`: optional knowledge block IDs for supplemental context.
- `message`: optional runner/user instruction refining scope, priority, validation, or handoff.

`tickets` and `runbooks` are mandatory. `tests`, `knowledge`, and `message` are optional. Each ID-bearing field accepts one ID or a list.

Supplying `tests` makes every referenced test ticket and its acceptance criteria required run scope. It emphasizes test work; it does not replace validation already required by tickets, runbooks, or repository policy. `knowledge` informs the run but is not an execution target by itself.

Load supplied `tickets`, `runbooks`, `tests`, and `knowledge` through the `pmem` skill. Do not duplicate PMem command-routing logic here. Require each `tests` ID to resolve to a work item of type `test`. Stop and name any supplied ID that cannot be loaded or has the wrong entity type.

Role boundaries:

- Tickets define goals, deliverables, scope, and acceptance criteria.
- Test tickets define mandatory verification deliverables, test cases, test levels, and evidence for in-scope behavior; they do not independently expand product behavior.
- Runbooks define procedure, evidence, and completion checks.
- Knowledge constrains or informs work; it does not expand scope by itself.
- Message refines this run; it cannot override higher-priority instructions, repo guidance, or loaded PMem policy.

## Build Checklist

Explicit `prun` invocation authorizes ensuring each supplied work item under `tickets` and `tests` is `in_progress` as the run's initial PMem status transition. Perform any needed transition through the `pmem` skill and verify status before substantive work. If status cannot be verified, stop and report the failed transition or status check.

Before substantive work, create a task-specific checklist from loaded inputs, including test tickets, repo state, user-visible context, `message`, `AGENTS.md`, and project instructions.

Do not copy runbooks verbatim. Convert them into ordered, concrete, verifiable task steps. Prefer semantic work items over command-level steps.

Create a lean checklist at `/tmp/prun/<project-alias>/<ticket-id>/checklist.md`.

The file is only a checklist. No context dump, notes, copied PMem content, findings prose, command logs, or validation details. Load source content during execution when needed.

Runbook-required records such as root cause, evidence, decisions, verification, and follow-ups do not belong in the checklist file. Use the final response as the default sink. Use a PMem WI checkpoint only when the loaded workflow requires one or the user requests or confirms writeback.

Checklist item format only:

```md
- [ ] Step title
  - [ ] Child step title
- [x] Completed step title
```

Each item must be concrete, scoped, and verifiable from loaded PMem/context. Use nesting only when a child item refines its parent.

When `tests` is supplied:

- Create one top-level checklist group per test ticket, labeled with its ID and scope. Within it, choose child groups by meaningful execution and verification boundaries, not one-to-one test-case mapping: a small set of distinct cases may remain separate, while larger related sets should be consolidated by behavior, component, risk, test level, or expected outcome. Keep unrelated scope separate and add no headings to the checklist file.
- The groups must collectively cover every required case and acceptance criterion. For each group, include applicable work to derive cases from requirements, add or update tests, run targeted cases and relevant regression suites, and verify results, coverage, and acceptance evidence. Writing tests alone does not complete a group. Do not invent a numeric coverage target absent a loaded requirement or repository policy.

Follow the test methodology prescribed by applicable runbooks, subject to higher-priority instructions; otherwise default to TDD for behavior that can be specified by an executable test before implementation. Under TDD, split each relevant test-work group into two ordered phases:

1. Red: resolve expected behavior, write and run the test before production implementation, and confirm it fails because the behavior is absent. Setup failures and unrelated errors are invalid evidence.
2. Green and refine: implement the minimum behavior, pass the targeted test, refactor as needed, then run relevant regression and coverage checks.

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
4. Confirm every supplied test ticket, required test case, validation result, and coverage requirement is reconciled.
5. Confirm PMem writeback state.
6. Report completed work, changed files, validation, PMem updates, and residual risks.

Do not claim completion if required items or test-ticket obligations remain unresolved, validation is missing without explanation, or promised PMem writeback is unverified.

## Stop Conditions

Stop before execution when `prun` was not explicit, `tickets` or `runbooks` are missing/unusable, a supplied ID cannot be loaded or has the wrong entity type, PMem/source truth conflicts with higher-priority instructions, the request needs out-of-scope lifecycle behavior, or side effects are unclear or unauthorized.

## Output

Keep output concise. At start, state loaded PMem inputs, including supplied test tickets, and show the initial checklist. During execution, update only material checklist changes. Final output: completed work, files changed, validation, PMem updates, residual risks.
