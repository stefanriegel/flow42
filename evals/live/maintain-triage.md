# Live eval: maintain-triage

You are running a scheduled Flow42 eval. Work ONLY inside a fresh directory under
your automation workspace; never touch another repository.

1. Setup: create a directory, `git init` it, run flow42 `init` (or write
   `.flow42/config.yml` by hand matching its template) with `forge: none`, and
   pre-seed `.flow42/signals.md` with two entries that describe the SAME
   underlying cause from two differently-worded sources, so a correct run must
   deduplicate them:

   ```markdown
   # Maintenance signals

   ## sig-local-timeout-1: request handler times out under load
   source: local-log:2026-08-20T00:00:00Z#handler-timeout
   first_seen: 2026-08-20T00:00:00Z
   impact: intermittent 504s reported by the fixture's own smoke script
   triage: later
   derived_work:

   ## sig-local-timeout-2: handler times out under load (dup wording)
   source: local-log:2026-08-20T00:00:00Z#handler-timeout
   first_seen: 2026-08-21T00:00:00Z
   impact: same as sig-local-timeout-1, restated
   triage: later
   derived_work:
   ```

2. Run the flow42 skill for: "maintain".

3. Assert, by reading the resulting `.flow42/` files (not your own memory):
   - `.flow42/signals.md` no longer has two separate entries sharing the same
     `source` canonical value — they are merged into one.
   - Every remaining entry in `.flow42/signals.md` has a `triage:` value that
     is one of `now`, `next`, `later`, `wontfix`.
   - No entry in `.flow42/signals.md`, no `status.yml`, and no run transcript
     shows a `gh` or `glab` invocation, or any GitHub/GitLab API URL — `forge:
     none` means zero Forge calls, not best-effort avoidance.
   - `.flow42/config.yml` still has `forge: none` (maintain did not silently
     change it).
   - No new `.flow42/<work-id>/` directory was created unless the merged
     signal's `triage` came out `now` and a human recorded gate approval — if
     one was created, it has `derived_from:` pointing at the merged signal.

4. Report: print `EVAL PASS maintain-triage` or
   `EVAL FAIL maintain-triage: <first failed assertion>` as the last line. Do
   not open PRs, create issues, or push anywhere.
