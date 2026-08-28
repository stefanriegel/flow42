---
name: verify
description: Independently verify a Flow42 implementation against intent, spec, plan, security, and evidence. Use before opening a PR or MR.
---

# Verify

Recompute approval hashes first. Use a separate review pass or agent that did
not implement any of the reviewed change. Record reviewer identity, exact head
SHA, verdict, findings, and checks; reject a review whose reviewer identity is
the implementing agent. Review the diff against approved
artifacts and acceptance criteria. Run repository-relevant format, lint, type,
test, build, secret, dependency, and static checks. Add UI interaction/visual
evidence or migration dry-run/rollback proof where applicable. The implementer
may fix findings but cannot approve its own result. Allow at most two automatic
fix/review loops, with each fixed head reviewed again by a non-implementing
review pass, then escalate concrete blockers. Independent review does not grant
human approval. Always run every available
secret, dependency-vulnerability, and static-analysis check. For auth,
permissions, sensitive data, networking, payments, infrastructure, or production
configuration, require a persisted threat model and independent security review.

Pass transitions `verifying` to `pr-ready`; any blocking finding transitions to
`blocked` with `resume_stage: verifying`. Use the canonical revision, atomic
status, append-only history, and read-back procedure.
