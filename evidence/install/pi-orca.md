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
- The version-matched Orca CLI guide lists `pi` as a known agent and documents
  agent-first worktree creation.
- Explicit Pi model selection uses a custom Orca terminal command, followed by
  `terminal wait --for tui-idle` and a single prompt send to the returned handle.
- Flow42 falls back to native harness and Git operations when Orca is absent or
  not ready; Orca remains optional.
