# Intent: Architecture hardening

- Work ID: `architecture-hardening`
- Risk: medium

## Problem

An exact-head architecture audit found eight material defects across the Claude
update flow, independent-review persistence, configuration validation, worker
ownership, contract reachability, evaluation depth, lifecycle repair, and
install-source grammar. The current suite is green while at least one supported
update path is behaviorally ineffective.

## Desired outcome

Make every material finding either behaviorally fixed or explicitly closed with
evidence. Concentrate each rule behind one load-bearing Module and ensure its
Interface is also the test surface.

## Users

Flow42 maintainers and users of the Claude Code, Codex, and Pi adapters.

## Constraints

- Preserve the seven-file lifecycle and ordinary intent/spec validation.
- Preserve explicit confirmation for high-risk and irreversible actions.
- Keep Flow42 runtime-free; development tests may use temporary fixtures.
- Preserve unrelated branches, worktrees, files, and user-owned state.
- Use Orca-supervised Codex workers with disjoint file ownership when their
  agent identity establishes; on a pre-prompt launcher failure, fence them and
  use native Codex subagents with the same ownership. No worker performs Forge
  writes or delegates.
- Reuse cleanroom work only after current-head review; do not merge its 125-file
  experimental delta wholesale.

## Non-goals

- Publishing, merging, deploying, tagging, or changing live plugin state.
- Reviving `approvals.yml`, config-approval artifacts, or intent/spec gates.
- Claiming physical, remote-CI, or Forge proof from local checks.

## Acceptance signals

- Every consolidated audit finding has a failing behavioral or structural test
  before its implementation and a passing result afterward.
- The complete local validation, test, eval, and ShellCheck matrix passes.
- A non-implementing exact-head reviewer finds no blocking issue.
- Repository and worker ownership remain attributable and no real harness or
  Forge state is mutated.

## Assumptions and risks

The vendor CLI behavior may differ across Claude Code versions, so the update
flow must tolerate both marketplace-removal semantics. Changes to review and
ownership controls are security-sensitive, but local source edits on an
unpublished branch are reversible and create no production effect.
