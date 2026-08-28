# Model routing contract

Flow42 routes jobs by required capability, risk, and verification cost. It does
not assume that one model should perform every node in the task graph.

| Profile | Use for | Required behavior |
| --- | --- | --- |
| `frontier` | intent synthesis, architecture, integration, ambiguous failures, final review synthesis | strongest available reasoning and full repository context |
| `worker` | bounded implementation, tests, focused research, specialist review | reliable tool use within explicit ownership and an output contract |
| `utility` | formatting, renaming, deterministic extraction, commit-message drafting | narrow context, cheap execution, no independent approval authority |

Use the cheapest profile that satisfies the job contract. Escalate when a worker
cannot satisfy its schema, repeats a failed attempt, encounters ambiguity outside
its ownership, or finds high-impact risk. Do not silently downgrade a frontier or
security-sensitive job. Record the selected harness, provider, model, reasoning
level, input artifact hashes, and output validation in evidence.

Model selection never changes authority. Workers cannot delegate, approve their
own work, merge, deploy, publish, discard changes, or widen scope. A utility model
cannot provide independent review. Parallel reviewers may run on the same exact
head SHA, but any verified critical finding blocks integration; majority voting
cannot override severity.

## Pi examples

Resolve model IDs with `pi --list-models` and authentication readiness with
`pi auth check --model <provider/model> --json --no-refresh`. Never print
credentials. Examples observed with Pi 0.84.3:

```sh
pi --model openai-codex/gpt-5.6-sol --thinking high
pi --model ollama-coding/qwen3-coder:30b-64k
pi --model qwen-redteam/qwen3.8-27b-uncensored
```

Model catalogs are local and change over time. These are examples, not portable
defaults. `model_profiles` stores an approved local choice or `auto`.

## Orca ADE examples

When `orca status --json` reports a ready runtime, use Orca-managed worktrees and
terminals. The known-agent path is sufficient when its default model matches the
profile:

```sh
orca worktree create --name <slice> --agent pi --prompt "<bounded job>" --json
```

For an explicit model, create the worktree, then start Pi with exact arguments:

```sh
orca worktree create --name <slice> --no-parent --json
orca terminal create --worktree <returned-worktree-id> --command 'pi --model openai-codex/gpt-5.6-sol --thinking high' --json
orca terminal wait --terminal <returned-handle> --for tui-idle --timeout-ms 60000 --json
orca terminal send --terminal <returned-handle> --text "<bounded job>" --enter --json
```

Use the returned full worktree ID and terminal handle. If Orca is absent or not
ready, use native harness and Git worktree operations with the same ownership,
data-contract, and recovery rules.
