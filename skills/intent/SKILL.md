---
name: intent
description: Capture a work request as an explicit, approvable Flow42 intent. Use for new products, features, bugs, refactors, and maintenance findings.
---

# Capture Intent

Create a safe work ID and initialize `.sdlc/<work-id>/` with
`scripts/flow42.py new`. Fill `intent.md` with the problem, desired outcome,
users, constraints, non-goals, acceptance signals, assumptions, and risks.
Research public facts when useful; ask only questions that materially change
outcome, risk, confidentiality, or cost. Present the completed intent and its
SHA-256 hash for explicit approval. Do not advance on an ambiguous approval.
