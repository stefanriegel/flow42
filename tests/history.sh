#!/bin/sh
# shellcheck disable=SC1091,SC2034,SC2154
set -eu
. "$(dirname -- "$0")/lib.sh"
TEST_NAME=history
p="$root/skills/flow42/core/policy.json"
ex="$root/tests/legacy-exemptions.txt"

# legal (from,to) pairs with pseudo-states expanded; entry uses literal "null"
pairs=$(jq -r '
  .workflow as $w
  | ($w.stages + $w.side_states) as $all
  | ($all - $w.final_states) as $nonfinal
  | def expand(f): if f == "any-non-final" then $nonfinal
      elif f == "any-unblocked-non-final" then ($nonfinal - ["blocked"])
      elif f == "recorded-resume-stage" then ($w.stages - $w.final_states)
      elif f == null then ["null"] else [f] end;
  [ ($w.transitions + $w.side_transitions + $w.repair_transitions)[]
    | expand(.from)[] as $f | expand(.to)[] as $t | "\($f)>\($t)" ]
  | unique | .[]' "$p")

for dir in "$root"/.flow42/*/; do
  id=${dir%/}; id=${id##*/}
  h="$dir/history.jsonl"; s="$dir/status.yml"
  test -f "$h" || continue
  jq -e . "$h" >/dev/null 2>&1 || jq -es . "$h" >/dev/null || fail "$id: invalid history JSON"
  if test -f "$ex" && grep -qx "$id" "$ex"; then continue; fi
  n=0
  while IFS= read -r line; do
    n=$((n + 1))
    rev=$(printf '%s' "$line" | jq -r '.revision'); f=$(printf '%s' "$line" | jq -r '.from'); t=$(printf '%s' "$line" | jq -r '.to')
    test "$rev" = "$n" || fail "$id: revision $rev at position $n not contiguous"
    printf '%s\n' "$pairs" | grep -qx "$f>$t" || fail "$id: illegal transition $f -> $t (rev $rev)"
  done < "$h"
  last_to=$(tail -1 "$h" | jq -r '.to')
  st=$(sed -n 's/^stage:[[:space:]]*//p' "$s" | tr -d '"')
  sr=$(sed -n 's/^state_revision:[[:space:]]*//p' "$s")
  test "$st" = "$last_to" || fail "$id: status stage $st != last history to $last_to"
  test "$sr" = "$n" || fail "$id: state_revision $sr != history length $n"
done
echo "history ok"
