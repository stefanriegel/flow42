---
name: init
description: Initialize Flow42 locally in a repository by discovering its stack, checks, conventions, and risks. Use before the first Flow42 work item.
---

# Initialize Flow42

Begin with a read-only onboarding preflight. Confirm that this installed skill
can resolve the Flow42 contract, templates, and all 12 canonical skill
directories. Read the installed manifest version and report it. Do not ask the
user to clone Flow42 or run repository maintainer scripts.

Confirm that the target is a Git worktree and report its root, current branch,
working-tree state, repository instruction files, and any available redacted
remote/default-branch metadata. Remote, default-branch, Forge CLI, and Forge
authentication discovery is optional and never blocks initialization. If Orca is installed, use `orca status --json`
and treat it as available only when its runtime is ready. Orca absence is not a
failure.

Report the preflight as `ready`, `optional`, and `blocked` items. Missing core
skills, contracts, templates, or Git blocks the dependent local operation. A
missing remote, default branch, Forge integration, or other optional integration
does not block local initialization or local work.

Perform read-only discovery first: languages, package managers, repository
instructions, architecture docs, test/lint/type/build commands, CI, protected
branches, available Git remotes, sensitive paths, and optional `gh`/`glab` availability.
Classify risk signals including auth, permissions, secrets, customer data,
networking, payments, infrastructure, migrations, and production configuration.

Create `.flow42/config.yml` from `../../templates/config.yml` using native file
operations. Never store secrets.
If `CLAUDE.md` or `AGENTS.md` needs Flow42 guidance, report a suggested patch but
do not edit those files during initialization. Init is local: never create setup
issues, PR/MR comments, or other Forge artifacts. Validate paths and configuration
by rereading them, and report optional Git/Forge capabilities separately.
Represent commands as direct-argv token arrays, never shell strings.
Reject scalar commands and unknown fields or schema versions.
Configuration may add gates but must include every canonical mandatory gate from
`core/workflow.json`; omission blocks initialization.
Once the local configuration validates, initialization is complete.
