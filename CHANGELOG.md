# Changelog

## 1.0.0 - release pending

This release is prepared but is not tagged or published.

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

### Security

- Added explicit trust boundaries for repository and Forge content, baseline
  secret/dependency/static checks, immutable release references, and
  fail-closed authenticated approval evidence.

### Known release gates

- The `v1.0.0` tag and release checksum are not published yet.
- Version-changing upgrade proof, current-head authenticated Claude invocation,
  formal dogfood PR reviews, and a CI-green GitLab MR remain unproven.
