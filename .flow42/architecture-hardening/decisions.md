# Decisions: Architecture hardening

## 2026-09-01T05:37:26Z — implementation baseline

- Context: The previous update branch was already merged through a different
  merge commit and was behind current `origin/main`.
- Options: continue on the stale branch; rewrite it; or preserve it and create a
  fresh branch from current main.
- Decision: Preserve `fix/update-skill-review` and implement on
  `fix/architecture-hardening` from `origin/main`.
- Rationale: This retains history and includes merged PR #16 while leaving the
  separate `feat/intent-safe-fallback` branch available for selective integration.
- Consequences: New changes are isolated; no force update or history rewrite.
- Actor: coordinator.

## 2026-09-01T05:37:26Z — user scope

- Context: The user requested all open findings be implemented with supervised
  Codex subagents and allowed Opus 5 for important work.
- Decision: Treat local reversible implementation and testing as authorized;
  keep merge, publish, release, deployment, and other irreversible operations
  out of scope.
- Rationale: This matches the explicit request without broadening authority.
- Consequences: Workers may edit only assigned paths and cannot write to Forge.
- Actor: user request, recorded by coordinator.

## 2026-09-01T06:02:11Z — architecture adjudication defaults

- D1: Allow and require Claude `plugin update` after `plugin install`; the latter
  is a success-looking no-op when another marketplace declaration preserves an
  old installation.
- D2: Use a local independent receipt as the solo/offline fallback; do not create
  a Forge comment merely to manufacture provenance.
- D3: Do not adopt the experimental whole-surface hash registry in this work
  item; enforce the selected controls at their authoritative interfaces.
- D4: Port only the NUL-safe ownership snapshot rules, not the unrelated
  cleanroom recovery feature.
- D5: Keep `core/workflow.json` at schema version 2 because the repair and target
  declarations are additive and do not change the v2 command-key contract.
- Rationale: These are the Opus adjudication's recommended safe defaults and
  preserve the runtime-free seven-file lifecycle without reviving approval gates.
- Actor: coordinator, based on dispatch `ctx_8a3345a7b3fc`.

## 2026-09-01T06:05:00Z — unanswered intent fallback

- Context: Immediate blocking on an unanswered material question can stall a
  project even when the choice is reversible and a conservative option is safe.
- Decision: Clarify and rephrase first, inspect for more evidence, offer concrete
  options, then use a bounded provisional default only for reversible choices
  that need no new authority. Defer implementation choices to later phases and
  block only when no safe fallback exists.
- Consequences: Headless and interactive flows can progress through safe intent
  uncertainty, while auth, permissions, sensitive data, money, production,
  infrastructure, migrations, destructive, high-risk, and irreversible choices
  remain fail-closed. Silence never supplies authorization; a documented safe
  provisional default is an assumption, not an answer or permission.
- Actor: user request, implemented by coordinator from the selectively reviewed
  `feat/intent-safe-fallback` branch.

## 2026-09-01T07:35:00Z — project configuration migration

- Context: The architecture hardening introduced the schema-authoritative
  configuration contract and retired configuration approval gates.
- Decision: Migrate `.flow42/config.yml` to schema version 1, retain the four
  canonical high-risk/irreversible/merge/deploy gates, use direct-argv command
  arrays, and remove nonexistent command paths.
- Validation: `tests/config-schema.sh`, `scripts/validate.sh`,
  `tests/contracts.sh`, and `scripts/check-parity.sh` passed after migration.
- Consequences: Unknown or unsupported syntax blocks execution; the migration
  creates no approval artifact and grants no Forge authority.
- Actor: coordinator.

## 2026-09-01T08:32:38Z — explicit human resume after review-limit block

- Context: Revision 10 blocked the work item after two automatic verification
  repair loops, with four independently reproduced HIGH findings.
- Decision: The user's instruction to work on the discovered blockers explicitly
  authorizes another reversible local repair cycle under Orca orchestration.
- Constraints: Preserve `review_loops: 2`; keep lifecycle stage `blocked` until
  every recorded blocker is resolved; use Codex workers with disjoint ownership;
  require fresh exact-head independent correctness and security review.
- Scope: Local files, disposable fixtures, read-only official documentation and
  CLI discovery, tests, and normal commits. No push, PR/MR, merge, release,
  deployment, destructive recovery, or Forge mutation is authorized.
- Actor: user request, recorded by coordinator.

## 2026-09-01T10:07:27Z — fail-closed blocker repair boundaries

- Context: The resumed Codex implementations and three read-only adversarial
  audits found that finite Git-admin manifests, self-asserted local receipts,
  string-only update readback, and an undocumented blanket cache exclusion could
  not support the claimed boundaries.
- Decision: Snapshot complete Git administrative trees with no exclusions;
  require independent resolver binding for every receipt tier; compare exact
  fetched and installed trees to the verified candidate from the canonical
  project identity; and allow only validated Claude decimal-PID JSON runtime
  markers outside the installed plugin tree identity.
- Evidence basis: Official Git documentation makes repository-local ignore,
  attribute, alternates, reflog, hook, and other administrative surfaces
  behavior-affecting. Official Claude documentation establishes copied,
  versioned plugin caches and project/user/local scope semantics. The observed
  `.in_use/<pid>` JSON shape is corroborating implementation evidence from the
  Anthropic issue tracker, not a documented stable vendor API.
- Consequences: Unknown Git-admin state and malformed runtime metadata fail
  closed. Two consecutive cache observations close the reproduced update race
  but are not described as atomic or durable immutability; a same-user writer
  after the final observation remains a disclosed residual risk.
- Actor: coordinator, based on Orca Codex implementation/audit results and
  primary-source review.

## 2026-09-01T10:24:09Z — integration self-review hardening

- Context: Coordinator review before the exact-head commit found that a receipt
  test could hash a separately supplied file while claiming an in-work-item
  evidence reference, and that Claude source/settings/runtime-marker inputs had
  adjacent link and grammar ambiguity not covered by the original blockers.
- Decision: Derive the evidence file from canonical repository/work identity and
  delimit each report by one unique ordered literal marker pair. Canonicalize the
  Claude config root for every CLI call; reject linked/multiply linked settings,
  irreproducible or option-shaped source objects, and linked, malformed, or
  invalid-hour runtime markers.
- Consequences: The receipt artifact has an executable reference-to-bytes
  mapping, and preflight stops before candidate discovery or harness mutation
  when rollback cannot reproduce the inspected declaration. These controls do
  not turn the mutable vendor cache into an atomic store.
- Actor: coordinator self-review; no additional worker or Forge mutation.

## 2026-09-01T12:46:23Z — simplify update and delegate execution isolation to Orca

- Context: The cache-attestation update design grew to 846 lines, duplicated
  harness package-manager responsibilities, still could not prove an atomic
  rollback, and blocked unrelated project progress on unsupported guarantees.
- Decision: Orca owns worktree, terminal, process, worker-settlement, and cleanup
  lifecycle. Flow42 update is limited to inspecting one installation, verifying
  a signed semantic-version release with the installed trust anchor, invoking
  the harness-native installer, checking version/bundle structure, and reporting
  best-effort recovery honestly.
- Evidence basis: Official Claude Code documentation defines marketplace/plugin
  installation, versioned cache behavior, native update commands, tag refs for
  marketplace sources, and exact SHA pins for plugin sources. Official Git
  documentation defines signed-tag verification. Neither provides Flow42 a
  supported byte-perfect vendor-cache rollback interface.
- Consequences: Private cache inspection and the two-observation mechanism are
  removed. An unsafe or ambiguous update leaves the prior installation in place;
  an incomplete recovery is reported but does not halt unrelated project work.
- Actor: explicit user direction, implemented by coordinator.

## 2026-09-01T13:15:00Z — reconcile guarantees with observable controls

- Context: Research and exact disposable-repository reproducers showed that the
  remaining architecture findings mixed real defects with promises broader than
  Flow42's mechanisms. The user explicitly rejected recursive Git config/object
  snapshots and a larger launcher denylist.
- Decision: Fix named control-CLI reachability across all argv positions, the
  swallowed Git diff producer error, the worker-staging contradiction, and a
  small observed hardlink gap. Narrow external-include, external-alternate,
  process-identity, and receipt file-identity guarantees to what the current
  mechanisms actually observe; delegate worker lifecycle and isolation to Orca.
- Evidence basis: Git documents that included configuration is inserted with
  origin semantics and that alternates borrow external object stores. POSIX
  pipeline status defaults to the last command, reproducing the old `git diff |
  jq` false success. NIST SSDF PW.7 supports policy-selected peer or expert
  review and issue triage, not a claim that a receipt proves universal
  correctness.
- Consequences: Residuals are executable and explicit. Named control-CLI tokens
  fail closed, but arbitrary scripts and renamed tools remain inside the Orca
  and ownership capability boundary. External include identity, external object
  contents, and concurrent same-user mutation are not newly claimed. Fresh
  exact-head correctness and security reviews remain required before PR-ready.
- Actor: explicit user direction, Claude Opus adjudication task
  `task_fc6b5967bd16`, Codex implementation tasks `task_819979b284fa`,
  `task_ccacd8bb7cb4`, and `task_85c8f2c16fb7`, coordinated in Orca run
  `run_b5ab6e7b3014`.

## 2026-09-01T14:20:00Z — accept exact-head review blockers and narrow again

- Context: Fresh independent reviews of `9a112d64f7677ce0148b42f45b98d5a49738ca56`
  returned BLOCKED. The counterexamples covered named mutation signatures with
  wrappers/global options, a producer-status requirement missing from normative
  instructions, stale update proof labels and fixtures, external-alternate
  latent refs, and per-worker isolation wording inconsistent with Orca-selected
  current-worktree execution.
- Decision: Accept and remediate every material finding without expanding the
  launcher list or recursively inspecting external stores. Match the existing
  mutation signatures as simple ordered token sequences from any executable
  position; make producer failure normative; explicitly de-claim alternate
  object availability, native non-cooperative delegation detection, and
  per-worker isolated worktrees; and remove obsolete fake-update artifacts.
- Consequences: The schema remains syntactic and may conservatively reject a
  harmless argv that contains a declared mutation signature in order. External
  alternate equality is not object-availability proof. Orca chooses the
  execution context; Flow42 records it and applies ownership/barriers. Update
  coverage is no longer presented as live harness convergence.
- Actor: coordinator, based on correctness task `task_152eb018de10`, security
  task `task_e5ea5198d28b`, and remediation tasks `task_0ea95ccbf085`,
  `task_2f550b2a490e`, and `task_e0eeca0cffe7` in Orca run
  `run_b5ab6e7b3014`.

## 2026-09-01T15:02:21Z — close case-insensitive executable-name escape

- Context: The second exact-head correctness review of
  `6b31d2491e2adfa59295eff08cd4f3c2a6c4d8ad` passed. Claude Opus security
  review reproduced `Git`, `GH`, `RM`, `Kubectl`, and wrapper-plus-case variants
  resolving to real tools on case-insensitive macOS while bypassing lowercase
  policy comparisons.
- Decision: ASCII-casefold only the candidate executable basename before the
  existing authority-bearing executable, blocked-launcher, and declared
  mutation-signature comparisons. Keep the inventories unchanged. Bind the
  update skill's unexpected Git-environment rejection with one structural
  mutation. Leave PATH-resolved trusted release tools within the already
  disclosed trusted-installed-tools boundary.
- Consequences: Named case variants fail closed on every supported shell without
  a launcher denylist or full command parser. Arbitrary renamed binaries and
  repository scripts remain an explicit semantic residual inside Orca's
  execution and ownership boundary.
- Actor: coordinator, based on correctness task `task_b0c3ab54f3eb` and Claude
  Opus security task `task_d20d31e953ec` in Orca run `run_b5ab6e7b3014`.

## 2026-09-01T15:40:23Z — close final parser and ownership alias gaps

- Context: Review of clean head
  `53e22ed4d86badedfd1b6fd4aa07f8ed1c287ea5` reproduced shell-signature
  global-option escapes, `arch`-wrapped `sh`/`xcrun`, long-s executable
  lookalikes first reproduced through APFS, dollar expansion, NUL evidence/status aliasing, and stale build
  worktree wording. Ownership mutations also did not cover permissive worker
  push and Forge-write statements.
- Decision: Keep every executable/signature inventory unchanged and send all
  authority, launcher, shell-evaluation, and mutation families through the
  existing basename-casefolded ordered matcher. Restrict tokens to printable
  ASCII and reject every dollar-bearing token. Reject NUL before evidence marker
  extraction or status parsing with a checked NUL-stripped copy/byte comparison.
  Bind build execution to Orca's exact selected context, and reject staging,
  push, Forge-write, isolated-worktree, and separate-worktree prose drift.
- Consequences: Safe direct `sh tests/...` argv remains valid. The command rule
  remains a syntactic naming boundary, not a full parser or semantic sandbox;
  the launcher list remains unchanged. The portable POSIX implementation uses
  the C locale rather than Unicode normalization, OS branches, or platform-
  specific runtime code. The NUL check is point-in-time input
  validation and does not expand the existing file-identity claim. Recursive
  Git snapshots and broader runtime enforcement remain out of scope.
- Evidence basis: Apple documents Unicode-aware normalization and case
  insensitivity for default macOS APFS, which explains the reproducer but is not
  an implementation dependency. POSIX limits portable utility names to the
  portable lowercase/digit character set, and OWASP recommends positive
  character allowlists plus separate argv. These support the portable ASCII
  boundary rather than OS-specific normalization.
- Actor: dispatched Codex worker `task_b4787edf6b27` /
  `ctx_91c404f68ce9`, under coordinator-owned integration.

## 2026-09-01T16:16:06Z — reject named-shell `c` option clusters

- Context: The exact-head correctness review of
  `f73f99b07e2b2219594fb12151d33696f667f5f6` reproduced `sh -lc`, `bash -xc`,
  and `arch -arm64 sh -lc` command-string evaluation escaping the exact `-c`
  shell signature.
- Decision: In the existing ordered matcher, only while matching the declared
  shell-evaluation family, treat a short ASCII-letter option cluster containing
  lowercase `c` as the declared `-c` token. Preserve every executable,
  launcher, and signature inventory.
- Consequences: The named combined forms fail closed and direct
  `sh tests/conformance.sh` remains valid. The rule is still a conservative
  syntactic naming boundary, not a general shell parser or semantic sandbox;
  unlisted launchers and arbitrary repository executables remain residual.
- Actor: dispatched Codex implementation worker under coordinator-owned
  integration; no staging, lifecycle transition, remote, or Forge authority.
