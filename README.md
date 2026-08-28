# flow42

**From intent to trusted PR, across coding agents.**

Flow42 is an open, artifact-driven agentic SDLC for professional engineers. It
keeps intent, specifications, plans, evidence, and approvals in Git so Claude
Code, Codex, and humans can safely resume the same work without relying on chat
memory.

> The V1 release candidate is merged. The signed `v1.0.0` tag and release remain
> pending, and support claims stay limited to paths backed by public conformance
> evidence. Don't Panic.

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

## 90-second quickstart (pending release evidence)

The 90-second claim is pending a signed published `v1.0.0` tag and a timed
end-to-end work-item run. The versioned commands below become usable only after
that tag is published. Until then, use the checkout command above and follow the
[development-checkout instructions](docs/INSTALLATION.md#development-checkout).

Claude Code:

```sh
claude plugin marketplace add stefanriegel/flow42#v1.0.0
claude plugin install flow42@flow42
claude
```

Then invoke `/flow42:init`, followed by `/flow42:intent <request>`.

Codex:

```sh
codex plugin marketplace add stefanriegel/flow42 --ref v1.0.0
codex plugin add flow42@flow42
codex
```

Then ask Codex to invoke `flow42:init`, followed by `flow42:intent` for the
request. Restart either harness after install or update so it reloads the plugin.

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

Current milestone: complete the remaining release gates, then publish the signed
`v1.0.0` tag and release. See [ROADMAP.md](ROADMAP.md).

## Contributing

Contributions are welcome after reading [CONTRIBUTING.md](CONTRIBUTING.md).
Please report vulnerabilities through [SECURITY.md](SECURITY.md), not a public
issue.

MIT © Stefan Riegel.
