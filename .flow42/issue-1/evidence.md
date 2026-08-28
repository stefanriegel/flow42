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
- Claude Code authenticated namespaced invocation and native intent lifecycle
  pass; status/history revision 2 agree and approval fabrication was refused.
- Independent review found three P1 lifecycle gaps; all three were fixed.
- Second independent review found no blockers.
- PR #2 CI passes on macOS and Ubuntu.
- Independent security review found three high and four medium issues; remediation
  is implemented and awaiting security re-review and CI.
- Codex adversarial preflight ignored prompt injection, protected credentials,
  performed no writes or Forge action, and blocked. It exposed a scalar-command
  validation gap, which was fixed in `flow` and `init`.

## 2026-08-28 merged and accepted evidence

- GitHub PRs [#2](https://github.com/stefanriegel/flow42/pull/2),
  [#3](https://github.com/stefanriegel/flow42/pull/3), and
  [#4](https://github.com/stefanriegel/flow42/pull/4) are merged as
  `71881245e39ff44e727c60b83a3d215a4ab4924c`,
  `ebbf1d5a75927843aea42c0317cfe729d180d5f5`, and
  `3b01874517ed0c51ce6727feffdbbfdda4a174e0`; each had all four GitHub checks
  pass. GitHub records no formal reviews on these PRs.
- The three feature, bug-fix, and maintenance dogfood PRs were merged with green
  exact-head checks. GitHub records zero formal reviews on each; separate Orca
  independent-review evidence does not satisfy the formal-review requirement.
- The Issue #1 owner [accepted the GitLab support delivery slice](https://github.com/stefanriegel/flow42/issues/1#issuecomment-5451319635)
  based on
  authenticated `glab` operation, durable approved artifacts, GitLab CI lint,
  local tests, and documented Forge differences.
- The GitLab runner was deliberately not used because it was unprotected,
  accepted untagged jobs, and advertised Docker-in-Docker/host-socket access.
  No GitLab pipeline execution or CI-green GitLab MR is claimed.
- PR #4 current-head Codex invocation passed. Current-head Claude invocation
  failed at isolated-scope authentication, so only the earlier authenticated
  Claude invocation is evidence.

## Known gaps

Version-changing upgrades, current-head authenticated Claude invocation, formal
dogfood PR reviews, and release authorization remain open. Issue #1 remains
open; no tag or release has been published.

## 2026-08-28 release-candidate review remediation

- Independent review of `94d6c35` found that checksum generation accepted
  mutable or unsigned refs, release manifests were not bound to the tag, and
  the active work state did not represent its blockers.
- The checksum path now fails closed on anything except a Git-verified signed
  annotated `refs/tags/v1.0.0`, with all three tagged manifests bound to
  version `1.0.0`; portable ephemeral-signing tests cover the negative cases.
- PR #5 merged the final release candidate as `5710926ca6af6abd3a6019d83e2d504ef6227cb7`.
  No tag, release, or issue close is authorized before all listed gates pass and
  the owner explicitly authorizes release.

## 2026-08-28 release signing finalization

- The repository now binds `v1.0.0` SSH tag verification to the committed
  release public key and signer identity `flow42-release@stefanriegel`.
- Tag and release publication remain pending; this change does not publish,
  push, tag, release, merge, or close Issue #1.
