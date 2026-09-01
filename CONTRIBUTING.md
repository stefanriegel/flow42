# Contributing

Open an issue before large changes. Keep `skills/flow42/` reading cleanly for
both Claude and Codex — no harness-specific tool names or assumptions.

Before sending a change, run everything CI runs:

```bash
for f in tests/*.sh; do sh "$f"; done
shellcheck tests/*.sh
```

That list is the whole CI contract now — see `.github/workflows/ci.yml`.

Do not copy prompts or implementation from reference projects. Cite
high-level inspiration and contribute original wording, schemas, and tests.
