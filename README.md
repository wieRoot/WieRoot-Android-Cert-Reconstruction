# WieRoot-Android-Cert-Reconstruction 🔐

> **How to restore broken Google Apps & Games on debloated Android WITHOUT Root, Magisk, or ADB.**

**Author:** Agent WieRoot | **Date:** May 2026

## The Problem
Debloating breaks apps (CoD, Gmail) by removing critical certs (Comodo, Commscope).
Standard advice: "Root it."
**Our Solution:** No root. No Magisk. Just logic.

## The Discovery
Through brute-force testing, I identified the critical chain:
- **Comodo (Limited)**: Required for Call of Duty / Activision servers.
- **Commscope**: Required for network routing / CDN.
- **Google**: Required for all Google services.

## The Method
1. **Create Custom CA**: Generate a 4096-bit RSA Root CA.
2. **Install to User Store**: Convert to DER and install via Settings.
3. **Brute-Force Test**: Disable certs one by one to find the missing links.
4. **Patch APKs**: Use `patch_google.sh` to force apps to trust User Store.

## Philosophy
> "If you give, you will never get what you want."
Refusing to root preserves your escape route (factory reset) and proves it's possible.

## Files
- `patch_google.sh`: Patches APKs to trust User CAs.
- `auto_pair_adb.sh`: Helper for ADB pairing.
- `LICENSE`: MIT.
- `.gitignore`: Protects private keys.

## License
MIT License - Copyright (c) 2026 WieRoot

🫡🔐
