#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)

manifests=$(find "$root" -type f \( -name package-lock.json -o -name pnpm-lock.yaml -o \
  -name yarn.lock -o -name requirements.txt -o -name poetry.lock -o -name Pipfile.lock -o \
  -name go.sum -o -name Cargo.lock -o -name Gemfile.lock \) -not -path "$root/.git/*")
test -z "$manifests"

uses=$(sed -n 's/^[[:space:]]*- uses: .*@\(.*\)$/\1/p' "$root/.github/workflows/ci.yml")
printf '%s\n' "$uses" | while IFS= read -r ref; do
  printf '%s\n' "$ref" | grep -Eq '^[0-9a-f]{40}$'
done

echo 'dependencies ok: no product manifests, immutable action pins'
