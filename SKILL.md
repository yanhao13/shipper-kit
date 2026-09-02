---
name: grill-me
description: Interview a vague feature idea into a complete written spec.md, with no open questions left for the loop to guess at.
---

# /grill-me

Usage: `/grill-me <one-sentence feature idea>`

## What to do

Interview the person before writing anything. Ask questions one or a few
at a time, not all at once. Cover, at minimum:

- **Problem**: what is broken or missing today, and for whom?
- **Happy path**: the single core flow, in plain steps.
- **Edge cases**: empty states, zero-data states, error states, what
  happens on double-submit or partial failure.
- **Non-goals**: what this explicitly does NOT do in v1.
- **Success**: one measurable signal that tells you it worked.

Push on vague answers. "Make it feel nice" is not an answer — ask what
specifically would make someone notice it feels nice, or ask for a
reference. "Handle errors gracefully" is not an answer — ask what the
user sees on each specific error.

Every decision skipped now becomes a `RALPH: NEEDS HUMAN` at 2am, so it's
worth the extra round of questions.

## When the interview is done

Write `spec.md` at the repo root with this shape:

```markdown
# PRD: <feature name>

## Problem
<1-3 sentences>

## Feature
<what gets built, in plain language>

## Requirements
1. ...
2. ...

## Non-goals
<explicitly out of scope for v1>

## Success
<one measurable signal>
```

Hand off with: "Spec written to spec.md. Run `/prd-to-backlog spec.md`
to slice it into a backlog."
