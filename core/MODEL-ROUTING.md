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
level, required inputs, and output validation in evidence.

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
Before persistence or invocation, require model IDs to match
`^[A-Za-z0-9][A-Za-z0-9._:/-]{0,127}$` and reasoning levels to be one of
`off`, `minimal`, `low`, `medium`, `high`, `xhigh`, or `max`. Never interpolate
a repository or work-item value into a terminal command string. Use a fixed,
human-approved command or a structured argv interface.

## Orca orchestration

Use a single agent by default. Use Orca orchestration only when the user asks for
it or independent, non-overlapping slices materially benefit from parallel work.
Resolve the current orchestration guide with `orca skills get orchestration`;
do not guess a cached command contract.

```sh
orca status --json
orca orchestration run-create --objective "<objective>" --json
orca orchestration task-create --spec "<bounded job>" --json
orca orchestration worker-start --task <task-id> --worktree current --agent codex --json
orca orchestration check --wait --types worker_done,escalation,question --timeout-ms 900000 --json
orca orchestration worker-release --dispatch <dispatch-id> --json
```

Create all independent tasks before starting their workers, wait for a valid
`worker_done` or escalation for every dispatch, and release settled workers.
Generic subagent tools are not Orca orchestration and must not be described as
such. If Orca is absent or not ready, continue with a normal single-agent flow.
