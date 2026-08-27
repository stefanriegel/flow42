---
name: pr
description: Open or update an idempotent GitHub PR or GitLab MR for a verified Flow42 work item and observe CI. Use after verification passes.
---

# Prepare PR or MR

Detect provider from explicit remotes. Preflight authenticated `gh` or `glab`;
do not manage tokens or implement an API client. Search for an existing linked
PR/MR before creating one. Include work ID, artifact links/hashes, verification
evidence, risks, rollback, and limitations. Observe required CI and address
in-scope findings. Stop when the PR/MR is reviewed and CI-green. Never merge or
deploy without explicit approval.
