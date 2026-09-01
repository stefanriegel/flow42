# Evidence: Architecture hardening

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
