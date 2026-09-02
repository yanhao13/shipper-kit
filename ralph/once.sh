#!/usr/bin/env bash
# One supervised iteration — the HITL warm-up stage before trusting loop.sh
# to run unattended. Watch every line of output.
set -euo pipefail

RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT_FILE="$RALPH_DIR/prompt.md"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "once: no prompt.md found next to once.sh. Aborting." >&2
  exit 1
fi

claude -p "$(cat "$PROMPT_FILE")"

echo
echo "--- last 3 commits ---"
git log -3 --oneline
