# Public evaluations

Flow42 uses three explicitly separate proof levels:

- **Behavioural:** disposable Git repositories and stateful fake harnesses
  observe end state, including update, ownership, receipt-currency,
  configuration, and lifecycle-transition controls.
- **Structural:** JSON/YAML shape, declared workflow targets, schema validation,
  and byte-identical direct-skill preludes.
- **Text conformance:** normative prose remains present. This detects accidental
  deletion but does not prove Git behaviour or agent semantics.

Every portable fixture defines an initial repository, intent, allowed actions,
required gates, expected artifacts, and observable pass/fail conditions.

Planned fixture families:

- greenfield feature;
- bug fix with observed red-green;
- legacy characterization before change;
- behavior-preserving refactor;
- UI change with visual/interaction evidence;
- migration with dry-run and rollback proof;
- interrupted session and deterministic resume;
- conflicting unrelated user changes;
- invalid or inconsistent persisted artifacts;
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

`cases/*.json` are harness-neutral inputs for both Claude Code and Codex. A
future stable harness reads `entrypoint` as the Flow42 skill to invoke, materializes
the durable state described by `given`, performs `when.request`, and compares
the observed durable state and attempted actions with `expect`. Values under
`forbidden` are negative assertions: observing any one of them fails the case.
Fixtures use only synthetic identities, URLs, commit identifiers, and worktree paths.

The cases cover implementer self-review rejection, fabricated human-authorization
rejection, status/history mismatch recovery, irreversible actions without
authorization, Forge authentication failure, required-CI failure, and forbidden
worker delegation. Validate their common schema and scenario-specific invariants
with the command below. Unsafe model identifiers also fail before invocation.

```sh
sh evals/cases/run.sh --dry-run
```

The dry run proves that inputs are complete and internally consistent, that each
entry point exists, each resume stage is declared, and each forbidden action is
in the validator's declared vocabulary. It does not execute an agent or prove
harness parity; record actual runs from both harnesses under `evidence/evals/`
before making either claim.
