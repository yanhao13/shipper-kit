---
name: prd-to-backlog
description: Convert a PRD or feature spec into a sliced, labeled, dependency-ordered GitHub issue backlog the loop can run against.
---

# /prd-to-backlog

Usage: `/prd-to-backlog <path-to-spec.md>`

## What to do

1. Ensure labels exist: `gh label create afk --color 0E8A16 --force` and
   `gh label create hitl --color FFA500 --force`.
2. Read the spec. Slice it into **vertical** tracer-bullet issues, never
   horizontal ones:
   - Issue #1 is the thinnest end-to-end slice of the whole feature:
     simplest data, one happy path, but it crosses every layer it
     touches and it works when closed.
   - Every later issue thickens a working system — more cases, more
     polish, more edge handling — always on top of something that runs.
   - Reject horizontal slices ("set up the database", "configure the
     client"). Fold that work into the vertical slice that needs it.
3. For each issue, write a body with exactly four parts:
   - **Goal**: one line.
   - **Spec section**: which part of the PRD this implements.
   - **Acceptance criteria**: a checklist. Every box must be
     machine-verifiable (a test, a typecheck, a screenshot diff against
     a mock) if the issue is labeled `afk`.
   - **Verify**: the exact command or check that proves it.
4. Encode order with `Blocked by #N` in the body — never with numbering
   in titles. Do not create issues in a way that requires renumbering
   later.
5. Label every issue `afk` or `hitl` at creation time. Default to `hitl`
   when unsure — spec-writing, architecture, public naming, migrations,
   deploys, and anything described with feel-words ("should feel",
   "nicer", "cleaner") are `hitl`.
6. Always file one final issue, labeled `hitl`:
   **"QA pass: use the product like a user. File every flaw as a new
   issue."**
7. Report the full list with the dependency chain before finishing.

## The five review questions (run these yourself before trusting the output)

1. Is #1 truly end to end?
2. Is anything horizontal that should be folded into a vertical slice?
3. Does any issue exceed one focused agent session? Split it.
4. Does every `afk` issue have machine-checkable acceptance? If an
   acceptance line reads like a feeling, relabel `hitl`.
5. Is the final QA issue present and labeled `hitl`?
