#!/system/bin/sh
boot="/data/adb/service.d"
placeholder="/data/adb/modules/playintegrity/webroot/common_scripts"

mkdir -p "$boot"

# Delete installation script if exists 
if [ -f "/data/adb/modules/playintegrity/customize.sh" ]; then
  rm -rf "/data/adb/modules/playintegrity/customize.sh"
fi

# create dummy placeholder files to fix broken translations in webui
touch "$placeholder/meowverse.sh"
touch "$placeholder/boot_hash.sh"
touch "$placeholder/vending.sh"
touch "$placeholder/report.sh"
touch "$placeholder/start.sh"
touch "$placeholder/stop.sh"
touch "$placeholder/sus.sh"

if [ ! -f "$boot/hash.sh" ]; then
  cat <<'EOF' > "$boot/hash.sh"
#!/system/bin/sh
HASH_FILE="/data/adb/Box-Brain/hash.txt"
LOG_DIR="/data/adb/Box-Brain/Integrity-Box-Logs"
LOG_FILE="$LOG_DIR/vbmeta.log"

mkdir -p "$LOG_DIR"

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$LOG_FILE"; }

# Only run if the hash file exists and is not empty
if [ -s "$HASH_FILE" ]; then

    # Look for resetprop in all known locations
    for RP in \
        /sbin/resetprop \
        /system/bin/resetprop \
        /system/xbin/resetprop \
        /data/adb/magisk/resetprop \
        /data/adb/ksu/bin/resetprop \
        $(command -v resetprop 2>/dev/null)
    do
        [ -x "$RP" ] && break
    done

    if [ ! -x "$RP" ]; then
        log "ERROR: resetprop not found anywhere"
        exit 1
    fi

    # Default VBMeta props
    SIZE="4096"
    ALG="sha256"
    VERSION="2.0"
    STATE="locked"

    # Read hash from file, keep only hex digits
    DIGEST=$(tr -cd '0-9a-fA-F' < "$HASH_FILE")

    # Apply VBMeta props
    "$RP" ro.boot.vbmeta.digest "$DIGEST"
    "$RP" ro.boot.vbmeta.size "$SIZE"
    "$RP" ro.boot.vbmeta.hash_alg "$ALG"
    "$RP" ro.boot.vbmeta.avb_version "$VERSION"
    "$RP" ro.boot.vbmeta.device_state "$STATE"

    if [ -n "$DIGEST" ]; then
        log "Set ro.boot.vbmeta.digest to: $DIGEST"
    else
        log "Cleared ro.boot.vbmeta.digest (no valid hash provided)"
    fi

    log "Set ro.boot.vbmeta.size=$SIZE, hash_alg=$ALG, avb_version=$VERSION, device_state=$STATE"

else
    log "Hash file missing or empty, skipping VBMeta update."
fi
EOF
fi

chmod 755 "$boot/hash.sh"
exit 0