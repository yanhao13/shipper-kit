#!/usr/bin/env bash
# Ralph: AFK loop with iteration cap, circuit breaker, and stop conditions.
#
# SAFETY: run this inside a sandbox (Docker/devcontainer) only. Never with
# bypass permissions on your raw machine. See README.md prereqs first.
#
# Usage: ./loop.sh [max_iterations]   (default 5)
# Stop early any time with: touch .ralph-stop
set -euo pipefail

MAX_ITERATIONS="${1:-5}"
RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$RALPH_DIR/prompt.md"
STOP_FILE=".ralph-stop"
LOG_DIR=".ralph-logs"

# Optional: set NTFY (e.g. ntfy.sh/your-long-random-topic) or SLACK_WEBHOOK_URL
# as env vars before running to get a notification on every exit path.
notify() {
  local msg="$1"
  if [ -n "${NTFY:-}" ]; then
    curl -s -d "ralph: $msg" "$NTFY" >/dev/null || true
  fi
  if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    curl -s -X POST -H 'Content-type: application/json' \
      -d "{\"text\":\"ralph: $msg\"}" "$SLACK_WEBHOOK_URL" >/dev/null || true
  fi
}
trap 'notify "exited: $(git log --oneline -1 2>/dev/null || echo "no commits")"' EXIT

if [ ! -f "$PROMPT_FILE" ]; then
  echo "ralph: no prompt.md found next to loop.sh. Aborting." >&2
  exit 1
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ralph: not inside a git repo. Aborting." >&2
  exit 1
fi

mkdir -p "$LOG_DIR"
rm -f "$STOP_FILE"

RUN_LOG="$LOG_DIR/run.log"
echo "=== run start $(date '+%Y-%m-%d %H:%M') cap=$MAX_ITERATIONS ===" >>"$RUN_LOG"

FAILS=0

for i in $(seq 1 "$MAX_ITERATIONS"); do
  if [ -f "$STOP_FILE" ]; then
    echo "ralph: stop file found, exiting after $((i-1)) iteration(s)."
    rm -f "$STOP_FILE"
    exit 0
  fi

  LOG="$LOG_DIR/iteration-$(date +%Y%m%d-%H%M%S)-$i.log"

  # Each iteration is a fresh session; commits and issue comments carry the memory.
  if ! claude -p "$(cat "$PROMPT_FILE")" >"$LOG" 2>&1; then
    FAILS=$((FAILS+1))
    echo "ralph: iteration $i exited nonzero ($FAILS in a row). See $LOG" >&2
    if [ "$FAILS" -ge 2 ]; then
      echo "ralph: circuit breaker tripped after $FAILS consecutive failures. Stopping." >&2
      notify "breaker tripped: $FAILS consecutive failures, see $LOG"
      exit 1
    fi
    continue
  fi
  FAILS=0

  SIGNAL=$(grep -o "RALPH: [A-Z ]*" "$LOG" | tail -1 || true)
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "no commits yet")
  echo "$(date '+%H:%M') iter $i/$MAX_ITERATIONS ${SIGNAL:-ok} | $LAST_COMMIT" >>"$RUN_LOG"

  if grep -q "RALPH: BACKLOG EMPTY" "$LOG"; then
    echo "ralph: backlog empty after $i iteration(s). Done."
    exit 0
  fi
  if grep -q "RALPH: NEEDS HUMAN" "$LOG"; then
    echo "ralph: iteration $i needs a human. Stopping. See $LOG"
    exit 0
  fi
  if grep -q "RALPH: BLOCKED" "$LOG"; then
    echo "ralph: iteration $i blocked after retries. Stopping. See $LOG"
    exit 1
  fi
done

echo "ralph: hit the $MAX_ITERATIONS-iteration cap. QA the commits before raising it."
