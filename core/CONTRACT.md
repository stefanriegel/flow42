# Flow42 compatibility contract

The canonical workflow is `init → intent → spec → plan → build → verify → pr → maintain`.
Harness adapters may change presentation and native tool calls, but must preserve:

- artifact names and meanings;
- state transitions and approval hashes;
- risk levels and mandatory gates;
- evidence and independent-review requirements;
- destructive-action and secret-handling boundaries.

Generated adapter files carry a `flow42-source` marker. Run `scripts/check-parity.py`
to detect missing commands or semantic drift.
