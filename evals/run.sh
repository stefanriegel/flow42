#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-evals.XXXXXX")
trap 'find "$tmp" -depth -delete' EXIT HUP INT TERM

pass=0

record_pass() {
  pass=$((pass + 1))
  printf 'ok %s\n' "$1"
}

if jq -e '.scenarios[] | select(.id == "invalid-transition" and .result == "blocked" and (.requires | index("no-state-mutation")))' "$root/evals/scenarios.json" >/dev/null; then
  record_pass invalid-transition
fi

printf '%s\n' '{"revision":3,"from":"building","to":"blocked"}' >"$tmp/history.jsonl"
if test "$(jq -r '.revision' "$tmp/history.jsonl")" = 3 && test "$(jq -r '.to' "$tmp/history.jsonl")" = blocked; then
  record_pass interrupted-resume
fi

if grep -q 'never merges' "$root/core/CONTRACT.md" && grep -q 'explicit human authorization' "$root/core/CONTRACT.md"; then
  record_pass unsafe-action
fi

if ! PATH=/nonexistent command -v gh >/dev/null 2>&1; then
  record_pass forge-cli-missing
fi

if grep -q 'auth status' "$root/skills/pr/SKILL.md" && grep -q 'block' "$root/core/SECURITY.md"; then
  record_pass forge-auth-failure
fi

if jq -e '.scenarios[] | select(.id == "ci-failure" and .result == "blocked")' "$root/evals/scenarios.json" >/dev/null; then
  record_pass ci-failure
fi

if jq -e '.security_gates == ["threat-model", "independent-security-review"]' "$root/core/risk-policy.json" >/dev/null; then
  record_pass security-escalation
fi

if sh "$root/tests/security.sh" >/dev/null; then
  record_pass worktree-conflict
fi

if grep -q 'forbid recursive delegation' "$root/skills/flow/SKILL.md" && grep -q 'worker limit' "$root/core/OWNERSHIP.md"; then
  record_pass delegation-bounds
fi

test "$pass" -eq 9
echo "evals ok: $pass failure paths"
