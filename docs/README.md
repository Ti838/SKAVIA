# SKAVIA Documentation Hub

Welcome to the official technical documentation library for **SKAVIA** — an on-demand, high-accountability service and workforce management ecosystem developed independently by **Timon Biswas** ([@Ti838](https://github.com/Ti838)).

This documentation hub provides an exhaustive, verified reference for the entire system architecture, database design, mobile application, web administration portal, release infrastructure, and operational procedures.

---

## 📚 Documentation Directory

```
docs/
├── README.md                          # This index and overview
│
├── architecture/                      # System blueprints and architectural designs
│   ├── system-overview.md             # High-level C4 context, business domain, and multi-tier layout
│   ├── application-architecture.md    # Flutter Clean Architecture, Layering & State Management
│   ├── feature-architecture.md        # Modular feature-first source tree organization
│   ├── authentication-flow.md         # Firebase Phone SMS OTP, Google OAuth & Supabase JWT handshake
│   ├── authorization-and-roles.md     # 4 User Roles, ABAC/RBAC, and Row-Level Security (RLS)
│   ├── data-flow.md                   # Real-time WebSockets, offline sync, and event lifecycles
│   └── infrastructure.md              # Multi-cloud layout (Supabase, Firebase, Vercel, SSLCommerz)
│
├── diagrams/                          # Standalone, editable Mermaid architectural diagrams
│   ├── system-context.mmd             # C4 Level-1 System Context Diagram
│   ├── component-diagram.mmd          # C4 Level-2 & Level-3 Flutter Component Decomposition
│   ├── class-diagram.mmd              # Core Domain Entity & Repository Class Relationships
│   ├── database-er-diagram.mmd        # PostgreSQL 34-Table Relational Schema Diagram
│   ├── authentication-flow.mmd        # Sequence diagram of Phone OTP & Passkey WebAuthn
│   ├── user-journey.mmd               # End-to-end booking, dispatch, OTP arrival & escrow payout
│   └── deployment-diagram.mmd         # Production multi-surface cloud topology
│
├── development/                       # Developer guides, local setup, and engineering standards
│   ├── getting-started.md             # Prerequisites, environment variables & local initialization
│   ├── project-structure.md           # Deep dive into directory conventions and responsibilities
│   ├── coding-guidelines.md           # Dart 3 / Flutter style guide, responsive rules & anti-patterns
│   ├── dependencies.md                # Complete dependency audit and rationale
│   └── troubleshooting.md             # Common errors, build issues, and debugging workflows
│
├── backend/                           # PostgreSQL, Supabase, and Serverless specifications
│   ├── database-schema.md             # Full 58-table catalog, migrations, indexes, and triggers
│   ├── supabase-integration.md        # PostgREST querying, Realtime channels, and RPC procedures
│   ├── rls-security.md                # Row Level Security policies and security hardening
│   ├── storage.md                     # Storage bucket policies (Firebase Storage & Supabase releases)
│   └── api-reference.md               # Next.js App Router endpoints & Supabase RPC functions
│
├── features/                          # In-depth functional specifications of core capabilities
│   ├── authentication.md              # Phone OTP, Google Sign-In, onboarding & role selection
│   ├── user-roles.md                  # Customer, Worker, Business Client & Admin roles
│   ├── customer.md                    # Service discovery, instant booking & requirement posting
│   ├── worker.md                      # Incoming requests, dispatch radar, work log & earnings wallet
│   ├── services.md                    # 8 Standard trade categories, SKU taxonomy & pricing rules
│   ├── booking.md                     # Order lifecycle, arrival verification OTP & job completion
│   ├── payments.md                    # SSLCommerz gateway, escrow accounts & payout settlement
│   └── localization.md                # Dual-language architecture (English & Bengali)
│
├── deployment/                        # DevOps, release pipelines, and distribution
│   ├── android-release.md             # Keystore signing, R8 shrinking & per-ABI APK generation
│   ├── ios-release.md                 # iOS configuration and Web App (PWA) parity
│   └── production-checklist.md       # Pre-flight audit, environment verification & health checks
│
└── project/                           # Project metadata, legal attribution, and history
    ├── project-status.md              # Current development status, test metrics & milestones
    ├── roadmap.md                     # Future release roadmap and enhancements
    ├── changelog.md                   # Chronological version history
    └── third-party-licenses.md        # Complete third-party open-source license inventory
```

---

## ⚡ Quick Navigation

| If you are looking for... | Start here: |
| :--- | :--- |
| **How to run the Flutter app locally** | [Getting Started](development/getting-started.md) |
| **Understanding the Flutter architecture** | [Application Architecture](architecture/application-architecture.md) |
| **Database tables and PostgreSQL schema** | [Database Schema](backend/database-schema.md) |
| **System diagrams (editable Mermaid)** | [Diagrams Directory](diagrams/) |
| **In-app device diagnostics & 5G support** | [Application Architecture](architecture/application-architecture.md) & [Changelog](project/changelog.md) |
| **License, copyright, and legal attribution** | [LICENSE](../LICENSE) & [Third-Party Licenses](project/third-party-licenses.md) |
