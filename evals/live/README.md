# Live evals

These four prompts are live agent evals (decision 14): a real coordinator runs
the flow42 skill end to end and asserts on the resulting `.flow42/` files. They
are not part of `tests/*.sh` and never run in per-push CI — CI only runs the
structural suite and `tests/history.sh`. Each eval runs scheduled, in its own
disposable workspace, as an Orca automation.

## Scenarios

- `greenfield-start.md` — empty directory. Expects a git-init offer, a
  `bootstrap: required` config, and an intent created.
- `trivial-brownfield-fix.md` — a tiny repo with a one-line bug and a failing
  test fixture. Expects observed red-green evidence and no `plan-gate` stage
  for a low-risk fix.
- `maintain-triage.md` — a repo with a fabricated local signals fixture and
  `forge: none`. Expects deduplicated signal entries with `triage:` values and
  no Forge calls.
- `blocked-resume.md` — a pre-seeded `.flow42/` fixture with a blocked work
  item and `resume_stage` bound in history. Expects resume to the bound stage
  when the binding is valid, and a refusal when the binding is broken.

## Scheduling

Create one Orca automation per eval, following the `maintain` cadence example
in `stages/maintain.md`. Each eval automation differs from that example the
same way: a fresh, throwaway workspace per run instead of the existing repo,
and the eval file's own content as the prompt. Spread the weekly triggers
across different days so the four runs never collide.

```sh
orca automations create --name flow42-eval-greenfield-start --provider claude \
  --workspace-mode new-per-run \
  --trigger weekly --day 1 --time 03:00 \
  --prompt "$(cat evals/live/greenfield-start.md)" --enabled

orca automations create --name flow42-eval-trivial-brownfield-fix --provider claude \
  --workspace-mode new-per-run \
  --trigger weekly --day 2 --time 03:00 \
  --prompt "$(cat evals/live/trivial-brownfield-fix.md)" --enabled

orca automations create --name flow42-eval-maintain-triage --provider claude \
  --workspace-mode new-per-run \
  --trigger weekly --day 3 --time 03:00 \
  --prompt "$(cat evals/live/maintain-triage.md)" --enabled

orca automations create --name flow42-eval-blocked-resume --provider claude \
  --workspace-mode new-per-run \
  --trigger weekly --day 4 --time 03:00 \
  --prompt "$(cat evals/live/blocked-resume.md)" --enabled
```

Use `--provider codex` on a second set of automations to cover the other
coordinator (decision 3); the prompts are agent-agnostic and need no change.

## Reading results

```sh
orca automations runs --name flow42-eval-<name>
```

Each run's last line is `EVAL PASS <name>` or `EVAL FAIL <name>: <reason>`. A
`FAIL` line is a defect: file it as a maintenance signal in this repo's own
`.flow42/signals.md` (source: the automation run, cause: the failed
assertion, triage: judged by impact) rather than silently rerunning until it
passes.
