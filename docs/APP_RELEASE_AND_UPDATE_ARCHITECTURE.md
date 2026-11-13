# SKAVIA — App Release Management, Secure APK Distribution & Android In-App Update Architecture

> **Status:** Production Implementation Complete (`supabase/`, `admin-web/`, `lib/`, `android/`)
> **Scope:** Shared Supabase Backend (`supabase/`), SKAVIA Super Admin Portal & Public Website (`admin-web/`), SKAVIA Flutter Android Application (`lib/`, `android/`)

---

## 1. Phase 1 — Industry Research & Architectural Selection

### 1.1 Comparative Evaluation of Android Distribution Models

| Approach | How It Works | Applicability to SKAVIA | Decision |
| --- | --- | --- | --- |
| **Google Play Core (`AppUpdateManager`)** | Delegates version check, delta patching, and silent install to Google Play Store Services (`PLAY_STORE` installer). | Fails when sideloaded or distributed directly via `skavia.com` because Play Store does not own non-Play installs and no Play Store listing exists during direct APK distribution. | **Rejected for primary flow** (direct website distribution requires independent metadata + APK delivery). |
| **Firebase App Distribution SDK** | Tester-centric pre-release SDK; requires Firebase Tester accounts and browser OAuth redirects; throttled/unsuited for general consumer production upgrades. | Not built for end-user production auto-updates or public website downloads without tester enrollment. | **Rejected for runtime updater** (patterns borrowed for release history & channel separation). |
| **GitHub Releases + External Browser Redirect (`url_launcher`)** | Static GitHub release assets + browser download fallback. | Publicly exposes draft/pre-release repo structure or lacks Super Admin governance, rollback controls, certificate pinning verification, and controlled notification throttling. | **Rejected as primary hosting**; kept only as architecture reference for release assets + SHA-256 manifests. |
| **Dedicated SKAVIA Release Registry + Private Storage + Signed Server Verification + In-App APK Downloader & `FileProvider` Install Handoff (Selected)** | Super Admin uploads APK to private Supabase Storage (`app-releases`), Next.js backend cryptographically inspects the ZIP/AXML/APK Signing Block v2/v3 (`packageName`, `versionCode`, `versionName`, signing cert SHA-256, file SHA-256), manages lifecycle (`draft -> validated -> published -> suspended -> archived`), dynamically serves website `#download` & Flutter update endpoints, and Flutter downloads, verifies SHA-256, checks `canRequestPackageInstalls()`, and hands off `content://` URI to Android Package Installer via `ACTION_VIEW`. | Gives full control over mandatory/optional enforcement, zero website redeploy on publish, strict certificate-continuity checks (preventing failed updates or signature mismatch), zero exposed drafts, and real download/check telemetry. | **Selected Architecture** |

### 1.2 Android Platform Security & Installer Mechanics

1. **Signing & Upgrade Continuity (`apksigner` / APK Signature Scheme v2/v3):**
   - Android enforces identical **applicationId** (`com.example.skavia` in `android/app/build.gradle.kts`) and **compatible signing certificate digest** across every in-place update.
   - If an APK is signed with a mismatched certificate (e.g., uploading a CI debug-signed APK over a release-signed installation, or vice versa), Android's installer fails with `INSTALL_FAILED_UPDATE_INCOMPATIBLE` / "App not installed as package appears to be invalid".
   - All SKAVIA user data (SharedPreferences, SQLite/local caches, `SecureStorageService`, and Firebase Auth persistent Android token) stays intact ONLY when updated in-place with matching `applicationId` and signing key.
   - **Rule:** Never allow publishing an APK whose package name differs from `com.example.skavia` or whose APK v2/v3 X.509 certificate SHA-256 fingerprint mismatches the configured/pinned SKAVIA signing fingerprint (unless bootstrapping the very first pinned fingerprint explicitly authorized by Primary Super Admin).

2. **Android 8.0+ (`REQUEST_INSTALL_PACKAGES`) & Android 14/15 Behavior:**
   - AndroidManifest must declare `<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />`.
   - Runtime check via `PackageManager.canRequestPackageInstalls()`. If `false`, the app guides the user via `Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES` (`Uri.parse("package:$packageName")`) and cleanly resumes/re-checks on return (`WidgetsBindingObserver.didChangeAppLifecycleState`).
   - APK files downloaded inside app-private storage (`cacheDir/updates/*.apk`) MUST be shared with the OS Package Installer using `androidx.core.content.FileProvider` (`content://com.example.skavia.fileprovider/...`) with `Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK` and MIME `application/vnd.android.package-archive` (`file://` URIs throw `FileUriExposedException` on Android 7+).
   - **Important Android Version Downgrade Rule:** Android forbids installing a lower `versionCode` over a higher installed `versionCode` (`INSTALL_FAILED_VERSION_DOWNGRADE`). Therefore, Super Admin **Rollback** switches the active public/update pointer back to a prior verified release immediately for all users not yet on the faulty build AND marks the faulty build `suspended`, while warning the Super Admin that any devices already running the higher faulty `versionCode` require a higher patch `versionCode` (`N + 1`) to upgrade cleanly.

---

## 2. Phase 1 — Existing SKAVIA Codebase Audit

### 2.1 Flutter Mobile Application (`lib/`, `android/`, `pubspec.yaml`)

- **`pubspec.yaml`**:
  - App currently pinned at `version: 1.0.0+1`, Dart SDK `^3.13.2`.
  - Already includes required packages: `package_info_plus: ^10.2.2`, `url_launcher: ^6.3.3`, `flutter_local_notifications: 18.0.1`, `permission_handler: 11.3.1`, `shared_preferences: ^2.5.5`, `http: ^1.6.0`, `supabase_flutter: ^2.8.4`.
  - No `crypto` dependency currently declared in `pubspec.yaml`, nor any native `install_plugin`/`open_file` bloat. SHA-256 verification can either add `crypto` cleanly OR invoke Kotlin's `java.security.MessageDigest.getInstance("SHA-256")` over `MethodChannel` (plus pure-Dart test coverage), avoiding unmaintained native third-party plugins.
- **`android/app/build.gradle.kts` & Local Keystore Status**:
  - `namespace = "com.example.skavia"`, `applicationId = "com.example.skavia"`.
  - `buildTypes.release` currently uses `signingConfig = signingConfigs.getByName("debug")` and `android/key.properties` does not exist.
  - Action plan: Update `build.gradle.kts` cleanly to use `key.properties` when present with safe fallback to debug signing if absent (never commit `.jks` or `key.properties`; `.gitignore` must ignore `key.properties`, `*.jks`, `*.keystore`).
- **`android/app/src/main/AndroidManifest.xml` & `MainActivity.kt`**:
  - Lacks `REQUEST_INSTALL_PACKAGES` permission and `<provider>` (`androidx.core.content.FileProvider`).
  - `MainActivity.kt` cleanly uses Flutter `MethodChannel` (`skavia/media_picker`). Adding a dedicated `MethodChannel("skavia/app_installer")` handles `canRequestPackageInstalls`, `openUnknownAppSourcesSettings`, `computeFileSha256`, and `installApk` cleanly on Android 8–15+.
- **App Entry, Splash & Navigation (`lib/main.dart`, `lib/app/bootstrap.dart`, `splash_screen.dart`, `main_scaffold_screen.dart`)**:
  - `AppBootstrap.init()` initializes `LocalCacheService`, `SecureStorageService`, Firebase Core, Supabase client, `NotificationService`, `NotificationCenterController` (tied to `FirebaseAuth.instance.authStateChanges()`), and offline sync queue.
  - `SplashScreen` waits ~2s and routes to `AppRoutes.appShell`, `AppRoutes.roleSelection`, or `AppRoutes.onboarding`.
  - `MainScaffoldScreen` hosts the authenticated root experience (`CustomerDashboardView`, `WorkerDashboardView`, etc.) — ideal place for `WidgetsBindingObserver` foreground resume update checks, optional `AppUpdateBanner`, non-blocking optional `AppUpdateDialog`, and blocking `AppUpdateScreen` when a mandatory update is active!
- **Notifications, Settings & About SKAVIA**:
  - `NotificationService` (`lib/core/services/notification_service.dart`) initializes `skavia_urgent_channel` and `skavia_general_channel` with tap stream `onNotificationTapped` (payload routing needs wiring or release deep-link handling).
  - `NotificationCenterController` (`lib/features/notifications/presentation/controllers/notification_center_controller.dart`) supports `dedupKey` idempotency, `actionRoute`, `metadata`, and filters (`NotificationCenterScreen` currently checks `'All'`, `'Unread'`, `'Bookings'`, `'Gifts & Profile'` — can support `'Updates'` / `'urgent'` category cleanly).
  - `AboutSkaviaScreen` displays hardcoded-fallback `AppConfig.appVersion+1` overridden by `PackageInfo.fromPlatform()`, with no update status or "Check for Updates" button yet.
  - `SettingsScreen` (`lib/features/profile/presentation/screens/settings_screen.dart`) lacks an App Updates section.
  - `AppRoutes` (`lib/app/router/app_routes.dart`) & `AppRouter` (`lib/app/router/app_router.dart`) need a registered `/app-update` route (`AppRoutes.appUpdate`).

### 2.2 Admin Web Portal & Public Website (`admin-web/`)

- **Hosting & Surface Isolation (`src/server/auth/surface.ts`, `AdminShell.tsx`)**:
  - Surfaces strictly isolated across `public` (`www.skavia.com`), `superadmin` (`superadmin.skavia.com`), and `admin` (`admin.skavia.com`).
  - `AdminShell.tsx` enforces `primarySuperAdminOnly` for Governance routes (`/admins`, `/security`). App Release Management belongs strictly under `Governance` with `primarySuperAdminOnly: true`, permission `release.manage` / `release.publish`, AND Step-Up MFA (`STEP_UP_REQUIRED_PERMISSIONS`).
- **Existing Distribution Endpoint & Website**:
  - `src/app/api/public/distribution/route.ts` currently returns static environment variables (`NEXT_PUBLIC_ANDROID_APK_URL`, `NEXT_PUBLIC_ANDROID_VERSION`, `NEXT_PUBLIC_IOS_APP_STORE_URL`).
  - `src/features/public-website/PublicWebsiteScreen.tsx` fetches `/api/public/distribution` dynamically on mount and renders `DownloadSection` (`PublicEcosystemSections.tsx`).
  - `next.config.ts` sets strict CSP headers (`connect-src 'self' https://*.supabase.co ...`). Direct signed uploads/downloads with Supabase Storage work within existing CSP!
- **Server Repository Architecture (`src/server/db/`)**:
  - Dual-implementation parity: `AdminRepository` (`repository.ts`), modular `Supabase*Store` classes under `stores/`, wired in `supabase-store.ts`, plus `InMemoryAdminRepository` in `admin-web/tests/helpers/in-memory-store.ts`. Both Supabase production and Vitest in-memory harness must implement the Release store cleanly.
- **Local Machine Build Tools Verified**:
  - `JDK 17` (`java.exe`, `keytool.exe`), `adb.exe`, and Android Build Tools `36.0.0` (`aapt2.exe`, `apksigner.bat`, `zipalign.exe`) are available on the workstation. However, production cloud web deployments (e.g., Node/Vercel) cannot assume Android SDK binaries exist on the host; therefore server-side APK inspection MUST use pure Node/TypeScript ZIP + AXML + APK Signing Block v2/v3 parsing (with optional `apksigner`/`aapt2` cross-check when configured locally).

### 2.3 Shared Supabase Backend (`supabase/`)

- Existing `system_settings` table stores general key/value pairs (`default_commission_percent`, etc.), which lacks release history, per-release SHA-256, build sequence uniqueness, lifecycle status (`draft`, `validated`, `published`, `suspended`, `archived`), rollback pointer auditability, and channel pointers.
- Existing `audit_logs` table is enforced append-only via `trg_audit_logs_immutable`.
- Existing `user_notifications` table supports `dedup_key`, `category`, `action_route`, and `metadata` per user.
- Existing Storage buckets (`verifications`, `avatars`, `portfolios`, `certificates`, `attachments`) are domain-specific; none exist for APK release binaries.

---

## 3. Phase 2 — Target System Architecture

### 3.1 Architecture Decisions

1. **Dedicated Release Tables vs `system_settings`**:
   - Create dedicated tables `public.app_releases` (immutable history per release artifact, never overwritten in place for prior builds) and `public.app_release_checks` (anonymous/device-scoped real update check & download/install telemetry — zero fabricated numbers).
   - Keep `system_settings` key `app_release_policy` / `app_release_signing_pins` ONLY for lightweight global channel pointers & expected certificate SHA-256 fingerprint pins (updated atomically alongside publish/rollback).
2. **Private APK Storage Bucket (`app-releases`) + Server-Validated Gated Distribution**:
   - Create Storage bucket `app-releases` with `public = false` (private).
   - Draft, validated, suspended, and archived APKs are stored safely inside private paths (`staging/...`, `releases/<channel>/<version>-b<build>/<id>.apk`) and are NEVER reachable by unauthenticated direct bucket guesses.
   - Public downloads route through `GET /api/public/releases/[releaseId]/download` (also linked as `downloadUrl` / `apkUrl` by `/api/public/distribution` and `/api/public/app-update`). This route validates `status === 'published'`, records a genuine download telemetry event, and returns a short-lived signed Storage download URL redirect (`302` / stream fallback in test mode) with verified filename and SHA-256 header. Zero website rebuild or redeployment is needed when publishing or rolling back!
3. **Large-APK Upload & Zero-Trust Cryptographic Inspection**:
   - Direct browser-to-Supabase Storage signed upload (`POST /api/admin/releases/upload-session` -> `createSignedUploadUrl` -> browser `PUT` upload with real XHR progress bar) avoids server body size caps (supports 20–150 MB APKs reliably).
   - Once uploaded to staging, `POST /api/admin/releases/inspect` / `POST /api/admin/releases/[id]/validate` reads the uploaded APK bytes server-side using `SUPABASE_SERVICE_ROLE_KEY`, parses:
     - Total file size (bytes) & exact **SHA-256** digest
     - Android binary `AndroidManifest.xml` (`package`, `android:versionCode`, `android:versionName`, `uses-sdk minSdkVersion`, `targetSdkVersion`)
     - **APK Signature Scheme v2 / v3** Signing Block signer X.509 certificate(s) + **cert SHA-256** & **SHA-1** fingerprint + v1 JAR fallback check
   - Rejects at validation & publish time: wrong package name (`!= com.example.skavia`), duplicate `(platform, channel, build_number)`, invalid version sequence (publishing a build <= currently higher active build on same channel unless explicitly using the dedicated Rollback action), incomplete metadata, or signing certificate mismatch against the pinned SKAVIA signing key fingerprint.
4. **Release Lifecycle & Safe Rollback**:
   - States: `draft` -> `validated` -> `published` -> (`suspended` | `archived`).
   - Transitions requiring Step-Up MFA + confirmation + immutable `audit_logs` write:
     - `validate`: inspects uploaded APK and locks artifact digest (`artifact_verified_at`, `signing_cert_sha256`).
     - `publish`: promotes `validated` release to active `published` on its channel, updates channel pointer (`published_release_id`), optionally dispatches in-app `user_notifications` (when `notify_users = true`), and sets `published_at`. Does NOT delete or overwrite prior release rows.
     - `suspend`: immediately blocks a broken release from new downloads / update prompts (optionally flags users already on that `build_number` with a notice).
     - `rollback`: selects a prior compatible non-suspended verified release (`validated` / previously `published` / `archived`), re-activates it as the channel's current recommended release (`status = 'published'`, `is_current = true`) while moving the broken release to `suspended` (`rolled_back_from_release_id`), preserving complete history and audit trail.
     - `archive`: retires old releases from active lists while keeping cryptographic audit history intact.
5. **Version Analytics & Device Update Monitoring (Real Telemetry Only)**:
   - Public Flutter clients call `GET /api/public/app-update?platform=android&channel=stable&build=<N>&version=<V>&deviceId=<anonHash>` (or `/api/public/app-update` + optional `POST /api/public/app-update/event` on check/download/install failure/install handoff).
   - Server logs real check-in & funnel counts (`update_check`, `download_started`, `checksum_verified`, `checksum_failed`, `installer_launched`, `app_active`) in `app_release_events` / `app_device_versions`. Super Admin portal aggregates strictly from those recorded rows (showing empty states cleanly when 0 devices have checked in).
6. **Flutter In-App Update & Android Installer Flow**:
   - Clean feature module under `lib/features/app_update/`:
     - `data/models/app_release_model.dart`: release metadata (`releaseId`, `versionName`, `buildNumber`, `minSupportedBuild`, `channel`, `apkUrl`, `sha256`, `fileSizeBytes`, `releaseNotes`, `isMandatory`, `status`, `signingCertSha256`, `publishedAt`) + computed `UpdateAvailabilityStatus` (`upToDate`, `optionalUpdate`, `mandatoryUpdate`, `suspendedInstalledBuild`, `unsupportedInstalledBuild`, `unavailable`).
     - `data/repositories/app_release_repository.dart`: HTTP fetch from public release check endpoint (`AppConfig.apiBaseUrl` / configurable web portal origin with local `SharedPreferences` metadata cache + offline graceful fallback; zero hardcoded APK URLs).
     - `services/app_update_service.dart`: orchestrates throttled automatic checks (startup after frame render, foreground resume every >= 4 hours, session restore, and unthrottled manual checks), `dismissedVersion` persistence for optional updates ("Later" suppresses re-prompting for that exact `buildNumber` for 24h while keeping a subtle banner/badge), streaming download to app `cacheDir/updates/`, progress ValueNotifier/ChangeNotifier, SHA-256 verification before install, permission check (`canRequestPackageInstalls`), and Kotlin `MethodChannel("skavia/app_installer")` handoff.
     - `providers/app_update_provider.dart`: `ChangeNotifier` state controller consumed by `MainScaffoldScreen`, `AboutSkaviaScreen`, `SettingsScreen`, `AppUpdateDialog`, `AppUpdateBanner`, `AppUpdateScreen`.
     - `presentation/widgets/app_update_dialog.dart`: polished SKAVIA-branded dialog showing current vs target version, release notes, formatted size, SHA-256 verification badge, `Update Now` & conditional `Later` (hidden on mandatory/min-supported violations).
     - `presentation/widgets/app_update_banner.dart`: subtle non-intrusive card/banner when an optional update is deferred or download is ready.
     - `presentation/screens/app_update_screen.dart` (routed at `AppRoutes.appUpdate`): dedicated update center screen & mandatory lock screen with download progress bar, retry/cancel, SHA-256 verification status, Android "Install unknown apps" permission helper card, helpline `16524` & `support@skavia.com` emergency support path, and fallback website link.
   - `NotificationService` & `NotificationCenterController`:
     - When `AppUpdateService` discovers an optional or mandatory update not yet notified (`dedupKey: 'app_update_${release.releaseId}'`), it creates an in-app `AppNotificationModel` (`category: isMandatory ? 'urgent' : 'system'`, `actionRoute: AppRoutes.appUpdate`) and optionally shows a local notification that navigates directly to `AppRoutes.appUpdate` on tap.

---

## 4. Database Schema & RBAC Summary (Implemented in Phase 3)

### 4.1 New Tables & Columns (`supabase/migrations/20261113000000_app_releases_and_update_system.sql`)
- `public.app_releases`
  - `release_id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
  - `platform VARCHAR(20) NOT NULL DEFAULT 'android'`
  - `channel VARCHAR(20) NOT NULL DEFAULT 'stable' CHECK (channel IN ('stable', 'beta', 'internal'))`
  - `package_name VARCHAR(150) NOT NULL`
  - `version_name VARCHAR(60) NOT NULL`
  - `build_number INTEGER NOT NULL CHECK (build_number > 0)`
  - `min_supported_build INTEGER NOT NULL CHECK (min_supported_build > 0 AND min_supported_build <= build_number)`
  - `min_sdk_version INTEGER`
  - `target_sdk_version INTEGER`
  - `release_notes TEXT NOT NULL`
  - `is_mandatory BOOLEAN NOT NULL DEFAULT FALSE`
  - `status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'validated', 'published', 'suspended', 'archived'))`
  - `is_current BOOLEAN NOT NULL DEFAULT FALSE` (partial unique index guarantees at most 1 current release per `(platform, channel)`)
  - `storage_bucket VARCHAR(80) NOT NULL DEFAULT 'app-releases'`
  - `storage_path TEXT NOT NULL`
  - `file_name TEXT NOT NULL`
  - `file_size_bytes BIGINT NOT NULL CHECK (file_size_bytes > 0)`
  - `sha256_checksum VARCHAR(64) NOT NULL`
  - `signing_cert_sha256 VARCHAR(64)`
  - `signing_schemes TEXT[] NOT NULL DEFAULT '{}'`
  - `notify_users BOOLEAN NOT NULL DEFAULT TRUE`
  - `rolled_back_from_release_id UUID REFERENCES public.app_releases(release_id) ON DELETE SET NULL`
  - `suspension_reason TEXT`
  - `created_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL`
  - `validated_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL`
  - `published_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL`
  - `validated_at TIMESTAMPTZ`
  - `published_at TIMESTAMPTZ`
  - `suspended_at TIMESTAMPTZ`
  - `archived_at TIMESTAMPTZ`
  - `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
  - `updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
  - `UNIQUE (platform, channel, build_number)`
- `public.app_release_events`
  - `event_id UUID PRIMARY KEY DEFAULT gen_random_uuid()`
  - `release_id UUID REFERENCES public.app_releases(release_id) ON DELETE SET NULL`
  - `platform VARCHAR(20) NOT NULL DEFAULT 'android'`
  - `channel VARCHAR(20) NOT NULL DEFAULT 'stable'`
  - `installed_build INTEGER`
  - `installed_version VARCHAR(60)`
  - `target_build INTEGER`
  - `event_type VARCHAR(40) NOT NULL CHECK (event_type IN ('update_check', 'download_started', 'download_completed', 'checksum_verified', 'checksum_failed', 'installer_launched', 'install_failed', 'app_active'))`
  - `device_fingerprint_hash VARCHAR(64)`
  - `android_api_level INTEGER`
  - `user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL`
  - `metadata JSONB NOT NULL DEFAULT '{}'::jsonb`
  - `created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()`
- **RBAC Permissions**:
  - `'release.view'`, `'release.manage'`, `'release.publish'` (requires Step-Up MFA + assigned exclusively to `Super Admin`).
- **Storage Bucket**:
  - `app-releases` (`public = false`, MIME `application/vnd.android.package-archive`, file limit `150MB`).

---

## 5. Verification Plan (Phase 9)

1. `admin-web` static checks & tests: `npm run typecheck`, `npm run lint`, `npm test` (APK inspector unit tests with real crafted/built APK bytes + lifecycle API + duplicate build + cert mismatch rejection + rollback tests), `npm run build`, Playwright E2E test for Super Admin Releases page & public `#download`.
2. Flutter static & unit tests: `flutter analyze`, `flutter test` (update evaluation matrix, mandatory vs optional vs suspended vs offline, throttling & `Later` suppression, notification dedup, Settings & About SKAVIA UI).
3. Real APK artifact build (`flutter build apk --release` or `--debug` signed verification test) inspected through our backend parser to verify actual `com.example.skavia` manifest & signature extraction!

