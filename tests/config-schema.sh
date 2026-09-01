#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
schema="$root/core/config-schema.json"
fixtures="$root/tests/fixtures/config"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-config.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM

test -f "$schema" || { echo CONFIG-SCHEMA-MISSING >&2; exit 1; }
jq -e '.schema_version == 1 and .unknown_fields == "block" and .extra_gates == "allowed" and .command_paths == "must-exist-or-be-auto"' "$schema" >/dev/null

scalar() { awk -v key="$2" '$0 ~ "^" key ":[[:space:]]*" {sub("^[^:]*:[[:space:]]*", ""); print; exit}' "$1"; }
top_keys() { awk '/^[A-Za-z_][A-Za-z0-9_]*:/ {sub(/:.*/, ""); print}' "$1"; }
section_pairs() { awk -v section="$2" '$0 == section ":" {inside=1; next} inside && /^[^ ]/ {exit} inside && /^  [A-Za-z_][A-Za-z0-9_]*:/ {sub(/^  /, ""); key=$0; sub(/:.*/, "", key); sub(/^[^:]*:[[:space:]]*/, ""); print key "\t" $0}' "$1"; }
list_values() { awk -v section="$2" '$0 == section ":" {inside=1; next} inside && /^[^ ]/ {exit} inside && /^  - / {sub(/^  - /, ""); print}' "$1"; }
fail() { echo "$1" >&2; return 1; }

validate_config() {
  file=$1
  version=$(scalar "$file" schema_version)
  test "$version" = "$(jq -r '.schema_version' "$schema")" || { fail CONFIG-SCHEMA-VERSION; return; }

  for key in $(top_keys "$file"); do
    jq -e --arg key "$key" '.fields | has($key)' "$schema" >/dev/null || { fail CONFIG-UNKNOWN-FIELD; return; }
  done
  for key in $(jq -r '.fields | to_entries[] | select(.value.required) | .key' "$schema"); do
    top_keys "$file" | grep -Fxq "$key" || { fail CONFIG-MISSING-FIELD; return; }
  done

  for key in forge harness execution_environment; do
    value=$(scalar "$file" "$key")
    jq -e --arg key "$key" --arg value "$value" '.fields[$key].enum | index($value)' "$schema" >/dev/null || { fail CONFIG-ENUM; return; }
  done
  concurrency=$(scalar "$file" concurrency)
  case "$concurrency" in *[!0-9]*|'') fail CONFIG-CONCURRENCY; return ;; esac
  min=$(jq -r '.fields.concurrency.minimum' "$schema"); max=$(jq -r '.fields.concurrency.maximum' "$schema")
  test "$concurrency" -ge "$min" && test "$concurrency" -le "$max" || { fail CONFIG-CONCURRENCY; return; }

  base_branch=$(scalar "$file" base_branch)
  base_pattern=$(jq -r '.fields.base_branch.pattern' "$schema")
  printf '%s\n' "$base_branch" | grep -Eq "$base_pattern" || { fail CONFIG-BASE-BRANCH; return; }
  worktree_parent=$(scalar "$file" worktree_parent)
  worktree_pattern=$(jq -r '.fields.worktree_parent.pattern' "$schema")
  printf '%s\n' "$worktree_parent" | grep -Eq "$worktree_pattern" || { fail CONFIG-WORKTREE-PARENT; return; }

  for section in model_profiles commands; do
    expected_keys=$(jq -r --arg section "$section" '.fields[$section].properties | keys[]' "$schema")
    actual=$(section_pairs "$file" "$section" | cut -f1)
    for key in $actual; do printf '%s\n' "$expected_keys" | grep -Fxq "$key" || { fail CONFIG-UNKNOWN-FIELD; return; }; done
    for key in $expected_keys; do printf '%s\n' "$actual" | grep -Fxq "$key" || { fail CONFIG-MISSING-FIELD; return; }; done
  done

  pattern=$(jq -r '.fields.model_profiles.properties.frontier.pattern' "$schema")
  section_pairs "$file" model_profiles | while IFS="$(printf '\t')" read -r key value; do
    test "$value" = auto || printf '%s\n' "$value" | grep -Eq "$pattern" || exit 7
  done || { fail CONFIG-MODEL-ID; return; }

  section_pairs "$file" commands | while IFS="$(printf '\t')" read -r key value; do
    printf '%s\n' "$value" | grep -Eq '^\[[^]]*\]$' || exit 8
  done || { fail CONFIG-COMMAND-ARRAY; return; }

  section_pairs "$file" commands | cut -f2- | tr -d '[]' | tr ',' '\n' | while IFS= read -r token; do
    token=$(printf '%s' "$token" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    case "$token" in ''|auto|-*) continue ;; */*) test -e "$root/$token" || exit 9 ;; esac
  done || { fail CONFIG-COMMAND-PATH; return; }

  path_pattern=$(jq -r '.fields.protected_paths.item_pattern' "$schema")
  for protected_path in $(list_values "$file" protected_paths); do
    printf '%s\n' "$protected_path" | grep -Eq "$path_pattern" || { fail CONFIG-PROTECTED-PATH; return; }
    case "$protected_path" in /* | ../* | */../* | */..) fail CONFIG-PROTECTED-PATH; return ;; esac
  done

  retired=$(jq -r '.retired_gates.names[]' "$schema")
  gate_pattern=$(jq -r '.fields.mandatory_gates.item_pattern' "$schema")
  for gate in $(list_values "$file" mandatory_gates); do
    printf '%s\n' "$gate" | grep -Eq "$gate_pattern" || { fail CONFIG-GATE-GRAMMAR; return; }
    if printf '%s\n' "$retired" | grep -Fxq "$gate"; then fail CONFIG-RETIRED-GATE; return; fi
  done
  for gate in $(jq -r '.canonical_mandatory_gates[]' "$schema"); do
    list_values "$file" mandatory_gates | grep -Fxq "$gate" || { fail CONFIG-MISSING-GATE; return; }
  done
}

validate_config "$root/templates/config.yml"
validate_config "$root/.flow42/config.yml"
validate_config "$fixtures/valid.yml"
validate_config "$fixtures/extra-custom-gate.yml"

for fixture in retired-gate missing-canonical-gate unknown-field scalar-command bad-model-id \
  bad-base-branch unsafe-protected-path missing-command-path unknown-schema-version; do
  case "$fixture" in
    retired-gate) expected=CONFIG-RETIRED-GATE ;;
    missing-canonical-gate) expected=CONFIG-MISSING-GATE ;;
    unknown-field) expected=CONFIG-UNKNOWN-FIELD ;;
    scalar-command) expected=CONFIG-COMMAND-ARRAY ;;
    bad-model-id) expected=CONFIG-MODEL-ID ;;
    bad-base-branch) expected=CONFIG-BASE-BRANCH ;;
    unsafe-protected-path) expected=CONFIG-PROTECTED-PATH ;;
    missing-command-path) expected=CONFIG-COMMAND-PATH ;;
    unknown-schema-version) expected=CONFIG-SCHEMA-VERSION ;;
  esac
  log="$tmp/$fixture.log"
  if validate_config "$fixtures/$fixture.yml" >"$log" 2>&1; then echo "config mutation survived: $fixture" >&2; exit 1; fi
  test "$(grep -c '^CONFIG-' "$log")" -eq 1
  grep -Fxq "$expected" "$log"
done

schema_fields=$(jq -r '.fields | to_entries[] | if (.value.type == "object") then .key as $p | .value.properties | keys[] | $p + "." + . else .key end' "$schema" | sort)
doc_fields=$(awk -F'`' '/^\| `/ {print $2}' "$root/docs/CONFIGURATION.md" | sort)
test "$schema_fields" = "$doc_fields" || { echo CONFIG-DOC-DRIFT >&2; exit 1; }
grep -q '^## Configuration: removed approval gates$' "$root/docs/MIGRATION.md"

echo 'config schema ok: authority, strict fixtures, additive gates, command paths, documentation drift'
