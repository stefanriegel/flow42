# Specification: Architecture hardening

## Functional requirements

1. The Claude update and rollback flows reach the requested installed version
   whether marketplace removal preserves or removes the installed plugin.
2. Exact-head independent review has a coherent durable receipt model without a
   commit-after-review fixed point.
3. Active and template configuration are validated against one versioned schema;
   configured command paths and canonical gates cannot drift silently.
4. Worker ownership snapshots are NUL-safe, include rename endpoints, preserve a
   dirty baseline, and reject unowned overlap.
5. Every directly invokable skill reaches the canonical contract and security
   authority; inert or competing rule copies are removed or made load-bearing.
6. Update, lifecycle, ownership, and eval tests exercise observable behavior,
   while text-only checks are labelled as such.
7. Review/CI repair loops are legal transitions and every transition endpoint is
   part of a declared grammar.
8. Claude GitHub shorthand uses the documented `owner/repo@ref` form from one
   canonical source.

## Non-functional requirements

All repository shell remains POSIX `sh` and passes ShellCheck. Tests use
temporary directories and must not mutate normal Claude, Codex, Git, or Forge
state. Diagnostics are deterministic and identify the failed invariant.

## Domain model and terminology

- Update Adapter: harness-specific instructions that move an installed plugin
  from one immutable version to another.
- Review receipt: provider-issued evidence binding an independent principal and
  verdict to the reviewed code identity.
- Ownership snapshot: raw Git path and content evidence captured before and
  after a worker dispatch.
- Contract prelude: the canonical authority every direct skill must load.

## Interfaces and data

The update Interface is requested immutable source plus recorded scopes in, and
observed installed version plus rollback state out. Configuration and lifecycle
Interfaces remain machine-readable JSON/YAML. Review receipts must not require
editing the reviewed code identity after attestation.

## Security considerations

Fail closed on ambiguous scope, source, ownership, schema, receipt provenance,
or transition state. Do not treat independent review as human authorization.
Do not persist secrets or raw authenticated CLI output.

## Acceptance criteria

- Stateful update fixtures cover both plugin-preserved and plugin-removed
  marketplace semantics and prove final/rollback versions.
- Adversarial configuration, transition, ownership, and receipt fixtures fail
  for the intended reason.
- Direct entrypoints demonstrably load the canonical contract prelude.
- The complete current suite plus all new checks pass at one exact head.

## Verification strategy

Observe red-green behavior in temporary fixtures for each slice; run focused
tests after every integration; then run the entire validation/test/eval matrix,
ShellCheck, `git diff --check`, and an independent exact-head Orca review.
