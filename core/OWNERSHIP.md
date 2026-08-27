# Worker ownership procedure

Before dispatch, persist the worktree path, base commit, allowed path prefixes,
worker limit, and `delegation_allowed: false` in the plan. Capture `git status
--short` so pre-existing changes remain attributed to their owner.

After worker completion, collect tracked changes with `git diff --name-only
<base> --` and untracked paths with `git status --short`. Normalize paths as
repository-relative names; reject absolute paths, `..`, empty prefixes, and
prefix lookalikes. A path is owned only when it equals an allowed path or begins
with that path plus `/`.

Block integration when a new path is outside ownership, the worker launched a
delegate, the worker used Forge-write authority, or the observed worktree differs
from the dispatched worktree. Preserve all files and report the exact mismatch.
