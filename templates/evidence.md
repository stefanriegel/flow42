# Evidence: {{title}}

Record timestamp, command/check, environment, expected result, actual result,
and evidence pointer. For behavior changes record the observed red and green.

## Independent review receipt

Persist one fenced JSON block per review. `issuer_kind` is the strongest
available of `authenticated-forge`, `trusted-orchestrator`, and
`local-independent-pass`; the local fallback records why stronger provenance was
unavailable and still represents a distinct non-implementing pass.

```json
{"schema_version":1,"issuer_kind":"{{issuer_kind}}","issuer_receipt_ref":"{{issuer_receipt_ref}}","reviewer_principal":"{{reviewer_principal}}","reviewer_role":"independent-reviewer","dispatch_or_session_ref":"{{dispatch_or_session_ref}}","stronger_issuer_unavailable_reason":"{{reason_or_not_applicable}}","implementer":false,"reviewed_head":"{{reviewed_head}}","verdict":"{{pass_or_blocked}}","checks":["{{check}}"],"artifact_ref":"{{artifact_ref}}","recorded_at":"{{timestamp}}"}
```

The receipt remains current after committing changes only to this work item's
`evidence.md`, `decisions.md`, `history.jsonl`, or `status.yml`. Every other path
change requires a fresh independent review.

## Known gaps
