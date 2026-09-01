#!/bin/sh
set -eu

# Structural contract for the runtime-free update instructions. Harness-native
# installation behavior belongs to the harness; this test prevents Flow42 from
# growing a second package manager or claiming stronger rollback than it has.

root=$(CDPATH=''; export CDPATH; cd -P -- "$(dirname -- "$0")/.." && pwd)
skill=$root/skills/update/SKILL.md
eval_runner=$root/evals/run.sh
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-update-test.XXXXXX")
trap 'find "$tmp" -depth -delete' EXIT HUP INT TERM

fail() {
  printf 'update contract failed: %s\n' "$1" >&2
  return 1
}

check_skill() {
  file=$1
  flat=$(tr '\n' ' ' <"$file")

  contains() {
    case "$flat" in *"$1"*) return 0 ;; *) return 1 ;; esac
  }

  lines=$(wc -l <"$file" | tr -d ' ')
  test "$lines" -le 180 || fail UPDATE-TOO-LARGE || return 1

  inspect=$(grep -n '^## 1\. Inspect without mutation$' "$file" | cut -d: -f1)
  verify=$(grep -n '^## 2\. Verify the release before mutation$' "$file" | cut -d: -f1)
  install=$(grep -n '^## 3\. Install through the harness$' "$file" | cut -d: -f1)
  report=$(grep -n '^## 4\. Verify and report$' "$file" | cut -d: -f1)
  test -n "$inspect" && test "$inspect" -lt "$verify" &&
    test "$verify" -lt "$install" && test "$install" -lt "$report" ||
    fail UPDATE-ORDER || return 1

  contains 'Orca owns worktree, terminal, process, and worker' ||
    fail UPDATE-ORCA-BOUNDARY || return 1
  contains 'Flow42 must not recreate or clean up those resources' ||
    fail UPDATE-ORCA-OWNERSHIP || return 1
  contains 'Require exactly one current installation target' ||
    fail UPDATE-AMBIGUOUS-STATE || return 1
  contains 'keep the current installation' ||
    fail UPDATE-SAFE-FALLBACK || return 1

  contains 'already-installed bundle is the trust anchor' ||
    fail UPDATE-TRUSTED-ROOT || return 1
  contains 'Fetch only the selected tag' ||
    fail UPDATE-BOUNDED-FETCH || return 1
  contains 'empty template' || fail UPDATE-EMPTY-TEMPLATE || return 1
  contains 'replacement objects' || fail UPDATE-NO-REPLACE || return 1
  contains 'alternate object stores' || fail UPDATE-NO-ALTERNATES || return 1
  contains "Reject unexpected \`GIT_CONFIG_*\`" ||
    fail UPDATE-GIT-ENVIRONMENT || return 1
  contains 'object-directory, worktree, or repository environment overrides' ||
    fail UPDATE-GIT-ENVIRONMENT || return 1
  contains 'Compare the fetched tag object with the exact remote advertisement' ||
    fail UPDATE-TAG-BINDING || return 1
  contains "Do not run scripts from the candidate before this verification succeeds" ||
    fail UPDATE-CANDIDATE-AUTHORITY || return 1

  for harness in 'Claude Code:' 'Codex:' 'Pi:'; do
    contains "$harness" || fail UPDATE-HARNESS-PARITY || return 1
  done
  contains 'best-effort recovery through the same native commands' ||
    fail UPDATE-RECOVERY || return 1
  contains 'Never claim byte-identical rollback' ||
    fail UPDATE-HONEST-ROLLBACK || return 1
  contains 'Do not edit, copy, delete, or attest private harness cache directories' ||
    fail UPDATE-CACHE-BOUNDARY || return 1
  contains 'do not block unrelated project work' ||
    fail UPDATE-PROJECT-FALLBACK || return 1

  private_cache_marker='~'/.claude/plugins/cache
  if contains "$private_cache_marker" ||
     contains 'recorded state restored' ||
     contains 'two consecutive point-in-time'; then
    fail UPDATE-PRIVATE-CACHE-MACHINERY || return 1
  fi
}

check_eval_tier() {
  file=$1
  label_count=$(grep -Fxc 'record_pass text-conformance update-instructions' \
    "$file" || true)
  test "$label_count" -eq 1 || fail UPDATE-EVAL-TIER || return 1
  if grep -Eq '^record_pass behavioural-reference update-' "$file"; then
    fail UPDATE-EVAL-BEHAVIOURAL-CLAIM || return 1
  fi
}

check_skill "$skill"
check_eval_tier "$eval_runner"

# Mutation checks prove the boundary assertions are not vacuous.
sed '/Orca owns worktree, terminal, process, and worker/d' "$skill" >"$tmp/no-orca.md"
if check_skill "$tmp/no-orca.md" 2>"$tmp/no-orca.err"; then
  fail UPDATE-MUTATION-ORCA-ACCEPTED
fi
grep -Fq UPDATE-ORCA-BOUNDARY "$tmp/no-orca.err"

sed 's/Never claim byte-identical rollback/Claim byte-identical rollback/' \
  "$skill" >"$tmp/false-rollback.md"
if check_skill "$tmp/false-rollback.md" 2>"$tmp/false-rollback.err"; then
  fail UPDATE-MUTATION-ROLLBACK-ACCEPTED
fi
grep -Fq UPDATE-HONEST-ROLLBACK "$tmp/false-rollback.err"

sed "/Reject unexpected \`GIT_CONFIG_\\*\`/,+1d" "$skill" >"$tmp/no-git-environment.md"
if check_skill "$tmp/no-git-environment.md" 2>"$tmp/no-git-environment.err"; then
  fail UPDATE-MUTATION-GIT-ENVIRONMENT-ACCEPTED
fi
grep -Fq UPDATE-GIT-ENVIRONMENT "$tmp/no-git-environment.err"

sed 's/^record_pass text-conformance update-instructions$/record_pass behavioural-reference update-convergence/' \
  "$eval_runner" >"$tmp/false-eval-tier.sh"
if check_eval_tier "$tmp/false-eval-tier.sh" 2>"$tmp/false-eval-tier.err"; then
  fail UPDATE-MUTATION-EVAL-TIER-ACCEPTED
fi
grep -Fq UPDATE-EVAL-TIER "$tmp/false-eval-tier.err"

echo "update ok: narrow verified-release instructions and honest text-conformance tier"
