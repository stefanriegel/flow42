#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-release.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

sh "$root/scripts/release-checksum.sh" HEAD "$tmp/one" >/dev/null
sh "$root/scripts/release-checksum.sh" HEAD "$tmp/two" >/dev/null

first="$tmp/one/flow42-vHEAD.tar"
second="$tmp/two/flow42-vHEAD.tar"
cmp "$first" "$second"
cmp "$first.sha256" "$second.sha256"

expected=$(sed -n 's/  .*//p' "$first.sha256")
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$first" | awk '{print $1}')
else
  actual=$(shasum -a 256 "$first" | awk '{print $1}')
fi
test "$expected" = "$actual"

echo 'release checksum ok: deterministic archive and SHA-256'
