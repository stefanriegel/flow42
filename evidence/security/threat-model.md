# Flow42 V1 threat model

## Scope

In scope are malicious repository contributors, attacker-controlled Forge text,
compromised dependencies or marketplace snapshots, and accidental credential or
authority misuse on an otherwise trusted host. A fully compromised harness, OS,
or credential store is outside scope.

## Assets and boundaries

Assets are approval authority, repository integrity, Forge credentials, CI and
release provenance, user data, and worktree contents. Boundaries are the human
channel, installed plugin, repository, worker harness, Git, Forge CLI, CI, and
marketplace/release distribution.

## Abuse cases and controls

| Abuse case | Control | Verification |
| --- | --- | --- |
| Contributor forges approval fields | Authenticated Forge comment or verified signed commit binds identity and digest | Read back provenance and recompute SHA-256 |
| Issue or repository text injects commands | Explicit instruction/data boundary; external text cannot change authority | Adversarial evaluation |
| Mutable marketplace replaces skills | V1 installs pin a signed immutable tag and checksum | Remote tag install and signature/checksum check |
| Config or identifiers inject shell syntax | Approved argv arrays, no shell evaluation, narrow validation, `--` where supported | Static review and adversarial inputs |
| Remote URL leaks credentials | Redact userinfo and query before evidence | Redaction evaluation |
| Worker edits outside ownership or delegates | Least-capable profile, no Forge writes, pre/post changed-path enforcement | Conflict and delegation evaluations |
| Unsafe merge, deploy, publish, or Git action | Explicit human gate independent of earlier approvals | Unsafe-path evaluations |
| Secrets or vulnerable dependencies enter PR | CI secret, dependency, and shell static checks | Required green security jobs |

## Residual risk

Skills remain interpreted policy rather than an OS sandbox. Harness capability
restrictions vary, Forge comments may be edited, and tag verification depends on
trusted signing keys. Flow42 therefore reverifies provenance and state at every
gate and blocks when a capability cannot enforce the documented boundary.
