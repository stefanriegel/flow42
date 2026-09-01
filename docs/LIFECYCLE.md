# Lifecycle walkthrough

1. `init` discovers repository conventions, checks, risk signals, and Forge.
2. `intent` creates a durable statement of scope and success.
3. `spec` turns the intent into testable requirements.
4. `plan` creates vertical slices and identifies actions needing confirmation.
5. `build` captures baseline or red evidence and implements isolated slices.
6. `verify` independently checks acceptance, security, and repository gates.
7. `pr` idempotently opens or updates a PR/MR and waits for a current independent
   review receipt plus green CI. The receipt binds `reviewed_head`; commits that
   change only the reviewed work item's evidence, decisions, history, or status
   are receipt-neutral, while any other changed path requires fresh review.
8. `maintain` converts relevant CI and review signals into deduplicated work.

`status` derives current and next legal actions from artifacts. `resume` verifies
history, confirmations, blockers, Git ownership, and Forge state after interruption.

`any-non-final` is a declared pseudo-state and `recorded-resume-stage` is a
declared dynamic target resolved from `status.resume_stage` to a real stage.
Repair transitions return blocking verification findings, failing CI checks, and
requested changes to `building`. A status/history inconsistency enters `blocked`
with a repair proposal. Each repair increments revision and appends the actual
transition; it never rewrites or invents history and adds no approval gate.

One human remains accountable for each high-risk or irreversible action, and
their explicit confirmation is recorded in decisions and history. Independent
review is a separate technical control and does not authorize actions.
See `core/CONTRACT.md` for recovery and side-state rules.
