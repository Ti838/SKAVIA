# SKAVIA — System Routing, Navigation Architecture & RBAC

<p align="center">
  <img src="../assets/images/skavia_logo.png" alt="SKAVIA Logo" width="220"/>
</p>

<p align="center">
  <strong>Declarative Named Route Dispatch, Dynamic Role-Adaptive Shell & Deep Linking Specification</strong><br>
  <em>Flutter 3.38+ • Dart 3.10+ • Single-Enterprise Multi-Role Control</em>
</p>

---

## 📑 1. Master System Navigation Topology

The navigation graph of **SKAVIA** coordinates the end-to-end user lifecycle across all four active user roles (**Individual Customer**, **Business Client**, **Organization**, and **Worker / Specialist**):

```mermaid
flowchart TD
    START(["Application Launch"]) --> SPLASH["SplashScreen (/)"]
    
    SPLASH -->|"Session Check"| GUARD{"Is User Authenticated?"}
    
    GUARD -- No Session --> ONBOARD["OnboardingScreen (/onboarding)"]
    ONBOARD --> LOGIN["LoginScreen (/login)"]
    LOGIN -->|"New User Registration"| REG["RegisterScreen (/register)"]
    REG --> OTP["OtpVerificationScreen (/otp-verify)"]
    OTP --> ROLE_SEL["RoleSelectionScreen (/role-selection)"]
    ROLE_SEL --> SHELL
    LOGIN -->|"Valid Phone / Password"| SHELL
    
    GUARD -- Valid Session --> SHELL["MainScaffoldScreen (/app)"]

    subgraph ADAPTIVE_SHELL ["Persistent Role-Adaptive Navigation Shell (/app)"]
        SHELL --> ROLE_BRANCH{"Active User Persona"}
        ROLE_BRANCH -- "Individual Customer" --> CUST_VIEW["Customer Mode (5 Tabs)"]
        ROLE_BRANCH -- "Business Client" --> BIZ_VIEW["Commercial Workspace (5 Tabs)"]
        ROLE_BRANCH -- "Organization" --> ORG_VIEW["Enterprise Portal (5 Tabs)"]
        ROLE_BRANCH -- "Worker / Specialist" --> WRK_VIEW["Specialist Operations (5 Tabs)"]
    end

    subgraph CUSTOMER_SUBSYSTEM ["Customer Subsystem (/category-catalog, /post-requirement)"]
        CUST_VIEW --> TAB0_CUST["Tab 0: Home & Discovery"]
        CUST_VIEW --> TAB1_CUST["Tab 1: Live Demand Feed"]
        CUST_VIEW --> TAB2_CUST["Tab 2: Post Requirement"]
        CUST_VIEW --> TAB3_CUST["Tab 3: Real-Time Chat"]
        CUST_VIEW --> TAB4_CUST["Tab 4: Customer Profile"]

        TAB0_CUST --> CATALOG["CategoryCatalogScreen (/category-catalog)"]
        TAB2_CUST --> POST_REQ["PostRequirementScreen (/post-requirement)"]
        POST_REQ --> AI_ASSIST["SkaviaAiScreen (/ai-assistant)"]
        POST_REQ --> MATCHES["CandidateMatchesScreen (/candidate-matches)"]
        MATCHES --> WORKER_VIEW["WorkerProfileDetailScreen (/worker-profile)"]
        WORKER_VIEW --> BOOK_CONFIRM["BookingConfirmationScreen (/booking-confirmation)"]
        BOOK_CONFIRM --> CHECKOUT["SimulatedCheckoutScreen (/checkout)"]
        CHECKOUT --> TIMELINE["BookingTimelineScreen (/booking-timeline)"]
        TIMELINE --> OTP_CARD["4-Digit Job Handshake OTP"]
        OTP_CARD --> SUBMIT_REV["SubmitReviewScreen (/submit-review)"]
    end

    subgraph WORKER_SUBSYSTEM ["Specialist Operations Subsystem (/worker/*)"]
        WRK_VIEW --> TAB0_WRK["Tab 0: Operations Hub"]
        WRK_VIEW --> TAB1_WRK["Tab 1: Incoming Job Requests"]
        WRK_VIEW --> TAB2_WRK["Tab 2: Open Job Feed / Bids"]
        WRK_VIEW --> TAB3_WRK["Tab 3: Client Chat"]
        WRK_VIEW --> TAB4_WRK["Tab 4: Specialist Scorecard"]

        TAB1_WRK --> INCOMING["IncomingRequestsScreen (/incoming-requests)"]
        INCOMING --> ACTIVE_JOB["ActiveJobScreen (/active-job)"]
        ACTIVE_JOB --> VALIDATE_OTP["Enter Customer 4-Digit OTP"]
        VALIDATE_OTP --> EARNINGS["WorkerEarningsScreen (/worker-earnings)"]
        TAB0_WRK --> SCHEDULE["AvailabilityCalendarScreen (/availability-calendar)"]
        TAB4_WRK --> PORTFOLIO["PortfolioManagementScreen (/portfolio-management)"]
    end

    subgraph COMMERCIAL_PROJECTS ["Turnkey Commercial Projects Subsystem (/project/*)"]
        BIZ_VIEW --> PROJ_DASH["ProjectDashboardScreen (/project-dashboard)"]
        ORG_VIEW --> PROJ_DASH
        PROJ_DASH --> KANBAN["TaskBoardScreen (/task-board)"]
        PROJ_DASH --> ASSIGN["AssignTaskScreen (/assign-task)"]
        PROJ_DASH --> ROSTER["TeamRosterScreen (/team-roster)"]
    end
```

---

## 🛡️ 2. Dynamic RBAC Navigation Interceptor Pipeline

Every route dispatch through `AppRouter.onGenerateRoute()` is verified against the authenticated user's permissions:

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 User
    participant Router as 🧭 AppRouter
    participant AuthCtrl as ⚙️ AuthController
    participant Guard as 🛡️ RouteGuard
    participant Destination as 📱 Target Screen

    User->>Router: Dispatches Route: /project-dashboard (Arguments: {projectId})
    Router->>AuthCtrl: Query Active Session & Role
    alt User Not Authenticated
        Router-->>User: Redirects to LoginScreen (/login) with returnTo argument
    else User is 'individual_customer'
        AuthCtrl->>Guard: Check Permission: view_commercial_project
        Guard-->>Router: Access Granted if User is Project Owner
        Router->>Destination: Mounts ProjectDashboardScreen
    else User is 'business' OR 'organization'
        Guard-->>Router: Access Authorized
        Router->>Destination: Mounts ProjectDashboardScreen
    else User is 'worker'
        Guard-->>Router: Access Authorized if Worker is assigned in team_members
        Router->>Destination: Mounts ProjectDashboardScreen
    end
```

---

## 🔗 3. Deep Linking & Notification Launch Sequence

```mermaid
sequenceDiagram
    autonumber
    actor OS as 📱 Android / iOS OS
    participant AppLinks as ⚡ AppLinks / FCM
    participant Router as 🧭 AppRouter
    participant Target as 📱 Target Screen (e.g. ChatRoomScreen)

    OS->>AppLinks: Inbound Intent / Deep Link (skavia://chat?conversationId=uuid)
    AppLinks->>Router: AppRouter.onGenerateRoute(RouteSettings)
    Router->>Router: Parse URI Parameters & Extract Query Arguments
    Router->>Target: MaterialPageRoute(ChatRoomScreen(conversationId: uuid))
    Target->>Target: Hydrates ChatController with conversationId
    Target-->>OS: Renders Chat Room UI directly
```

---

## 📋 4. Master Route Inventory & Arguments Specification

| Route Constant | Named Route Path | Target Screen File | Allowed Roles | Argument Payload Structure |
| :--- | :--- | :--- | :--- | :--- |
| `AppRoutes.splash` | `/` | `SplashScreen` | Public | None |
| `AppRoutes.onboarding` | `/onboarding` | `OnboardingScreen` | Public | None |
| `AppRoutes.login` | `/login` | `LoginScreen` | Public | None |
| `AppRoutes.register` | `/register` | `RegisterScreen` | Public | None |
| `AppRoutes.roleSelection`| `/role-selection` | `RoleSelectionScreen` | Authenticated | None |
| `AppRoutes.otpVerify` | `/otp-verify` | `OtpVerificationScreen` | Public | `{'phoneNumber': String, 'fullName': String?, 'verificationId': String?}` |
| `AppRoutes.appShell` | `/app` | `MainScaffoldScreen` | Authenticated | None |
| `AppRoutes.categoryCatalog`| `/category-catalog` | `CategoryCatalogScreen` | Public / All | `{'categoryId': String?, 'searchQuery': String?}` |
| `AppRoutes.postRequirement`| `/post-requirement` | `PostRequirementScreen` | Customer, Biz, Org | `{'categoryId': String?}` |
| `AppRoutes.candidateMatches`| `/candidate-matches`| `CandidateMatchesScreen` | Customer, Biz, Org | `{'requirementId': String, 'requirementTitle': String, 'budget': double}` |
| `AppRoutes.workerProfile`| `/worker-profile` | `WorkerProfileDetailScreen`| All Roles | `{'name': String, 'title': String, 'rating': double, 'hourlyRate': String}` |
| `AppRoutes.bookingConfirmation`| `/booking-confirmation`| `BookingConfirmationScreen`| Customer, Biz, Org| `{'workerProfileId': String, 'workerName': String, 'hourlyRate': double}` |
| `AppRoutes.checkout` | `/checkout` | `SimulatedCheckoutScreen` | Customer, Biz, Org| `{'title': String, 'amount': double, 'serviceRequestId': String?}` |
| `AppRoutes.invoice` | `/invoice` | `InvoiceScreen` | Authenticated | `{'invoiceNumber': String, 'amount': double, 'paidAt': DateTime}` |
| `AppRoutes.paymentSuccess`| `/payment-success` | `PaymentSuccessScreen` | Authenticated | `{'amount': double, 'transactionId': String, 'jobTitle': String}` |
| `AppRoutes.incomingRequests`| `/incoming-requests`| `IncomingRequestsScreen` | Worker | None |
| `AppRoutes.activeJob` | `/active-job` | `ActiveJobScreen` | Worker | None |
| `AppRoutes.workerEarnings`| `/worker-earnings` | `WorkerEarningsScreen` | Worker | None |
| `AppRoutes.availabilityCalendar`| `/availability-calendar`| `AvailabilityCalendarScreen`| Worker | None |
| `AppRoutes.portfolioManagement`| `/portfolio-management`| `PortfolioManagementScreen`| Worker | None |
| `AppRoutes.projectDashboard`| `/project-dashboard`| `ProjectDashboardScreen`| Biz, Org, Worker | `{'projectId': String, 'projectTitle': String}` |
| `AppRoutes.taskBoard` | `/task-board` | `TaskBoardScreen` | Biz, Org, Worker | `{'projectId': String, 'projectTitle': String}` |
| `AppRoutes.assignTask` | `/assign-task` | `AssignTaskScreen` | Biz, Org | `{'projectId': String}` |
| `AppRoutes.teamRoster` | `/team-roster` | `TeamRosterScreen` | Biz, Org, Worker | `{'projectId': String}` |
| `AppRoutes.chatList` | `/chat-list` | `ChatListScreen` | Authenticated | None |
| `AppRoutes.chatRoom` | `/chat-room` | `ChatRoomScreen` | Authenticated | `{'conversationId': String, 'otherParticipantName': String}` |
| `AppRoutes.submitReview` | `/submit-review` | `SubmitReviewScreen` | Customer, Biz, Org| `{'workerProfileId': String, 'serviceRequestId': String?}` |
| `AppRoutes.workerReputation`| `/worker-reputation`| `WorkerReputationScreen` | Authenticated | `{'workerProfileId': String, 'workerName': String}` |
| `AppRoutes.skaviaAi` | `/ai-assistant` | `SkaviaAiScreen` | All Roles | `{'initialPrompt': String?}` |
| `AppRoutes.liveJobFeed` | `/live-job-feed` | `LiveJobFeedScreen` | All Roles | None |
| `AppRoutes.adminDashboard`| `/admin-dashboard` | `AdminDashboardScreen` | Admin / Internal | None (Governance Hub) |
