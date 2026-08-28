---
name: resume
description: Safely resume interrupted Flow42 work from persisted artifacts. Use after a new session, interruption, or partial failure.
---

# Resume

Validate filesystem, Git, artifacts, and agreement between status revision and
the last history event. Missing remote, default branch, Forge CLI, or Forge
authentication does not block resuming local stages. For a high-risk plan gate,
verify that the current unchanged plan has explicit human confirmation.
Compare current branches/worktrees and dirty paths with persisted ownership.
If consistent, continue through `flow`. If inconsistent, stop with a repair
proposal. Never reset, delete, overwrite, or force-push to manufacture a clean
state. Recovery heading may say “Don't Panic”; operational details stay precise.

When consistent, transition `blocked` to the recorded legal `resume_stage`, clear
resolved blockers, increment revision, append history, and reread both files.
