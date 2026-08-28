# Lifecycle walkthrough

1. `init` discovers repository conventions, checks, risk signals, and Forge.
2. `intent` creates durable artifacts and stops for human approval.
3. `spec` turns approved intent into testable requirements and stops for approval.
4. `plan` creates vertical slices; high/critical plans stop for approval.
5. `build` captures baseline or red evidence and implements isolated slices.
6. `verify` independently checks acceptance, security, and repository gates.
7. `pr` idempotently opens or updates a PR/MR and waits for exact-head
   independent review and green CI. With no distinct eligible Forge reviewer,
   a non-implementing review agent's SHA-pinned PR/MR comment is sufficient.
8. `maintain` converts new Forge signals into deduplicated gated intents.

`status` derives current and next legal actions from artifacts. `resume` verifies
history, approvals, blockers, Git ownership, and Forge state after interruption.

One authenticated human remains accountable for each human gate and
irreversible action. Independent review is a separate technical control, not a
second human approval.
See `core/CONTRACT.md` for invalidation and side-state rules.
