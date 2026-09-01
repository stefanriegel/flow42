# Lifecycle walkthrough

1. `init` discovers repository conventions, checks, risk signals, and Forge.
2. `intent` creates a durable statement of scope and success.
3. `spec` turns the intent into testable requirements.
4. `plan` creates vertical slices and identifies actions needing confirmation.
5. `build` captures baseline or red evidence and implements isolated slices.
6. `verify` independently checks acceptance, security, and repository gates.
7. `pr` idempotently opens or updates a PR/MR and waits for a current independent
   review receipt plus green CI. The receipt binds `reviewed_head`; commits that
   change exact bookkeeping leaves or only the eight permitted lifecycle/CI
   fields in status are receipt-neutral. Renames, nested lookalikes, risk changes,
   and any other changed path require fresh review.
8. `maintain` converts relevant CI and review signals into deduplicated work.

`status` derives current and next legal actions from artifacts. `resume` verifies
history, confirmations, blockers, Git ownership, and Forge state after interruption.

`any-non-final` is a structured pseudo-state built from `stages` and
`side_states`, excluding final states and `blocked` so it cannot create a
blocked-to-blocked self-loop. `recorded-resume-stage` resolves from
`status.resume_stage` only when it is a non-final lifecycle stage and equals the
actual `from` stage of the latest history transition into `blocked`.
Repair transitions return blocking verification findings, failing CI checks, and
requested changes to `building`. A status/history inconsistency enters `blocked`
with a repair proposal. Each repair increments revision and appends the actual
transition; it never rewrites or invents history and adds no approval gate.
Each `verifying → building` repair increments `review_loops`; after the automatic
review limit, Flow42 blocks and escalates rather than taking a third loop.

One human remains accountable for each high-risk or irreversible action, and
their explicit confirmation is recorded in decisions and history. Independent
review is a separate technical control and does not authorize actions.
See `core/CONTRACT.md` for recovery and side-state rules.
