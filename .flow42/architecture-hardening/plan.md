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

- Update interface: installed-trust-anchor release verification, harness-native
  installation and structural readback instructions, honest best-effort
  recovery, and structural/text-conformance coverage. The earlier stateful fake
  convergence adapter was superseded by the human-directed simplification.
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

## Human-directed update simplification

The 2026-09-01 user direction replaces the cache-attestation design above for
the update slice. Orca owns worktrees, terminals, processes, worker settlement,
and cleanup. Flow42 update owns only read-only discovery, trusted signed-release
verification, harness-native install/reinstall, structural readback, and honest
reporting.

The simplified update has four phases: inspect one unambiguous installation;
verify a selected signed semantic-version tag with the already-installed trust
anchor; install through the documented harness CLI; then verify version and
bundle structure. It never edits or attests private harness caches. Failure
keeps the current version when mutation has not started, otherwise attempts a
best-effort native reinstall and reports incomplete recovery without blocking
unrelated project work.

## Human-directed promise reconciliation

The 2026-09-01 follow-up directs Flow42 to reconcile its remaining architecture
claims with observable behavior, fix the review-receipt producer failure and
worker-staging contradiction, keep the hardlink mitigation small, and delegate
execution isolation to Orca. It explicitly rejects recursive Git-object/config
snapshots and another launcher denylist.

- Claude Opus/high independently adjudicates the claims without repository
  edits. Codex `gpt-5.6-sol`/xhigh workers own disjoint receipt, command-policy,
  ownership, lifecycle-prose, and threat-model slices. All workers run under
  Orca with delegation disabled; only the coordinator stages and commits.
- Named `git`, `gh`, `glab`, and `terraform` tokens are rejected in every argv
  position. The launcher list remains unchanged and explicitly illustrative;
  accepted repository scripts pin the residual semantic gap.
- External Git includes are bound by effective value, origin, and scope only.
  External alternate stores are declaration-bound only, with refs, `HEAD`, the
  index, and owned working-tree paths retained as compensating integration
  surfaces. The residuals are tested and documented rather than recursively
  snapshotted.
- Receipt currency stores the Git diff producer output only after its exit status
  succeeds. Evidence extraction adds only a point-in-time single-link predicate
  and makes no atomic identity promise.
- Fresh non-implementing exact-head correctness and security reviews are the
  final risk-based release gate. They assess the named acceptance and threat
  surfaces; they are not described as universal product-correctness proof.

### First exact-head review remediation

The first fresh review subject `9a112d64f7677ce0148b42f45b98d5a49738ca56`
was correctly blocked. Claude Opus/high found the mutation-signature position
asymmetry and missing normative producer-status rule; Codex/xhigh additionally
found stale update proof tiers, a latent-ref alternate counterexample, and an
isolated-worktree claim inconsistent with Orca-selected current-worktree use.

- `codex-control-remediation` owns the existing command signatures and receipt
  producer contract. It generalizes the unchanged signature inventory to a
  basename-normalized ordered subsequence from any candidate executable token;
  it does not add a launcher or implement a full CLI parser.
- `codex-ownership-remediation` pins external alternate latent-ref
  resolvability as a disclosed residual and replaces isolated-worktree wording
  with the exact Orca-provided execution context plus disjoint ownership and
  barriers when Orca selects the current worktree.
- `codex-proof-tier-remediation` labels update coverage as structural/text
  conformance, retains release-checksum proof at its local cryptographic tier,
  corrects public claims, and deletes the seven unreferenced legacy update
  fixtures rather than reviving the removed package-manager simulation.
- Coordinator integration carries the cross-file security wording, runs the
  full local matrix, creates a new exact subject, and requires fresh independent
  correctness and security reviews. The blocked reports do not become pass
  receipts.

### Final macOS casefold remediation

The second review subject `6b31d2491e2adfa59295eff08cd4f3c2a6c4d8ad`
passed correctness review but security review reproduced one remaining named-
executable escape on a case-insensitive macOS filesystem. The final bounded
repair ASCII-casefolds executable basenames before the existing authority,
blocked-launcher, and mutation-signature comparisons. It does not add launcher
names or parse CLI grammars. One text-conformance mutation also binds the
update instruction that rejects unexpected Git configuration and repository
environment overrides. Fresh exact-head correctness and security reviews are
required after this repair.

### Final bounded remediation of the `53e22ed` review

The next blocked exact-head review found adjacent gaps in the same bounded
interfaces: shell and launcher signatures were not all routed through the
ordered matcher; command tokens admitted Unicode executable lookalikes and
dollar expansion; review evidence/status parsing admitted NUL aliasing; and the
build skill plus ownership mutations did not fully bind Orca-selected context or
worker staging, push, and Forge-write prohibitions.

- Execution context: Orca-provided current worktree
  `/Users/sr/orca/flow42`, exact base
  `53e22ed4d86badedfd1b6fd4aa07f8ed1c287ea5`, task
  `task_b4787edf6b27`, dispatch `ctx_91c404f68ce9`; one Codex worker,
  `delegation_allowed: false`, no overlapping worker schedule.
- Owned paths: only the command schema/docs/tests, receipt policy/verify/
  contract/security/tests, build/ownership/threat-model/tests, and this work
  item's `plan.md`, `decisions.md`, and `evidence.md`.
- Inputs: the coordinator-supplied blocked findings, the unchanged command
  inventories, the existing `matches_ordered_signature` matcher, and the exact
  current ownership/review contracts. Output is an unstaged worker report with
  exact changed paths and red/green local evidence.
- Implementation boundary: reuse the ordered matcher for all four rejection
  families; use printable-ASCII/direct-argv grammar rather than a parser or new
  launcher entry; reject NUL before interpretation with a checked portable byte
  comparison; bind the build skill to Orca's selected worktree and extend only
  structural mutation coverage. Do not add recursive Git snapshots or broader
  runtime enforcement.
- Integration barrier: the coordinator owns staging and all later integration.
  This repair records no lifecycle transition; `status.yml` remains unchanged
  and fresh independent exact-head reviews are still required.

### Exact-head `f73f99b` named-shell cluster remediation

The final correctness review of clean head
`f73f99b07e2b2219594fb12151d33696f667f5f6` found one bounded command-policy
escape: a declared named-shell `-c` signature did not match a short option
cluster containing `c`. Extend only the existing portable ordered matcher so
`sh -lc`, `bash -xc`, and `arch -arm64 sh -lc` fail, while retaining direct
`sh tests/conformance.sh`. Do not add a shell parser, launcher inventory,
Unicode or OS branch, recursive snapshot, or new prose guard. The coordinator
owns staging and integration; `status.yml`, `history.jsonl`, and `handoff.md`
remain unchanged, and fresh exact-head review remains required.
