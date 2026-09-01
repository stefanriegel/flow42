# Evidence: Architecture hardening

This file is chronological. Update-convergence and private-cache observations
recorded before the `2026-09-01 update simplification repair` describe the
historical implementation at those subjects; they were superseded and are not
current proof for the simplified update interface.

- 2026-09-01T05:37:26Z; baseline
  `65a7910b9b2ec1d44aa5724b13a319633d69bcc3`; clean worktree; expected complete
  existing suite green; actual all validation, parity, conformance, contract,
  update, release-checksum, security, dependency, eval, case-eval, ShellCheck,
  and `git diff --check` checks passed.
- 2026-09-01T05:37:26Z; source reconciliation; expected current main to include
  completed handoff work; actual `origin/main` includes merged PRs #15 and #16,
  while every T1-T17 entry in `/Users/sr/orca/flow42-HANDOFF.md` is marked done.
- 2026-09-01T05:37:26Z; architecture reuse check; expected experimental
  cleanroom branch to require selective review; actual delta is 125 files and
  prior exact-head reviews recorded blocking semantic/provenance gaps, so no
  wholesale integration is accepted.
- 2026-09-01T06:00:27Z; Opus architecture adjudication; dispatch
  `ctx_8a3345a7b3fc`; expected all eight findings to have implementation-ready
  red tests and disjoint ownership; actual report
  `/tmp/flow42-architecture-remediation-design.md` covers F1-F8, records five
  defaults, and reports no blocking question. Repository and Forge state were
  untouched; isolated Claude CLI experiments reproduced the multi-scope update
  no-op and verified install-then-update convergence.
- 2026-09-01T06:02:11Z; contract-prelude integration barrier; expected every
  direct skill entry point to reach the same contract before workers diverge;
  actual identical prelude added to all 12 skills. Dirty-baseline porcelain-v2
  digest after the barrier is
  `5b4303b21bdaecd20f5543dfa6d3d8aecb23e8508fd4f8f5119eecda60b84b0a`.
- 2026-09-01T06:05:00Z; intent safe-fallback red; command `sh tests/intent.sh`;
  expected new clarification/default contract to fail before implementation;
  actual exit 1 with nine missing requirements and two missing ordering
  relationships. Green after implementation: exit 0 and all seven adversarial
  mutations rejected, including immediate blocking and unsafe authorization.
- 2026-09-01T06:06:00Z; primary-source review; expected external guidance to
  corroborate the update and ownership designs; actual current Claude Code docs
  specify `owner/repo@ref`, preserve installed state when another declaration
  survives, uninstall only on last-scope removal, and expose `plugin update`;
  current Git documentation recommends `-z` and describes both rename paths as
  NUL-separated. These sources agree with F1, F4, and F8.
- 2026-09-01T06:09:00Z; Orca Codex launch attempt; tasks
  `task_a72ff7f1d17a`, `task_3da236c4afda`, and `task_14a2017b66c6`; expected
  three xhigh Codex workers; actual all three terminals stalled at common MCP
  startup before agent identity, transcript, or repository edit. Dispatches
  `ctx_07e59afe8ebb`, `ctx_c214a8551392`, and `ctx_63866b27f232` were fenced;
  native Codex subagents were started with the same disjoint ownership instead.
- 2026-09-01T06:18:00Z; Update Adapter slice; expected the plugin-preserved fake
  to expose the old success-looking no-op; actual red exit 1 at version 1.0.1
  after `install` returned success. Green `sh tests/update.sh`, parity, and
  conformance prove install-then-update convergence for plugin-removed,
  plugin-preserved, and multiple installation scopes, plus rollback/source-kind
  fidelity and canonical `owner/repo@ref` grammar.
- 2026-09-01T06:20:00Z; ownership/reachability/eval slice; expected line-based
  Git collection and missing agent authority pointers to fail; actual red
  diagnostics `OWNERSHIP-NUL-STATUS` and missing agent pointer. Green temporary
  Git behavior covers spaces, tabs, newlines, UTF-8, leading dashes, deletion,
  both rename endpoints, literal pathspecs, and already-dirty overlap; all 12
  skill preludes agree byte-for-byte, and all four agent authority pointers are
  present.
- 2026-09-01T06:23:00Z; control-plane slice; expected absent schema, undeclared
  lifecycle nodes, and the receipt fixed point to fail; actual red diagnostics
  `CONFIG-SCHEMA-MISSING`, `LIFECYCLE-UNDECLARED-NODE`, and missing
  receipt-neutral policy. Green focused tests validate configuration, repair
  transitions, receipt shape/issuer strength, and NUL-safe currency.
- 2026-09-01T06:28:00Z; coordinator adversarial review; expected focused tests
  to reject integration-level mutations; actual three additional reds exposed:
  root `evidence.md` incorrectly counted receipt-neutral, a disconnected
  `pr-ready` remained accepted, and unsafe base-branch syntax was not validated.
  The repaired tests now restrict neutrality to the reviewed work item, prove
  forward and endpoint reachability, validate base branches and protected paths,
  and require update verification to cover every prelude authority.
- 2026-09-01T06:30:15Z; whole-tree local verification; dirty-snapshot digest
  `b3b80554d5059b910b903afebfa2e87d6799fff04e685b4b9e629529af1f662a`;
  expected every available local gate green; actual parity, validation,
  conformance, contracts, update, release checksum, security, dependencies,
  14-check eval index, eight structural case evals, ShellCheck, dash focused
  checks, and `git diff --check` passed.
- 2026-09-01T06:47:21Z; exact-head independent Codex review; reviewed head
  `1883c384b1d6d1158d546d65228b51a15f9e7f7c`; reviewer
  `/root/independent_review`; expected adversarial review to distinguish green
  fixtures from real safety behavior; actual verdict BLOCKED with five HIGH and
  two MEDIUM findings. Reproducers exposed rollback loss under `sh -e`, unsafe
  configured argv and invalid Git refs accepted by the schema validator,
  committed rename source loss, unauthenticated trusted-receipt claims, a
  `blocked` to `complete` resume path, proof-tier drift, and the missing threat
  model. The work item returned from `verifying` to `building`; no receipt was
  issued and no Forge state changed.
- 2026-09-01T06:49:20Z; tool-less Opus 5 diff review through the local Claude
  wrapper; reviewed baseline-to-head diff
  `65a7910b9b2ec1d44aa5724b13a319633d69bcc3..1883c384b1d6d1158d546d65228b51a15f9e7f7c`;
  expected an independent architecture/security challenge with no repository
  tools; actual second attempt completed with `VERDICT: BLOCKED`. It confirmed
  the rollback defect and additionally identified receipt rename/risk currency,
  review-loop enforcement, unmerged ownership records, unsafe worktree paths,
  heterogeneous-scope rollback, and false eval-tier claims. The first attempt
  emitted a tool request despite receiving no tools and was discarded as
  unusable evidence. Opus performed no repository or Forge mutation.
- 2026-09-01T06:51:04Z; primary-source remediation check; expected the repair
  primitives to match their providers' actual contracts; actual
  [Git diff options](https://git-scm.com/docs/diff-options) document
  `--name-status -z` as status plus unmodified NUL-terminated pathnames and
  `--no-renames` as disabling rename folding, while
  [Git check-ref-format](https://git-scm.com/docs/git-check-ref-format.html) is
  the branch-name authority. [SLSA provenance](https://slsa.dev/spec/v1.0/provenance)
  verification requires authenticated signer/builder identity and a matching
  subject digest; [GitHub's attestation guidance](https://docs.github.com/en/actions/concepts/security/artifact-attestations)
  similarly binds repository, workflow, commit SHA, and OIDC identity and
  states that unverified attestations provide no security benefit. These
  sources support endpoint-safe Git parsing, delegating ref validation to Git,
  and rejecting self-asserted trusted receipt labels.
- 2026-09-01T07:15:18Z; independent-review remediation; expected every HIGH and
  MEDIUM reproducer plus integration-discovered seam to fail before its repair
  and pass afterward; actual update rollback now executes as one strict
  transaction and restores exact state after 18 before-effect, 18 after-effect,
  and six post-condition failures across GitHub, Git, and directory sources.
  Config fixtures reject shell evaluation, path-qualified and wrapper-obscured
  destructive commands, Git/Forge/Terraform option hiding, invalid refs including
  `@{-1}`, unsafe paths, duplicate keys, and unsupported YAML. Ownership retains
  committed rename/copy endpoints and real unmerged records. Receipt tests reject
  forged strong issuers, non-ancestor heads, rename-to-neutral paths, nested
  lookalikes, risk changes, and duplicate status keys. Lifecycle tests bind a
  non-final resume stage to history and block a third automatic review repair.
  Coordinator review also corrected every skill and worker authority pointer
  from the erroneous grandparent to the actual bundle great-grandparent.
- 2026-09-01T07:15:18Z; post-remediation whole-tree verification; expected all
  available local checks at one dirty snapshot to pass; actual parity,
  validation, conformance, contracts, update, release checksum, security,
  dependencies, 12-check mixed-tier eval index, eight structural case evals,
  ShellCheck, `sh -n`, `dash -n`, `git diff --check`, and focused execution under
  `sh`, `dash`, and `ksh` passed. No general agent runtime, remote CI, Forge,
  release, or deployment proof is inferred from these local checks.
- 2026-09-01T07:32:29Z; second exact-head independent reviews; reviewed head
  `82214519776a1a5a0b0aea38fa76faec3d2241ca` against baseline
  `65a7910b9b2ec1d44aa5724b13a319633d69bcc3`; expected fresh correctness and
  security reviewers to challenge the repaired controls from a clean tree;
  actual both `/root/final_correctness_review` and
  `/root/final_security_review` returned `BLOCKED` and confirmed clean
  before/after state. Executable reproducers exposed Git-alias and generic
  Forge API command-policy bypasses, verified-source substitution during Git
  marketplace updates, unobserved remote/hooks Git-administration mutations,
  receipt replay and unauthenticated claim substitution, and quoted duplicate
  status keys. The reviewers also found the change-request receipt fixed point,
  high-risk gate namespace drift, contradictory repository-instruction
  provenance, and stale persisted threat-model claims. All prior focused and
  whole-tree local checks remained green, demonstrating that those checks did
  not cover these boundaries. This transition consumes review loop 2, the
  configured final automatic repair loop; another blocking final review must
  transition the item to `blocked` rather than start a third repair.
- 2026-09-01T07:32:29Z; independent tool-less Opus 5 review; reviewed the same
  exact baseline-to-head diff through the local Claude wrapper; expected a
  cross-model challenge independent of repository tools; actual verdict
  `BLOCKED`. Opus independently confirmed the Git-alias and generic Forge API
  surfaces, found the blocked-to-abandoned/superseded lifecycle regression,
  and identified missing executable receipt-contract mutation coverage plus
  lower-severity documentation, update-composition, and rollback-no-op gaps.
  Opus performed no repository or Forge mutation.
- 2026-09-01T08:02:17Z; second and final automatic repair integration;
  expected every HIGH/MEDIUM finding from both Codex reviews and the Opus
  challenge to have an executable or explicitly tiered control; actual
  configured argv now rejects all bare/path-qualified Git, GitHub CLI, GitLab
  CLI, and Terraform commands plus empty/whitespace-ambiguous tokens. Temporary
  Git proves why aliases are unsafe without performing an external mutation.
  Ownership identity now includes effective configuration/remotes, hook path
  and content, refs/reftable/pseudo-refs, HEAD, and index. Receipt validation
  binds independently expected repository, work, baseline/head, scope/diff,
  reviewer/check, subject, and artifact identities; it rejects cross-repository,
  cross-work/scope replay and unsupported status YAML while allowing a validated
  change-request link as neutral bookkeeping. Blocked work can be abandoned or
  superseded without a blocked self-loop, and the high-risk gate is consistently
  `high-risk-plan`.
- 2026-09-01T08:02:17Z; update/provenance repair integration; expected exact
  verified-source fidelity and honest instruction provenance; actual GitHub and
  Git marketplace convergence retain the recorded repository/source kind and
  verified tag, directory sources stop before candidate discovery and route to
  `scripts/install-local`, and a pre-effect first-remove failure performs no
  rollback install/update mutation. Composed preflight-plus-transaction cases
  cover candidate mismatch, source readback, installed-version readback, and 18
  mutation points in each of before/after-effect phases across three mutable
  configurations. All 12 skill preludes now distinguish host-assigned precedence
  from authentication. The native Codex observation confirms that an `AGENTS.md`
  can be elevated, but is explicitly not authentication or a security proof;
  the persisted threat model records trusted-base handling as an outer control
  and residual risk.
- 2026-09-01T08:02:17Z; coordinator adversarial integration review; dirty diff
  digest `c377a593f20686233d83ea8b383345e166944d75b4e8764f330e19bf952e6b10`;
  expected owner-green tests not to end review; actual inspection found and
  repaired three additional seams: status canonicalization had erased
  significant title whitespace, command substitution had hidden a trailing
  empty argv element, and the Git-admin fixture did not directly mutate
  `core.hooksPath`. New temporary-repository/fixture regressions reject all
  three, and a nested GitLab merge-request URL remains valid neutral bookkeeping.
- 2026-09-01T08:02:17Z; post-repair complete local matrix; expected all
  available gates green at one snapshot; actual parity, validation,
  conformance, contracts, intent, prelude, ownership, receipt, configuration,
  lifecycle, update, release checksum, security, dependency, 12-check eval
  index, eight structural case evals, ShellCheck, `sh -n`, `dash -n`, JSON
  parsing, and `git diff --check` passed. Focused behavioral suites passed under
  `sh`, `dash`, and `ksh`; the opt-in native Codex instruction-delivery
  observation also passed. `gitleaks` is unavailable. No remote CI, Forge,
  Claude-native parity, authenticated provider, release, deployment, or live
  marketplace claim is inferred.
- 2026-09-01T08:20:05Z; final exact-head correctness review; reviewer
  `/root/final_correctness_review`; reviewed subject
  `bac4ad95e3d9d46fb60c275e6c526cfea7407abd` against baseline
  `65a7910b9b2ec1d44aa5724b13a319633d69bcc3`; expected a clean independent
  pass after the final automatic repair; actual `VERDICT: BLOCKED`. Disposable
  execution proved that accepted `[xcrun,git,push]` can create a remote ref and
  that `.git/info/exclude` can hide an out-of-scope file from both implemented
  ownership snapshots. MEDIUM findings showed lossy YAML escape handling in
  status canonicalization, unrelated neutral change-request URLs, an
  unauthenticated receipt timestamp, and a contract conflict between allowed
  worker commits and blanket ref/HEAD blocking. LOW: earlier durable evidence
  overstated directory-source rollback coverage. The reviewer confirmed exact
  HEAD and a clean tree before/after and performed no repository or Forge write.
- 2026-09-01T08:20:05Z; final exact-head security review; reviewer
  `/root/final_security_review`; reviewed the same exact subject/baseline;
  actual `SECURITY VERDICT: BLOCKED`. It independently reproduced the
  `.git/info/exclude` ownership bypass; proved that a `spellcheck-only` local
  PASS with an unrelated artifact reference/digest still satisfies receipt
  validation because required review kind/check set/artifact bytes are not
  caller-bound; and reproduced a verified-to-installed TOCTOU in which a tag is
  force-moved after candidate verification but before Claude fetches the same
  URL/tag. It also found the neutral change-request URL unbound to repository,
  provider, or reviewed head. Exact HEAD and clean state were confirmed before
  and after; no repository or Forge write occurred outside disposable fixtures.
- 2026-09-01T08:20:05Z; final cross-model attempt; expected tool-less Opus 5 to
  review the identical full diff without repository tools; actual Claude Code
  reached its session limit before returning a review. No Opus verdict or
  evidence is claimed, and no repository/Forge mutation occurred.
- 2026-09-01T08:20:05Z; exhausted-loop disposition; expected
  `automatic_review_limit: 2` to prevent an unbounded third silent repair;
  actual revision 10 transitions `verifying` to `blocked` with
  `resume_stage: verifying` and the four HIGH blocker identifiers. A human
  resume is required before another implementation loop. The exact reviewed
  subject remains `bac4ad95e3d9d46fb60c275e6c526cfea7407abd`; no PASS receipt
  is issued.
- 2026-09-01T08:32:38Z; explicit human resume; expected the exhausted automatic
  review counter to remain unchanged while another reversible local cycle became
  authorized; actual the item stayed `blocked` at revision 10 with
  `review_loops: 2`, three disjoint Codex implementation tasks and three read-only
  adversarial audits were dispatched through Orca run `run_700a4d3f5bac`, and no
  worker staged, committed, mutated Forge state, or launched a delegate.
- 2026-09-01T10:07:27Z; resumed blocker reds and adversarial audit; expected the
  four recorded HIGH findings to reproduce and owner-green tests to receive an
  independent challenge; actual disposable execution reproduced the `xcrun git
  push` authority escape, hidden `.git/info/exclude` path, spellcheck-only local
  receipt with an unrelated artifact, and same-tag verified-to-installed cache
  substitution. The audits additionally exposed omitted reflog/recovery state,
  trailing-newline and invalid-byte effective config paths, link/hardlink
  retargeting, swallowed archive/hash failures, hostile Git clean-filter
  templates, wrong-project plugin entries, and the absence of a vendor cache
  lock.
- 2026-09-01T10:07:27Z; primary-source repair check; expected the generalized
  controls to match provider behavior rather than only the four examples;
  actual [Git repository layout](https://git-scm.com/docs/gitrepository-layout)
  documents `info/exclude`, `info/attributes`, alternates, refs, reflogs, hooks,
  index, and other administrative state, while
  [Git attributes](https://git-scm.com/docs/gitattributes/2.50.0.html) documents
  highest-precedence `$GIT_DIR/info/attributes`. [Claude plugin
  reference](https://code.claude.com/docs/en/plugins-reference) documents copied,
  versioned cache directories and user/project/local scopes. Anthropic tracker
  [issue 69626](https://github.com/anthropics/claude-code/issues/69626) reports
  the currently observed `.in_use/<pid>` JSON and UTC-asctime shape; it is
  corroborating implementation evidence, not a stable documented API.
- 2026-09-01T10:07:27Z; resumed blocker greens; expected all focused adversarial
  suites to pass under every supported local shell; actual `tests/config-schema.sh`,
  `tests/ownership.sh`, `tests/review-receipt.sh`, and `tests/update.sh` passed
  under `sh`, `dash`, and `ksh`. The update cases include hostile templates and
  filters, exact current-project selection with foreign entries ignored, fetched
  and installed tree substitution, valid and malformed runtime markers, and a
  mutation between the first and second full observation. The result is two
  consecutive point-in-time observations, not a durable cache-immutability
  claim.
- 2026-09-01T10:07:27Z; correction to the 2026-09-01T06:18:00Z durable entry;
  the directory-source cases prove a fail-closed stop before candidate discovery
  or mutation, not mutation-time rollback. GitHub, Git, and GitHub-mirror
  fixtures provide the before/after-effect rollback evidence. The earlier phrase
  grouping directory sources with mutation rollback was overbroad; this appended
  correction is authoritative and preserves the evidence log's append-only
  history.
- 2026-09-01T10:24:09Z; coordinator receipt-artifact self-review; expected a
  receipt's digest bytes to be forced by its in-work-item reference; actual red
  `tests/review-receipt.sh` exit 1 reported `accepted bytes that were not
  extracted from its evidence reference` when a different repository evidence
  file was paired with a caller-supplied matching fixture. Green under `sh`,
  `dash`, and `ksh` derives `.flow42/<work-id>/evidence.md`, requires one ordered
  marker pair, hashes only the exact enclosed LF-terminated bytes, and rejects
  substitute bytes and duplicate markers.
- 2026-09-01T10:24:09Z; coordinator update-boundary self-review; expected
  settings/source/runtime metadata to be safe inputs to later Git and Claude
  argv; actual reds showed an option-shaped GitHub source, a linked settings
  file, and a marker with hour 25 were accepted. Green `tests/update.sh` under
  `sh`, `dash`, and `ksh` now canonicalizes and exports the config root, rejects
  linked or multiply linked settings, validates exact reproducible GitHub/Git/
  directory source shapes before discovery, and rejects malformed, invalid-hour,
  symlinked, or hardlinked runtime markers.
- 2026-09-01T10:27:39Z; human-resumed post-repair complete local matrix;
  expected all available gates to pass at one integrated snapshot before the
  resume transition; actual validation, parity, conformance, contracts, intent,
  prelude, ownership, receipt, configuration, lifecycle, update, release
  checksum, security, dependencies, 12-check eval index, eight case evals,
  ShellCheck, `sh`/Dash/Ksh syntax, JSON parsing, `git diff --check`, and the
  opt-in native Codex instruction-delivery observation passed. Focused config,
  ownership, receipt, and update suites also passed behaviorally under `sh`,
  Dash, and Ksh. `gitleaks` is unavailable; no result is claimed for it.

## Known gaps

The human-resumed local repair is implemented, the item resumed to `verifying`,
and focused/aggregate local checks are green; fresh correctness and security
review of one final clean exact head is still required. `gitleaks` is unavailable,
so no gitleaks result is claimed. Two
consecutive Claude cache observations do not provide a vendor lock or durable
immutability against a later same-user writer. No remote CI, authenticated Forge,
merge, release, deployment, or live normal-harness mutation proof has been run.

## Human-resumed final exact-head reviews

Both non-implementing Orca/Codex reviewers inspected exact subject
`bfcb565670e572a977b26296fdc84d11347e94dd` against baseline
`65a7910b9b2ec1d44aa5724b13a319633d69bcc3`, independently matched the
173-path scope digest and raw no-renames diff digest, and confirmed a clean
tree before and after. Correctness returned `BLOCKED` with three HIGH and one
MEDIUM finding. Security returned `BLOCKED` with one CRITICAL, three HIGH,
and three MEDIUM findings. All configured local gates were green; `gitleaks`
was unavailable, and neither reviewer mutated repository, Forge, live Claude
marketplace, release, or deployment state.

The reproduced blocking boundaries are ambient Git template/replacement-object
substitution during candidate verification, an `arch`-wrapped Git authority
escape, unbound external included-config and alternate-object state, mismatch
between Claude's effective marketplace source and the declaration selected for
verification, and rollback success without prior-byte attestation. Git's
[replace documentation](https://git-scm.com/docs/git-replace) confirms that
replacement refs affect Git commands by default and identifies
`GIT_NO_REPLACE_OBJECTS`/`--no-replace-objects` as the opt-out; its
[init documentation](https://git-scm.com/docs/git-init) confirms that
repository initialization consumes templates unless explicitly overridden.

### Final correctness report

<!-- flow42-review-section:final-correctness-bfcb565:begin -->
# Independent final correctness review: architecture-hardening

## Review identity

- Review kind: `correctness`
- Reviewer: non-implementing Orca worker `orca:task_135ee22b123a`
- Repository: `https://github.com/stefanriegel/flow42`
- Work ID: `architecture-hardening`
- Branch observed: `fix/architecture-hardening`
- Baseline: `65a7910b9b2ec1d44aa5724b13a319633d69bcc3`
- Reviewed exact head: `bfcb565670e572a977b26296fdc84d11347e94dd`
- Review subject: `architecture-hardening final exact-head verification`
- Scope: complete baseline-to-subject diff, 173 canonical NUL-sorted paths, 7,728 insertions and 267 deletions.
- Scope digest: `sha256:334ee617e165f8ca051980ae92d9888cc1d6279f9f188f5045fd2ba3beadaa35` (matched the required digest).
- Diff digest: `sha256:251270c075a90541caf8a7fc1122a04025373286bfb9edbdc54485bc5e511123` (matched the required raw no-renames digest).

## Findings

### HIGH — External alternate object databases escape the claimed complete Git-admin snapshot

`core/OWNERSHIP.md:46-65` requires a complete identity that binds alternates and the object database, and `core/OWNERSHIP.md:73-80` says any Git-administration change must block integration. The executable reference hashes only the common and per-worktree Git directories at `tests/ownership.sh:330-340`; its separate external-path collection at `tests/ownership.sh:308-317` covers only excludes and attributes, not the object directories named by `objects/info/alternates`.

A disposable reproducer created an alternate object directory, captured `admin_snapshot`, wrote a new blob only into the external alternate, proved the blob became visible through `git cat-file`, and captured the snapshot again. Both snapshots compared equal and the reproducer printed:

```text
UNDETECTED: external alternate object 3ad725a5dc13b211825788547bde2ba5046691fd became visible while the ownership snapshot stayed identical
```

This leaves worker-visible Git object storage outside the ownership decision even though the contract claims complete object-database coverage. Fail closed when an alternate points outside the captured admin trees, or recursively resolve, canonicalize, link-check, and snapshot every reachable alternate object directory with cycle and producer-failure handling; add the disposable regression to `tests/ownership.sh`.

### HIGH — Claude preflight does not bind the effective marketplace listing to the declaration used for verification and rollback

`skills/update/SKILL.md:104-124` says the marketplace listing identifies the effective source, but the executable preflight only verifies that the listing is an array at `skills/update/SKILL.md:175-178`. It then selects a settings declaration at `skills/update/SKILL.md:180-220` and derives `repository_url` and rollback input from that declaration at `skills/update/SKILL.md:250-268` without comparing the effective listing entry to it. Rollback later re-adds the declaration-derived source at `skills/update/SKILL.md:656-670`; its listing reconciliation at `skills/update/SKILL.md:614-620` checks only the number of `flow42` entries.

A disposable fake returned an effective marketplace entry for `effective-other/flow42@v9.9.9`, a settings declaration for `declared/flow42@v1.0.1`, and a valid current-project plugin entry. The shipped preflight exited zero, selected `https://github.com/declared/flow42.git`, and printed:

```text
ACCEPTED: effective marketplace source differs from the declaration selected for verification and rollback
```

The updater can therefore verify one repository, remove a different effective marketplace, and call restoration complete after adding the declaration-derived source rather than the original effective source. Canonicalize the listing's exact source object and require it to equal the uniquely selected settings declaration before candidate discovery or mutation; cover GitHub, Git, scope/project, and mismatch cases behaviorally.

### HIGH — Rollback success is not bound to restored plugin bytes

Target convergence now attests marketplace and plugin trees, but rollback verification at `skills/update/SKILL.md:623-653` checks only the declaration, selected identities, and reported prior version. It never reads each restored `installPath` or compares a restored tree with a pre-mutation identity. `flow42_claude_abort_update` nevertheless reports `recorded state restored` at `skills/update/SKILL.md:695-702`, and the explanatory contract at `skills/update/SKILL.md:798-815` likewise treats source and version readback as restoration.

A disposable reproducer supplied the expected prior source, scope, project path, and version while returning `installPath: /tmp/substituted-old-version-cache`. `flow42_claude_verify_recorded_state` exited zero and printed:

```text
ACCEPTED: rollback verification reported restored state without reading or attesting the restored installPath bytes
```

If the prior semver ref or cache is substituted during failure recovery, rollback can accept attacker-controlled or corrupt code carrying the expected version string. Before mutation, capture a sanitized tree identity for every selected installed prior cache and the effective prior marketplace; after rollback, require exact identity restoration, or explicitly fail closed and report rollback incomplete when exact prior-byte restoration cannot be established.

### MEDIUM — The persisted threat model still grants a worker staging exception that the canonical ownership contract removed

`evidence/security/threat-model.md:33` states that workers may not mutate Git administration “except an explicitly authorized exact staging operation.” The repaired canonical rule forbids worker staging and reserves exact staging to the coordinator only at `core/OWNERSHIP.md:73-80` and `core/OWNERSHIP.md:94-98`; `skills/build/SKILL.md:43-48` and `docs/ARCHITECTURE.md:57-60` agree with the canonical rule.

This is stale security evidence for the same boundary revision 10 repaired, and the current suites do not compare the threat-model statement with the load-bearing contract. Remove the worker exception or explicitly name coordinator-only post-worker staging, then add a cross-document mutation check so the persisted threat model cannot regress independently.

## Revision-10 and adjacent repair assessment

- xcrun authority: repaired for the documented forms. `tests/config-schema.sh` used the available Xcode `xcrun` to create a ref in a disposable bare remote, then proved bare/path-qualified and option-bearing xcrun argv are rejected. The broader command policy remains explicitly a syntactic boundary, not a semantic sandbox.
- Git-admin ownership and producer failures: the in-tree common/worktree, reflog/recovery, external hook/ignore/attribute, link, malformed-path, tar-failure, and hash-failure cases pass under all supported local shells. External alternate object storage remains a blocking omission.
- Receipt v2: current fixtures pass purpose, exact-check-array, artifact reference-to-bytes, real calendar time, issuer resolution, local-session distinction, status grammar/currency, and evidence-only Forge-link tests. No live authenticated Forge or provider receipt was resolved in this review.
- Claude candidate/fetched/installed identity: candidate, fetched marketplace, current-project selection, settings links, hostile templates/filters, runtime markers, installed cache substitution, and two point-in-time target observations pass the shipped fixtures. Effective-source mismatch and rollback byte identity remain blocking.
- Project/config/source/link handling: canonical roots, exact `projectPath`, one declaration, supported source shapes, linked settings, and runtime-marker links are covered. The effective listing is not compared with that declaration.
- Rollback: before/after-effect command failures and source/version restoration pass the fake harness matrix, but the success predicate remains byte-blind.
- Portability: all focused suites passed under macOS `/bin/sh`, Dash, and Ksh; ShellCheck and syntax checks passed. This is supported-shell proof on Darwin, not Linux execution proof.
- Residual claims: the post-observation same-user Claude cache race is disclosed honestly. The threat-model staging exception is not aligned with the repaired contract.

## Exact checks run

### Identity and diff

```text
git rev-parse HEAD
  bfcb565670e572a977b26296fdc84d11347e94dd
git symbolic-ref --short HEAD
  fix/architecture-hardening
git status --porcelain=v2 -z | wc -c
  0
git config --get remote.origin.url
  https://github.com/stefanriegel/flow42
git merge-base --is-ancestor 65a7910b9b2ec1d44aa5724b13a319633d69bcc3 bfcb565670e572a977b26296fdc84d11347e94dd
  exit 0
git rev-list --count 65a7910b9b2ec1d44aa5724b13a319633d69bcc3..bfcb565670e572a977b26296fdc84d11347e94dd
  5
git diff --name-only --no-renames -z BASE HEAD | LC_ALL=C sort -z | shasum -a 256
  334ee617e165f8ca051980ae92d9888cc1d6279f9f188f5045fd2ba3beadaa35
git diff --name-only --no-renames -z BASE HEAD | tr -cd '\000' | wc -c
  173
git diff --raw --no-renames -z --abbrev=64 BASE HEAD | shasum -a 256
  251270c075a90541caf8a7fc1122a04025373286bfb9edbdc54485bc5e511123
git diff --check BASE HEAD
  exit 0
```

### Repository and configured gates

All of these exited zero:

```text
sh scripts/check-parity.sh
sh scripts/validate.sh
sh tests/conformance.sh
sh tests/contracts.sh
sh tests/update.sh
sh tests/release-checksum.sh
sh tests/security.sh
sh tests/dependencies.sh
sh evals/run.sh
sh evals/cases/run.sh
sh evals/cases/run.sh --dry-run
shellcheck scripts/*.sh scripts/install-local tests/*.sh
sh -n scripts/*.sh scripts/install-local tests/*.sh evals/*.sh evals/cases/*.sh
dash -n scripts/*.sh scripts/install-local tests/*.sh evals/*.sh evals/cases/*.sh
ksh -n scripts/*.sh scripts/install-local tests/*.sh evals/*.sh evals/cases/*.sh
jq -e . core/*.json evals/*.json evals/cases/*.json .claude-plugin/*.json .codex-plugin/*.json
```

The configured lint command is covered by the broader ShellCheck invocation, and the configured test command `sh tests/conformance.sh` passed directly.

### Focused supported-shell matrix

Each of the following passed under both `dash` and `ksh`; the same suites also passed under `/bin/sh` through the direct and aggregate runs:

```text
tests/config-schema.sh
tests/ownership.sh
tests/review-receipt.sh
tests/update.sh
```

### Independent adversarial reproducers

These disposable `/tmp` scripts exited zero only because they demonstrated the named acceptance bug; they did not touch the reviewed repository or a real Forge/harness:

```text
sh /tmp/flow42-external-alternate-reproducer.sh
sh /tmp/flow42-update-source-mismatch-reproducer.sh
sh /tmp/flow42-rollback-byte-reproducer.sh
```

The exact observed outputs are quoted in the findings above. The temporary fixtures and reproducer scripts were deleted after capture.

## Clean-state evidence

- Before review: `HEAD` was exactly `bfcb565670e572a977b26296fdc84d11347e94dd`; `git status --porcelain=v2 -z` contained zero bytes.
- After all repository gates and disposable reproducers: `HEAD` was still exactly `bfcb565670e572a977b26296fdc84d11347e94dd`; `git status --porcelain=v2 -z` still contained zero bytes.
- No repository file, index, ref, Git administration, Forge object, harness cache, or installed plugin state was changed.

## Proof limitations

- `gitleaks` is unavailable locally, so no local gitleaks result is claimed. Dependency and static ShellCheck baselines passed; the full diff was manually inspected for correctness and credential exposure.
- The native-agent provenance probe remained opt-in and was not run. No normal Claude/Codex/Pi agent compliance or harness-parity claim is made.
- Execution was on Darwin 25.4.0 arm64 with Git 2.54.0, jq 1.7.1-apple, ShellCheck 0.11.0, macOS `/bin/sh`, Dash, Ksh 93u+, and zsh 5.9. Ubuntu/macOS CI configuration was inspected, but no remote CI run was observed.
- No internet research, authenticated Forge readback, provider receipt resolution, release, deployment, merge, push, or live marketplace mutation was performed.
- Green repository gates do not override the three executable blockers above or the stale threat-model statement.

VERDICT: BLOCKED
<!-- flow42-review-section:final-correctness-bfcb565:end -->

Coordinator readback immediately after Orca task
`task_135ee22b123a` completed observed SHA-256
`d128e928dc6d8639af7116b17b20aabe18f7185606c5e6f17ee364d1517683ba`
for the exact report above. The trusted task result bound the task, dispatch,
report path, completion time, and `BLOCKED` subject, but its `worker_done` body
was empty and therefore did not bind the artifact digest or the complete
review record required by schema version 2. Resolution fails closed, so no
correctness receipt is issued and this report cannot satisfy the verification
gate.

### Final security report

<!-- flow42-review-section:final-security-bfcb565:begin -->
# Independent final security review — architecture-hardening

## Review identity

- Review kind: `security`
- Repository: `https://github.com/stefanriegel/flow42`
- Work item: `architecture-hardening`
- Baseline: `65a7910b9b2ec1d44aa5724b13a319633d69bcc3`
- Reviewed exact head: `bfcb565670e572a977b26296fdc84d11347e94dd`
- Scope digest: `sha256:334ee617e165f8ca051980ae92d9888cc1d6279f9f188f5045fd2ba3beadaa35`
- Diff digest: `sha256:251270c075a90541caf8a7fc1122a04025373286bfb9edbdc54485bc5e511123`
- Review subject: `architecture-hardening final exact-head verification`
- Required checks: `threat-model`, `baseline-checks`, `configured-repository-security-gates`, `independent-security-review`
- Reviewer: `orca:task_c075cf062c46`, role `independent-reviewer`, implementer `false`
- Artifact reference: `evidence:.flow42/architecture-hardening/evidence.md#final-security-bfcb565`

## Findings

### CRITICAL — Ambient Git templates can substitute attacker content beneath a valid signed tag

**Evidence:** `skills/update/SKILL.md:47-77`, especially the unsanitized `git init`, fetch, verifier invocation, and subsequent `rev-parse`/`git show`; compare the later, sanitized installed-tree repository at `skills/update/SKILL.md:473-503`. This also contradicts the exact signed-candidate-tree requirement at `.flow42/architecture-hardening/spec.md:5-9` and the stated template/config neutralization at `.flow42/architecture-hardening/plan.md:186-190`.

The candidate repository inherits ambient Git template, configuration, object, and replacement-ref state. A disposable signed-tag reproducer placed a malicious commit and `refs/replace/<signed-commit>` in the init template. `git verify-tag` passed for the authentic signed tag, but `refs/tags/v1.0.0^{tree}` resolved to the attacker's tree and `git show refs/tags/v1.0.0:payload.txt` returned attacker content. Observed output was `verify-tag=passed`, good tree `924329ac26dc1761143133e6b4db3f78a7bf66c5`, resolved attacker tree `4ad18adf0a456f962752c93b9e8f3d609caa93d5`, payload `attacker`.

The later marketplace and cache comparisons use `verified_candidate_tree`; after this substitution they prove equality to attacker-selected bytes, not to the tree named by the signed tag. Initialize with an explicitly empty template under a comprehensively sanitized Git environment, disable replacement objects for every verification command (including the trusted verifier subprocess), disable global/system/config injection and alternate object stores, and add a signed-tag replacement-ref regression before treating the trust boundary as closed.

### HIGH — The configured-argv predicate accepts the supported macOS `arch` launcher around `git push`

**Evidence:** `core/config-schema.json:50-80` lists only `xcrun` as a blocked launcher, and `tests/config-schema.sh:61-105` examines only the first executable plus finite prefixes. The threat model claims configured argv cannot hide control-CLI authority at `evidence/security/threat-model.md:30`.

A disposable config using `[arch, -arm64, git, push, origin, HEAD:main]` passed `validate_config`. Executing that exact direct argv against a disposable bare repository changed its ref count from zero to one. Thus a supported-platform launcher bypasses the supposedly shared fail-closed control-CLI predicate and can perform an external Git write with whatever credentials/network authority the configured gate process has.

At minimum, unwrap and reject `arch` with adversarial execution coverage. More generally, a finite launcher denylist cannot support the broad fail-closed claim while arbitrary executables remain allowed; either narrow the claim and isolate configured tools from network/credentials/Git administration, or enforce a structurally bounded executable allowlist at the actual launcher interface.

### HIGH — External included Git config can be changed to a symlink without changing the ownership snapshot

**Evidence:** `core/OWNERSHIP.md:46-71` requires complete Git-admin identity and says the effective config stream keeps included configuration attributable. The behavioral implementation hashes only `git config --null --show-origin --show-scope --list` at `tests/ownership.sh:360-365`; the separately metadata-checked external surfaces are limited to excludes and attributes at `tests/ownership.sh:308-318`.

In a disposable repository with an absolute `[include] path`, replacing the included regular config file with a symlink to an equal-content target produced `admin_snapshot_identical=true` while `included_config_is_symlink=true`. The common/worktree Git trees and effective config bytes/origin strings remain unchanged, so the worker's prohibited external Git-behavior mutation is missed and a later target change becomes an untracked control channel.

Parse every file origin in the exact NUL-delimited effective-config result, canonicalize it without lossy decoding, and bind each origin's type, device/inode/link count, mode, and content before and after dispatch. Reject symlinked or multiply linked external config origins and add this executable regression.

### HIGH — Claude rollback can report restoration without restoring or attesting prior bytes

**Evidence:** `skills/update/SKILL.md:623-653` validates only the recorded source object, selected scope/project identities, and version strings after rollback. `skills/update/SKILL.md:656-700` re-adds the recorded mutable tag and then prints `recorded state restored`; no marketplace or plugin tree attestation is performed on the restored state. The current rollback tests likewise assert declaration/install/version state at `tests/update.sh:846-890`, not restored bytes.

If the recorded old tag moves, or the restored marketplace/plugin cache is substituted while retaining the old version string, rollback can return success with different bytes. The target-path two-observation defense does not repair this because it is not called by `flow42_claude_verify_recorded_state`.

Capture and independently verify the pre-update marketplace and every selected plugin tree, retain immutable old-release identity through the transaction, and attest each restored path to that identity before claiming restoration. If the vendor cannot reproduce and attest the previous bytes, report rollback as incomplete rather than restored.

### MEDIUM — Receipt-currency path collection swallows a failing Git producer

**Evidence:** `tests/review-receipt.sh:450-466` pipes `git diff --name-only --no-renames -z` directly into `jq` under POSIX `sh`; the pipeline status is the consumer's status.

A disposable descendant commit referencing a missing subtree produced `git diff` exit 128 and zero path bytes, while the implemented pipeline exited 0 and the later status-only diff exited 0. The receipt can therefore remain current when the complete changed-path set was not produced, contrary to the fail-closed and NUL-safe claims.

Capture the Git output into a temporary file with the producer's exit status checked directly, then run the NUL parser. Add truncated, unreadable-tree, and partial-producer regressions.

### MEDIUM — Receipt artifact extraction rejects symlinks but accepts hardlinks

**Evidence:** `core/CONTRACT.md:111-116`, `core/SECURITY.md:73-75`, and `skills/verify/SKILL.md:54-60` say links are rejected. `tests/review-receipt.sh:44-63` checks only `test -f` and `test ! -L`.

A disposable two-link evidence file passed the implemented link predicate (`implemented_link_check=true`, `hardlink_count=2`). An external hardlink writer can therefore change the canonical work-item evidence bytes outside the repository path and create a reference-to-bytes TOCTOU that the stated link policy was intended to reject.

Require a regular single-linked evidence file, bind metadata before and after extraction/hash, and add hardlink plus swap regressions. If atomic file identity cannot be maintained through acceptance, disclose and fail closed on the race.

### MEDIUM — Claude settings link validation is not retained across candidate verification

**Evidence:** `skills/update/SKILL.md:138-220` validates the settings file once during preflight and retains only its path/source values. Candidate discovery, fetch, signature, archive, and checksum work then occurs before the transaction at `skills/update/SKILL.md:32-97`; mutations start at `skills/update/SKILL.md:714-725` without rechecking the settings file's device/inode/link count/content identity.

A same-user writer can swap the validated settings path to a link or different file during that interval. Later `jq` readbacks follow the current path, and the Claude CLI may mutate a file different from the one that established scope and source identity. The disclosed cache race at `skills/update/SKILL.md:833-838` does not cover this settings authority race.

Bind the declaring settings file identity and exact relevant bytes through candidate verification, revalidate immediately before every marketplace mutation and readback, and stop on any path/type/link/inode/content change. Record an explicit residual if the vendor provides no settings lock.

## Checks run

The pre-review guard confirmed exact `HEAD` `bfcb565670e572a977b26296fdc84d11347e94dd`, branch `fix/architecture-hardening`, normalized origin `https://github.com/stefanriegel/flow42`, and zero bytes from `git status --porcelain=v2 -z`. Independent recomputation matched the required 173-path canonical NUL-sorted scope digest and the required `git diff --raw --no-renames -z --abbrev=64` digest. The complete 173-path baseline-to-subject diff, work-item artifacts, and persisted threat model were inspected.

All available repository checks below passed locally at the reviewed head:

- `sh scripts/check-parity.sh`
- `sh scripts/validate.sh`
- `sh tests/conformance.sh`
- `sh tests/contracts.sh`
- `sh tests/prelude.sh`
- `sh tests/ownership.sh`
- `sh tests/review-receipt.sh`
- `sh tests/config-schema.sh`
- `sh tests/lifecycle-transitions.sh`
- `sh tests/update.sh`
- `sh tests/release-checksum.sh`
- `sh tests/security.sh`
- `sh evals/run.sh`
- `sh evals/cases/run.sh`
- `shellcheck scripts/*.sh scripts/install-local tests/*.sh`
- `sh tests/dependencies.sh`
- `git diff --check 65a7910b9b2ec1d44aa5724b13a319633d69bcc3 bfcb565670e572a977b26296fdc84d11347e94dd`
- `tests/config-schema.sh`, `tests/ownership.sh`, `tests/review-receipt.sh`, and `tests/update.sh` under both `/bin/dash` and `/bin/ksh`

The repository-configured lint/test argv were therefore covered, and the security-sensitive behavioral suites were run beyond that minimum. A bounded added-line secret heuristic found zero private-key/common-token-pattern matches. `gitleaks` was not installed, so no gitleaks result is claimed.

Disposable adversarial reproducers exercised: the `arch`-wrapped external push; authentic signed-tag verification plus init-template replacement-object substitution; external included-config regular-file-to-symlink replacement; real Git missing-tree producer failure through the receipt pipeline; and a hardlinked evidence artifact. No real remote, Forge, normal Claude/plugin installation, or user repository was mutated by these reproducers.

## Proof limitations

- Local execution was on macOS only. Dash and Ksh portability runs passed locally; no Linux runner or remote exact-head CI was observed.
- The native Codex instruction-delivery probe remained opt-in and was skipped. No native Claude/Codex policy-compliance claim is made.
- `gitleaks` was unavailable. The zero-match heuristic is not a substitute for the pinned CI scanner.
- No authenticated Forge/provider observation, PR/MR, release publication, deployment, or live Claude/plugin mutation was performed.
- Stateful fake-CLI and temporary-Git tests establish only the named local behaviors. They do not authenticate a provider or prove undocumented vendor cache/rollback semantics.
- The two Claude cache observations remain point-in-time observations, not a durable lock. The findings above show additional trust-boundary gaps before that residual is reached.

## Clean-state evidence

Before review: exact subject `bfcb565670e572a977b26296fdc84d11347e94dd` matched and `git status --porcelain=v2 -z` contained zero bytes. After all read-only inspection, local checks, disposable reproducers, and report creation: exact subject `bfcb565670e572a977b26296fdc84d11347e94dd` still matched and `git status --porcelain=v2 -z` still contained zero bytes. No repository file, index entry, ref, Git administration, Forge state, or live plugin state was changed by this review.

## SECURITY VERDICT: BLOCKED

The green configured and aggregate suites do not overcome the reproduced signed-candidate substitution, configured-launcher external-write bypass, undetected external Git-config link mutation, or unverified rollback bytes. These are material trust-boundary blockers at the exact reviewed head.
<!-- flow42-review-section:final-security-bfcb565:end -->

The independent Orca task record for `task_c075cf062c46` resolved the exact
task/dispatch, reviewer, subject fields, checks, blocked verdict, report path,
digest, and orchestrator completion time. Coordinator readback matched the
recorded digest before persistence.

```json
{"schema_version":2,"review_kind":"security","issuer_kind":"trusted-orchestrator","issuer_receipt_ref":"orca:run_700a4d3f5bac/task_c075cf062c46","repository_id":"https://github.com/stefanriegel/flow42","work_id":"architecture-hardening","baseline_head":"65a7910b9b2ec1d44aa5724b13a319633d69bcc3","reviewed_head":"bfcb565670e572a977b26296fdc84d11347e94dd","scope_digest":"sha256:334ee617e165f8ca051980ae92d9888cc1d6279f9f188f5045fd2ba3beadaa35","diff_digest":"sha256:251270c075a90541caf8a7fc1122a04025373286bfb9edbdc54485bc5e511123","review_subject":"architecture-hardening final exact-head verification","reviewer_principal":"orca:task_c075cf062c46","reviewer_role":"independent-reviewer","dispatch_or_session_ref":"orca:ctx_7a80c72205d6","stronger_issuer_unavailable_reason":"not-applicable","implementer":false,"verdict":"blocked","checks":["threat-model","baseline-checks","configured-repository-security-gates","independent-security-review"],"artifact_ref":"evidence:.flow42/architecture-hardening/evidence.md#final-security-bfcb565","artifact_digest":"sha256:678d00ddfa66a6988c2e61b4396899afdfaf991413d939e7bc17ca0a246da67c","recorded_at":"2026-09-01T10:45:48Z"}
```

## Final blocked disposition

The human-resumed cycle returns from `verifying` to `blocked`. The configured
automatic repair limit remains exhausted and the final two allowed workers
have been released after transcript archival. Another repair cycle requires
fresh human resume authority and fresh independent exact-head correctness and
security reviews. No push, PR/MR, merge, release, deployment, or live normal-
harness mutation was performed.

## 2026-09-01 update simplification repair

The user explicitly resumed the local reversible update slice and clarified
that Orca owns worktree, terminal, process, and worker lifecycle. The prior
Claude cache-attestation design was removed rather than extended. The update
skill changed from 846 lines to 114 lines and the update contract test from
1,489 lines to 94 lines. The new boundary verifies the signed release input,
delegates install/reinstall to the harness, checks version and bundle structure,
and describes rollback only as best-effort.

Observed red after replacing the skill but before replacing its obsolete test:
`sh tests/update.sh` exited 1. After the focused test and coupled contracts were
updated, `sh tests/update.sh`, `sh tests/prelude.sh`, `sh scripts/validate.sh`,
and `git diff --check` passed. The complete local CI command matrix then passed:
parity, validation, conformance, contracts, prelude, ownership, review receipt,
configuration schema, lifecycle transitions, update, release checksum,
security, both eval suites, dependencies, ShellCheck, and `git diff --check`.
The native-agent provenance probe remained opt-in and skipped. No gitleaks,
remote CI, Forge action, live plugin mutation, release, or deployment is
claimed.

Coordinator self-review found no concrete security, correctness, performance,
or maintainability defect in the simplified diff. This is not an independent
review receipt. The work item therefore remains blocked pending resolution or
explicit disposition of the non-update findings and a fresh independent review.

## 2026-09-01 architecture promise reconciliation

The user explicitly resumed reversible local work and constrained the repair:
narrow guarantees #1-#3 to reality and Orca's isolation boundary; fix the
receipt producer error and worker-staging contradiction; keep the hardlink
follow-up small; review the independent-review requirement; do not recursively
snapshot external Git config/object stores or grow another launcher denylist.

Claude Opus/high performed the read-only claims adjudication at baseline
`b71743ae64923142928be920d5ba4c71452aeeb6` in Orca task
`task_fc6b5967bd16` / dispatch `ctx_23b264376025`. Its recommended boundary was
implemented by three supervised Codex `gpt-5.6-sol`/xhigh tasks:
`task_819979b284fa` fixed the receipt diff producer,
`task_ccacd8bb7cb4` added the bounded hardlink predicate, and
`task_85c8f2c16fb7` reconciled command, ownership, lifecycle, and staging claims.
Workers neither staged nor committed; the coordinator released each settled
dispatch after processing its result.

Observed red evidence included the old `git diff --name-only -z | jq` pipeline
returning the consumer status after a required tree object was removed, named
control CLIs surviving in later argv positions, missing external Git residual
language, and the threat model's worker-staging exception. The integrated green
checks are `tests/config-schema.sh`, `tests/ownership.sh`,
`tests/review-receipt.sh`, `tests/contracts.sh`, `tests/security.sh`,
`tests/conformance.sh`, `scripts/validate.sh`, `scripts/check-parity.sh`,
ShellCheck, and `git diff --check`.

The resulting claims are deliberately limited. The command predicate rejects
named control CLIs in any position but accepts an unnamed repository script that
invokes one. External included configuration is value/origin/scope-bound, while
equal-value file-identity substitution remains visible as an accepted residual.
External alternate declarations are bound, while their object-store contents
are not; a separately bound ref exposes the integration-relevant change. Review
evidence with more than one observed link is rejected, without claiming atomic
identity against a concurrent same-user writer. Orca, not Flow42, owns process
identity, worker settlement, and cleanup.

Primary-source research supporting the disposition:

- Git configuration includes insert another file's contents and retain origin
  semantics: <https://git-scm.com/docs/git-config/2.44.3.html>.
- Git alternates allow an object store to borrow objects from another object
  store: <https://git-scm.com/docs/gitrepository-layout>.
- POSIX pipeline status without `!` is the last command's status, explaining why
  the old producer failure could be hidden by successful `jq`:
  <https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html>.
- NIST SSDF PW.7 recommends defined code-review processes and recording and
  triaging discovered issues. This supports a risk-selected independent review
  gate, not an unlimited correctness guarantee:
  <https://tsapps.nist.gov/publication/get_pdf.cfm?pub_id=934124>.

This implementation evidence is coordinator evidence, not the required fresh
exact-head correctness or security receipt. No remote CI, authenticated Forge
action, live plugin mutation, release, or deployment is claimed.

### First exact-head review and remediation

Commit `9a112d64f7677ce0148b42f45b98d5a49738ca56` was reviewed from a clean
worktree by two fresh non-implementers. Codex `gpt-5.6-sol`/xhigh task
`task_152eb018de10` returned BLOCKED in
`/tmp/flow42-correctness-9a112d6.md`; Claude Opus/high task
`task_e5ea5198d28b` returned BLOCKED in `/tmp/flow42-security-9a112d6.md`.
Both confirmed the same exact SHA and zero-byte porcelain before and after,
ran the complete local gates with additional `dash` coverage, and preserved
gitleaks, remote CI, native harness, Forge, release, and deployment as separate
unavailable proof tiers. These blocked reports are remediation evidence, not
pass receipts.

The accepted findings were closed in three supervised, disjoint Codex/xhigh
slices. `task_0ea95ccbf085` generalized the unchanged mutation-signature list to
a basename-normalized ordered subsequence starting at any candidate executable
token and made Git producer success plus complete NUL output normative for both
receipt-neutral validation and diff digest derivation. Its red cases covered
`arch ... /bin/rm`, `kubectl` and `helm` global options, `docker --context ...
push`, and `cargo +stable publish`; safe configured gates remained accepted.

`task_2f550b2a490e` replaced the false alternate-object inertness claim with a
disposable latent-ref fixture: adding only the missing external object changed
ref resolvability while the administrative snapshot and bound ref stream stayed
equal. Contracts now say that snapshot equality is not object-availability
proof and integration may rely only on explicitly resolved objects and
identities for the actual baseline, `HEAD`, index, and owned worktree decision.
The same slice records Orca's exact supplied execution context, permits a
current worktree only with disjoint ownership and explicit barriers, and limits
delegation detection to Orca records or native worker reporting.

`task_e0eeca0cffe7` moved update coverage to its actual structural/text tier,
kept the signed-tag/archive/checksum fixture separate, corrected the changelog
and specification, and deleted seven unreferenced files under
`tests/fixtures/update/`. The deletion is recoverable from Git and removes an
executable, unlinted release-archive surface left by the earlier simplification.

After coordinator cross-file integration, the focused configuration,
ownership, receipt, contract, update, evaluation, validation, parity,
conformance, security, dependency, ShellCheck, and `git diff --check` gates all
passed. The opt-in native-agent provenance probe remained skipped. A new exact
subject and fresh independent reviews are still required before this work item
can leave `blocked`.

### Second exact-head review and final bounded repair

At clean subject `6b31d2491e2adfa59295eff08cd4f3c2a6c4d8ad`, Codex
`gpt-5.6-sol`/xhigh task `task_b0c3ab54f3eb` returned PASS and Claude Opus/high
task `task_d20d31e953ec` returned BLOCKED. Claude reproduced a macOS-specific
case-insensitive executable-name escape in the otherwise bounded command-name
policy. The PATH-resolved verifier-tool observation was retained as a LOW
trusted-tools residual rather than expanded into another verifier design.

The final repair casefolds executable basenames under the C locale before the
existing comparisons. Portable adversarial cases now reject `[Git, push, ...]`,
`[GH, pr, merge]`, `[arch, -arm64, Git, push, ...]`, `[RM, -rf, ...]`, and
`[Kubectl, ..., delete, ...]`. The existing executable and signature inventories
are unchanged. `tests/update.sh` also removes the documented Git-environment
rule in a mutation and requires the intended `UPDATE-GIT-ENVIRONMENT`
diagnostic.

Before freezing a new subject, the complete local matrix passed under `sh`, and
the focused configuration and update gates also passed under `dash` and `ksh`.
ShellCheck, JSON parsing, and `git diff --check` passed. The native-agent
provenance probe remained opt-in and skipped; gitleaks, remote exact-head CI,
authenticated Forge/provider observation, live harness/plugin mutation,
release, and deployment remain separate unavailable proof tiers.

### Final bounded remediation at `53e22ed`

The pre-edit guard confirmed exact `HEAD`
`53e22ed4d86badedfd1b6fd4aa07f8ed1c287ea5` and an empty
`git status --short`. Baselines `sh tests/config-schema.sh`,
`sh tests/ownership.sh`, and `sh tests/review-receipt.sh` all passed before the
new adversarial coverage was introduced.

The pre-implementation command reproducer accepted all of
`[sh, -x, -c, echo]`, `[arch, -arm64, sh, -c, echo]`,
`[arch, -arm64, Xcrun, --find, swift]`, long-s variants of `sh`, `bash`, and
`shutdown`, and `[sh, tests/conformance.sh, ${IFS}git]`. After tests alone were
added, the three focused reds were:

- `CONFIG-SHELL-EVALUATION-SIGNATURE-ESCAPE: accepted [sh, -x, -c, echo]`;
- `OWNERSHIP-BUILD-ORCA-EXACT-CONTEXT`; and
- `review receipt accepted distinct NUL evidence bytes for digest extraction`.

The repair routes blocked-launcher singletons, authority-bearing executable
singletons, shell-evaluation signatures, and declared mutation signatures
through `matches_ordered_signature` from any token with ASCII-casefolded
basename and ordered remaining tokens. The inventories are unchanged; no
launcher or full parser was added. Printable-ASCII tokens plus the bare-dollar
rejection close long-s and `${IFS}` forms while preserving direct
`[sh, tests/conformance.sh]`. APFS was only the reproducer: the implementation is
portable POSIX C-locale matching with no Unicode library, OS branch, sandbox,
extra launcher entry, or platform-specific runtime code.

Primary-source disposition: Apple's APFS guide documents Unicode-aware
normalization and case insensitivity on default macOS APFS, making the original
lookalike an environment-specific reproducer. POSIX utility conventions keep
portable utility names in the portable lowercase/digit set, while OWASP's
command-injection guidance recommends positive character allowlists and
separate argv. The implementation follows those portable principles rather
than emulating any filesystem's Unicode folding.

- Apple APFS filename behavior:
  <https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/APFS_Guide/FAQ/FAQ.html>.
- POSIX utility conventions:
  <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>.
- OWASP OS command-injection defense:
  <https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html>.

Receipt evidence and status files now pass through a checked `tr -d '\000'`
copy plus `cmp` before marker extraction or YAML parsing. Executable mutations
prove that distinct NUL-bearing evidence never reaches digest derivation and a
NUL `change_request` cannot canonicalize as empty. The build skill now uses the
exact Orca-provided context/worktree, requiring disjoint ownership and explicit
scheduling/integration barriers for a current worktree. Ownership mutations
cover isolated/separate-worktree drift plus permissive worker staging, push, and
Forge writes without adding runtime enforcement or recursive snapshots.

Green local evidence after implementation:

- `sh tests/config-schema.sh`, `sh tests/ownership.sh`,
  `sh tests/review-receipt.sh`, and `sh tests/contracts.sh` passed;
- the focused configuration, ownership, and review-receipt suites also passed
  under Dash and Ksh, exercising the same POSIX implementation;
- `sh tests/security.sh` passed with the native-agent provenance probe explicitly
  skipped, and `sh tests/update.sh` passed;
- `sh scripts/validate.sh` and `sh scripts/check-parity.sh` passed;
- `shellcheck scripts/*.sh scripts/install-local tests/*.sh` passed after the
  intended literal `${IFS}` fixture received a local `SC2016` directive;
- all repository JSON parsed with `jq -e .`, and `git diff --check` passed.

This is local implementation evidence, not a fresh correctness/security review
receipt. The worker did not stage, commit, change refs, push, mutate Forge,
release, deploy, or delegate. `status.yml` was not transitioned.

### Exact-head `f73f99b` named-shell option-cluster repair

The pre-edit guard confirmed clean `HEAD`
`f73f99b07e2b2219594fb12151d33696f667f5f6`. The supplied independent
correctness review identified one HIGH configured-command bypass: the exact
shell signature token `-c` did not match a combined short option containing
`c`.

After adding only the focused validator cases, `sh`, `dash`, and `ksh`
`tests/config-schema.sh` each failed with exit 1 and:

```text
CONFIG-SHELL-EVALUATION-SIGNATURE-ESCAPE: accepted [sh, -lc, exit]
```

The same executable loop also covers `[bash, -xc, exit]` and
`[arch, -arm64, sh, -lc, exit]`. The implementation extends the existing
ordered matcher only for the declared shell-evaluation family: an ASCII-letter
short-option cluster containing lowercase `c` satisfies its declared `-c`
token. Executable, launcher, and signature inventories remain unchanged, and
the positive `validate_command '[sh, tests/conformance.sh]'` assertion remains.

Green local evidence after implementation:

- `sh`, `dash`, and `ksh` each passed `tests/config-schema.sh`,
  `tests/contracts.sh`, `tests/security.sh`, and `tests/conformance.sh`;
- `shellcheck scripts/*.sh scripts/install-local tests/*.sh` passed;
- `sh`, `dash`, and `ksh` syntax checks passed for the modified validator;
- every tracked JSON file parsed with `jq -e .`;
- `sh scripts/validate.sh`, `sh scripts/check-parity.sh`, and
  `git diff --check` passed.

This remains a portable syntactic naming boundary, not a general shell parser,
launcher inventory, or semantic sandbox. Arbitrary repository executables and
unlisted launchers remain the documented residual. No Unicode/OS-specific
logic, recursive snapshot, or prose-guard family was added. This is local
implementation proof, not fresh exact-head review or remote CI evidence. The
worker did not stage, commit, push, mutate Forge, delegate, or edit
`status.yml`, `history.jsonl`, or `handoff.md`.

## Final exact-head PASS reviews for `739f5b8`

### Correctness report

<!-- flow42-review-section:final-correctness-739f5b8:begin -->
# Independent final correctness review: architecture-hardening

## Verdict

**PASS** at exact subject `739f5b86df0430e5712a0c370c84c3c2bb9b14b4` against baseline `65a7910b9b2ec1d44aa5724b13a319633d69bcc3`.

No CRITICAL, HIGH, or MEDIUM correctness finding remains in the reviewed 166-path baseline diff. This verdict is limited to the repository-local behavior and contracts named below; it is not a security-review substitute, authenticated Forge receipt, remote-CI result, release authorization, or deployment proof.

## Review identity and scope

- Repository: `/Users/sr/orca/flow42`
- Branch observed: `fix/architecture-hardening`
- Baseline: `65a7910b9b2ec1d44aa5724b13a319633d69bcc3`
- Exact reviewed head: `739f5b86df0430e5712a0c370c84c3c2bb9b14b4`
- Ancestry: baseline is an ancestor of reviewed head; 12 commits are in scope.
- Complete scope: 166 canonical NUL-sorted paths; 7,621 insertions and 773 deletions.
- Canonical scope digest: `sha256:61deab84922120a002399aa8df5f7edc6edb699fa2956547f3b7364e2f9dc25d`
- Raw no-renames diff digest: `sha256:db8ac5e02b441fd73b70963df40dd0422da8d9edd3a1814a0d22d8d1ab3102b2`
- Digest commands used `git diff --name-only --no-renames -z ... | LC_ALL=C sort -z` and `git diff --raw --no-renames -z --abbrev=64 ...` with pipeline failure propagation enabled; every producer/consumer exited zero.
- Worktree before review: exact head matched; `git status --porcelain=v2 -z --untracked-files=all` contained zero bytes.

I inspected the complete baseline-to-head diff and the current full authority, workflow, ownership, update, receipt, lifecycle, agent, documentation, test, fixture, and seven-file work-item surfaces. All 166 changed paths are regular tracked files; the diff contains no binary change, symlink, or unexpected mode transition.

## Findings and earlier-blocker disposition

No material blocker remains.

### Configured-command matching

- `tests/config-schema.sh:45-72` implements one `matches_ordered_signature` predicate. It considers every token as a possible executable, strips its path, ASCII-casefolds its basename under `LC_ALL=C`, and matches remaining signature tokens as an ordered subsequence.
- `tests/config-schema.sh:117-154` routes blocked-launcher singletons, authority-bearing singleton executables, named-shell evaluation signatures, and declared mutation signatures through that shared predicate. Intervening/global options and `arch` wrapping therefore do not create a privileged first-token exception.
- The named-shell-only extension at `tests/config-schema.sh:62-65` treats an ASCII-letter short-option cluster containing lowercase `c` as declared `-c`. The shipped cases reject `sh -lc`, `bash -xc`, and `arch -arm64 sh -lc`; additional read-only stream mutations rejected `dash -ec`, `zsh -fc`, both `arch`-wrapped variants, and a path/case/global-option variant under `sh`, `dash`, and `ksh`.
- The authority inventory remains exactly `git`, `gh`, `glab`, and `terraform`; the blocked-launcher inventory remains exactly `xcrun`. Authority, launcher, shell-prefix, and mutation inventories compare byte-for-byte equal to `53e22ed4d86badedfd1b6fd4aa07f8ed1c287ea5`; their combined canonical inventory digest is `700d2cc2c5677317ab79e38b61df2dc9a59bdd7bc66bce80e9a7f527c4d37ee1`.
- `core/config-schema.json:52-76` binds printable ASCII, the empty read-only control-CLI allowlist, the shared matching semantics, and the named-shell cluster rule. `tests/config-schema.sh:104-155` rejects malformed/non-ASCII and dollar-bearing tokens before execution; `tests/config-schema.sh:360-390` exercises Unicode lookalikes and `${IFS}`. `tests/config-schema.sh:414-421` retains safe direct `[sh, tests/conformance.sh]` and validates the configured lint argv.
- No platform branch or Unicode/filesystem emulation appears in the implementation. APFS/macOS is explanatory evidence only; the matcher is portable C-locale awk/grep logic. The deliberately narrowed residual remains accurate: arbitrary repository executables, copied/renamed binaries, and unlisted launchers are not a semantic sandbox.

### Orca context, ownership, and worker authority

- `core/OWNERSHIP.md:6-18`, `skills/build/SKILL.md:27-31`, and the agent/architecture contracts use the exact Orca-provided context and recorded worktree. A current-worktree selection requires disjoint ownership plus explicit schedule and integration barriers; Flow42 does not claim isolated worktrees or independent process-lifecycle enforcement.
- NUL-safe porcelain-v2 and rename-aware tracked-delta parsing, both rename endpoints, dirty overlap identities, literal pathspec staging, unmerged records, and producer failure are exercised in disposable Git repositories by `tests/ownership.sh`.
- `core/OWNERSHIP.md:106-143` consistently forbids worker commits, staging, pushes, Git-administration changes, and Forge writes; coordinator-only exact literal staging occurs only after the post-worker barrier. Cross-document mutations in `tests/ownership.sh:1172-1201` reject permissive staging, push, and Forge-write drift.
- External Git guarantees are correctly narrowed. External include configuration is bound by effective value/origin/scope, not equal-value file identity; external alternate declarations are bound, not recursively snapshotted. The latent-ref and equal-value-link fixtures pin those residuals rather than claiming detection. No recursive snapshot, launcher expansion, sandbox, or verifier redesign is required by the stated contract.

### Receipt, NUL producer, and hardlink boundaries

- `tests/review-receipt.sh:43-70` rejects NUL-bearing evidence before marker extraction and requires a regular, non-symlink evidence file with observed link count one. The hardlink fixture at `tests/review-receipt.sh:325-340` accepts the single-link control and rejects the same artifact after a second link is created.
- The evidence/status NUL mutations reject distinct hidden bytes before digest/YAML interpretation. Receipt currency writes `git diff --name-only --no-renames -z` to a file and checks the Git producer before parsing (`tests/review-receipt.sh:518-535`). The missing-tree fixture at `tests/review-receipt.sh:805-827` reproduces the old POSIX-pipeline false success and proves the current producer-checked path fails closed.
- Review purpose, exact ordered checks, repository/work/baseline/head/scope/diff subject, expected evidence reference and extracted bytes, reviewer/implementer role, strongest available independently resolved issuer, and real observed UTC time are all bound by the v2 receipt tests. Receipt-neutral paths remain exact work-item leaves, status neutrality is field-limited, and Forge observations remain non-authoritative.
- The current work item contains exactly the canonical seven files. `status.yml` is intentionally still `blocked` at revision 12 with `resume_stage: verifying`; the last history record is the matching `verifying -> blocked` revision 12 event. The only persisted v2 receipt is the older blocked security receipt for `bfcb565...`; no stale PASS is claimed for this subject. A coordinator may persist this exact-head result and perform only a legal, independently validated lifecycle transition; this report itself does not mutate lifecycle state.

### Update proof tiers and lifecycle

- `tests/update.sh` is explicitly structural/text-conformance evidence. The separate signed-tag/archive/checksum fixture is local cryptographic evidence. Neither is presented as live Claude/Codex/Pi update convergence, provider authentication, private-cache identity, or byte-identical rollback.
- Update instructions retain installed trusted-root verification, ambient-Git rejection, immutable signed-tag binding, harness-native installation/readback, and honest best-effort recovery without reintroducing private-cache machinery.
- Workflow endpoints, side states, recorded non-final resume targets, blocked self-loop prevention, final-state closure, high-risk gate mapping, and the two-loop automatic repair cap passed executable structural mutations. The current blocked status/history pair is internally legal; correctness PASS alone does not satisfy a separately required security receipt or authorize PR/merge/release action.

## Checks run

All commands below exited zero unless explicitly described as a skipped/unavailable tier.

### Complete local `sh` matrix

- `sh scripts/check-parity.sh`
- `sh scripts/validate.sh`
- `sh tests/conformance.sh`
- `sh tests/contracts.sh`
- `sh tests/intent.sh`
- `sh tests/prelude.sh`
- `sh tests/ownership.sh`
- `sh tests/review-receipt.sh`
- `sh tests/config-schema.sh`
- `sh tests/lifecycle-transitions.sh`
- `sh tests/update.sh`
- `sh tests/release-checksum.sh`
- `sh tests/security.sh`
- `sh tests/dependencies.sh`
- `sh evals/run.sh`
- `sh evals/cases/run.sh`
- `sh evals/cases/run.sh --dry-run`

### Supported-shell portability

Each repository test from `conformance`, `contracts`, `intent`, `prelude`, `ownership`, `review-receipt`, `config-schema`, `lifecycle-transitions`, `update`, `release-checksum`, `security`, and `dependencies` passed under both `dash` and `ksh`; the same tests passed under macOS `/bin/sh`. The targeted added command mutations also passed under all three shells.

### Static, syntax, JSON, diff, and bounded secret checks

- `shellcheck scripts/*.sh scripts/install-local tests/*.sh evals/*.sh evals/cases/*.sh`
- `sh -n`, `dash -n`, and `ksh -n` over repository shell scripts
- `jq -e .` over every tracked `.json` file and every event in the work-item `history.jsonl`
- `git diff --check 65a7910... 739f5b8...`
- Bounded added-diff private-key/common-token heuristic: zero matches (not a gitleaks substitute)

## Unavailable or deliberately unclaimed proof tiers

- `gitleaks` is not installed locally. The pinned CI gitleaks job was inspected but not observed remotely.
- The opt-in native Codex instruction-delivery probe was skipped; no native-agent policy-compliance or Claude/Codex parity claim is made.
- No remote exact-head CI, authenticated Forge/provider receipt resolution, PR/MR, push, merge, release publication, deployment, live plugin/harness mutation, or private-cache observation was performed.
- Execution was on Darwin arm64 with macOS `/bin/sh`, Dash, and Ksh. This is supported-shell local proof, not Linux-runner proof.
- Temporary-Git and fake-resolver suites prove only their named local behavior. They do not authenticate a provider, establish an OS sandbox, or remove the documented same-user concurrency, external-include identity, external-alternate content, arbitrary-executable, or unlisted-launcher residuals.

## Clean-state result

Repository HEAD, index, refs, Git administration, worktree files, and Forge state were not modified by this review. The final exact-head and zero-byte porcelain check is recorded in the task completion after this report was written.
<!-- flow42-review-section:final-correctness-739f5b8:end -->

```json
{"schema_version":2,"review_kind":"correctness","issuer_kind":"trusted-orchestrator","issuer_receipt_ref":"orca:run_b5ab6e7b3014/task_ac232ea4703f","repository_id":"https://github.com/stefanriegel/flow42","work_id":"architecture-hardening","baseline_head":"65a7910b9b2ec1d44aa5724b13a319633d69bcc3","reviewed_head":"739f5b86df0430e5712a0c370c84c3c2bb9b14b4","scope_digest":"sha256:61deab84922120a002399aa8df5f7edc6edb699fa2956547f3b7364e2f9dc25d","diff_digest":"sha256:db8ac5e02b441fd73b70963df40dd0422da8d9edd3a1814a0d22d8d1ab3102b2","review_subject":"architecture-hardening final exact-head verification","reviewer_principal":"orca:task_ac232ea4703f","reviewer_role":"independent-reviewer","dispatch_or_session_ref":"orca:ctx_b1f95926d3d0","stronger_issuer_unavailable_reason":"not-applicable","implementer":false,"verdict":"pass","checks":["acceptance-criteria","baseline-checks","configured-repository-gates","independent-verification"],"artifact_ref":"evidence:.flow42/architecture-hardening/evidence.md#final-correctness-739f5b8","artifact_digest":"sha256:e6cc7cbd42611e23ffc62f11ec98c15ab0499c052962642dab61d390c69b0557","recorded_at":"2026-09-01T16:58:56Z"}
```

### Security report

<!-- flow42-review-section:final-security-739f5b8:begin -->
# Flow42 — Final Independent Security & Threat-Boundary Review

**Verdict: PASS** — no material security blocker.

## Scope and integrity

| Item | Value |
|---|---|
| Repository | `/Users/sr/orca/flow42` |
| Subject (exact SHA) | `739f5b86df0430e5712a0c370c84c3c2bb9b14b4` |
| Baseline | `65a7910b9b2ec1d44aa5724b13a319633d69bcc3` |
| Paths in diff | 166 |
| Insertions / deletions | 7621 / 773 |
| Canonical NUL-sorted scope digest | `61deab84922120a002399aa8df5f7edc6edb699fa2956547f3b7364e2f9dc25d` |
| Raw NUL diff digest | `6dbd968254e1963baef9519b437c7b3779d5093bed9ea8838694973d9df6c3ba` |
| Porcelain before / after | empty / empty |
| Review mode | read-only; no edit, stage, commit, push, or Forge mutation |

Scope digest = `git diff --name-only -z BASE HEAD` → NUL-split → `LC_ALL=C sort` → NUL-joined → SHA-256.
Raw diff digest = `git diff --no-color -z BASE HEAD` → SHA-256.

`git rev-parse HEAD`, `git status --porcelain`, `git stash list`, and `git reflog` were
re-checked after all probing: SHA unchanged, porcelain empty, no stash, reflog tip unchanged.
All mutation testing ran against `git archive` extracts in a scratch directory; the working
tree was never written to.

## Local verification matrix (14/14 PASS)

`check-parity.sh`, `validate.sh`, `conformance.sh`, `contracts.sh`, `prelude.sh`,
`ownership.sh`, `review-receipt.sh`, `config-schema.sh`, `lifecycle-transitions.sh`,
`update.sh`, `release-checksum.sh`, `security.sh`, `intent.sh`, `dependencies.sh`,
plus `evals/run.sh` and `evals/cases/run.sh`. All pass on darwin/BSD userland.

**Unavailable tiers** (not run here, disclosed rather than assumed):
- `ubuntu-latest` / GNU-userland leg of the CI matrix (macOS only locally).
- `shellcheck` and `gitleaks` CI jobs (not installed locally).
- Any live agent or harness runtime — by design, `evals/run.sh` prints
  *"no agent or harness runtime executed"*; all eval tiers are structural or text-conformance.
- Live Forge/network operations — intentionally not exercised.

## Retest of prior security blockers

### Configured-command argv policy

The normative source is `core/config-schema.json` `command_policy`. All 12 skills carry a
byte-identical contract prelude (pinned by `tests/prelude.sh`) that requires reading both
`core/SECURITY.md` and `core/config-schema.json`, so the runtime agent always reaches the schema.

I drove the reference validator (`matches_ordered_signature` / `validate_command` /
`validate_config`, extracted verbatim from `tests/config-schema.sh`) with hostile inputs.

**Short-option clusters containing `c` — all rejected (`CONFIG-COMMAND-SHELL-EVAL`):**
`sh -c`, `sh -lc`, `sh -xc`, `sh -ec`, `bash -lc`, `bash -euxc`, `dash -ec`, `zsh -ic`,
`zsh -c`, `sh --command`, `bash -eux -c`.

**Arch-wrapped and any-position wrappers — all rejected:**
`arch sh -c`, `arch -x86_64 bash -lc`, `arch -arm64 zsh -c`, `/bin/sh -c`,
`arch /bin/bash -lc`, `/usr/bin/BaSh -Lc`, `make deploy git push`, `npx foo terraform apply`.

**Shared matcher families — all four confirmed live** (authority-bearing singletons,
blocked-launcher singletons, shell-evaluation signatures, declared mutation signatures),
each matching from *any* token position with basename ASCII-casefold:
`git push`, `git status`, `git -C sub push`, `gh api -X POST`, `glab api`, `terraform plan`,
`a b c d git push`, `/usr/bin/git push`, `GIT push`, `Terraform apply`, `rm -rf`, `sudo rm`,
`env FOO=1 rm`, `/bin/rm -rf`, `nice -n 5 rm`, `timeout 5 rm`, `xargs rm`, `command rm`,
`eval`, `kubectl apply`, `npm publish`, `docker push`, `xcrun foo`, `a xcrun foo`.

**Safe direct shell script argv — correctly accepted:**
`[sh, tests/contracts.sh]`, `[bash, tests/contracts.sh]`, `[shellcheck, tests/contracts.sh]`,
`[sh, -eu, tests/contracts.sh]`. The evaluation/execution distinction holds.

**Printable ASCII and bare-dollar rejection — all rejected:**
bare `$`, `$HOME`, `${HOME}`, `$(id)`, backticks, `;`, `|`, `||`, `&&`, `>`, `<`,
mid-token `foo$bar`, empty token, trailing empty token, whitespace token, tab,
DEL 0x7f, Latin-1 high byte, non-ASCII `café`, and the Cyrillic homoglyph `рm`.
The repo additionally pins the long-s Unicode casefold trap (`ſh`, `baſh`, `ſhutdown`),
which Unicode-casefolds to `sh`/`bash`/`shutdown` but must fail as non-ASCII.

**One accepted case examined and cleared:** `[SH, -C, ls]` is accepted. This is correct, not a
gap. The executable is casefolded (filesystems may be case-insensitive) but options are matched
case-sensitively, and uppercase `-C` is `noclobber`, not a command string. I confirmed this
empirically against all four shells: `sh -C echo hi`, `bash -C echo hi`, `dash -C echo hi`,
`zsh -C echo hi` all attempt to *open a script file* named `echo`, never evaluate. No exploit.

**OS independence:** the matcher runs under `LC_ALL=C awk`. Identical reject decisions under
`LC_ALL=C`, `en_US.UTF-8`, `tr_TR.UTF-8`, and `tr_TR.ISO8859-9` — the Turkish dotless-i casefold
trap does not move the boundary. Shipped scripts contain no GNU-only constructs;
`stat` has BSD-then-GNU fallbacks and hashers have `sha256sum`/`shasum` fallbacks.

**Schema mutation testing (12/12 caught)** by `config-schema.sh` + `contracts.sh`:
weakening `named_shell_short_option_cluster`, `executable_position`, `executable_normalization`,
`remaining_signature_tokens`, `token_pattern`, `forbidden_token_pattern`, `fail_closed`,
`read_only_control_cli_allowlist`, dropping `terraform`, dropping `dash`/`zsh` shell-eval
prefixes, dropping `rm`, dropping `git push`. Every weakening of the normative policy is caught.

### NUL rejection, evidence extraction, status parsing

`extract_review_section` orders its predicates correctly: regular-file and non-symlink →
link-count-1 → NUL byte-comparison → marker cardinality → extraction. NUL is rejected
**before** any marker inspection or parsing. 14/14 adversarial probes rejected: NUL inside
section, NUL outside section, NUL at EOF, symlink, hardlink (nlink=2), duplicate begin marker,
duplicate end marker, end-before-begin, missing end, marker with trailing whitespace, missing
file, directory, FIFO.

**Digest-collapse proof:** two files differing only by an embedded NUL have distinct raw
SHA-256; the second is rejected before extraction, so distinct bytes cannot collapse into one
extracted digest.

`validate_status_yaml` calls `reject_nul_file` first. 22/22 status probes correct, including
NUL `change_request` (cannot canonicalize as empty), NUL in `schema_version`, duplicate key,
quoted key, missing key, unknown key, anchor, alias, tag, merge key, block scalar, folded
scalar, nested mapping, lossy quoted escape, invalid enums, non-https `forge_item`, negative
`review_loops`, wrong `schema_version`. Canonical quoted scalars without escapes remain accepted.

### Producer status and producer failure

`receipt_is_current` checks the Git diff producer's exit status directly
(`if ! git diff ... >"$diff_paths"; then return 1; fi`) and feeds `jq` from the file by
redirect, so no pipeline can mask producer failure. The suite proves this rather than asserting
it: it builds a repository with a deliberately unlinked tree object, confirms raw `git diff`
now fails, confirms the *old* POSIX pipeline form would still have returned success (masking),
and asserts the current implementation fails closed.

### Hardlink point-in-time boundary

The extractor requires `find <file> -prune -links 1`. Hardlinked evidence is rejected when
observed. `core/SECURITY.md` explicitly declines to claim atomic file identity across
extraction, hashing, resolution, and acceptance, and discloses concurrent same-user replacement
as residual. The claim matches the control.

### Ownership, Orca, delegation, worker prohibitions

`tests/ownership.sh` carries explicit named assertions for every claim in scope:
external Git residuals (`OWNERSHIP-EXTERNAL-GIT-RESIDUALS`, plus four
`EXTERNAL-ALTERNATE-*` assertions including false-inertness and integration-inputs);
Orca worktree (`ORCA-ISOLATED-WORKTREE-CLAIM`, `ORCA-PROVIDED-CONTEXT`, `ORCA-EXACT-WORKTREE`,
`ORCA-CURRENT-WORKTREE-BARRIERS`, `BUILD-ORCA-EXACT-CONTEXT`, `BUILD-CURRENT-WORKTREE-BARRIERS`);
worker process delegation (`DELEGATION-OBSERVATION-BOUNDARY`, `DELEGATION-UNQUALIFIED-BLOCK`,
`DELEGATION-NATIVE-RESIDUAL`, `DELEGATION-FALSE-NATIVE-PROOF`); and worker staging/push/Forge
prohibitions (`WORKER-STAGING-FORBIDDEN`, `WORKER-STAGING-EXCEPTION`, `WORKER-PUSH-EXCEPTION`,
`WORKER-FORGE-WRITE-EXCEPTION`, `WORKER-COMMIT-FORBIDDEN`, `WORKER-HEAD-REF-FORBIDDEN`).
Git-admin snapshotting rejects symlinks, multiply-linked regular files, special files, and
partial `tar`/`shasum` producer output, with dedicated `failing-tar` and `failing-shasum` fixtures.

### Update and receipt proof claims

`tests/update.sh` enforces that the update-instructions eval stays labeled
`text-conformance` and actively rejects an upgrade of that label to `behavioural-reference`
(`UPDATE-EVAL-TIER`). `evals/run.sh` states "no agent or harness runtime executed".
`evidence/security/threat-model.md` names the cluster rule, arch-wrapped coverage, and the
repository-script residual, and explicitly refuses a semantic-sandbox claim. Proof claims are
bounded and honest; no tier is overstated.

### Unchanged inventories

`evidence/install/claude-code.md` records "11 skills and 4 agents" while the repo has 12 skills
and 4 agents. This entry is a **dated historical observation** (2026-08-27 / 2026-08-28) bound to
a named commit `f9a8f77`, not a current-state claim, and the skill count was already 12 at the
baseline — so the discrepancy is pre-existing and not introduced by this diff. Structural
inventory currency is separately enforced: `tests/prelude.sh` pins exactly 12 direct skills
against `core/workflow.json`, and `check-parity.sh` confirms 12 commands and 3 harness paths.
Non-blocking.

## Findings

**No material security blocker.**

### F1 — Low / non-blocking: two `core/SECURITY.md` prose sentences are not text-pinned

Removing the whole named-shell `-c` cluster sentence (lines 44–45), or the any-position
shared-matcher sentence (lines 40–43), from `core/SECURITY.md` survives the entire local
matrix. Verified on a pristine `git archive` extract after discarding one earlier contaminated
result (a background mutation battery had raced on the shared scratch tree; the clean rerun
is the one reported here).

This is prose-only and exposes **no behavior contradiction**:

- The normative source is `core/config-schema.json`, whose
  `named_shell_short_option_cluster` and `executable_position` values are pinned by exact
  equality in `config-schema.sh` and independently caught by 12/12 schema mutations.
- Behavior is pinned by six shell-evaluation argv cases (`sh -lc`, `bash -xc`,
  `arch -arm64 sh -lc`, and three more) and six control-CLI any-position cases, each asserting
  an exact diagnostic code.
- Every skill's byte-identical prelude requires reading `core/config-schema.json`, so the
  runtime agent still receives the rule even with the prose removed.

Recommendation (hardening, not a gate): add a text-conformance grep pinning these two
sentences alongside the existing `core/SECURITY.md` pins in `review-receipt.sh`.

### Out of scope, correctly excluded

Configured argv such as `python3 -c <expr>` is accepted. This does not contradict a stated
guarantee: `core/SECURITY.md` and the threat model both state the predicate is a naming check,
not a semantic sandbox, that the blocked-launcher list is illustrative and non-exhaustive, and
that the worker capability and ownership boundary — not the argv predicate — is the control.
Per the narrowed scope, launcher expansion was not pursued further. No recursive snapshots,
Unicode subsystem, sandbox, or verifier redesign was undertaken; no concrete exploit was found
that would have justified reopening them.
<!-- flow42-review-section:final-security-739f5b8:end -->

```json
{"schema_version":2,"review_kind":"security","issuer_kind":"trusted-orchestrator","issuer_receipt_ref":"orca:run_b5ab6e7b3014/task_7e33797c5026","repository_id":"https://github.com/stefanriegel/flow42","work_id":"architecture-hardening","baseline_head":"65a7910b9b2ec1d44aa5724b13a319633d69bcc3","reviewed_head":"739f5b86df0430e5712a0c370c84c3c2bb9b14b4","scope_digest":"sha256:61deab84922120a002399aa8df5f7edc6edb699fa2956547f3b7364e2f9dc25d","diff_digest":"sha256:db8ac5e02b441fd73b70963df40dd0422da8d9edd3a1814a0d22d8d1ab3102b2","review_subject":"architecture-hardening final exact-head verification","reviewer_principal":"orca:task_7e33797c5026","reviewer_role":"independent-reviewer","dispatch_or_session_ref":"orca:ctx_2b1802ac82a5","stronger_issuer_unavailable_reason":"not-applicable","implementer":false,"verdict":"pass","checks":["threat-model","baseline-checks","configured-repository-security-gates","independent-security-review"],"artifact_ref":"evidence:.flow42/architecture-hardening/evidence.md#final-security-739f5b8","artifact_digest":"sha256:fdadc223b24f4e1eaccba6c55603ee90aad1c93045edf29558f28513fdbdcd7c","recorded_at":"2026-09-01T16:56:49Z"}
```

### Architecture disposition

Claude Code Opus independently returned PASS at exact subject `739f5b86df0430e5712a0c370c84c3c2bb9b14b4`; report `/tmp/flow42-final-architecture-739f5b8.md` had SHA-256 `b31040bcf31fb0f41de510e364f0267946c041d96c8645d0179583aa45e925ad`. The review confirmed the final cluster repair stays inside the one shared matcher, preserves inventories and direct argv, delegates worktree topology to Orca, keeps NUL controls at parse boundaries, and adds no OS branch, Unicode subsystem, recursive snapshot, sandbox, or duplicate update flow. Its three optional cleanups (one mapping cross-check, prose-only drift guards, and mixed-tier eval labels) do not contradict behavior or block this work item and are deliberately not expanded into this bounded repair.
