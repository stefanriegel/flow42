# Configuration

`.flow42/config.yml` is versioned and contains no secrets.

| Field | Values | Meaning |
| --- | --- | --- |
| `schema_version` | `1` | Configuration contract version. |
| `forge` | `auto`, `github`, `gitlab`, `none` | Provider selection. `auto` inspects `origin`. |
| `base_branch` | `auto` or branch | Integration base. |
| `concurrency` | `1`–`4` | Total worker ceiling; workers cannot delegate. |
| `worktree_parent` | `auto` or safe path | Isolated worktree location. |
| `commands.*` | token array, `[auto]`, or `[]` | Direct-argv checks discovered by `init`. |
| `protected_paths` | path list | Areas that raise risk and review depth. |
| `mandatory_gates` | gate list | May add gates but never remove canonical gates. |

Unknown fields or schema versions block execution until a human approves a
migration. `auto` values must be resolved into work-item evidence before build.
The resolved configuration digest requires human approval. Never execute command
strings through a shell; each array element is one argument.
