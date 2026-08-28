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
