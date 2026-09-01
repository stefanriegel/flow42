# Troubleshooting

## Orca is not ready

Every stage preflights `orca status --json` and stops if `runtime.state`
isn't `ready`. Enable orchestration under Orca Settings → Experimental (see
[Installation](INSTALLATION.md)), then retry. Flow42 does not fall back to a
non-Orca path — Orca is required, not optional.

## Confirmation no longer matches the action

Do not proceed. Record the scope change and get a fresh, explicit human
confirmation for the exact high-risk or irreversible action, taken
immediately before it happens.

## Status and history disagree

Enter `blocked`, preserve both files, and present a repair proposal. Do not
rewrite history or increment `state_revision` speculatively.

## Forge CLI missing or unauthenticated

Persist the preflight failure and the exact recovery command. Installation or
login is a human action. Retry the same idempotent Forge operation after
recovery, or set `forge: none` in `.flow42/config.yml` to finish the item
locally instead.

## CI fails

Persist the failing run URL and checks. Take the repair transition back to
`building` for an in-scope fix, or block with a concrete limitation. A fresh
review is required before returning to `pr`, even for a bookkeeping-only fix.

## Worker or worktree conflicts

Stop integration and compare the five bounded observations from
`skills/flow42/core/CONTRACT.md`'s `## Workers and Orca` — `HEAD`, the
`for-each-ref` stream, effective config, the hooks tree, and porcelain
status — before and after the worker. Any change you cannot explain blocks
integration; report exactly which observation moved. Never reset, delete, or
overwrite another slice's worktree to force a clean state.

## Flow42 update fails

`update` reports the installed `policy.json .flow42_version` and refreshes
through the same mechanism that installed it (the skills CLI, or Orca
Settings if that's what pins the version). If the update command itself
fails, the installed skill is untouched — retry it, or point the user at
Orca Settings if versions are pinned there. Flow42 does not verify a signed
release or manage a harness's private skill cache; that trust boundary is the
skills CLI's or harness's, not Flow42's.
