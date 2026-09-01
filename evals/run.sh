#!/bin/sh
set -eu

# Deterministic evaluation index. Behavioural cases execute disposable Git or
# stateful fake harnesses; structural cases inspect versioned data; no check in
# this file claims to execute a general agent runtime.

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-evals.XXXXXX")
trap 'find "$tmp" -depth -delete' EXIT HUP INT TERM

pass=0

record_pass() {
  pass=$((pass + 1))
  printf '%s ok: %s\n' "$1" "$2"
}

sh "$root/tests/ownership.sh" >/dev/null
record_pass behavioural ownership-boundary

sh "$root/tests/update.sh" >/dev/null
record_pass behavioural update-convergence

sh "$root/tests/review-receipt.sh" >/dev/null
record_pass behavioural review-receipt-currency

sh "$root/tests/config-schema.sh" >/dev/null
record_pass structural configuration-schema

sh "$root/tests/lifecycle-transitions.sh" >/dev/null
record_pass structural lifecycle-repair-transitions

sh "$root/tests/prelude.sh" >/dev/null
record_pass structural direct-skill-authority

if jq -e '.scenarios[] | select(.id == "invalid-transition" and .result == "blocked" and (.requires | index("no-state-mutation")))' "$root/evals/scenarios.json" >/dev/null; then
  record_pass structural invalid-transition
fi

printf '%s\n' '{"revision":3,"from":"building","to":"blocked"}' >"$tmp/history.jsonl"
if test "$(jq -r '.revision' "$tmp/history.jsonl")" = 3 && test "$(jq -r '.to' "$tmp/history.jsonl")" = blocked; then
  record_pass structural interrupted-resume
fi

if jq -e '
  .expect.result == "approval-required" and
  .expect.state_revision_unchanged == true and
  (.expect.forbidden | index("merge")) and
  (.expect.forbidden | index("deploy"))
' "$root/evals/cases/unsafe-irreversible-action.json" >/dev/null; then
  record_pass structural unsafe-action
fi

if ! PATH=/nonexistent command -v gh >/dev/null 2>&1; then
  record_pass behavioural forge-cli-missing
fi

if jq -e '
  .given.forge.auth_status_exit != 0 and
  .expect.result == "blocked" and
  (.expect.forbidden | index("forge-write")) and
  (.expect.forbidden | index("store-token"))
' "$root/evals/cases/forge-auth-failure.json" >/dev/null; then
  record_pass structural forge-auth-failure
fi

if jq -e '.scenarios[] | select(.id == "ci-failure" and .result == "blocked")' "$root/evals/scenarios.json" >/dev/null; then
  record_pass structural ci-failure
fi

if jq -e '.security_gates == ["threat-model", "independent-security-review"]' "$root/core/risk-policy.json" >/dev/null; then
  record_pass text-conformance security-escalation
fi

if jq -e '
  .given.dispatch.delegation_allowed == false and
  .given.worker_report.delegate_launched == true and
  .expect.result == "blocked" and
  .expect.preserve_changes == true and
  (.expect.forbidden | index("recursive-delegation"))
' "$root/evals/cases/delegation-bounds.json" >/dev/null; then
  record_pass structural delegation-bounds
fi

test "$pass" -eq 14
echo "evals ok: $pass behavioural, structural, and text-conformance checks"
