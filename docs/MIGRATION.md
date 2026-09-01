# Migration from the preview runtime

The preview Python CLI is retired. Existing `.flow42/<work-id>/` directories
remain source material but are not silently upgraded.

1. Commit or back up existing artifacts.
2. Add `history.jsonl` from the V1 templates.
3. Map the old stage to `core/workflow.json` and set `state_revision` to the last
   verified history revision.
4. Remove obsolete local artifact and configuration authorization metadata;
   preserve decisions and history, recording explicit human confirmation for
   any pending high-risk or irreversible action.
5. Record the migration decision and evidence, then resume at the last proven state.

Never fabricate historical events or infer confirmation from legacy metadata.

## Workflow schema 1 to 2

Consumers that read `core/workflow.json` must check `schema_version` before
interpreting it. Schema version 1 exposed one `commands` array; schema version 2
replaces it with `lifecycle_commands` and `maintenance_commands`. Read their
union when enumerating all commands, and retain the category when presenting or
validating lifecycle behavior. Existing `.flow42/<work-id>/` artifacts do not
need rewriting for this schema-only change.

## Configuration: removed approval gates

Configuration schema version 1 no longer accepts `intent`, `spec`, `config`,
`configuration`, or `approval` in `mandatory_gates`. Remove those names from
`.flow42/config.yml`; do not add a replacement gate. Intent and specification
remain validated lifecycle stages, not approval gates. Preserve the four
canonical gates `high-risk-plan`, `irreversible-action`, `merge`, and `deploy`,
plus any intentional project-specific additive gates.

Also add any required fields introduced by `core/config-schema.json`, convert
commands to direct-argv token arrays, and remove or correct command path tokens
that do not exist. Record the migration and its validation result in
`decisions.md`; configuration migration itself needs no approval artifact or
Forge interaction.

## Review receipt schema 1 to 2

Receipt schema version 2 adds caller-required `review_kind`, exact canonical
ordered checks containing the policy minimums, exact in-work-item evidence
section reference and byte digest, and resolver-bound `recorded_at` for every
issuer. The local fallback additionally requires a resolver-observed distinct
session. The evidence file is derived from canonical repository/work identity;
the report is enclosed by one unique ordered literal marker pair, and the digest
covers the LF-terminated bytes strictly between those lines. Version 1 receipts are
not accepted or mechanically rewritten: rerun the independent correctness or
security review against the current exact head and issue a new version 2
receipt. Keep `status.yml.change_request` present but empty; persist provider,
redacted canonical PR/MR URL, request ID, source branch, pushed/reviewed heads,
observation time, and authenticated CLI readback in `evidence.md` only as a
non-authoritative observation that must be revalidated live.
