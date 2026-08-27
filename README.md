# flow42

**From intent to trusted PR, across coding agents.**

Flow42 is an open, artifact-driven agentic SDLC for professional engineers. It
keeps intent, specifications, plans, evidence, and approvals in Git so Claude
Code, Codex, and humans can safely resume the same work without relying on chat
memory.

> V1 development is in progress. Support claims remain limited to paths backed
> by public conformance evidence. Don't Panic.

## Why Flow42

Coding agents are fast, but speed without durable intent and independent proof
creates expensive ambiguity. Flow42 supplies a risk-adaptive loop:

`init → intent → spec → plan → build → verify → PR/MR → maintain`

- one canonical workflow across coding agents;
- human gates where judgment or authority matters;
- vertical slices in isolated worktrees;
- observable red-green for behavior changes and bug fixes;
- independent verification and security escalation;
- GitHub and GitLab through the official `gh` and `glab` CLIs;
- deterministic resume from `.flow42/<work-id>/` artifacts.

## Runtime-free local start

Requirements: your selected coding-agent harness and Git. `gh` or `glab` is
needed only for the corresponding Forge. No Flow42 executable, Python
environment, Node runtime, service, or token store is required.

```bash
git clone https://github.com/stefanriegel/flow42.git
cd flow42
sh scripts/check-parity.sh
```

Install `skills/` through the native skill/plugin mechanism of your harness,
invoke `flow42:init` for a repository, then invoke `flow42:intent` with your
request. The skill creates `.flow42/<work-id>/` directly from the templates.

## Agent installation

Exact install, upgrade, and uninstall commands will be published only after the
native paths have been exercised end to end in both harnesses. Until then, use a
local development checkout; this is deliberately not an unverified support claim.

## Skills

`flow`, `init`, `intent`, `spec`, `plan`, `build`, `verify`, `pr`, `maintain`,
`status`, and `resume`. Claude Code exposes plugin skills as `/flow42:<skill>`;
Codex discovers the same skill directories through its native plugin manifest.

## Safety model

Intent and specification approval are mandatory. High-risk plans, irreversible
actions, publication, merge, and deployment are explicit human gates. Flow42
does not store Forge tokens, force-push, discard unrelated changes, merge, or
deploy on its own.

## Architecture

The canonical contract lives in `core/`; shared skills live in `skills/`;
harness manifests are thin adapters. Repository conformance checks use portable
shell plus `jq`; they are development checks, not a product runtime. See
[core/CONTRACT.md](core/CONTRACT.md).

Documentation: [installation](docs/INSTALLATION.md),
[lifecycle](docs/LIFECYCLE.md), [architecture](docs/ARCHITECTURE.md),
[configuration](docs/CONFIGURATION.md),
[troubleshooting](docs/TROUBLESHOOTING.md), and
[preview migration](docs/MIGRATION.md).

## Status and roadmap

Current milestone: prove the state machine, approval hashing, native installs,
GitHub/GitLab adapters, interrupted resume, and public eval fixtures. See
[ROADMAP.md](ROADMAP.md).

## Contributing

Contributions are welcome after reading [CONTRIBUTING.md](CONTRIBUTING.md).
Please report vulnerabilities through [SECURITY.md](SECURITY.md), not a public
issue.

MIT © Stefan Riegel.
