---
name: build
description: Implement planned Flow42 slices with isolated ownership and evidence. Use after planning.
---

# Build

Confirm the current intent, spec, plan, status, and history agree before editing
product code. For high or critical risk, require the explicit plan confirmation
recorded by the plan gate. Establish a green baseline. For behavior changes and bug fixes, observe a
relevant failing test before implementation, then make it pass. For legacy code,
add characterization coverage first. Assign independent slices to separate
worktrees and agents only when file ownership is disjoint. Preserve unrelated
changes. Record checks, red-green observations, decisions, and gaps in
`evidence.md`. Name the proof strategy and use applicable characterization,
unit, integration, E2E, lint, type, build, UI interaction/visual, or migration
dry-run/rollback evidence. Justify unavailable checks. Never integrate a slice
whose local gates fail.

Apply the exact `core/OWNERSHIP.md` procedure before and after every worker.
Compare changed paths to its recorded ownership.
Workers receive no Forge-write authority and cannot delegate. Block integration
on out-of-scope paths or unauthorized processes while preserving the worktree.

After all planned slices integrate with local gates green, transition
`building` to `verifying` using the canonical revision, atomic status,
append-only history, and read-back procedure.
