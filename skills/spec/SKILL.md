---
name: spec
description: Turn a Flow42 intent into testable requirements and design constraints. Use after intent capture.
---

# Specify

Read the current `intent.md` and ensure it agrees with persisted status and
history. On mismatch append an inconsistency event and block. Otherwise write `spec.md` with functional and
non-functional requirements, domain terminology, interfaces, data behavior,
security considerations, acceptance criteria, and verification strategy.
Identify contradictions and decisions rather than silently choosing. Trigger a
threat model for auth, permissions, sensitive data, network boundaries, money,
infrastructure, supply chain, or production configuration.

On completion transition directly from `drafting-spec` to `planning` with the
canonical revision, atomic status, append-only history, and read-back procedure.
