# SKAVIA — System Architecture & Technical Blueprint

<p align="center">
  <img src="../assets/images/skavia_logo.png" alt="SKAVIA Logo" width="220"/>
</p>

<p align="center">
  <strong>Enterprise Clean Architecture, Reactive State Management & Multi-Cloud Infrastructure Specification</strong><br>
  <em>Production Standard • Architecture Classification: Feature-First Domain-Driven Design (DDD)</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Architecture-Feature--First_Clean-blueviolet?logo=dart&logoColor=white" alt="Clean Architecture"/>
  <img src="https://img.shields.io/badge/State_Management-ChangeNotifier_/_Reactive-02569B?logo=flutter&logoColor=white" alt="State Management"/>
  <img src="https://img.shields.io/badge/Relational_Store-PostgreSQL_15_(Supabase)-3ECF8E?logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Media_Storage-Firebase_Storage-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Auth_Engine-Firebase_+_Session_MFA-FFCA28?logo=firebase&logoColor=black" alt="Firebase"/>
  <img src="https://img.shields.io/badge/Payment_Gateway-SSLCommerz_v4-success" alt="Payment"/>
  <img src="https://img.shields.io/badge/Test_Suite-152_Flutter_+_25_Web_Passing-brightgreen" alt="Tests"/>
</p>

---

## 📑 1. Architectural Philosophy & C4 System Context

SKAVIA is engineered on the foundational principles of **Feature-First Domain-Driven Design (DDD)**, **High Cohesion**, **Loose Coupling**, and **Zero-Trust Cloud Boundaries**. The client mobile application treats the client runtime environment as untrusted, delegating authoritative business validation and financial settlement strictly to PostgreSQL Row Level Security (RLS) policies, Edge Functions (`service_role`), and transactional database procedures.

SKAVIA is designed as **one unified enterprise** operating **9 internal DB specialization branches** (`TECH`, `HOME`, `CORP`, `AGRI`, `LOGI`, `DIGI`, `BIZ`, `CONS`, `EVNT`, with `8` consumer-facing branches presented on the public website and `CORP` representing enterprise operations) across **58 PostgreSQL tables** (34 core schema tables + 24 lifecycle, offline-sync, admin-governance, invitation, passkey, and app-release tables across 8 migrations), rather than an external multi-tenant SaaS. Its web administration and public landing portal live separately in [`admin-web/`](file:///c:/Users/TIMON/Desktop/SKAVIA/admin-web/) (`superadmin.skavia.com`, `admin.skavia.com`, `www.skavia.com`), decoupled from the Flutter consumer/worker mobile application (`lib/`).

### C4 Model — Level 1: System Context Diagram

```mermaid
graph TB
    subgraph Users ["Actors & Stakeholder Personas"]
        ClientUser["👤 Individual Customer<br/>(Service discovery, Instant booking, OTP verification)"]
        BizUser["🏢 Business Client / Organization<br/>(Turnkey projects, Milestone contracts, Kanban boards)"]
        WorkerUser["🔧 Skilled Specialist / Contractor<br/>(Accepts dispatches, Job execution, Wallet earnings)"]
        AdminUser["👔 Internal SKAVIA Administrator<br/>(KYC verification, Dispute mediation, Operations audit)"]
    end

    subgraph SKAVIA_System ["🏢 SKAVIA Core Enterprise Platform"]
        UserApp["📱 SKAVIA Client Application<br/>(Flutter 3.38+ / Dart 3.10+ Null-Safe)"]
        CloudBackend["☁️ SKAVIA Backend Infrastructure<br/>(Supabase PostgreSQL 15, PostgREST API, Realtime WebSockets)"]
        UserApp <-->|HTTPS REST & Realtime WSS| CloudBackend
    end

    subgraph External_Services ["🌐 External Infrastructure & Financial Rails"]
        FirebaseEngine["🔥 Google Firebase Cloud<br/>(Phone SMS OTP, Google OAuth, Cloud Storage Buckets)"]
        PaymentRails["💳 Bangladesh Banking & MFS Rails<br/>(SSLCommerz Gateway v4, bKash Direct, Nagad)"]
        AIEngines["🤖 Natural Language Inference Cloud<br/>(Task breakdown & Diagnostic prompt processing)"]
        MapEngine["🗺️ Geospatial & Cartography Engine<br/>(Geolocator telemetry & Custom Radar Canvas)"]
    end

    ClientUser <-->|Uses| UserApp
    BizUser <-->|Uses| UserApp
    WorkerUser <-->|Uses| UserApp
    AdminUser <-->|Governance & Verification| CloudBackend

    UserApp <-->|Phone Auth & Storage| FirebaseEngine
    UserApp <-->|Telemetry & Distance| MapEngine
    CloudBackend <-->|AI Diagnostics| AIEngines
    CloudBackend <-->|Server-to-Server IPN| PaymentRails
    UserApp -->|Hosted Checkout Redirect| PaymentRails
```

---

### C4 Model — Level 2: Container Architecture Diagram

```mermaid
graph TB
    subgraph ClientContainer ["📱 Client Application Container (Flutter 3.38+ / Dart 3.10+)"]
        PresentationTier["Presentation Layer<br/>(Screens, Micro-Widgets, Theme Tokens)"]
        StateControllers["Reactive State Controller Tier<br/>(AuthController, CustomerDashboardController, WorkerDashboardController, ProjectController)"]
        DomainContracts["Domain Layer<br/>(Entities, Value Objects, Abstract Repositories)"]
        DataSources["Data & Remote Layer<br/>(Supabase PostgREST, Realtime WebSocket, Firebase Storage, SSLCommerz)"]
        
        PresentationTier --> StateControllers
        StateControllers --> DomainContracts
        DataSources -.->|Implements| DomainContracts
    end

    subgraph CloudContainer ["☁️ Supabase Cloud Container (AWS eu-central-1)"]
        PostgREST["PostgREST Direct Data Access API<br/>(Automated CRUD with Row Level Security)"]
        RealtimeEngine["Realtime Engine (WebSockets)<br/>(Live Chat, Dispatch Alerts, Status Sync)"]
        
        subgraph PostgreSQL15 ["PostgreSQL 15 Relational Engine"]
            CoreTables["58 Relational Tables<br/>(core marketplace, lifecycle, governance, releases)"]
            RLSFilters["Strict Row Level Security (RLS) Policies"]
            SettlementRPC["complete_payment_transaction()<br/>(Atomic ACID SECURITY DEFINER RPC, service_role only)"]
            
            CoreTables --- RLSFilters
            SettlementRPC --> CoreTables
        end
    end

    subgraph FirebaseContainer ["🔥 Google Cloud Firebase Container"]
        FirebaseAuth["Firebase Authentication<br/>(Phone SMS OTP Verification)"]
        FirebaseStorage["Firebase Cloud Storage<br/>(Buckets: kyc-documents, portfolio-images, chat-attachments)"]
    end

    DataSources -->|HTTPS REST| PostgREST
    DataSources -->|WSS Protocol| RealtimeEngine
    DataSources -->|Multipart Media Upload| FirebaseStorage
    DataSources -->|SMS Handshake| FirebaseAuth
    
    PostgREST --> CoreTables
    RealtimeEngine --> CoreTables
```

---

## 🏛️ 2. Clean Architecture Tier Breakdown

Every feature inside `lib/features/` follows strict three-tier clean separation:

```mermaid
flowchart TD
    subgraph Presentation ["1. Presentation Layer (UI & Interaction)"]
        Screens["Screens & Composition Layouts<br/>(e.g., CategoryCatalogScreen, BookingTimelineScreen, TaskBoardScreen)"]
        CustomWidgets["Focused Sub-Widgets<br/>(e.g., PostComposerFields, WorkerBalanceCard, ChatMessageBubble, JobOtpBannerCard)"]
        Controllers["ChangeNotifier Controllers<br/>(Business Logic & State Mutation)"]
        
        Screens --> CustomWidgets
        Screens --> Controllers
        CustomWidgets --> Controllers
    end

    subgraph Domain ["2. Pure Domain Layer (Business Contracts)"]
        Entities["Domain Entities<br/>(Plain Dart, Immutable Models: UserEntity, RequirementEntity, ProjectEntity)"]
        RepoContracts["Repository Interfaces<br/>(Abstract Class Signatures)"]
        Engines["Algorithmic Scoring Engines<br/>(Candidate Proximity, Reputation, Skill Match)"]
    end

    subgraph Data ["3. Data Layer (Persistence & Networking)"]
        ModelsDTO["Data Transfer Objects (DTOs)<br/>(fromJson, toJson, copyWith)"]
        RepoImplementations["Repository Implementations<br/>(Implements Abstract Interfaces)"]
        RemoteDS["Remote DataSources<br/>(CustomerRemoteDataSource, WorkerRemoteDataSource, ChatRemoteDataSource)"]
        LocalDS["Secure Local Storage<br/>(SharedPreferences & Cache)"]
        
        RepoImplementations --> ModelsDTO
        RepoImplementations --> RemoteDS
        RepoImplementations --> LocalDS
    end

    Controllers --> Entities
    Controllers --> RepoContracts
    RepoImplementations -.->|Implements| RepoContracts
    RemoteDS --> PostgRESTBackend["Supabase PostgreSQL 15 Backend"]
```

### Architectural Invariants:
1. **Unidirectional Dependency:** Dependencies point strictly inward. Domain knows nothing of Flutter, UI packages, or third-party SDKs.
2. **Deterministic Testability:** Because controllers depend on abstract repository interfaces, any repository can be mocked in unit tests without touching a network socket.
3. **Immutability by Default:** All entities and DTOs provide immutable properties with copy methods (`copyWith`) preventing unexpected side effects during reactive state broadcasts.
4. **Preventing Oversized Files:** Large UI views are split into dedicated, single-responsibility sub-widgets (e.g., separating input bars, rating selectors, and cards into standalone presentation files).

---

## 🔄 3. Dual-Identity & Authentication Synchronization

SKAVIA separates **Firebase Auth** (Flutter mobile client sessions) and **Supabase PostgreSQL 15** identity records. Note that `/functions/v1/analyze-requirement` already verifies Firebase RS256 ID Tokens directly, whereas direct mobile PostgREST/Storage queries currently use the publishable key without minting a Supabase session JWT (meaning Supabase Third-Party Firebase Auth + `auth.jwt() ->> 'sub'` RLS alignment is an explicit pre-production requirement before enabling strict `auth.uid()` enforcement for mobile clients).

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 User / Specialist
    participant App as 📱 Flutter Client
    participant AuthCtrl as ⚙️ AuthController
    participant Firebase as 🔥 Firebase Auth SDK
    participant Supabase as 🗄️ Supabase PostgreSQL 15

    User->>App: Enters Phone Number (+8801XXXXXXXXX)
    App->>Firebase: Submits phone verification request
    Firebase-->>User: Delivers 6-digit SMS OTP
    User->>App: Inputs 6-digit verification code
    App->>Firebase: Validates SMS credential
    Firebase-->>App: Emits Firebase UserCredential (UID, Token)

    critical Database Identity Synchronization
        App->>AuthCtrl: handleAuthSuccess(firebaseUser)
        AuthCtrl->>Supabase: SELECT * FROM public.users WHERE phone = firebaseUser.phoneNumber
        alt User Exists in Database
            Supabase-->>AuthCtrl: Returns user row, current role, and customer/worker profile
        else First-Time User Registration
            AuthCtrl->>Supabase: INSERT INTO public.users (id, phone, full_name, status)
            AuthCtrl->>Supabase: INSERT INTO public.customer_profiles (user_id, customer_type)
            Supabase-->>AuthCtrl: Confirmation of user creation
        end
    end

    AuthCtrl->>AuthCtrl: Hydrates SessionState & active role ('customer' or 'worker')
    AuthCtrl-->>App: Triggers navigation to MainScaffoldScreen
    App-->>User: Mounts role-adaptive navigation shell
```

---

## ⚙️ 4. On-Demand Service Request Lifecycle State Machine

```mermaid
stateDiagram-v2
    [*] --> Draft : Customer selects Service from Catalog
    Draft --> Matching : Customer submits Requirement & Budget
    
    state Matching {
        [*] --> Scoring : Calculate 4-Factor Weighted Score
        Scoring --> CandidateList : Rank Specialists by Compatibility
    }
    
    Matching --> Assigned : Customer selects Specialist or Accepts Bid
    Assigned --> PaymentPending : Booking created, awaiting Escrow
    
    PaymentPending --> Confirmed : complete_payment_transaction RPC succeeds
    PaymentPending --> Cancelled : Payment timeout or cancelled by user
    
    Confirmed --> EnRoute : Specialist accepts dispatch & begins transit
    EnRoute --> InProgress : Specialist arrives at customer site
    
    InProgress --> OtpVerification : Specialist finishes physical work
    
    state OtpVerification {
        [*] --> PromptOtp : Customer shows 4-digit OTP from App
        PromptOtp --> ValidateOtp : Specialist inputs OTP in ActiveJobScreen
    }
    
    OtpVerification --> Completed : 4-Digit OTP matches Database
    OtpVerification --> InProgress : OTP mismatch (Retry allowed)
    
    Completed --> Settled : Escrow released (85% to Worker Wallet, 15% SKAVIA Fee)
    Settled --> Reviewed : Customer submits Verified Star Rating & Compliments
    Reviewed --> [*]
    
    Cancelled --> [*]
```

---

## 🏢 5. Turnkey Commercial Project Lifecycle

```mermaid
flowchart TD
    subgraph Initialization ["1. Tender Creation & Scope Definition"]
        A["Commercial Client posts Turnkey RFP"] --> B["SKAVIA AI parses scope & milestone targets"]
        B --> C["Client approves Budget Cap & Milestones"]
    end

    subgraph Assembly ["2. Specialist Team Assembly"]
        C --> D["Matching engine queries verified specialists"]
        D --> E["Lead Architect & Specialists assigned via team_members"]
        E --> F["Dedicated project chat room initialized in conversations"]
    end

    subgraph Execution ["3. Milestone & Kanban Task Board"]
        F --> G["Milestone 1 funded into Escrow"]
        G --> H["Tasks created in 'Todo' column"]
        H --> I["Specialist pulls task to 'In Progress'"]
        I --> J["Deliverable submitted -> Task moves to 'Done'"]
    end

    subgraph Settlement ["4. Milestone Acceptance & Release"]
        J --> K{"Client inspects Milestone deliverables"}
        K -- Approved --> L["Escrow tranche released to Team Members"]
        L --> M{"Next Milestone?"}
        M -- Yes --> G
        M -- No (All Done) --> N["Project Closed & Formal Commercial VAT Invoice Issued"]
        K -- Revisions Needed --> I
    end
```

---

## 💳 6. Financial & Escrow Settlement Architecture

SKAVIA incorporates strict financial anti-tampering rules: **clients cannot update payment statuses directly**, and **workers cannot withdraw funds until physical inspection is validated via a 4-digit Job OTP**.

```mermaid
sequenceDiagram
    autonumber
    actor Client as 👤 Client
    actor Worker as 🔧 Specialist
    participant App as 📱 SKAVIA Client
    participant PostgREST as 🗄️ Supabase DB
    participant SSL as 🌐 SSLCommerz
    participant Edge as ⚡ Edge Function / RPC
    participant Bank as 🏦 Bank / MFS Rail

    Client->>App: Submits Service Requirement / Accepts Proposal
    App->>PostgREST: Inserts service_requests (status='Draft' -> 'Matching')
    PostgREST-->>App: Confirms requirement broadcasted
    Worker->>App: Submits Proposal / Bid on Incoming Request
    Client->>App: Approves Proposal & selects 'Proceed to Escrow'
    
    App->>PostgREST: Inserts payments (status='pending')
    App->>SSL: Initiates Hosted Checkout Gateway Session
    SSL-->>App: Directs Client to secure payment webview
    Client->>Bank: Completes payment via bKash / Nagad / Card
    Bank-->>SSL: Payment Authorized (TrxID issued)

    critical Server-to-Server Escrow Verification & Settlement
        SSL->>Edge: Dispatches IPN Webhook or Client returns with Transaction ID
        Edge->>SSL: Verifies authenticity with Transaction Validator API
        SSL-->>Edge: Status: VALIDATED
        Edge->>PostgREST: Calls complete_payment_transaction(p_payment_id, p_gateway_name, p_gateway_tx_id, p_val_id, p_verified_amount)
        Note over PostgREST: Status -> 'Completed'<br/>Locks row (FOR UPDATE)<br/>Generates Invoice (INV-XXXX)<br/>Credits Worker Earnings Wallet
    end

    App->>PostgREST: Polls / streams payment settlement
    PostgREST-->>App: Emits payment status: 'Completed'
    App-->>Client: Displays Escrow Locked & Booking Confirmed

    Note over Client,Worker: Specialist arrives on site & performs service

    Client->>App: Taps 'Job Finished' -> App displays 4-Digit Job OTP (e.g., '4821')
    Client-->>Worker: Communicates OTP physically
    Worker->>App: Enters OTP in ActiveJobScreen
    App->>PostgREST: Verifies OTP against service_requests.verification_otp
    
    alt Valid OTP Handshake
        PostgREST-->>App: Verification Confirmed
        PostgREST->>PostgREST: Releases Escrow: inserts worker_earnings (85%) & skavia_fee (15%)
        App-->>Worker: Balance Credited to Withdrawable Wallet
        App-->>Client: Prompts for 5-Star Review & Feedback
    else Invalid OTP Handshake
        App-->>Worker: Error: Invalid Handshake OTP (Anti-Fraud Lock)
    end
```

---

## 🧠 7. Core Applied Algorithms & Systems

SKAVIA uses well-tested software engineering algorithms to power candidate recommendation, distance calculation, fraud protection, financial settlement, and offline synchronization:

1. **4-Factor Weighted Candidate Matching Algorithm:**
   Ranks available specialists using four practical factors: verified skill overlap (40%), geographic proximity (25%), past customer ratings & completed jobs (20%), and rate alignment with client budget (15%).

2. **Haversine Geodetic Distance Algorithm:**
   Calculates exact real-world distance in kilometers between customer and technician coordinates across the Earth's curvature on device without incurring external map API costs.

3. **Cryptographic 4-Digit Handshake OTP Verification:**
   A secure random 4-digit code displayed only on the customer's phone. When the technician finishes the job on site, the customer provides the code to enter in the app, preventing false job completion claims.

4. **Idempotent Atomic Settlement Algorithm:**
   Executed in the PostgreSQL stored procedure `complete_payment_transaction`. Uses database row locking to prevent duplicate payouts, splits amounts automatically (85% worker earnings, 15% platform fee), and rolls back on any error.

5. **Radar Sweep Polar Projection:**
   Converts real-world GPS coordinates into screen canvas pixels, displaying nearby technicians with animated sweeps on a circular radar display.

6. **Exponential Backoff Offline Sync Algorithm:**
   Queues offline actions with unique UUID idempotency keys. When connection returns, it processes queued actions with doubling retry delays (1s, 2s, 4s, 8s) to prevent duplicate transactions and network flooding.

### 7.6 Offline-First Resilience & Sync Queue Architecture
SKAVIA implements an industrial-grade offline sync engine guaranteeing zero data loss:

```mermaid
flowchart TD
    A["User triggers action (e.g. Save Address, Draft Booking)"] --> B{"Network Status"}
    B -- Online --> C["Execute Direct API Request to Supabase"]
    B -- Offline / Poor Network --> D["Write to In-Memory & Persistent LocalCache"]
    D --> E["Enqueue to OfflineSyncQueue with UUID v4 Idempotency Key"]
    E --> F["Show Optimistic UI Update & Offline Status Banner"]
    
    G["Network Connectivity Restored (Online)"] --> H["OfflineSyncQueueManager triggers processQueue()"]
    H --> I["Sequentially Dispatch Items in FIFO Order"]
    I --> J{"Server Response"}
    J -- Success (200/201) --> K["Mark item completed & Purge from Local Queue"]
    J -- Failure (5xx / Timeout) --> L["Increment retryCount & Apply Exponential Backoff (2^r * 1s)"]
    L --> M{"retryCount >= 5?"}
    M -- No --> I
    M -- Yes --> N["Flag item as syncFailed & Alert User for manual retry"]
```

---

## 📂 8. Modular Project Structure

```
SKAVIA/
├── admin-web/               # Separate Next.js 15 Public Website, Super Admin & Internal Admin Portals
├── android/                 # Android Native Host (Manifest, Permissions, FileProvider, Audio)
├── ios/                     # iOS Native Host (Info.plist, Permissions, Audio)
├── assets/                  # High-density logos, emblems, and audio chimes
│   ├── images/              # skavia_logo.png, skavia_emblem.png, google_logo.png
│   └── sounds/              # notification_sound.wav
├── docs/                    # Consolidated Engineering & Operations Documentation
│   ├── ARCHITECTURE.md      # This specification
│   ├── DATABASE_SCHEMA.md   # PostgreSQL 15 ER model (58 tables across 8 migrations), RLS & RPC specs
│   ├── APP_RELEASE_AND_UPDATE_ARCHITECTURE.md # Signed APK verification, public delivery & in-app auto-update
│   └── DEPLOYMENT_GUIDE.md  # Supabase migrations, Vercel setup & Android release build instructions
├── lib/
│   ├── app/                 # App lifecycle, router, theme, bootstrap
│   │   ├── bootstrap.dart   # App initialization, Supabase/Firebase/Notifications/Sync
│   │   ├── router/          # AppRouter, AppRoutes, RouteGuards
│   │   └── theme/           # AppColors, AppTypography, AppDimensions, SkaviaSurfaceTokens
│   ├── core/                # Core platform services, utilities, and constants
│   │   ├── constants/       # App-wide fixed definitions
│   │   ├── network/         # NetworkConnectivityService, OfflineSyncQueueManager, OfflineSyncReplayHandler
│   │   ├── services/        # NotificationService, LocationService, FeatureEligibilityService, MediaPickerService
│   │   ├── storage/         # LocalCacheService, SecureStorageService, RemoteStorageDataSource
│   │   └── utils/           # Formatters, CategoryResolver, JobOtpUtil, UuidUtil, Validators
│   ├── data/                # Global tables and shared data infrastructure
│   ├── features/            # Feature-first domain modules
│   │   ├── admin/           # Mobile admin controllers & governance views (guarded)
│   │   ├── ai_assistant/    # SKAVIA AI diagnostic assistant
│   │   ├── app_update/      # In-app APK update checker, SHA-256 verifier & installer bridge
│   │   ├── authentication/  # Login, OTP verification, 4-role onboarding, dual-identity
│   │   ├── billing/         # Escrow checkout, invoices, transaction history, fee calculator
│   │   ├── chat/            # WebSocket real-time messaging
│   │   ├── customer/        # Post requirement, catalog, live job feed, booking
│   │   ├── matching/        # Algorithmic multi-trade candidate scoring
│   │   ├── navigation/      # MainScaffoldScreen, role-adaptive switcher
│   │   ├── notifications/   # In-app notification center, category filters, dedup
│   │   ├── profile/         # User lifecycle, avatar/cover crop, addresses, completion engine, privacy
│   │   ├── reviews/         # 1-5 star ratings, complaints, reputation scorecard
│   │   ├── team_project/    # Turnkey commercial projects, Kanban board, teams
│   │   └── worker/          # Dispatch feed, active job OTP, earnings, schedule
│   ├── shared/              # Cross-cutting UI widgets, dialogs, and cropper screen
│   │   ├── dialogs/         # FeatureGateDialog, NotificationPermissionSheet, AccountDeletionDialog
│   │   ├── screens/         # ImageCropResizeScreen (1:1 avatar & 16:9 cover crop)
│   │   └── widgets/         # AppButton, AppTextField, OfflineSyncBanner, RadarMapSheet
│   └── main.dart            # Application entrypoint
├── supabase/                # Cloud Supabase configurations, Edge Functions & SQL assets
│   ├── functions/           # Deno Edge Functions (analyze-requirement, verify-sslcommerz-ipn)
│   └── migrations/          # 8 version-controlled idempotent SQL migrations
├── test/
│   └── unit/                # 17 Automated Flutter test suites (152 tests) + admin-web Vitest/Playwright suites (25 tests)
├── .env.example             # Environment template
├── analysis_options.yaml    # Strict Dart analyzer and linter configuration
└── pubspec.yaml             # Flutter project manifest & dependency locks
```
