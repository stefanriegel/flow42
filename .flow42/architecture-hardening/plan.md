# Plan: Architecture hardening

## Vertical slices

1. Adjudicate the architecture and safe cleanroom reuse; no repository files.
2. Deepen the Claude Update Adapter and its behavior tests.
3. Repair lifecycle, review-receipt, and configuration authority.
4. Repair ownership collection, contract reachability, and evaluation depth.
5. Integrate the safe unanswered-intent fallback if it remains compatible.
6. Run whole-tree verification and independent exact-head review.

## Parallelization map

- `opus-design`: no dependencies; Opus/high; current worktree; output only
  `/tmp/flow42-architecture-remediation-design.md`; retry limit 1;
  `delegation_allowed: false`; completed by dispatch `ctx_8a3345a7b3fc`.
- `codex-update-adapter`: F1/F8; Codex `gpt-5.6-sol`/xhigh; owns only
  `skills/update/SKILL.md`, `tests/update.sh`, `tests/fixtures/update/**`,
  `README.md`, `docs/INSTALLATION.md`, `scripts/check-parity.sh`, and
  `tests/conformance.sh`.
- `codex-control-plane`: F2/F3/F7; Codex `gpt-5.6-sol`/xhigh; owns only
  `core/CONTRACT.md`, `core/workflow.json`, `core/risk-policy.json`,
  `core/config-schema.json`, `skills/{verify,pr,init,resume,spec}/SKILL.md`,
  `templates/config.yml`, `templates/evidence.md`, `.flow42/config.yml`,
  `docs/{CONFIGURATION,MIGRATION,LIFECYCLE,ARCHITECTURE}.md`,
  `tests/{review-receipt,config-schema,lifecycle-transitions}.sh`, and their
  corresponding fixture directories.
- `codex-ownership-evals`: F4/F5 tests/F6; Codex `gpt-5.6-sol`/xhigh; owns only
  `core/{OWNERSHIP,SECURITY}.md`, `skills/{build,flow}/SKILL.md`, `agents/*.md`,
  `tests/{ownership,prelude,contracts}.sh`, `scripts/validate.sh`, `evals/**`, and
  `.github/workflows/ci.yml`.
- All workers use the current worktree because integration depends on the same
  evolving branch; synchronization barriers prevent overlapping edits.
- If an Orca worker cannot establish an agent identity before executing its
  prompt, fence it and use a native Codex subagent with the identical ownership
  contract; record both attempts so provenance does not imply work that never ran.

## Data contracts

- Design report v1: Opus producer, coordinator and implementers consume; exact
  baseline, finding disposition, owned files, red test, implementation, and
  cleanroom provenance required; coordinator validates against current files.
- Worker result v1: worker producer, coordinator consumer; dispatch identity,
  base commit, modified files, red/green commands, remaining gaps required;
  coordinator validates against ownership and the worktree diff.
- Review receipt v1: independent reviewer producer, PR skill consumer; reviewed
  code identity, provider provenance, verdict, checks, and artifact reference
  required; invalid or self-authored receipts fail closed.

## Integration order

Design first; canonical contract prelude barrier; then three disjoint slices in parallel;
coordinator-owned cross-cutting integration; safe intent fallback; full checks;
independent review; remediation and fresh review if needed.

## Completed implementation

- Update Adapter: install-then-update convergence, scope/source fidelity, exact
  version readback, canonical install grammar, and stateful fake behavior.
- Control plane: receipt-subject currency, strict configuration authority and
  migration, declared pseudo/dynamic states, and legal repair transitions.
- Ownership/evals: NUL-safe snapshots, rename and dirty-content attribution,
  literal pathspecs, contract reachability, and explicit proof-tier labels.
- Coordinator seams: schema added to all preludes and update verification;
  Flow config validation; review security wording; safe unanswered-intent
  fallback; adversarial receipt, lifecycle, and configuration repairs.

## Independent-review remediation

- Update rollback runs as one transaction with live state, strict failure
  handling, settings-backed source reconciliation, homogeneous-version
  preflight, and before/after-effect failure fixtures for supported source kinds.
- Configuration delegates branch grammar to Git while retaining a literal-name
  guard, accepts only the documented YAML subset, and normalizes wrappers,
  path-qualified executables, and control-CLI options before policy checks.
- Ownership uses NUL-safe name-status records for committed rename/copy
  endpoints, retains unmerged records, and fails closed on unknown or truncated
  records.
- Strong receipt issuers require independently authenticated exact binding;
  currency disables rename folding, validates ancestry, and permits only exact
  bookkeeping leaves plus field-level status changes with unique canonical keys.
- Resume binds to the actual pre-block stage, excludes final/self-loop targets,
  and the third automatic verification repair blocks and escalates.
- Proof labels distinguish behavioural reference fixtures from structural and
  text-conformance checks; environment probes and literal read-backs are not
  counted as Flow42 behavior.
- The security-sensitive control work has a persisted threat model, and every
  direct skill and worker pointer resolves authority from the bundle's actual
  great-grandparent root.

## Second and final automatic review repair

- Update: bind the verified candidate URL to the recorded GitHub/Git source,
  stop directory sources before discovery, compose preflight and transaction,
  and avoid rollback mutation after a pre-effect first-remove failure.
- Control plane: bind receipts to independently derived repository/work/scope/
  diff/artifact identities, strictly parse the status subset, make a valid
  change-request link neutral, fix blocked side transitions, and unify the
  high-risk gate ID.
- Ownership/security: reject all configured control CLIs, snapshot Git
  administrative state, make host-instruction provenance and residual risk
  honest, update the threat model, and centralize eval vocabulary.
- Coordinator seams: preserve title whitespace during status canonicalization,
  reject trailing empty argv elements, cover `core.hooksPath`, and keep silence
  distinct from authorization. This consumes `automatic_review_limit: 2`; a
  further blocking exact-head verdict must transition to `blocked`.

## Risks and rollback

Each worker owns exact paths and makes no commits or Forge writes. A failed slice
is isolated by its path set and can be repaired without discarding unrelated
changes. Preserve every file on ownership mismatch and stop integration. No
merge, publish, or deployment is authorized by this plan.
