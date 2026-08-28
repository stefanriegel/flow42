# Decisions: Ship Flow42 V1

## Runtime-free means no Flow42 executable

- Actor: stefanriegel via Issue #1
- Decision: Skills use native harness file/process operations plus Git and Forge CLIs.
- Consequence: Repository development checks may use shell and `jq`, but the
  installed product owns no executable runtime.

## Unverified claims stay unpublished

- Actor: flow42
- Decision: Installation and parity claims remain qualified until exercised.
- Consequence: Missing evidence blocks release rather than becoming documentation.

## Independent review does not require a second human

- Actor: stefanriegel via Issue #1 private dual-harness evidence
- Decision: A separate non-implementing review pass may publish an exact-head
  SHA-pinned PR/MR comment when no distinct eligible Forge reviewer exists.
- Consequence: One authenticated human remains accountable for gates and
  irreversible actions; agent review evidence cannot fabricate human approval.
