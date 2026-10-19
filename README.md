# SKAVIA — On-Demand Services & Skilled Workforce Platform

<p align="center">
  <img src="assets/images/skavia_logo.png" alt="SKAVIA Logo" width="240"/>
</p>

<p align="center">
  <strong>Every Skill. Every Opportunity.</strong><br>
  <em>A unified platform for on-demand home repairs, technical services, commercial turnkey projects, and secure escrow payments.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Architecture-Feature--First_Clean-blueviolet?logo=dart&logoColor=white" alt="Clean Architecture"/>
  <img src="https://img.shields.io/badge/Database-Supabase_PostgreSQL_15-3ECF8E?logo=supabase&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Auth-Firebase_Phone_SMS_OTP-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Payment-SSLCommerz_+_bKash_+_Nagad-success" alt="Payment"/>
  <img src="https://img.shields.io/badge/Security-OWASP_MASVS_Hardened-success?logo=owasp&logoColor=white" alt="Security"/>
  <img src="https://img.shields.io/badge/Tests-77/77_Passing_(100%25)-brightgreen" alt="Tests"/>
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"/>
</p>

---

## 📖 1. What is SKAVIA?

**SKAVIA** is an all-in-one platform built for on-demand home services, technical maintenance, and commercial turnkey projects. 

Instead of acting like an unverified open classifieds board where anyone can post an ad, **SKAVIA operates as a trusted, verified service platform**. When a customer books a service, SKAVIA assigns vetted specialists, tracks the work in real time, holds payments safely in escrow, and only releases payment when the customer is completely satisfied.

### The Three Service Branches of SKAVIA:

```mermaid
flowchart TD
    subgraph SKAVIA_PLATFORM ["🏢 SKAVIA Enterprise Platform"]
        TECH["⚡ SKAVIA Technical<br/>(Electrical, AC Inverter, IT & CCTV Security)"]
        HOME["🏡 SKAVIA Home<br/>(Plumbing, Painting, Carpentry, Masonry)"]
        CORP["🏢 SKAVIA Corporate<br/>(Office Renovation, Commercial Fit-Outs, Multi-Trade Teams)"]
    end

    subgraph USERS ["👥 Who Uses SKAVIA?"]
        CUST["👤 Individual Customers<br/>(Doorstep repairs, instant booking)"]
        BIZ["🏢 Businesses & Offices<br/>(Turnkey projects & facility upkeep)"]
        WRK["🔧 Verified Specialists<br/>(Guaranteed jobs & secure payouts)"]
    end

    CUST --> TECH
    CUST --> HOME
    BIZ --> TECH
    BIZ --> CORP
    WRK --> SKAVIA_PLATFORM
```

1. **SKAVIA Technical (`TECH`):** Electrical repairs, inverter AC servicing, industrial wiring, CCTV installation, and network setup.
2. **SKAVIA Home (`HOME`):** Sanitary plumbing, leak repairs, wall painting, waterproofing, and custom wood carpentry.
3. **SKAVIA Corporate (`CORP`):** Full office renovations, commercial fit-outs, and multi-specialist project teams.

---

## 🎯 2. The Problems We Solve

In traditional service markets, hiring a technician is often stressful, risky, and unreliable. SKAVIA solves these everyday problems directly:

| Traditional Problem | Real-World Issue | How SKAVIA Solves It |
| :--- | :--- | :--- |
| **Safety & Trust Concerns** | Strangers enter homes without background checks or verified identity. | **100% Verified Specialists:** Every technician must pass National ID (NID) checks, police verification, and a practical skill test. |
| **Unpredictable Pricing** | Technicians quote arbitrary prices after arriving, leading to arguments. | **Fixed, Upfront Pricing:** Standard catalog services have clear, fixed rates in BDT. No hidden fees. |
| **Unfinished Work** | Contractors demand payment before the work is properly finished. | **4-Digit Handshake OTP:** Technicians cannot mark a job complete without the customer's secret 4-digit code. |
| **Commercial Contract Risks** | Businesses lose money when contractors delay or abandon large projects. | **Milestone Escrow:** Project funds are held securely and released stage by stage only after inspection. |
| **No Arrival Time Tracking** | Customers wait hours without knowing when the technician will arrive. | **Live Proximity Radar:** Customers can view nearby technicians on an animated radar screen. |
| **No Digital Receipts** | Cash payments leave no proof of transaction or tax records. | **Instant Digital Invoices:** Downloadable VAT-compliant receipts are generated automatically for bKash, Nagad, and card payments. |

---

## 🏛️ 3. The Four Core Pillars of SKAVIA

```mermaid
flowchart LR
    P1["🛡️ 1. Full Platform<br/>Accountability"] --> P2["🔒 2. Anti-Fraud<br/>4-Digit Job OTP"]
    P2 --> P3["🧮 3. Smart Matching<br/>Logic"]
    P3 --> P4["💼 4. Milestone Escrow<br/>For Turnkey Projects"]
```

1. **Full Platform Accountability:** Every service request is backed by responsive customer support, quality standards, and customer protection.
2. **Anti-Fraud 4-Digit Handshake OTP:** When a technician finishes work, the customer gives them a secret 4-digit code shown on the customer's phone. Entering this code confirms completion and unlocks the payment.
3. **Smart Matching Logic:** When customers post custom requirements, the system automatically finds and ranks the best-suited specialists based on skills, distance, ratings, and budget.
4. **Milestone Escrow for Turnkey Projects:** Large projects are broken down into clear stages. Money is held safely in escrow and released one stage at a time as each milestone is approved.

---

## 🛠️ 4. Core Features & Smart Logic Used in SKAVIA

Rather than complex academic math, SKAVIA applies clean, real-world software engineering logic to solve everyday on-demand service problems:

### 1. Smart Candidate Matching Logic
* **What we used:** A practical 4-factor scoring check in `SpecialistMatchingEngine`.
* **How it works:** When a customer requests a job, available technicians are ranked by:
  - **Skill Match (40%):** Does the specialist have the exact skills required for this job?
  - **Proximity (25%):** How close is the technician to the customer's location (prioritizing technicians within 2 km)?
  - **Reputation (20%):** Customer ratings and past completed jobs on the platform.
  - **Budget Fit (15%):** Does the specialist's hourly rate match what the customer wants to pay?
* **Why it matters:** The customer instantly sees the top, most relevant specialists at the top of their screen.

---

### 2. Device-Based Distance Calculation
* **What we used:** Direct latitude and longitude distance calculation in `LocationService` and `RadarMapCanvas`.
* **How it works:** Compares the GPS coordinates of the customer and the technician to find the exact distance in kilometers.
* **Why it matters:** Runs directly on the user's phone in milliseconds without needing expensive paid third-party map API requests for simple distance checks.

---

### 3. Anti-Fraud 4-Digit Job OTP Verification
* **What we used:** Secure random 4-digit code verification between `JobOtpBannerCard` and `ActiveJobScreen`.
* **How it works:**
  1. When a booking starts, the system generates a random 4-digit code (e.g. `4821`) visible **only on the customer's phone**.
  2. When the technician completes the repair work on site, the customer tells the code to the technician.
  3. The technician inputs the code into the app.
  4. Once verified by the database, the job marks as completed and the technician receives payment.
* **Why it matters:** Technicians cannot falsely mark jobs completed to claim money without actually visiting the customer.

---

### 4. Safe Financial Settlement (Atomic Database Transaction)
* **What we used:** PostgreSQL stored procedure (`complete_payment_transaction`) inside an atomic database transaction.
* **How it works:**
  - **Duplicate Prevention:** Locks the transaction row so double taps or delayed network requests never process twice.
  - **Automatic Split:** Automatically allocates 85% of the payment to the technician's earnings wallet and 15% to the platform service account.
  - **All-or-Nothing:** Updates booking status, credits wallet balance, and creates an official digital receipt simultaneously. If any step fails, the entire transaction cancels safely.
* **Why it matters:** Guarantees zero lost money, zero duplicate deductions, and accurate bookkeeping.

---

### 5. Interactive Radar Visualizer
* **What we used:** Custom Flutter Canvas rendering in `RadarMapCanvas`.
* **How it works:** Takes GPS locations of nearby specialists and maps them onto a clean circular radar screen with an animated sweep effect.
* **Why it matters:** Customers can see nearby technicians in real time with a modern, responsive UI.

---

### 6. Offline-First Sync Queue
* **What we used:** Local SQLite/cache queuing in `OfflineSyncQueueService` with auto-retry.
* **How it works:** If a user saves an address or updates profile details while having no internet connection, the app saves the action safely on the device. As soon as the internet connection returns, it automatically uploads the changes to the database.
* **Why it matters:** The app never crashes or loses user inputs even in poor network conditions.

---

## 👥 5. User Roles and Experiences

SKAVIA automatically adapts its screens, menus, and permissions based on who logs in:

```mermaid
graph TD
    User([Logged-in User]) --> CheckRole{User Account Type}
    CheckRole -->|Individual Customer| Cust[Customer Experience]
    CheckRole -->|Business / Corporate| Biz[Corporate Experience]
    CheckRole -->|Specialist / Worker| Wrk[Specialist Operations]
```

* 👤 **Individual Customers:** Browse service catalog, book doorstep repairs in 1 tap, describe custom jobs with AI assistance, track technicians on radar, chat in real time, and pay securely via bKash, Nagad, or cards.
* 🏢 **Business Clients:** Manage commercial turnkey renovations, create multi-specialist teams, manage milestone payments in escrow, track progress on Kanban task boards, and download VAT-compliant invoices.
* 🔧 **Specialists & Technicians:** Receive real-time job notifications, manage weekly working shifts, verify completed work using 4-digit OTPs, track earnings, and request bank or MFS withdrawals.

---

## 🏗️ 6. System Architecture

SKAVIA is built following **Clean Architecture** principles to keep code modular, testable, and maintainable:

```
┌────────────────────────────────────────────────────────┐
│               PRESENTATION LAYER (Flutter)             │
│   Screens, Custom Widgets, Theme Tokens, Navigation    │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│               STATE CONTROLLER LAYER                   │
│   ChangeNotifier Controllers (Auth, Customer, Worker)  │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                    DOMAIN LAYER                        │
│   Business Entities, Value Objects, Repository Models  │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                    DATA LAYER                          │
│   Supabase PostgREST, WebSockets, Firebase, SSLCommerz │
└────────────────────────────────────────────────────────┘
```

* **Frontend:** Flutter 3.38+ with Dart 3.10+ (Null-Safe).
* **Database & Realtime:** Supabase PostgreSQL 15 with Row Level Security (RLS) on all 34 tables.
* **Authentication & Media:** Firebase Phone SMS OTP and Firebase Cloud Storage.
* **Payments:** SSLCommerz, bKash, and Nagad.

---

## 🔄 7. How a Service Booking Works

```mermaid
sequenceDiagram
    autonumber
    actor Customer as 👤 Customer
    actor Specialist as 🔧 Specialist
    participant App as 📱 SKAVIA App
    participant DB as 🗄️ Database (Supabase)
    participant Pay as 💳 Payment Gateway

    Customer->>App: Chooses a service or accepts technician quote
    App->>DB: Creates booking (status = pending)
    Customer->>Pay: Pays via bKash / Nagad / Card
    Pay-->>App: Confirms payment with Transaction ID
    
    critical Secure Escrow Lock
        App->>DB: Runs complete_payment_transaction()
        Note over DB: Locks row, checks for duplicates,<br/>credits worker pending wallet (85%),<br/>and generates official invoice
        DB-->>App: Payment locked in escrow
    end

    App-->>Specialist: Sends instant job alert with customer address
    Specialist->>App: Accepts job & taps "On the Way"
    Specialist->>App: Arrives and starts work ("In Progress")

    Note over Customer,Specialist: Work is completed on-site

    Customer->>App: Views secret 4-Digit Job OTP (e.g. 4821)
    Customer-->>Specialist: Shares OTP verbally with technician
    Specialist->>App: Types OTP into ActiveJobScreen
    App->>DB: Validates OTP
    
    alt Correct OTP
        DB-->>App: OTP Verified!
        DB->>DB: Status -> "completed", money released to technician wallet
        App-->>Specialist: Funds now available for withdrawal
        App-->>Customer: Rate your technician (1 to 5 stars)
    else Wrong OTP
        App-->>Specialist: Error: Invalid OTP. Work cannot be marked complete.
    end
```

---

## 📚 8. Master Documentation Index

All technical documents are stored in the [`docs/`](docs/) directory and written in clean, standard English:

| Document | What It Covers | Link |
| :--- | :--- | :--- |
| **System Architecture** | Clean Architecture, folder layout, state controllers, and cloud services | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| **Database Schema** | Complete PostgreSQL schema (38 tables), table relationships, RLS, and stored procedures | [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) |
| **Product Specification** | Features, workflows, branches, OTP handshake, and algorithm specs | [docs/PRODUCT_SPECIFICATION.md](docs/PRODUCT_SPECIFICATION.md) |
| **Project File Directory** | Full categorized inventory of every file in the project and its exact purpose | [docs/PROJECT_FILE_DIRECTORY.md](docs/PROJECT_FILE_DIRECTORY.md) |
| **API & Integration Guide** | Supabase REST, Realtime WebSockets, Firebase Auth, and SSLCommerz payment APIs | [docs/API_AND_INTEGRATION_GUIDE.md](docs/API_AND_INTEGRATION_GUIDE.md) |
| **Routing & Navigation** | App routes, role-based navigation guards, and screen transitions | [docs/ROUTING_AND_NAVIGATION.md](docs/ROUTING_AND_NAVIGATION.md) |
| **Security & Testing** | Security practices, Row Level Security policies, and 77/77 test results | [docs/SECURITY_AND_TESTING.md](docs/SECURITY_AND_TESTING.md) |
| **Feature Traceability Matrix** | Maps every product feature directly to its Flutter screen and database table | [docs/FEATURE_TRACEABILITY_MATRIX.md](docs/FEATURE_TRACEABILITY_MATRIX.md) |
| **Admin Roadmap** | Step-by-step roadmap for building the future Super Admin and Branch Manager web portal | [docs/ADMIN_ROADMAP.md](docs/ADMIN_ROADMAP.md) |

---

## 🚀 9. How to Run the App

### Requirements:
- **Flutter SDK:** Version `3.38+`
- **Dart SDK:** Version `3.10+`
- **Android Studio / VS Code / Xcode**
- **Connected Android or iOS device / emulator**

### Step 1: Set Up Environment Variables
Create a file named `.env` in the project root:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
SSLCOMMERZ_STORE_ID=testbox
SSLCOMMERZ_STORE_PASSWD=qwerty
SSLCOMMERZ_IS_SANDBOX=true
```

### Step 2: Install Packages
```bash
flutter pub get
```

### Step 3: Check Code Quality and Run Tests
```bash
# Check code for any errors or warnings (must show 0 issues)
flutter analyze

# Run all 77 unit, lifecycle, and security tests
flutter test test/unit/
```

### Step 4: Run the Application
```bash
flutter run
```

---

## 🛡️ 10. Quality & Test Summary

```
========================================================================================
SKAVIA QUALITY & VERIFICATION METRICS
========================================================================================
[1] Static Code Analysis (flutter analyze)          : No issues found! (0 warnings)
[2] Automated Test Suite (flutter test test/unit/)  : 77 / 77 Passed (100% Green)
[3] Relational Database Schema                      : 38 Tables with Row Level Security
[4] Financial Settlement                            : Atomic & Idempotent (SEC-13)
[5] Code Architecture                               : Feature-First Clean Architecture
[6] Open-Source License                             : MIT License (Open and Permissive)
========================================================================================
```

---

## 📄 11. License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <strong>SKAVIA</strong><br>
  <em>Every Skill. Every Opportunity.</em><br>
  © 2026 Timon Biswas
</p>
