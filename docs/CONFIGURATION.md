# Configuration

`.flow42/config.yml` is versioned and contains no secrets.

| Field | Values | Meaning |
| --- | --- | --- |
| `schema_version` | `1` | Configuration contract version. |
| `forge` | `auto`, `github`, `gitlab`, `none` | Provider selection. `auto` inspects `origin`. |
| `harness` | `auto`, `claude-code`, `codex`, `pi` | Active coding-agent harness. |
| `execution_environment` | `auto`, `orca`, `native` | Prefer Orca ADE when its CLI reports a ready runtime. |
| `base_branch` | `auto` or branch | Integration base. |
| `concurrency` | `1`–`4` | Total worker ceiling; workers cannot delegate. |
| `worktree_parent` | `auto` or safe path | Isolated worktree location. |
| `model_profiles.*` | `auto` or harness model ID | Frontier, worker, and utility model preferences. |
| `commands.*` | token array, `[auto]`, or `[]` | Direct-argv checks discovered by `init`. |
| `protected_paths` | path list | Areas that raise risk and review depth. |
| `mandatory_gates` | gate list | May add gates but never remove canonical gates. |

Unknown fields or schema versions block execution until a human approves a
migration. `auto` values must be resolved into work-item evidence before build.
The resolved configuration digest requires human approval. Never execute command
strings through a shell; each array element is one argument.

Model profiles are capability floors, not model allowlists. The orchestrator records the
resolved provider, model, and reasoning level for every delegated job. See
[model routing](../core/MODEL-ROUTING.md).
