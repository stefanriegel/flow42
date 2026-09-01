# Flow42 V3 Direction (spec)

Decision record from the 2026-09-01 architecture review + 360° intent interview.
Published copy: "Flow42 V3 Direction" artifact. ◆ = owner's deliberate departure
from the interviewer's recommendation; binding either way.

## Decisions

**Identity**
1. Full product lifecycle scope: `explore* → intent → spec → plan → build → verify → pr | local-complete → maintain ⟳` (\* opt-in), greenfield + brownfield.
2. ◆ Full Orca-native. Orca is required. Claude-marketplace/Codex/Pi plugin surfaces are dropped. Orca Run/Task/Dispatch provenance, worktrees, decision gates, and automations are the enforcement layer.
3. ◆ Agent-agnostic coordinator: claude or codex may coordinate inside Orca; every skill must read cleanly for both.
4. Trust model: solo dev, honest evidence — records convince the owner and future sessions, not an audit committee.

**Lifecycle**
5. Opt-in `explore` skill: divergent (3–6 candidate directions with rough value/cost/risk), converges on a pick that seeds `intent`. No workflow stage.
6. Greenfield minimal bootstrap: `init` on a non-repo offers `git init` (recorded, reversible) and writes `bootstrap: required`; the first build slice establishes the toolchain and its first passing test as its own green baseline.
7. Local work can finish: `verifying → complete` gated on `forge: none` + explicit human close. Same review evidence, no CI gate.
8. Maintenance engine: durable `.flow42/signals.md` (source, cause, impact, `triage: now|next|later|wontfix`); `maintain → intent` hand-off records `derived_from`; `pr` closes the loop to the source issue; a scheduled Orca automation runs `maintain` on a cadence and raises a decision gate on a `now` signal.

**Trust & evidence**
9. Repo `.flow42/<work-id>/` files remain the single durable truth; Orca refs are recorded from the files, never the reverse.
10. ◆ Review evidence = one-line stamp in `evidence.md`: Orca run/task/dispatch ref, reviewer agent, review kind, verdict, reviewed SHA, UTC time. The 20-field receipt schema, issuer tiers, resolver doctrine, and marker-pair byte digests are deleted. Staleness rule stays: `reviewed_head` must be ancestor-of-or-equal-to `HEAD`.
11. Risk gates: domain triggers (auth, permissions, sensitive data, networking, payments, infrastructure, production config) keep forcing threat model + independent security review — no implementer-judged exemption — satisfied by one cheap Orca reviewer dispatch.
12. Human gates run through Orca `gate-create`/`gate-resolve`; the decision is still recorded in `decisions.md` + `history.jsonl`.

**Engineering**
13. ◆ Prose-pinning test tier retired entirely (all exact-sentence `grep` assertions and sed mutation fixtures).
14. Tests: structural checks + real `.flow42` history validation (must catch illegal transitions such as `blocked → blocked`) + 3–5 live agent evals run via scheduled Orca automations, not per-push CI.
15. No shipped toolkit (`bin/flow42-check` moot after #10).
16. Distribution: Orca skills CLI, versioned by git tag; the signed-release `update` machinery is replaced; the v2.0.1 marketplace line is archived with a successor note.

## Derived consequences (pre-approved unless vetoed)

- One lean `core/CONTRACT.md` (~90 lines) + one merged `core/policy.json` (workflow + risk + config schema + model profiles). `SECURITY.md`, `OWNERSHIP.md`, `FORGE.md`, `MODEL-ROUTING.md`, `risk-policy.json`, `config-schema.json`, `workflow.json` are deleted/merged.
- 5-line pointer prelude; per-skill authority lists; token floor ≈8.7k → ≈3k per invocation.
- Command policy shrinks to 5 rules (token arrays; printable ASCII; no shell metacharacters in any token; first token not a shell or `env`; first token not `git`/`gh`/`glab`/`terraform`).
- `agents/*.md` deleted; specialists become Orca `worker-start` profiles (agent + model + effort per routing tier) declared in `policy.json`.
- Worker ownership collapses to: Orca worktree isolation by default + five bounded checks (HEAD, refs stream, effective config, hooks tree, `git status --porcelain=v2 -z`); workers never commit/stage/push.
- `review_loops` rule (unresolved in interview, chosen here): the counter always increments, never freezes; each post-limit repair loop requires fresh explicit human authorization recorded in `decisions.md`.
- `status.yml` drops `change_request`; schema_version 3.
- Docs refreshed; `ROADMAP.md` folded into a CHANGELOG "Unreleased / Next" section; stale evidence gets dated legacy headers.
- Version v3.0.0.
- OWNER DIRECTIVE: the V3 rebuild is NOT run through the flow42 lifecycle; work directly on a branch.
