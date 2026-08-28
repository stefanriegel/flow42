# Worker ownership procedure

Use a single agent by default. Delegate only when the user requests multi-agent
work or independent slices materially benefit from parallel execution.

Before dispatch, persist the worktree path, base commit, allowed path prefixes,
worker limit, selected model profile, required inputs, output schema, and
`delegation_allowed: false` in the plan. Capture `git status
--short` so pre-existing changes remain attributed to their owner.

After worker completion, collect tracked changes with `git diff --name-only
<base> --` and untracked paths with `git status --short`. Normalize paths as
repository-relative names; reject absolute paths, `..`, empty prefixes, and
prefix lookalikes. A path is owned only when it equals an allowed path or begins
with that path plus `/`.

Block integration when a new path is outside ownership, the worker launched a
delegate, or the observed worktree differs from the dispatched worktree.
Preserve all files and report the exact mismatch. Workers do not perform Forge
writes; the coordinator owns any later real issue or PR/MR operation.

Keep the task schedule graph separate from the data flow graph. Schedule edges
define dependencies and synchronization barriers. Data edges name a versioned
artifact, schema, producer, consumer, provenance fields, and validator. Integration
starts only after every required input validates.
