#!/bin/sh
# shellcheck disable=SC1091,SC2034,SC2154
set -eu
. "$(dirname -- "$0")/lib.sh"
TEST_NAME=structure
p="$root/skills/flow42/core/policy.json"

jq -e '.schema_version == 3' "$p" >/dev/null || fail "policy schema_version must be 3"
jq -e '.flow42_version | test("^[0-9]+\\.[0-9]+\\.[0-9]+$")' "$p" >/dev/null || fail "flow42_version not semver"

s="$root/skills/flow42/SKILL.md"
test -f "$s" || fail "router SKILL.md missing"
test "$(sed -n 1p "$s")" = '---' || fail "router frontmatter missing"
grep -q '^description:' "$s" || fail "router description missing"

for f in init explore intent spec plan build verify pr maintain status resume update; do
  test -f "$root/skills/flow42/stages/$f.md" || fail "stage file missing: $f.md"
done
for t in intent.md spec.md plan.md evidence.md decisions.md status.yml history.jsonl config.yml signals.md options.md; do
  test -f "$root/skills/flow42/templates/$t" || fail "template missing: $t"
done
# every stage file must carry the prelude pointer (structure, not sentence-pinning: just the two authority paths)
for f in "$root"/skills/flow42/stages/*.md; do
  grep -q 'core/CONTRACT.md' "$f" || fail "missing CONTRACT authority pointer: ${f##*/}"
  grep -q 'core/policy.json' "$f" || fail "missing policy authority pointer: ${f##*/}"
done
! grep -rn '\[TODO:' "$root/skills" || fail "placeholder found"
# deleted concepts must not survive in the shipped skill
! grep -rniE 'issuer_kind|resolver|marker-pair|scope_digest|diff_digest|change_request|intent-gate' "$root/skills" || fail "retired concept survives in skills/"

# the evidence template carries the canonical review-stamp format
grep -q 'review stamp:' "$root/skills/flow42/templates/evidence.md" || fail "review stamp format missing from evidence template"

# worktree_parent pattern must reject dot-only (traversal) segments
pat=$(jq -r '.config_schema.fields.worktree_parent.pattern' "$p")
for bad in '..' '../outside' 'a/../b' '.'; do
  printf '%s' "$bad" | jq -R --arg re "$pat" 'test($re)' | grep -qx false || fail "worktree_parent pattern accepts traversal: $bad"
done

# validate the repo's own .flow42/config.yml against policy
c="$root/.flow42/config.yml"
if test -f "$c"; then
  grep -q '^schema_version: 3$' "$c" || fail "config schema_version must be 3"
  for key in $(jq -r '.config_schema.fields | to_entries[] | select(.value.required == true) | .key' "$p"); do
    grep -q "^$key:" "$c" || fail "config missing required field: $key"
  done
  for g in $(jq -r '.config_schema.fields.mandatory_gates.must_include_all[]' "$p"); do
    grep -qE "^[[:space:]]*-[[:space:]]$g\$" "$c" || fail "config missing mandatory gate: $g"
  done
  for key in format lint typecheck test build; do
    toks=$(sed -n "s/^  $key: \[\(.*\)\]\$/\1/p" "$c" | tr -d ' ')
    test -n "$toks" || continue
    first=${toks%%,*}
    case "$first" in
      sh|bash|dash|zsh|env|eval|command|xargs|nohup|timeout|git|gh|glab|terraform|kubectl|helm)
        fail "config commands.$key first token violates command_policy_rules: $first";;
    esac
    case "$toks" in
      *'$'*|*'`'*|*';'*|*'|'*|*'&'*|*'<'*|*'>'*|*'('*|*')'*)
        fail "config commands.$key contains shell metacharacters";;
    esac
  done
fi
echo "structure ok"
