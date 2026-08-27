# Contributing

Open an issue before large changes. Keep the canonical contract harness-neutral;
put native behavior in adapters. Behavior changes require a failing test first.
Run:

```bash
python3 scripts/check-parity.py
python3 -m unittest discover -s tests -v
python3 scripts/validate.py
```

Do not copy prompts or implementation from reference projects. Cite high-level
inspiration and contribute original wording, schemas, code, and tests.
