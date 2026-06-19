#!/usr/bin/env bash
#
# revert-mods.sh — remove this mod's patch files from the game's data dir,
# restoring the unmodded state. A standalone safety net.
#
# It only deletes this mod's archive (9ba626afa44a3aa3.patch_<n>[.gpu_resources
# |.stream]); base game files and other mods' patches are never touched.
#
# Usage: revert-mods.sh [GAME_PATH]
#   GAME_PATH   the game install dir (containing data/); defaults to
#               $HD2_GAME_PATH.
#
# Baseline before any destructive action: back up the data dir, e.g.
#   cp -a "$GAME/data" "$GAME/data.bak"   (restore by moving it back)

set -euo pipefail

ARCHIVE="9ba626afa44a3aa3"
GAME="${1:-${HD2_GAME_PATH:-}}"
[ -n "$GAME" ] || { echo "usage: revert-mods.sh [GAME_PATH] (or set HD2_GAME_PATH)" >&2; exit 1; }

DATA="$GAME/data"
[ -d "$DATA" ] || { echo "no data dir at: $DATA" >&2; exit 1; }

echo "Reverting '$ARCHIVE' patches in: $DATA"
count=0
shopt -s nullglob
for f in "$DATA/$ARCHIVE".patch_*; do
  base="$(basename "$f")"
  if [[ "$base" =~ ^[0-9a-f]{16}\.patch_[0-9]+(\.gpu_resources|\.stream)?$ ]]; then
    rm -f "$f" && count=$((count + 1))
  fi
done
echo "Removed $count file(s); base game files and other mods untouched."
