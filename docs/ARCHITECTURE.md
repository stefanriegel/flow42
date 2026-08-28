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
their own implementation. Independence is role separation: a separate review
pass or agent did not implement the change. In a solo-owned repository, its
exact-head verdict may be a SHA-pinned PR/MR comment instead of a formal Forge
approval. This does not add a second human gate or grant approval authority. The
trusted endpoint is an independently reviewed, CI-green PR/MR.

Trust boundaries are the human approval channel, repository and worktrees,
agent harness, Forge CLI credential store, CI, and untrusted external text.
