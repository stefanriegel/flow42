# Evidence: {{title}}

Record timestamp, command/check, environment, expected result, actual result,
and evidence pointer. For behavior changes record the observed red and green.

## Independent review receipt

Persist one fenced JSON block per review. `issuer_kind` is the strongest
available of `authenticated-forge`, `trusted-orchestrator`, and
`local-independent-pass`. Resolve Forge and orchestrator receipts independently
and require authenticated exact binding to the receipt. The explicitly
lower-tier local fallback records why stronger provenance was unavailable and
still represents a distinct non-implementing pass.

```json
{"schema_version":1,"issuer_kind":"{{issuer_kind}}","issuer_receipt_ref":"{{issuer_receipt_ref}}","repository_id":"{{normalized_origin_repository}}","work_id":"{{work_id}}","baseline_head":"{{baseline_head}}","reviewed_head":"{{reviewed_head}}","scope_digest":"sha256:{{canonical_scope_digest}}","diff_digest":"sha256:{{no_renames_diff_digest}}","review_subject":"{{expected_subject}}","reviewer_principal":"{{reviewer_principal}}","reviewer_role":"independent-reviewer","dispatch_or_session_ref":"{{dispatch_or_session_ref}}","stronger_issuer_unavailable_reason":"{{reason_or_not_applicable}}","implementer":false,"verdict":"{{pass_or_blocked}}","checks":["{{check}}"],"artifact_ref":"{{artifact_ref}}","artifact_digest":"sha256:{{artifact_content_digest}}","recorded_at":"{{timestamp}}"}
```

The receipt remains current after committing exact receipt-neutral leaves in
this work item. For `status.yml`, only `stage`, `state_revision`, `updated_at`,
`blockers`, `resume_stage`, `ci_state`, `next_actions`, `forge_item`, and a
grammar-valid `change_request` are neutral. Renames, nested lookalikes,
non-ancestor heads, and every other field or
path change require fresh independent review. Duplicate, missing, or unknown
top-level status keys fail closed. A `decisions.md` change does not
authenticate human confirmation.

## Known gaps
