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

## Flow42 update fails

If release verification fails, keep the installed version and report the failed
tag, signature, checksum, or manifest check. If a harness mutation fails, stop
forward progress and use the harness's native commands to reinstall the recorded
previous release. Verify the resulting listing and bundle structure. If recovery
is incomplete, preserve the remaining state and report the exact manual
reinstall command. Do not edit private harness caches or claim byte-identical
rollback when the harness has no supported restore interface. Unrelated project
work may continue while the previous Flow42 installation remains usable.
