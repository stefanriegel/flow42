# Live eval: blocked-resume

You are running a scheduled Flow42 eval. Work ONLY inside a fresh directory under
your automation workspace; never touch another repository.

1. Setup: create a directory, `git init` it, write `.flow42/config.yml`
   matching the flow42 config template (`schema_version: 3`, `forge: none`),
   and pre-seed TWO work items by hand.

   `.flow42/resume-good/status.yml` (valid binding — `resume_stage` equals the
   `from` of the latest transition into `blocked`):
   ```yaml
   schema_version: 3
   work_id: "resume-good"
   title: "fixture: valid blocked binding"
   work_type: "fix"
   stage: blocked
   risk: low
   state_revision: 5
   created_at: "2026-08-20T00:00:00Z"
   updated_at: "2026-08-20T01:00:00Z"
   review_loops: 0
   blockers: ["fixture: waiting on nothing, safe to resume"]
   resume_stage: "building"
   forge_item: ""
   orca_run: ""
   ci_state: unknown
   next_actions: [resume]
   ```

   `.flow42/resume-good/history.jsonl`:
   ```jsonl
   {"revision": 1, "at": "2026-08-20T00:00:00Z", "actor": "fixture", "from": null, "to": "draft-intent", "reason": "work item created"}
   {"revision": 2, "at": "2026-08-20T00:10:00Z", "actor": "fixture", "from": "draft-intent", "to": "drafting-spec", "reason": "intent captured"}
   {"revision": 3, "at": "2026-08-20T00:20:00Z", "actor": "fixture", "from": "drafting-spec", "to": "planning", "reason": "spec drafted"}
   {"revision": 4, "at": "2026-08-20T00:30:00Z", "actor": "fixture", "from": "planning", "to": "building", "reason": "low risk, plan-gate skipped"}
   {"revision": 5, "at": "2026-08-20T01:00:00Z", "actor": "fixture", "from": "building", "to": "blocked", "reason": "fixture: paused for eval"}
   ```

   `.flow42/resume-bad/status.yml` (broken binding — `resume_stage` does NOT
   equal the `from` of the latest transition into `blocked`):
   ```yaml
   schema_version: 3
   work_id: "resume-bad"
   title: "fixture: broken blocked binding"
   work_type: "fix"
   stage: blocked
   risk: low
   state_revision: 5
   created_at: "2026-08-20T00:00:00Z"
   updated_at: "2026-08-20T01:00:00Z"
   review_loops: 0
   blockers: ["fixture: binding deliberately wrong"]
   resume_stage: "building"
   forge_item: ""
   orca_run: ""
   ci_state: unknown
   next_actions: [resume]
   ```

   `.flow42/resume-bad/history.jsonl` (identical to `resume-good` except the
   last transition is FROM `verifying`, not `building`, so `resume_stage:
   "building"` in `status.yml` above no longer matches):
   ```jsonl
   {"revision": 1, "at": "2026-08-20T00:00:00Z", "actor": "fixture", "from": null, "to": "draft-intent", "reason": "work item created"}
   {"revision": 2, "at": "2026-08-20T00:10:00Z", "actor": "fixture", "from": "draft-intent", "to": "drafting-spec", "reason": "intent captured"}
   {"revision": 3, "at": "2026-08-20T00:20:00Z", "actor": "fixture", "from": "drafting-spec", "to": "planning", "reason": "spec drafted"}
   {"revision": 4, "at": "2026-08-20T00:30:00Z", "actor": "fixture", "from": "planning", "to": "verifying", "reason": "fixture shortcut to verifying"}
   {"revision": 5, "at": "2026-08-20T01:00:00Z", "actor": "fixture", "from": "verifying", "to": "blocked", "reason": "fixture: paused for eval"}
   ```

2. Run the flow42 skill for: "resume resume-good", then separately for:
   "resume resume-bad".

3. Assert, by reading the resulting `.flow42/` files (not your own memory):
   - `resume-good`'s `status.yml` `stage` is now `building` (the bound
     stage), `state_revision` is 6, and `history.jsonl` revision 6 has
     `from: "blocked"`, `to: "building"`.
   - `resume-good`'s `blockers` list is cleared (empty) after the resume.
   - `resume-bad`'s `status.yml` `stage` is still `blocked` — the coordinator
     refused to resume on a broken binding.
   - `resume-bad`'s `history.jsonl` has no new revision beyond 5, and no
     event with `from: "blocked", "to": "blocked"` (no self-loop was taken
     to paper over the mismatch).
   - The `resume-bad` run's report names the mismatch (e.g. references
     `state-inconsistency-recorded-with-repair-proposal` or plainly says the
     recorded `resume_stage` does not match history) rather than silently
     doing nothing.

4. Report: print `EVAL PASS blocked-resume` or
   `EVAL FAIL blocked-resume: <first failed assertion>` as the last line. Do
   not open PRs, create issues, or push anywhere.
