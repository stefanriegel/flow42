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
  skill preludes and four agent pointers agree byte-for-byte.
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

## Known gaps

Independent receipt-subject review is pending. `gitleaks` is unavailable, so no
gitleaks result is claimed. No remote CI, Forge, merge, release, deployment, or
live normal-harness mutation proof has been run.
