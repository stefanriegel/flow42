---
name: plan
description: Plan a Flow42 specification as vertical, provable implementation slices. Use before implementation.
---

# Plan

Confirm intent, spec, status, and history agree; block on inconsistency. Inspect the actual repository and use
native plan-mode capabilities where available. Create `plan.md` with vertical
tracer slices, dependencies, owned file areas, proving tests, worktree/branch
boundaries, integration order, risks, and rollback. Prefer end-to-end value
slices over layer-based tickets. Require a plan gate for high or critical risk.

On completion, low/medium work transitions `planning` to `building`; high or
critical work transitions to `plan-gate` and stops for explicit human
confirmation. A later invocation may move the unchanged current plan from
`plan-gate` to `building` after that confirmation. Every path uses the
canonical revision, atomic status, append-only history, and read-back procedure.
