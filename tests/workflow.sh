#!/bin/sh
# shellcheck disable=SC1091,SC2034,SC2154
set -eu
. "$(dirname -- "$0")/lib.sh"
TEST_NAME=workflow
p="$root/skills/flow42/core/policy.json"
w() { jq -r "$1" "$p"; }

# every transition endpoint is a declared state, pseudo-state, dynamic target, or null
jq -e '
  .workflow as $w
  | ($w.stages + $w.side_states) as $states
  | ($w.pseudo_states | keys) as $pseudo
  | ($w.dynamic_targets | keys) as $dyn
  | [ ($w.transitions + $w.side_transitions + $w.repair_transitions)[]
      | [.from, .to][]
      | select(. != null)
      | select( ( [.] | inside($states + $pseudo + $dyn) ) | not ) ]
  | length == 0' "$p" >/dev/null || fail "undeclared transition endpoint"

# final states have no outgoing edges
jq -e '
  .workflow as $w
  | [ ($w.transitions + $w.side_transitions + $w.repair_transitions)[]
      | select(.from != null) | select([.from] | inside($w.final_states)) ]
  | length == 0' "$p" >/dev/null || fail "final state has outgoing transition"

# entry transition and forge-none completion exist
jq -e '.workflow.transitions | any(.from == null and .to == "draft-intent")' "$p" >/dev/null || fail "entry transition missing"
jq -e '.workflow.transitions | any(.from == "verifying" and .to == "complete" and .when == "forge-none")' "$p" >/dev/null || fail "local completion missing"

# blocked is entered only from any-unblocked-non-final
jq -e '
  [ (.workflow.side_transitions + .workflow.repair_transitions)[]
    | select(.to == "blocked") | select(.from != "any-unblocked-non-final") ]
  | length == 0' "$p" >/dev/null || fail "blocked entered from wrong source"

test "$(w '.workflow.automatic_review_limit')" = "2" || fail "review limit changed silently"
echo "workflow ok"
