#!/bin/sh
# shellcheck disable=SC2016
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
fixtures="$root/tests/fixtures/review-receipt"
expected_head=0123456789abcdef0123456789abcdef01234567
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-receipt.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM

validate_receipt() {
  receipt=$1
  reviewed_head=$2
  strongest=$3
  failed=0
  check() {
    diagnostic=$1
    expression=$2
    if ! jq -e --arg head "$reviewed_head" --arg strongest "$strongest" "$expression" "$receipt" >/dev/null; then
      echo "$diagnostic" >&2
      failed=1
    fi
  }
  check RECEIPT-ISSUER '.issuer_kind | IN("authenticated-forge", "trusted-orchestrator", "local-independent-pass")'
  check RECEIPT-PROVENANCE '(.issuer_receipt_ref | type == "string" and length > 0) and (.dispatch_or_session_ref | type == "string" and length > 0) and .issuer_kind == $strongest and (if .issuer_kind == "local-independent-pass" then (.stronger_issuer_unavailable_reason | type == "string" and length > 0) else true end)'
  check RECEIPT-REVIEWER '(.reviewer_principal | type == "string" and length > 0) and .reviewer_role == "independent-reviewer" and .implementer == false'
  check RECEIPT-HEAD '(.reviewed_head | type == "string" and test("^[0-9a-f]{40}$")) and .reviewed_head == $head'
  check RECEIPT-VERDICT '.verdict | IN("pass", "blocked")'
  check RECEIPT-CHECKS '(.checks | type == "array" and length > 0) and all(.checks[]; type == "string" and length > 0)'
  check RECEIPT-ARTIFACT '(.artifact_ref | type == "string" and length > 0) and (.recorded_at | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")) and .schema_version == 1'
  test "$failed" -eq 0
}

validate_receipt "$fixtures/valid-forge.json" "$expected_head" authenticated-forge
validate_receipt "$fixtures/valid-local-pass.json" "$expected_head" local-independent-pass

for fixture in "$fixtures"/invalid-*.json; do
  name=${fixture##*/}; name=${name%.json}
  strongest=trusted-orchestrator
  case "$name" in
    invalid-issuer) expected=RECEIPT-ISSUER; strongest=self-authored ;;
    invalid-provenance) expected=RECEIPT-PROVENANCE ;;
    invalid-weaker-issuer) expected=RECEIPT-PROVENANCE; strongest=authenticated-forge ;;
    invalid-reviewer) expected=RECEIPT-REVIEWER ;;
    invalid-head) expected=RECEIPT-HEAD ;;
    invalid-verdict) expected=RECEIPT-VERDICT ;;
    invalid-checks) expected=RECEIPT-CHECKS ;;
    invalid-artifact) expected=RECEIPT-ARTIFACT ;;
    *) echo "unknown fixture: $name" >&2; exit 1 ;;
  esac
  log="$tmp/$name.log"
  if validate_receipt "$fixture" "$expected_head" "$strongest" >"$log" 2>&1; then
    echo "review receipt mutation survived: $name" >&2
    exit 1
  fi
  if test "$(wc -l <"$log" | tr -d ' ')" -ne 1 || ! grep -Fxq "$expected" "$log"; then
    echo "review receipt failed non-exclusively or for the wrong reason: $name" >&2
    sed -n '1,20p' "$log" >&2
    exit 1
  fi
done

receipt_is_current() {
  repo=$1; reviewed=$2; work_id=$3; policy=$4
  git -C "$repo" merge-base --is-ancestor "$reviewed" HEAD || return 1
  neutral=$(jq -c '.independent_review.receipt_neutral_paths' "$policy")
  git -C "$repo" diff --name-only -z "$reviewed" HEAD -- |
    jq -Rse --arg prefix ".flow42/$work_id/" --argjson neutral "$neutral" '
      split("\u0000")[:-1] | all(.[];
        . as $path |
        (($path | startswith($prefix)) and
          (($path | ltrimstr($prefix)) as $leaf |
            ($leaf | contains("/")) == false and ($neutral | index($leaf)) != null)))' >/dev/null
}

repo="$tmp/repo"
mkdir -p "$repo/.flow42/wi"
git -C "$repo" init -q
git -C "$repo" config user.name fixture
git -C "$repo" config user.email fixture@example.test
printf 'code\n' >"$repo/product.txt"
for file in intent.md spec.md plan.md evidence.md decisions.md status.yml history.jsonl; do
  printf 'initial\n' >"$repo/.flow42/wi/$file"
done
git -C "$repo" add . && git -C "$repo" commit -qm initial
reviewed=$(git -C "$repo" rev-parse HEAD)

printf 'receipt\n' >>"$repo/.flow42/wi/evidence.md"
git -C "$repo" add . && git -C "$repo" commit -qm receipt
git -C "$repo" branch neutral

git -C "$repo" switch -q -c spec-case "$reviewed"
printf 'changed\n' >>"$repo/.flow42/wi/spec.md"
git -C "$repo" add . && git -C "$repo" commit -qm spec
git -C "$repo" branch spec

git -C "$repo" switch -q -c config-case "$reviewed"
printf 'schema_version: 1\n' >"$repo/.flow42/config.yml"
git -C "$repo" add . && git -C "$repo" commit -qm config
git -C "$repo" branch config

git -C "$repo" switch -q -c product-case "$reviewed"
printf 'changed\n' >>"$repo/product.txt"
git -C "$repo" add . && git -C "$repo" commit -qm product
git -C "$repo" branch product

git -C "$repo" switch -q -c root-evidence-case "$reviewed"
printf 'unrelated receipt\n' >"$repo/evidence.md"
git -C "$repo" add . && git -C "$repo" commit -qm root-evidence
git -C "$repo" branch root-evidence

git -C "$repo" switch -q -c odd-case "$reviewed"
odd=$(printf '.flow42/wi/odd\n"name')
printf 'changed\n' >"$repo/$odd"
git -C "$repo" add . && git -C "$repo" commit -qm odd
git -C "$repo" branch odd

git -C "$repo" switch -q neutral
receipt_is_current "$repo" "$reviewed" wi "$root/core/risk-policy.json"
for branch in spec config product root-evidence odd; do
  git -C "$repo" switch -q "$branch"
  if receipt_is_current "$repo" "$reviewed" wi "$root/core/risk-policy.json"; then
    echo "receipt remained current after $branch mutation" >&2
    exit 1
  fi
done

sed -f "$fixtures/neutral-includes-spec.sed" "$root/core/risk-policy.json" \
  >"$tmp/neutral-includes-spec.json"
git -C "$repo" switch -q spec
if ! receipt_is_current "$repo" "$reviewed" wi "$tmp/neutral-includes-spec.json"; then
  echo 'receipt policy mutation was not behaviorally exercised: neutral-includes-spec' >&2
  exit 1
fi

# Even a mutated leaf policy cannot make a path outside the reviewed work item
# neutral; the path-scope rule is an independent part of the Interface.
sed -f "$fixtures/neutral-includes-config.sed" "$root/core/risk-policy.json" \
  >"$tmp/neutral-includes-config.json"
git -C "$repo" switch -q config
if receipt_is_current "$repo" "$reviewed" wi "$tmp/neutral-includes-config.json"; then
  echo 'receipt policy escaped the reviewed work-item path scope' >&2
  exit 1
fi

echo 'review receipt ok: exclusive shape diagnostics, issuer strength, NUL-safe receipt-neutral currency'
