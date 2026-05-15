#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/eximiaco/ai-playbook"
BRANCH="main"

# If running from a local clone, use it; otherwise clone to a temp dir.
if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "/dev/stdin" ]]; then
  SKILLS_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/skills"
else
  TMP=$(mktemp -d)
  trap 'rm -rf "$TMP"' EXIT
  git clone --depth=1 --branch "$BRANCH" "$REPO_URL" "$TMP" --quiet
  SKILLS_SRC="$TMP/claude-code/skills"
fi

# Default: global. Pass "." (or any path) for project-local.
if [[ "${1:-}" == "" ]]; then
  TARGET_DIR="$HOME/.claude/skills"
else
  TARGET_DIR="$(cd "$1" && pwd)/.claude/skills"
fi

echo "Installing skills → $TARGET_DIR"
mkdir -p "$TARGET_DIR"

for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  rm -rf "$TARGET_DIR/$name"
  cp -r "${skill_dir%/}" "$TARGET_DIR/$name"
  echo "  OK   $name"
done

echo ""
echo "Done. Run /reload-plugins in Claude Code."
