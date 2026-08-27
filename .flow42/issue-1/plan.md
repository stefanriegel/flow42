# Plan: Ship Flow42 V1

## Vertical slices

1. Remove the runtime and stabilize lifecycle, artifact, approval, and risk contracts.
2. Complete native phase skills, Forge parity, orchestration, and failure evaluations.
3. Prove Claude Code and Codex install, discovery, invocation, upgrade, and removal.
4. Dogfood feature, bug, and maintenance changes across three stacks and both Forges.
5. Finish launch docs, security review, CI, public PR review, and the V1 release.

Each slice remains usable, records evidence, and is independently reviewed.

## Parallelization map

Only disjoint review or dogfood ownership may run concurrently. Workers cannot
delegate. The orchestrator owns integration and the total worker ceiling is four.

## Integration order

Contracts precede harness proof; harness proof precedes dogfoods; all evidence,
review, and CI gates precede release.

## Risks and rollback

This is high risk due to installation and release behavior. Revert individual
reviewable commits; never rewrite published history or remove evidence.
