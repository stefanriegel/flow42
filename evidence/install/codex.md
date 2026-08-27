# Codex installation evidence

- Date: 2026-08-27
- Environment: macOS, Codex CLI 0.150.1
- Source: local checkout
- Marketplace add: passed; resolved marketplace `flow42`
- Plugin install: passed; installed `flow42@flow42` version `0.1.0`
- Discovery: passed; plugin list reported enabled installation
- Invocation: passed; a fresh read-only `codex exec` returned
  `FLOW42_STATUS_DISCOVERED` for the installed status skill
- Native lifecycle: passed in a fresh temporary Git repository. A new Codex
  session invoked `flow42:intent`, created all eight work-item files, preserved
  empty approvals, atomically transitioned `draft-intent` to `intent-gate`, and
  produced matching status/history revision 2 without a Flow42 runtime.
- Lifecycle digest: intent SHA-256
  `4a5c03e61c79a10225fa3dceb2cef8b727fc8ac44f38feb2b20dd2aa0918c9d6`
- Removal: passed for plugin and marketplace
- Read-back: passed; neither remained registered

Remote install, version-changing upgrade, and trusted-PR dogfood are still open.
