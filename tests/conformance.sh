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
grep -q '^stage: draft-intent$' "$target/status.yml"
test "$(jq -r '.revision' "$target/history.jsonl")" = 1
test "$(jq -r '.to' "$target/history.jsonl")" = draft-intent

grep -q 'ready-for-human' "$root/core/workflow.json"
grep -q 'no required executable' "$root/core/CONTRACT.md"

echo 'conformance ok: seven-file work item and contract'
