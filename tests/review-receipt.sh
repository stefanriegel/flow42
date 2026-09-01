#!/bin/sh
# shellcheck disable=SC2016
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
fixtures="$root/tests/fixtures/review-receipt"
resolver="$fixtures/fake-resolver.sh"
expected_head=0123456789abcdef0123456789abcdef01234567
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-receipt.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM

jq -e '.independent_review.local_fallback_tier == "lower" and
  .independent_review.issuer_resolution.fail_closed == true and
  .independent_review.issuer_resolution.required_for == ["authenticated-forge","trusted-orchestrator"] and
  .independent_review.issuer_resolution.resolver_must_be_independent == true and
  .independent_review.issuer_resolution.binding_fields == ["issuer_kind","issuer_receipt_ref","reviewer_principal","dispatch_or_session_ref","reviewed_head","verdict","artifact_ref"] and
  .independent_review.status_neutral_fields == ["stage","state_revision","updated_at","blockers","resume_stage","ci_state","next_actions","forge_item"] and
  (.independent_review.status_required_fields | type == "array" and length == 16)' "$root/core/risk-policy.json" >/dev/null || {
  echo RECEIPT-RESOLVER-POLICY >&2
  exit 1
}

validate_receipt() {
  receipt=$1
  reviewed_head=$2
  strongest=$3
  receipt_resolver=$4
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
  test "$failed" -eq 0 || return 1

  issuer=$(jq -r '.issuer_kind' "$receipt")
  test "$issuer" = local-independent-pass && return 0
  reference=$(jq -r '.issuer_receipt_ref' "$receipt")
  if ! resolved=$(sh "$receipt_resolver" "$issuer" "$reference"); then
    echo RECEIPT-RESOLUTION >&2
    return 1
  fi
  if ! printf '%s\n' "$resolved" | jq -e '
    .schema_version == 1 and .resolved == true and .authenticated == true and
    .resolver_independent == true' >/dev/null; then
    echo RECEIPT-RESOLUTION >&2
    return 1
  fi
  if ! jq -e --argjson resolved "$resolved" '
    .issuer_kind == $resolved.issuer_kind and
    .issuer_receipt_ref == $resolved.issuer_receipt_ref and
    .reviewer_principal == $resolved.reviewer_principal and
    .dispatch_or_session_ref == $resolved.dispatch_or_session_ref and
    .reviewed_head == $resolved.reviewed_head and
    .verdict == $resolved.verdict and
    .artifact_ref == $resolved.artifact_ref' "$receipt" >/dev/null; then
    echo RECEIPT-BINDING >&2
    return 1
  fi
}

validate_receipt "$fixtures/valid-forge.json" "$expected_head" authenticated-forge "$resolver"
validate_receipt "$fixtures/valid-orchestrator.json" "$expected_head" trusted-orchestrator "$resolver"
validate_receipt "$fixtures/valid-local-pass.json" "$expected_head" local-independent-pass "$resolver"

for fixture in "$fixtures"/invalid-*.json; do
  name=${fixture##*/}; name=${name%.json}
  strongest=trusted-orchestrator
  case "$name" in
    invalid-issuer) expected=RECEIPT-ISSUER; strongest=self-authored ;;
    invalid-provenance) expected=RECEIPT-PROVENANCE ;;
    invalid-weaker-issuer) expected=RECEIPT-PROVENANCE; strongest=authenticated-forge ;;
    invalid-unresolvable | invalid-unauthenticated) expected=RECEIPT-RESOLUTION ;;
    invalid-resolver-binding) expected=RECEIPT-BINDING; strongest=authenticated-forge ;;
    invalid-reviewer) expected=RECEIPT-REVIEWER ;;
    invalid-head) expected=RECEIPT-HEAD ;;
    invalid-verdict) expected=RECEIPT-VERDICT ;;
    invalid-checks) expected=RECEIPT-CHECKS ;;
    invalid-artifact) expected=RECEIPT-ARTIFACT ;;
    *) echo "unknown fixture: $name" >&2; exit 1 ;;
  esac
  log="$tmp/$name.log"
  if validate_receipt "$fixture" "$expected_head" "$strongest" "$resolver" >"$log" 2>&1; then
    echo "review receipt mutation survived: $name" >&2
    exit 1
  fi
  if test "$(wc -l <"$log" | tr -d ' ')" -ne 1 || ! grep -Fxq "$expected" "$log"; then
    echo "review receipt failed non-exclusively or for the wrong reason: $name" >&2
    sed -n '1,20p' "$log" >&2
    exit 1
  fi
done

tr '\n' ' ' <"$root/core/SECURITY.md" |
  grep -Fq 'Receipt-neutral changes to decisions.md never authenticate or supply human confirmation'

receipt_is_current() {
  repo=$1; reviewed=$2; work_id=$3; policy=$4
  git -C "$repo" merge-base --is-ancestor "$reviewed" HEAD || return 1
  neutral=$(jq -c '.independent_review.receipt_neutral_paths' "$policy")
  if ! git -C "$repo" diff --name-only --no-renames -z "$reviewed" HEAD -- |
    jq -Rse --arg prefix ".flow42/$work_id/" --argjson neutral "$neutral" '
      split("\u0000")[:-1] | all(.[];
        . as $path |
        (($path | startswith($prefix)) and
          (($path | ltrimstr($prefix)) as $leaf |
            ($leaf | contains("/")) == false and ($neutral | index($leaf)) != null)))' >/dev/null; then
    return 1
  fi

  status_path=".flow42/$work_id/status.yml"
  if git -C "$repo" diff --quiet "$reviewed" HEAD -- "$status_path"; then
    return 0
  fi
  git -C "$repo" show "$reviewed:$status_path" >"$tmp/status-before.yml" 2>/dev/null || return 1
  git -C "$repo" show "HEAD:$status_path" >"$tmp/status-after.yml" 2>/dev/null || return 1
  required_fields=$(jq -r '.independent_review.status_required_fields[]' "$policy" | sort)
  for status_file in "$tmp/status-before.yml" "$tmp/status-after.yml"; do
    all_fields=$(awk '/^[A-Za-z_][A-Za-z0-9_]*:/ {key=$0; sub(/:.*/, "", key); print key}' "$status_file")
    test "$(printf '%s\n' "$all_fields" | wc -l | tr -d ' ')" -eq \
      "$(printf '%s\n' "$all_fields" | sort -u | wc -l | tr -d ' ')" || return 1
    test "$(printf '%s\n' "$all_fields" | sort)" = "$required_fields" || return 1
  done
  status_fields=$(awk '/^[A-Za-z_][A-Za-z0-9_]*:/ {key=$0; sub(/:.*/, "", key); print key}' \
    "$tmp/status-before.yml" "$tmp/status-after.yml" | sort -u)
  allowed_fields=$(jq -r '.independent_review.status_neutral_fields[]' "$policy")
  for field in $status_fields; do
    awk -v field="$field" '
      $0 ~ "^" field ":" {inside=1}
      inside && $0 !~ "^" field ":" && /^[A-Za-z_][A-Za-z0-9_]*:/ {exit}
      inside {print}' "$tmp/status-before.yml" >"$tmp/status-before-field"
    awk -v field="$field" '
      $0 ~ "^" field ":" {inside=1}
      inside && $0 !~ "^" field ":" && /^[A-Za-z_][A-Za-z0-9_]*:/ {exit}
      inside {print}' "$tmp/status-after.yml" >"$tmp/status-after-field"
    if ! cmp -s "$tmp/status-before-field" "$tmp/status-after-field" &&
      ! printf '%s\n' "$allowed_fields" | grep -Fxq "$field"; then
      return 1
    fi
  done
}

repo="$tmp/repo"
mkdir -p "$repo/.flow42/wi"
git -C "$repo" init -q
git -C "$repo" config user.name fixture
git -C "$repo" config user.email fixture@example.test
git -C "$repo" commit --allow-empty -qm base
base=$(git -C "$repo" rev-parse HEAD)
printf 'code\n' >"$repo/product.txt"
for file in intent.md spec.md plan.md evidence.md decisions.md status.yml history.jsonl; do
  printf 'initial\n' >"$repo/.flow42/wi/$file"
done
{
  printf '%s\n' \
    'schema_version: 1' \
    'work_id: wi' \
    'title: Fixture' \
    'work_type: feature' \
    'stage: verifying' \
    'risk: high' \
    'state_revision: 1' \
    'created_at: 2026-09-01T10:00:00Z' \
    'updated_at: 2026-09-01T10:00:00Z' \
    'review_loops: 0' \
    'blockers: []' \
    'resume_stage: ""' \
    'forge_item: ""' \
    'change_request: ""' \
    'ci_state: unknown' \
    'next_actions: [verify]'
} >"$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm initial
reviewed=$(git -C "$repo" rev-parse HEAD)

printf 'receipt\n' >>"$repo/.flow42/wi/evidence.md"
git -C "$repo" add . && git -C "$repo" commit -qm receipt
git -C "$repo" branch neutral

git -C "$repo" checkout -q -b status-neutral-case "$reviewed"
sed -e 's/^stage: verifying$/stage: pr-ready/' \
  -e 's/^state_revision: 1$/state_revision: 2/' \
  -e 's/^updated_at: .*/updated_at: 2026-09-01T11:00:00Z/' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-neutral.yml"
mv "$tmp/status-neutral.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-neutral
git -C "$repo" branch status-neutral

git -C "$repo" checkout -q -b status-risk-case "$reviewed"
sed 's/^risk: high$/risk: low/' "$repo/.flow42/wi/status.yml" >"$tmp/status-risk.yml"
mv "$tmp/status-risk.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-risk
git -C "$repo" branch status-risk

git -C "$repo" checkout -q -b status-duplicate-risk-case "$reviewed"
sed -n '1,999p' "$fixtures/status-duplicate-risk.append" >>"$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-duplicate-risk
git -C "$repo" branch status-duplicate-risk

git -C "$repo" checkout -q -b spec-case "$reviewed"
printf 'changed\n' >>"$repo/.flow42/wi/spec.md"
git -C "$repo" add . && git -C "$repo" commit -qm spec
git -C "$repo" branch spec

git -C "$repo" checkout -q -b config-case "$reviewed"
printf 'schema_version: 1\n' >"$repo/.flow42/config.yml"
git -C "$repo" add . && git -C "$repo" commit -qm config
git -C "$repo" branch config

git -C "$repo" checkout -q -b product-case "$reviewed"
printf 'changed\n' >>"$repo/product.txt"
git -C "$repo" add . && git -C "$repo" commit -qm product
git -C "$repo" branch product

git -C "$repo" checkout -q -b root-evidence-case "$reviewed"
printf 'unrelated receipt\n' >"$repo/evidence.md"
git -C "$repo" add . && git -C "$repo" commit -qm root-evidence
git -C "$repo" branch root-evidence

git -C "$repo" checkout -q -b odd-case "$reviewed"
odd=$(printf '.flow42/wi/odd\n"name')
printf 'changed\n' >"$repo/$odd"
git -C "$repo" add . && git -C "$repo" commit -qm odd
git -C "$repo" branch odd

git -C "$repo" checkout -q -b nested-case "$reviewed"
mkdir -p "$repo/.flow42/wi/nested"
printf 'nested\n' >"$repo/.flow42/wi/nested/evidence.md"
git -C "$repo" add . && git -C "$repo" commit -qm nested
git -C "$repo" branch nested

git -C "$repo" checkout -q -b rename-case "$reviewed"
git -C "$repo" rm -q .flow42/wi/evidence.md
git -C "$repo" mv product.txt .flow42/wi/evidence.md
git -C "$repo" commit -qm rename-into-neutral
git -C "$repo" branch rename-into-neutral

git -C "$repo" checkout -q -b nonancestor-case "$base"
printf 'sibling\n' >"$repo/sibling.txt"
git -C "$repo" add . && git -C "$repo" commit -qm sibling
git -C "$repo" branch nonancestor

git -C "$repo" checkout -q neutral
receipt_is_current "$repo" "$reviewed" wi "$root/core/risk-policy.json"
git -C "$repo" checkout -q status-neutral
receipt_is_current "$repo" "$reviewed" wi "$root/core/risk-policy.json"
for branch in spec config product root-evidence odd status-risk status-duplicate-risk nested rename-into-neutral nonancestor; do
  git -C "$repo" checkout -q "$branch"
  if receipt_is_current "$repo" "$reviewed" wi "$root/core/risk-policy.json"; then
    echo "receipt remained current after $branch mutation" >&2
    exit 1
  fi
done

sed -f "$fixtures/neutral-includes-spec.sed" "$root/core/risk-policy.json" \
  >"$tmp/neutral-includes-spec.json"
git -C "$repo" checkout -q spec
if ! receipt_is_current "$repo" "$reviewed" wi "$tmp/neutral-includes-spec.json"; then
  echo 'receipt policy mutation was not behaviorally exercised: neutral-includes-spec' >&2
  exit 1
fi

# Even a mutated leaf policy cannot make a path outside the reviewed work item
# neutral; the path-scope rule is an independent part of the Interface.
sed -f "$fixtures/neutral-includes-config.sed" "$root/core/risk-policy.json" \
  >"$tmp/neutral-includes-config.json"
git -C "$repo" checkout -q config
if receipt_is_current "$repo" "$reviewed" wi "$tmp/neutral-includes-config.json"; then
  echo 'receipt policy escaped the reviewed work-item path scope' >&2
  exit 1
fi

echo 'review receipt ok: authenticated resolver binding, lower-tier local fallback, rename-safe field-level currency'
