# Migration from the preview runtime

The preview Python CLI is retired. Existing `.flow42/<work-id>/` directories
remain source material but are not silently upgraded.

1. Commit or back up existing artifacts.
2. Add `approvals.yml` and `history.jsonl` from the V1 templates.
3. Map the old stage to `core/workflow.json` and set `state_revision` to the last
   verified history revision.
4. Recompute every artifact digest. Existing approvals without a named human and
   UTC timestamp are invalid.
5. Record the migration decision and evidence, then resume at the last proven gate.

Never fabricate historical events or translate approval hashes automatically.
