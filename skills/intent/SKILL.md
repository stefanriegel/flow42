---
name: intent
description: Capture a work request as an explicit, approvable Flow42 intent. Use for new products, features, bugs, refactors, and maintenance findings.
---

# Capture Intent

Create a lowercase work ID matching `^[a-z0-9][a-z0-9-]{0,62}$`; reject unsafe
or colliding paths. Create `.flow42/<work-id>/` from every work-item template
using native harness file operations, including the revision-1 creation event in
`history.jsonl` and empty `approvals.yml`. Fill `intent.md` with the problem, desired outcome,
users, constraints, non-goals, acceptance signals, assumptions, and risks.
Research public facts when useful; ask only questions that materially change
outcome, risk, confidentiality, or cost. Compute SHA-256 with `sha256sum` or
macOS `shasum -a 256`. Persist a named human approval and UTC time in
`approvals.yml`. Require authenticated Forge-comment read-back or a verified
signed-commit trailer as defined by `core/SECURITY.md`; store and reverify its
canonical reference. Reread the record and do not advance on ambiguous approval.

When the intent is complete, transition `draft-intent` to `intent-gate` by
incrementing the revision, atomically updating status, appending history, and
rereading both. Approval permits the later transition to `drafting-spec`; it
does not itself change stage.
