#!/data/data/com.termux/files/usr/bin/bash

# Configuration
PHONE_IP="YOUR_PHONE_IP_HERE"  # Replace with your actual IP
PAIRING_PORT=""          # Will be filled by user
PAIRING_CODE=""          # Will be filled by user

echo "🔐 Auto-Pair ADB Script"
echo "========================"
echo "1. Open Settings > Developer Options > Wireless Debugging"
echo "2. Tap 'Pair device with pairing code'"
echo "3. Note the IP:Port and 6-digit code"
echo ""
read -p "Enter Pairing Port (e.g., 45678): " PAIRING_PORT
read -p "Enter 6-digit Pairing Code: " PAIRING_CODE

if [ -z "$PAIRING_PORT" ] || [ -z "$PAIRING_CODE" ]; then
    echo "❌ Missing information. Exiting."
    exit 1
fi

echo "🔄 Starting ADB server..."
adb kill-server
adb start-server

echo "🔗 Attempting to pair with $PHONE_IP:$PAIRING_PORT..."
adb pair "$PHONE_IP:$PAIRING_PORT" <<< "$PAIRING_CODE"

if [ $? -eq 0 ]; then
    echo "✅ Pairing successful!"
    
    # Get the main port (user needs to provide this)
    read -p "Enter Main Connection Port (from Wireless Debugging screen): " MAIN_PORT
    
    echo "🔌 Connecting to $PHONE_IP:$MAIN_PORT..."
    adb connect "$PHONE_IP:$MAIN_PORT"
    
    if [ $? -eq 0 ]; then
        echo "✅ Connected!"
        adb devices
        echo "🎉 Ready to push certificate!"
        
        # Push certificate automatically
        HASH=$(openssl x509 -inform PEM -subject_hash_old -in ~/ca_backup/root_ca.crt | head -1)
        cp ~/ca_backup/root_ca.crt $PREFIX/tmp/${HASH}.0
        
        adb shell "mkdir -p /data/local/tmp/cacerts"
        adb push $PREFIX/tmp/${HASH}.0 /data/local/tmp/cacerts/
        adb shell "cp /system/etc/security/cacerts/* /data/local/tmp/cacerts/"
        adb shell "mount -t tmpfs tmpfs /system/etc/security/cacerts"
        adb shell "cp /data/local/tmp/cacerts/* /system/etc/security/cacerts/"
        adb shell "chmod 644 /system/etc/security/cacerts/*"
        adb shell "chown root:root /system/etc/security/cacerts/*"
        adb shell "rm -rf /data/local/tmp/cacerts"
        
        echo "✅ Certificate pushed! Reboot now."
        adb reboot
    else
        echo "❌ Connection failed."
    fi
else
    echo "❌ Pairing failed."
fi
