---
name: init
description: Initialize Flow42 in a repository by discovering its stack, checks, conventions, risks, and Forge. Use before the first Flow42 work item.
---

# Initialize Flow42

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
