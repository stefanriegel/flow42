# Public evaluations

Flow42 evaluates workflow outcomes, not prose similarity. Every fixture defines
an initial repository, intent, allowed actions, required gates, expected
artifacts, and observable pass/fail conditions.

Planned fixture families:

- greenfield feature;
- bug fix with observed red-green;
- legacy characterization before change;
- behavior-preserving refactor;
- UI change with visual/interaction evidence;
- migration with dry-run and rollback proof;
- interrupted session and deterministic resume;
- conflicting unrelated user changes;
- stale or invalid approval hash;
- GitHub and GitLab PR/MR parity;
- Claude Code and Codex adapter parity.

Fixtures must contain no private repositories, credentials, or unverifiable
claims. Benchmark reports publish methodology, environment, raw aggregate
results, limitations, and Flow42 version.

Run deterministic failure-path evaluations with:

```sh
sh evals/run.sh
```

Native harness evidence is recorded under `evidence/evals/`; these runs complement
the deterministic suite and are required before a harness-parity claim.

## Portable failure cases

`cases/*.json` are executable, harness-neutral inputs for both Claude Code and
Codex. A harness reads `entrypoint` as the Flow42 skill to invoke, materializes
the durable state described by `given`, performs `when.request`, and compares
the observed durable state and attempted actions with `expect`. Values under
`forbidden` are negative assertions: observing any one of them fails the case.
Fixtures use only synthetic identities, URLs, hashes, and worktree paths.

The cases cover downstream invalidation after a stale intent approval,
status/history mismatch recovery, irreversible actions without authorization,
Forge authentication failure, required-CI failure, and forbidden worker
delegation. Validate their common schema and scenario-specific invariants with:

```sh
sh evals/cases/run.sh
```

Passing the fixture validator proves that the inputs are complete and internally
consistent. It does not by itself prove harness parity; record actual runs from
both harnesses under `evidence/evals/` before making that claim.
