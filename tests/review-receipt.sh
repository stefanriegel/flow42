#!/bin/sh
# shellcheck disable=SC2016
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
fixtures="$root/tests/fixtures/review-receipt"
resolver="$fixtures/fake-resolver.sh"
expected_head=0123456789abcdef0123456789abcdef01234567
expected_baseline=1111111111111111111111111111111111111111
expected_repository=repo:example/flow42
expected_work_id=wi
expected_subject=flow42-work-item
expected_scope=sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
expected_diff=sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
expected_review_kind=correctness
expected_checks='["acceptance-criteria","baseline-checks","configured-repository-gates","independent-verification"]'
expected_artifact_ref=evidence:.flow42/wi/evidence.md#correctness-review
expected_artifact_repository="$fixtures/artifacts/repository"
security_checks='["threat-model","baseline-checks","configured-repository-security-gates","independent-security-review"]'
security_artifact_ref=evidence:.flow42/wi/evidence.md#security-review
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-receipt.XXXXXX")
trap 'rm -rf "$tmp"' 0 HUP INT TERM

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    hash_line=$(sha256sum "$1") || return 1
  elif command -v shasum >/dev/null 2>&1; then
    hash_line=$(shasum -a 256 "$1") || return 1
  else
    echo RECEIPT-ARTIFACT-HASHER >&2
    return 1
  fi
  hash_value=${hash_line%% *}
  case "$hash_value" in
    *[!0-9a-f]*|'') echo RECEIPT-ARTIFACT-HASHER >&2; return 1 ;;
  esac
  test "${#hash_value}" -eq 64 || {
    echo RECEIPT-ARTIFACT-HASHER >&2
    return 1
  }
  printf '%s\n' "$hash_value"
}

reject_nul_file() {
  byte_input=$1
  byte_without_nul=$2
  LC_ALL=C tr -d '\000' <"$byte_input" >"$byte_without_nul" || return 1
  cmp -s "$byte_input" "$byte_without_nul"
}

extract_review_section() {
  evidence_file=$1
  section_id=$2
  section_output=$3
  begin_marker="<!-- flow42-review-section:$section_id:begin -->"
  end_marker="<!-- flow42-review-section:$section_id:end -->"
  test -f "$evidence_file" && test ! -L "$evidence_file" || return 1
  test "$(find "$evidence_file" -prune -links 1)" = "$evidence_file" || return 1
  reject_nul_file "$evidence_file" "$section_output.nul-check" || return 1
  test "$(grep -F -x -c "$begin_marker" "$evidence_file")" -eq 1 || return 1
  test "$(grep -F -x -c "$end_marker" "$evidence_file")" -eq 1 || return 1
  awk -v begin="$begin_marker" -v end="$end_marker" '
    $0 == begin { active = 1; next }
    $0 == end {
      if (!active) exit 2
      complete = 1
      exit
    }
    active { print }
    END { if (!complete) exit 3 }
  ' "$evidence_file" >"$section_output"
}

validate_utc_timestamp() {
  utc_value=$1
  printf '%s\n' "$utc_value" |
    grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' ||
    return 1
  utc_year=$(printf '%s' "$utc_value" | cut -c 1-4)
  utc_month=$(printf '%s' "$utc_value" | cut -c 6-7)
  utc_day=$(printf '%s' "$utc_value" | cut -c 9-10)
  utc_hour=$(printf '%s' "$utc_value" | cut -c 12-13)
  utc_minute=$(printf '%s' "$utc_value" | cut -c 15-16)
  utc_second=$(printf '%s' "$utc_value" | cut -c 18-19)
  utc_year=$(printf '%s\n' "$utc_year" | sed 's/^0*//; s/^$/0/')
  utc_month=${utc_month#0}; utc_month=${utc_month:-0}
  utc_day=${utc_day#0}; utc_day=${utc_day:-0}
  utc_hour=${utc_hour#0}; utc_hour=${utc_hour:-0}
  utc_minute=${utc_minute#0}; utc_minute=${utc_minute:-0}
  utc_second=${utc_second#0}; utc_second=${utc_second:-0}
  test "$utc_year" -gt 0 && test "$utc_month" -ge 1 &&
    test "$utc_month" -le 12 && test "$utc_hour" -le 23 &&
    test "$utc_minute" -le 59 && test "$utc_second" -le 59 || return 1
  case "$utc_month" in
    1|3|5|7|8|10|12) utc_month_days=31 ;;
    4|6|9|11) utc_month_days=30 ;;
    2)
      utc_month_days=28
      if test $((utc_year % 400)) -eq 0 || {
        test $((utc_year % 4)) -eq 0 && test $((utc_year % 100)) -ne 0;
      }; then
        utc_month_days=29
      fi
      ;;
  esac
  test "$utc_day" -ge 1 && test "$utc_day" -le "$utc_month_days"
}

jq -e '.independent_review.local_fallback_tier == "lower" and
  .independent_review.issuer_resolution.fail_closed == true and
  .independent_review.issuer_resolution.required_for == ["authenticated-forge","trusted-orchestrator","local-independent-pass"] and
  .independent_review.issuer_resolution.resolver_must_be_independent == true and
  .independent_review.receipt_schema_version == 2 and
  .independent_review.receipt_schema_migration == {"from_version":1,"accept_previous":false,"action":"rerun-and-reissue-independent-review"} and
  .independent_review.review_kinds == ["correctness","security"] and
  .independent_review.review_kind_gates == {"correctness":"independent-verification","security":"independent-security-review"} and
  .independent_review.review_kind_minimum_checks == {"correctness":["acceptance-criteria","baseline-checks","configured-repository-gates","independent-verification"],"security":["threat-model","baseline-checks","configured-repository-security-gates","independent-security-review"]} and
  .independent_review.issuer_resolution.resolver_result_schema_version == 2 and
  .independent_review.issuer_resolution.authenticated_issuer_kinds == ["authenticated-forge","trusted-orchestrator"] and
  .independent_review.issuer_resolution.local_fallback_requirements == ["authenticated-false","distinct-session-true","resolver-observed-recorded-at"] and
  .independent_review.issuer_resolution.binding_fields == ["review_kind","issuer_kind","issuer_receipt_ref","repository_id","work_id","baseline_head","reviewed_head","scope_digest","diff_digest","review_subject","reviewer_principal","reviewer_role","dispatch_or_session_ref","implementer","verdict","checks","artifact_ref","artifact_digest","recorded_at"] and
  .independent_review.status_neutral_fields == ["stage","state_revision","updated_at","blockers","resume_stage","ci_state","next_actions"] and
  .independent_review.forge_link_storage == "evidence.md-non-authoritative-observation" and
  .independent_review.forge_link_authority.persisted_observation_is_authority == false and
  .independent_review.status_yaml_subset.duplicate_keys == "reject" and
  .independent_review.status_yaml_subset.quoted_keys == "reject" and
  .independent_review.status_yaml_subset.unknown_keys == "reject" and
  .independent_review.status_yaml_subset.unsupported_constructs == "reject" and
  .independent_review.status_yaml_subset.nul_bytes == "reject-before-parsing" and
  .independent_review.status_yaml_subset.canonicalization == {"quoted_scalar":"unquote-without-escapes","quoted_scalar_escapes":"reject","plain_scalar":"preserve","inline_string_sequence":"remove-insignificant-whitespace","field_order":"status_required_fields","comparison":"canonical-key-value"} and
  .independent_review.status_yaml_subset.required_fields == .independent_review.status_required_fields and
  .independent_review.subject_derivation == {"repository_id":"normalized-origin-remote","work_id":"exact-work-item-directory","baseline_head":"git-rev-parse-verify","reviewed_head":"git-rev-parse-verify","scope_digest":"sha256-canonical-ordered-reviewed-path-set","diff_digest":"sha256-nul-safe-no-renames-baseline-to-head-path-content-diff","review_subject":"caller-expected-subject"} and
  .independent_review.nul_detection == {"applies_to":["evidence-section-extraction","status-yaml-parsing"],"method":"nul-stripped-copy-and-byte-compare","producer_exit_zero_required":true,"reject_before_interpretation":true} and
  .independent_review.review_expectation_derivation == {"review_kind":"caller-required-review-kind","checks":"caller-required-exact-canonical-ordered-check-array-containing-policy-minimums","artifact_ref":"caller-expected-evidence-section-in-exact-work-item","artifact_digest":"sha256-exact-persisted-evidence-section-bytes"} and
  .independent_review.artifact_section_format == {"evidence_path":"repository-root/.flow42/<work-id>/evidence.md","begin_marker":"<!-- flow42-review-section:<section-id>:begin -->","end_marker":"<!-- flow42-review-section:<section-id>:end -->","marker_cardinality":"exactly-one-ordered-pair","digest_bytes":"exact-bytes-strictly-between-marker-lines-with-lf-line-terminators","nul_bytes":"reject-before-marker-extraction","links":"reject"} and
  .independent_review.authenticated_derivation == {"recorded_at":"issuer-authenticated-record-time-or-resolver-observed-distinct-local-session-time"} and
  .independent_review.receipt_required_fields == ["schema_version","review_kind","issuer_kind","issuer_receipt_ref","repository_id","work_id","baseline_head","reviewed_head","scope_digest","diff_digest","review_subject","reviewer_principal","reviewer_role","dispatch_or_session_ref","implementer","verdict","checks","artifact_ref","artifact_digest","recorded_at"] and
  .independent_review.status_yaml_subset.change_request_policy == "reserved-empty-for-schema-compatibility" and
  .independent_review.status_yaml_subset.change_request_pattern == "^$" and
  (.independent_review.status_required_fields | type == "array" and length == 16)' "$root/core/risk-policy.json" >/dev/null || {
  echo RECEIPT-RESOLVER-POLICY >&2
  exit 1
}

validate_receipt() {
  receipt=$1
  reviewed_head=$2
  strongest=$3
  receipt_resolver=$4
  required_checks=$5
  artifact_ref=$6
  artifact_repository=$7
  expected_kind=$8
  artifact_prefix="evidence:.flow42/$expected_work_id/evidence.md#"
  case "$artifact_ref" in
    "$artifact_prefix"*) artifact_section_id=${artifact_ref#"$artifact_prefix"} ;;
    *) echo RECEIPT-ARTIFACT >&2; return 1 ;;
  esac
  if ! printf '%s\n' "$artifact_section_id" |
    grep -Eq '^[a-z0-9][a-z0-9-]{0,62}$'; then
    echo RECEIPT-ARTIFACT >&2
    return 1
  fi
  artifact_flow42_dir="$artifact_repository/.flow42"
  artifact_work_dir="$artifact_flow42_dir/$expected_work_id"
  artifact_path="$artifact_work_dir/evidence.md"
  if ! test -d "$artifact_repository" || test -L "$artifact_repository" ||
    ! test -d "$artifact_flow42_dir" || test -L "$artifact_flow42_dir" ||
    ! test -d "$artifact_work_dir" || test -L "$artifact_work_dir" ||
    ! extract_review_section "$artifact_path" "$artifact_section_id" \
      "$tmp/extracted-review-section"; then
    echo RECEIPT-ARTIFACT >&2
    return 1
  fi
  artifact_digest=sha256:$(sha256_file "$tmp/extracted-review-section") || return 1
  minimum_checks=$(jq -c --arg kind "$expected_kind" \
    '.independent_review.review_kind_minimum_checks[$kind]' \
    "$root/core/risk-policy.json") || return 1
  check() {
    diagnostic=$1
    expression=$2
    if ! jq -e --arg head "$reviewed_head" --arg strongest "$strongest" \
      --arg expected_kind "$expected_kind" \
      --arg artifact_ref "$artifact_ref" --arg artifact_digest "$artifact_digest" \
      --arg expected_work "$expected_work_id" \
      --argjson required_checks "$required_checks" \
      --argjson minimum_checks "$minimum_checks" "$expression" "$receipt" >/dev/null; then
      echo "$diagnostic" >&2
      return 1
    fi
  }
  check RECEIPT-SCHEMA '.schema_version == 2' || return 1
  check RECEIPT-PURPOSE '(.review_kind | IN("correctness", "security")) and .review_kind == $expected_kind' || return 1
  check RECEIPT-ISSUER '.issuer_kind | IN("authenticated-forge", "trusted-orchestrator", "local-independent-pass")' || return 1
  check RECEIPT-PROVENANCE '(.issuer_receipt_ref | type == "string" and length > 0) and (.dispatch_or_session_ref | type == "string" and length > 0) and .issuer_kind == $strongest and (if .issuer_kind == "local-independent-pass" then (.stronger_issuer_unavailable_reason | type == "string" and length > 0) else true end)' || return 1
  check RECEIPT-REVIEWER '(.reviewer_principal | type == "string" and length > 0) and .reviewer_role == "independent-reviewer" and .implementer == false' || return 1
  check RECEIPT-HEAD '(.reviewed_head | type == "string" and test("^[0-9a-f]{40}$")) and .reviewed_head == $head' || return 1
  check RECEIPT-VERDICT '.verdict | IN("pass", "blocked")' || return 1
  check RECEIPT-CHECKS '(.checks | type == "array" and length > 0) and all(.checks[]; type == "string" and length > 0) and .checks == $required_checks and (($minimum_checks - .checks) | length == 0)' || return 1
  check RECEIPT-ARTIFACT '(.artifact_ref | type == "string" and length > 0) and .artifact_ref == $artifact_ref and (.artifact_ref | startswith("evidence:.flow42/" + $expected_work + "/evidence.md#")) and (.artifact_ref | ltrimstr("evidence:.flow42/" + $expected_work + "/evidence.md#") | test("^[a-z0-9][a-z0-9-]{0,62}$")) and (.artifact_digest | type == "string" and test("^sha256:[0-9a-f]{64}$")) and .artifact_digest == $artifact_digest' || return 1
  receipt_recorded_at=$(jq -r '.recorded_at // empty' "$receipt")
  if ! validate_utc_timestamp "$receipt_recorded_at"; then
    echo RECEIPT-TIME >&2
    return 1
  fi
  if ! jq -e --arg repository "$expected_repository" --arg work "$expected_work_id" \
    --arg baseline "$expected_baseline" --arg head "$reviewed_head" --arg scope "$expected_scope" \
    --arg diff "$expected_diff" --arg subject "$expected_subject" '
      .repository_id == $repository and .work_id == $work and
      (.baseline_head | test("^[0-9a-f]{40}$")) and .baseline_head == $baseline and
      .reviewed_head == $head and .scope_digest == $scope and .diff_digest == $diff and
      .review_subject == $subject' "$receipt" >/dev/null; then
    echo RECEIPT-SUBJECT >&2
    return 1
  fi

  issuer=$(jq -r '.issuer_kind' "$receipt")
  reference=$(jq -r '.issuer_receipt_ref' "$receipt")
  if ! resolved=$(sh "$receipt_resolver" "$issuer" "$reference"); then
    echo RECEIPT-RESOLUTION >&2
    return 1
  fi
  if ! printf '%s\n' "$resolved" | jq -e --arg issuer "$issuer" '
    .schema_version == 2 and .resolved == true and .resolver_independent == true and
    (if $issuer == "local-independent-pass"
     then .authenticated == false and .local_distinct_session == true
     else .authenticated == true end)' >/dev/null; then
    echo RECEIPT-RESOLUTION >&2
    return 1
  fi
  if ! jq -e --argjson resolved "$resolved" '
    .review_kind == $resolved.review_kind and
    .issuer_kind == $resolved.issuer_kind and
    .issuer_receipt_ref == $resolved.issuer_receipt_ref and
    .repository_id == $resolved.repository_id and
    .work_id == $resolved.work_id and
    .baseline_head == $resolved.baseline_head and
    .reviewer_principal == $resolved.reviewer_principal and
    .reviewer_role == $resolved.reviewer_role and
    .dispatch_or_session_ref == $resolved.dispatch_or_session_ref and
    .implementer == $resolved.implementer and
    .reviewed_head == $resolved.reviewed_head and
    .scope_digest == $resolved.scope_digest and
    .diff_digest == $resolved.diff_digest and
    .review_subject == $resolved.review_subject and
    .verdict == $resolved.verdict and
    .checks == $resolved.checks and
    .artifact_ref == $resolved.artifact_ref and
    .artifact_digest == $resolved.artifact_digest and
    .recorded_at == $resolved.recorded_at and
    (if .issuer_kind == "local-independent-pass"
     then .stronger_issuer_unavailable_reason == $resolved.stronger_issuer_unavailable_reason
     else true end)' "$receipt" >/dev/null; then
    echo RECEIPT-BINDING >&2
    return 1
  fi
}

validate_receipt "$fixtures/valid-forge.json" "$expected_head" authenticated-forge "$resolver" "$expected_checks" "$expected_artifact_ref" "$expected_artifact_repository" "$expected_review_kind"
validate_receipt "$fixtures/valid-orchestrator.json" "$expected_head" trusted-orchestrator "$resolver" "$expected_checks" "$expected_artifact_ref" "$expected_artifact_repository" "$expected_review_kind"
validate_receipt "$fixtures/valid-local-pass.json" "$expected_head" local-independent-pass "$resolver" "$expected_checks" "$expected_artifact_ref" "$expected_artifact_repository" "$expected_review_kind"
validate_receipt "$fixtures/valid-security-local.json" "$expected_head" local-independent-pass "$resolver" "$security_checks" "$security_artifact_ref" "$expected_artifact_repository" security

artifact_substitution_repository="$tmp/artifact-substitution-repository"
mkdir -p "$artifact_substitution_repository/.flow42/$expected_work_id"
printf '%s\n' 'different persisted evidence bytes' \
  >"$artifact_substitution_repository/.flow42/$expected_work_id/evidence.md"
if validate_receipt "$fixtures/valid-local-pass.json" "$expected_head" \
  local-independent-pass "$resolver" "$expected_checks" \
  "$expected_artifact_ref" "$artifact_substitution_repository" \
  "$expected_review_kind" >/dev/null 2>&1; then
  echo 'review receipt accepted bytes that were not extracted from its evidence reference' >&2
  exit 1
fi

artifact_nul_repository="$tmp/artifact-nul-repository"
artifact_nul_path="$artifact_nul_repository/.flow42/$expected_work_id/evidence.md"
artifact_nul_control="$tmp/artifact-nul-control.md"
mkdir -p "$artifact_nul_repository/.flow42/$expected_work_id"
printf '%s\n' \
  '<!-- flow42-review-section:correctness-review:begin -->' \
  '# Correctness review' \
  '' \
  'The required contract check passed for the reviewed subject.' \
  '<!-- flow42-review-section:correctness-review:end -->' \
  >"$artifact_nul_control"
{
  printf '%s\n' \
    '<!-- flow42-review-section:correctness-review:begin -->' \
    '# Correctness review' \
    ''
  printf 'The required contract check passed for the reviewed subject.\000concealed-bytes\n'
  printf '%s\n' '<!-- flow42-review-section:correctness-review:end -->'
} >"$artifact_nul_path"
test "$(sha256_file "$artifact_nul_control")" != \
  "$(sha256_file "$artifact_nul_path")" || {
  echo 'NUL evidence fixture did not create distinct bytes' >&2
  exit 1
}
extract_review_section "$artifact_nul_control" correctness-review \
  "$tmp/artifact-nul-control-section"
if extract_review_section "$artifact_nul_path" correctness-review \
  "$tmp/artifact-nul-section" >/dev/null 2>&1; then
  echo 'review receipt accepted distinct NUL evidence bytes for digest extraction' >&2
  exit 1
fi

artifact_duplicate_repository="$tmp/artifact-duplicate-repository"
mkdir -p "$artifact_duplicate_repository/.flow42/$expected_work_id"
cp "$expected_artifact_repository/.flow42/$expected_work_id/evidence.md" \
  "$artifact_duplicate_repository/.flow42/$expected_work_id/evidence.md"
printf '%s\n' \
  '<!-- flow42-review-section:correctness-review:begin -->' \
  'duplicate' \
  '<!-- flow42-review-section:correctness-review:end -->' \
  >>"$artifact_duplicate_repository/.flow42/$expected_work_id/evidence.md"
if validate_receipt "$fixtures/valid-local-pass.json" "$expected_head" \
  local-independent-pass "$resolver" "$expected_checks" \
  "$expected_artifact_ref" "$artifact_duplicate_repository" \
  "$expected_review_kind" >/dev/null 2>&1; then
  echo 'review receipt accepted duplicate evidence section markers' >&2
  exit 1
fi

artifact_hardlink_repository="$tmp/artifact-hardlink-repository"
artifact_hardlink_path="$artifact_hardlink_repository/.flow42/$expected_work_id/evidence.md"
mkdir -p "$artifact_hardlink_repository/.flow42/$expected_work_id"
cp "$expected_artifact_repository/.flow42/$expected_work_id/evidence.md" \
  "$artifact_hardlink_path"
validate_receipt "$fixtures/valid-local-pass.json" "$expected_head" \
  local-independent-pass "$resolver" "$expected_checks" \
  "$expected_artifact_ref" "$artifact_hardlink_repository" \
  "$expected_review_kind"
ln "$artifact_hardlink_path" "$artifact_hardlink_repository/evidence-alias.md"
if validate_receipt "$fixtures/valid-local-pass.json" "$expected_head" \
  local-independent-pass "$resolver" "$expected_checks" \
  "$expected_artifact_ref" "$artifact_hardlink_repository" \
  "$expected_review_kind" >/dev/null 2>&1; then
  echo 'review receipt accepted a hardlinked evidence artifact' >&2
  exit 1
fi

for fixture in "$fixtures"/invalid-*.json; do
  name=${fixture##*/}; name=${name%.json}
  strongest=trusted-orchestrator
  review_kind=$expected_review_kind
  required_checks=$expected_checks
  artifact_ref=$expected_artifact_ref
  artifact_repository=$expected_artifact_repository
  case "$name" in
    invalid-issuer) expected=RECEIPT-ISSUER; strongest=self-authored ;;
    invalid-provenance) expected=RECEIPT-PROVENANCE ;;
    invalid-weaker-issuer) expected=RECEIPT-PROVENANCE; strongest=authenticated-forge ;;
    invalid-unresolvable | invalid-unauthenticated) expected=RECEIPT-RESOLUTION ;;
    invalid-self-asserted-local | invalid-local-not-distinct)
      expected=RECEIPT-RESOLUTION
      strongest=local-independent-pass
      ;;
    invalid-resolver-binding) expected=RECEIPT-BINDING; strongest=authenticated-forge ;;
    invalid-recorded-at) expected=RECEIPT-BINDING; strongest=authenticated-forge ;;
    invalid-local-time) expected=RECEIPT-TIME; strongest=local-independent-pass ;;
    invalid-review-kind)
      expected=RECEIPT-PURPOSE
      strongest=local-independent-pass
      review_kind=security
      required_checks=$security_checks
      artifact_ref=$security_artifact_ref
      ;;
    invalid-unrelated-artifact) expected=RECEIPT-ARTIFACT; strongest=local-independent-pass ;;
    invalid-artifact-traversal)
      expected=RECEIPT-ARTIFACT
      strongest=local-independent-pass
      artifact_ref=../../outside-review.md
      ;;
    invalid-reviewer) expected=RECEIPT-REVIEWER ;;
    invalid-head) expected=RECEIPT-HEAD ;;
    invalid-verdict) expected=RECEIPT-VERDICT ;;
    invalid-checks) expected=RECEIPT-CHECKS ;;
    invalid-spellcheck-only) expected=RECEIPT-CHECKS; strongest=local-independent-pass ;;
    invalid-schema-v1) expected=RECEIPT-SCHEMA ;;
    invalid-cross-repository | invalid-cross-work | invalid-cross-scope) expected=RECEIPT-SUBJECT; strongest=local-independent-pass ;;
    *) echo "unknown fixture: $name" >&2; exit 1 ;;
  esac
  log="$tmp/$name.log"
  if validate_receipt "$fixture" "$expected_head" "$strongest" "$resolver" "$required_checks" "$artifact_ref" "$artifact_repository" "$review_kind" >"$log" 2>&1; then
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

validate_receipt_contract() {
  contract=$1
  security=$2
  grep -Fq 'git diff --name-only --no-renames -z "$reviewed_head" HEAD --' "$contract" || { echo RECEIPT-CONTRACT-DIFF >&2; return 1; }
  grep -Fq '`reviewed_head` is an ancestor of or equal to `HEAD`' "$contract" || { echo RECEIPT-CONTRACT-ANCESTRY >&2; return 1; }
  grep -Fq 'exact receipt-neutral leaf in the work item under review' "$contract" || { echo RECEIPT-CONTRACT-PATHS >&2; return 1; }
  grep -Fq 'canonical top-level key set exactly once' "$contract" || { echo RECEIPT-CONTRACT-STATUS >&2; return 1; }
  grep -Fq '`change_request`' "$security" || { echo RECEIPT-CONTRACT-STATUS >&2; return 1; }
  if ! grep -Fq 'reject NUL bytes' "$contract" ||
    ! grep -Fq 'NUL-bearing `change_request` cannot canonicalize as empty' "$contract" ||
    ! grep -Fq 'checked NUL-stripped copy and byte' "$security"; then
    echo RECEIPT-CONTRACT-NUL >&2
    return 1
  fi
  if ! grep -Fq 'Every receipt must' "$contract" ||
    ! grep -Fq 'resolver-observed distinct local session' "$contract"; then
    echo RECEIPT-CONTRACT-LOCAL-RESOLUTION >&2
    return 1
  fi
  if ! grep -Fq 'query the authenticated official CLI' "$contract" ||
    ! grep -Fq 'non-authoritative observation; revalidate live' "$contract"; then
    echo RECEIPT-CONTRACT-FORGE-AUTHORITY >&2
    return 1
  fi
  if ! grep -Fq 'canonical repository identity from normalized `origin`' "$contract" ||
    ! grep -Fq 'the work ID from' "$contract" ||
    ! grep -Fq 'scope digest from the canonical ordered reviewed path set' "$contract" ||
    ! grep -Fq 'diff digest from the NUL-safe no-renames baseline-to-head path/content diff' "$contract" ||
    ! grep -Fq 'artifact digest from the exact bytes of the named review section' "$contract" ||
    ! grep -Fq 'do not accept a caller-selected substitute' "$contract" ||
    ! grep -Fq '<!-- flow42-review-section:<section-id>:begin -->' "$contract" ||
    ! grep -Fq 'exact canonical ordered check array containing every policy minimum' "$contract"; then
    echo RECEIPT-CONTRACT-SUBJECT >&2
    return 1
  fi
}

validate_receipt_contract "$root/core/CONTRACT.md" "$root/core/SECURITY.md"
for mutation in contract-drop-no-renames contract-drop-ancestry contract-widen-neutral-path contract-drop-canonical-status contract-drop-subject-binding contract-weaken-local-resolver contract-trust-persisted-forge; do
  sed -f "$fixtures/$mutation.sed" "$root/core/CONTRACT.md" >"$tmp/$mutation.md"
  case "$mutation" in
    contract-drop-no-renames) expected=RECEIPT-CONTRACT-DIFF ;;
    contract-drop-ancestry) expected=RECEIPT-CONTRACT-ANCESTRY ;;
    contract-widen-neutral-path) expected=RECEIPT-CONTRACT-PATHS ;;
    contract-drop-canonical-status) expected=RECEIPT-CONTRACT-STATUS ;;
    contract-drop-subject-binding) expected=RECEIPT-CONTRACT-SUBJECT ;;
    contract-weaken-local-resolver) expected=RECEIPT-CONTRACT-LOCAL-RESOLUTION ;;
    contract-trust-persisted-forge) expected=RECEIPT-CONTRACT-FORGE-AUTHORITY ;;
  esac
  log="$tmp/$mutation.log"
  if validate_receipt_contract "$tmp/$mutation.md" "$root/core/SECURITY.md" >"$log" 2>&1; then
    echo "receipt contract mutation survived: $mutation" >&2; exit 1
  fi
  grep -Fxq "$expected" "$log"
done

validate_status_yaml() {
  status_file=$1
  policy=$2
  canonical_file=$3
  reject_nul_file "$status_file" "$canonical_file.nul-check" || return 1
  awk '
    function unquote(value) {
      if (value ~ /^"[^"]*"$/) return substr(value, 2, length(value) - 2)
      return value
    }
    function placeholder(value) { return value ~ /^\{\{[a-z_][a-z0-9_]*\}\}$/ }
    /^[[:space:]]*($|#)/ { next }
    /^[[:space:]]/ { exit 10 }
    !/^[a-z][a-z0-9_]*:[[:space:]]*/ { exit 11 }
    {
      key=$0; sub(/:.*/, "", key); if (seen[key]++) exit 13
      value=$0; sub(/^[^:]*:[[:space:]]*/, "", value)
      plain=unquote(value)
      if (value ~ /^"/ && value !~ /^"[^"\\]*"$/) exit 12
      if (plain ~ /(^|[[:space:]])[&*!]/ || plain ~ /<<:/ || plain ~ /^[|>]/ || (plain ~ /[{}]/ && !placeholder(plain))) exit 12
      print key
    }
  ' "$status_file" >"$tmp/status-fields" || return 1
  test "$(sort "$tmp/status-fields")" = "$(jq -r '.independent_review.status_yaml_subset.required_fields[]' "$policy" | sort)" || return 1
  awk '
    function unquote(value) {
      if (value ~ /^"[^"]*"$/) return substr(value, 2, length(value) - 2)
      return value
    }
    function placeholder(value) { return value ~ /^\{\{[a-z_][a-z0-9_]*\}\}$/ }
    /^[[:space:]]*($|#)/ { next }
    {
      key=$0; sub(/:.*/, "", key)
      value=$0; sub(/^[^:]*:[[:space:]]*/, "", value)
      quoted = value ~ /^"/
      if (value ~ /^"/ && value !~ /^"[^"\\]*"$/) exit 12
      if (!quoted && (value ~ /(^|[[:space:]])#/ || value ~ /:[[:space:]]/ ||
          value ~ /^[-?:][[:space:]]/ || value ~ /^[`@]/)) exit 12
      value=unquote(value)
      ok=0
      if (key == "schema_version") ok = value == "1"
      else if (key == "work_id") ok = placeholder(value) || (value ~ /^[a-z0-9][a-z0-9-]*$/ && length(value) <= 63)
      else if (key == "title") ok = placeholder(value) ||
        (length(value) > 0 && value !~ /[&*!]/ &&
         (quoted || value !~ /^[\[\]{},]/))
      else if (key == "work_type") ok = placeholder(value) || value ~ /^[a-z][a-z0-9-]*$/
      else if (key == "stage") ok = value ~ /^[a-z][a-z0-9-]*$/
      else if (key == "risk") ok = value ~ /^(unclassified|low|medium|high|critical)$/
      else if (key == "state_revision" || key == "review_loops") ok = value ~ /^[0-9][0-9]*$/
      else if (key == "created_at" || key == "updated_at") ok = placeholder(value) || value ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]Z$/
      else if (key == "blockers" || key == "next_actions") ok = !quoted &&
        (value == "[]" || value ~ /^\[[a-z0-9][a-z0-9-]*(,[[:space:]]*[a-z0-9][a-z0-9-]*)*\]$/)
      else if (key == "resume_stage") ok = value == "" || value ~ /^[a-z][a-z0-9-]*$/
      else if (key == "forge_item") ok = value == "" || value ~ /^https:\/\/[^?#[:space:]]+$/
      else if (key == "change_request") ok = value == ""
      else if (key == "ci_state") ok = value ~ /^(unknown|pending|running|passed|failed|cancelled)$/
      if (!ok) exit 20
      if (key == "blockers" || key == "next_actions") gsub(/[[:space:]]+/, "", value)
      print key "=" value
    }
  ' "$status_file" >"$canonical_file" || return 1
}

receipt_is_current() {
  repo=$1; reviewed=$2; work_id=$3; policy=$4
  git -C "$repo" merge-base --is-ancestor "$reviewed" HEAD || return 1
  neutral=$(jq -c '.independent_review.receipt_neutral_paths' "$policy")
  diff_paths="$tmp/receipt-current-paths.nul"
  if ! git -C "$repo" diff --name-only --no-renames -z \
    "$reviewed" HEAD -- >"$diff_paths"; then
    return 1
  fi
  if ! jq -Rse --arg prefix ".flow42/$work_id/" --argjson neutral "$neutral" '
      split("\u0000")[:-1] | all(.[];
        . as $path |
        (($path | startswith($prefix)) and
          (($path | ltrimstr($prefix)) as $leaf |
            ($leaf | contains("/")) == false and ($neutral | index($leaf)) != null)))' \
    <"$diff_paths" >/dev/null; then
    return 1
  fi

  status_path=".flow42/$work_id/status.yml"
  if git -C "$repo" diff --quiet "$reviewed" HEAD -- "$status_path"; then
    return 0
  fi
  git -C "$repo" show "$reviewed:$status_path" >"$tmp/status-before.yml" 2>/dev/null || return 1
  git -C "$repo" show "HEAD:$status_path" >"$tmp/status-after.yml" 2>/dev/null || return 1
  validate_status_yaml "$tmp/status-before.yml" "$policy" "$tmp/status-before.canonical" || return 1
  validate_status_yaml "$tmp/status-after.yml" "$policy" "$tmp/status-after.canonical" || return 1
  status_fields=$(jq -r '.independent_review.status_required_fields[]' "$policy")
  allowed_fields=$(jq -r '.independent_review.status_neutral_fields[]' "$policy")
  for field in $status_fields; do
    grep -F "$field=" "$tmp/status-before.canonical" >"$tmp/status-before-field"
    grep -F "$field=" "$tmp/status-after.canonical" >"$tmp/status-after-field"
    if ! cmp -s "$tmp/status-before-field" "$tmp/status-after-field" &&
      ! printf '%s\n' "$allowed_fields" | grep -Fxq "$field"; then
      return 1
    fi
  done
}

validate_status_yaml "$root/templates/status.yml" "$root/core/risk-policy.json" "$tmp/template-status.canonical"
for current_status in "$root"/.flow42/*/status.yml; do
  test -f "$current_status" || continue
  validate_status_yaml "$current_status" "$root/core/risk-policy.json" "$tmp/current-status.canonical"
done

while IFS= read -r status_line; do
  case "$status_line" in
    'change_request: ""') printf 'change_request: \000\n' ;;
    *) printf '%s\n' "$status_line" ;;
  esac
done <"$root/templates/status.yml" >"$tmp/status-nul-change-request.yml"
if validate_status_yaml "$tmp/status-nul-change-request.yml" \
  "$root/core/risk-policy.json" "$tmp/status-nul-change-request.canonical"; then
  echo 'status YAML accepted NUL change_request as canonical empty' >&2
  exit 1
fi

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

git -C "$repo" checkout -q -b status-forge-item-case "$reviewed"
sed 's|^forge_item: ""$|forge_item: "https://attacker.example/unrelated/issues/42"|' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-forge-item.yml"
mv "$tmp/status-forge-item.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-forge-item
git -C "$repo" branch status-forge-item

git -C "$repo" checkout -q -b status-inline-map-case "$reviewed"
sed 's/^blockers: \[\]$/blockers: [a: b]/' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-inline-map.yml"
mv "$tmp/status-inline-map.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-inline-map
git -C "$repo" branch status-inline-map

git -C "$repo" checkout -q -b status-quoted-list-case "$reviewed"
sed 's/^blockers: \[\]$/blockers: "[]"/' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-quoted-list.yml"
mv "$tmp/status-quoted-list.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-quoted-list
git -C "$repo" branch status-quoted-list

git -C "$repo" checkout -q -b status-change-request-case "$reviewed"
sed 's|^change_request: ""$|change_request: https://github.com/example/flow42/pull/42|' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-change-request.yml"
mv "$tmp/status-change-request.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-change-request
git -C "$repo" branch status-change-request

git -C "$repo" checkout -q -b status-nested-change-request-case "$reviewed"
sed 's|^change_request: ""$|change_request: https://gitlab.example.invalid/group/subgroup/flow42/-/merge_requests/42|' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-nested-change-request.yml"
mv "$tmp/status-nested-change-request.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-nested-change-request
git -C "$repo" branch status-nested-change-request

git -C "$repo" checkout -q -b status-unrelated-change-request-case "$reviewed"
sed 's|^change_request: ""$|change_request: https://github.com/attacker/unrelated/pull/42|' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-unrelated-change-request.yml"
mv "$tmp/status-unrelated-change-request.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-unrelated-change-request
git -C "$repo" branch status-unrelated-change-request

git -C "$repo" checkout -q -b status-title-whitespace-case "$reviewed"
sed 's/^title: Fixture$/title: Fix ture/' \
  "$repo/.flow42/wi/status.yml" >"$tmp/status-title-whitespace.yml"
mv "$tmp/status-title-whitespace.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-title-whitespace
git -C "$repo" branch status-title-whitespace

git -C "$repo" show "$reviewed:.flow42/wi/status.yml" |
  sed 's/^title: Fixture$/title: Foo: bar/' \
    >"$tmp/status-invalid-plain-title.yml"
if validate_status_yaml "$tmp/status-invalid-plain-title.yml" \
  "$root/core/risk-policy.json" "$tmp/status-invalid-plain-title.canonical"; then
  echo 'status YAML accepted an invalid plain scalar' >&2
  exit 1
fi

git -C "$repo" checkout -q -b status-canonical-quotes-case "$reviewed"
sed -f "$fixtures/status-canonical-quotes.sed" "$repo/.flow42/wi/status.yml" >"$tmp/status-canonical-quotes.yml"
mv "$tmp/status-canonical-quotes.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-canonical-quotes
git -C "$repo" branch status-canonical-quotes

git -C "$repo" checkout -q -b status-invalid-change-request-case "$reviewed"
sed -f "$fixtures/status-invalid-change-request.sed" "$repo/.flow42/wi/status.yml" >"$tmp/status-invalid-change-request.yml"
mv "$tmp/status-invalid-change-request.yml" "$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-invalid-change-request
git -C "$repo" branch status-invalid-change-request

for mutation in quoted-key anchor lossy-quoted-escape; do
  git -C "$repo" checkout -q -b "status-$mutation-case" "$reviewed"
  sed -f "$fixtures/status-$mutation.sed" "$repo/.flow42/wi/status.yml" >"$tmp/status-$mutation.yml"
  mv "$tmp/status-$mutation.yml" "$repo/.flow42/wi/status.yml"
  git -C "$repo" add . && git -C "$repo" commit -qm "status-$mutation"
  git -C "$repo" branch "status-$mutation"
done

git -C "$repo" checkout -q -b status-unknown-case "$reviewed"
sed -n '1,999p' "$fixtures/status-unknown.append" >>"$repo/.flow42/wi/status.yml"
git -C "$repo" add . && git -C "$repo" commit -qm status-unknown
git -C "$repo" branch status-unknown

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
git -C "$repo" checkout -q status-canonical-quotes
receipt_is_current "$repo" "$reviewed" wi "$root/core/risk-policy.json"
for branch in spec config product root-evidence odd status-risk status-duplicate-risk status-title-whitespace status-quoted-key status-anchor status-lossy-quoted-escape status-unknown status-forge-item status-inline-map status-quoted-list status-change-request status-nested-change-request status-invalid-change-request status-unrelated-change-request nested rename-into-neutral nonancestor; do
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

git -C "$repo" checkout -q -b missing-tree-case "$reviewed"
mkdir -p "$repo/missing-tree"
printf 'unreadable tree\n' >"$repo/missing-tree/product.txt"
git -C "$repo" add . && git -C "$repo" commit -qm missing-tree
missing_tree=$(git -C "$repo" rev-parse 'HEAD:missing-tree')
missing_tree_dir=$(printf '%s\n' "$missing_tree" | cut -c 1-2)
missing_tree_leaf=$(printf '%s\n' "$missing_tree" | cut -c 3-)
missing_tree_object="$repo/.git/objects/$missing_tree_dir/$missing_tree_leaf"
test -f "$missing_tree_object" && test ! -L "$missing_tree_object"
unlink "$missing_tree_object"

git -C "$repo" merge-base --is-ancestor "$reviewed" HEAD || {
  echo 'missing-tree producer fixture lost reviewed-head ancestry' >&2
  exit 1
}
if git -C "$repo" diff --name-only --no-renames -z "$reviewed" HEAD -- \
  >"$tmp/missing-tree.raw" 2>"$tmp/missing-tree.raw.log"; then
  echo 'missing-tree producer fixture did not make raw git diff fail' >&2
  exit 1
fi
neutral=$(jq -c '.independent_review.receipt_neutral_paths' \
  "$root/core/risk-policy.json")
if ! git -C "$repo" diff --name-only --no-renames -z "$reviewed" HEAD -- \
  2>/dev/null |
  jq -Rse --arg prefix '.flow42/wi/' --argjson neutral "$neutral" '
    split("\u0000")[:-1] | all(.[];
      . as $path |
      (($path | startswith($prefix)) and
        (($path | ltrimstr($prefix)) as $leaf |
          ($leaf | contains("/")) == false and ($neutral | index($leaf)) != null)))' \
    >/dev/null; then
  echo 'missing-tree fixture did not reproduce the old POSIX pipeline status' >&2
  exit 1
fi
if receipt_is_current "$repo" "$reviewed" wi "$root/core/risk-policy.json" \
  2>"$tmp/missing-tree.receipt.log"; then
  echo 'receipt remained current after its diff producer lost a required tree' >&2
  exit 1
fi

echo 'review receipt ok: v2 purpose/check/artifact/time binding, strict YAML, evidence-only Forge linkage'
