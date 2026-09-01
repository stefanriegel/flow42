#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
workflow="$root/core/workflow.json"
fixtures="$root/tests/fixtures/lifecycle"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-lifecycle.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM

fail() { echo "$1" >&2; return 1; }
validate_workflow() {
  file=$1
  jq -e '.schema_version == 2' "$file" >/dev/null || { fail LIFECYCLE-SCHEMA; return; }
  jq -e '
    (.stages + .side_states + ((.pseudo_states // {}) | keys) + ((.dynamic_targets // {}) | keys)) as $nodes |
    all(((.transitions // []) + (.side_transitions // []) + (.repair_transitions // []))[];
      (.from as $v | ($nodes | index($v)) != null) and (.to as $v | ($nodes | index($v)) != null))' "$file" >/dev/null || { fail LIFECYCLE-UNDECLARED-NODE; return; }
  jq -e '
    .pseudo_states["any-non-final"].include_sets == ["stages", "side_states"] and
    .pseudo_states["any-non-final"].exclude_sets == ["final_states"] and
    .pseudo_states["any-non-final"].exclude_states == ["blocked"] and
    .state_sets.resumable_stages.include_sets == ["stages"] and
    .state_sets.resumable_stages.exclude_sets == ["final_states"] and
    .dynamic_targets["recorded-resume-stage"].source == "status.resume_stage" and
    .dynamic_targets["recorded-resume-stage"].must_be_in == "resumable_stages" and
    .dynamic_targets["recorded-resume-stage"].must_equal == "history.latest-transition-to-blocked.from"' "$file" >/dev/null || { fail LIFECYCLE-DECLARATION; return; }

  jq -e 'any(.side_transitions[]; .from == "blocked" and .to == "recorded-resume-stage" and .gate == "blockers-cleared-and-state-valid-and-resume-bound") and
    (all(.side_transitions[]; (.from == "blocked" and .to == "blocked") == false))' "$file" >/dev/null || { fail LIFECYCLE-RESUME-EDGE; return; }

  stages=$(jq -r '.stages[]' "$file")
  reachable=' draft-intent '
  changed=true
  while test "$changed" = true; do
    changed=false
    for from_stage in $stages; do
      case "$reachable" in *" $from_stage "*) ;; *) continue ;; esac
      for to_stage in $(jq -r --arg from "$from_stage" '.transitions[] | select(.from == $from) | .to' "$file"); do
        case "$reachable" in
          *" $to_stage "*) ;;
          *) reachable="$reachable$to_stage "; changed=true ;;
        esac
      done
    done
  done
  for stage in $stages; do
    case "$reachable" in *" $stage "*) ;; *) fail LIFECYCLE-FORWARD-REACHABILITY; return ;; esac
  done

  can_reach_endpoint=' ready-for-human '
  changed=true
  while test "$changed" = true; do
    changed=false
    for to_stage in $stages; do
      case "$can_reach_endpoint" in *" $to_stage "*) ;; *) continue ;; esac
      for from_stage in $(jq -r --arg to "$to_stage" '.transitions[] | select(.to == $to) | .from' "$file"); do
        case "$can_reach_endpoint" in
          *" $from_stage "*) ;;
          *) can_reach_endpoint="$can_reach_endpoint$from_stage "; changed=true ;;
        esac
      done
    done
  done
  for stage in $stages; do
    test "$stage" = complete && continue
    case "$can_reach_endpoint" in *" $stage "*) ;; *) fail LIFECYCLE-FORWARD-REACHABILITY; return ;; esac
  done

  jq -e '(.final_states) as $final | all(((.transitions // []) + (.side_transitions // []) + (.repair_transitions // []))[]; (.from as $v | ($final | index($v))) == null)' "$file" >/dev/null || { fail LIFECYCLE-FINAL-OUTGOING; return; }
  jq -e 'all(.repair_transitions[]; (.gate | type == "string" and length > 0))' "$file" >/dev/null || { fail LIFECYCLE-REPAIR-GATE-MISSING; return; }
  jq -e 'all(.repair_transitions[]; (.gate | ascii_downcase | contains("human")) == false)' "$file" >/dev/null || { fail LIFECYCLE-REPAIR-HUMAN; return; }
  jq -e '.mandatory_gates == ["high-risk-plan","irreversible-action","merge","deploy"]' "$file" >/dev/null || { fail LIFECYCLE-MANDATORY-GATES; return; }
  jq -e '
    (.repair_transitions | length == 4) and
    any(.repair_transitions[]; .from == "verifying" and .to == "building" and .gate == "recorded-blocking-finding") and
    any(.repair_transitions[]; .from == "ci-running" and .to == "building" and .gate == "recorded-failing-check") and
    any(.repair_transitions[]; .from == "ready-for-human" and .to == "building" and .gate == "recorded-change-request") and
    any(.repair_transitions[]; .from == "any-non-final" and .to == "blocked" and .gate == "state-inconsistency-recorded-with-repair-proposal")' "$file" >/dev/null || { fail LIFECYCLE-REPAIR-EDGES; return; }
  jq -e '.automatic_review_limit == 2 and
    any(.repair_transitions[];
      .from == "verifying" and .to == "building" and
      .counter.field == "status.review_loops" and .counter.increment == 1 and
      .counter.maximum_from == "automatic_review_limit" and
      .counter.on_exhausted.to == "blocked" and
      .counter.on_exhausted.gate == "automatic-review-limit-reached" and
      .counter.on_exhausted.effect == "escalate")' "$file" >/dev/null || { fail LIFECYCLE-REVIEW-LIMIT; return; }
  jq -e --slurpfile mismatch "$root/evals/cases/status-history-mismatch.json" --slurpfile ci "$root/evals/cases/ci-failure.json" '
    ($mismatch[0].expect.result == "blocked" and $mismatch[0].expect.repair_proposal_required == true and
      any(.repair_transitions[]; .from == "any-non-final" and .to == "blocked" and .gate == "state-inconsistency-recorded-with-repair-proposal")) and
    ($ci[0].expect.result == "blocked" and $ci[0].expect.resume_stage == "ci-running" and
      any(.side_transitions[]; .from == "any-non-final" and .to == "blocked"))' "$file" >/dev/null || { fail LIFECYCLE-SIMULATION; return; }
}

validate_resume_fixture() {
  fixture=$1
  resume_stage=$(jq -r '.status.resume_stage' "$fixture")
  if ! jq -e --arg stage "$resume_stage" '
    (.stages - .final_states) | index($stage) != null' "$workflow" >/dev/null; then
    fail LIFECYCLE-RESUME-FINAL
    return
  fi
  jq -e '.status.stage == "blocked" and .history[-1].to == "blocked" and
    .status.resume_stage == .history[-1].from and
    .status.state_revision == .history[-1].revision' "$fixture" >/dev/null || {
    fail LIFECYCLE-RESUME-BINDING
    return
  }
}

simulate_review_repairs() {
  count=0
  limit=$(jq -r '.automatic_review_limit' "$workflow")
  for expected in building building blocked; do
    if test "$count" -lt "$limit"; then
      actual=building
      count=$((count + 1))
    else
      actual=blocked
    fi
    test "$actual" = "$expected" || { fail LIFECYCLE-REVIEW-LIMIT; return; }
  done
}

validate_workflow "$workflow"
validate_resume_fixture "$fixtures/resume-valid.json"
for fixture in resume-final resume-mismatched-history; do
  case "$fixture" in
    resume-final) expected=LIFECYCLE-RESUME-FINAL ;;
    resume-mismatched-history) expected=LIFECYCLE-RESUME-BINDING ;;
  esac
  log="$tmp/$fixture.log"
  if validate_resume_fixture "$fixtures/$fixture.json" >"$log" 2>&1; then echo "resume mutation survived: $fixture" >&2; exit 1; fi
  test "$(grep -c '^LIFECYCLE-' "$log")" -eq 1
  grep -Fxq "$expected" "$log"
done
simulate_review_repairs

for mutation in add-human-gate-to-repair undeclared-target repair-from-final disconnect-pr-ready \
  resume-target-complete missing-repair-gate remove-review-loop-limit; do
  jq -f "$fixtures/$mutation.jq" "$workflow" >"$tmp/$mutation.json"
  case "$mutation" in
    add-human-gate-to-repair) expected=LIFECYCLE-REPAIR-HUMAN ;;
    undeclared-target) expected=LIFECYCLE-UNDECLARED-NODE ;;
    repair-from-final) expected=LIFECYCLE-FINAL-OUTGOING ;;
    disconnect-pr-ready) expected=LIFECYCLE-FORWARD-REACHABILITY ;;
    resume-target-complete) expected=LIFECYCLE-RESUME-EDGE ;;
    missing-repair-gate) expected=LIFECYCLE-REPAIR-GATE-MISSING ;;
    remove-review-loop-limit) expected=LIFECYCLE-REVIEW-LIMIT ;;
  esac
  log="$tmp/$mutation.log"
  if validate_workflow "$tmp/$mutation.json" >"$log" 2>&1; then echo "lifecycle mutation survived: $mutation" >&2; exit 1; fi
  test "$(grep -c '^LIFECYCLE-' "$log")" -eq 1
  grep -Fxq "$expected" "$log"
done

echo 'lifecycle transitions ok: closed grammar, bound non-final resume, capped review loops, deterministic repair diagnostics'
