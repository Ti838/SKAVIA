# Feature Architecture & Modular Decomposition

## 1. Feature Catalog

The SKAVIA codebase organizes all business capabilities into independent, feature-first directories within `lib/features/`:

| Feature Directory | Primary Responsibility | Key Screens | Domain Entities / Models |
| :--- | :--- | :--- | :--- |
| `authentication` | User onboarding, Phone SMS OTP, Google OAuth, and initial role selection. | `LoginScreen`, `RegisterScreen`, `OtpVerificationScreen`, `RoleSelectionScreen` | `AuthUser`, `UserRole`, `RoleOption` |
| `navigation` | Main shell container, dynamic role switcher, and unified dashboard rendering. | `MainScaffoldScreen` | `AppRoleMode`, `DashboardStats` |
| `customer` | Taxonomy browsing, requirement posting, bid comparison, and instant bookings. | `ServicesCatalogScreen`, `PostRequirementScreen`, `BookingConfirmationScreen` | `CategoryModel`, `ServiceModel`, `RequirementModel` |
| `worker` | Dispatch radar, incoming request triage, active job execution, and verification. | `IncomingRequestsScreen`, `ActiveJobScreen`, `WorkerEditProfileScreen` | `WorkerProfile`, `DispatchOrder`, `WorkLog` |
| `team_project` | Turnkey commercial contracts, milestone management, and team discovery. | `TeamDiscoveryScreen`, `ProjectDetailsScreen`, `MilestoneTrackerScreen` | `Project`, `Milestone`, `TeamMember` |
| `billing` | Invoices, escrow status, digital wallet, transaction ledger, and payment handoff. | `InvoiceScreen`, `WalletScreen`, `PaymentCheckoutScreen` | `Invoice`, `EscrowRecord`, `PaymentIntent` |
| `chat` | Direct messaging, arrival coordination, and real-time presence. | `ChatScreen`, `ConversationListScreen` | `ChatMessageModel`, `Conversation` |
| `diagnostics` | Local hardware telemetry, permission health, and 5G/4G network latency probe. | `DeviceDiagnosticsScreen` | `HardwareTelemetry`, `PermissionHealth`, `DiagnosticReport` |
| `notifications` | In-app notification center, urgent dispatch alerts, and deep-link routing. | `NotificationCenterScreen` | `NotificationItem`, `NotificationCategory` |
| `profile` | Profile editing, address book, security sessions, and appearance settings. | `SettingsScreen`, `EditDetailedProfileScreen`, `SavedAddressesScreen`, `PrivacySecurityScreen` | `UserProfile`, `UserAddress`, `UserSession` |
| `update` | In-app release distribution, SHA-256 verification, and Android installer handoff. | `AppUpdateScreen`, `AppUpdateDialog` | `AppReleaseModel`, `UpdateState` |

---

## 2. File Responsibility Standards

To prevent code degradation and eliminate monolithic files, the following boundaries are strictly enforced across all features:

1. **Pages / Screens (`presentation/screens/`):**
   - Responsible strictly for composing structural scaffolding, handling routing parameters, and listening to controller state changes.
   - Target line count: **100–250 lines**.
2. **Widgets (`presentation/widgets/`):**
   - Responsible for rendering dedicated visual sections, inputs, cards, or dialogs.
   - Target line count: **30–150 lines**.
3. **Controllers (`presentation/controllers/`):**
   - Responsible for business state, user actions, error handling, and orchestrating repositories.
   - Free of `BuildContext` dependencies where possible.
4. **Repositories (`data/repositories/` & `domain/repositories/`):**
   - Responsible for mapping network DTOs to immutable domain models and enforcing local cache fallbacks.
