# Worker ownership procedure

Use a single agent by default. Delegate only when the user requests multi-agent
work or independent slices materially benefit from parallel execution.

Before dispatch, persist the worktree path, base commit, allowed path prefixes,
worker limit, selected model profile, required inputs, output schema, and
`delegation_allowed: false` in the plan.

From the repository root, capture the pre-dispatch dirty and ownership snapshot
as raw NUL-delimited records with
`git status --porcelain=v2 -z --untracked-files=all` and tracked names with
`git diff --name-only -z "$base" --`. Use a NUL-capable parser; never split a
path snapshot on whitespace or newline. Decode each porcelain-v2 record by its
record type and record both endpoints of every rename. Preserve the exact
repository-relative bytes of paths containing spaces, tabs, newlines, non-ASCII
characters, or a leading dash.

For every pre-existing dirty tracked or untracked path, persist a content hash
or another deterministic content identity that distinguishes changed, deleted,
and absent content. Do not persist secret-bearing content. If a path cannot be
identified without disclosing a secret, record that attribution is unavailable
and fail closed before dispatch.

After worker completion, repeat both NUL-delimited snapshots and compare them
with the pre-dispatch path and content identities. Normalize only after NUL-safe
parsing; reject absolute paths, `..` components, empty prefixes, pathspec magic,
and prefix lookalikes, while allowing literal names such as `:name`. A path is
owned only when it equals an allowed path or begins with that path plus `/`.
Both the source and destination of a rename must be owned. Block integration
when a worker changed a pre-existing dirty path unless that exact overlapping
edit and its baseline content identity were explicitly handed off; ordinary
path-prefix ownership is insufficient.

When staging an exact reviewed path, use literal pathspec semantics with an
option terminator: `git --literal-pathspecs add -- "$path"`. Never use a broad
path, glob, implicit pathspec magic, `git add .`, or `git add -A` for worker
integration.

Block integration when a new path is outside ownership, the worker launched a
delegate, or the observed worktree differs from the dispatched worktree.
Preserve all files and report the exact mismatch, including rename endpoints
and dirty-path collisions. Workers do not perform Forge writes; the coordinator
owns any later real issue or PR/MR operation.

Keep the task schedule graph separate from the data flow graph. Schedule edges
define dependencies and synchronization barriers. Data edges name a versioned
artifact, schema, producer, consumer, provenance fields, and validator. Integration
starts only after every required input validates.
