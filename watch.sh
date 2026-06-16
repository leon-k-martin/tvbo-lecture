#!/usr/bin/env bash
# Auto-sync: watch the workshop repo and run sync.sh whenever it changes.
#
# Pair this with `make preview` (or `quarto preview`) in a SECOND terminal:
#   terminal 1:  make watch      # this script — keeps tvbo-lecture in sync
#   terminal 2:  make preview     # serves the deck, hot-reloads on the synced files
#
# So: edit in the workshop repo -> watch syncs it here -> preview reloads.
#
# Usage:  ./watch.sh             (SRC defaults to ../tvb-ontology-optim-workshop)
#         SRC=/path ./watch.sh
#
# NOTE: deliberately NOT using `set -e`/`pipefail` — a long-running watcher
# should survive a transient error (e.g. a half-written file mid-save).
set -u

DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${SRC:-$DEST/../tvb-ontology-optim-workshop}"
if [[ ! -f "$SRC/slides.qmd" ]]; then
  echo "workshop repo not found at: $SRC (set SRC=...)" >&2; exit 1
fi
SRC="$(cd "$SRC" && pwd)"

# paths in the workshop repo whose changes should trigger a re-sync
WATCH=( "$SRC/slides.qmd" "$SRC/slides" "$SRC/_freeze/slides"
        "$SRC/img" "$SRC/data" "$SRC/js" "$SRC/slides.css" "$SRC/bibliography.bib" )
for h in "$SRC"/brain-*.html; do [[ -e "$h" ]] && WATCH+=("$h"); done

sync_now() {
  echo "  change detected -> sync ($(date +%H:%M:%S))"
  if SRC="$SRC" "$DEST/sync.sh" >/dev/null 2>&1; then echo "  ✓ synced"; else echo "  ✗ sync failed" >&2; fi
}

echo "watching: $SRC"
echo "          (run 'make preview' in another terminal; Ctrl-C to stop)"

if command -v fswatch >/dev/null 2>&1; then
  echo "          using fswatch (event-based)"
  fswatch -o -r "${WATCH[@]}" | while read -r _; do sync_now; done
else
  echo "          using 2s polling (install fswatch for instant: brew install fswatch)"
  prev=0
  while true; do
    # newest modification time (epoch seconds) across all watched files
    cur=$(find "${WATCH[@]}" -type f -exec stat -f '%m' {} + 2>/dev/null | sort -rn | head -1)
    cur=${cur:-0}
    if [[ "$cur" -gt "$prev" ]]; then
      [[ "$prev" -ne 0 ]] && sync_now   # skip the initial baseline reading
      prev="$cur"
    fi
    sleep 2
  done
fi
