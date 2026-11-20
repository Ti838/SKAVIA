# iOS Release & Web App (PWA) Distribution

## 1. Apple Ecosystem Strategy

SKAVIA serves Apple iPhone and iPad users through a dual-channel strategy:
1. **Responsive Web App (PWA):**  
   The Next.js 15 web application (`admin-web/`) functions as a full Progressive Web App with service worker caching, WebAuthn passkey authentication, and responsive layout matching the native mobile experience.
2. **Native iOS Build:**  
   The Flutter codebase maintains an updated `ios/` workspace ready for Xcode archive generation when deploying to Apple TestFlight and the App Store.

---

## 2. iOS Native Verification

```powershell
# Open iOS project in Xcode on macOS
cd ios
pod install
open Runner.xcworkspace
```

Ensure capabilities are enabled in Xcode:
- Background Modes (Remote Notifications)
- Camera Usage Description (`NSCameraUsageDescription`)
- Location When In Use Description (`NSLocationWhenInUseUsageDescription`)
