# Agent Guidance

## Priorities

Bias decisions in this order:

1. Security
2. Correctness
3. Portability
4. Maintainability
5. Convenience

## General Principles

- Prefer explicit errors over silent fallback.
- Validate inputs early.
- Fail safely and fail fast where failure is required.
- Avoid destructive behavior by default.
- Keep side effects local and explicit.
- Prefer default XDG layout for config, data, and state.
- Explain design goals and intended usage, not only implementation details.
- Keep public documentation focused on user install, verification, current features, and stable behavior.
- Keep agent/contributor guidance in `AGENTS.md`, not in the public README.
- Do not wrap Markdown lines solely to satisfy line-length limits.

## Skill Guidance

- Initial skill targets are Codex and Claude Code. Compatibility with other agents is not considered yet.
- A skill should improve a specific agent capability, not act as a broad template library.
- Keep `SKILL.md` focused on task semantics, boundaries, navigation, core constraints, execution skeleton, inputs, outputs, and stop conditions.
- Put detailed domain material in supporting reference files and load it only when needed.
- Put deterministic evidence collection in scripts only when it removes real repeated risk or ambiguity.
- Default responses should return only the minimal required information.
- Verbose debugging must be available through an environment variable, explicit flag, or CLI option.
- Side-effecting skills require explicit safety guidance and must not perform durable writes silently.
- Provide skill install scripts when implementation moves beyond manual install steps; keep their side effects explicit and local.

## Git Hook Guidance

- Use Git's `core.hooksPath` config for repo hooks.
- If a check needs an external tool such as `rg` or `jq`, detect it with `command <name>` and provide an install hint when it is missing.
- A missing dependency must skip only the affected hook check, not fail the entire hook run.
- Hooks are best for deterministic guardrails and fast checks. Complex semantic judgment, long-running business processes, and multi-step tradeoff decisions belong in skills, scripts, or explicit workflows.
- Provide Git hook install scripts when hook runtime implementation is added; use `core.hooksPath` and avoid hidden global mutation.
- Repo-internal `.githooks/` wrappers are for this repository's own development workflow. Do not document them as the public hook install surface.

## Script Guidance

- Prefer POSIX `sh` when practical.
- Avoid shell-specific and environment-specific behavior.
- Call dependencies with `command <name>` to avoid alias or function leakage.
- Fail fast when required setup inputs are unavailable.
- Fail safely inside individual checks so one skipped check does not hide or abort unrelated checks.
- Prefer structured data handling over ad hoc text parsing when a standard parser is available.
- Keep side effects explicit, local, and reviewable.
- Document each script's purpose, behavior, usage, dependencies, recommendations, limitations, security concerns, future improvement backlog, and test coverage summary.
- Document script functions when their purpose or behavior is not obvious.
- Cover shell scripts with ShellSpec tests.
- Place script tests under `test/`, mirroring the script path from the repository root.
