# SKAVIA — On-Demand Services & Skilled Workforce Platform

<p align="center">
  <img src="assets/images/skavia_logo.png" alt="SKAVIA Logo" width="220"/>
</p>

<p align="center">
  <strong>Accountable On-Demand Services, Skilled Workforce Management & Escrow Financial Settlement</strong><br>
  <em>An independently developed enterprise ecosystem for doorstep technical maintenance, commercial turnkey contracting, and verified workforce dispatch.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.13+-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.0+_Null--Safe-0175C2?logo=dart&logoColor=white" alt="Dart 3"/>
  <img src="https://img.shields.io/badge/Web_Console-Next.js_15_App_Router-000000?logo=nextdotjs&logoColor=white" alt="Next.js 15"/>
  <img src="https://img.shields.io/badge/Architecture-Feature--First_Clean-blueviolet?logo=dart&logoColor=white" alt="Clean Architecture"/>
  <img src="https://img.shields.io/badge/Database-Supabase_PostgreSQL_15-3ECF8E?logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Auth-Cloud_OTP_%2B_Mailjet_SMTP_%2B_Passkeys-FFCA28?logo=firebase&logoColor=black" alt="Auth"/>
  <img src="https://img.shields.io/badge/Payment-SSLCommerz_v4-success" alt="Payment"/>
  <img src="https://img.shields.io/badge/Flutter_Tests-182_Passed-brightgreen" alt="Flutter Tests"/>
  <img src="https://img.shields.io/badge/Web_Tests-43_Passed-brightgreen" alt="Web Tests"/>
  <img src="https://img.shields.io/badge/License-Proprietary_/_All_Rights_Reserved-red.svg" alt="License"/>
</p>

---

## 📌 Project Overview

**SKAVIA** is an accountable service and workforce management platform designed for the Bangladesh market. 

Unlike unmonitored classified directories, SKAVIA provides an end-to-end operational guarantee:
1. **Physical Arrival Verification:** Cryptographic 4-digit arrival OTP handoff required before any billable timer or job execution begins.
2. **Atomic Escrow Financial Settlement:** Customer funds are held securely in escrow upon order confirmation and released to the worker's earnings wallet only after customer digital sign-off.
3. **Multi-Role Single Enterprise Ecosystem:** One unified mobile application serving Individual Customers, Enterprise Business Clients, and Skilled Specialists (Workers), supervised by an administrative web console (`admin-web`).
4. **Device Detection & Smart APK Recommendation:** Real-time client-side device telemetry that automatically highlights the optimal 5G/4G 64-bit APK (`arm64-v8a`) or 32-bit legacy APK (`armeabi-v7a`), with dedicated iOS Web App (PWA) guidance.
5. **On-Device Hardware & Network Diagnostics:** Built-in mobile diagnostics module inspecting device hardware, permissions, and network edge latency with strict privacy controls (zero IMEI, zero serials, zero GPS logging).

---

## 🏛️ System Architecture

```mermaid
graph TB
    subgraph Users ["Actors & Stakeholder Personas"]
        ClientUser["👤 Individual Customer<br/>(Service discovery, Instant booking, OTP verification)"]
        BizUser["🏢 Business Client / Organization<br/>(Turnkey projects, Milestone contracts, Kanban boards)"]
        WorkerUser["🔧 Skilled Specialist / Contractor<br/>(Accepts dispatches, Job execution, Wallet earnings)"]
        AdminUser["👔 Internal SKAVIA Administrator<br/>(KYC verification, Dispute mediation, Operations audit)"]
    end

    subgraph SKAVIA_System ["🏢 SKAVIA Core Enterprise Platform"]
        UserApp["📱 SKAVIA Client Application<br/>(Flutter 3.13+ / Dart 3 Null-Safe)"]
        AdminWeb["🌐 SKAVIA Web Administration & Public Portal<br/>(Next.js 15 App Router, TypeScript)"]
        CloudBackend["☁️ SKAVIA Backend Infrastructure<br/>(Supabase PostgreSQL 15, PostgREST API, Realtime WSS)"]
        
        UserApp <-->|HTTPS REST & Realtime WSS| CloudBackend
        AdminWeb <-->|Server-Side Service Role & PostgREST| CloudBackend
        UserApp <-->|Cloud OTP & Releases| AdminWeb
    end

    subgraph External_Services ["🌐 External Cloud & Financial Rails"]
        FirebaseEngine["🔥 Google Firebase Cloud<br/>(Firebase Auth Spark Bridge, Google OAuth, Media Storage)"]
        EmailEngine["✉️ Transactional Messaging Rails<br/>(Mailjet SMTP Primary, Resend Fallback, Multi-Gateway BD SMS)"]
        PaymentRails["💳 Bangladesh Banking & MFS Rails<br/>(SSLCommerz Gateway v4, bKash Direct, Nagad)"]
        CloudflareEdge["🛡️ Cloudflare CDN & 1.1.1.1 Latency Endpoint"]
    end

    ClientUser <-->|Orders Services| UserApp
    BizUser <-->|Manages Projects| UserApp
    WorkerUser <-->|Fulfills Dispatches| UserApp
    AdminUser <-->|Supervises Operations| AdminWeb

    UserApp <-->|Auth Tokens & Storage| FirebaseEngine
    AdminWeb <-->|OTP & Admin Invitations| EmailEngine
    UserApp <-->|Latency Ping| CloudflareEdge
    CloudBackend <-->|Server-to-Server IPN| PaymentRails
    UserApp -->|Hosted Checkout Redirect| PaymentRails
```

For complete architectural specifications, see the [Architecture Documentation](docs/architecture/system-overview.md) and [Editable Mermaid Diagrams](docs/diagrams/).

---

## 📂 Source Code Directory Structure

```
SKAVIA/
├── lib/                               # Flutter Mobile Client Source
│   ├── main.dart                      # Minimal application bootstrap
│   ├── app/                           # App configuration, routing & themes
│   ├── core/                          # Cross-cutting foundational services
│   ├── shared/                        # Reusable design system & UI components
│   └── features/                      # Modular feature-first business domains
│       ├── authentication/            # Login, registration, OTP & role selection
│       ├── billing/                   # Invoices, escrow status & payment handoff
│       ├── customer/                  # Category catalog, bidding & bookings
│       ├── diagnostics/               # On-device hardware, permissions & latency
│       ├── navigation/                # Main shell scaffold & role mode switcher
│       ├── notifications/             # Notification center & urgent alert routing
│       ├── profile/                   # User profile, security & settings
│       ├── team_project/              # Turnkey commercial projects & Kanban
│       ├── update/                    # Android in-app update & SHA-256 verify
│       └── worker/                    # Dispatch radar, job timers & active jobs
│
├── admin-web/                         # Next.js 15 Web Portal & Admin Console
│   ├── src/app/                       # App Router pages & API routes
│   ├── src/features/                  # Public website, passkey auth & admin panels
│   └── public/downloads/              # Official production APK binaries
│
├── supabase/                          # PostgreSQL 15 Database Tier
│   └── migrations/                    # 8 Sequential SQL migrations (58 tables total)
│
├── test/                              # Comprehensive Flutter Test Suite (182 tests)
│   └── unit/                          # Unit & widget tests verifying 320dp layouts & logic
│
└── docs/                              # Comprehensive Documentation Hub
```

---

## ⚡ Quick Start & Development

### 1. Flutter Mobile App
```powershell
# Install Flutter dependencies
flutter pub get

# Run static analysis (strict zero-warning policy)
dart analyze --fatal-infos

# Run comprehensive test suite (182 unit/widget tests)
flutter test

# Run application on Android or Desktop
flutter run
```

### 2. Admin Web Portal
```powershell
cd admin-web

# Install npm dependencies
npm ci

# Run lint, typecheck and test suite (43 vitest tests)
npm run lint
npm run typecheck
npm test

# Build production bundle
npm run build

# Start development server
npm run dev
```

For detailed setup instructions and environment variable configurations, refer to the [Getting Started Guide](docs/development/getting-started.md).

---

## 📚 Complete Documentation Index

| Topic | Documentation Link |
| :--- | :--- |
| **System Overview & C4 Model** | [docs/architecture/system-overview.md](docs/architecture/system-overview.md) |
| **Web Ecosystem Architecture (Public Site & Admin Portal)** | [docs/architecture/web-ecosystem-architecture.md](docs/architecture/web-ecosystem-architecture.md) |
| **Flutter Application Architecture** | [docs/architecture/application-architecture.md](docs/architecture/application-architecture.md) |
| **Feature Directory Decomposition** | [docs/architecture/feature-architecture.md](docs/architecture/feature-architecture.md) |
| **Authentication & Identity Flow** | [docs/architecture/authentication-flow.md](docs/architecture/authentication-flow.md) |
| **Authorization & User Roles** | [docs/architecture/authorization-and-roles.md](docs/architecture/authorization-and-roles.md) |
| **Data Flow & Escrow Lifecycle** | [docs/architecture/data-flow.md](docs/architecture/data-flow.md) |
| **Multi-Cloud Infrastructure** | [docs/architecture/infrastructure.md](docs/architecture/infrastructure.md) |
| **System Diagrams (Mermaid)** | [docs/diagrams/](docs/diagrams/) |
| **Developer Getting Started** | [docs/development/getting-started.md](docs/development/getting-started.md) |
| **Project Structure Guide** | [docs/development/project-structure.md](docs/development/project-structure.md) |
| **Coding & Responsive Guidelines** | [docs/development/coding-guidelines.md](docs/development/coding-guidelines.md) |
| **Dependency Rationale Audit** | [docs/development/dependencies.md](docs/development/dependencies.md) |
| **Developer Troubleshooting** | [docs/development/troubleshooting.md](docs/development/troubleshooting.md) |
| **PostgreSQL Database Schema** | [docs/backend/database-schema.md](docs/backend/database-schema.md) |
| **Supabase Stored Procedures (RPC)** | [docs/backend/supabase-integration.md](docs/backend/supabase-integration.md) |
| **Row-Level Security (RLS)** | [docs/backend/rls-security.md](docs/backend/rls-security.md) |
| **Storage Bucket Policies** | [docs/backend/storage.md](docs/backend/storage.md) |
| **API Reference Catalog** | [docs/backend/api-reference.md](docs/backend/api-reference.md) |
| **Android Release & Keystore Signing** | [docs/deployment/android-release.md](docs/deployment/android-release.md) |
| **Production Pre-Flight Checklist** | [docs/deployment/production-checklist.md](docs/deployment/production-checklist.md) |
| **Project Status & Test Metrics** | [docs/project/project-status.md](docs/project/project-status.md) |
| **Third-Party Open-Source Licenses** | [docs/project/third-party-licenses.md](docs/project/third-party-licenses.md) |

---

## 🔒 Ownership, Author & License

- **Product:** SKAVIA
- **Product Type:** Service and Workforce Management Platform
- **Developer / Author:** **Timon Biswas** ([GitHub: @Ti838](https://github.com/Ti838))
- **Organization:** Independent Project
- **Copyright:** &copy; 2026 Timon Biswas. All rights reserved.
- **License:** Proprietary Software License — All Rights Reserved. See [LICENSE](LICENSE) for terms.
- **Third-Party Open-Source Attributions:** See [Third-Party License Inventory](docs/project/third-party-licenses.md).
