# Intent: Ship Flow42 V1

- Work ID: `issue-1`
- Status: approved
- Risk: high
- Source: https://github.com/stefanriegel/flow42/issues/1

## Problem

The preview depends on a Python lifecycle runtime and lacks proven native
installation, Forge parity, evaluations, dogfoods, and release evidence.

## Desired outcome

Ship a runtime-free, skill-first V1 that moves Claude Code and Codex users from
intent to a reviewed, CI-green PR/MR using durable repository artifacts.

## Users

Professional engineers using Claude Code or Codex with GitHub or GitLab.

## Constraints

No required Flow42 runtime. Human approval remains mandatory for gated and
irreversible actions. Official Forge CLIs own authentication and API behavior.

## Non-goals

Automatic merge or deployment, custom Forge API clients, mandatory telemetry,
and additional harnesses before V1 parity.

## Acceptance signals

All Issue #1 delivery slices and acceptance criteria have reproducible evidence,
three real dogfoods reach reviewed green PRs/MRs, and `v1.0.0` is published.

## Assumptions and risks

Risk is high because installation, supply-chain behavior, external Forge writes,
parallel agents, and a public release cross multiple trust boundaries.
