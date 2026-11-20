# Android Production Release & Keystore Signing

## 1. Keystore Configuration

To build production release APKs with certificate continuity:

1. Create a secure keystore (if not already existing):
   ```powershell
   keytool -genkey -v -keystore skavia-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias skavia
   ```
2. Configure `android/key.properties` (never commit this file; ensure it is in `.gitignore`):
   ```ini
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=skavia
   storeFile=../skavia-release.jks
   ```

---

## 2. Generating Per-ABI APKs

SKAVIA builds lightweight per-ABI APKs to reduce client download sizes:

```powershell
# Clean build artifacts
flutter clean
flutter pub get

# Build split-per-abi release APKs
flutter build apk --split-per-abi --release
```

Generated outputs in `build/app/outputs/flutter-apk/`:
- `app-arm64-v8a-release.apk` (~22.6 MB): Modern 5G and 64-bit 4G devices.
- `app-armeabi-v7a-release.apk` (~20.3 MB): Legacy 32-bit budget devices.

---

## 3. Uploading to Private Release Registry

Upload the built APKs to Supabase Storage `app-releases` and publish via the Super Admin portal at `/releases` to activate auto-recommendation on `https://www.skavia.com`.
