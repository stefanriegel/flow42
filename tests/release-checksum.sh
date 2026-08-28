#!/bin/sh
set -eu

tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-release.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
repo="$tmp/repo"

command -v ssh-keygen >/dev/null 2>&1
git init -q "$repo"
cd "$repo"
git config user.name 'Flow42 CI'
git config user.email 'flow42-ci@example.invalid'
git config gpg.format ssh
ssh-keygen -q -t ed25519 -N '' -C flow42-ci@example.invalid -f "$tmp/signing-key"
git config user.signingkey "$tmp/signing-key"
printf 'flow42-ci@example.invalid %s\n' "$(cat "$tmp/signing-key.pub")" >"$tmp/allowed-signers"
git config gpg.ssh.allowedSignersFile "$tmp/allowed-signers"

mkdir -p .claude-plugin .codex-plugin
for manifest in .claude-plugin/marketplace.json .claude-plugin/plugin.json .codex-plugin/plugin.json; do
  printf '{"version":"1.0.0"}\n' >"$manifest"
done
printf 'release fixture\n' >README.md
git add .
git commit -qm fixture
git tag -s v1.0.0 -m 'Flow42 1.0.0'

sh "$root/scripts/release-checksum.sh" refs/tags/v1.0.0 "$tmp/one" >/dev/null
sh "$root/scripts/release-checksum.sh" refs/tags/v1.0.0 "$tmp/two" >/dev/null

first="$tmp/one/flow42-v1.0.0.tar"
second="$tmp/two/flow42-v1.0.0.tar"
cmp "$first" "$second"
cmp "$first.sha256" "$second.sha256"

expected=$(sed -n 's/  .*//p' "$first.sha256")
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$first" | awk '{print $1}')
else
  actual=$(shasum -a 256 "$first" | awk '{print $1}')
fi
test "$expected" = "$actual"

reject() {
  if sh "$root/scripts/release-checksum.sh" "$1" "$tmp/rejected" >/dev/null 2>&1; then
    echo "accepted invalid release ref: $1" >&2
    exit 1
  fi
}

reject HEAD
reject refs/heads/main
reject v1.0.0
git tag -s v1.0.1 -m wrong
reject refs/tags/v1.0.1

git tag -d v1.0.0 >/dev/null
git tag v1.0.0
reject refs/tags/v1.0.0
git tag -d v1.0.0 >/dev/null
git tag -a v1.0.0 -m unsigned
reject refs/tags/v1.0.0
git tag -d v1.0.0 >/dev/null
sed 's/1.0.0/1.0.1/' .codex-plugin/plugin.json >.codex-plugin/plugin.json.tmp
mv .codex-plugin/plugin.json.tmp .codex-plugin/plugin.json
git add .codex-plugin/plugin.json
git commit -qm mismatch
git tag -s v1.0.0 -m 'mismatched Flow42 1.0.0'
reject refs/tags/v1.0.0

echo 'release checksum ok: signed exact tag, bound manifests, deterministic SHA-256'
