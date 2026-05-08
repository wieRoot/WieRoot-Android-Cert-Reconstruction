#!/data/data/com.termux/files/usr/bin/bash

# CONFIGURATION
APP_NAME="Gmail"
APK_FILE="$1"
CERT_NAME="WieRoot-Root-CA"
WORK_DIR="./patch_work"

if [ -z "$APK_FILE" ]; then
    echo "Usage: $0 <path_to_apk_file>"
    exit 1
fi

echo "🔧 Starting Patch for $APP_NAME..."

# 1. Setup Work Directory
rm -rf $WORK_DIR
mkdir -p $WORK_DIR
cp $APK_FILE $WORK_DIR/original.apk

# 2. Decompile
echo "📦 Decompiling APK..."
apktool d $WORK_DIR/original.apk -o $WORK_DIR/decompiled

# 3. Locate and Patch network_security_config.xml
CONFIG_PATH=""
for path in "$WORK_DIR/decompiled/res/xml/network_security_config.xml"; do
    if [ -f "$path" ]; then
        CONFIG_PATH="$path"
        break
    fi
done

if [ -z "$CONFIG_PATH" ]; then
    mkdir -p "$WORK_DIR/decompiled/res/xml"
    CONFIG_PATH="$WORK_DIR/decompiled/res/xml/network_security_config.xml"
    echo "Creating new network_security_config.xml..."
else
    echo "Found existing config at: $CONFIG_PATH"
fi

# 4. Inject the "Trust User" Rule
cat > "$CONFIG_PATH" <<EOF
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
EOF

echo "✅ Patched network_security_config.xml to trust User CAs."

# 5. Recompile
echo "🔄 Recompiling APK..."
apktool b $WORK_DIR/decompiled -o $WORK_DIR/patched_unsigned.apk

# 6. Sign the APK
echo "🔐 Signing APK..."
if [ ! -f "$HOME/debug.keystore" ]; then
    keytool -genkeypair -alias androiddebugkey -keypass android -keystore $HOME/debug.keystore -storepass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" 2>/dev/null
fi

apksigner sign --ks $HOME/debug.keystore --ks-key-alias androiddebugkey --ks-pass pass:android --key-pass pass:android $WORK_DIR/patched_unsigned.apk

# 7. Finalize
mv $WORK_DIR/patched_unsigned.apk "${APP_NAME}_Patched.apk"

echo "🎉 Done! Install: ${APP_NAME}_Patched.apk"
echo "⚠️  WARNING: You must uninstall the original app first!"
