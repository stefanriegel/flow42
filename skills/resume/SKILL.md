---
name: resume
description: Safely resume interrupted Flow42 work from persisted artifacts. Use after a new session, interruption, or partial failure.
---

# Resume

Validate filesystem, Git, Forge, artifact hashes, approvals, and state revision.
Compare current branches/worktrees and dirty paths with persisted ownership.
If consistent, continue through `flow`. If inconsistent, stop with a repair
proposal. Never reset, delete, overwrite, or force-push to manufacture a clean
state. Recovery heading may say “Don't Panic”; operational details stay precise.
