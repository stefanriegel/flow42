#!/bin/sh
set -eu

ref=${1:-refs/tags/v1.0.0}
output_dir=${2:-dist}

if test "$ref" != refs/tags/v1.0.0; then
    echo "release ref must be exactly refs/tags/v1.0.0" >&2
    exit 2
fi

git rev-parse --verify "$ref^{tag}" >/dev/null 2>&1 || {
  echo "release ref must be an annotated tag" >&2
  exit 1
}
git verify-tag "$ref" >/dev/null 2>&1 || {
  echo "release tag signature verification failed" >&2
  exit 1
}

for manifest in .claude-plugin/marketplace.json .claude-plugin/plugin.json .codex-plugin/plugin.json; do
  version=$(git show "$ref:$manifest" | jq -er '.version') || {
    echo "cannot read version from $manifest at $ref" >&2
    exit 1
  }
  if test "$version" != 1.0.0; then
    echo "$manifest at $ref must declare version 1.0.0" >&2
    exit 1
  fi
done

mkdir -p "$output_dir"
archive="$output_dir/flow42-v1.0.0.tar"
checksum="$archive.sha256"

git archive --format=tar --prefix="flow42-v1.0.0/" "$ref" >"$archive"

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
