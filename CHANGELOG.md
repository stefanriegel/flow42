# Changelog

## Unreleased / Next

Folding forward the surviving intent of the retired `ROADMAP.md` (removed in
3.0.0): three real-repository dogfoods of the V3 lifecycle, public results
from the scheduled live evals (`evals/live/`, decision 14), and a stable
contract once those results land.

## 3.0.0

V3 is a full rebuild: one self-contained Orca-native skill in
`skills/flow42/` (`SKILL.md` router + `core/CONTRACT.md` + `core/policy.json`
+ `stages/*.md` + `templates/*`) replaces the old 12-skill-directory bundle,
`agents/`, and the seven separate root-level core files.

### Added

- `explore`: an opt-in, pre-lifecycle stage that diverges on 3–6 candidate
  directions and converges on a pick that seeds `intent`.
- Local completion: `verifying → complete` with `forge: none` plus an
  explicit human close — no CI gate required for local-only work.
- A maintenance loop with a durable `.flow42/signals.md` (triage-judged,
  deduplicated), a decision-gated hand-off from a `now` signal into a fresh
  `intent`, and a scheduled Orca automation to run it on a cadence.
- Three structural tests (`tests/structure.sh`, `tests/workflow.sh`,
  `tests/history.sh`) plus 3–5 live agent evals (`evals/live/`) run as
  scheduled Orca automations rather than per-push CI.

### Changed

- **Orca-native.** Orca with a ready runtime is required. The Claude
  marketplace, Codex plugin, and Pi plugin surfaces are dropped; Flow42 is
  distributed as a single skill through the community skills CLI (`npx skills
  add stefanriegel/flow42 --skill flow42`, or `orca skills install`).
- **Review evidence.** The 20-field receipt schema, issuer tiers, resolver
  doctrine, and marker-pair byte digests are replaced by one line in
  `evidence.md`: an Orca run/task/dispatch ref, reviewer agent, review kind,
  verdict, reviewed SHA, and UTC time. The staleness rule is unchanged —
  `reviewed_head` must be an ancestor of, or equal to, `HEAD`.
- **Worker ownership** collapses to Orca worktree isolation by default plus
  five bounded observations (`HEAD`, the ref stream, effective config, the
  hooks tree, porcelain status); workers never commit, stage, or push.
- `agents/*.md` are deleted; specialists are now `orca orchestration
  worker-start` model profiles (`frontier`/`worker`/`utility`, each an
  agent/model/effort default) declared in `policy.json .model_profiles`.
- `status.yml` drops `change_request`. Work-item and policy `schema_version`
  is 3.
- CI slims to the three structural tests, `shellcheck`, and `gitleaks`.
- Version 3.0.0.

### Removed

- The entire V2 plugin bundle, prose-pinning test tier (exact-sentence `grep`
  assertions and `sed` mutation fixtures), and the signed-release `update`
  machinery (`scripts/release-checksum.sh`, `.github/allowed_signers`). See
  [Migration](docs/MIGRATION.md) for the v2 → v3 path.

## Unreleased (pre-3.0.0 hardening, superseded)

This work landed on `fix/architecture-hardening` ahead of the V3 rebuild and
was never tagged as its own release; 3.0.0 replaces the mechanisms it added
(receipt-subject review evidence, NUL-safe ownership fixtures) with the
simpler Orca-provenance model above. Kept here for provenance.

### Added

- A bounded adaptive intent interview with durable question resumption,
  headless blocking, consent-safe recommendations, data minimization, and a
  trivial-change fast path.
- A versioned configuration authority, legal lifecycle repair transitions,
  receipt-subject review evidence, behavioral temporary-Git fixtures for
  NUL-safe ownership and review currency, and structural/text-conformance
  coverage for configuration, lifecycle, and update instructions.

### Changed

- Added a clarification and conservative-default fallback before intent blocking,
  while keeping high-risk or irreversible choices fail-closed.
- Made every direct skill load one canonical contract prelude and hardened Claude
  marketplace syntax with canonical `owner/repo@ref` grammar.
- Narrowed update instructions to trusted signed-release verification before
  mutation, documented harness-native installation and native readback, and
  honest best-effort recovery without private-cache or byte-identical rollback
  claims.
- Kept update proof claims at their actual tiers: local signed-tag/archive and
  checksum verification plus structural/text conformance, not live harness
  update convergence.
- Made local harness installation idempotent and explicit about skipped
  preflight checks.
- Split lifecycle and maintenance commands in workflow schema version 2 and
  strengthened parity, contract, update-ordering, release-checksum, and CI
  coverage against drift and false-green results.

## 2.0.1 - 2026-08-28

### Removed

- Removed obsolete tracked configuration and work-item approval artifacts from
  release archives.

## 2.0.0 - 2026-08-28

### Added

- Added the `update` management skill for immutable-tag upgrades through Claude
  Code, Codex, and Pi.
- Added `scripts/install-local` for validated checkout installation through each
  harness's supported local source mechanism.

### Changed

- Made initialization entirely local and non-blocking when a repository has no
  remote, default branch, Forge CLI, or Forge authentication.
- Made single-agent execution the default and bound multi-agent claims to real
  Orca Run, Task, Dispatch, and `worker_done` provenance.
- Reduced human confirmation to high-risk and irreversible actions, merge,
  deploy, publish, force-push, and destructive operations.

### Removed

- Removed setup issues and comments used only for approval bookkeeping.
- Removed configuration and work-item approval files, artifact approval hashes,
  authenticated Forge-comment provenance, and intent/spec approval gates.

## 1.0.2 - 2026-08-28

### Changed

- Made `init` responsible for harness-native installation and repository
  onboarding checks.
- Streamlined the README and installation guidance for the current release.
- Removed private dogfood repository identifiers from public evidence.

## 1.0.1 - 2026-08-28

### Added

- Pi package discovery and invocation through the same 11 Agent Skills.
- Optional Orca ADE execution with managed worktrees and exact-model terminals.
- Capability-based frontier, worker, and utility model routing.
- Separate task-schedule and data-flow graphs with typed edge contracts.

### Changed

- Solo developers can use a distinct non-implementing exact-head agent review
  when no eligible independent Forge approver exists.
- Signed release archive verification now supports any matching semantic-version tag.

## 1.0.0 - 2026-08-28

The initial signed V1 release is published with deterministic source archives and checksums.

### Added

- Runtime-free intent-to-trusted-PR workflow for Claude Code and Codex, with 11
  shared skills and harness-native plugin manifests.
- Versioned intent, specification, plan, approval, decision, evidence, status,
  and history artifacts under `.flow42/<work-id>/`.
- GitHub and GitLab Forge contracts using the official `gh` and `glab` CLIs.
- Portable shell validation, conformance, security, dependency, and adversarial
  evaluation suites for macOS and Linux.

### Changed

- Removed the preview Python runtime from the supported product and development
  path; Flow42 now relies on harness-native operations, Git, and optional Forge
  CLIs.
- Stabilized lifecycle stages, approval hashing and provenance, stale-approval
  invalidation, recovery, bounded delegation, and human gates.
- Defined solo-developer independent review as a separate non-implementing pass,
  with exact-head PR/MR comment attestations when no eligible reviewer exists.

### Security

- Added explicit trust boundaries for repository and Forge content, baseline
  secret/dependency/static checks, immutable release references, and
  fail-closed authenticated approval evidence.
