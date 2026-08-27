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
- Invocation: blocked because the local Claude CLI was not authenticated

Skill invocation, version-changing upgrade, and trusted-PR dogfood are still open.
