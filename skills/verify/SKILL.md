---
name: verify
description: Independently verify a Flow42 implementation against intent, spec, plan, security, and evidence. Use before opening a PR or MR.
---

# Verify

Use an agent that did not implement the change. Review the diff against approved
artifacts and acceptance criteria. Run repository-relevant format, lint, type,
test, build, secret, dependency, and static checks. Add UI interaction/visual
evidence or migration dry-run/rollback proof where applicable. The implementer
may fix findings but cannot approve its own result. Allow at most two automatic
fix/review loops, then escalate concrete blockers.
