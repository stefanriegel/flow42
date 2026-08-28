#!/bin/sh
set -eu

ref=${1:-}
output_dir=${2:-dist}
signer_identity=flow42-release@stefanriegel
trusted_key=AAAAC3NzaC1lZDI1NTE5AAAAIHwQoU4CQFvLL4xDRlGZbvtAfU+NK7cZhPey28aCoiV8

case "$ref" in
  refs/tags/v[0-9]*.[0-9]*.[0-9]*) ;;
  *)
    echo "release ref must be an exact refs/tags/vX.Y.Z ref" >&2
    exit 2
    ;;
esac
release_version=${ref#refs/tags/v}
if ! printf '%s\n' "$release_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "release ref must be an exact refs/tags/vX.Y.Z ref" >&2
  exit 2
fi

git rev-parse --verify "$ref^{tag}" >/dev/null 2>&1 || {
  echo "release ref must be an annotated tag" >&2
  exit 1
}
allowed_signers=$(mktemp "${TMPDIR:-/tmp}/flow42-signers.XXXXXX")
trap 'rm -f "$allowed_signers"' EXIT HUP INT TERM
git show "$ref:.github/allowed_signers" >"$allowed_signers" || {
  echo "cannot read release signer allowlist" >&2
  exit 1
}
if test "$(wc -l <"$allowed_signers" | tr -d ' ')" != 1 ||
  test "$(awk '{print $1}' "$allowed_signers")" != "$signer_identity" ||
  test "$(awk '{print $2}' "$allowed_signers")" != ssh-ed25519 ||
  test "$(awk '{print $3}' "$allowed_signers")" != "$trusted_key"; then
  echo "release signer allowlist differs from pinned trust root" >&2
  exit 1
fi
verification=$(git -c gpg.format=ssh \
  -c gpg.ssh.allowedSignersFile="$allowed_signers" \
  verify-tag --raw "$ref" 2>&1) || {
  echo "release tag signature verification failed" >&2
  exit 1
}
printf '%s\n' "$verification" |
  grep -Fq "Good \"git\" signature for $signer_identity with" || {
  echo "release tag signer must be $signer_identity" >&2
  exit 1
}

for manifest in .claude-plugin/marketplace.json .claude-plugin/plugin.json .codex-plugin/plugin.json; do
  version=$(git show "$ref:$manifest" | jq -er '.version') || {
    echo "cannot read version from $manifest at $ref" >&2
    exit 1
  }
  if test "$version" != "$release_version"; then
    echo "$manifest at $ref must declare version $release_version" >&2
    exit 1
  fi
done

mkdir -p "$output_dir"
archive="$output_dir/flow42-v$release_version.tar"
checksum="$archive.sha256"

git archive --format=tar --prefix="flow42-v$release_version/" "$ref" >"$archive"

if command -v sha256sum >/dev/null 2>&1; then
  digest=$(sha256sum "$archive" | awk '{print $1}')
elif command -v shasum >/dev/null 2>&1; then
  digest=$(shasum -a 256 "$archive" | awk '{print $1}')
else
  echo 'sha256sum or shasum is required' >&2
  exit 1
fi

printf '%s  %s\n' "$digest" "$(basename "$archive")" >"$checksum"
printf '%s\n' "$checksum"
