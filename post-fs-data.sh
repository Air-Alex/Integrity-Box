#!/system/bin/sh

placeholder="/data/adb/modules/playintegrity/webroot/common_scripts"

cat <<'EOF' > "/data/adb/Box-Brain/Integrity-Box-Logs/description.sh"

#!/system/bin/sh

MODULE="/data/adb/modules"
MODDIR="$MODULE/playintegrity"
PIF="$MODULE/playintegrityfix"
SHAMIKO="$MODULE/playintegrity_shamiko"
NOHELLO="$MODULE/playintegrity_nohello"
TRICKY_STORE="$MODULE/tricky_store"
SUSFS="$MODULE/susfs4ksu"

# Utility
append_item() {
    if [ -z "$1" ]; then
        echo "$2"
    else
        echo "$1 | $2"
    fi
}

safe_version() {
    dumpsys package "$1" 2>/dev/null | awk -F= '/versionName/{print $2; exit}'
}

# Module state
ENABLED_LIST=""
DISABLED_LIST=""

[ -d "$SHAMIKO" ]      && ENABLED_LIST=$(append_item "$ENABLED_LIST" "Shamiko ✔")     || DISABLED_LIST=$(append_item "$DISABLED_LIST" "Shamiko ✘")
[ -d "$TRICKY_STORE" ] && ENABLED_LIST=$(append_item "$ENABLED_LIST" "TrickyStore ✔") || DISABLED_LIST=$(append_item "$DISABLED_LIST" "TrickyStore ✘")
[ -d "$NOHELLO" ]      && ENABLED_LIST=$(append_item "$ENABLED_LIST" "NoHello ✔")     || DISABLED_LIST=$(append_item "$DISABLED_LIST" "NoHello ✘")
[ -d "$SUSFS" ]        && ENABLED_LIST=$(append_item "$ENABLED_LIST" "SusFS ✔")       || DISABLED_LIST=$(append_item "$DISABLED_LIST" "SusFS ✘")
[ -d "$PIF" ]          && ENABLED_LIST=$(append_item "$ENABLED_LIST" "PIF ✔")         || DISABLED_LIST=$(append_item "$DISABLED_LIST" "PIF ✘")

# Risky app detection
RISKY_APPS="com.rifsxd.ksunext
me.weishu.kernelsu
com.google.android.hmal
com.reveny.vbmetafix.service
me.twrp.twrpapp
com.termux
bin.mt.plus
org.swiftapps.swiftbackup
ru.mike.updatelocker
com.coderstory.toolkit
ru.maximoff.apktool
io.github.muntashirakon.AppManager.debug
io.github.a13e300.ksuwebui
com.slash.batterychargelimit
io.github.vvb2060.keyattestation
io.github.qwq233.keyattestation
io.github.muntashirakon.AppManager
io.github.vvb2060.mahoshojo
com.reveny.nativecheck
icu.nullptr.nativetest
io.github.huskydg.memorydetector
org.akanework.checker
icu.nullptr.applistdetector
io.github.rabehx.securify
krypton.tbsafetychecker
me.garfieldhan.holmes
com.byxiaorun.detector
com.kimchangyoun.rootbeerFresh.sample"

RISKY_COUNT=0
for PKG in $RISKY_APPS; do
    if pm list packages | grep -q "$PKG"; then
        RISKY_COUNT=$((RISKY_COUNT + 1))
    fi
done

# Spoofed versionName check
for PKG in $(pm list packages -3 | cut -d':' -f2); do
    VERSION=$(safe_version "$PKG")
    if echo "$VERSION" | grep -qi "spoofed"; then
        RISKY_COUNT=$((RISKY_COUNT + 1))
    fi
done

# Counts & info
ALL_COUNT=$(find "$MODULE" -mindepth 1 -maxdepth 1 -type d | wc -l)

DEVICE_MODEL=$(getprop ro.product.system.model)
[ -z "$DEVICE_MODEL" ] && DEVICE_MODEL=$(getprop ro.build.product)

ANDROID_VERSION=$(getprop ro.build.version.release)
PATCH=$(getprop ro.build.version.security_patch)

SELINUX_RAW=$(getenforce)
if [ "$SELINUX_RAW" = "Enforcing" ]; then
    SELINUX="🟢"
else
    SELINUX="🔴"
fi

# Play Store version
PSTORE_VER=$(safe_version "com.android.vending" | awk '{print $1}')
[ -z "$PSTORE_VER" ] && PSTORE_VER="N/A"

# Kernel check
BANNED_KERNELS="AICP arter97 blu_spark CAF cm crDroid crdroid CyanogenMod Deathly EAS eas ElementalX Elite franco hadesKernel Lineage LineageOS mokee MoRoKernel Noble Optimus SlimRoms Sultan"
KERNEL_NAME=$(uname -r)
KERNEL_STATUS="🟢"
for banned in $BANNED_KERNELS; do
    if echo "$KERNEL_NAME" | grep -iqE "(^|[^a-zA-Z0-9])$banned([^a-zA-Z0-9]|$)"; then
        KERNEL_STATUS="🔴"
        break
    fi
done

# TEE status
TEE_FILE="/data/adb/tricky_store/tee_status"
if [ -f "$TEE_FILE" ]; then
    TEE_VAL=$(grep -m1 "teeBroken=" "$TEE_FILE" | cut -d'=' -f2)
    case "$TEE_VAL" in
        true)  TEE_STATUS="🔴" ;;
        false) TEE_STATUS="🟢" ;;
        *)     TEE_STATUS="🟢" ;;
    esac
else
    TEE_STATUS="🟢"
fi

# ROM signature
if [ -f /system/etc/security/otacerts.zip ]; then
    ROM_SIGN=$(unzip -l /system/etc/security/otacerts.zip 2>/dev/null | awk '/\.pem$/ {print $4; exit}')
    case "$ROM_SIGN" in
        *release*) ROM_SIGN_STATUS="🟢" ;;
        *test*)    ROM_SIGN_STATUS="🔴" ;;
        *)         ROM_SIGN_STATUS="🟢" ;;
    esac
else
    ROM_SIGN_STATUS="⚪"
fi

# Description string
ALL_MODULES="$ENABLED_LIST"
[ -n "$DISABLED_LIST" ] && ALL_MODULES="$ALL_MODULES | $DISABLED_LIST"

DESCRIPTION="description=𝗮𝘀𝘀𝗶𝘀𝘁 𝗺𝗼𝗱𝗲: $ALL_MODULES  | 𝗞𝗲𝗿𝗻𝗲𝗹: $KERNEL_STATUS | 𝗥𝗢𝗠 𝗦𝗶𝗴𝗻: $ROM_SIGN_STATUS | 𝗦𝗘.𝗟𝗶𝗻𝘂𝘅: $SELINUX | 𝗥𝗶𝘀𝗸𝘆: $RISKY_COUNT | 𝗣𝘀𝘁𝗼𝗿𝗲: $PSTORE_VER | 𝗔𝗹𝗹: $ALL_COUNT | 𝗣𝗮𝘁𝗰𝗵: $PATCH | A$ANDROID_VERSION $DEVICE_MODEL" 
# | 𝗧𝗘𝗘: $TEE_STATUS

# Update module.prop
TMPFILE=$(mktemp)

if grep -q "^description=" "$MODDIR/module.prop"; then
    awk -v desc="$DESCRIPTION" 'BEGIN{OFS=FS} 
        /^description=/{print desc; next} 
        {print}' "$MODDIR/module.prop" > "$TMPFILE" && mv "$TMPFILE" "$MODDIR/module.prop"
else
    echo "$DESCRIPTION" >> "$MODDIR/module.prop"
fi
EOF

chmod 755 "/data/adb/Box-Brain/Integrity-Box-Logs/description.sh"

if [ -f "/data/adb/modules/playintegrity/customize.sh" ]; then
  rm -rf "/data/adb/modules/playintegrity/customize.sh"
fi

# create dummy placeholder files to fix broken translations in webui
touch "$placeholder/meowverse.sh"
touch "$placeholder/report.sh"