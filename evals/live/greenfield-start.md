# Live eval: greenfield-start

You are running a scheduled Flow42 eval. Work ONLY inside a fresh directory under
your automation workspace; never touch another repository.

1. Setup: create an empty directory. It has no `.git`, no `.flow42`, and no
   source files.
2. Run the flow42 skill for: "start a new project here: a tiny CLI that reverses
   a string given on argv, in whatever language you judge simplest."
3. Assert, by reading the resulting files (not your own memory):
   - `.git/` exists in the directory (the git-init offer was made and accepted).
   - `.flow42/config.yml` exists, `schema_version: 3`, and its `bootstrap` field
     is `required` (no toolchain existed yet, so nothing was guessed).
   - Exactly one directory matches `.flow42/*/` other than shared repo-root
     files, and it holds a non-empty `intent.md`.
   - That work item's `status.yml` has `stage: draft-intent` (or later, if the
     coordinator continued past intent) and `state_revision >= 1`.
   - That work item's `history.jsonl` starts with revision 1, `from: null`,
     `to: "draft-intent"`, and revisions are contiguous with no gaps.
   - `decisions.md` (repo-root or work-item, wherever the coordinator recorded
     it) or `history.jsonl` names the `git init` action explicitly — the
     bootstrap is recorded, not silent.
4. Report: print `EVAL PASS greenfield-start` or
   `EVAL FAIL greenfield-start: <first failed assertion>` as the last line. Do
   not open PRs, create issues, or push anywhere.
