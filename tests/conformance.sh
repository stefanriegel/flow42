#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

cp -R "$root/templates" "$tmp/templates"
work_id=reliable-retries
target="$tmp/repo/.flow42/$work_id"
mkdir -p "$target"

for name in intent.md spec.md plan.md evidence.md decisions.md status.yml approvals.yml history.jsonl; do
  sed \
    -e "s/{{work_id}}/$work_id/g" \
    -e 's/{{title}}/Reliable retries/g' \
    -e 's/{{work_type}}/feature/g' \
    -e 's/{{timestamp}}/2026-08-27T00:00:00Z/g' \
    "$tmp/templates/$name" >"$target/$name"
done

test "$(find "$target" -type f | wc -l | tr -d ' ')" = 8
grep -q '^stage: draft-intent$' "$target/status.yml"
test "$(jq -r '.revision' "$target/history.jsonl")" = 1
test "$(jq -r '.to' "$target/history.jsonl")" = draft-intent

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

approved=$(hash_file "$target/intent.md")
current=$(hash_file "$target/intent.md")
test "$approved" = "$current"
printf '\nchanged after approval\n' >>"$target/intent.md"
current=$(hash_file "$target/intent.md")
test "$approved" != "$current"

grep -q 'stale approval must block' "$root/core/CONTRACT.md"
grep -q 'ready-for-human' "$root/core/workflow.json"
grep -q 'No Flow42 executable' "$root/README.md"

echo 'conformance ok: creation, hashing, stale approval, contract'
