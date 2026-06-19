#!/usr/bin/env bash
#
# install.sh — install one appearance variant of the mod into the game.
#
# Copies the chosen variant's patch triplet into the game's data directory.
# The game path is never hardcoded: pass it as an argument or set HD2_GAME_PATH.
#
# Usage: install.sh <variant> [GAME_PATH]
#   <variant>   one of: blue/glow  blue/no_glow  purple/glow  purple/no_glow
#   GAME_PATH   the game install dir (the folder that contains data/);
#               defaults to $HD2_GAME_PATH.
#
# Prefer HD2ModManager for managed installs; this is the manual path.

set -euo pipefail
cd "$(dirname "$0")/.."

VARIANT="${1:-}"
GAME="${2:-${HD2_GAME_PATH:-}}"

case "$VARIANT" in
  blue/glow|blue/no_glow|purple/glow|purple/no_glow) ;;
  *) echo "usage: install.sh <blue/glow|blue/no_glow|purple/glow|purple/no_glow> [GAME_PATH]" >&2; exit 1 ;;
esac
[ -n "$GAME" ] || { echo "set GAME_PATH arg or HD2_GAME_PATH (the dir containing data/)" >&2; exit 1; }

SRC="$VARIANT"
DATA="$GAME/data"
[ -d "$SRC" ] || { echo "variant not found: $SRC" >&2; exit 1; }
[ -d "$DATA" ] || { echo "no data dir at: $DATA" >&2; exit 1; }

echo "Installing '$VARIANT' into: $DATA"
count=0
shopt -s nullglob
for f in "$SRC"/*; do
  cp -f "$f" "$DATA/" && count=$((count + 1))
done
echo "Copied $count file(s). Revert with: scripts/revert-mods.sh \"$GAME\""
