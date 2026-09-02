---
name: ship
description: The definition of done for any unit of work in this repo. Use for every task, whether typed by a human or picked by the loop.
---

# /ship

A task is shipped when this whole list has run clean, not before.

1. **Understand.** Read the relevant code before writing any. If the task
   is ambiguous, say what you assumed.
2. **Red-green-refactor**, for backend logic. Write the failing test
   first and run it to prove it fails. Then the minimal implementation to
   green. Then refactor with the suite as a net.
3. **Visual check**, for UI. Implement, then verify visually: screenshot
   or manual check against the requirement.
4. **Typecheck.** `<FILL_IN: e.g. npm run typecheck>` — fix until clean.
5. **Tests.** `<FILL_IN: e.g. npm test>` — fix until green. Never skip,
   stub out, or delete a failing test to get there; fix the cause.
6. **Commit.** A message that says why, not just what. One coherent
   change per commit.

If after 3 attempts something still fails, stop and report what you
tried rather than thrashing.

## Why each step is there

- Understand-first prevents the most expensive failure: confidently
  building the wrong thing.
- Red-before-green proves the test actually detects the problem; a test
  written after the code often passes vacuously.
- The 3-attempts limit converts a silent overnight burn into a readable,
  reportable failure.

## Make it yours

Replace the `<FILL_IN>` placeholders with your repo's real commands
(from `npm run` / `pyright` / `pytest` / whatever your Module 1 gate
audit settled on). If your project has no backend logic, delete step 2
rather than let the agent improvise around it. The stations are the
contract; the commands are yours.
