# Public evaluations

The deterministic evaluation index uses three explicitly separate proof tiers:

- **Behavioural reference fixtures:** disposable Git repositories and a
  test-local receipt resolver observe ownership, including committed rename
  attribution, and review-receipt currency. They prove the test-local predicates
  against Git and resolver semantics; they do not prove that an installed agent
  followed the instructions.
- **Structural:** JSON/YAML shape, declared workflow targets, schema validation,
  lifecycle-grammar simulations, portable case consistency, and byte-identical
  direct-skill preludes. Structural simulation is not Flow42 runtime behaviour.
- **Text conformance:** normative prose remains present. This detects accidental
  deletion but does not prove Git behaviour or agent semantics.
  `tests/update.sh` is in this tier: it checks the runtime-free update
  instructions' structure, required boundaries, and evaluation label, without
  executing a vendor CLI or observing update convergence.

`tests/release-checksum.sh` is a separate local cryptographic fixture. It creates
disposable signed tags and deterministic archives with fixture keys and exercises
the trusted verifier, manifest binding, and checksum checks. This proves the
local Git, SSH-signature, archive, and checksum path only; it does not prove a
live remote advertisement or published artifact, native harness installation,
readback or recovery, or private cache bytes.

Environment probes are outside those proof tiers. In particular, masking
`PATH` and calling `command -v` does not execute Flow42's missing-Forge behavior
and is not an evaluation result.

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

The runner prints the proof tier beside every check. It does not count a literal
fixture read or environment probe as behaviour. Its summary is an index of mixed
local evidence, not a native-agent or harness-parity result.

Native harness evidence is recorded under `evidence/evals/`; these runs complement
the deterministic suite and are required before a harness-parity claim. The
deterministic suite contains no live update run for Claude Code, Codex, or Pi.

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
in `forbidden-actions.json`. The validator also requires that vocabulary to be
the sorted, duplicate-free exact union used by all case fixtures, so adding or
removing a fixture action cannot silently drift from the index. This remains a
structural consistency check: it does not execute an agent or prove
harness parity; record actual runs from both harnesses under `evidence/evals/`
before making either claim.
