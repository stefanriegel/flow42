# Contributing

Open an issue before large changes. Keep the canonical contract harness-neutral;
put native behavior in adapters. Behavior changes require a failing test first.
Run:

```bash
sh scripts/check-parity.sh
sh scripts/validate.sh
sh tests/conformance.sh
```

Do not copy prompts or implementation from reference projects. Cite high-level
inspiration and contribute original wording, schemas, code, and tests.
