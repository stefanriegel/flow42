#!/bin/sh
set -eu

# Aggregate behavioural, structural, and explicitly labelled text-conformance
# checks. A green text assertion is not agent-runtime or Git-behaviour proof.

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
workflow="$root/core/workflow.json"
risk="$root/core/risk-policy.json"
scenarios="$root/evals/scenarios.json"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-contracts.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM

for contract_file in "$root/core/SECURITY.md" "$root/docs/CONFIGURATION.md"; do
  tr '\n' ' ' <"$contract_file" | grep -Fq 'illustrative, not exhaustive'
  grep -Fq 'naming check, not a semantic sandbox' "$contract_file"
done
grep -Fq 'by value and origin path only' "$root/core/OWNERSHIP.md"
tr '\n' ' ' <"$root/core/OWNERSHIP.md" |
  grep -Fq 'does not resolve or snapshot an external object store'

for contract_file in "$root/core/SECURITY.md" "$root/core/OWNERSHIP.md"; do
  grep -Fq 'does not govern resource lifecycle' "$contract_file"
done
grep -Fq 'no independent process-identity claim' "$root/core/SECURITY.md"
grep -Fq 'no independent process-identity claim' "$root/docs/ARCHITECTURE.md"
if grep -R -i -E 'untracked process|unauthorized process' \
  "$root/core" "$root/skills" >/dev/null; then
  echo 'Flow42 reacquired an execution-environment process-identity claim' >&2
  exit 1
fi

for contract_file in "$root/core/CONTRACT.md" "$root/core/SECURITY.md" \
  "$root/skills/verify/SKILL.md"; do
  tr '\n' ' ' <"$contract_file" |
    grep -Fq 'Multiply linked evidence files are rejected when observed'
done

validate_diff_producer_contract() {
  contract_file=$1
  tr '\n' ' ' <"$contract_file" |
    grep -Fq 'Receipt-neutral diff validation and diff digest derivation fail closed unless the Git diff producer exits successfully and its complete NUL-delimited output is consumed without parse or hash failure.' || return 1
  if tr '\n' ' ' <"$contract_file" |
    grep -Eiq 'may accept[^.]*Git diff producer[^.]*non-zero|downstream[^.]*may mask[^.]*producer failure'; then
    return 1
  fi
}

for contract_file in "$root/core/CONTRACT.md" "$root/core/SECURITY.md" \
  "$root/skills/verify/SKILL.md"; do
  validate_diff_producer_contract "$contract_file" || {
    echo "receipt diff producer-status contract missing: $contract_file" >&2
    exit 1
  }
done
jq -e '
  .independent_review.diff_producer_status == {
    "applies_to": ["receipt-neutral-diff-validation", "diff-digest-derivation"],
    "git_exit_zero_required": true,
    "complete_nul_output_required": true,
    "downstream_success_may_mask_failure": false
  }
' "$risk" >/dev/null

sed 's/exits successfully/exits non-zero/' \
  "$root/core/CONTRACT.md" >"$tmp/mutated-diff-producer-contract.md"
if validate_diff_producer_contract "$tmp/mutated-diff-producer-contract.md"; then
  echo 'receipt diff producer-status mutation survived' >&2
  exit 1
fi

validate_threat_model_staging() {
  threat_model=$1
  grep -Fq 'Workers never stage; only the coordinator may stage an exact reviewed path after the post-worker checks pass.' \
    "$threat_model" || return 1
  if tr '\n' ' ' <"$threat_model" |
    grep -Eiq 'workers? may[^.]*stag|except an explicitly authorized exact staging operation'; then
    return 1
  fi
}

validate_threat_model_staging "$root/evidence/security/threat-model.md"
cp "$root/evidence/security/threat-model.md" "$tmp/mutated-threat-model.md"
printf '%s\n' 'Workers may perform an exact staging operation during dispatch.' \
  >>"$tmp/mutated-threat-model.md"
if validate_threat_model_staging "$tmp/mutated-threat-model.md"; then
  echo 'threat-model worker-staging mutation survived' >&2
  exit 1
fi

sh "$root/tests/intent.sh"
sh "$root/tests/prelude.sh"
sh "$root/tests/ownership.sh"
sh "$root/tests/review-receipt.sh"
sh "$root/tests/config-schema.sh"
sh "$root/tests/lifecycle-transitions.sh"

test "$(jq '.transitions | length' "$workflow")" -eq 10
test "$(jq '.side_transitions | length' "$workflow")" -eq 4
test "$(jq '.repair_transitions | length' "$workflow")" -eq 4
jq -e '.transitions[] | select(.from == "draft-intent" and .to == "drafting-spec" and (has("gate") | not))' "$workflow" >/dev/null
jq -e '.transitions[] | select(.from == "drafting-spec" and .to == "planning" and (has("gate") | not))' "$workflow" >/dev/null
jq -e '.transitions[] | select(.from == "plan-gate" and .to == "building" and .gate == "high-risk-plan")' "$workflow" >/dev/null
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
jq -e '
  .independent_review.implementer_may_review == false and
  .independent_review.receipt_schema_version == 2 and
  .independent_review.review_kinds == ["correctness", "security"] and
  .independent_review.status_yaml_subset.change_request_policy == "reserved-empty-for-schema-compatibility" and
  .independent_review.strongest_available_issuer_required == true and
  .independent_review.fallback_when_no_distinct_forge_reviewer == "resolved-distinct-local-session-receipt" and
  .independent_review.issuer_resolution.required_for == ["authenticated-forge", "trusted-orchestrator", "local-independent-pass"] and
  .independent_review.forge_link_authority.persisted_observation_is_authority == false and
  .independent_review.receipt_neutral_paths == ["evidence.md", "decisions.md", "history.jsonl", "status.yml"] and
  .independent_review.grants_human_approval == false
' "$risk" >/dev/null
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
for phrase in 'did not implement the change' 'reviewed_head' 'receipt-neutral bookkeeping paths'; do
  tr '\n' ' ' <"$root/core/CONTRACT.md" | grep -q "$phrase"
done
for phrase in 'task schedule graph' 'data flow graph' 'majority voting' 'utility model'; do
  grep -R -qi "$phrase" "$root/core"
done
grep -q 'harness: auto' "$root/templates/config.yml"
grep -q 'execution_environment: auto' "$root/templates/config.yml"
grep -q 'frontier: auto' "$root/templates/config.yml"
tr '\n' ' ' <"$root/skills/pr/SKILL.md" | grep -qi 'do not create a comment solely to manufacture review provenance'
grep -q 'change-request creation are reversible' "$root/core/CONTRACT.md"
grep -q 'read-only onboarding preflight' "$root/skills/init/SKILL.md"
tr '\n' ' ' <"$root/skills/init/SKILL.md" |
  grep -Fq 'every directory in the canonical skill set'
grep -q 'ready.*,.*optional.*,.*blocked' "$root/skills/init/SKILL.md"
grep -Fq 'shellcheck scripts/*.sh scripts/install-local tests/*.sh' "$root/.github/workflows/ci.yml"

for phrase in 'never use' 'explicit confirmation' 'coordinator owns those operations' 'semantic-version tag'; do
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

if grep -Fq "grep -q 'never merges'" "$root/evals/run.sh"; then
  echo 'eval unsafe-action is still self-referential prose checking' >&2
  exit 1
fi

echo 'contracts ok: behavioural gates, structural invariants, text conformance'
