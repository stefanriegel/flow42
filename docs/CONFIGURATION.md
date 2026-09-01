# Configuration

`.flow42/config.yml` is versioned and contains no secrets. The machine-readable
authority is [`core/config-schema.json`](../core/config-schema.json); this page is
its human rendering.

| Field | Values | Meaning |
| --- | --- | --- |
| `schema_version` | `1` | Configuration contract version. |
| `forge` | `auto`, `github`, `gitlab`, `none` | Provider selection. `auto` inspects `origin`. |
| `harness` | `auto`, `claude-code`, `codex`, `pi` | Active coding-agent harness. |
| `execution_environment` | `auto`, `orca`, `native` | Prefer Orca ADE when its CLI reports a ready runtime. |
| `base_branch` | `auto` or `git check-ref-format --branch` valid name | Integration base. |
| `concurrency` | `1`–`4` | Total worker ceiling; workers cannot delegate. |
| `worktree_parent` | `auto` or safe repository-relative path | Absolute, home-relative, and parent-traversing paths are rejected. |
| `model_profiles.frontier` | `auto` or `^[A-Za-z0-9][A-Za-z0-9._:/-]{0,127}$` | Frontier model preference. |
| `model_profiles.worker` | same pattern | Worker model preference. |
| `model_profiles.utility` | same pattern | Utility model preference. |
| `commands.format` | token array, `[auto]`, or `[]` | Direct-argv formatting check. |
| `commands.lint` | token array, `[auto]`, or `[]` | Direct-argv lint check. |
| `commands.typecheck` | token array, `[auto]`, or `[]` | Direct-argv type check. |
| `commands.test` | token array, `[auto]`, or `[]` | Direct-argv test check. |
| `commands.build` | token array, `[auto]`, or `[]` | Direct-argv build check. |
| `protected_paths` | path list | Areas that raise risk and review depth. |
| `mandatory_gates` | gate list | May add gates but never remove canonical gates. |

Unknown fields or schema versions block execution until the configuration is
migrated and validates. The retired gate names `intent`, `spec`, `config`,
`configuration`, and `approval` have the explicit `block-with-migration` effect;
delete them rather than translating them into a replacement approval gate.
Additional project-specific gates remain allowed, but all four canonical gates
are required. A command token that looks like a repository path must exist,
unless the value is `[auto]`. `auto` values must be resolved into work-item
evidence before build. Configuration does not require an approval artifact or
Forge interaction. Never execute command strings through a shell; each array
element is one argument. Under the POSIX C locale, tokens are restricted to
printable ASCII, while
whitespace, commas, square brackets, and every dollar-bearing token are rejected.
This excludes Unicode executable-name lookalikes and dollar-brace expansion.
The command policy applies one ordered-signature matcher to authority-bearing
executable singletons, blocked-launcher singletons, shell-evaluation signatures,
and declared mutation signatures. Every token position is a potential
executable; its basename is ASCII-casefolded, and the remaining signature tokens
must occur later in order. This catches named wrappers and intervening global
options without parsing each CLI grammar. The
schema's shared read-only control-CLI allowlist is intentionally empty. Bare and
path-qualified `xcrun` remains one blocked launcher because it can locate and
execute a developer tool; this includes default run mode, `--run`/`-r`, SDK
selection, and toolchain selection. The blocked-launcher list is illustrative,
not exhaustive, and adding an entry does not prove every wrapper is enumerated.

This predicate is a naming check, not a semantic sandbox. It cannot see an
authority-bearing tool reached through an arbitrary repository script,
executable, build runner, copied or renamed binary, or unlisted launcher that
resolves the tool itself. Configured project tools therefore still run inside
the normal worker, ownership, and capability boundary, with no implicit Git,
Forge, infrastructure, deployment, publish, or irreversible-action authority.

The accepted YAML subset is deliberate: plain unquoted single-line scalars,
two-space-indented mappings, inline comma-separated plain token arrays, and
empty-inline or two-space block lists for paths and gates. Aliases, anchors,
tags, merge keys, flow mappings, quoted/multiline scalars, and other YAML forms
are rejected rather than interpreted differently by different harnesses.
Comments are also rejected by this deliberately data-only subset.
Duplicate mapping keys are also rejected before semantic validation.

Model profiles are capability floors, not model allowlists. The orchestrator records the
resolved provider, model, and reasoning level for every delegated job. See
[model routing](../core/MODEL-ROUTING.md).
