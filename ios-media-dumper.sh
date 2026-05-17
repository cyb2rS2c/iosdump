#!/bin/bash

set -euo pipefail

TARGET_DIR="iphone_media"
ERROR_LOG="/tmp/afc_error.log"
find . -type d -iname "$TARGET_DIR" -exec rm -rf {} +
mkdir -p "$TARGET_DIR/DCIM"

echo "Fetching media from iPhone..."

afcclient ls DCIM 2>/dev/null | while IFS= read -r d; do
    [ -z "$d" ] && continue

    dev_path="DCIM/$d"

    afcclient ls "$dev_path" 2>/dev/null | while IFS= read -r i; do
        [ -z "$i" ] && continue

        remote_path="$dev_path/$i"
        local_path="$TARGET_DIR/$remote_path"

        mkdir -p "$(dirname "$local_path")"

        if afcclient get "$remote_path" "$local_path" 2>"$ERROR_LOG"; then
            echo "Fetched: $remote_path"
        else
            if grep -q "Failed to get a directory" "$ERROR_LOG"; then
                echo "Skipping directory: $remote_path"
                rm -f "$local_path"
            else
                echo "Error fetching: $remote_path"
            fi
        fi
    done
done

echo
clear
echo "Download complete."
tree "$TARGET_DIR"
