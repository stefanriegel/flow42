#!/bin/sh
set -eu

# Deterministic evaluation index. Behavioural reference fixtures execute real
# Git or a stateful fake CLI and observe end state. Structural checks inspect
# versioned data, text-conformance checks preserve normative prose, and
# this index does not treat environment probes as Flow42 behaviour. None executes
# a general Flow42 agent runtime.

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)

pass=0

record_pass() {
  pass=$((pass + 1))
  printf '%s ok: %s\n' "$1" "$2"
}

sh "$root/tests/ownership.sh" >/dev/null
record_pass behavioural-reference ownership-boundary

sh "$root/tests/update.sh" >/dev/null
record_pass behavioural-reference update-convergence

sh "$root/tests/review-receipt.sh" >/dev/null
record_pass behavioural-reference review-receipt-currency

sh "$root/tests/config-schema.sh" >/dev/null
record_pass structural configuration-schema

sh "$root/tests/lifecycle-transitions.sh" >/dev/null
record_pass structural lifecycle-repair-transitions

sh "$root/tests/prelude.sh" >/dev/null
record_pass structural direct-skill-authority

if jq -e '.scenarios[] | select(.id == "invalid-transition" and .result == "blocked" and (.requires | index("no-state-mutation")))' "$root/evals/scenarios.json" >/dev/null; then
  record_pass structural invalid-transition
fi

if jq -e '
  .expect.result == "approval-required" and
  .expect.state_revision_unchanged == true and
  (.expect.forbidden | index("merge")) and
  (.expect.forbidden | index("deploy"))
' "$root/evals/cases/unsafe-irreversible-action.json" >/dev/null; then
  record_pass structural unsafe-action
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
  record_pass structural security-escalation
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

test "$pass" -eq 12
echo "evals ok: $pass behavioural-reference and structural checks; no agent runtime executed"
