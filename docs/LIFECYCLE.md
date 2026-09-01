# Lifecycle walkthrough

1. `explore` (opt-in, pre-lifecycle): diverge on 3–6 candidate directions,
   present them neutrally with one recommendation, and stop until the human
   picks or merges one. No work item exists yet.
2. `init` discovers repository conventions, checks, toolchain, and Forge
   reachability, and writes `.flow42/config.yml`. On a non-repository target
   it offers `git init`; when no toolchain is found it marks
   `bootstrap: required` instead of guessing commands.
3. `intent` creates the work item and a durable statement of scope, users,
   constraints, and success criteria — seeded from the `explore` pick when one
   exists. Transitions `draft-intent` to `drafting-spec`.
4. `spec` turns the intent into testable requirements, terminology,
   interfaces, and acceptance criteria, adding a threat model when a security
   trigger applies. Transitions `drafting-spec` to `planning`.
5. `plan` breaks the work into vertical slices with owned paths, proving
   tests, and a set risk level. Low or medium risk moves straight to
   `building`; high or critical risk moves to `plan-gate` and waits for an
   explicit human confirmation of that exact plan before `building`.
6. `build` implements one slice at a time: a green baseline first (the
   bootstrap slice's own first passing test counts as its baseline), then
   observed-red-then-green evidence for behavior changes, recorded in
   `evidence.md`. Workers run as isolated Orca dispatches; the coordinator
   integrates. Transitions `building` to `verifying`.
7. `verify` dispatches an independent reviewer — an Orca worker that did not
   implement the change — to check the diff against intent/spec/plan and run
   the configured and baseline checks. A pass stamps `evidence.md` and moves
   to `pr-ready`; a blocking finding repairs back to `building` and increments
   `review_loops`.
8. `pr` opens or updates the PR/MR idempotently (search before create), then
   watches CI. A current `pass` stamp is required first, and any commit that
   lands after the stamp needs a fresh review. Moves `pr-ready` through
   `ci-running` to `ready-for-human` once independently reviewed and green.
9. **Local completion**: with `forge: none`, there is no PR/MR to wait on.
   `verifying` moves straight to `complete` once the accountable human closes
   it explicitly through an Orca decision gate — same review evidence, no CI
   gate.
10. The human close at `ready-for-human` (or the local-completion close above)
    is the only door into `complete`; nothing else marks a work item done.
11. `status` and `resume` are available at any point: `status` derives the
    current and next legal actions from `policy.json .workflow`, never from
    memory. `resume` validates that `status.yml` and `history.jsonl` still
    agree, and re-binds a `blocked` item to its recorded resume stage.
12. `maintain` runs the loop that keeps going after `complete`: it reads
    Forge and CI signals, deduplicates them into `.flow42/signals.md` with a
    `triage` judgment, and raises a decision gate on each `now` signal — a
    "yes" seeds a fresh `intent` with `derived_from` pointing back at the
    signal. It is normally a scheduled Orca automation, not a manual step.

## Pseudo-states and repair

`any-non-final` is every stage and side state except the three final ones
(`complete`, `abandoned`, `superseded`); it lets blocked work be abandoned or
superseded. `any-unblocked-non-final` also excludes `blocked` itself and is
the only legal source for entering `blocked`, which rules out a
`blocked → blocked` self-loop. `recorded-resume-stage` resolves from
`status.resume_stage` only when it names a non-final stage and matches the
`from` of the latest history transition into `blocked` — a label alone is not
enough.

Repair transitions return a blocking review finding, a failing CI check, or a
recorded change request to `building`; a status/history disagreement enters
`blocked` with a repair proposal instead. Every repair increments the
revision and appends the real transition — it never rewrites or invents
history, and it adds no approval gate of its own. Each `verifying → building`
repair also increments `review_loops`; once that passes
`policy.json .workflow.automatic_review_limit`, Flow42 blocks and escalates
instead of taking another loop on its own authority.

One accountable human confirms every high-risk or irreversible action
immediately before it happens; independent review is a separate technical
control and never substitutes for that confirmation. See
`skills/flow42/core/CONTRACT.md` for the full recovery and side-state rules,
and `skills/flow42/core/policy.json` for the exact transition table.
