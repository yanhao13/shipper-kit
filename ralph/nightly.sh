#!/usr/bin/env bash
# One scheduled run of the ralph loop, inside the agent-box cage.
# Wired to by cron or launchd — keep the scheduler entry dumb, edit this file.
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"   # schedulers start with a bare PATH; docker lives here

cd "$(dirname "$0")/.."   # repo root

if ! docker info >/dev/null 2>&1; then
  echo "nightly: docker is not running. Aborting." >&2
  # Notify even though loop.sh's own trap never got to run.
  if [ -n "${NTFY:-}" ]; then
    curl -s -d "ralph: nightly run aborted — docker not running" "$NTFY" >/dev/null || true
  fi
  exit 1
fi

docker run --rm --env-file .env -v "$PWD":/workspace agent-box \
  bash ralph/loop.sh "${1:-5}"
