---
name: pr
description: Open or update an idempotent GitHub PR or GitLab MR for a verified Flow42 work item and observe CI. Use after verification passes.
---

# Prepare PR or MR

Detect provider from `git remote get-url origin`. For GitHub require `gh auth
status`, find an existing request with `gh pr list --state all --head <branch>
--json number,url,state`, create only when absent with `gh pr create`, inspect
reviews with `gh pr view --json reviewDecision,reviews`, and watch checks with
`gh pr checks --watch`. For GitLab use `glab auth status`, `glab mr list
--source-branch <branch>`, `glab mr create`, `glab mr view`, and `glab ci status`.
Document a CLI-version capability gap instead of guessing. Use the independent
verifier's persisted PASS attestation for the exact Git head SHA, reviewer
identity, and evidence reference; the verifier must not be the implementing
agent. A Forge review may provide additional evidence when available, but do not
create a comment solely to manufacture review provenance.

Use direct argv with validated branch and identifier grammars and `--` before
untrusted positional values where supported. Never interpolate Forge text into a
shell command. Redact remote userinfo and query strings before recording evidence.

Do not manage tokens or implement an API client. Include work ID, artifact
links, evidence, risks, rollback, limitations, and issue closure syntax.
Retries update the found PR/MR and never create duplicates. Stop only at a
reviewed, CI-green PR/MR. Never merge or deploy without explicit approval.

An opened request transitions `pr-ready` to `ci-running`. Only current
independent review for the exact Git head SHA plus green required CI transitions
to `ready-for-human`; the persisted verifier attestation is sufficient for the
independent-review requirement. A failed check
transitions to `blocked` with `resume_stage: ci-running`. Persist each transition
with the canonical revision, atomic status, append-only history, and read-back.
