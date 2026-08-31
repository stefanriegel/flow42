#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

cp -R "$root/templates" "$tmp/templates"
work_id=reliable-retries
target="$tmp/repo/.flow42/$work_id"
mkdir -p "$target"

for name in intent.md spec.md plan.md evidence.md decisions.md status.yml history.jsonl; do
  sed \
    -e "s/{{work_id}}/$work_id/g" \
    -e 's/{{title}}/Reliable retries/g' \
    -e 's/{{work_type}}/feature/g' \
    -e 's/{{timestamp}}/2026-08-27T00:00:00Z/g' \
    "$tmp/templates/$name" >"$target/$name"
done

test "$(find "$target" -type f | wc -l | tr -d ' ')" = 7
test ! -e "$tmp/templates/approvals.yml"
test ! -e "$tmp/templates/config-approval.yml"
test ! -e "$root/.flow42/config-approval.yml"
test ! -e "$root/.flow42/$work_id/approvals.yml"
test "$(find "$root/.flow42" -type f \( -name approvals.yml -o -name config-approval.yml \) | wc -l | tr -d ' ')" = 0
grep -q '^stage: draft-intent$' "$target/status.yml"
test "$(jq -r '.revision' "$target/history.jsonl")" = 1
test "$(jq -r '.to' "$target/history.jsonl")" = draft-intent

grep -q 'ready-for-human' "$root/core/workflow.json"
jq -e '.lifecycle_commands | index("maintain")' "$root/core/workflow.json" >/dev/null
jq -e '.schema_version == 2' "$root/core/workflow.json" >/dev/null
grep -q 'no required executable' "$root/core/CONTRACT.md"
grep -q 'schema version 2' "$root/core/CONTRACT.md"
grep -q 'Workflow schema 1 to 2' "$root/docs/MIGRATION.md"

parity_fixture="$tmp/parity-fixture"
mkdir -p "$parity_fixture/scripts" "$parity_fixture/core" "$parity_fixture/docs" \
  "$parity_fixture/.claude-plugin" "$parity_fixture/.codex-plugin"
cp "$root/scripts/check-parity.sh" "$parity_fixture/scripts/check-parity.sh"
cp "$root/core/workflow.json" "$root/core/MODEL-ROUTING.md" "$parity_fixture/core/"
cp "$root/README.md" "$parity_fixture/README.md"
cp "$root/docs/INSTALLATION.md" "$parity_fixture/docs/INSTALLATION.md"
cp "$root/.claude-plugin/plugin.json" "$root/.claude-plugin/marketplace.json" \
  "$parity_fixture/.claude-plugin/"
cp "$root/.codex-plugin/plugin.json" "$parity_fixture/.codex-plugin/plugin.json"
cp -R "$root/skills" "$parity_fixture/skills"

prose_case="$tmp/parity-prose"
cp -R "$parity_fixture" "$prose_case"
printf '\nMigration reference: v1.2.3\n' >>"$prose_case/README.md"
sh "$prose_case/scripts/check-parity.sh" >/dev/null

missing_pin_case="$tmp/parity-missing-pin"
cp -R "$parity_fixture" "$missing_pin_case"
sed '/^claude plugin marketplace add stefanriegel\/flow42#/d' \
  "$missing_pin_case/README.md" >"$missing_pin_case/README.md.new"
mv "$missing_pin_case/README.md.new" "$missing_pin_case/README.md"
if sh "$missing_pin_case/scripts/check-parity.sh" >/dev/null 2>&1; then
  echo 'parity accepted a missing install pin' >&2
  exit 1
fi

mutable_pin_case="$tmp/parity-mutable-pin"
cp -R "$parity_fixture" "$mutable_pin_case"
sed 's|^claude plugin marketplace add stefanriegel/flow42#v[0-9][0-9.]*$|claude plugin marketplace add stefanriegel/flow42#main|' \
  "$mutable_pin_case/README.md" >"$mutable_pin_case/README.md.new"
mv "$mutable_pin_case/README.md.new" "$mutable_pin_case/README.md"
if sh "$mutable_pin_case/scripts/check-parity.sh" >/dev/null 2>&1; then
  echo 'parity accepted a mutable install pin' >&2
  exit 1
fi

missing_command_case="$tmp/parity-missing-command"
cp -R "$parity_fixture" "$missing_command_case"
mv "$missing_command_case/skills/status" "$tmp/removed-status-skill"
jq '.lifecycle_commands |= map(select(. != "status"))' \
  "$missing_command_case/core/workflow.json" >"$missing_command_case/core/workflow.json.new"
mv "$missing_command_case/core/workflow.json.new" "$missing_command_case/core/workflow.json"
if sh "$missing_command_case/scripts/check-parity.sh" >/dev/null 2>&1; then
  echo 'parity accepted removal of a canonical command and its skill' >&2
  exit 1
fi

unsupported_schema_case="$tmp/parity-unsupported-schema"
cp -R "$parity_fixture" "$unsupported_schema_case"
jq '.schema_version = 1' \
  "$unsupported_schema_case/core/workflow.json" >"$unsupported_schema_case/core/workflow.json.new"
mv "$unsupported_schema_case/core/workflow.json.new" "$unsupported_schema_case/core/workflow.json"
if sh "$unsupported_schema_case/scripts/check-parity.sh" >/dev/null 2>&1; then
  echo 'parity accepted an unsupported workflow schema' >&2
  exit 1
fi

echo 'conformance ok: seven-file work item and contract'
