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
is available. The local fallback is explicitly lower-tier. Every record requires
independent resolution: Forge and orchestrator results are authenticated, while
the local fallback is a resolver-observed distinct session. Resolution binds
repository and work identity, baseline/reviewed heads, scope/diff/subject,
caller-required correctness or security purpose and policy-minimum-bearing exact
checks, reviewer, exact in-work-item evidence section and digest, valid UTC time,
and verdict. The evidence path is repository/work-derived, and one unique
ordered literal marker pair defines the exact report bytes; links and
caller-selected substitute files fail closed. The receipt binds that review
subject while exact bookkeeping leaves plus declared lifecycle/CI fields remain
receipt-neutral. The required `status.yml.change_request` stays empty; provider,
redacted request URL, request ID, source branch, pushed/reviewed heads, observation
time, and authenticated CLI readback live in `evidence.md` only as a
non-authoritative observation that is revalidated before action. Rename sources,
nested lookalikes, quoted scalar escapes, risk
changes, and non-ancestor heads invalidate the receipt. This does not add a
second human gate or grant authorization authority. The
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
Git worker ownership binds the complete common/worktree administrative trees
without a finite filename allowlist, plus external behavior paths; workers never
commit or stage. Release updates bind the signed candidate to Claude's fetched
marketplace and exact current-project plugin identities with canonical config/
settings targets, exact reproducible source shapes, and two sanitized
point-in-time cache observations, so demonstrated template/filter, wrong-project,
mutable-tag, and same-version substitution failures close. Claude exposes no
documented atomic multi-cache lock, so post-observation same-user mutation remains
an explicit residual boundary rather than a durable installed-byte claim.
