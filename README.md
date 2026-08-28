# flow42

**From intent to trusted PR, across coding agents.**

Flow42 gives coding agents a shared, durable way to take an idea all the way to
a trusted pull request. Intent, specifications, plans, evidence, and approvals
live in Git, so people and agents can pick up the work without depending on chat
history.

Flow42 supports Claude Code, Codex, and Pi, and uses Orca ADE when available.
It has no runtime of its own: just your agent harness, Git, and `gh` or `glab`
for Forge operations.

`init → intent → spec → plan → build → verify → PR/MR → maintain`

## Quickstart

Install the current release, [`v1.0.1`](https://github.com/stefanriegel/flow42/releases/tag/v1.0.1):

Claude Code:

```sh
claude plugin marketplace add stefanriegel/flow42#v1.0.1
claude plugin install flow42@flow42
claude
```

Codex:

```sh
codex plugin marketplace add stefanriegel/flow42 --ref v1.0.1
codex plugin add flow42@flow42
codex
```

Pi:

```sh
pi install git:github.com/stefanriegel/flow42@v1.0.1
pi
```

Run `init` in the target repository, then pass your request to `flow`. Depending
on the harness, commands appear as `/flow42:<stage>`, `flow42:<stage>`, or
`/skill:<stage>`. Restart Claude Code or Codex after installing or updating.

`init` checks the installation, repository, Git, Forge access, and optional
Orca readiness. It reports anything blocking before work begins.

## Lifecycle

Use `flow <request>` for the guided path or invoke a stage directly.

| Stage | Purpose |
| --- | --- |
| `init` | Check onboarding and propose repository configuration. |
| `intent` | Capture scope and success criteria, then request approval. |
| `spec` | Turn approved intent into testable requirements, then request approval. |
| `plan` | Split the work into owned, verifiable slices; gate high-risk plans. |
| `build` | Capture baseline evidence and implement the approved plan. |
| `verify` | Independently check requirements, tests, security, scope, and evidence. |
| `pr` | Open or update the PR/MR and wait for exact-head review and green CI. |
| `maintain` | Turn new Forge signals into scoped, gated follow-up work. |
| `status` | Show the current stage, blockers, approvals, and next actions. |
| `resume` | Revalidate durable state before continuing an interrupted job. |

State lives under `.flow42/<work-id>/`, so another session or agent can resume
without chat history.

Current evidence covers Pi through intent creation, including an Orca-managed
run. Full Pi trusted-PR and GitLab end-to-end execution remain V2 work.

## Safety model

One authenticated human owns each gate; a second human is not required.
Intent, specification, high-risk plans, irreversible actions, publication,
merge, and deployment remain human decisions. Flow42 never merges, deploys,
force-pushes, stores Forge tokens, or discards unrelated work on its own.

The normal outcome is a reviewed, CI-green PR/MR ready for a person to merge.

## Learn more

[Installation](docs/INSTALLATION.md) · [Lifecycle](docs/LIFECYCLE.md) ·
[Architecture](docs/ARCHITECTURE.md) · [Configuration](docs/CONFIGURATION.md) ·
[Troubleshooting](docs/TROUBLESHOOTING.md) · [Model routing](core/MODEL-ROUTING.md) ·
[Roadmap](ROADMAP.md)

## Contributing

Contributions are welcome after reading [CONTRIBUTING.md](CONTRIBUTING.md).
Please report vulnerabilities through [SECURITY.md](SECURITY.md), not a public
issue.

MIT © Stefan Riegel.
