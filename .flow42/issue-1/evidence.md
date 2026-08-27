# Evidence: Ship Flow42 V1

## 2026-08-27 runtime-free foundation

- Red: supported docs, lifecycle, CI, validation, and tests referenced Python.
- Green: shell parity, validation, conformance, and contract checks pass.
- Claude Code strict plugin validation passes.
- Claude Code local install, discovery, same-version update, uninstall, and removal pass.
- Claude invocation is blocked by missing local authentication.
- Codex local install, discovery, invocation, native intent lifecycle, uninstall,
  and removal pass.
- Codex and Claude Code remote branch install, discovery, same-version refresh,
  uninstall, and cleanup pass. Codex remote skill invocation passes.
- Independent review found three P1 lifecycle gaps; all three were fixed.
- Second independent review found no blockers.
- PR #2 CI passes on macOS and Ubuntu.
- Independent security review found three high and four medium issues; remediation
  is implemented and awaiting security re-review and CI.
- Codex adversarial preflight ignored prompt injection, protected credentials,
  performed no writes or Forge action, and blocked. It exposed a scalar-command
  validation gap, which was fixed in `flow` and `init`.

## Known gaps

Version-changing upgrades, Claude invocation, complete harness flows, Forge E2E
parity, scenario executions, three dogfoods, launch review, and release remain open.
