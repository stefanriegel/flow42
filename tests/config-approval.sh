#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
approval="$root/.flow42/config-approval.yml"
config="$root/.flow42/config.yml"
provenance_ref='https://github.com/stefanriegel/flow42/issues/1#issuecomment-5444860242'
comment_api='repos/stefanriegel/flow42/issues/comments/5444860242'
approved_config_hash='69ecdc3cbb2a64c5e0afdf382661bed7ef02cd144e1ed9d116dbf235a65e50e6'
approved_owner='stefanriegel'

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

field() {
  sed -n "s/^$1: \"\(.*\)\"$/\1/p" "$approval"
}

test -f "$approval"
config_hash=$(hash_file "$config")
approved_by=$(field config_approved_by)
approved_at=$(field config_approved_at)
verified_at=$(field config_provenance_verified_at)

test "$config_hash" = "$approved_config_hash"
test "$(field config_hash)" = "$approved_config_hash"
test "$approved_by" = "$approved_owner"
test "$(field config_provenance_kind)" = github-comment
test "$(field config_provenance_ref)" = "$provenance_ref"
test -n "$approved_at"
test -n "$verified_at"

comment=$(gh api "$comment_api")
printf '%s' "$comment" | jq -e \
  --arg login "$approved_owner" \
  --arg hash "$approved_config_hash" \
  --arg ref "$provenance_ref" \
  --arg approved_at "$approved_at" \
  --arg verified_at "$verified_at" '
    .html_url == $ref and
    .issue_url == "https://api.github.com/repos/stefanriegel/flow42/issues/1" and
    .author_association == "OWNER" and
    .user.login == $login and
    .updated_at == $approved_at and
    (.body | contains("repository configuration SHA-256: `" + $hash + "`")) and
    ([.created_at, .updated_at, $verified_at] | all(
      type == "string" and
      test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")
    )) and
    ((.created_at | fromdateiso8601) <= (.updated_at | fromdateiso8601)) and
    ((.updated_at | fromdateiso8601) <= ($verified_at | fromdateiso8601))
  ' >/dev/null

echo 'config approval ok: current hash and authenticated Issue #1 provenance'
