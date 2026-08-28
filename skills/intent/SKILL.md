---
name: intent
description: Capture a work request as an explicit Flow42 intent. Use for new products, features, bugs, refactors, and maintenance findings.
---

# Capture Intent

Create a lowercase work ID matching `^[a-z0-9][a-z0-9-]{0,62}$`; reject unsafe
or colliding paths. Create `.flow42/<work-id>/` from every work-item template
using native harness file operations, including the revision-1 creation event in
`history.jsonl`. Fill `intent.md` with the problem, desired outcome,
users, constraints, non-goals, acceptance signals, assumptions, and risks.
Research public facts when useful; ask only questions that materially change
outcome, risk, confidentiality, or cost. Reread the completed artifact before
advancing; intent capture has no gate before specification.

When the intent is complete, transition directly from `draft-intent` to
`drafting-spec` by incrementing the revision, atomically updating status,
appending history, and rereading both.
