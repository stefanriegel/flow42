#!/bin/sh
set -eu

ref=${1:-v1.0.0}
output_dir=${2:-dist}
version=${ref#v}

case "$version" in
  ''|*[!0-9A-Za-z.-]*)
    echo "invalid release ref: $ref" >&2
    exit 2
    ;;
esac

git rev-parse --verify "$ref^{commit}" >/dev/null
mkdir -p "$output_dir"
archive="$output_dir/flow42-v$version.tar"
checksum="$archive.sha256"

git archive --format=tar --prefix="flow42-v$version/" "$ref" >"$archive"

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
