# flow42

Flow42 is an Orca-native skill that runs a software change through its whole
lifecycle. It helps you figure out what to build, bootstraps a greenfield
project or picks up a brownfield one, implements a feature end to end with
independent review, and keeps working after merge by triaging maintenance
signals into new work. Everything it produces lives in `.flow42/<work-id>/`
inside your repository; Flow42 itself has no daemon and no state of its own.

V3 is Orca-native. The last harness-portable release is
[`v2.0.1`](https://github.com/stefanriegel/flow42/releases/tag/v2.0.1)
(maintenance mode).

## Requirements

Orca, with orchestration enabled, plus `git` and `jq`. `gh` or `glab` are
needed only for Forge (GitHub/GitLab) work — a local-only work item can finish
without either.

## Quickstart

Install the skill:

```sh
npx skills add stefanriegel/flow42 --skill flow42
```

(`orca skills install` is the same operation through Orca's UI.)

In your repository, run the skill with `init` first, then hand it a request —
plain language, or "for an existing ticket, paste its URL or text as the
request." If the request is open-ended ("help me figure out what to build"),
it offers `explore` before committing to a direction.

## Lifecycle

| Stage | Purpose |
| --- | --- |
| `explore` | Opt-in: diverge on 3–6 candidate directions, then converge on one that seeds `intent`. |
| `init` | Inspect the repository and write local Flow42 configuration. |
| `intent` | Record the request, scope, constraints, and success criteria. |
| `spec` | Turn intent into testable requirements and boundaries. |
| `plan` | Break the work into vertical slices with owned paths, proving tests, and risk. |
| `build` | Implement one slice at a time with red–green evidence. |
| `verify` | Independently review the change and run the required checks. |
| `pr` | Open or update the PR/MR and watch CI. |
| `maintain` | Turn CI, issue, and review signals into deduplicated follow-up work. |
| `status` | Show the current stage, blockers, and next action. |
| `resume` | Validate saved state and continue after an interruption. |
| `update` | Refresh the installed Flow42 skill itself. |

Any session or agent — Claude or Codex — can resume a work item from its files
alone, without the conversation that started it.

## Safety

One accountable human explicitly confirms high-risk, critical, irreversible,
merge, deploy, publish, force-push, and destructive actions immediately before
each one; the confirmation is recorded in `decisions.md` and `history.jsonl`.
Independent review is a separate technical control and never substitutes for
that confirmation. Flow42 stops at a reviewed, CI-green PR/MR (or an explicit
human close for local-only work) — it never merges, deploys, force-pushes, or
discards unrelated work on its own.

## Learn more

[Installation](docs/INSTALLATION.md) · [Lifecycle](docs/LIFECYCLE.md) ·
[Architecture](docs/ARCHITECTURE.md) · [Configuration](docs/CONFIGURATION.md) ·
[Troubleshooting](docs/TROUBLESHOOTING.md) · [Migration](docs/MIGRATION.md) ·
[Changelog](CHANGELOG.md)

## Contributing

Contributions are welcome after reading [CONTRIBUTING.md](CONTRIBUTING.md).
Please report vulnerabilities through [SECURITY.md](SECURITY.md), not a public
issue.

MIT © Stefan Riegel.
