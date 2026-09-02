# LOOP.md — ops doc for this repo's agent loop

## Sandbox
- Rung: 4 (Docker container, repo-only bind mount)
- Why: nightly unattended runs on my machine; the repo is recoverable,
  my home dir is not
- Egress policy: <allow-all (TODO: firewall) | allowlisted via init-firewall.sh>
- Secrets in reach inside the cage: ANTHROPIC_API_KEY + GH_TOKEN (fine-grained,
  one repo, Issues rw / Contents rw / PRs rw) and nothing else

## Schedule
- Rung: <2 (cron/launchd) | 3 (cloud runner) | 4 (managed platform)>
- Cron/plist location: <path>
- Fire time: <e.g. 07:00 local>
- Wake strategy: <pmset wakeorpoweron | fires-on-wake | always-on machine>
- Scheduler logs: <path>

## Secrets calendar
- GH_TOKEN (fine-grained PAT) expires: <date> — rotate by: <date minus 1 week>
- ANTHROPIC_API_KEY rotation date: <date>

## Guardrails checklist
- [ ] Branch protection on main enabled, verified with a rejected direct push
- [ ] Monthly API spend limit set in Anthropic Console
- [ ] Circuit breaker tested (2 consecutive failures trips it)
- [ ] Kill switch tested (`touch .ralph-stop` mid-run, graceful stop timed: ___)

## Acceptance criteria (Daily Shipper)
- [ ] 5 consecutive scheduled runs, no manual starts
- [ ] At least 3 agent PRs merged
- [ ] Zero mid-run human interventions (no .ralph-stop touches, no prompt edits mid-run)
- [ ] Morning report on time, all 5 days

## Weekly audit slot
- Day/time: <e.g. Friday 4pm>
- Last audit: <date> — see LEARNINGS.md for findings
