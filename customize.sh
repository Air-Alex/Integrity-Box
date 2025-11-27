#!/system/bin/sh

# Module and log directory paths
MODDIR="${0%/*}"
LOG_DIR="/data/adb/Box-Brain/Integrity-Box-Logs"
INSTALL_LOG="$LOG_DIR/Installation.log"
SCRIPT="$MODPATH/webroot/common_scripts"
SRC="/data/adb/modules_update/playintegrity/module.prop"
DEST="/data/adb/modules/playintegrity/module.prop"
FLAG="/data/adb/Box-Brain"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR" || true

# Logger
debug() {
    echo "$1" | tee -a "$INSTALL_LOG"
}

# Module info variables
MODNAME=$(grep_prop name $TMPDIR/module.prop)
MODVER=$(grep_prop version $TMPDIR/module.prop)
AUTHOR=$(grep_prop author $TMPDIR/module.prop)
TIME=$(date "+%d, %b - %H:%M %Z")

# Gather system information
BRAND=$(getprop ro.product.brand)
MODEL=$(getprop ro.product.model)
DEVICE=$(getprop ro.product.device)
ANDROID=$(getprop ro.system.build.version.release)
SDK=$(getprop ro.system.build.version.sdk)
ARCH=$(getprop ro.product.cpu.abi)
BUILD_DATE=$(getprop ro.system.build.date)
ROM_TYPE=$(getprop ro.system.build.type)
FINGERPRINT=$(getprop ro.system.build.fingerprint)
SE=$(getenforce)
KERNEL=$(uname -r)

# Display module details
display_header() {
    debug
    debug "========================================="
    debug "          Module Information     "
    debug "========================================="
    debug " ✦ Module Name   : $MODNAME"
    debug " ✦ Version       : $MODVER"
    debug " ✦ Author        : $AUTHOR"
    debug " ✦ Started at    : $TIME"
    debug "_________________________________________"
    debug
    debug
    debug
}

# Verify module integrity
check_integrity() {
    debug "========================================="
    debug "          Integrity Box Installer    "
    debug "========================================="
    debug " ✦ Verifying Module Integrity    "
    
    if [ -n "$ZIPFILE" ] && [ -f "$ZIPFILE" ]; then
        if [ -f "$MODPATH/verify.sh" ]; then
            if sh "$MODPATH/verify.sh"; then
                debug " ✦ Module integrity verified." > /dev/null 2>&1
            else
                debug " ✘ Module integrity check failed!"
                exit 1
            fi
        else
            debug " ✘ Missing verification script!"
            exit 1
        fi
    fi
}

# Setup environment and permissions
setup_environment() {
    debug " ✦ Setting up Environment "
    chmod +x "$MODPATH/action.sh"
    sh "$MODPATH/action.sh" > /dev/null 2>&1
}

# Clean up old logs and files
cleanup() {
    chmod +x "$SCRIPT/cleanup.sh"
    sh "$SCRIPT/cleanup.sh"
}

setup_keybox() {
  local MOD="$1/toolbox"
  local TRICKY="/data/adb/tricky_store"
  local files="secondary_keybox.xml aosp_keybox.xml"

  # Create target directory if missing
  [ ! -d "$TRICKY" ] && mkdir -p "$TRICKY" && chmod 700 "$TRICKY"

  # Move files
  for f in $files; do
    local src="$MOD/$f"
    local dst="$TRICKY/$f"
    [ ! -f "$dst" ] && mv "$src" "$dst" && chmod 600 "$dst"
  done
}

# Create necessary directories if missing
prepare_directories() {
    debug " ✦ Preparing Required Directories  "
    [ ! -d "/data/adb/modules/playintegrity" ] && mkdir -p "/data/adb/modules/playintegrity"
    [ ! -f "$SRC" ] && return 1
}

# Handle module prop file
handle_module_props() {
    debug " ✦ Handling Module Properties "
    touch "/data/adb/modules/playintegrity/update"
    cp "$SRC" "$DEST"
}

# Verify boot hash file
check_boot_hash() {
    debug " ✦ Creating Verified Boot Hash config     "
    if [ ! -f "/data/adb/Box-Brain/hash.txt" ]; then
        touch "/data/adb/Box-Brain/hash.txt"
    fi
}

# Gather additional system info
gather_system_info() {
    debug "========================================="
    debug "          Gathering System Info "
    debug "========================================="
    debug " ✦ Device Brand   : $BRAND"
    debug " ✦ Device Model   : $MODEL"
    debug " ✦ Android Version: $ANDROID (SDK $SDK)"
    debug " ✦ Architecture   : $ARCH"
    debug " ✦ Kernel Version : $KERNEL"
    debug " ✦ SELinux Status : $SE"
    debug " ✦ ROM Type       : $ROM_TYPE"
    debug " ✦ Build Date     : $BUILD_DATE"
    debug " ✦ Fingerprint    : $FINGERPRINT"
    debug "_________________________________________"
    debug
    debug
    debug
}

# Release the source
release_source() {
    [ -f "/data/adb/Box-Brain/noredirect" ] && return 0
    nohup am start -a android.intent.action.VIEW -d "https://t.me/MeowDump" > /dev/null 2>&1 &
}

# Enable recommended settings
enable_recommended_settings() {
    debug " ✦ Enabling Recommended Settings "
    touch "$FLAG/advanced"
#    touch "$FLAG/playstore"
#    touch "$FLAG/gms"
    touch "$FLAG/encrypt"
    touch "$FLAG/noredirect"
    touch "$FLAG/nodebug"
    touch "$FLAG/selinux"
    debug "_________________________________________"
    debug
    debug
    debug
}

# Final footer message
display_footer() {
    debug "             Installation Completed "
    debug "   This module was released by 𝗠𝗘𝗢𝗪 𝗗𝗨𝗠𝗣"
    debug
    debug
}

# Main installation flow
install_module() {
    display_header
    gather_system_info
    check_integrity
    setup_environment
    prepare_directories
    cleanup
    check_boot_hash
    setup_keybox "$MODPATH"
    handle_module_props
    release_source
    enable_recommended_settings
    display_footer
}

echo "
    ____      __                  _ __       
   /  _/___  / /____  ____ ______(_) /___  __
   / // __ \/ __/ _ \/ __ / ___/ / __/  / / /
 _/ // / / / /_/  __/ /_/ / /  / / /_/ /_/ / 
/___/_/ /_/\__/\___/\__, /_/  /_/\__/\__, /  
                   /____/           /____/           
             ____            
            / __ )____  _  __
           / __  / __ \| |/_/
          / /_/ / /_/ />  <  
         /_____/\____/_/|_|  
                    
"

# Quote of the day 
cat <<EOF > $LOG_DIR/.verify
YourMindIsAWeaponTrainItToSeeOpportunityNotObstacles
EOF

# Start the installation process
install_module

exit 0
