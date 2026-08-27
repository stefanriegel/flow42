# flow42

**From intent to trusted PR, across coding agents.**

Flow42 is an open, artifact-driven agentic SDLC for professional engineers. It
keeps intent, specifications, plans, evidence, and approvals in Git so Claude
Code, Codex, and humans can safely resume the same work without relying on chat
memory.

> Early development preview. The workflow contract is public; V1 is not yet
> launch-ready. Don't Panic.

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
- deterministic resume from `.sdlc/<work-id>/` artifacts.

## 90-second local preview

Requirements: Git and Python 3.11+.

```bash
git clone https://github.com/stefanriegel/flow42.git
cd flow42
python3 scripts/check-parity.py
python3 scripts/flow42.py doctor
```

To create a work item inside any Git repository:

```bash
python3 /path/to/flow42/scripts/flow42.py new reliable-retries "Add reliable retries" --type feature
```

This creates versionable artifacts under `.sdlc/reliable-retries/`.

## Agent installation

Native one-command installation for Claude Code and Codex will be documented
and tested before V1. Until then, use a local development checkout. We will not
publish installation commands that have not been exercised end to end.

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
harness manifests are thin adapters. `scripts/check-parity.py` rejects missing
commands or malformed adapter names. See [core/CONTRACT.md](core/CONTRACT.md).

## Status and roadmap

Current milestone: prove the state machine, approval hashing, native installs,
GitHub/GitLab adapters, interrupted resume, and public eval fixtures. See
[ROADMAP.md](ROADMAP.md).

## Contributing

Contributions are welcome after reading [CONTRIBUTING.md](CONTRIBUTING.md).
Please report vulnerabilities through [SECURITY.md](SECURITY.md), not a public
issue.

MIT © Stefan Riegel.
