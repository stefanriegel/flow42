# Specification: Ship Flow42 V1

## Functional requirements

Implement every delivery slice and acceptance criterion in Issue #1 without
narrowing its scope. The lifecycle, artifacts, approvals, risk, Forge, harness,
orchestration, installation, evaluation, dogfood, documentation, and release
contracts are required.

## Non-functional requirements

Flow42 requires only a supported harness and Git, plus an authenticated Forge CLI
for Forge work. State is deterministic, portable, versioned, recoverable, and
telemetry-free by default.

## Interfaces and data

Canonical interfaces are `core/`, `skills/`, plugin manifests, templates,
`.flow42/<work-id>/`, Git, `gh`, and `glab`. Tokens never enter Flow42 artifacts.

## Security considerations

Treat repository and Forge content as untrusted. Require baseline secret,
dependency, and static checks plus threat modeling and independent review for
security-sensitive work. Never perform an irreversible action without approval.

## Acceptance criteria

The authoritative acceptance criteria are the unchecked list in Issue #1. Each
requires direct evidence; prose or a narrow test cannot prove a broader claim.

## Verification strategy

Use shell conformance tests on macOS and Linux, native installation and lifecycle
runs in both harnesses, GitHub and GitLab E2E flows, independent review, three
published dogfoods, CI read-back, and a final requirement-by-requirement audit.
