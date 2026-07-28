#!/usr/bin/env bash
# Daily Shipper Kit installer.
# Usage: ./install.sh [target-repo-path]   (default: current directory)
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"
cd "$TARGET"
TARGET="$(pwd)"

echo "Installing Daily Shipper Kit into $TARGET"

if [ ! -d .git ]; then
  echo "error: $TARGET is not a git repo. Aborting." >&2
  exit 1
fi

# 1. Copy the pieces
mkdir -p ralph .claude/skills .githooks
cp -n "$KIT_DIR"/ralph/*.sh ralph/ 2>/dev/null || true
cp -n "$KIT_DIR"/ralph/prompt.md ralph/ 2>/dev/null || echo "  (ralph/prompt.md already exists, skipped)"
cp -R "$KIT_DIR"/.claude/skills/* .claude/skills/
cp -n "$KIT_DIR"/Dockerfile.agent .
chmod +x ralph/*.sh

# 2. Detect stack and fill gate commands
STACK="unknown"
if [ -f package.json ]; then
  STACK="node"
elif [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  STACK="python"
fi
echo "  detected stack: $STACK"

mkdir -p .githooks
if [ "$STACK" = "node" ]; then
  cat > .githooks/pre-commit <<'EOF'
#!/bin/sh
set -e
echo "gate 1/3: lint"
npx eslint . 2>/dev/null || npx prettier --check . 2>/dev/null || echo "  (no linter found — add one)"
echo "gate 2/3: typecheck"
npm run typecheck --if-present
echo "gate 3/3: tests"
npm test --if-present
echo "all gates green"
EOF
elif [ "$STACK" = "python" ]; then
  cat > .githooks/pre-commit <<'EOF'
#!/bin/sh
set -e
echo "gate 1/3: format"
ruff format --check . 2>/dev/null || echo "  (ruff not found — add it)"
echo "gate 2/3: typecheck"
pyright 2>/dev/null || echo "  (pyright not found — add it)"
echo "gate 3/3: tests"
pytest -q
echo "all gates green"
EOF
else
  cp "$KIT_DIR"/.githooks/pre-commit .githooks/pre-commit
  echo "  unknown stack: edit .githooks/pre-commit and .claude/skills/ship/SKILL.md by hand"
fi
chmod +x .githooks/pre-commit
git config core.hooksPath .githooks

# 3. Fill the ship skill's placeholder commands for known stacks
if [ "$STACK" = "node" ]; then
  sed -i.bak \
    -e 's#<FILL_IN: e.g. npm run typecheck>#npm run typecheck#' \
    -e 's#<FILL_IN: e.g. npm test>#npm test#' \
    .claude/skills/ship/SKILL.md 2>/dev/null && rm -f .claude/skills/ship/SKILL.md.bak
elif [ "$STACK" = "python" ]; then
  sed -i.bak \
    -e 's#<FILL_IN: e.g. npm run typecheck>#pyright#' \
    -e 's#<FILL_IN: e.g. npm test>#pytest -q#' \
    .claude/skills/ship/SKILL.md 2>/dev/null && rm -f .claude/skills/ship/SKILL.md.bak
fi

# 4. Ops docs
[ -f LOOP.md ] || cp "$KIT_DIR"/templates/LOOP.md .
[ -f LEARNINGS.md ] || cp "$KIT_DIR"/templates/LEARNINGS.md .

# 5. .gitignore the secrets file and logs
touch .gitignore
grep -qxF '.env' .gitignore || echo '.env' >> .gitignore
grep -qxF '.ralph-logs/' .gitignore || echo '.ralph-logs/' >> .gitignore
grep -qxF '.ralph-stop' .gitignore || echo '.ralph-stop' >> .gitignore

echo ""
echo "Installed. Next steps:"
echo "  1. Fill any remaining <FILL_IN> spots in .githooks/pre-commit and .claude/skills/ship/SKILL.md"
echo "  2. docker build -f Dockerfile.agent -t agent-box ."
echo "  3. Create .env with ANTHROPIC_API_KEY and a fine-grained GH_TOKEN (see README)"
echo "  4. gh label create afk --color 0E8A16 --force && gh label create hitl --color FFA500 --force"
echo "  5. Seed one small afk issue, then: ./ralph/once.sh"
