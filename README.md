# flow42

Flow42 is a set of skills for moving a code change from request to reviewed
PR/MR. It stores the request, specification, plan, approvals, decisions, status,
and test evidence in `.flow42/<work-id>/` inside the repository.

It works with Claude Code, Codex, and Pi, and can use Orca ADE when available.
It has no executable or service of its own. You need an agent harness, Git, and
`gh` or `glab` for GitHub or GitLab operations.

`init → intent → spec → plan → build → verify → PR/MR → maintain`

## Quickstart

Install the current release, [`v1.0.2`](https://github.com/stefanriegel/flow42/releases/tag/v1.0.2):

Claude Code:

```sh
claude plugin marketplace add stefanriegel/flow42#v1.0.2
claude plugin install flow42@flow42
claude
```

Codex:

```sh
codex plugin marketplace add stefanriegel/flow42 --ref v1.0.2
codex plugin add flow42@flow42
codex
```

Pi:

```sh
pi install git:github.com/stefanriegel/flow42@v1.0.2
pi
```

Run `init` in the target repository, then pass the change you want to `flow`.
Depending on the harness, commands appear as `/flow42:<stage>`,
`flow42:<stage>`, or `/skill:<stage>`. Restart Claude Code or Codex after an
install or update.

`init` checks the installation, repository, Git, Forge access, and optional
Orca readiness. It reports anything blocking before work begins.

## Lifecycle

Use `flow <request>` to run the stages in order, or invoke a stage directly.

| Stage | Purpose |
| --- | --- |
| `init` | Inspect the repository and propose Flow42 configuration. |
| `intent` | Record the request, scope, constraints, and success criteria; then ask for approval. |
| `spec` | Write testable requirements and boundaries; then ask for approval. |
| `plan` | List implementation slices, file ownership, checks, and recovery steps. High-risk plans need approval. |
| `build` | Record the starting behavior, change the code, and capture the result. |
| `verify` | Run the required checks and review the change independently. |
| `pr` | Open or update the PR/MR and wait for exact-head review and green CI. |
| `maintain` | Record new CI, review, or issue feedback as follow-up work. |
| `status` | Show the current stage, blockers, approvals, and next actions. |
| `resume` | Check the saved files, approvals, Git state, and PR/MR before continuing. |

Another session or agent can resume from the files without the previous chat.

Current evidence covers Pi through intent creation, including an Orca-managed
run. Full Pi trusted-PR and GitLab end-to-end execution remain V2 work.

## Safety

One authenticated human owns each approval; a second human is not required.
Intent, specification, high-risk plans, irreversible actions, releases, merges,
and deployments need human approval. Flow42 stops at a reviewed, CI-green PR/MR.
It does not merge, deploy, force-push, store Forge tokens, or discard unrelated
work on its own.

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
