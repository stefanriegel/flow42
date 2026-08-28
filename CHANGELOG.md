# Changelog

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
