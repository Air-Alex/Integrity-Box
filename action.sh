#!/system/bin/sh

# Paths
MODULE="/data/adb/modules"
MODDIR="$MODULE/playintegrity"
SCRIPT_DIR="$MODDIR/webroot/common_scripts"
TARGET="$SCRIPT_DIR/user.sh"
KILL="$SCRIPT_DIR/kill.sh"
UPDATE="$SCRIPT_DIR/key.sh"
PIF="$MODULE/playintegrityfix"
PROP="/data/adb/modules/playintegrity/module.prop"
URL="https://raw.githubusercontent.com/MeowDump/Integrity-Box/refs/heads/main/DUMP/notice.md"
BAK="$PROP.bak"
FLAG="/data/adb/Box-Brain/advanced"
JSON="$PIF/custom.pif.json"

# Connectivity check
megatron() {
  hosts="8.8.8.8 1.1.1.1 8.8.4.4"
  max_attempts=5
  attempt=1
  while [ $attempt -le $max_attempts ]; do
    for h in $hosts; do
      ping -c 1 -W 5 $h >/dev/null 2>&1 && return 0
    done
    if command -v curl >/dev/null 2>&1; then
      curl -s --max-time 5 http://clients3.google.com/generate_204 >/dev/null 2>&1 && return 0
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
  return 1
}

# Print header
print_header() {
  echo
  echo "══════════════════════════════════════════"
  echo "          Integrity Box Action Log"
  echo "══════════════════════════════════════════"
  echo
  printf " %-9s | %s\n" "STATUS" "TASK"
  echo "--------------------------------------------"
}

# Track results
log_step() {
  local status="$1"
  local task="$2"
  printf " %-9s | %s\n" "$status" "$task"
}

# Exit delay
handle_delay() {
  if [ "$KSU" = "true" ] || [ "$APATCH" = "true" ] && [ "$KSU_NEXT" != "true" ] && [ "$MMRL" != "true" ]; then
    echo
    echo "Closing in 7 seconds..."
    sleep 7
  fi
}

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
if [ -f "$TARGET" ]; then
  sh "$TARGET" >/dev/null 2>&1 && log_step "OK" "Updating Target List" || log_step "FAIL" "Updating Target List"
else
  log_step "MISSING" "Updating Target List"
fi

if [ -f "$PIF/autopif2.sh" ]; then FP_SCRIPT="$PIF/autopif2.sh"
elif [ -f "$PIF/autopif.sh" ]; then FP_SCRIPT="$PIF/autopif.sh"
else FP_SCRIPT=""; fi
if [ -n "$FP_SCRIPT" ]; then
  sh "$FP_SCRIPT" >/dev/null 2>&1 && log_step "OK" "Downloading Fingerprint" || log_step "FAIL" "Downloading Fingerprint"
else
  log_step "MISSING" "Downloading Fingerprint"
fi

# Check if config exists first
if [ -f "$JSON" ]; then
  if [ -f "$FLAG" ]; then
    sh "$PIF/migrate.sh" -a -f >/dev/null 2>&1 \
      && log_step "OK" "Applying Advanced PIF Settings" \
      || log_step "FAIL" "Applying Advanced PIF Settings"
  else
    echo " ⚠️          Advanced PIF Setting is disabled by you"
  fi
fi

if [ -f "$UPDATE" ]; then
  sh "$UPDATE" >/dev/null 2>&1 && log_step "OK" "Updating Keybox" || log_step "FAIL" "Updating Keybox"
else
  log_step "MISSING" "Updating Keybox"
fi

if [ -f "$KILL" ]; then
  sh "$KILL" >/dev/null 2>&1 && log_step "OK" "Restarting GMS Services" || log_step "FAIL" "Restarting GMS Services"
else
  log_step "MISSING" "Restarting GMS Services"
fi

echo "--------------------------------------------"
echo " "
echo " Action completed successfully."
handle_delay
exit 0