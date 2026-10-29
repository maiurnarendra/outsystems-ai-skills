#!/usr/bin/env bash
# Installs (or updates) the OutSystems AI Skills into the skills directory
# of Claude Code (~/.claude/skills) or Google Antigravity (~/.gemini/config/skills).
#
# Usage:
#   bash scripts/install.sh                            # Claude Code, latest from GitHub
#   bash scripts/install.sh --target antigravity       # Antigravity, latest from GitHub
#   bash scripts/install.sh --source .                 # copy from a local checkout
#   bash scripts/install.sh --destination ./.agents/skills   # any folder (e.g. one workspace)
set -euo pipefail

REPO_URL="https://github.com/maiurnarendra/outsystems-ai-skills.git"
TARGET="claude"
DESTINATION=""
SOURCE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --destination) DESTINATION="$2"; shift 2 ;;
    --source) SOURCE="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -n "$DESTINATION" ]]; then
  SKILLS_DIR="$DESTINATION"
else
  case "$TARGET" in
    claude) SKILLS_DIR="${HOME}/.claude/skills" ;;
    antigravity) SKILLS_DIR="${HOME}/.gemini/config/skills" ;;
    *) echo "Unknown target: $TARGET (use claude or antigravity)" >&2; exit 1 ;;
  esac
fi

TMP_DIR=""
cleanup() { [[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

if [[ -n "$SOURCE" ]]; then
  REPO_DIR="$SOURCE"
else
  command -v git >/dev/null || { echo "git is required but not found on PATH." >&2; exit 1; }
  TMP_DIR="$(mktemp -d)"
  echo "Cloning $REPO_URL..."
  git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"
  REPO_DIR="$TMP_DIR/repo"
fi

[[ -d "$REPO_DIR/skills" ]] || { echo "'skills' folder not found under $REPO_DIR" >&2; exit 1; }

mkdir -p "$SKILLS_DIR"
for skill in "$REPO_DIR"/skills/*/; do
  name="$(basename "$skill")"
  rm -rf "${SKILLS_DIR:?}/$name"
  cp -R "$skill" "$SKILLS_DIR/$name"
  echo "Installed '$name'"
done

echo "Done. Skills are in $SKILLS_DIR. Start a new agent session for them to load."
