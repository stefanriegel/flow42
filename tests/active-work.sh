#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target="$root/.flow42/issue-1"

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

for artifact in intent spec plan; do
  expected=$(sed -n "s/^${artifact}_hash: \"\(.*\)\"$/\1/p" "$target/approvals.yml")
  test -n "$expected"
  test "$expected" = "$(hash_file "$target/$artifact.md")"
done

status_revision=$(sed -n 's/^state_revision: //p' "$target/status.yml")
history_revision=$(tail -n 1 "$target/history.jsonl" | jq -r '.revision')
history_stage=$(tail -n 1 "$target/history.jsonl" | jq -r '.to')
status_stage=$(sed -n 's/^stage: //p' "$target/status.yml")

test "$status_revision" = "$history_revision"
test "$status_stage" = "$history_stage"
test "$status_stage" = building

echo 'active work ok: approvals, revision, stage'
