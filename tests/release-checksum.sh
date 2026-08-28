#!/bin/sh
set -eu

tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-release.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
repo="$tmp/repo"
identity=flow42-release@stefanriegel
release_signers="$root/.github/allowed_signers"

command -v ssh-keygen >/dev/null 2>&1
test "$(wc -l <"$release_signers" | tr -d ' ')" = 1
test "$(awk '{print $1}' "$release_signers")" = "$identity"
test "$(awk '{print $2}' "$release_signers")" = ssh-ed25519
test "$(awk '{print $3}' "$release_signers")" = AAAAC3NzaC1lZDI1NTE5AAAAIHwQoU4CQFvLL4xDRlGZbvtAfU+NK7cZhPey28aCoiV8
ssh-keygen -l -f "$release_signers" >/dev/null

git init -q "$repo"
cd "$repo"
git config user.name 'Flow42 CI'
git config user.email 'flow42-ci@example.invalid'
git config gpg.format ssh
ssh-keygen -q -t ed25519 -N '' -C flow42-ci@example.invalid -f "$tmp/signing-key"
git config user.signingkey "$tmp/signing-key"
mkdir -p .github scripts
awk -v identity="$identity" '{print identity, $0}' "$tmp/signing-key.pub" >.github/allowed_signers
cp "$root/scripts/release-checksum.sh" scripts/release-checksum.sh
printf 'ambient@example.invalid %s\n' "$(cat "$tmp/signing-key.pub")" >"$tmp/ambient-signers"
git config gpg.ssh.allowedSignersFile "$tmp/ambient-signers"

mkdir -p .claude-plugin .codex-plugin
for manifest in .claude-plugin/marketplace.json .claude-plugin/plugin.json .codex-plugin/plugin.json; do
  printf '{"version":"1.0.0"}\n' >"$manifest"
done
printf 'release fixture\n' >README.md
git add .
git commit -qm fixture
git tag -s v1.0.0 -m 'Flow42 1.0.0'

sh "$repo/scripts/release-checksum.sh" refs/tags/v1.0.0 "$tmp/one" >/dev/null
sh "$repo/scripts/release-checksum.sh" refs/tags/v1.0.0 "$tmp/two" >/dev/null

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
  if sh "$repo/scripts/release-checksum.sh" "$1" "$tmp/rejected" >/dev/null 2>&1; then
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
awk '{print "wrong@example.invalid", $2, $3, $4}' .github/allowed_signers >.github/allowed_signers.tmp
mv .github/allowed_signers.tmp .github/allowed_signers
git add .github/allowed_signers
git commit -qm wrong-principal
git tag -s v1.0.0 -m 'wrong-principal Flow42 1.0.0'
reject refs/tags/v1.0.0
git tag -d v1.0.0 >/dev/null
awk -v identity="$identity" '{print identity, $2, $3, $4}' .github/allowed_signers >.github/allowed_signers.tmp
mv .github/allowed_signers.tmp .github/allowed_signers
ssh-keygen -q -t ed25519 -N '' -C untrusted@example.invalid -f "$tmp/untrusted-key"
git config user.signingkey "$tmp/untrusted-key"
git add .github/allowed_signers
git commit -qm untrusted-key
git tag -s v1.0.0 -m 'untrusted-key Flow42 1.0.0'
reject refs/tags/v1.0.0
git tag -d v1.0.0 >/dev/null
git config user.signingkey "$tmp/signing-key"
sed 's/1.0.0/1.0.1/' .codex-plugin/plugin.json >.codex-plugin/plugin.json.tmp
mv .codex-plugin/plugin.json.tmp .codex-plugin/plugin.json
git add .codex-plugin/plugin.json
git commit -qm mismatch
git tag -s v1.0.0 -m 'mismatched Flow42 1.0.0'
reject refs/tags/v1.0.0

echo 'release checksum ok: trusted signer, exact tag, bound manifests, deterministic SHA-256'
