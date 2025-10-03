#!/system/bin/sh
MODDIR=${0%/*}
LOG_DIR="/data/adb/Box-Brain/Integrity-Box-Logs"
INSTALL_LOG="$LOG_DIR/Installation.log"
UPDATE="/data/adb/modules_update/playintegrity"
SCRIPT="$UPDATE/webroot/common_scripts"
PIF_DIR="/data/adb/modules/playintegrityfix"
PIF_PROP="$PIF_DIR/module.prop"

# create dirs
mkdir -p "$LOG_DIR" 2>/dev/null || true
echo " "

# Quote of the day 
cat <<EOF > $LOG_DIR/.verify
YourMindIsAWeaponTrainItToSeeOpportunityNotObstacles
EOF

# Delete old fingerprint files with advanced settings if they exist
[ -f /data/adb/modules/playintegrityfix/custom.pif.json ] && rm -f /data/adb/modules/playintegrityfix/custom.pif.json
[ -f /data/adb/modules/playintegrityfix/custom.pif.json.bak ] && rm -f /data/adb/modules/playintegrityfix/custom.pif.json.bak
[ -f /data/adb/modules/playintegrity/webroot/PlayIntegrityFork/toggle_state.json ] && rm -f /data/adb/modules/playintegrity/webroot/PlayIntegrityFork/toggle_state.json

# logger
log() {
    echo "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_DIR/installation.log"
}

chup() {
echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_DIR/pixel.log"
}


set_resetprop() {
    PROP="$1"
    VALUE="$2"
    CURRENT=$(su -c getprop "$PROP")
    
    if [ -n "$CURRENT" ]; then
        su -c resetprop -n -p "$PROP" "$VALUE" > /dev/null 2>&1
        chup "Reset $PROP to $VALUE"
    else
        chup "Skipping $PROP, property does not exist"
    fi
}

set_simpleprop() {
    PROP="$1"
    VALUE="$2"
    CURRENT=$(su -c getprop "$PROP")
    
    if [ -n "$CURRENT" ]; then
        su -c setprop "$PROP" "$VALUE" > /dev/null 2>&1
        chup "Set $PROP to $VALUE"
    else
        chup "Skipping $PROP, property does not exist"
    fi
}

# Run actions
batman() {

  if [ -n "$ZIPFILE" ] && [ -f "$ZIPFILE" ]; then
    log " "
    log " ✦ Checking Module Integrity..."

    if [ -f "$UPDATE/verify.sh" ]; then
      if sh "$UPDATE/verify.sh"; then
        log " ✦ Verification completed successfully"
      else
        log " ✘ Verification failed"
        exit 1
      fi
    else
      log " ✦ verify.sh not found ❌"
      exit 1
    fi
  fi

  log " "
  log " ✦ Preparing keybox downloader"
  chmod +x "$SCRIPT/key.sh"
  sh "$SCRIPT/key.sh" # >/dev/null 2>&1
  log " "
  log " ✦ Updating target list as per TEE"
  chmod +x "$SCRIPT/user.sh"
  sh "$SCRIPT/user.sh" >/dev/null 2>&1
  log " ✦ Target list has been updated "
  log " "
  log " ✦ Updating Boot patch file"
  chmod +x "$SCRIPT/patch.sh"
  sh "$SCRIPT/patch.sh" >/dev/null 2>&1
  log " ✦ TrickyStore spoof applied "
  log " "
  log " ✦ Scanning Play Integrity Fix"
  if [ -d "$PIF_DIR" ] && [ -f "$PIF_PROP" ]; then
    if grep -q "name=Play Integrity Fork" "$PIF_PROP" 2>/dev/null; then
      log " ✦ Detected: PIF by @osm0sis"
      log " ✦ Refreshing fingerprint using PIF"
      [ -f "$PIF_DIR/autopif2.sh" ] && chmod 755 "$PIF_DIR/autopif2.sh" && sh "$PIF_DIR/autopif2.sh" >/dev/null 2>&1 || true
    elif grep -q "name=Play Integrity Fix" "$PIF_PROP" 2>/dev/null; then
      log " ✦ Detected: Unofficial PIF"
      log " ✦ Refreshing fingerprint using PIF module"
      [ -x "$PIF_DIR/autopif.sh" ] && sh "$PIF_DIR/autopif.sh" >/dev/null 2>&1 || true
    else
      log " ✦ Unknown PIF module detected (not recommended)"
      log "    🙏PLEASE USE PIF FORK BY @osm0sis🙏"
    fi
  else
    log " ✦ PIF is not installed"
    log "    Maybe you're using ROM's inbuilt spoofing"
  fi
}

release_source() {
    [ -f "/data/adb/Box-Brain/noredirect" ] && return 0
    nohup am start -a android.intent.action.VIEW -d https://t.me/MeowDump >/dev/null 2>&1 &
}

# Delete old fingerprint with advance settings if they exists
[ -f /data/adb/modules/playintegrityfix/custom.pif.json ] && rm -f /data/adb/modules/playintegrityfix/custom.pif.json
[ -f /data/adb/modules/playintegrityfix/custom.pif.json.bak ] && rm -f /data/adb/modules/playintegrityfix/custom.pif.json.bak

# Entry point
batman

# Delete old logs & trash generated integrity box
chmod +x "$SCRIPT/cleanup.sh"
sh "$SCRIPT/cleanup.sh"

# delete old integrity box module ID if exists
if [ -e /data/adb/modules/zygisk/module.prop ]; then
    rm -rf /data/adb/modules/zygisk
fi

log " "
log " ✦ Analyzing GMS spoofing"
# Check for gms flag, skip if found
if [ -f "/data/adb/Box-Brain/gms" ]; then
    log " ✦ Skipping, GMS flag found"
elif [ -f "$PIF_DIR/module.prop" ]; then
    log " ✦ Disabling inbuilt GMS spoofing"
    # Set/reset props if they exist
    set_resetprop persist.sys.pihooks.disable.gms_key_attestation_block true
    set_resetprop persist.sys.pihooks.disable.gms_props true
    set_simpleprop persist.sys.pihooks.disable 1
    set_simpleprop persist.sys.kihooks.disable 1
else
    log " ✦ Skipping operations, PIF not found"
fi

# Abnormal boot hash fixer
log " "
log " ✦ Checking for Verified Boot Hash file..."

if [ ! -f /data/adb/Box-Brain/hash.txt ]; then
    log " ✦ Building Verified Boot Hash config"
    touch /data/adb/Box-Brain/hash.txt
    log " ✦ File created successfully"
else
    log " ✦ File already exists, skipping"
fi

# Force stop Playstore 
am force-stop com.android.vending

release_source
log " "
log " "
log "        ••• Installation Completed ••• "
log " "
log "    This module was released by 𝗠𝗘𝗢𝗪 𝗗𝗨𝗠𝗣"
log " "
log " "
log " "
exit 0