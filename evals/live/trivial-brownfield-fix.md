# Live eval: trivial-brownfield-fix

You are running a scheduled Flow42 eval. Work ONLY inside a fresh directory under
your automation workspace; never touch another repository.

1. Setup: create a directory, `git init` it, and write these two files exactly,
   then commit them as the initial commit:

   `add.py`:
   ```python
   def add(a, b):
       return a - b
   ```

   `test_add.py`:
   ```python
   from add import add

   def test_add():
       assert add(2, 3) == 5
   ```

   Confirm `python3 -m pytest test_add.py` fails before doing anything else —
   this is the fixture's one deliberate bug (`-` instead of `+`), and the
   failing test is the fixture, not something to fix by hand.

2. Run the flow42 skill for: "fix the bug in add.py; test_add.py should pass."

3. Assert, by reading the resulting `.flow42/` files and the source tree (not
   your own memory):
   - The work item's `status.yml` `risk` is `low` or `medium`.
   - `history.jsonl` contains no event with `to: "plan-gate"` (low/medium risk
     skips the plan gate entirely).
   - `history.jsonl` revisions are contiguous starting at 1, with no
     `blocked -> blocked` self-loop.
   - `evidence.md` records an observed-red result (the failing test, before
     the fix) followed by an observed-green result (the passing test, after).
   - `add.py` now returns `a + b`, and `python3 -m pytest test_add.py` passes.
   - `status.yml` `stage` is `verifying` or later (the item does not stall in
     `building`).

4. Report: print `EVAL PASS trivial-brownfield-fix` or
   `EVAL FAIL trivial-brownfield-fix: <first failed assertion>` as the last
   line. Do not open PRs, create issues, or push anywhere.
