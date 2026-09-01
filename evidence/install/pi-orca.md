> LEGACY (recorded against v0.x–v2 schemas; describes retired stages/counts. Kept for provenance; superseded by V3 live evals.)

# Pi and Orca ADE evidence

- Date: 2026-08-28
- Flow42 source: local `release/v1.0.1-readiness`; the PR head and CI run bind
  this record to the final commit
- Pi: 0.84.3 on macOS
- Orca: 1.4.190, local runtime ready

## Pi package and skills

- An isolated `PI_CODING_AGENT_DIR` installed the checkout as a local Pi package
  and `pi list` read it back.
- A read-only Pi invocation loaded `skills/` and returned all 11 canonical names:
  `build`, `flow`, `init`, `intent`, `maintain`, `plan`, `pr`, `resume`, `spec`,
  `status`, and `verify`.
- `openai-codex/gpt-5.6-sol` with minimal thinking returned the expected discovery
  sentinel through Pi.
- `qwen-redteam/qwen3.8-27b-uncensored` completed the 11-skill discovery check.
- `ollama-coding/qwen3-coder:30b-64k` was configured and authenticated but its
  endpoint returned `Connection error`; it is documented as an available local
  route, not a successful invocation.
- No credential values were read or printed.

## Orca ADE

- `orca status --json` reported `runtime.state: ready` and `graph.state: ready`.
- Orca created a child worktree at exact source commit
  `b9e8d83913cf0e73a968420975c99da7ad63260b`.
- An accountable-coordinator Orca terminal launched Pi with Qwen 3.8 and the
  checkout's Flow42 skills. This was not a delegated worker and made no Forge call.
  The model twice exhausted its response before writing files, so the job was
  escalated instead of retried again.
- A second accountable-coordinator Orca terminal launched Pi with
  `openai-codex/gpt-5.6-sol` in the same
  worktree. It created all eight files for `orca-pi-hello-proof`, reached
  `intent-gate` at revision 2, wrote matching two-entry history, and left every
  approval field empty.
- Intent SHA-256:
  `ad25d97b872a1c12cbad279e20fa235f27c8cc0bf1ffbf70a0416742aaa58748`
- Sanitized observed state:

```text
source: b9e8d83913cf0e73a968420975c99da7ad63260b
files: approvals.yml decisions.md evidence.md history.jsonl intent.md plan.md spec.md status.yml
status: stage=intent-gate state_revision=2 next_actions=[await-intent-approval]
history: 1 null->draft-intent; 2 draft-intent->intent-gate
approvals: all provenance, actor, timestamp, and hash fields empty
```
- Flow42 falls back to native harness and Git operations when Orca is absent or
  not ready. That fallback and a complete Orca trusted-PR run remain unexecuted
  and are not claimed by this record.