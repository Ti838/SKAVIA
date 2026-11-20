# Changelog

All notable changes to the **SKAVIA** platform are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-11-20

### Added
- **Device Detection & Compatibility Intelligence:**
  - Real-time client-side device, OS, browser, CPU concurrency, screen resolution, DPR, and network telemetry on download portal (`admin-web`).
  - Automatic architecture recommendation: highlights ARM64 (`arm64-v8a`) for modern 5G/4G devices and ARMv7 (`armeabi-v7a`) for legacy 32-bit devices with "★ Recommended for your device" badge.
  - Dedicated iOS guidance card with one-click redirect to responsive Web Portal (PWA).
  - Desktop transfer guidance and QR compatibility mode.
- **On-Device Flutter Diagnostics Engine (`lib/features/diagnostics/`):**
  - Full feature-first mobile diagnostics dashboard (`device_diagnostics_screen.dart`).
  - Safe hardware telemetry: manufacturer, model, OS release, SDK int, supported ABIs without persistent hardware identifiers (zero IMEI, zero serials).
  - Operational permissions health audit: Camera, Location (GPS service check without logging coordinates), and Notifications.
  - Microphone status explicitly tagged as `notApplicable` ("Feature not used by SKAVIA") to prevent invalid permission requests.
  - Round-trip edge ping latency probe classifying connections into 5G/Ultra-Fast, 4G LTE/High-Speed, or Standard.
  - Startup benchmark stopwatch and UI frame raster smoothness monitoring.
  - Privacy-preserving redacted JSON report export with explicit user consent dialog.
- **In-App Release & Update System:**
  - Native Android installer handoff via `MethodChannel` (`skavia/app_installer`) using `androidx.core.content.FileProvider`.
  - Cryptographic SHA-256 binary integrity verification prior to installation.
  - Flexible update triggers: startup check, foreground resume throttling, and manual checking in Settings.
  - Non-blocking optional update banner/dialog and blocking mandatory update screen.

### Changed
- **Comprehensive Clean Architecture Refactoring:**
  - Completely decomposed monolithic Dart files across `features/authentication`, `features/customer`, `features/worker`, `features/billing`, `features/team_project`, `features/profile`, and `shared/widgets/`.
  - Reduced oversized 1,200+ line files into modular, single-responsibility files (100–250 lines for pages, 30–150 lines for widgets).
  - Replaced hardcoded dummy mock data with typed domain repositories and real state services.
  - Centralized theme architecture into decoupled `AppThemeLight` and `AppThemeDark` modules.
- **Vercel Build Stabilization (`admin-web`):**
  - Replaced failing `next/font/google` loader for `Noto_Sans_Bengali` with robust Google Fonts `@import` stylesheet, resolving deployment crash.
  - Excluded `.vercel/**` from ESLint checks.

### Fixed
- Fixed layout overflows (`RenderFlex`) on small 320dp screens across all authentication, worker profile, team discovery, and diagnostic screens with 1.5x and 2.0x text scaling.
- Fixed deprecated color opacity methods (`withOpacity`) in favor of modern Flutter `withValues(alpha: ...)`.
- Fixed multiple undefined getter warnings on `AppColors` and unconstrained flex children.

### Security
- Enforced strict zero-trust boundary: all client inputs validated through PostgreSQL Row-Level Security (RLS) policies and Edge Functions.
- Eliminated persistent device identifier collection (no IMEI, no MAC address, no Android serial query).
- Sealed admin console access via WebAuthn/Passkey registration, session encryption, and role-based access control.
