#!/system/bin/sh
FLAG="/data/adb/Box-Brain/downgrade"
PSH="/data/adb/modules/playintegrity/webroot/common_scripts/playstore.sh"
FLAG2="/data/adb/Box-Brain/upgrade"
PSH2="/data/adb/modules/playintegrity/webroot/common_scripts/playstore2.sh"
DESCRIPTION="/data/adb/Box-Brain/Integrity-Box-Logs/description.sh"

[ -f "$FLAG" ] && { chmod +x "$PSH" && "$PSH"; exit 0; }

[ -f "$FLAG2" ] && { chmod +x "$PSH2" && "$PSH2"; exit 0; }

echo "
────────────█───────────────█
────────────██─────────────██
─────────────███████████████
────────────█████████████████
───────────███████████████████
──────────████──█████████──████
─────────███████████████████████
────────█████████████████████████
────────█████████████████████████
───███──▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒──███
──█████─█████████████████████████─█████
──█████─████████████████──███████─█████
──█████─██████────────█──█────███─█████
──█████─█████─▓▓▓▓▓▓▓█──█▓▓─▓─███─█████
──█████─███─█─▓▓▓▓▓▓█──█▓▓─▓▓─███─█████
──█████─██──█─▓▓▓▓▓█──█▓▓─▓▓▓─███─█████
──█████─███─█─▓▓▓▓█──█▓▓─▓▓▓▓─███─█████
──█████─█████────█──█─────────███─█████
──█████─█████████──██████████████─█████
───███──████████──███████████████──███
────────█████████████████████████
─────────███████████████████████
──────────█████████████████████
─────────────██████───██████
─────────────██████───██████
─────────────██████───██████
─────────────██████───██████
──────────────████─────████
"

chmod +x "$DESCRIPTION"
sh "$DESCRIPTION"

# Network check
megatron() {
  local hosts="8.8.8.8 1.1.1.1 8.8.4.4"
  local max_attempts=5
  local attempt=1

  while [ "$attempt" -le "$max_attempts" ]; do
    echo "Internet check Attempt $attempt of $max_attempts ..."
    
    # ping host
    for h in $hosts; do
      if ping -c 1 -W 5 "$h" >/dev/null 2>&1; then
        return 0
      fi
    done

    # Try HTTP 204 fallback
    if command -v curl >/dev/null 2>&1; then
      if curl -s --max-time 5 http://clients3.google.com/generate_204 >/dev/null 2>&1; then
        return 0
      fi
    fi

    attempt=$((attempt + 1))
    sleep 3
  done

  echo "Poor/No internet connection after $max_attempts attempts."
  return 1
}

echo " "
if ! megatron; then
    exit 1
fi

OK="   ✓ OK"
FAIL="   ✗ FAIL"

MODULE="/data/adb/modules"
MODDIR="$MODULE/playintegrity"
SCRIPT_DIR="$MODDIR/webroot/common_scripts"
TARGET="$SCRIPT_DIR/user.sh"
KILL="$SCRIPT_DIR/kill.sh"
UPDATE="$SCRIPT_DIR/key.sh"
PIF="$MODULE/playintegrityfix"
TRICKY_STORE="$MODULE/tricky_store"

# Initialize counters
PASS_COUNT=0
FAIL_COUNT=0
TOTAL_STEPS=5

# print step header
start_step() {
    echo ""
    echo "[$1/${TOTAL_STEPS}] $2"
}

# delay handler
handle_delay() {
    if [ "$KSU" = "true" -o "$APATCH" = "true" ] && [ "$KSU_NEXT" != "true" ] && [ "$MMRL" != "true" ]; then
        echo -e "\nClosing in 7 seconds.."
        sleep 7
    fi
}

# run command silently, only return exit code
run_cmd_capture() {
    CMD_STR="$1"
    sh -c "$CMD_STR" >/dev/null 2>&1
    return $?
}

# Step 1
start_step 1 "Updating Tricky Store packages"
if run_cmd_capture "sh \"$TARGET\""; then
    echo "   $OK"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "   $FAIL"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Step 2
start_step 2 "Refreshing fingerprint"
if [ -f "$PIF/autopif2.sh" ]; then
    FP_SCRIPT="$PIF/autopif2.sh"
elif [ -f "$PIF/autopif.sh" ]; then
    FP_SCRIPT="$PIF/autopif.sh"
else
    FP_SCRIPT=""
fi

if [ -n "$FP_SCRIPT" ]; then
    if run_cmd_capture "sh \"$FP_SCRIPT\""; then
        echo "   $OK"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "   $FAIL"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "   $FAIL (UNKNOWN PIF DETECTED)"
    echo "   Please use PIF Fork by @osm0sis"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Step 3
start_step 3 "Applying Advanced settings to PIF"
if run_cmd_capture "sh \"$PIF/migrate.sh\" -a -f"; then
    echo "   $OK"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "   $FAIL"
    echo "   Why don't you use PIF Fork by @osm0sis?"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Step 4
start_step 4 "Updating Keybox"
if sh "$UPDATE"; then
    echo "   $OK"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "   $FAIL"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Step 5
start_step 5 "Restarting GMS process"
if run_cmd_capture "sh \"$KILL\""; then
    echo "   $OK"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "   $FAIL"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Final summary
#echo ""
#echo "============ SUMMARY ============"
#echo "✓ Passed: $PASS_COUNT"
#echo "✗ Failed: $FAIL_COUNT"
#echo "♞ Total: $TOTAL_STEPS"
#echo "================================="

handle_delay
exit 0