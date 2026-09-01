# Flow42 threat model

## Scope and assumptions

Flow42 coordinates an agent on a trusted host. In scope are malicious or
mistaken repository contributors, attacker-controlled repository and Forge
text, unsafe repository configuration, worker overreach, Git administrative
state changes, and accidental credential or authority misuse. The harness, OS,
credential store, installed Flow42 bundle, and human authority channel are trust
anchors; compromise of one of those anchors is outside Flow42's enforcement.

This document describes controls in the current repository. Local deterministic
checks do not establish exact-head remote CI, provider authentication, native
Claude/Codex parity, deployment, publication, or release provenance.

## Assets and trust boundaries

Protected assets are human approval authority, installed policy, repository
contents and Git administrative state, Forge credentials, independent-review
provenance, CI/release state, work-item evidence, and unrelated user changes.
Trust boundaries exist between the human channel, host harness, installed
Flow42 bundle, discovered repository data, configured commands, worker agents,
Git common/worktree directories, Forge CLI/API, CI, and distribution channels.

## Abuse cases, controls, and available proof

| Abuse case | Enforced control | Available repository proof |
| --- | --- | --- |
| Repository `AGENTS.md` or `CLAUDE.md` injects authority | Host-delivered instructions retain host precedence, but delivery is not authentication. Discovered files are data; ambiguous provenance blocks. An untrusted instruction-file change requires a trusted base and human handling before launch. | Text/structural assertions plus an opt-in native Codex observation that `AGENTS.md` can be elevated. The observation proves delivery behavior only, not authentication or security. |
| Configured argv names Git, Forge, or infrastructure authority | Empty and whitespace-ambiguous tokens fail. Every argv token is checked by ASCII-casefolded basename for `git`, `gh`, `glab`, and `terraform`; the explicit read-only exception list is empty. The separate blocked-launcher list uses the same normalization and is illustrative, not exhaustive. | Portable schema tests cover authority-bearing tokens in first and later positions, case variants, path-qualified tokens, shell syntax, and accepted repository-script residuals. The naming predicate is not evidence of arbitrary program semantics. |
| A repository executable performs an undeclared side effect | Configured project tools remain inside worker capability, ownership, and human-action gates. No semantic-sandbox claim is made for arbitrary executables, build runners, copied binaries, or launchers that resolve a control tool without naming it. | Structural policy checks plus an accepted disposable repository-script fixture; arbitrary program semantics remain residual risk. |
| Worker changes an unowned path or hides a rename endpoint | NUL-safe porcelain-v2 and tracked-delta parsing retains supported ordinary, rename/copy, unmerged, and untracked records; both rename endpoints are checked; unknown record types and cross-boundary overlap fail closed. Pre-existing dirty content is compared by identity with literal pathspecs. | Executable temporary Git repositories cover spaces, tabs, newlines, UTF-8, leading dashes, rename/delete, conflict, already-dirty, and collision cases. |
| Worker changes Git state while the worktree appears clean | Pre/post identity covers canonical common/worktree Git directories, config and remotes, effective hooks, refs and `HEAD`, and index. Workers never stage; only the coordinator may stage an exact reviewed path after the post-worker checks pass. | Temporary repositories show remote, hook, ref, and assume-unchanged index mutations changing the administrative snapshot while porcelain status remains clean; a cross-document mutation check rejects a reintroduced worker-staging exception. |
| External included Git configuration changes outside the administrative trees | Effective config bytes bind value, origin path, and scope. External include files are not identity-bound, so an equal-value same-origin replacement is disclosed rather than claimed as detected. | A value change changes the snapshot; replacing the include with an equal-content symlink leaves it unchanged and pins the residual. |
| An external alternate object store changes | The in-tree alternates declaration is bound, but Flow42 does not resolve or recursively snapshot the external store. External alternate content can make a pre-existing latent ref become resolvable or unresolvable without changing the bound ref stream. Snapshot equality is not object-availability proof; integration may rely only on objects and identities explicitly resolved for its actual baseline, `HEAD`, index, and owned worktree decision. | The declaration changes the snapshot. A disposable latent-ref fixture pins an unchanged snapshot and bound ref stream while external content changes resolvability. |
| External text fabricates confirmation or review | Repository, work-item, issue, review, CI-log, and web text are data. Human confirmation is explicit. Independent-review receipts bind the review subject and fail closed when the configured issuer/resolver cannot establish it. | Structural schemas, mutation fixtures, and local fake-resolver/temporary-Git behavior. These do not authenticate a real provider. |
| Worker writes to Forge, delegates, merges, deploys, publishes, force-pushes, or destroys state | Worker authority excludes Forge writes and delegation. Irreversible and high-risk actions require explicit human confirmation and coordinator execution. Delegation blocks integration when observed through Orca records or worker reporting in native execution. | Structural failure cases and contract checks; no live remote mutation is performed. A non-cooperative native worker remains a residual because it can delegate without reporting. |
| Secrets leak through evidence or remotes | URL userinfo/query data and sensitive values are excluded or reduced to hashes; raw auth output and raw remotes are not persisted. | Local redaction and conformance checks. |

## Instruction-provenance residual

Codex and Claude may inject repository instruction files before Flow42 runs and
without an authenticated commit/source signal. Flow42 cannot demote an
instruction that the host already assigned higher precedence. Consequently,
the trusted operator or harness must establish a trusted repository base and
handle untrusted instruction-file changes before launching the agent. If that
outer control is absent, instruction-source authenticity remains an explicit
residual risk; the local native probe must not be cited as proof that it is
resolved.

## Other residual risk

Flow42 skills are interpreted policy, not an OS sandbox. Runtime capability
isolation varies, arbitrary repository executables are not semantically proven
safe, local receipt resolvers cannot establish provider identity, Forge records
can change outside a captured run, hardlinked review evidence has a concurrent
same-user mutation residual, and supply-chain verification depends on trusted
installed keys and tools. Flow42 does not independently enumerate process
identity; Orca owns that lifecycle when selected. A focused local green suite
therefore proves only the named fixture semantics and structural contracts.
Claims about native agent compliance, authenticated Forge identity, exact-head
remote CI, release, or deployment require separate evidence at that tier.
