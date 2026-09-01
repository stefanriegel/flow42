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
- Review receipt v2: independent reviewer producer, verifier and PR skill
  consumers; caller-required purpose and exact policy-minimum-bearing checks,
  reviewed code identity, provider provenance, verdict, exact in-work-item
  report bytes/reference, and resolver-bound time required. Version 1,
  purpose-substituted, partial, unrelated-artifact, or self-authored receipts
  fail closed.

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

## Human-resumed blocker repair

The 2026-09-01 user instruction explicitly resumes reversible local repair after
revision 10 exhausted the two automatic review loops. The item remains
`blocked` and `review_loops: 2` while repairs are in flight; after all recorded
blockers are resolved, the legal `blocked → verifying` resume transition may be
taken without inventing another automatic repair loop.

- Dispatch base and worktree: commit
  `20c3cf002a2c90fa49047d496c0fc347c8a5261f` in
  `/Users/sr/orca/flow42`; current worktree only because all repairs build on the
  exact blocked branch. Worker limit three. Harness Codex, provider OpenAI,
  model `gpt-5.6-sol`, effort `xhigh`, `delegation_allowed: false`.
- `codex-config-wrapper`: owns only `core/config-schema.json`,
  `tests/config-schema.sh`, and `docs/CONFIGURATION.md`. Inputs are the exact
  xcrun reproducer and current command-policy contract. Output must identify
  modified files, observed red/green commands, residual semantic-sandbox limits,
  and any proposed cross-cutting edits without making them.
- `codex-git-admin`: owns only `core/OWNERSHIP.md` and `tests/ownership.sh`.
  Inputs are the exact `info/exclude` hiding reproducer and the administrative
  state contract. Output must identify modified files, observed red/green
  commands, fail-closed coverage, performance/portability tradeoffs, and any
  proposed cross-cutting edits without making them.
- `codex-review-receipt`: owns only `core/risk-policy.json`,
  `tests/review-receipt.sh`, `tests/fixtures/review-receipt/**`,
  `skills/verify/SKILL.md`, `skills/pr/SKILL.md`, and
  `templates/evidence.md`. Inputs are the spellcheck-only/unrelated-artifact
  replay and timestamp/purpose findings. Output must identify modified files,
  observed red/green commands, migration implications, and any proposed
  cross-cutting edits without making them.
- The coordinator owns `skills/update/SKILL.md`, `tests/update.sh`, update
  fixtures, lifecycle/status canonicalization, change-request placement,
  cross-cutting `core/{CONTRACT,SECURITY}.md`, threat-model/evidence corrections,
  integration, commits, and all work-item or handoff files. Workers must not
  stage, commit, write Git administrative state, mutate Forge state, launch
  delegates, or touch coordinator-owned/pre-existing dirty files.

Integration requires NUL-safe ownership and Git-administration snapshots before
and after every dispatch, exact-path reconciliation, focused adversarial tests,
the whole local matrix, one committed exact subject, and fresh non-implementer
correctness and security reviews of that same subject. A new blocker returns the
item to `blocked`; no repair is inferred from a reviewer verdict.

### Pre-integration adversarial audits

After the implementation workers settle, three additional read-only Codex
workers inspect the security-sensitive slices before integration: one audits Git
behavior and administrative-state coverage, one audits receipt purpose/check/
artifact/time binding, and one audits the verified-candidate-to-installed-cache
boundary. They own no files, may not mutate Git or Forge state, and do not
replace the required fresh correctness and security reviews of the final clean
exact-head subject. All use `gpt-5.6-sol` at `xhigh` effort with delegation
disabled.

### Human-resumed repair disposition

- Configuration rejects `xcrun` as a control-CLI launcher and proves the former
  escape can push only inside a disposable reproducer before the repaired policy
  rejects it.
- Ownership snapshots the complete common/worktree Git administrative trees and
  exact effective external behavior paths, rejects partial or lossy producers,
  and forbids worker staging, commits, ref moves, and every other Git-admin
  mutation.
- Receipt schema v2 binds correctness/security purpose, exact required checks,
  exact report bytes/reference, and real resolver time for every issuer. Report
  bytes come only from a unique literal marker pair in the canonical work-item
  evidence path; local fallback is a separately resolved distinct session, not
  a self-asserted pass.
- Claude update commands execute at the canonical project root, bind project and
  config root, reject linked settings and unsupported source shapes, bind project
  and local entries by exact `projectPath`, neutralize Git templates/config/
  filters, compare fetched and installed trees to the verified candidate twice,
  and disclose the remaining post-observation same-user cache race.
