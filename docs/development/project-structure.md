# Project Structure & Directory Layout

The SKAVIA workspace is structured as a mono-repository containing the Flutter client mobile application, the Next.js web application, Supabase database definitions, and comprehensive system documentation.

```
SKAVIA/
├── .env.example                       # Template for mobile environment variables
├── pubspec.yaml                       # Flutter package specifications & assets
├── android/                           # Native Android project (SDK 24–35, Gradle, FileProvider)
├── ios/                               # Native iOS project (Runner, Assets, Plist)
├── macos/                             # macOS desktop platform support
│
├── lib/                               # Flutter Mobile Client Source
│   ├── main.dart                      # Minimal application bootstrap
│   ├── app/                           # App initialization, routing & theming
│   │   ├── bootstrap.dart             # Storage warming & service initialization
│   │   ├── app.dart                   # Root MaterialApp widget
│   │   ├── router/                    # GoRouter route declarations
│   │   └── theme/                     # AppThemeLight & AppThemeDark
│   ├── core/                          # Cross-cutting foundational services
│   ├── shared/                        # Centralized design system & widgets
│   └── features/                      # Modular feature modules
│       ├── authentication/
│       ├── billing/
│       ├── customer/
│       ├── diagnostics/
│       ├── navigation/
│       ├── notifications/
│       ├── profile/
│       ├── team_project/
│       ├── update/
│       └── worker/
│
├── admin-web/                         # Next.js 15 Web Portal & Admin Console
│   ├── src/
│   │   ├── app/                       # Next.js App Router pages & API routes
│   │   ├── features/                  # Web feature modules (admin, public, passkey)
│   │   ├── server/                    # Server-side auth, db & release services
│   │   └── middleware.ts              # Surface routing & authentication gate
│   ├── public/                        # Static assets & downloadable APK binaries
│   └── tests/                         # Vitest unit & integration test suites
│
├── supabase/                          # PostgreSQL database definitions
│   └── migrations/                    # Sequential timestamped SQL schema migrations
│
├── test/                              # Comprehensive Flutter Test Suite (182 tests)
│   └── unit/                          # Unit & widget tests verifying 320dp layouts & logic
│
└── docs/                              # System documentation library
```
