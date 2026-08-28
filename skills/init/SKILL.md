---
name: init
description: Initialize Flow42 in a repository by discovering its stack, checks, conventions, risks, and Forge. Use before the first Flow42 work item.
---

# Initialize Flow42

Begin with a read-only onboarding preflight. Confirm that this installed skill
can resolve the Flow42 contract, templates, and all 11 canonical skill
directories. Read the installed manifest version and report it. Do not ask the
user to clone Flow42 or run repository maintainer scripts.

Confirm that the target is a Git worktree and report its root, current branch,
working-tree state, redacted remotes, and repository instruction files. Detect
the Forge from remotes. Check the matching `gh` or `glab` executable and authentication
without printing credentials. If Orca is installed, use `orca status --json`
and treat it as available only when its runtime is ready. Orca absence is not a
failure.

Report the preflight as `ready`, `optional`, and `blocked` items. Missing core
skills, contracts, templates, Git, or required Forge authentication blocks the
dependent operation. A missing optional integration does not block local work.

Perform read-only discovery first: languages, package managers, repository
instructions, architecture docs, test/lint/type/build commands, CI, protected
branches, Git remotes, sensitive paths, and authenticated `gh`/`glab` availability.
Classify risk signals including auth, permissions, secrets, customer data,
networking, payments, infrastructure, migrations, and production configuration.

Propose `.flow42/config.yml` from `../../templates/config.yml` using native file
operations. Never store secrets.
If `CLAUDE.md` or `AGENTS.md` needs Flow42 guidance, show a mergeable patch and
wait for approval; never replace existing instructions. Validate paths and
configuration by rereading them, and report discovered Git/Forge prerequisites.
Represent commands as direct-argv token arrays, never shell strings. Present the
resolved configuration digest for authenticated human approval before execution.
Reject scalar commands and unknown fields or schema versions.
Configuration may add gates but must include every canonical mandatory gate from
`core/workflow.json`; omission blocks initialization.
Persist approval in `.flow42/config-approval.yml`, reverify its Forge comment or
signed commit, and block all configured commands when the digest is stale.
