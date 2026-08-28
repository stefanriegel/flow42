#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-config-approval.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/check/tests" "$tmp/check/.flow42" "$tmp/bin"
cp "$root/tests/config-approval.sh" "$tmp/check/tests/config-approval.sh"
cp "$root/.flow42/config.yml" "$tmp/check/.flow42/config.yml"

if command -v sha256sum >/dev/null 2>&1; then
  config_hash=$(sha256sum "$tmp/check/.flow42/config.yml" | awk '{print $1}')
else
  config_hash=$(shasum -a 256 "$tmp/check/.flow42/config.yml" | awk '{print $1}')
fi

write_approval() {
  hash=$1
  approver=$2
  approved_at=$3
  verified_at=$4
  provenance=${5:-yes}
  {
    printf '%s\n' 'schema_version: 1'
    printf 'config_hash: "%s"\n' "$hash"
    printf 'config_approved_by: "%s"\n' "$approver"
    printf 'config_approved_at: "%s"\n' "$approved_at"
    if test "$provenance" = yes; then
      printf '%s\n' 'config_provenance_kind: "github-comment"'
      printf '%s\n' 'config_provenance_ref: "https://github.com/stefanriegel/flow42/issues/1#issuecomment-5444860242"'
      printf 'config_provenance_verified_at: "%s"\n' "$verified_at"
    fi
  } >"$tmp/check/.flow42/config-approval.yml"
}

write_comment() {
  hash=$1
  login=${2:-stefanriegel}
  updated_at=${3:-2026-08-27T20:33:30Z}
  jq -n --arg hash "$hash" --arg login "$login" --arg updated_at "$updated_at" '{
    html_url: "https://github.com/stefanriegel/flow42/issues/1#issuecomment-5444860242",
    issue_url: "https://api.github.com/repos/stefanriegel/flow42/issues/1",
    author_association: "OWNER",
    user: {login: $login},
    body: ("repository configuration SHA-256: `" + $hash + "`"),
    created_at: "2026-08-27T20:30:28Z",
    updated_at: $updated_at
  }' >"$tmp/comment.json"
}

cat >"$tmp/bin/gh" <<'EOF'
#!/bin/sh
set -eu
test "$1" = api
test "$2" = repos/stefanriegel/flow42/issues/comments/5444860242
cat "$FLOW42_TEST_COMMENT"
EOF
chmod +x "$tmp/bin/gh"

run_check() {
  FLOW42_TEST_COMMENT="$tmp/comment.json" PATH="$tmp/bin:$PATH" sh "$tmp/check/tests/config-approval.sh" >/dev/null 2>&1
}

expect_failure() {
  label=$1
  if run_check; then
    printf 'unexpected success: %s\n' "$label" >&2
    exit 1
  fi
  printf 'ok rejected %s\n' "$label"
}

write_comment "$config_hash"
write_approval "$config_hash" stefanriegel 2026-08-27T20:33:30Z 2026-08-27T22:43:04Z
run_check
printf '%s\n' 'ok exact authenticated record'

printf '%s\n' 'risk_default: high' >>"$tmp/check/.flow42/config.yml"
if command -v sha256sum >/dev/null 2>&1; then
  rebased_hash=$(sha256sum "$tmp/check/.flow42/config.yml" | awk '{print $1}')
else
  rebased_hash=$(shasum -a 256 "$tmp/check/.flow42/config.yml" | awk '{print $1}')
fi
write_approval "$rebased_hash" stefanriegel 2026-08-27T20:33:30Z 2026-08-27T22:43:04Z
expect_failure 'config-plus-record hash rebasing'

write_comment "$rebased_hash" arbitrary-user
write_approval "$rebased_hash" arbitrary-user 2026-08-27T20:33:30Z 2026-08-27T22:43:04Z
expect_failure 'forged response plus config and approval-record rebasing'

cp "$root/.flow42/config.yml" "$tmp/check/.flow42/config.yml"
write_comment "$config_hash"
write_approval "$config_hash" arbitrary-user 2026-08-27T20:33:30Z 2026-08-27T22:43:04Z
expect_failure 'arbitrary approver'

write_approval "$config_hash" stefanriegel 2026-08-27T20:33:30Z 2026-08-27T19:00:00Z
expect_failure 'stale provenance timestamp'

write_approval "$config_hash" stefanriegel 2026-08-27T20:33:30Z not-a-timestamp
expect_failure 'malformed provenance timestamp'

write_approval "$config_hash" stefanriegel 2026-08-27T20:33:30Z 2026-08-27T22:43:04Z no
expect_failure 'missing provenance'

echo 'config approval adversarial checks ok'
