# Drive mode (v3.1 spec)

Status: **design only — not approved for implementation.** Written 2026-09-02
against Flow42 v3.0.0 (`main` @ 1b90b4c). Decisions marked ❓ need the owner's
answer before any plan is written.

## Problem

V3's router runs exactly one stage per invocation. Continuation is implicit: a
user with an already-formed request must re-invoke the skill at every hop
(`intent` → `spec` → `plan` → `build` → `verify` → `pr`), and nothing carries a
work item forward on its own.

Two consequences:

1. **The cheapest path is the most tedious.** A low-risk brownfield fix passes
   through no human gate at all between `intent` and `pr-ready`, yet still costs
   six manual invocations. The prompts add no safety — they are pure friction.
2. **The ticket pillar is only half-built.** The scheduled `maintain` automation
   triages signals and raises a decision gate, then stops. Even after the human
   answers "yes, work this", nothing advances the derived work item. Signal → PR
   is not achievable unattended, which was the point of the maintenance loop.

## What drive mode is

`drive` is a **router mode, not a lifecycle stage.** It repeatedly derives and
executes the next legal action for one work item until a stopping condition. It
introduces no new state, no new transition, and — critically — **no new
authority.** Every gate that halts a manual run halts a driven run identically.

It is the difference between "run the next stage" and "keep running stages while
that is unambiguously safe."

### Loop

```
until a stop condition fires:
  1. read .flow42/<work-id>/status.yml + history.jsonl   (files are truth)
  2. derive the next legal action from policy.json .workflow,
     given current stage, risk, and forge setting
  3. if the outgoing transition carries a human gate:
        raise an Orca decision gate, report, STOP
  4. execute that stage from its own stage file, unchanged
  5. confirm the stage persisted its transition
        (state_revision incremented AND one history event appended)
  6. decrement budget
```

Step 4 is deliberately dumb: drive does not reimplement or reinterpret any
stage. It calls the same stage file a human invocation would, so a stage's
behaviour cannot silently differ between driven and manual runs.

Step 5 is the load-bearing safety check — see *no-progress detection* below.

### Stop conditions

| Condition | Behaviour |
|---|---|
| Human gate on the outgoing transition | Raise Orca decision gate, report, stop |
| `blocked` entered (incl. intent's unresolved-material-question rule) | Report blockers, stop |
| Final state (`complete`, `abandoned`, `superseded`) | Report, stop |
| **No progress** — stage ran but `state_revision` unchanged | Stop immediately, report as a defect. Never retry |
| Budget exhausted (`drive.max_stage_transitions`) | Report where it stopped and how to resume |
| Review-loop limit reached | Existing escalation applies; stop |
| Target stage reached (`--to <stage>`) | Report, stop |

**No-progress detection is not optional.** Without it, a stage that fails to
persist its transition loops forever, burning tokens and re-running side
effects. One non-advancing iteration is a bug, not something to retry.

### What drive must never do

- Run `explore`. It is divergent and requires a human selection; "silence is not
  a selection" is already explicit in the stage. Drive starts at `intent` at the
  earliest.
- Merge, deploy, publish, force-push, or resolve its own decision gates.
- Skip `verify`, or act as the independent reviewer for work it drove. The
  reviewer remains a separate Orca dispatch with `implementer: false`.
- Run without a ready Orca runtime, or invent a transition absent from
  `policy.json`.

## Why this is safe here specifically

Drive is only defensible because V3 already has the properties that make an
unattended loop recoverable:

- **Every iteration persists before continuing.** A crash mid-drive leaves a
  valid `.flow42/` item; `resume` picks it up. The loop holds no state of its
  own beyond its budget counter.
- **The brakes are real.** Human gates are Orca decision gates, not prose
  requests an agent can talk itself past. High/critical risk still stops at
  `plan-gate` before any code is written.
- **The expensive cycle is already bounded** by `automatic_review_limit` and its
  escalation.
- **The endpoint is a PR, not a merge.** Per `core/CONTRACT.md`, commits,
  branch pushes, and change-request creation are reversible workflow steps.

The residual risk drive genuinely adds is **cost and failure amplification**: a
weak spec now drives into a weak build without a human noticing between hops.
The budget and the per-stage report are the mitigations; the design does not
pretend they eliminate it.

## Changes required

| File | Change |
|---|---|
| `skills/flow42/SKILL.md` | Dispatch table gains `drive` as a mode; ~20 lines describing the loop, stop conditions, and per-iteration reporting |
| `skills/flow42/core/policy.json` | New `.drive` block (below); `drive` added to `.workflow.lifecycle_commands` |
| `tests/structure.sh` | Assert `.drive` exists with its required keys and a sane budget |
| `tests/workflow.sh` | Pin `.drive.stop_on` the way gates and counters are pinned |
| `evals/live/drive-low-risk.md` | New live eval: drive a trivial brownfield fix in a disposable repo; assert it reached the expected stop, wrote a legal history, and produced a review stamp |
| `README.md`, `docs/LIFECYCLE.md` | Document the mode and its stop conditions |

No stage file changes. No workflow transitions added. No schema version bump —
`.drive` is additive, so this is **v3.1.0**.

```json
"drive": {
  "enabled": true,
  "max_stage_transitions": 8,
  "default_target": "ready-for-human",
  "never_auto_run": ["explore"],
  "stop_on": ["human-gate", "blocked", "final-state", "no-progress",
              "review-limit-reached", "budget-exhausted", "target-reached"],
  "adds_authority": false
}
```

## How it closes the ticket loop

```
scheduled maintain automation
  → appends signal to .flow42/signals.md, triages it
  → raises decision gate on a `now` signal
  → human resolves "yes"
  → drive carries the derived work item intent → … → ready-for-human
  → human reviews the PR
```

Every hop between the two human touches is ungated by design. That is the
maintenance lifecycle the intent interview asked for, and it is unreachable
without something like drive.

## Open questions ❓

1. **Default target.** Should `drive` run through `pr` (opening a real PR
   unattended) or stop at `verifying`/`pr-ready` and ask? Opening a PR is
   outward-facing but reversible, and the contract already classifies it as a
   reversible workflow step. Proposed default `ready-for-human` with `--to
   <stage>` to stop earlier — but the conservative default is defensible and
   this is the single most consequential choice in the spec.
2. **Unattended drive.** May a *scheduled automation* drive, or is drive
   interactive-only for v3.1? Unattended signal → PR is the full prize; it is
   also the first time Flow42 writes to a Forge with no human in the session.
   Recommend interactive-only in v3.1, revisit once the live eval has run
   against real work.
3. **Budget.** Is 8 the right default, and should `.flow42/config.yml` be able
   to override it per repository (config-schema growth) or is the policy default
   sufficient?
4. **Reporting cadence.** Report per stage as it goes, or once at the stop? Per
   stage is more legible for a long run and lets a human interrupt; once is
   quieter. Proposed: one line per completed stage, full report at the stop.

## Explicitly out of scope

Resident processes or daemons (Orca automations own recurrence), a Flow42-owned
scheduler, cross-work-item drive (one item per run), and any relaxation of an
existing gate.
