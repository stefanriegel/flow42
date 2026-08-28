# Lifecycle walkthrough

1. `init` discovers repository conventions, checks, risk signals, and Forge.
2. `intent` creates a durable statement of scope and success.
3. `spec` turns the intent into testable requirements.
4. `plan` creates vertical slices and identifies actions needing confirmation.
5. `build` captures baseline or red evidence and implements isolated slices.
6. `verify` independently checks acceptance, security, and repository gates.
7. `pr` idempotently opens or updates a PR/MR and waits for exact-head
   independent review bound to the exact Git head SHA and green CI.
8. `maintain` converts relevant CI and review signals into deduplicated work.

`status` derives current and next legal actions from artifacts. `resume` verifies
history, confirmations, blockers, Git ownership, and Forge state after interruption.

One human remains accountable for each high-risk or irreversible action, and
their explicit confirmation is recorded in decisions and history. Independent
review is a separate technical control and does not authorize actions.
See `core/CONTRACT.md` for recovery and side-state rules.
