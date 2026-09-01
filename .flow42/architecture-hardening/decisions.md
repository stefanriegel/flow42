# Decisions: Architecture hardening

## 2026-09-01T05:37:26Z — implementation baseline

- Context: The previous update branch was already merged through a different
  merge commit and was behind current `origin/main`.
- Options: continue on the stale branch; rewrite it; or preserve it and create a
  fresh branch from current main.
- Decision: Preserve `fix/update-skill-review` and implement on
  `fix/architecture-hardening` from `origin/main`.
- Rationale: This retains history and includes merged PR #16 while leaving the
  separate `feat/intent-safe-fallback` branch available for selective integration.
- Consequences: New changes are isolated; no force update or history rewrite.
- Actor: coordinator.

## 2026-09-01T05:37:26Z — user scope

- Context: The user requested all open findings be implemented with supervised
  Codex subagents and allowed Opus 5 for important work.
- Decision: Treat local reversible implementation and testing as authorized;
  keep merge, publish, release, deployment, and other irreversible operations
  out of scope.
- Rationale: This matches the explicit request without broadening authority.
- Consequences: Workers may edit only assigned paths and cannot write to Forge.
- Actor: user request, recorded by coordinator.

## 2026-09-01T06:02:11Z — architecture adjudication defaults

- D1: Allow and require Claude `plugin update` after `plugin install`; the latter
  is a success-looking no-op when another marketplace declaration preserves an
  old installation.
- D2: Use a local independent receipt as the solo/offline fallback; do not create
  a Forge comment merely to manufacture provenance.
- D3: Do not adopt the experimental whole-surface hash registry in this work
  item; enforce the selected controls at their authoritative interfaces.
- D4: Port only the NUL-safe ownership snapshot rules, not the unrelated
  cleanroom recovery feature.
- D5: Keep `core/workflow.json` at schema version 2 because the repair and target
  declarations are additive and do not change the v2 command-key contract.
- Rationale: These are the Opus adjudication's recommended safe defaults and
  preserve the runtime-free seven-file lifecycle without reviving approval gates.
- Actor: coordinator, based on dispatch `ctx_8a3345a7b3fc`.

## 2026-09-01T06:05:00Z — unanswered intent fallback

- Context: Immediate blocking on an unanswered material question can stall a
  project even when the choice is reversible and a conservative option is safe.
- Decision: Clarify and rephrase first, inspect for more evidence, offer concrete
  options, then use a bounded provisional default only for reversible choices
  that need no new authority. Defer implementation choices to later phases and
  block only when no safe fallback exists.
- Consequences: Headless and interactive flows can progress through safe intent
  uncertainty, while auth, permissions, sensitive data, money, production,
  infrastructure, migrations, destructive, high-risk, and irreversible choices
  remain fail-closed. Silence never supplies authorization; a documented safe
  provisional default is an assumption, not an answer or permission.
- Actor: user request, implemented by coordinator from the selectively reviewed
  `feat/intent-safe-fallback` branch.

## 2026-09-01T07:35:00Z — project configuration migration

- Context: The architecture hardening introduced the schema-authoritative
  configuration contract and retired configuration approval gates.
- Decision: Migrate `.flow42/config.yml` to schema version 1, retain the four
  canonical high-risk/irreversible/merge/deploy gates, use direct-argv command
  arrays, and remove nonexistent command paths.
- Validation: `tests/config-schema.sh`, `scripts/validate.sh`,
  `tests/contracts.sh`, and `scripts/check-parity.sh` passed after migration.
- Consequences: Unknown or unsupported syntax blocks execution; the migration
  creates no approval artifact and grants no Forge authority.
- Actor: coordinator.
