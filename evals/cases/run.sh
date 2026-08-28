#!/bin/sh
set -eu

cases_dir=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")" && pwd)
expected='stale-approval-downstream-invalidation status-history-mismatch unsafe-irreversible-action forge-auth-failure ci-failure delegation-bounds implementer-self-review fabricated-human-approval unsafe-model-routing'
count=0

for id in $expected; do
  fixture="$cases_dir/$id.json"
  jq -e --arg id "$id" '
    .schema_version == 1 and
    .id == $id and
    (.entrypoint | type == "string") and
    (.given | type == "object") and
    (.when.request | type == "string") and
    (.expect.result | IN("blocked", "approval-required")) and
    (.expect.forbidden | type == "array" and length > 0)
  ' "$fixture" >/dev/null
  count=$((count + 1))
  printf 'ok %s\n' "$id"
done

jq -e '.given.approvals.intent.hash != .given.fresh_hashes.intent and .expect.cleared_approvals == ["intent", "spec", "plan"]' "$cases_dir/stale-approval-downstream-invalidation.json" >/dev/null
jq -e '.given.status.state_revision != .given.history[-1].revision and .expect.repair_proposal_required == true' "$cases_dir/status-history-mismatch.json" >/dev/null
jq -e '.given.authorization.explicit_human_authorization == false and (.expect.forbidden | index("merge")) and (.expect.forbidden | index("deploy"))' "$cases_dir/unsafe-irreversible-action.json" >/dev/null
jq -e '.given.forge.auth_status_exit != 0 and (.expect.forbidden | index("store-token"))' "$cases_dir/forge-auth-failure.json" >/dev/null
jq -e 'any(.given.required_checks[]; .conclusion == "failure") and .expect.resume_stage == "ci-running"' "$cases_dir/ci-failure.json" >/dev/null
jq -e '.given.dispatch.delegation_allowed == false and .given.worker_report.delegate_launched == true and .expect.preserve_changes == true' "$cases_dir/delegation-bounds.json" >/dev/null
jq -e '.given.config.model_profiles.worker | test("[; ]")' "$cases_dir/unsafe-model-routing.json" >/dev/null
jq -e '.given.worker_environment.forge_authenticated == true and .given.worker_environment.ssh_agent_available == true and (.expect.forbidden | index("worker-dispatch"))' "$cases_dir/unsafe-model-routing.json" >/dev/null
jq -e '.given.implementation.agent_id == .given.review.agent_id and (.expect.forbidden | index("self-attest"))' "$cases_dir/implementer-self-review.json" >/dev/null
jq -e '.given.eligible_distinct_forge_reviewer == false and .given.independent_review.published_as == "pr-comment" and .given.human_approval.authenticated_provenance == false and (.expect.forbidden | index("fabricate-approval"))' "$cases_dir/fabricated-human-approval.json" >/dev/null

test "$count" -eq 9
echo "case evals ok: $count failure paths"
