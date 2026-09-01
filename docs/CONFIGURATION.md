# Configuration

`.flow42/config.yml` is versioned and contains no secrets. The machine-readable
authority is [`skills/flow42/core/policy.json`](../skills/flow42/core/policy.json)'s
`.config_schema`; this page is its human rendering.

| Field | Values | Meaning |
| --- | --- | --- |
| `schema_version` | `3` | Configuration contract version. |
| `forge` | `auto`, `github`, `gitlab`, `none` | Provider selection. `auto` inspects `origin`. |
| `base_branch` | `auto` or a valid branch name | Integration base. |
| `concurrency` | `1`–`4` | Total worker ceiling. |
| `worktree_parent` | `auto` or a safe repository-relative path | Absolute, home-relative, and parent-traversing paths are rejected. |
| `bootstrap` | `required`, `done`, or absent | Set by `init` on a greenfield target with no discovered toolchain; the first build slice must establish one and flip this to `done`. |
| `commands.format` / `lint` / `typecheck` / `test` / `build` | token array or `[]` | Direct-argv checks; never a shell string. |
| `protected_paths` | path list | Areas that raise risk and review depth. |
| `mandatory_gates` | gate list | May add gates but must include every gate in `must_include_all`. |
| `model_profiles.frontier` / `worker` / `utility` | `{agent, model, effort}` | Per-tier defaults for `orca orchestration worker-start`; see `policy.json .model_profiles`. |

Unknown fields or an unsupported `schema_version` block execution until the
configuration is migrated and revalidates. Configuration never requires a
Forge interaction or an approval artifact of its own.

## The five command rules

Every entry under `commands.*` is a token array, checked against
`policy.json .config_schema.command_policy_rules`:

1. Commands are token arrays, never shell strings.
2. Every token is printable ASCII (`^[!-~]+$`).
3. No token contains `$` `` ` `` `;` `|` `&` `<` `>` `(` `)`.
4. The first token is not a shell or launcher: `sh`, `bash`, `dash`, `zsh`,
   `env`, `eval`, `command`, `xargs`, `nohup`, `timeout`.
5. The first token is not an authority CLI: `git`, `gh`, `glab`, `terraform`,
   `kubectl`, `helm`.

A command that fails any rule is rejected at write time, not silently
tolerated at execution time. This is a naming check, not a semantic sandbox:
a rejected token cannot reach one of these tools directly, but a repository
script or build runner that reaches one indirectly is not proven safe by this
check — configured project tools still run inside the ordinary worker,
ownership, and human-confirmation boundary described in
[Architecture](ARCHITECTURE.md).
