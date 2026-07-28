# Daily Shipper Kit

**Ship code while you sleep — safely.**

Daily Shipper Kit turns any repo with tests into an unattended AI dev loop:
a scheduled agent that reads your GitHub backlog, ships the top task
test-first inside a locked-down container, opens a PR, comments its
reasoning, and pings you with a morning report. You wake up, read, merge.

This isn't a single bash script. It's the six things that have to exist
*together* before "unattended" is safe instead of reckless:

| Layer | What it does | Where |
|---|---|---|
| **Gates** | Typecheck/test/lint that fail loudly, enforced at commit time | `.githooks/pre-commit` |
| **Definition of done** | A skill the agent must walk every task through (red‑green‑refactor, then commit) | `.claude/skills/ship` |
| **Cage** | Docker container: the agent's whole world is the repo + 2 scoped secrets | `Dockerfile.agent` |
| **Loop** | A dumb, hardened bash loop: fresh context per task, iteration cap, circuit breaker, kill switch | `ralph/loop.sh` |
| **Backlog** | GitHub issues as the queue; a skill turns a PRD into sliced, labeled, dependency-ordered tasks | `.claude/skills/prd-to-backlog` |
| **Routing** | `afk` vs `hitl` labels so only machine-verifiable work runs unattended | built into the loop prompt |

Nothing here is exotic — it's ~200 lines of bash/markdown that compose into
something a dozen "Ralph loop" gists don't: a system you can actually trust
to run every night without watching it.

## Quickstart (5 minutes)

```bash
curl -fsSL https://raw.githubusercontent.com/yanhao13/daily-shipper-kit/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/yanhao13/daily-shipper-kit.git /tmp/dsk
cd /path/to/your-repo
/tmp/dsk/install.sh .
```

The installer:
1. Copies `ralph/`, `.claude/skills/`, `Dockerfile.agent`, `.githooks/` into your repo
2. Wires `core.hooksPath` to `.githooks`
3. Detects your stack (npm/pnpm/yarn or Python) and fills in real gate commands
4. Creates `LOOP.md` and `LEARNINGS.md` from templates
5. Prints the next 4 commands to run

## What "done" looks like

Five consecutive scheduled runs, at least 3 PRs merged, zero mid-run
interventions, morning report on time every day. See `templates/LOOP.md`
for the exact acceptance criteria and `ralph/nightly.sh` for the scheduler
wiring (cron/launchd).

## Design principles (why this and not a smarter prompt)

- **Steering vs. enforcement.** Anything in a prompt is a suggestion the
  model weighs against everything else in context. Anything with an exit
  code is a wall. Gates and the cage are walls; the prompt is steering on
  top of walls, never instead of them.
- **One task per iteration.** Fresh context, one commit, one PR. Keeps
  every diff small enough to review and every crash cheap to resume.
- **Machine-decidable stop conditions.** The loop never infers "done" —
  it greps for exact strings the agent is instructed to emit.
- **Blast radius before autonomy.** The container's home directory is
  empty. The GitHub token is scoped to one repo. Losing either is an
  annoyance, not an incident.
- **Guardrails one rung behind autonomy, never two.** Scale the schedule
  (rung 2 → 4) only after branch protection, budgets, and a tested kill
  switch are in place.

## Repo layout

```
Dockerfile.agent            # the cage
install.sh                  # one-command installer
ralph/
  loop.sh                   # the loop: cap, breaker, signals, logging, notify
  once.sh                   # single supervised iteration (HITL warm-up)
  nightly.sh                # cron/launchd wrapper
  prompt.md                 # the loop's operating manual (edit this per-repo)
.claude/skills/
  ship/SKILL.md             # definition-of-done: red-green-refactor -> commit
  prd-to-backlog/SKILL.md   # PRD -> sliced, labeled, dependency-ordered issues
  grill-me/SKILL.md         # interview a vague idea into a PRD
.githooks/pre-commit        # the enforcement layer
templates/
  LOOP.md                   # ops doc: sandbox rung, schedule, secrets, criteria
  LEARNINGS.md              # weekly-audit failure log (misfire -> fix, no exceptions)
```

## License

MIT. Use it, fork it, ship your own nights off.
