# Claude Code installation evidence

- Date: 2026-08-27
- Environment: macOS, Claude Code 2.1.247
- Source: local checkout
- Strict plugin validation: passed
- Local marketplace add: passed
- Local plugin install: passed; inventory reported 11 skills and 4 agents
- Same-version update: passed at local scope
- Uninstall and marketplace removal: passed
- Read-back: passed; installation was removed
- Remote branch install: passed from
  `stefanriegel/flow42#stefanriegel/ship-flow42-v1-runtime-free-intent-to-trusted-pr`;
  inventory reported 11 skills and 4 agents, update reported version `0.1.0`
  current, and uninstall/marketplace cleanup passed.
- Namespaced invocation: passed after Claude authentication became available;
  `/flow42:status` returned `FLOW42_REMOTE_DISCOVERED` from the remote install.
- Native lifecycle: passed in a fresh disposable Git repository. Claude invoked
  `/flow42:intent`, created all eight files, atomically transitioned to
  `intent-gate`, and produced matching status/history revision 2 without a
  Flow42 runtime or commit.
- Intent SHA-256:
  `aa37e9444a5ed803e2ed9c1a940d4ef2a18898aa476bbf4ad2a34e899ab5aef8`
- Approval safety: passed; Claude refused to fabricate authenticated provenance
  and left the gate closed.

Version-changing upgrade and trusted-PR dogfood are still open.
