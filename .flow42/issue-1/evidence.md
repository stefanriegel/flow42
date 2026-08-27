# Evidence: Ship Flow42 V1

## 2026-08-27 runtime-free foundation

- Red: supported docs, lifecycle, CI, validation, and tests referenced Python.
- Green: shell parity, validation, conformance, and contract checks pass.
- Claude Code strict plugin validation passes.
- Claude Code local install, discovery, same-version update, uninstall, and removal pass.
- Claude invocation is blocked by missing local authentication.
- Codex local install, discovery, invocation, native intent lifecycle, uninstall,
  and removal pass.
- Independent review found three P1 lifecycle gaps; all three were fixed.

## Known gaps

Remote installs, version-changing upgrades, Claude invocation, complete harness
flows, Forge E2E parity, scenario executions, three dogfoods, launch review, CI,
and release remain open.
