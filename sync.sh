#!/usr/bin/env bash
# Symlink every skill in ./skills into each agent's user-level skills dir.
# Safe to re-run: only touches symlinks that point into this repo.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/skills"

# ~/.agents/skills: Codex, OpenCode, and most other agents
# ~/.claude/skills: Claude Code
TARGETS=("$HOME/.agents/skills" "$HOME/.claude/skills")

for target in "${TARGETS[@]}"; do
  mkdir -p "$target"

  # Remove links to skills that were deleted or renamed in this repo.
  for link in "$target"/*; do
    [ -L "$link" ] || continue
    case "$(readlink "$link")" in
      "$SRC"/*) [ -e "$link" ] || { rm "$link"; echo "removed  $link"; } ;;
    esac
  done

  for dir in "$SRC"/*/; do
    [ -f "$dir/SKILL.md" ] || continue
    name="$(basename "$dir")"
    dest="$target/$name"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "skipped  $dest (exists and is not a symlink)" >&2
      continue
    fi
    ln -sfn "$SRC/$name" "$dest"
    echo "linked   $dest"
  done
done
