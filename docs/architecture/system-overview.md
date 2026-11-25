# System Overview & C4 Model

## 1. Executive Summary

**SKAVIA** is an accountable on-demand service and workforce management platform designed to deliver guaranteed, high-accountability service fulfillment across Bangladesh. 

Unlike traditional gig-economy listings or unmonitored directories, SKAVIA enforces:
1. **Physical Arrival Verification:** Cryptographic 4-digit arrival OTP handoff required before any billable timer or job execution begins.
2. **Atomic Escrow Financial Settlement:** Customer funds are locked in escrow upon order confirmation and released to worker earnings only upon digital customer sign-off or resolution.
3. **Multi-Role Single Enterprise Ecosystem:** One unified database architecture serving Individual Customers, Enterprise Business Clients, Skilled Specialists (Workers), and Governance Administrators.
4. **Zero-Cost Production Identity Rails:** Dual-channel OTP challenge engine combining **Mailjet SMTP** with a deterministic **Firebase Auth Spark Bridge** to bypass cellular SMS gating.

---

## 2. C4 Model — Level 1: System Context

```mermaid
graph TB
    subgraph Users ["Actors & Stakeholder Personas"]
        ClientUser["👤 Individual Customer<br/>(Service discovery, Instant booking, Email/Phone OTP)"]
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
        AIEngines["🤖 Natural Language Inference Cloud<br/>(Task breakdown & Diagnostic prompt processing)"]
        MapEngine["🗺️ Geospatial & Cartography Engine<br/>(CartoDB Positron / OSM Basemap & Geolocator)"]
    end

    ClientUser <-->|Orders Services| UserApp
    BizUser <-->|Manages Projects| UserApp
    WorkerUser <-->|Fulfills Dispatches| UserApp
    AdminUser <-->|Supervises Operations| AdminWeb

    UserApp <-->|Auth Tokens & Storage| FirebaseEngine
    AdminWeb <-->|OTP & Admin Invitations| EmailEngine
    UserApp <-->|Telemetry & Distance| MapEngine
    CloudBackend <-->|AI Diagnostics| AIEngines
    CloudBackend <-->|Server-to-Server IPN| PaymentRails
    UserApp -->|Hosted Checkout Redirect| PaymentRails
```

---

## 3. Core Subsystems

### A. Mobile Application (`lib/`)
The primary touchpoint for consumers, business clients, and field specialists. Built with Flutter 3 and Dart 3 using feature-first clean architecture:
- Dual-channel Phone/Email OTP sign-in with auto-paste and delivery indicator.
- Google Sign-In with automatic Supabase profile synchronization.
- CartoDB Positron / OpenStreetMap basemaps (zero paid API keys required).
- Responsive UI layouts supporting mobile handsets, foldables, tablets, and desktop viewports.

### B. Admin Web Console (`admin-web/`)
A multi-surface enterprise platform built with Next.js 15 App Router serving:
- **Public Landing & Release Distribution Portal:** Live product downloads, SHA-256 verification manifests, real-time client device detection and 5G/4G architecture recommendation.
- **Identity & Cloud OTP Engine:** HMAC-SHA256 keyed challenge issuance, rate-limiting, and Mailjet SMTP transactional email delivery.
- **Internal Operations Console:** KYC worker verification queue, dispute resolution desk, and transaction auditing.
- **Super Admin Governance:** Role-based access control (RBAC), single-use cryptographic admin invitations, WebAuthn/Passkey registration, session revocation, and cryptographic APK release signing policy.

### C. Backend & Database Tier (`supabase/`)
PostgreSQL 15 managed via Supabase Cloud:
- **Modular Schema Organization:** 8 structured domain DDL files under `supabase/schema/` (`01_identity_and_rbac.sql` to `08_rls_functions_and_indexes.sql`).
- **Strict Row-Level Security (RLS):** Mobile clients access user-scoped records via `auth.uid()::text`. Administrative operations are exclusively handled by server-side `service_role` through authenticated Next.js API endpoints.
- **Atomic Stored Procedures (RPC):** Ensuring all financial ledger debits and credits execute within atomic ACID transactions (`complete_payment_transaction()`).
