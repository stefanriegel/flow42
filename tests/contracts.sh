#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
workflow="$root/core/workflow.json"
risk="$root/core/risk-policy.json"
scenarios="$root/evals/scenarios.json"

test "$(jq '.transitions | length' "$workflow")" -eq 12
test "$(jq '.side_transitions | length' "$workflow")" -eq 4
jq -e '.transitions[] | select(.from == "intent-gate" and .to == "drafting-spec" and .gate == "intent")' "$workflow" >/dev/null
jq -e '.transitions[] | select(.from == "spec-gate" and .to == "planning" and .gate == "spec")' "$workflow" >/dev/null
jq -e '.transitions[] | select(.from == "plan-gate" and .to == "building" and .gate == "plan")' "$workflow" >/dev/null
jq -e '.transitions[] | select(.to == "ready-for-human" and .gate == "reviewed-and-ci-green")' "$workflow" >/dev/null
jq -e '.terminal_outcome == "ready-for-human"' "$workflow" >/dev/null
jq -e '.side_states == ["blocked", "abandoned", "superseded"]' "$workflow" >/dev/null

for stage in drafting-spec verifying pr-ready; do
  grep -R -q "$stage" "$root/skills"
done
if grep -R -E -q "\`(draft-spec|verification|pr-gate)\`" "$root/skills"; then
  exit 1
fi

jq -e '.baseline_checks == ["secrets", "dependencies", "static-analysis"]' "$risk" >/dev/null
jq -e '.security_triggers | length == 7' "$risk" >/dev/null
jq -e '.automatic_review_limit == 2' "$risk" >/dev/null

for gate in intent spec high-risk-plan irreversible-action merge deploy; do
  grep -q "^  - $gate$" "$root/templates/config.yml"
done

for id in happy-feature invalid-transition stale-approval interrupted-resume unsafe-action \
  forge-cli-missing forge-auth-failure ci-failure security-escalation \
  worktree-conflict delegation-bounds adapter-parity install-lifecycle; do
  jq -e --arg id "$id" '.scenarios[] | select(.id == $id)' "$scenarios" >/dev/null
done

for phrase in 'never merges' 'force-pushes' 'explicit human authorization' 'stale approval must block'; do
  grep -qi "$phrase" "$root/core/CONTRACT.md"
done
grep -q 'change-request creation are reversible' "$root/core/CONTRACT.md"

for phrase in 'never use' 'authenticated approval' 'no Forge-write authority' 'immutable V1 tag'; do
  grep -qi "$phrase" "$root/core/SECURITY.md"
done

for command in 'gh auth status' 'gh pr create' 'glab auth status' 'glab mr create'; do
  tr '\n' ' ' <"$root/skills/pr/SKILL.md" | grep -q "$command"
done

echo 'contracts ok: lifecycle, risk, safety, Forge, scenarios'
