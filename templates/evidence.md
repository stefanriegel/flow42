# Evidence: {{title}}

Record timestamp, command/check, environment, expected result, actual result,
and evidence pointer. For behavior changes record the observed red and green.

## Independent review receipt

Persist one fenced JSON block per review. `issuer_kind` is the strongest
available of `authenticated-forge`, `trusted-orchestrator`, and
`local-independent-pass`. Resolve every receipt independently. Forge and
orchestrator results require authenticated exact binding; the explicitly
lower-tier local fallback requires a resolver-observed distinct local session,
`authenticated: false`, and exact binding of the same subject, purpose, checks,
artifact, verdict, and locally observed time. A self-authored local receipt or
unresolvable session never satisfies the gate.

The caller declares `review_kind` and the canonical ordered required-check
array before review; that array must contain every policy minimum for its kind.
Use `correctness` for independent verification and a separate `security`
receipt when the risk policy requires security review. Persist the exact report
bytes as a named section of this work item's `evidence.md`, use an
`evidence:.flow42/<work-id>/evidence.md#<section-id>` reference, and hash only
the exact LF-terminated bytes strictly between one ordered pair of these literal
marker lines. Derive the evidence path from the canonical repository/work
identity; never accept a caller-selected substitute file, link, duplicate or
missing marker, traversal, or invalid section ID.

```text
<!-- flow42-review-section:{{section_id}}:begin -->
{{exact_review_report}}
<!-- flow42-review-section:{{section_id}}:end -->
```

Do not accept purpose substitution, a spellcheck-only
or other partial check list, traversal/out-of-work-item references, an unrelated
artifact, an impossible UTC calendar value, or a resolver timestamp mismatch.
Schema-version 1 receipts must be replaced by a fresh independent review and a
version 2 receipt.

```json
{"schema_version":2,"review_kind":"{{correctness_or_security}}","issuer_kind":"{{issuer_kind}}","issuer_receipt_ref":"{{issuer_receipt_ref}}","repository_id":"{{normalized_origin_repository}}","work_id":"{{work_id}}","baseline_head":"{{baseline_head}}","reviewed_head":"{{reviewed_head}}","scope_digest":"sha256:{{canonical_scope_digest}}","diff_digest":"sha256:{{no_renames_diff_digest}}","review_subject":"{{expected_subject}}","reviewer_principal":"{{reviewer_principal}}","reviewer_role":"independent-reviewer","dispatch_or_session_ref":"{{dispatch_or_session_ref}}","stronger_issuer_unavailable_reason":"{{reason_or_not_applicable}}","implementer":false,"verdict":"{{pass_or_blocked}}","checks":{{canonical_required_checks_json}},"artifact_ref":"evidence:.flow42/{{work_id}}/evidence.md#{{section_id}}","artifact_digest":"sha256:{{exact_section_bytes_digest}}","recorded_at":"{{issuer_or_resolver_observed_utc_timestamp}}"}
```

The receipt remains current after committing exact receipt-neutral leaves in
this work item. For `status.yml`, only `stage`, `state_revision`, `updated_at`,
`blockers`, `resume_stage`, `ci_state`, and `next_actions` are
neutral. Keep the schema-compatible `change_request` field empty and record the
redacted canonical PR or MR observation in this receipt-neutral evidence file.
`forge_item` and every other non-neutral field must already be correct at review.
Renames,
nested lookalikes, non-ancestor heads, and every other field or path change
require fresh independent review. Duplicate, missing, or unknown
top-level status keys fail closed. A `decisions.md` change does not
authenticate human confirmation.

## Forge observation (non-authoritative)

Record provider, normalized repository, request ID, redacted canonical PR or MR
URL, source branch, pushed and reviewed heads, valid UTC observation time, and
the authenticated CLI command that returned them. This persisted text is an
audit observation, never authority: before acting, query the Forge again and
require every field to match the live authenticated readback. Do not copy the
URL into `status.yml.change_request`.

## Known gaps
