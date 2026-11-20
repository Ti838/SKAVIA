# Flutter Mobile Application Architecture

## 1. Architectural Pattern: Feature-First Clean Architecture

The SKAVIA Flutter mobile application strictly adheres to **Feature-First Clean Architecture** with distinct layer separation:

```
lib/
├── main.dart                          # Application entrypoint (minimal bootstrap launcher)
├── app/                               # Core application configuration & router
│   ├── bootstrap.dart                 # Async dependency initialization & local storage warming
│   ├── app.dart                       # Root MaterialApp widget & theme attachment
│   ├── router/                        # GoRouter declarative navigation & auth guards
│   ├── theme/                         # Decoupled light & dark theme tokens (Material 3)
│   └── localization/                  # AppLocaleScope & dual-language engine (en/bn)
│
├── core/                              # Cross-cutting foundational infrastructure
│   ├── constants/                     # Database table names, API keys & static configurations
│   ├── errors/                        # AppFailure & domain exception hierarchies
│   ├── helpers/                       # UI feedback, date formatters & validation rules
│   ├── services/                      # Secure storage, notifications, cache & offline sync
│   └── utils/                         # Cryptography, math, and telemetry utilities
│
├── shared/                            # Global design system & generic UI widgets
│   ├── widgets/                       # Buttons, inputs, cards, dialogs & bottom sheets
│   ├── models/                        # Cross-feature models & DTOs
│   └── enums/                         # AppRoleMode, VerificationStatus, etc.
│
└── features/                          # Self-contained business capability slices
    ├── authentication/                # Login, registration, OTP verification & role selection
    ├── navigation/                    # Shell scaffold, role mode switcher & dashboard tabs
    ├── customer/                      # Booking wizard, requirement bidding & service catalog
    ├── worker/                        # Dispatch radar, incoming requests & active job execution
    ├── team_project/                  # B2B turnkey projects, milestone tracking & team discovery
    ├── billing/                       # Invoices, escrow status, wallet & payment handoff
    ├── chat/                          # Real-time WebSockets conversation & presence
    ├── diagnostics/                   # Hardware telemetry, permission audit & 5G/4G latency
    ├── notifications/                 # In-app notification center & push alert routing
    ├── profile/                       # User profile, addresses, security & settings
    └── update/                        # Native Android APK download, SHA-256 verify & in-app install
```

---

## 2. Layering & Separation of Concerns

Inside each feature module, responsibilities are strictly separated across three layers:

```
features/<feature_name>/
├── domain/                            # Enterprise business rules (independent of Flutter/UI)
│   ├── entities/                      # Immutable Dart data classes
│   ├── enums/                         # Feature-specific state classifications
│   └── repositories/                  # Abstract interface contracts
│
├── data/                              # Data access & platform implementations
│   ├── datasources/                   # Supabase PostgREST & Firebase API callers
│   ├── models/                        # JSON serialization / deserialization DTOs
│   └── repositories/                  # Concrete repository implementations
│
└── presentation/                      # UI components & user interaction
    ├── controllers/                   # StateNotifier / ChangeNotifier business logic
    ├── screens/                       # High-level responsive page views (100–250 lines)
    └── widgets/                       # Modular leaf components (30–150 lines)
```

---

## 3. State Management & Reactive UI

1. **Explicit View Models:** Each complex screen is backed by a dedicated controller (e.g., `NotificationCenterController`, `AppUpdateProvider`, `DashboardRepository`).
2. **Business Logic Decoupling:** UI widgets never make raw HTTP calls or construct raw database queries. All interactions route through typed service classes and repositories.
3. **Responsive Constraint Compliance:**
   - Every layout is engineered to fit down to 320dp screen width (legacy mobile devices).
   - All flex children (`Row`, `Column`) are guarded with `Flexible`, `Expanded`, or `Wrap` with explicit text overflow handling (`TextOverflow.ellipsis`).
   - Scales smoothly under accessibility font scalers (`TextScaler.linear(1.5)` and `TextScaler.linear(2.0)`).

---

## 4. Theme System: Google Material Design 3

- **Tonal Color Schemes:** Engineered around SKAVIA primary blue (`#003399`), energetic cyan accent (`#15E7CA`), and safety amber (`#FFB703`).
- **Decoupled Definitions:** Separated into `lib/app/theme/app_theme_light.dart` and `lib/app/theme/app_theme_dark.dart` to eliminate monolithic theme files.
- **Surface Elevation:** Utilizes tonal fill containers (`surfaceContainer`, `surfaceContainerHigh`) rather than heavy drop shadows, guaranteeing crisp visual hierarchy on AMOLED and LCD displays.
