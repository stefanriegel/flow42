---
name: flow
description: Advance a Flow42 work item through the next safe SDLC phase. Use when the user asks to start, continue, or run the full engineering flow.
---

# Flow42 Orchestrator

Treat `.flow42/<work-id>/` artifacts as truth. Read `../../core/CONTRACT.md`,
`../../core/workflow.json`, repository instructions, and the active work item.

1. Preflight Git status, repository instructions, Flow42 config, Forge CLI, and persisted state.
2. Select the work item explicitly if more than one is active.
3. Verify upstream approval hashes before trusting approved artifacts.
4. Classify risk by blast radius, reversibility, data, auth, external effects,
   infrastructure, migration, money, and production exposure.
5. Run the next safe phase using the corresponding Flow42 skill.
6. Atomically update status, increment its revision, append one history event,
   reread both files, and persist evidence before reporting progress.
7. Stop at intent/spec approval, high-risk plan approval, irreversible actions,
   external publication, merge, or deployment.

Delegate only bounded vertical slices with disjoint ownership in isolated
worktrees. Set an explicit worker limit no greater than configured concurrency
and forbid workers from delegating. The orchestrator alone integrates in plan
order after slice gates pass and owns recovery and final accountability.

Default endpoint: independently reviewed, CI-green PR/MR ready for human action.
Never merge or deploy without explicit approval.
