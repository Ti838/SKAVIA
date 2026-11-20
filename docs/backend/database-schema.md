# PostgreSQL Database Schema & Table Reference

## 1. Schema Overview

The SKAVIA database is engineered in Third Normal Form (3NF) on **PostgreSQL 15** (managed via Supabase Cloud). The schema comprises **34 core tables** plus **24 migration/governance tables** (58 total tables across 8 timestamped migrations):

---

## 2. Core Functional Clusters

### Cluster 1: Organizational Hierarchy & Identity
- `branches`: Internal specialization sectors (`TECH`, `HOME`, `CORP`, `AGRI`, `LOGI`, `DIGI`, `BIZ`, `CONS`, `EVNT`).
- `users`: Core identity table linked to authentication provider UID with status (`active`, `suspended`).
- `user_roles`: Multi-role assignment linking `users` to `branches` and roles (`customer`, `worker`, `business_client`, `admin`).
- `customer_profiles`: Consumer preferences, default addresses, and emergency contacts.
- `worker_profiles`: Trade category, hourly rate, verified skill badge, and active dispatch toggle.

### Cluster 2: Taxonomy & Service SKU Catalog
- `categories`: Service classifications with localized names (English & Bengali).
- `services`: SKU items with base prices, estimated duration, and required trade qualifications.
- `service_addons`: Optional modular add-on equipment or labor extensions.

### Cluster 3: Customer Demand & Bidding
- `requirements`: Turnkey customized requests posted by customers.
- `requirement_bids`: Sealed bids submitted by qualified specialists.

### Cluster 4: Dispatch & Real-Time Telemetry
- `service_requests`: Instant booking orders with 4-digit arrival OTP, timestamps, and status history.
- `service_request_status_history`: Immutable audit trail of every status transition.
- `service_request_coordinates`: Live geospatial breadcrumbs during technician transit.

### Cluster 5: Turnkey Commercial Projects & Kanban
- `projects`: Commercial multi-phase contracts with start/end milestones.
- `project_milestones`: Discrete deliverables tied to escrow tranches.
- `tasks`: Kanban work items (`todo`, `in_progress`, `review`, `done`).
- `teams` & `team_members`: Collaborative multi-trade workforce squads.

### Cluster 6: Real-Time Chat & Communications
- `conversations`: Two-party or group messaging channels.
- `conversation_participants`: Presence, read receipts, and mute status.
- `messages`: Encrypted text, location pins, and media attachment references.

### Cluster 7: Billing, Financial Ledger & Escrow
- `payments`: Payment gateway transaction logs (SSLCommerz, bKash, Card).
- `invoices`: Formal customer bills with breakdown of labor, materials, and taxes.
- `worker_earnings`: Net accrued technician balances available for withdrawal.
- `escrow_accounts`: Locked escrow accounts guaranteeing payout upon job sign-off.

### Cluster 8: Trust, Quality & Platform Governance
- `reviews`: Mutual rating and feedback scores.
- `worker_reputations`: Aggregated completion rates, punctuality, and ratings.
- `disputes` & `dispute_messages`: Formal complaint escalation desk.
- `worker_verifications`: National ID (NID) and trade certificate verification queue.
- `audit_logs`: Immutable security and administrative action logs.
