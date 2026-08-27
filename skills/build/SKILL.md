---
name: build
description: Implement approved Flow42 slices with isolated ownership and evidence. Use after planning.
---

# Build

Establish a green baseline. For behavior changes and bug fixes, observe a
relevant failing test before implementation, then make it pass. For legacy code,
add characterization coverage first. Assign independent slices to separate
worktrees and agents only when file ownership is disjoint. Preserve unrelated
changes. Record checks, red-green observations, decisions, and gaps in
`evidence.md`. Never integrate a slice whose local gates fail.
