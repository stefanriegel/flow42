---
name: plan
description: Plan an approved Flow42 specification as vertical, provable implementation slices. Use before implementation.
---

# Plan

Recompute approved intent and spec hashes; invalidate downstream approvals and
block on mismatch. Inspect the actual repository and use
native plan-mode capabilities where available. Create `plan.md` with vertical
tracer slices, dependencies, owned file areas, proving tests, worktree/branch
boundaries, integration order, risks, and rollback. Prefer end-to-end value
slices over layer-based tickets. Require a plan gate for high or critical risk.

On completion, low/medium work transitions `planning` to `building`; high or
critical work transitions to `plan-gate` and stops. A later invocation may move
an authenticated, provenance-verified current plan from `plan-gate` to
`building`. Every path uses the
canonical revision, atomic status, append-only history, and read-back procedure.
