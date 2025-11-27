#!/system/bin/sh
MODPATH="${0%/*}"
. $MODPATH/common_func.sh

# Paths
MODULE="/data/adb/modules"
MODDIR="$MODULE/playintegrity"
SCRIPT_DIR="$MODDIR/webroot/common_scripts"
UPDATE="$SCRIPT_DIR/key.sh"
PIF="$MODULE/playintegrityfix"
PROP="/data/adb/modules/playintegrity/module.prop"
URL="https://raw.githubusercontent.com/MeowDump/Integrity-Box/refs/heads/main/DUMP/notice.md"
BAK="$PROP.bak"
FLAG="/data/adb/Box-Brain/advanced"
FINGERPRINT="$PIF/custom.pif.json"
FORK="/data/adb/modules_update/playintegrityfix"
P="/data/adb/modules/playintegrityfix/custom.pif.prop"
BADMOSI="/data/adb/modules_update/playintegrity/toolbox/custom.pif.prop"
PATCH_DATE="2025-10-05"
TARGET_DIR="/data/adb/tricky_store"
FILE_PATH="$TARGET_DIR/security_patch.txt"
PATCH_FLAG="/data/adb/Box-Brain/patch"
PROP_MAIN="ro.build.version.security_patch"
DIR="/sdcard/Download"
CPP="/data/adb/Box-Brain/Integrity-Box-Logs/spoofing.log"
PATCH_LOG="/data/adb/Box-Brain/Integrity-Box-Logs/patch.log"
LOG="/data/adb/Box-Brain/Integrity-Box-Logs/root.log"
LOGFILE="/data/adb/Box-Brain/Integrity-Box-Logs/gapps.log"
LOGZ="/data/adb/Box-Brain/Integrity-Box-Logs/integrity_downloader.log"
URL_PIF="https://github.com/osm0sis/PlayIntegrityFork/releases/download/v15/PlayIntegrityFork-v15.zip"
SUM_PIF="ecb0542d04bd4a1dbedd1398651dced86d90a87f4e817125753665a24297124e"
URL_ZN="https://github.com/Dr-TSNG/ZygiskNext/releases/download/v1.3.1/Zygisk-Next-1.3.1-665-7e5b533-release.zip"
SUM_ZN="7ab5f6bb06c60c960f62fdbf2312e56b094ee91e44105a734a57c763c274b5c3"
URL_TS="https://github.com/5ec1cff/TrickyStore/releases/download/1.4.1/Tricky-Store-v1.4.1-245-72b2e84-release.zip"
SUM_TS="2f5e73fcba0e4e43b6e96b38f333cbe394873e3a81cf8fe1b831c2fbd6c46ea9"
URL_IB="https://github.com/MeowDump/Integrity-Box/releases/download/v26/v26-Integrity-Box-16-11-2025.zip"
SUM_IB="a084af2d95fbf8a67800ff2303e6317272bac1605515b7f0984bde517d6c9f0c"
PIPE="$RECORD/integrity_downloader.pipe"
OUT="/storage/emulated/0/Download/IntegrityModules"
WIDTH=55

if [ -f /data/adb/Box-Brain/download ]; then

    rm -f "$LOGZ" "$PIPE"
    mkdir -p "$OUT"

    if command -v mkfifo >/dev/null 2>&1; then
        mkfifo "$PIPE"
        tee -a "$LOGZ" < "$PIPE" &
        exec 1> "$PIPE" 2>&1
    else
        exec >> "$LOGZ" 2>&1
    fi

    banner
    printf "Module                  Size         Status\n"
    printf "%${WIDTH}s\n" | tr ' ' '-'

    download "$URL_PIF" "PlayIntegrityFork.zip" "$SUM_PIF"
    [ -f "$OUT/PlayIntegrityFork.zip" ] &&
        print_row "PlayIntegrityFork" "$(get_size "$OUT/PlayIntegrityFork.zip")" "Verified" ||
        print_row "PlayIntegrityFork" "-" "Failed"

    download "$URL_ZN" "ZygiskNext.zip" "$SUM_ZN"
    [ -f "$OUT/ZygiskNext.zip" ] &&
        print_row "ZygiskNext" "$(get_size "$OUT/ZygiskNext.zip")" "Verified" ||
        print_row "ZygiskNext" "-" "Failed"

    download "$URL_TS" "TrickyStore.zip" "$SUM_TS"
    [ -f "$OUT/TrickyStore.zip" ] &&
        print_row "TrickyStore" "$(get_size "$OUT/TrickyStore.zip")" "Verified" ||
        print_row "TrickyStore" "-" "Failed"

    download "$URL_IB" "IntegrityBox.zip" "$SUM_IB"
    [ -f "$OUT/IntegrityBox.zip" ] &&
        print_row "IntegrityBox" "$(get_size "$OUT/IntegrityBox.zip")" "Verified" ||
        print_row "IntegrityBox" "-" "Failed"

    printf "%${WIDTH}s\n" | tr ' ' '='
    center "DONE"
    printf "%${WIDTH}s\n" | tr ' ' '='

    rm -rf "/data/adb/Box-Brain/download"
    echo 
    echo "Saved to $OUT"
    handle_delay
    exit 0
fi

if [ -f "/data/adb/Box-Brain/root" ]; then
  rm -f "/data/adb/Box-Brain/root"
  find "$DIR" -type f \( -name "*_install_log_2025*" -o -name "*_action_log_2025*" \) | while read -r f; do
    echo "$(date '+%F %T') Deleted: $f" | tee -a "$LOG"
    rm -f "$f"
  done
  handle_delay
  exit 0
fi

if [ -f "/data/adb/Box-Brain/gapps" ]; then
  rm -f "/data/adb/Box-Brain/gapps"
  echo "====================================" | tee -a "$LOGFILE"
  echo "Starting Log Cleanup" | tee -a "$LOGFILE"
  echo "====================================" | tee -a "$LOGFILE"
  echo "" | tee -a "$LOGFILE"

  TARGETS="
/sdcard/Android/litegapps/litegapps_controller.log
/tmp/NikGapps
/tmp/NikGapps/logfiles
/tmp/NikGapps/addonscripts
/tmp/NikGapps/logfiles/package_log
/sdcard/NikGapps
/tmp/recovery.log
/tmp/NikGapps.log
/tmp/Mount.log
/tmp/installation_size.log
/tmp/busybox.log
/tmp/Logs-*.tar.gz
/tmp/bitgapps_debug_logs_*.tar.gz
/sdcard/bitgapps_debug_logs_*.tar.gz
/system/etc/bitgapps_debug_logs_*.tar.gz
/sdcard/Download/*_install_log_2025*
/sdcard/Download/*_action_log_2025*
"

  for path in $TARGETS; do
    if echo "$path" | grep -q '\*'; then
      files=$(find "$(dirname "$path")" -type f -name "$(basename "$path")" 2>/dev/null)
    else
      files=$(find "$path" -type f 2>/dev/null)
    fi

    if [ -n "$files" ]; then
      echo "Found: $path" | tee -a "$LOGFILE"
      echo "$files" | tee -a "$LOGFILE"
      echo "$files" | while read -r f; do
        echo "Deleting: $f" | tee -a "$LOGFILE"
        rm -rf "$f" 2>&1 | tee -a "$LOGFILE"
      done
    elif [ -d "$path" ]; then
      echo "Deleting directory: $path" | tee -a "$LOGFILE"
      rm -rf "$path" 2>&1 | tee -a "$LOGFILE"
    fi
  done

  echo "" | tee -a "$LOGFILE"
  echo "Cleanup complete." | tee -a "$LOGFILE"
  echo "====================================" | tee -a "$LOGFILE"
  handle_delay
  exit 0
fi

# Force override lineage props
if [ -f "/data/adb/Box-Brain/override" ]; then
  echo "
  
  ┈╱▔▔▔▔▔▔╲┈╭━━━━━━━━━━━━━━━╮
  ▕┈╭━╮╭━╮┈▏┃ Hello Human...┃
  ▕┈┃╭╯╰╮┃┈▏╰┳━━━━━━━━━━━━━━╯ 
  ▕┈╰╯╭╮╰╯┈▏┈┃ 
  ▕┈┈┈┃┃┈┈┈▏━╯ 
  ▕┈┈┈╰╯┈┈┈▏ 
  ▕╱╲╱╲╱╲╱╲▏
  
  "
  sh "$SCRIPT_DIR/override_lineage.sh"
  handle_delay
  exit 0
fi

# Detect if Google Wallet is installed
if command -v pm >/dev/null 2>&1 && pm list packages | grep -q com.google.android.apps.walletnfcrel; then
  WALLET_INSTALLED=true
else
  WALLET_INSTALLED=false
fi

# Ensure log directory/file exists
mkdir -p "$(dirname "$CPP")" 2>/dev/null || true
touch "$CPP" 2>/dev/null || true

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$CPP"; }

# Exit if offline
if ! megatron; then exit 1; fi

# Show header
print_header

# Description content update
{
  for p in /data/adb/modules/busybox-ndk/system/*/busybox \
           /data/adb/ksu/bin/busybox \
           /data/adb/ap/bin/busybox \
           /data/adb/magisk/busybox \
           /system/bin/busybox \
           /system/xbin/busybox; do
    [ -x "$p" ] && bb=$p && break
  done
  [ -z "$bb" ] && return 0

  C=$($bb wget -qO- "$URL" 2>/dev/null)
  if [ -n "$C" ]; then
    [ ! -f "$BAK" ] && $bb cp "$PROP" "$BAK"
    $bb sed -i '/^description=/d' "$PROP"
    echo "description=$C" >> "$PROP"
  else
    [ -f "$BAK" ] && $bb cp "$BAK" "$PROP"
  fi
} || true

# Run steps
# Update Target List
if [ ! -d "/data/adb/tricky_store" ]; then
  echo "- TrickyStore module not found"
  log_step "MISSING" "TrickyStore Module"
else
  TRICKY_DIR='/data/adb/tricky_store'
  TARGET="$TRICKY_DIR/target.txt"
  BACKUP="$TARGET.bak"
  TMP="${TARGET}.new.$$"
  success=0
  made_backup=0
  orig_selinux="$(getenforce 2>/dev/null || echo Permissive)"

  # Temporarily set SELinux permissive
  if [ "$orig_selinux" = "Enforcing" ]; then
    setenforce 0 >/dev/null 2>&1
    log "SELinux temporarily set to Permissive"
  fi

  # Backup current target
  if [ -f "$TARGET" ]; then
    mv -f "$TARGET" "$BACKUP" && made_backup=1
    log "Backup created: $BACKUP"
  fi

  # Read teeBroken status
  teeBroken="false"
  TEE_STATUS="$TRICKY_DIR/tee_status"
  if [ -f "$TEE_STATUS" ]; then
    v=$(grep -E '^teeBroken=' "$TEE_STATUS" 2>/dev/null | cut -d '=' -f2)
    [ "$v" = "true" ] && teeBroken="true"
  fi

  # Base packages
  for pkg in com.android.vending com.google.android.gms com.reveny.nativecheck \
             io.github.vvb2060.keyattestation com.google.android.gsf io.github.qwq233.keyattestation \
             io.github.vvb2060.mahoshojo icu.nullptr.nativetest \
             com.google.android.contactkeys com.google.android.ims com.google.android.safetycore; do
    echo "$pkg" >> "$TMP"
  done

  # Append installed packages avoiding duplicates
  cmd package list packages -3 2>/dev/null | cut -d ":" -f2 | while read -r pkg; do
    [ -z "$pkg" ] && continue
    grep -Fxq "$pkg" "$TMP" || echo "$pkg" >> "$TMP"
  done

  # Trim spaces, remove duplicates
  sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "$TMP"
  sort -u "$TMP" -o "$TMP"

  # Apply blacklist filtering
  BLACKLIST="/data/adb/Box-Brain/blacklist.txt"
  if [ -s "$BLACKLIST" ]; then
    sed -i 's/^[[:space:]]*//;s/[[:space:]]*$//' "$BLACKLIST"
    grep -Fvxf "$BLACKLIST" "$TMP" > "${TMP}.filtered" || true
    mv -f "${TMP}.filtered" "$TMP"
    log_step "CLEANED" "Blacklisted Apps"
  else
    log_step "SKIPPED" "Blacklist not Configured"
  fi

  # If teeBroken=true, append '!' to every package name
  if [ "$teeBroken" = "true" ]; then
    sed -i 's/$/!/' "$TMP"
    log_step "SUPPORT" "TEE Broken (added '!')"
  fi

  # Swap in atomically
  mv -f "$TMP" "$TARGET" && success=1
  log_step "UPDATED" "Target Packages"

  # Restore SELinux
  if [ "$orig_selinux" = "Enforcing" ]; then
    setenforce 1 >/dev/null 2>&1
    log "SELinux restored to Enforcing"
  fi
fi

# Update Fingerprint based on Advanced Flag
if [ -f "$FLAG" ]; then
  if [ -f "$PIF/autopif2.sh" ]; then
    sh "$PIF/autopif2.sh" -s -m -p >/dev/null 2>&1 || exit 1
    log_step "UPDATED" "Advanced Fingerprint"
  else
    log_step "MISSING" "autopif2.sh for advanced mode"
  fi
else
  if [ -f "$PIF/autopif2.sh" ]; then 
    FP_SCRIPT="$PIF/autopif2.sh"
  elif [ -f "$PIF/autopif.sh" ]; then 
    FP_SCRIPT="$PIF/autopif.sh"
  else 
    FP_SCRIPT=""
  fi

  if [ -n "$FP_SCRIPT" ]; then
    sh "$FP_SCRIPT" >/dev/null 2>&1 \
      && log_step "UPDATED" "Fingerprint" \
      || log_step "FAILED" "Updating Fingerprint"
  else
    log_step "MISSING" "PIF Module"
  fi
fi

# Only update spoofing props if Google Wallet NOT installed and advanced flag is present
if [ "$WALLET_INSTALLED" != "true" ] && [ -f "$FLAG" ]; then
  if [ -f "$P" ]; then
    cp -f "$P" "$P.bak" && log "Backup: $P.bak"
    for k in spoofProvider spoofProps spoofBuild spoofVendingFinger; do
      setval "$P" "$k" "1"
    done
    s=$(grep -m1 "^spoofProvider=" "$P" 2>/dev/null | cut -d= -f2 || echo "")
    log "Spoofing: $( [ "$s" = "1" ] || [ "$s" = "true" ] && echo "✅ Enabled" || echo "⚠️ Disabled" )"
    log_step "UPDATED" "Spoofing Props"
  else
    log_step "MISSING" "PIF Fork Module"
  fi
else
  # If wallet installed we skip only the updater; if advanced flag missing we skip updater too.
  if [ "$WALLET_INSTALLED" = "true" ]; then
    log_step "SKIPPED" "Spoofing Props update (Google Wallet)"
  else
    log_step "SKIPPED" "Spoofing Props (Disabled)"
  fi
fi

# Remove advanced settings from PROP only if advanced flag is missing (run always regardless of Google Wallet)
if [ -f "$P" ] && [ ! -f "$FLAG" ]; then
  if grep -qE '^(spoofBuild|spoofProps|spoofProvider|spoofSignature|spoofVendingSdk|spoofVendingFinger|verboseLogs)=' "$P"; then
    sed -i -E '/^(spoofBuild|spoofProps|spoofProvider|spoofSignature|spoofVendingSdk|spoofVendingFinger|verboseLogs)=/d' "$P"
    log_step "CLEANED" "Advanced settings from Fingerprint"
  else
    log_step "SKIPPED" "Default Fingerprint Detected"
  fi
fi

if [ -f "$UPDATE" ]; then
  sh "$UPDATE" >/dev/null 2>&1 && log_step "UPDATED" "Keybox" || log_step "FAILED" "Updating Keybox"
else
  log_step "MISSING" "Keybox script"
fi

# Ensure log directory exists
mkdir -p "$(dirname "$PATCH_LOG")" 2>/dev/null || true
touch "$PATCH_LOG" 2>/dev/null || true

# Format PATCH_DATE into human-readable form
HUMAN_DATE=$(date -d "$PATCH_DATE" '+%d %B %Y' 2>/dev/null)

log_patch "Patch Date   : $HUMAN_DATE"
log_patch "Applied On   : $(date '+%Y-%m-%d %H:%M:%S')"

# Ensure Tricky Store directory exists
if [ ! -d "$TARGET_DIR" ]; then
  mkdir -p "$TARGET_DIR" 2>>"$PATCH_LOG"
  log_step "CREATED" "Tricky Store folder"
fi

# Write security_patch.txt based on patch flag
if [ -f "$PATCH_FLAG" ]; then
  echo "system=prop" > "$FILE_PATH" 2>>"$PATCH_LOG"
  log_step "UPDATED" "Patch to Stock"
else
  echo "all=$PATCH_DATE" > "$FILE_PATH" 2>>"$PATCH_LOG"
  log_step "SPOOFED" "Security Patch to $PATCH_DATE"

  # Check system property and patch if needed
  CURRENT_PROP="$(getprop "$PROP_MAIN" | tr -d ' \t\r\n')"
  log_patch "Current $PROP_MAIN: $CURRENT_PROP"

  if [ "$CURRENT_PROP" != "$PATCH_DATE" ]; then
    if command -v resetprop >/dev/null 2>&1; then
      resetprop "$PROP_MAIN" "$PATCH_DATE"
      log_step "PATCHED" "$PROP_MAIN to $PATCH_DATE"
    else
      log_step "FAILED" "resetprop not found"
    fi
  else
    log_step "SKIPPED" "All Good, Resetprop not Required"
  fi
fi

log_patch "Patch handling complete"
log_patch " "

for proc in com.google.android.gms.unstable com.google.android.gms com.android.vending; do
  kill_process "$proc"
done

log_step "REVIVED" "Droidguard Processes"

if [ -f "$FORK/app_replace_list.txt" ]; then
  cp "$BADMOSI" "$FORK"
fi

echo "--------------------------------------------"
echo " "
echo " Action completed successfully."
handle_delay
exit 0
