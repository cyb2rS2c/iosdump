#!/usr/bin/env bash

set -uo pipefail

# ==========================================
# CONFIGURATION
# ==========================================

TARGET="$HOME/Downloads/iphone_backup"
LOG="$TARGET/errors.log"
BACKUP="$TARGET/full_backup"
INFO="$TARGET/device_info"

MIN_FREE_GB=20

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

mkdir -p "$TARGET" "$INFO" "$BACKUP"

# ==========================================
# LOGGING
# ==========================================

touch "$LOG"

log_error() {
    echo "[$(date '+%F %T')] $*" >> "$LOG"
}

# ==========================================
# PROGRESS BAR
# ==========================================

STAGES=5
CURRENT=0

progress() {
    local percent=$((CURRENT * 100 / STAGES))
    local filled=$((percent / 5))
    local empty=$((20 - filled))

    printf "\r\033[K["
    printf '%*s' "$filled" '' | tr ' ' '#'
    printf '%*s' "$empty" '' | tr ' ' '-'

    printf "] %3d%% | %s" "$percent" "$1"
}

step_done() {
    ((CURRENT+=1))
    progress "$1"
}

# ==========================================
# HEADER
# ==========================================

clear

echo -e "${BLUE}"
echo "======================================"
echo "           IPHONE DUMPER"
echo "======================================"
echo -e "${NC}"

echo "Destination: $TARGET"
echo

# ==========================================
# CHECK DISK SPACE
# ==========================================

AVAILABLE=$(df -Pk "$TARGET" | awk 'NR==2 {print $4}')

REQUIRED=$((MIN_FREE_GB * 1024 * 1024))

if (( AVAILABLE < REQUIRED )); then
    echo -e "${RED}ERROR: Insufficient disk space.${NC}"
    echo "Required: ${MIN_FREE_GB} GB"
    df -h "$TARGET"
    exit 1
fi

echo -e "${GREEN}Disk space check passed.${NC}"
df -h "$TARGET" | tail -1
echo

# ==========================================
# CHECK IPHONE CONNECTION
# ==========================================

echo "Checking iPhone connection..."

if ! ideviceinfo >/dev/null 2>&1; then
    echo -e "${RED}No iPhone detected.${NC}"
    echo "Unlock your iPhone and trust this computer."
    exit 1
fi

# ==========================================
# STAGE 1: DEVICE INFORMATION
# ==========================================

progress "Collecting device information"

ideviceinfo > "$INFO/device_info.txt" 2>>"$LOG" || {
    log_error "Could not collect device information"
}

ideviceinfo -k DeviceName > "$INFO/device_name.txt" 2>/dev/null || true
ideviceinfo -k ProductVersion > "$INFO/ios_version.txt" 2>/dev/null || true
ideviceinfo -k ProductType > "$INFO/model.txt" 2>/dev/null || true

step_done "Device information collected"

# ==========================================
# STAGE 2: DOWNLOAD MEDIA
# ==========================================

progress "Scanning iPhone media"

mkdir -p "$TARGET/photos"

MEDIA_TOTAL=0
MEDIA_SUCCESS=0
MEDIA_FAILED=0

if command -v afcclient >/dev/null 2>&1; then

    mapfile -t DIRS < <(
        afcclient ls DCIM 2>/dev/null || true
    )

    FILES=()

    for d in "${DIRS[@]}"; do

        [[ -z "$d" ]] && continue

        while IFS= read -r f; do

            [[ -z "$f" ]] && continue

            FILES+=("DCIM/$d/$f")

        done < <(
            afcclient ls "DCIM/$d" 2>/dev/null || true
        )

    done

    MEDIA_TOTAL=${#FILES[@]}

    echo
    echo "Found $MEDIA_TOTAL media items."

    COUNT=0

    for file in "${FILES[@]}"; do

        local_path="$TARGET/photos/$file"

        mkdir -p "$(dirname "$local_path")"

        if afcclient get "$file" "$local_path" \
            >/dev/null 2>>"$LOG"; then

            ((MEDIA_SUCCESS+=1))

        else

            ((MEDIA_FAILED+=1))
            log_error "Failed to download: $file"

        fi

        ((COUNT+=1))

        if (( MEDIA_TOTAL > 0 )); then

            percent=$((COUNT * 100 / MEDIA_TOTAL))

            printf "\r\033[KMedia: %3d%% (%d/%d) | OK: %d | Failed: %d" \
                "$percent" "$COUNT" "$MEDIA_TOTAL" \
                "$MEDIA_SUCCESS" "$MEDIA_FAILED"

        fi

    done

    echo

else

    echo "afcclient not installed."
    log_error "afcclient not installed"

fi

step_done "Media download finished"

# ==========================================
# STAGE 3: FULL IPHONE BACKUP
# ==========================================

progress "Creating iPhone backup"

BACKUP_STATUS=1

if command -v idevicebackup2 >/dev/null 2>&1; then

    echo
    echo "Starting iPhone backup..."
    echo "Keep your iPhone connected and unlocked."
    echo

    # Backup output goes to LOG, not /tmp.
    if idevicebackup2 backup "$BACKUP" >>"$LOG" 2>&1; then

        BACKUP_STATUS=0

        # Verify backup manifest
        if find "$BACKUP" -type f \
            \( -name "Manifest.db" -o -name "Manifest.plist" \) \
            -print -quit | grep -q .; then

            BACKUP_STATUS=0

        else

            BACKUP_STATUS=1
            log_error "Backup command completed but no manifest was found"

        fi

    else

        BACKUP_STATUS=$?
        log_error "iPhone backup failed with exit code $BACKUP_STATUS"

    fi

else

    log_error "idevicebackup2 not installed"

fi

if (( BACKUP_STATUS == 0 )); then

    step_done "iPhone backup completed"

else

    step_done "Backup failed - check errors.log"

fi

# ==========================================
# STAGE 4: ORGANIZE OUTPUT
# ==========================================

progress "Organizing output"

mkdir -p \
    "$TARGET/notes" \
    "$TARGET/files" \
    "$TARGET/messages" \
    "$TARGET/contacts" \
    "$TARGET/app_data" \
    "$TARGET/attachments"

step_done "Output directories created"

# ==========================================
# STAGE 5: GENERATE REPORT
# ==========================================

progress "Generating report"

{

    echo "======================================"
    echo "         IPHONE DUMPER REPORT"
    echo "======================================"

    echo
    echo "Device information:"

    echo "Name: $(cat "$INFO/device_name.txt" 2>/dev/null || echo Unknown)"
    echo "iOS: $(cat "$INFO/ios_version.txt" 2>/dev/null || echo Unknown)"
    echo "Model: $(cat "$INFO/model.txt" 2>/dev/null || echo Unknown)"

    echo
    echo "Media:"
    echo "Total: $MEDIA_TOTAL"
    echo "Downloaded: $MEDIA_SUCCESS"
    echo "Failed: $MEDIA_FAILED"

    echo
    echo "Backup:"
    if (( BACKUP_STATUS == 0 )); then
        echo "Status: SUCCESS"
    else
        echo "Status: FAILED"
    fi

    echo "Location: $BACKUP"

    echo
    echo "Storage:"
    df -h "$TARGET"

    echo
    echo "Logs: $LOG"

} > "$TARGET/report.txt" 2>>"$LOG"

step_done "Report generated"

# ==========================================
# FINISH
# ==========================================

echo
echo

if (( BACKUP_STATUS == 0 )); then
    echo -e "${GREEN}======================================"
    echo "          DUMP COMPLETE"
    echo "======================================${NC}"
else
    echo -e "${YELLOW}======================================"
    echo "     MEDIA COMPLETE / BACKUP FAILED"
    echo "======================================${NC}"
fi

echo
echo "Destination:"
echo "$TARGET"

echo
echo "Media downloaded: $MEDIA_SUCCESS / $MEDIA_TOTAL"

echo
echo "Backup status:"
if (( BACKUP_STATUS == 0 )); then
    echo "SUCCESS"
else
    echo "FAILED"
fi

echo
echo "Report: $TARGET/report.txt"
echo "Errors: $LOG"

echo
echo "Directory structure:"
tree -L 3 "$TARGET" 2>/dev/null || true
