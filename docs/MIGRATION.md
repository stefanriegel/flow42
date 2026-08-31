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
