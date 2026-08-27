---
name: build
description: Implement approved Flow42 slices with isolated ownership and evidence. Use after planning.
---

# Build

Recompute all required approval hashes and block on staleness before editing
product code. Establish a green baseline. For behavior changes and bug fixes, observe a
relevant failing test before implementation, then make it pass. For legacy code,
add characterization coverage first. Assign independent slices to separate
worktrees and agents only when file ownership is disjoint. Preserve unrelated
changes. Record checks, red-green observations, decisions, and gaps in
`evidence.md`. Name the proof strategy and use applicable characterization,
unit, integration, E2E, lint, type, build, UI interaction/visual, or migration
dry-run/rollback evidence. Justify unavailable checks. Never integrate a slice
whose local gates fail.

After all approved slices integrate with local gates green, transition
`building` to `verifying` using the canonical revision, atomic status,
append-only history, and read-back procedure.
