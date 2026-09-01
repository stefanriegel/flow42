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
| `base_branch` | `auto` or branch | Integration base. |
| `concurrency` | `1`–`4` | Total worker ceiling; workers cannot delegate. |
| `worktree_parent` | `auto` or safe path | Isolated worktree location. |
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
element is one argument.

Model profiles are capability floors, not model allowlists. The orchestrator records the
resolved provider, model, and reasoning level for every delegated job. See
[model routing](../core/MODEL-ROUTING.md).
