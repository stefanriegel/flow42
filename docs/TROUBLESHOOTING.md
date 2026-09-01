# Troubleshooting

## Confirmation no longer matches the action

Do not proceed. Record the scope change and obtain fresh explicit human
confirmation for the exact high-risk or irreversible action.

## Status and history disagree

Enter `blocked`, preserve both files, and present a repair proposal. Do not
rewrite history or increment revisions speculatively.

## Forge CLI missing or unauthenticated

Persist the preflight failure and exact recovery command. Installation or login
is a human action. Retry the same idempotent Forge operation after recovery.

## CI fails

Persist the failing run URL and checks. Return to build for an in-scope fix or
block with a concrete limitation. Never mark the request trusted while CI fails.

## Worktree ownership conflicts

Stop integration, preserve every worktree, and compare the plan ownership map to
the changed paths. Do not reset, delete, or overwrite another slice.

## Claude update tree attestation fails

Treat the update as failed even when source, tag, and version strings look
correct. Preserve the reported failed phase, let the declared transaction
restore the prior marketplace and plugin versions, and verify that rollback
readback. A missing `installLocation`/`installPath`, wrong `projectPath`,
linked settings target, unsupported source shape, force-moved tag, malformed or
multiply linked `.in_use` marker, unexpected cache file, or
byte/mode/path mismatch requires investigation. Never bypass the tree comparison
or claim immutable installed bytes: the supported proof is two consecutive
point-in-time observations, and a same-user cache writer can act after them when
no documented vendor lock exists.
