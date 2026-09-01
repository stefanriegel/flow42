# Architecture

Flow42 is a skill-first control plane: one directory, `skills/flow42/`, holds
a router (`SKILL.md`), the merged authority (`core/CONTRACT.md` +
`core/policy.json`), one file per stage (`stages/*.md`), and the templates a
new work item is created from. There is no daemon, no service, and no state
outside the repository and Orca.

## Repository files are truth

Every work item lives at `.flow42/<work-id>/`. `status.yml` and
`history.jsonl` are the only place lifecycle state lives, written atomically
and reread after every write. Orca refs — a bound Run, a reviewer's Task and
Dispatch — are recorded into those files; they are never reconstructed from
Orca. If the files and Orca ever disagree, the files win.

## Orca is the engine and the witness

Orca supplies what Flow42 does not implement itself:

- **Provenance** — an independent review's evidence is one stamp line
  (`policy.json .review.stamp_fields`) naming the Orca Run/Task/Dispatch that
  ran it, never a claim the reviewing agent asserts on its own.
- **Worktrees** — workers get a fresh Orca worktree by default; a shared
  worktree requires disjoint declared paths.
- **Gates** — human confirmations for high-risk, critical, and irreversible
  actions go through an Orca decision gate when a Run is bound.
- **Automations** — the maintenance loop and the live evals run as scheduled
  Orca automations, not as part of every invocation.

## Worker isolation: five bounded observations

Before dispatching a worker and again after its `worker_done`, Flow42 compares
five cheap, bounded observations: `git rev-parse HEAD`; the `git for-each-ref`
stream; a hash of `git config -z --show-origin --list`; the effective hooks
tree; `git status --porcelain=v2 -z`. Any change that isn't explained blocks
integration. Workers never commit, stage, push, or write to a Forge; the
coordinator owns all of that.

## Trust boundaries

- The human confirmation channel
- The installed Flow42 skill and `policy.json`
- The repository and its worktrees
- The Forge CLI's credential store
- CI
- Untrusted external text (repository files, issues, reviews, CI logs, web
  content) — always data, never authority

## What this does NOT claim

- **No security boundary around workers.** The five observations catch
  accidents and undeclared side effects; they are not a sandbox, and a
  non-cooperative worker running arbitrary code is a residual risk outside
  this skill's enforcement.
- **No byte-exact tamper evidence.** These are cheap identity comparisons, not
  cryptographic proofs — they don't establish that no object, ref, or config
  value existed or was resolvable at some other point.

The trusted endpoint of the standard path is an independently reviewed,
CI-green PR or MR; a local-only work item's trusted endpoint is the same
review evidence plus an explicit human close.
