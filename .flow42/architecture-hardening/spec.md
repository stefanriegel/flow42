# Specification: Architecture hardening

## Functional requirements

1. The update flow verifies a selected signed semantic-version release before
   mutation, delegates installation to the harness's documented package-manager
   commands, and verifies the reported version and installed bundle structure.
   It does not inspect or modify private harness caches. Recovery is a
   best-effort native reinstall of the recorded prior release and never claims
   byte-identical restoration without a supported vendor restore interface.
2. Exact-head independent review has a coherent durable receipt model without a
   commit-after-review fixed point; correctness/security purpose, exact required
   checks, expected artifact bytes/reference, and authenticated time are
   caller/provider-bound, with artifact bytes extracted only from a uniquely
   delimited section of the repository/work-derived evidence file.
3. Active and template configuration are validated against one versioned schema;
   configured command paths and canonical gates cannot drift silently.
4. Worker ownership snapshots are NUL-safe, include rename endpoints, preserve a
   dirty baseline, reject unowned overlap, and bind the complete common/worktree
   Git administrative trees plus enumerated external hooks, ignore, and
   attributes paths. External included configuration is bound by effective
   value, origin, and scope; external alternate stores are declaration-bound.
5. Every directly invokable skill reaches the canonical contract and security
   authority; inert or competing rule copies are removed or made load-bearing.
6. Update, lifecycle, ownership, and eval tests exercise observable behavior,
   while text-only checks are labelled as such.
7. Review/CI repair loops are legal transitions and every transition endpoint is
   part of a declared grammar.
8. Claude GitHub shorthand uses the documented `owner/repo@ref` form from one
   canonical source.

## Non-functional requirements

All repository shell remains `sh`-compatible across the supported macOS
`/bin/sh`, `dash`, and `ksh` test environments and passes ShellCheck; this is a
supported-shell portability claim, not proof against every strict POSIX
implementation. Tests use temporary directories and must not mutate normal
Claude, Codex, Git, or Forge state. Diagnostics are deterministic and identify
the failed invariant.

## Domain model and terminology

- Update Adapter: harness-specific instructions that move an installed plugin
  from one immutable version to another.
- Review receipt: provider-issued evidence binding an independent principal and
  verdict to the reviewed code identity.
- Ownership snapshot: raw Git path and content evidence captured before and
  after a worker dispatch.
- Contract prelude: the canonical authority every direct skill must load.

## Interfaces and data

The update Interface is requested immutable release plus the native harness's
recorded source/scope in, and verified release identity, observed installed
version and bundle structure, plus honest recovery status out. Configuration and
lifecycle Interfaces remain machine-readable JSON/YAML. Review receipts must not require editing the
reviewed code identity after attestation; Forge linkage is receipt-neutral
evidence while the schema-compatible status change-request field stays empty.

## Security considerations

Fail closed on ambiguous scope, source, ownership, schema, receipt provenance,
or transition state. Do not treat independent review as human authorization.
Do not persist secrets or raw authenticated CLI output.

### Threat model

- Assets: repository integrity; the reviewed repository, baseline, head, scope,
  diff, and artifact identities; worker path and Git-administration ownership;
  human confirmation state; configured command argv; signed plugin release
  identity, installation scope, native harness state, and recovery status; and
  review provenance.
- Actors: the accountable human; the coordinating agent; non-implementing
  reviewers; bounded implementation workers; authenticated Forge and
  orchestrator principals; vendor CLIs; and an attacker able to control
  repository text, issue/review text, configuration values, Git pathnames or
  administrative state including ignore/attributes/alternates files, a moved
  release tag, a harness-elevated repository instruction, or a
  replayed/unauthenticated receipt claim.
- Trust boundaries: human request to coordinator; repository data to executable
  agent instructions; configuration tokens to process execution; coordinator
  to worker worktree; Git's byte-oriented path records to ownership decisions;
  vendor marketplace state to the update adapter; and a review provider's
  authenticated record to local receipt validation; and host instruction
  precedence to Flow42's later interpreted policy.
- Abuse cases: hide a push behind a Git alias or generic Forge API command;
  substitute candidate content through ambient Git state, install an unverified
  release, or claim exact rollback from labels alone; redirect a coordinator push through remote/hook or
  ignore-file mutation while leaving the worktree clean; replay a valid receipt
  across work items/scopes/purposes or substitute its checks/artifact/time; use a
  quoted duplicate key or escaped scalar in status; smuggle an
  unowned source through a committed rename; claim a forged trusted review;
  resume from `blocked` directly to a final state; make update rollback delete
  the only usable marketplace declaration; use malicious path bytes to evade
  ownership checks; or edit non-bookkeeping code while retaining a stale
  receipt.
- Mitigations: direct-argv validation rejects a named control CLI in any token
  position and retains an empty control-CLI allowlist, while explicitly relying
  on the worker capability boundary rather than claiming semantic sandboxing;
  Git's NUL-delimited name-status records plus pre/post Git-administration
  identities cover the declared repository and external behavior surfaces;
  authenticated receipt resolution binds caller-expected repository/work/scope/
  diff/purpose/check/artifact and provider time; strict escape-free status parsing
  and non-final recorded resume targets constrain lifecycle state; release input
  is verified before harness-native installation; coordinator-only literal
  pathspec staging follows worker settlement and ownership checks; and receipt
  currency is restricted to the reviewed work item's bookkeeping paths.
- Residual risk: local independent review cannot authenticate an external
  principal and remains a lower proof tier; vendor CLI semantics can change;
  arbitrary scripts can reach authority without naming a control CLI; external
  include file identity and external alternate object contents are not bound;
  point-in-time link and digest checks are not atomic against a concurrent
  same-user writer; Flow42 delegates process identity and settlement to Orca;
  and local fixtures do not prove remote Forge, normal-harness, release, or
  deployment behavior. These risks are explicit and require stronger evidence
  before a stronger proof tier is claimed.

## Acceptance criteria

- Stateful update fixtures cover both plugin-preserved and plugin-removed
  marketplace semantics, same-tag byte substitution, installed-cache
  substitution, linked settings/runtime metadata, invalid source shapes, and
  final/rollback versions.
- Adversarial configuration, transition, ownership, and receipt fixtures fail
  for the intended reason.
- Direct entrypoints demonstrably load the canonical contract prelude.
- The complete current suite plus all new checks pass at one exact head.

## Verification strategy

Observe red-green behavior in temporary fixtures for each slice; run focused
tests after every integration; then run the entire validation/test/eval matrix,
ShellCheck, `git diff --check`, and an independent exact-head Orca review.
