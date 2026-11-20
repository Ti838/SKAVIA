# Getting Started with SKAVIA Development

## 1. Prerequisites

Before setting up the SKAVIA workspace locally, verify that your machine has the following toolchains installed:

- **Flutter SDK:** Version `3.13.2` or later (Dart SDK `^3.13.2`).
- **Node.js & npm:** Node.js `20.x` LTS or `22.x` LTS with npm `10.x+`.
- **Git:** Git `2.40+`.
- **Android Studio / SDK:** Android SDK Command-line Tools with API levels `24` through `35`.

---

## 2. Environment Configuration

### A. Mobile Application (`.env`)
Create a `.env` file in the project root by copying `.env.example`:

```powershell
Copy-Item .env.example .env
```

Ensure the following variables are configured:
```ini
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key

# Web Origin (Release Distribution & In-App Updates)
SKAVIA_WEB_ORIGIN=http://localhost:3000

# Firebase Configuration
FIREBASE_PROJECT_ID=skavia-113a3
```

### B. Admin Web Console (`admin-web/.env.local`)
Create `admin-web/.env.local` by copying `admin-web/.env.example`:

```powershell
Set-Location admin-web
Copy-Item .env.example .env.local
Set-Location ..
```

---

## 3. Local Installation & Execution

### A. Running the Flutter Mobile App
```powershell
# 1. Fetch Flutter dependencies
flutter pub get

# 2. Run static analyzer check
dart analyze --fatal-infos

# 3. Execute Flutter test suite
flutter test

# 4. Launch on connected Android device or emulator
flutter run
```

### B. Running the Admin Web Console
```powershell
Set-Location admin-web

# 1. Install npm dependencies
npm ci

# 2. Run lint & typecheck
npm run lint
npm run typecheck

# 3. Execute web test suite
npm test

# 4. Start Next.js development server
npm run dev
```
Access the public landing page at `http://localhost:3000` and the admin portal at `http://localhost:3000/login`.
