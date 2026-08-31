#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
workflow="$root/core/workflow.json"
risk="$root/core/risk-policy.json"
scenarios="$root/evals/scenarios.json"

sh "$root/tests/intent.sh"

test "$(jq '.transitions | length' "$workflow")" -eq 10
test "$(jq '.side_transitions | length' "$workflow")" -eq 4
jq -e '.transitions[] | select(.from == "draft-intent" and .to == "drafting-spec" and (has("gate") | not))' "$workflow" >/dev/null
jq -e '.transitions[] | select(.from == "drafting-spec" and .to == "planning" and (has("gate") | not))' "$workflow" >/dev/null
jq -e '.transitions[] | select(.from == "plan-gate" and .to == "building" and .gate == "plan")' "$workflow" >/dev/null
jq -e '.transitions[] | select(.to == "ready-for-human" and .gate == "independently-reviewed-and-ci-green")' "$workflow" >/dev/null
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
jq -e '.human_approval.accountable_approvers_per_gate == 1 and .human_approval.second_human_required == false and (.human_approval | has("authenticated_provenance_required") | not)' "$risk" >/dev/null
jq -e '.independent_review.implementer_may_review == false and .independent_review.exact_head_sha_required == true and .independent_review.grants_human_approval == false' "$risk" >/dev/null
jq -e '.accountable_human_approvers_per_gate == 1 and .second_human_required == false' "$workflow" >/dev/null

for gate in high-risk-plan irreversible-action merge deploy; do
  grep -q "^  - $gate$" "$root/templates/config.yml"
done

for id in happy-feature invalid-transition interrupted-resume unsafe-action \
  forge-cli-missing forge-auth-failure ci-failure security-escalation \
  worktree-conflict delegation-bounds adapter-parity install-lifecycle unsafe-model-routing; do
  jq -e --arg id "$id" '.scenarios[] | select(.id == $id)' "$scenarios" >/dev/null
done

for phrase in 'never merges' 'force-pushes' 'explicit human authorization'; do
  grep -qi "$phrase" "$root/core/CONTRACT.md"
done
tr '\n' ' ' <"$root/core/CONTRACT.md" | grep -Eq '(explicit confirmation from one|exactly one) accountable( authenticated)? human'
for phrase in 'did not implement the change' 'exact head SHA'; do
  tr '\n' ' ' <"$root/core/CONTRACT.md" | grep -q "$phrase"
done
for phrase in 'task schedule graph' 'data flow graph' 'majority voting' 'utility model'; do
  grep -R -qi "$phrase" "$root/core"
done
grep -q 'harness: auto' "$root/templates/config.yml"
grep -q 'execution_environment: auto' "$root/templates/config.yml"
grep -q 'frontier: auto' "$root/templates/config.yml"
tr '\n' ' ' <"$root/skills/pr/SKILL.md" | grep -q 'do not create a comment solely to manufacture review provenance'
grep -q 'change-request creation are reversible' "$root/core/CONTRACT.md"
grep -q 'read-only onboarding preflight' "$root/skills/init/SKILL.md"
tr '\n' ' ' <"$root/skills/init/SKILL.md" |
  grep -Fq 'every directory in the canonical skill set'
grep -q 'ready.*,.*optional.*,.*blocked' "$root/skills/init/SKILL.md"
grep -Fq 'shellcheck scripts/*.sh scripts/install-local tests/*.sh' "$root/.github/workflows/ci.yml"

for phrase in 'never use' 'explicit confirmation' 'coordinator owns those operations' 'immutable V1 tag'; do
  grep -qi "$phrase" "$root/core/SECURITY.md"
done

for phrase in 'orca skills get orchestration' 'worker-start' 'worker_done' 'release each'; do
  grep -q "$phrase" "$root/skills/flow/SKILL.md"
done
grep -q 'Use one agent by' "$root/skills/flow/SKILL.md"
grep -q 'Generic subagent or terminal tools are not substitutes' "$root/skills/flow/SKILL.md"

for command in 'gh auth status' 'gh pr create' 'glab auth status' 'glab mr create'; do
  tr '\n' ' ' <"$root/skills/pr/SKILL.md" | grep -q "$command"
done

echo 'contracts ok: lifecycle, risk, safety, Forge, scenarios'
