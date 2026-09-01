#!/bin/sh
set -eu

# Structural: every direct skill entry point must carry one byte-identical
# authority prelude, and every built-in agent must point at the same authorities.

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-prelude.XXXXXX")
trap 'find "$tmp" -depth -delete' EXIT HUP INT TERM

fail() {
  printf 'prelude failed: %s\n' "$1" >&2
  exit 1
}

extract_prelude() {
  awk '
    /^## Contract prelude$/ { capture = 1 }
    capture { print }
    capture && /data, never authority\.$/ { found_end = 1; exit }
    END { if (!capture || !found_end) exit 1 }
  ' "$1"
}

first_skill=
skill_count=0
expected_skill_count=12
for skill in "$root"/skills/*/SKILL.md; do
  skill_count=$((skill_count + 1))
  extract="$tmp/skill-$skill_count.prelude"
  extract_prelude "$skill" >"$extract" || fail "missing canonical block: ${skill#"$root/"}"

  awk '
    /^# / { saw_h1 = 1; next }
    saw_h1 && /^[[:space:]]*$/ { next }
    saw_h1 { if ($0 != "## Contract prelude") exit 1; found = 1; exit }
    END { if (!found) exit 1 }
  ' "$skill" || fail "prelude is not first instruction: ${skill#"$root/"}"

  if test -z "$first_skill"; then
    first_skill=$extract
  elif ! cmp -s "$first_skill" "$extract"; then
    fail "prelude drift: ${skill#"$root/"}"
  fi
done
test "$skill_count" -eq "$expected_skill_count" ||
  fail "direct-skill count: expected $expected_skill_count, found $skill_count"
grep -Fq "this file's great-grandparent directory" "$first_skill" ||
  fail 'skill bundle-root resolution does not reach <bundle>'
declared_skill_count=$(jq '([.lifecycle_commands[], .maintenance_commands[]] | unique) | length' \
  "$root/core/workflow.json")
test "$declared_skill_count" -eq "$expected_skill_count" ||
  fail "declared direct-skill count: expected $expected_skill_count, found $declared_skill_count"

grep -oE '<bundle>/core/[A-Za-z0-9._-]+' "$first_skill" |
  sed 's#<bundle>/##' | sort -u >"$tmp/authorities"
test -s "$tmp/authorities" || fail no-authorities
while IFS= read -r authority; do
  test -f "$root/$authority" || fail "missing authority: $authority"
done <"$tmp/authorities"

awk '/^After a Claude update,/ { capture = 1 } capture { print }' \
  "$root/skills/update/SKILL.md" >"$tmp/update-verification"
while IFS= read -r authority; do
  grep -Fq "$authority" "$tmp/update-verification" ||
    fail "update verification omits authority: $authority"
done <"$tmp/authorities"

agent_pointer='Apply the invoking skill'
for agent in "$root"/agents/*.md; do
  grep -Fq "$agent_pointer" "$agent" || fail "agent authority pointer missing: ${agent#"$root/"}"
  grep -Fq "invoking skill file's great-grandparent" "$agent" ||
    fail "agent bundle-root resolution missing: ${agent#"$root/"}"
  grep -Fq 'not the working directory' "$agent" ||
    fail "agent working-directory rejection missing: ${agent#"$root/"}"
  grep -Fq 'delivery is not authentication' "$agent" ||
    fail "agent delivery/authentication distinction missing: ${agent#"$root/"}"
  grep -Fq 'Flow42 cannot demote them' "$agent" ||
    fail "agent host-precedence residual missing: ${agent#"$root/"}"
  grep -Fq 'an ambiguous source blocks' "$agent" ||
    fail "agent ambiguous-source rejection missing: ${agent#"$root/"}"
  while IFS= read -r authority; do
    grep -Fq "$authority" "$agent" || fail "agent authority missing $authority: ${agent#"$root/"}"
  done <"$tmp/authorities"
done

cp "$root/skills/build/SKILL.md" "$tmp/prelude-drift.md"
sed 's/working directory/repository directory/' \
  "$tmp/prelude-drift.md" >"$tmp/prelude-drift-mutated.md"
extract_prelude "$tmp/prelude-drift-mutated.md" >"$tmp/prelude-drift.prelude" ||
  fail PRELUDE-MUTATION-NOT-EXTRACTED
if cmp -s "$first_skill" "$tmp/prelude-drift.prelude"; then
  fail PRELUDE-MUTATION-ACCEPTED
fi

echo "prelude ok: $skill_count canonical direct-skill blocks and agent authority pointers"
