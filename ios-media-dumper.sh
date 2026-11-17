#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="iphone_media"
ERROR_LOG="/tmp/afc_error.log"

# Clean destination
find . -type d -iname "$TARGET_DIR" -exec rm -rf {} +
mkdir -p "$TARGET_DIR/DCIM"

echo "Scanning iPhone..."

# Collect directories
mapfile -t DIRS < <(afcclient ls DCIM 2>/dev/null)

FILES=()

for d in "${DIRS[@]}"; do
    [[ -z "$d" ]] && continue

    dev_path="DCIM/$d"

    while IFS= read -r i; do
        [[ -z "$i" ]] && continue
        FILES+=("$dev_path/$i")
    done < <(afcclient ls "$dev_path" 2>/dev/null || true)
done

TOTAL=${#FILES[@]}
COUNT=0
SUCCESS=0
SKIPPED=0
FAILED=0

# Progress bar
show_progress() {
    local percent=0
    local filled=0
    local empty=50

    if (( TOTAL > 0 )); then
        percent=$((COUNT * 100 / TOTAL))
        filled=$((percent / 2))
        empty=$((50 - filled))
    fi

    printf "\r\033[K["
    printf '%*s' "$filled" '' | tr ' ' '#'
    printf '%*s' "$empty" '' | tr ' ' '-'

    printf "] %3d%% | %d/%d | OK: %d | Skipped: %d | Failed: %d" \
        "$percent" "$COUNT" "$TOTAL" "$SUCCESS" "$SKIPPED" "$FAILED"
}

echo "Downloading $TOTAL items..."

show_progress

for remote_path in "${FILES[@]}"; do
    local_path="$TARGET_DIR/$remote_path"

    mkdir -p "$(dirname "$local_path")"

    if afcclient get "$remote_path" "$local_path" >/dev/null 2>"$ERROR_LOG"; then
        ((SUCCESS+=1))
    elif grep -q "Failed to get a directory" "$ERROR_LOG"; then
        ((SKIPPED+=1))
        rm -f "$local_path"
    else
        ((FAILED+=1))
    fi

    ((COUNT+=1))
    show_progress
done

echo
echo
echo "Download complete!"
echo "Total:   $TOTAL"
echo "Success: $SUCCESS"
echo "Skipped: $SKIPPED"
echo "Failed:  $FAILED"

tree "$TARGET_DIR"
