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
  jq -e '.pseudo_states["any-non-final"].expands_to == "stages+side_states minus final_states" and .dynamic_targets["recorded-resume-stage"].source == "status.resume_stage" and .dynamic_targets["recorded-resume-stage"].must_be_in == "stages"' "$file" >/dev/null || { fail LIFECYCLE-DECLARATION; return; }

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
  jq -e 'all(.repair_transitions[]; (.gate | ascii_downcase | contains("human")) == false)' "$file" >/dev/null || { fail LIFECYCLE-REPAIR-HUMAN; return; }
  jq -e '.mandatory_gates == ["high-risk-plan","irreversible-action","merge","deploy"]' "$file" >/dev/null || { fail LIFECYCLE-MANDATORY-GATES; return; }
  jq -e '
    (.repair_transitions | length == 4) and
    any(.repair_transitions[]; .from == "verifying" and .to == "building" and .gate == "recorded-blocking-finding") and
    any(.repair_transitions[]; .from == "ci-running" and .to == "building" and .gate == "recorded-failing-check") and
    any(.repair_transitions[]; .from == "ready-for-human" and .to == "building" and .gate == "recorded-change-request") and
    any(.repair_transitions[]; .from == "any-non-final" and .to == "blocked" and .gate == "state-inconsistency-recorded-with-repair-proposal")' "$file" >/dev/null || { fail LIFECYCLE-REPAIR-EDGES; return; }
  jq -e --slurpfile mismatch "$root/evals/cases/status-history-mismatch.json" --slurpfile ci "$root/evals/cases/ci-failure.json" '
    ($mismatch[0].expect.result == "blocked" and $mismatch[0].expect.repair_proposal_required == true and
      any(.repair_transitions[]; .from == "any-non-final" and .to == "blocked" and .gate == "state-inconsistency-recorded-with-repair-proposal")) and
    ($ci[0].expect.result == "blocked" and $ci[0].expect.resume_stage == "ci-running" and
      any(.side_transitions[]; .from == "any-non-final" and .to == "blocked"))' "$file" >/dev/null || { fail LIFECYCLE-SIMULATION; return; }
}

validate_workflow "$workflow"
for mutation in add-human-gate-to-repair undeclared-target repair-from-final disconnect-pr-ready; do
  jq -f "$fixtures/$mutation.jq" "$workflow" >"$tmp/$mutation.json"
  case "$mutation" in
    add-human-gate-to-repair) expected=LIFECYCLE-REPAIR-HUMAN ;;
    undeclared-target) expected=LIFECYCLE-UNDECLARED-NODE ;;
    repair-from-final) expected=LIFECYCLE-FINAL-OUTGOING ;;
    disconnect-pr-ready) expected=LIFECYCLE-FORWARD-REACHABILITY ;;
  esac
  log="$tmp/$mutation.log"
  if validate_workflow "$tmp/$mutation.json" >"$log" 2>&1; then echo "lifecycle mutation survived: $mutation" >&2; exit 1; fi
  test "$(grep -c '^LIFECYCLE-' "$log")" -eq 1
  grep -Fxq "$expected" "$log"
done

echo 'lifecycle transitions ok: closed grammar, declared indirection, repair loops, unchanged gates, simulations'
