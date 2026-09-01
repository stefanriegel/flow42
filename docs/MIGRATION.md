# Migration

## v2 → v3

V3 is Orca-native and no longer ships as a per-harness marketplace plugin.

1. Uninstall the old marketplace plugin (Claude Code: `claude plugin uninstall
   flow42@flow42` then `claude plugin marketplace remove flow42`; Codex:
   `codex plugin remove flow42@flow42` then `codex plugin marketplace remove
   flow42`). Pi's git-package install is removed the same way it was added.
2. Install V3 through the skills CLI: `npx skills add stefanriegel/flow42
   --skill flow42` (or `orca skills install`). See
   [Installation](INSTALLATION.md).
3. Existing `.flow42/<work-id>/` directories keep working. A schema-1 item is
   read-only legacy: do not hand-edit it into schema 3. Every new work item
   `intent` creates is schema 3.
4. Review evidence is not migrated. V2's receipt schema — the durable JSON
   receipt with issuer tiers, a resolver, and marker-pair digests — is
   deleted; it has no V3 equivalent to convert into. A schema-1 item's
   historical receipts stay in its `evidence.md` as a record of what happened;
   any new review on that item produces a V3 stamp instead (one line: Orca
   run/task/dispatch ref, reviewer agent, review kind, verdict, reviewed SHA,
   UTC time).
5. `status.yml.change_request` is gone. A schema-1 item that still has the
   field keeps it as inert history; nothing reads or writes it going forward.

## Historical: preview runtime → v1 (archival)

Kept for provenance; this predates the receipt schema and the workflow this
document otherwise describes. The preview Python CLI was retired before v1.
Existing pre-v1 `.flow42/<work-id>/` directories were source material, not
silently upgraded: back up the artifacts, add a `history.jsonl`, map the old
stage to the then-current workflow schema, remove obsolete local
authorization metadata while preserving `decisions.md` and `history.jsonl`,
and record the migration decision before resuming.
