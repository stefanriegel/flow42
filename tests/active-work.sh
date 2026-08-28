#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
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
  test -n "$(sed -n "s/^${artifact}_provenance_kind: \"\(.*\)\"$/\1/p" "$target/approvals.yml")"
  test -n "$(sed -n "s/^${artifact}_provenance_ref: \"\(.*\)\"$/\1/p" "$target/approvals.yml")"
done

config_expected=$(sed -n 's/^config_hash: "\(.*\)"$/\1/p' "$target/approvals.yml")
test "$config_expected" = "$(hash_file "$root/.flow42/config.yml")"

status_revision=$(sed -n 's/^state_revision: //p' "$target/status.yml")
history_revision=$(tail -n 1 "$target/history.jsonl" | jq -r '.revision')
history_stage=$(tail -n 1 "$target/history.jsonl" | jq -r '.to')
status_stage=$(sed -n 's/^stage: //p' "$target/status.yml")

test "$status_revision" = "$history_revision"
test "$status_stage" = "$history_stage"
test "$status_stage" = blocked

blockers=$(sed -n 's/^blockers: \(.*\)$/\1/p' "$target/status.yml")
resume_stage=$(sed -n 's/^resume_stage: \(.*\)$/\1/p' "$target/status.yml")
test "$blockers" != '[]'
test "$resume_stage" = verifying

valid_blocker_state() {
  candidate_stage=$1
  candidate_blockers=$2
  candidate_resume=$3
  if test "$candidate_blockers" != '[]'; then
    test "$candidate_stage" = blocked
    test -n "$candidate_resume"
  fi
}

valid_blocker_state "$status_stage" "$blockers" "$resume_stage"
for ordinary_stage in building verifying pr-ready; do
  if valid_blocker_state "$ordinary_stage" '[open-gate]' ''; then
    echo "accepted blockers at ordinary stage: $ordinary_stage" >&2
    exit 1
  fi
done
if valid_blocker_state blocked '[open-gate]' ''; then
  echo 'accepted blocked state with empty resume_stage' >&2
  exit 1
fi

provenance_ref=$(sed -n 's/^plan_provenance_ref: "\(.*\)"$/\1/p' "$target/approvals.yml")
comment_id=${provenance_ref##*issuecomment-}
repo_path=$(printf '%s\n' "$provenance_ref" | sed -n 's#https://github.com/\([^/]*/[^/]*\)/issues/.*#\1#p')
test -n "$repo_path"
test -n "$comment_id"
comment=$(gh api "repos/$repo_path/issues/comments/$comment_id")
test "$(printf '%s' "$comment" | jq -r '.user.login')" = stefanriegel

for artifact in config intent spec plan; do
  expected=$(sed -n "s/^${artifact}_hash: \"\(.*\)\"$/\1/p" "$target/approvals.yml")
  printf '%s' "$comment" | jq -er --arg hash "$expected" '.body | contains($hash)' >/dev/null
done

echo 'active work ok: approvals, provenance, revision, stage'
