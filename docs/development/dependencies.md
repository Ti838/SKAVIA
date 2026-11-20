# Dependency Audit & Technology Stack

## 1. Flutter Mobile Dependencies (`pubspec.yaml`)

| Package | Version | Purpose | Architectural Rationale |
| :--- | :--- | :--- | :--- |
| `flutter` | SDK | Core UI framework | Cross-platform Material Design 3 engine. |
| `device_info_plus` | `^13.3.0` | Hardware telemetry | Safely reads manufacturer, model, SDK int, and ABIs. |
| `geolocator` | `^14.1.1` | Location services | GPS availability & Haversine technician dispatch. |
| `permission_handler` | `^11.3.1` | Permissions | Runtime permissions check for camera, location, and alerts. |
| `flutter_local_notifications` | `^18.0.1` | System alerts | Urgent dispatch notifications and arrival OTP alerts. |
| `shared_preferences` | `^2.5.5` | Key-value store | User preferences and non-sensitive UI state cache. |
| `flutter_secure_storage` | `^9.2.4` | Keystore encryption | Encrypted authentication tokens & user credentials. |
| `http` | `^1.6.0` | Network client | Edge ping latency probe & in-app update binary download. |
| `supabase_flutter` | `^2.8.4` | Backend SDK | PostgreSQL PostgREST queries, Realtime, and RPC calls. |
| `firebase_core` | `^3.12.1` | Cloud identity | Firebase initialization. |
| `firebase_auth` | `^5.5.1` | Phone SMS OTP | Cellular authentication & Google Sign-In. |
| `package_info_plus` | `^10.2.2` | App metadata | Resolves installed package version and build number. |
| `url_launcher` | `^6.3.3` | External browser | Support URLs and terms of service links. |

---

## 2. Web Administration Dependencies (`admin-web/package.json`)

| Package | Version | Purpose |
| :--- | :--- | :--- |
| `next` | `15.5.29` | React server-side rendering framework with App Router. |
| `react` / `react-dom` | `19.0.0` | Modern reactive UI engine with server actions. |
| `@supabase/supabase-js` | `^2.49.1` | Server-side PostgREST client with service-role authority. |
| `@simplewebauthn/browser` / `server` | `^13.1.0` | FIDO2 / WebAuthn hardware passkey registration & authentication. |
| `lucide-react` | `^0.475.0` | Consistent SVG icon library. |
| `tailwindcss` | `^4.0.0` | Utility-first responsive design tokens. |
| `vitest` | `^3.0.5` | Fast ESM unit and integration test runner. |
