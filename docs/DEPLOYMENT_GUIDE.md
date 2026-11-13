# SKAVIA — Production Deployment & Operations Guide

## 1. Supabase Database & Edge Functions
Apply all timestamped SQL migrations in [`supabase/migrations/`](../supabase/migrations) sequentially (via Supabase CLI or SQL Editor), then deploy hardened Edge Functions:

```powershell
supabase db push
supabase functions deploy analyze-requirement
supabase functions deploy verify-sslcommerz-ipn
```

Configure sensitive credentials in **Supabase Function Secrets / Vault** (never commit or bundle server secrets into mobile builds):
- `SUPABASE_SERVICE_ROLE_KEY`
- `FIREBASE_PROJECT_ID=skavia-113a3`
- `ALLOWED_ORIGINS` (e.g. `https://www.skavia.com,https://admin.skavia.com`)
- SSLCommerz live merchant credentials (`SSLCOMMERZ_STORE_ID`, `SSLCOMMERZ_STORE_PASSWD`)
- AI provider keys (`GROQ_API_KEY` / `OPENROUTER_API_KEY`)

---

## 2. Admin Web & Public Website (`admin-web/` on Vercel)

The Next.js 15 App Router application in [`admin-web/`](../admin-web) serves the **Public Website**, **Internal Admin Portal**, and **Super Admin Portal** from one deployment with hostname/path surface isolation (`src/middleware.ts`, `src/server/auth/surface.ts`).

### Pre-Deploy Verification
```powershell
Set-Location admin-web
npm ci
npm run typecheck
npm run lint
npm test
npm run build
```

### Vercel Configuration
1. **Root Directory:** Set to `admin-web` in Vercel Project Settings.
2. **Environment Variables:** Configure everything from [`admin-web/.env.example`](../admin-web/.env.example):
   - **Browser Public (`NEXT_PUBLIC_*`):**
     - `NEXT_PUBLIC_FIREBASE_API_KEY`, `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`, `NEXT_PUBLIC_FIREBASE_PROJECT_ID`, `NEXT_PUBLIC_FIREBASE_APP_ID`
     - Optional surface hostnames (`NEXT_PUBLIC_PUBLIC_HOST`, `NEXT_PUBLIC_ADMIN_HOST`, `NEXT_PUBLIC_SUPERADMIN_HOST`) — leave blank on a single `*.vercel.app` origin to use single-domain path routing (`/`, `/login`, `/activate`, `/dashboard`, `/admins`, `/security`).
   - **Server-Only (NEVER prefix with `NEXT_PUBLIC_`):**
     - `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`
     - `ADMIN_SESSION_SECRET` (`openssl rand -hex 32`)
     - `PRIMARY_SUPER_ADMIN_UID`, `ADMIN_ALLOWED_ORIGIN`, `ADMIN_REQUIRE_MFA=true`, `ADMIN_INVITE_TTL_HOURS=24`
     - Optional SMTP/Resend (`SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM`, `RESEND_API_KEY`)
     - Optional WebAuthn overrides (`WEBAUTHN_RP_ID`, `WEBAUTHN_ORIGIN`; auto-derived from `Host` / `X-Forwarded-Host` otherwise)
3. **Custom Domains (Production Multi-Surface):**
   - Point `www.skavia.com`, `admin.skavia.com`, and `superadmin.skavia.com` to the Vercel project and set the matching `NEXT_PUBLIC_*_HOST` + `ADMIN_ALLOWED_ORIGIN` variables.
   - Vercel forwards `Host` / `X-Forwarded-Host` automatically so `src/middleware.ts` enforces strict surface boundaries.

---

## 3. Flutter Mobile App (`lib/`) & APK Release Distribution

Populate `.env` from [`.env.example`](../.env.example), verify tests, and build lightweight per-ABI Android APKs (ProGuard/R8 + resource shrinking enabled in `android/app/build.gradle.kts`):

```powershell
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --split-per-abi --release
# Universal APK or Play Store App Bundle:
flutter build apk --release
flutter build appbundle --release
```

After building the release APK, upload and publish the release via the Super Admin Portal **App Releases & APK Distribution** console (`/releases` / `/api/admin/releases`) so the public website (`/`) and Flutter in-app update checker (`app_releases`) serve the verified SHA-256 checksum build.

