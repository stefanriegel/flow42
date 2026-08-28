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
- Remote branch install: passed from `stefanriegel/flow42` at commit
  `d1d860ea3576094dad530562ad86a000c5b23659`; discovery and invocation returned
  `FLOW42_REMOTE_DISCOVERED`, marketplace refresh returned no errors, and cleanup
  read-back passed.

## PR #4 current-head rerun

- Date: 2026-08-28
- Commit: `f9a8f77bd7fbdc7d2060b3e720823733a7734a45`
- Environment: macOS, Codex CLI 0.150.1, temporary `CODEX_HOME`
- Checkout marketplace add, install, enabled-state read-back, fresh read-only
  `flow42:status` invocation, idempotent marketplace add, same-version reinstall,
  uninstall, marketplace removal, and empty read-backs: passed
- Isolation: invocation used approval policy `never` and a read-only sandbox.
  Authentication was copied temporarily with mode 0600, never inspected or
  printed, and removed with the complete temporary home.
- Repository and normal Codex configuration: unchanged
- Local-marketplace difference: `marketplace upgrade` applies only to Git
  marketplaces; checkout replacement is proven by idempotent marketplace add
  and same-version reinstall.

Version-changing release upgrade and trusted-PR dogfood are still open.
