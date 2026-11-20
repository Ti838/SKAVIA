# System Overview & C4 Model

## 1. Executive Summary

**SKAVIA** is an accountable on-demand service and workforce management platform designed to deliver guaranteed, high-accountability service fulfillment across Bangladesh. 

Unlike traditional gig-economy listings or unmonitored directories, SKAVIA enforces:
1. **Physical Arrival Verification:** Cryptographic 4-digit arrival OTP handoff required before any billable timer or job execution begins.
2. **Atomic Escrow Financial Settlement:** Customer funds are locked in escrow upon order confirmation and released to worker earnings only upon digital customer sign-off or resolution.
3. **Multi-Role Single Enterprise Ecosystem:** One unified database architecture serving Individual Customers, Enterprise Business Clients, Skilled Specialists (Workers), and Governance Administrators.

---

## 2. C4 Model — Level 1: System Context

```mermaid
graph TB
    subgraph Users ["Actors & Stakeholder Personas"]
        ClientUser["👤 Individual Customer<br/>(Service discovery, Instant booking, OTP verification)"]
        BizUser["🏢 Business Client / Organization<br/>(Turnkey projects, Milestone contracts, Kanban boards)"]
        WorkerUser["🔧 Skilled Specialist / Contractor<br/>(Accepts dispatches, Job execution, Wallet earnings)"]
        AdminUser["👔 Internal SKAVIA Administrator<br/>(KYC verification, Dispute mediation, Operations audit)"]
    end

    subgraph SKAVIA_System ["🏢 SKAVIA Core Enterprise Platform"]
        UserApp["📱 SKAVIA Client Application<br/>(Flutter 3.13+ / Dart 3, Null-Safe, Android SDK 24–35)"]
        AdminWeb["🌐 SKAVIA Web Administration & Public Portal<br/>(Next.js 15 App Router, TypeScript, Tailwind CSS)"]
        CloudBackend["☁️ SKAVIA Backend Infrastructure<br/>(Supabase PostgreSQL 15, PostgREST API, Realtime WebSockets)"]
        
        UserApp <-->|HTTPS REST & Realtime WSS| CloudBackend
        AdminWeb <-->|Server-Side Service Role & PostgREST| CloudBackend
    end

    subgraph External_Services ["🌐 External Cloud & Financial Rails"]
        FirebaseEngine["🔥 Google Firebase Cloud<br/>(Phone SMS OTP, Google OAuth, Cloud Storage Buckets)"]
        PaymentRails["💳 Bangladesh Banking & MFS Rails<br/>(SSLCommerz Gateway v4, bKash Direct, Nagad)"]
        AIEngines["🤖 Natural Language Inference Cloud<br/>(Task breakdown & Diagnostic prompt processing)"]
        MapEngine["🗺️ Geospatial & Cartography Engine<br/>(Geolocator telemetry & Haversine distance matrix)"]
    end

    ClientUser <-->|Orders Services| UserApp
    BizUser <-->|Manages Projects| UserApp
    WorkerUser <-->|Fulfills Dispatches| UserApp
    AdminUser <-->|Supervises Operations| AdminWeb

    UserApp <-->|Phone Auth & Storage| FirebaseEngine
    UserApp <-->|Telemetry & Distance| MapEngine
    CloudBackend <-->|AI Diagnostics| AIEngines
    CloudBackend <-->|Server-to-Server IPN| PaymentRails
    UserApp -->|Hosted Checkout Redirect| PaymentRails
```

---

## 3. Core Subsystems

### A. Mobile Application (`lib/`)
The primary touchpoint for consumers, business clients, and field specialists. Built with Flutter 3 and Dart 3 using feature-first clean architecture. Runs across modern 5G/4G 64-bit devices (`arm64-v8a`), legacy 32-bit devices (`armeabi-v7a`), and Web/Desktop environments.

### B. Admin Web Console (`admin-web/`)
A multi-surface web platform built with Next.js 15 App Router serving:
- **Public Landing & Release Distribution Portal:** Live product downloads, SHA-256 verification manifests, real-time client device detection and 5G/4G architecture recommendation.
- **Internal Operations Console:** KYC worker verification queue, dispute resolution desk, and transaction auditing.
- **Super Admin Governance:** Role-based access control (RBAC), WebAuthn/Passkey registration, session revocation, and cryptographic APK release signing policy.

### C. Backend & Database Tier (`supabase/`)
PostgreSQL 15 managed via Supabase Cloud:
- **34 Base Schema Tables + 24 Lifecycle Tables:** Managing enterprise branches, users, taxonomies, dispatches, projects, escrow ledgers, and governance logs.
- **Strict Row-Level Security (RLS):** Every table is guarded by declarative PostgreSQL policies.
- **Atomic Stored Procedures (RPC):** Ensuring all financial ledger debits and credits execute within atomic ACID transactions.
