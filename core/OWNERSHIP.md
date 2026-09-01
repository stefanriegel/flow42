# Worker ownership procedure

Use a single agent by default. Delegate only when the user requests multi-agent
work or independent slices materially benefit from parallel execution.

This document governs path ownership, content identity, and Git-administration
state. It does not govern resource lifecycle. When Orca is the selected and
ready execution environment, the worker uses the Orca-provided execution
context; record the exact worktree path and dispatch reference rather than
creating or removing a worktree. If Orca selects the current worktree, record
that exact selection and require disjoint ownership plus explicit task-schedule
and integration barriers before concurrent work. In the native path the
coordinator selects, records, and retains the exact worktree. The ownership
decision below is identical in both paths.

Before dispatch, persist the worktree path, base commit, allowed path prefixes,
worker limit, selected model profile, required inputs, output schema, and
`delegation_allowed: false` in the plan.

From the repository root, capture the pre-dispatch dirty and ownership snapshot
as raw NUL-delimited records with
`git status --porcelain=v2 -z --untracked-files=all` and capture the tracked
delta from the dispatch base as NUL-delimited rename-aware records with
`git diff --name-status -z --find-renames "$base" --`. Use a NUL-capable
parser; never split a path snapshot on whitespace or newline. Decode each
porcelain-v2 record by its record type: `1` is an ordinary tracked change, `2`
is a rename or copy followed by its second path, `u` is an unmerged path, and
`?` is an untracked path. For the tracked delta, accept the documented
name-status types `A`, `C<score>`, `D`, `M`, `R<score>`, `T`, `U`, `X`, and `B`;
parse the status record followed by one path for ordinary changes and by both
source and destination paths for `R<score>` or `C<score>` records. The equivalent
`git diff --raw -z --find-renames "$base" --` form is acceptable only when its
raw header and following path records are parsed with the same rules.

An unknown record type, malformed header, missing path, or missing rename/copy
endpoint must fail closed. Do not skip a record merely because it is not an
ordinary modification; in particular, an unmerged `u` record is ownership and
dirty-state evidence.

Do not use `--name-only` for an ownership snapshot: a committed rename has a
clean status and name-only output retains only the destination. Both rename
endpoints must remain attributable across uncommitted and committed states so
the coordinator can evaluate base-relative history and disposable regression
fixtures. This evidence requirement does not authorize a worker commit.
Workers are forbidden from creating commits, moving or detaching `HEAD`, and
creating, updating, or deleting any ref in the real dispatched worktree.
Preserve the exact repository-relative bytes of paths containing spaces, tabs,
newlines, non-ASCII characters, or a leading dash.

For every pre-existing dirty tracked or untracked path, persist a content hash
or another deterministic content identity that distinguishes changed, deleted,
and absent content. Do not persist secret-bearing content. If a path cannot be
identified without disclosing a secret, record that attribution is unavailable
and fail closed before dispatch.

The working-tree snapshot is not sufficient for Git administrative state. From
the repository root, resolve and canonicalize both
`git rev-parse --git-common-dir` and `git rev-parse --git-dir`. Before dispatch,
persist a complete content-and-metadata identity for every entry under both
directories, without exclusions. This complete Git-admin tree, not a finite
manifest of currently known files, binds configuration, refs, reflogs,
pseudo-refs, recovery/sequencer/bisect state, hooks, ignore and attribute state,
the alternates and shallow/graft declarations,
this repository's own object database, and the index.
Within the two Git directories and the enumerated
external behavior paths below, a producer error, unreadable entry, special file,
symlink, or multiply linked regular file fails closed; do not accept a partial
archive or hash pipeline.

An external alternate object store is declaration-bound: Flow42 records and
compares `objects/info/alternates` but does not resolve or snapshot an external
object store, recursively or otherwise. External alternate content can make a
pre-existing latent ref become resolvable or unresolvable without changing the
bound ref stream. Snapshot equality is not object-availability proof.
Integration may rely only on objects and identities explicitly resolved for its
actual baseline, HEAD, index, and owned worktree decision. Record an alternates
entry that points outside the two Git directories in dispatch evidence as a
disclosed residual.

Also persist separate diagnostic identities, without raw secret-bearing values,
for:

- the common config and worktree config, plus the exact-byte effective
  `git config --null --show-origin --show-scope --list` stream. This binds the
  effective value, origin path, and scope of included configuration, remotes,
  aliases, and `core.hooksPath`. Configuration files outside the two Git
  directories, including files reached through `include` and `includeIf`, are
  bound by value and origin path only. Flow42 does not walk include chains and
  does not bind the file identity of an external configuration file. A
  same-user replacement that preserves every effective value and origin path,
  such as replacing an included regular file with a link to an equal-content
  target, is a disclosed residual rather than a detected change. Any effective
  value or origin change is detected and blocks integration;
- the effective hooks directory's complete tree, including modes and content,
  whether it is under the common directory or selected by `core.hooksPath`;
- the effective `core.excludesFile` and `core.attributesFile` paths and content,
  or their XDG default paths when the setting is absent; and
- the `git for-each-ref` name/object/symref stream.

Read configured paths as exactly one NUL-terminated byte record. Reject embedded
newlines, invalid UTF-8 rather than allowing lossy transcoding, relative
`XDG_CONFIG_HOME` or `HOME`, empty `core.hooksPath`, and any link or unreadable
enumerated configured behavior path. Never pass a line-delimited or shell-trimmed
`core.hooksPath` to the snapshot; a trailing-newline path must fail closed.

Repeat these identities after the worker. Workers must not mutate any Git
administrative state, including a file not named in this document. Common or
worktree configuration, remotes, aliases, hooks, hook paths, ignore or attribute
controls, alternates declarations, this repository's object storage, shallow or
graft state, refs, reflogs, recovery state, `HEAD`, pseudo-refs, and index are
coordinator-owned; any change blocks integration. Effective-value or origin
changes in external included configuration also block, while the disclosed
file-identity and external-alternate residuals above do not expand worker
authority. A worker commit, staging operation, push, or other `HEAD`/ref change is
forbidden rather than an integration mechanism. Ordinary ownership of product
paths never grants Git-administration authority.

After worker completion, repeat both NUL-delimited snapshots with rename
detection and compare them with the pre-dispatch path and content identities.
Normalize only after NUL-safe parsing; reject absolute paths, `..` components,
empty prefixes, pathspec magic, and prefix lookalikes, while allowing literal
names such as `:name`. A path is owned only when it equals an allowed path or
begins with that path plus `/`. Both the source and destination of every rename
or copy must be owned; a cross-boundary endpoint blocks integration even when
the destination alone is owned. Block integration when a worker changed a
pre-existing dirty path unless that exact overlapping edit and its baseline
content identity were explicitly handed off; ordinary path-prefix ownership is
insufficient.

After the worker's unchanged Git-admin snapshot and owned worktree delta pass,
the coordinator may stage an exact reviewed path using literal pathspec
semantics with an option terminator: `git --literal-pathspecs add -- "$path"`.
Never let the worker stage, and never use a broad path, glob, implicit pathspec
magic, `git add .`, or `git add -A` for integration.

Block integration when a new path is outside ownership or the observed worktree
differs from the recorded exact worktree. The delegation prohibition blocks
integration when a delegate launch is observed through Orca records or through
worker reporting in native execution. Reporting by a non-cooperative native
worker is not trustworthy, so native absence of delegation remains a disclosed
residual rather than a proven fact. Preserve all files and report the exact
mismatch, including rename endpoints, dirty-path collisions, and Git
administrative identity changes. Workers do not push or perform Forge writes; the
coordinator owns any later real issue or PR/MR operation.

Keep the task schedule graph separate from the data flow graph. Schedule edges
define dependencies and synchronization barriers. Data edges name a versioned
artifact, schema, producer, consumer, provenance fields, and validator. Integration
starts only after every required input validates.
