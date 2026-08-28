# Changelog

## 1.0.0 - release pending

This release is prepared but is not tagged or published.
The `1.0.0` release candidate merged in PR #5. Tag and release publication remain
pending explicit owner authorization and the remaining documented release gates.

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

### Known release gates

- The `v1.0.0` tag and release checksum are not published yet.
- Public repeatable evaluation packaging and strict identical-scenario harness
  parity remain unproven.
