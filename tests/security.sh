#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)

owned() {
  path=$1
  allowed=$2
  test "$path" = "$allowed" || test "${path#"$allowed"/}" != "$path"
}

owned skills/intent/SKILL.md skills
owned skills skills
if owned skillset/escape.md skills; then
  exit 1
fi
if owned ../escape skills; then
  exit 1
fi

redact_remote() {
  printf '%s\n' "$1" | sed -E 's#(https?://)[^/@]+@#\1#; s#[?].*$##'
}

test "$(redact_remote 'https://token@example.com/owner/repo.git?access_token=secret')" = 'https://example.com/owner/repo.git'
test "$(redact_remote 'git@github.com:owner/repo.git')" = 'git@github.com:owner/repo.git'

if grep -Eq '^  (format|lint|typecheck|test|build): [^[]' "$root/templates/config.yml"; then
  exit 1
fi

for forbidden in 'eval' 'sh -c' 'bash -c'; do
  grep -q "$forbidden" "$root/core/SECURITY.md"
done

echo 'security ok: ownership, redaction, argv, forbidden shell execution'
