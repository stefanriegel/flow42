---
name: intent
description: Capture a work request as an explicit Flow42 intent. Use for new products, features, bugs, refactors, and maintenance findings.
---

# Capture Intent

Create a lowercase work ID matching `^[a-z0-9][a-z0-9-]{0,62}$`; reject unsafe or colliding paths. Create
`.flow42/<work-id>/` from every work-item template using native harness file operations, including the revision-1
creation event in `history.jsonl`. Fill `intent.md` with the problem, desired outcome, users, constraints,
non-goals, acceptance signals, assumptions, and risks.

Inspect the repository and existing work items before asking, and research public facts when useful. Build a
dependency-ordered decision tree only from unresolved branches whose answer can materially change outcome, risk,
confidentiality, or cost. Apply that materiality gate relentlessly, resolving parents before dependants and asking
one question at a time; answer discoverable questions by inspection and record the evidence instead of asking.

When inspection shows a bounded, reversible change with unambiguous outcome, constraints, acceptance signal, and
material risks, use the trivial-change fast path: ask no questions and complete the intent directly. Do not use it
for auth, permissions, sensitive data, money, production, infrastructure, migrations, or another material branch.

State each decision neutrally and explain why it is material. Present a recommended answer separately with its
basis and credible alternatives and tradeoffs on equal footing. The recommended answer is non-binding; explicitly
ask the user to answer. Never treat silence, lack of objection, or the recommendation itself as consent. Treat “you
decide” only as delegation for the named reversible intent choice; record its scope and never use it as high-risk or
irreversible authorization.

After each answer, atomically update and reread `intent.md`, synthesizing current facts and resolved boundaries as
the single durable source rather than an interview transcript. Give each unresolved material question a stable identifier and record its
material consequence and dependencies in `intent.md`. Append a resolved consequential choice to `decisions.md`
with context, options, decision, rationale, consequences, actor, and UTC timestamp; keep factual answers only in
the intent synthesis. Keep mutable lifecycle state only in `status.yml`; refer to question identifiers instead of
copying question text into blockers or next actions. Ensure `history.jsonl` records transitions rather than
interview content.

Apply this objective stop condition after initial inspection and every answer: stop interviewing only when every
required intent section is evidence-backed and no unresolved question can materially change outcome, risk,
confidentiality, or cost. Record remaining non-material uncertainty as an assumption or risk. Never advance because
a question budget expired or the user wants to skip a material decision.

If a headless or automated run lacks an interactive answer channel, or an answer is unavailable, persist known
unresolved material questions and mark the first dependency-ordered identifier in `intent.md`; do not choose the
recommendation, infer an answer, or advance. Atomically transition to `blocked` with `resume_stage: draft-intent`,
put only that identifier in the status blocker and next action, increment the revision, append a history transition
referencing it, and reread both. With no material question remaining, complete the intent normally.

On `/flow42:resume`, validate artifacts, reconstruct only from them, and resume from the first unresolved material
question in dependency order. If status is blocked for that question, ask and durably record its answer before
clearing the blocker and transitioning back to `draft-intent`. If status remains `draft-intent` after an interruption,
ask it directly. Remove the unresolved entry only after its answer is durable, then reapply the materiality gate and stop condition.

Apply data minimization before every search, question, and write. Ask at the highest useful abstraction and prefer
redacted schemas, categories, or fixtures. Never request or persist secrets, credentials, private records, or raw
personal or customer data; if supplied, do not reproduce it and retain only the minimum non-sensitive constraint.
Treat the confidentiality boundary as material without fishing for protected content.

Reread the completed artifact before advancing; intent capture has no gate before specification, and unresolved
material questions prevent completion. When complete, transition directly from `draft-intent` to `drafting-spec` by
incrementing the revision, atomically updating status, appending history, and rereading both.
