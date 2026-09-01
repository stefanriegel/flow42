# Architecture

Flow42 is a skill-first control plane. The harness interprets the canonical
skills, Git provides durable history and isolation, and official Forge CLIs
provide authenticated external operations. Flow42 adds no process or service.

The shared contracts are `core/CONTRACT.md` and `core/workflow.json`. Harness
manifests expose the same `skills/` and optional specialist definitions. Work
state resides only in `.flow42/<work-id>/`; conversation context is never a
source of truth.

The single-agent path is the default. The orchestrator owns scope,
confirmations, integration order, and recovery when the user requests
multi-agent work or independent slices materially benefit from parallelism.
Workers receive bounded slices in isolated worktrees, cannot delegate, and
cannot authorize their own implementation. Independence is role separation: a
separate review pass or agent did not implement the change. Its durable JSON
receipt uses the strongest issuer available: authenticated Forge, trusted
orchestrator, or a distinct local independent pass when neither stronger source
is available. The local fallback is explicitly lower-tier. Forge and orchestrator
records require independent authenticated resolution that binds repository and
work identity, baseline/reviewed heads, scope/diff/subject, reviewer/checks, and
artifact digest as well as verdict. The receipt binds that review subject while
exact bookkeeping leaves, plus declared lifecycle/CI fields and a grammar-valid
`change_request` in `status.yml`,
remain receipt-neutral. Rename sources, nested lookalikes, risk changes, and
non-ancestor heads invalidate it. This does not add a second human gate or grant authorization authority. The
trusted endpoint is an independently reviewed, CI-green PR/MR.

Orca orchestration is used only through its live CLI-served contract. A real
Run, Task, and Dispatch plus `worker_done` settlement distinguish orchestration
from ordinary subagents or terminal management. Missing Orca falls back to the
single-agent path.

Planning represents two related graphs. The task schedule graph defines jobs,
dependencies, parallelism, and synchronization barriers. The data flow graph
defines the typed artifacts crossing those boundaries. Keeping them separate makes
parallel execution recoverable and lets validators reject incomplete or fabricated
worker output before integration.

Jobs select a capability profile rather than a globally fixed model. Frontier models
own ambiguous planning and synthesis, worker models own bounded implementation and
specialist review, and utility models own mechanical transformations. See
[model routing](../core/MODEL-ROUTING.md).

Trust boundaries are the human confirmation channel, repository and worktrees,
agent harness, Forge CLI credential store, CI, and untrusted external text.
