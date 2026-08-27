# Architecture

Flow42 is a skill-first control plane. The harness interprets the canonical
skills, Git provides durable history and isolation, and official Forge CLIs
provide authenticated external operations. Flow42 adds no process or service.

The shared contracts are `core/CONTRACT.md` and `core/workflow.json`. Harness
manifests expose the same `skills/` and optional specialist definitions. Work
state resides only in `.flow42/<work-id>/`; conversation context is never a
source of truth.

The orchestrator owns scope, approvals, integration order, and recovery. Workers
receive bounded slices in isolated worktrees, cannot delegate, and cannot approve
their own implementation. The trusted endpoint is a reviewed, CI-green PR/MR.

Trust boundaries are the human approval channel, repository and worktrees,
agent harness, Forge CLI credential store, CI, and untrusted external text.
