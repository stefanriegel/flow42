#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)

test -f "$root/skills/update/SKILL.md"
grep -q 'Do not edit harness cache directories' "$root/skills/update/SKILL.md"
grep -q 'all 12 canonical skill' "$root/skills/update/SKILL.md"
grep -q 'refreshing the existing marketplace alone cannot advance versions' "$root/skills/update/SKILL.md"
grep -q 'restore the recorded source' "$root/skills/update/SKILL.md"

for target in claude codex pi; do
  output=$(sh "$root/scripts/install-local" "$target" --dry-run)
  printf '%s\n' "$output" | grep -q "local $target installation plan verified"
done

if sh "$root/scripts/install-local" invalid --dry-run >/dev/null 2>&1; then
  echo 'invalid harness accepted' >&2
  exit 1
fi

echo 'update ok: release skill and local harness plans'
