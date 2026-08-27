---
name: init
description: Initialize Flow42 in a repository by discovering its stack, checks, conventions, risks, and Forge. Use before the first Flow42 work item.
---

# Initialize Flow42

Perform read-only discovery first: languages, package managers, repository
instructions, architecture docs, test/lint/type/build commands, CI, protected
branches, Git remotes, sensitive paths, and authenticated `gh`/`glab` availability.

Propose `.sdlc/config.yml` from `../../templates/config.yml`. Never store secrets.
If `CLAUDE.md` or `AGENTS.md` needs Flow42 guidance, show a mergeable patch and
wait for approval; never replace existing instructions. Validate with
`scripts/flow42.py doctor`.
