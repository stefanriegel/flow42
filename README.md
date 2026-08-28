# flow42

**From intent to trusted PR, across coding agents.**

Flow42 gives coding agents a shared, durable way to take an idea all the way to
a trusted pull request. Intent, specifications, plans, evidence, and approvals
live in Git, so people and agents can pick up the work without depending on chat
history.

The current release is [`v1.0.1`](https://github.com/stefanriegel/flow42/releases/tag/v1.0.1).
It supports Claude Code, Codex, and Pi, can use Orca ADE when it is available,
and routes work by model capability. Every support claim is limited to a path
backed by public evidence. Don't Panic.

## Why Flow42

Coding agents move quickly. The hard part is keeping the original intent clear,
knowing what was actually verified, and making sure a fast change does not turn
into an expensive surprise. Flow42 adds a risk-aware loop:

`init → intent → spec → plan → build → verify → PR/MR → maintain`

- one canonical skill contract across Claude Code, Codex, and Pi;
- human gates where judgment or authority matters;
- vertical slices in isolated worktrees;
- observable red-green for behavior changes and bug fixes;
- independent verification and security escalation;
- Forge operations through the official `gh` and `glab` CLIs;
- deterministic resume from `.flow42/<work-id>/` artifacts.

## Runtime-free onboarding

Requirements: your selected coding-agent harness and Git. `gh` or `glab` is
needed only for the corresponding Forge. No Flow42 executable, Python
environment, Node runtime, service, or token store is required.

Install Flow42 through your harness and run `flow42:init` in the repository you
want to work on. The skill checks its own installation, the repository, Git,
the matching Forge CLI, and optional Orca readiness. It reports what is ready,
what is optional, and what must be fixed before work begins. You do not need to
clone Flow42 or run its maintainer scripts.

Once onboarding passes, give `flow42:intent` the change you want to make.
Flow42 creates the durable work record under `.flow42/<work-id>/`.

## Quickstart

Use the immutable release tag below. Installation time depends on your network
and how quickly the harness starts.

Claude Code:

```sh
claude plugin marketplace add stefanriegel/flow42#v1.0.1
claude plugin install flow42@flow42
claude
```

Then invoke `/flow42:init`, followed by `/flow42:intent <request>`.

Codex:

```sh
codex plugin marketplace add stefanriegel/flow42 --ref v1.0.1
codex plugin add flow42@flow42
codex
```

Then ask Codex to invoke `flow42:init`, followed by `flow42:intent` for the
request. Restart either harness after install or update so it reloads the plugin.

Pi:

```sh
pi install git:github.com/stefanriegel/flow42@v1.0.1
pi
```

Then invoke `/skill:init`, followed by `/skill:intent <request>`. Pi discovers
Flow42's conventional `skills/` package without a Flow42 runtime. The published
evidence covers Pi discovery and intent creation, including an Orca-managed run.
A complete Pi trusted-PR run is not yet claimed.

## Skills

`flow`, `init`, `intent`, `spec`, `plan`, `build`, `verify`, `pr`, `maintain`,
`status`, and `resume`. Claude Code exposes plugin skills as `/flow42:<skill>`;
Codex discovers them through its native plugin manifest, and Pi discovers the
same directories as an Agent Skills package.

## Safety model

People stay in charge of consequential decisions. Intent and specification need
human approval, as do high-risk plans, irreversible actions, publication,
merging, and deployment. Flow42 does not store Forge tokens, force-push, discard
unrelated changes, merge, or deploy on its own.

Each gate has one accountable authenticated human; Flow42 does not require a
second human or repository collaborator. Independent review is performed by a
separate non-implementing pass or agent and can be published as an exact-head
SHA-pinned PR/MR comment when formal Forge approval is unavailable.

## Architecture

The canonical contract lives in `core/`; shared skills live in `skills/`;
harness manifests are thin adapters. Repository conformance checks use portable
shell plus `jq`; they are development checks, not a product runtime. See
[core/CONTRACT.md](core/CONTRACT.md).

Documentation: [installation](docs/INSTALLATION.md),
[lifecycle](docs/LIFECYCLE.md), [architecture](docs/ARCHITECTURE.md),
[configuration](docs/CONFIGURATION.md),
[troubleshooting](docs/TROUBLESHOOTING.md), [model routing](core/MODEL-ROUTING.md), and
[preview migration](docs/MIGRATION.md).

## Status and roadmap

`v1.0.1` is published. The next milestone focuses on the remaining launch
evidence and GitLab execution work planned for V2. See [ROADMAP.md](ROADMAP.md).

## Contributing

Contributions are welcome after reading [CONTRIBUTING.md](CONTRIBUTING.md).
Please report vulnerabilities through [SECURITY.md](SECURITY.md), not a public
issue.

MIT © Stefan Riegel.
