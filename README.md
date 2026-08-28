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

## How to use the lifecycle

Start with `flow42:flow <request>` when you want Flow42 to guide the whole job.
You can also invoke a stage directly when you know exactly where the work should
continue. Your harness may display the command as `/flow42:<stage>`,
`flow42:<stage>`, or `/skill:<stage>`.

| Stage | Use it when | What it does |
| --- | --- | --- |
| `init` | Flow42 is new to the repository | Checks the installation and repository, discovers commands, risk signals, Forge access, and optional Orca, then proposes configuration. |
| `intent` | You have an idea, issue, or requested change | Captures the problem, scope, constraints, and success criteria. Stops for human approval before solution design. |
| `spec` | The intent is approved | Turns the request into testable requirements, boundaries, and acceptance criteria. Stops for human approval. |
| `plan` | The specification is approved | Breaks the work into owned vertical slices, checks, dependencies, and recovery steps. High-risk plans need human approval. |
| `build` | The plan is ready | Captures baseline or failing evidence, implements the approved slices, and records what changed. |
| `verify` | Implementation is complete | Checks acceptance criteria, tests, security, scope, and evidence independently. It does not approve its own implementation. |
| `pr` | Verification has passed | Opens or updates the PR/MR, watches exact-head CI, and records independent review. It never merges by itself. |
| `maintain` | CI, review, or a new issue changes the work | Converts new Forge signals into deduplicated, gated follow-up intent instead of silently expanding scope. |
| `status` | You want to know where the work stands | Reads the durable artifacts and reports the current stage, blockers, approvals, and next legal actions. |
| `resume` | A session stopped or another agent takes over | Revalidates history, approvals, Git state, ownership, and Forge state before continuing safely. |

`intent`, `spec`, high-risk `plan`, irreversible actions, merge, and deployment
remain human decisions. Flow42 normally finishes at a reviewed, CI-green PR/MR
that is ready for a person to merge.

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
