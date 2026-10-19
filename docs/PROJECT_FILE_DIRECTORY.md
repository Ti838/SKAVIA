# SKAVIA — Complete Project File Directory & Module Map

<p align="center">
  <strong>Comprehensive Architecture & Directory Navigation Guide</strong><br>
  <em>Clean Architecture • Feature-First Directory Structure • Standard Reference</em>
</p>

---

## 📑 Directory Navigation Quick Links

- [1. App & Platform Initialization (`lib/app`)](#1-app--platform-initialization-libapp)
- [2. Core Infrastructure & System Services (`lib/core`)](#2-core-infrastructure--system-services-libcore)
- [3. Authentication & Onboarding (`lib/features/authentication`)](#3-authentication--onboarding-libfeaturesauthentication)
- [4. Customer & Service Marketplace (`lib/features/customer`)](#4-customer--service-marketplace-libfeaturescustomer)
- [5. Specialist Worker & Field Operations (`lib/features/worker`)](#5-specialist-worker--field-operations-libfeaturesworker)
- [6. Commercial Turnkey Projects & Kanban (`lib/features/team_project`)](#6-commercial-turnkey-projects--kanban-libfeaturesteam_project)
- [7. Profile, Saved Locations & Lifecycle (`lib/features/profile`)](#7-profile-saved-locations--lifecycle-libfeaturesprofile)
- [8. In-App Notification Center (`lib/features/notifications`)](#8-in-app-notification-center-libfeaturesnotifications)
- [9. Algorithmic Candidate Matching (`lib/features/matching`)](#9-algorithmic-candidate-matching-libfeaturesmatching)
- [10. Real-Time WebSocket Chat (`lib/features/chat`)](#10-real-time-websocket-chat-libfeatureschat)
- [11. Escrow Billing & Invoice Engine (`lib/features/billing`)](#11-escrow-billing--invoice-engine-libfeaturesbilling)
- [12. Verified Reviews & Reputation (`lib/features/reviews`)](#12-verified-reviews--reputation-libfeaturesreviews)
- [13. SKAVIA AI Diagnostic Assistant (`lib/features/ai_assistant`)](#13-skavia-ai-diagnostic-assistant-libfeaturesai_assistant)
- [14. Navigation Shell & Adaptive Switching (`lib/features/navigation`)](#14-navigation-shell--adaptive-switching-libfeaturesnavigation)
- [15. Shared UI Widgets, Canvas & Dialogs (`lib/shared`)](#15-shared-ui-widgets-canvas--dialogs-libshared)
- [16. Supabase Database Migrations (`supabase/`)](#16-supabase-database-migrations-supabase)
- [17. Automated Unit & Security Test Suite (`test/unit/`)](#17-automated-unit--security-test-suite-testunit)
- [18. Technical Documentation Suite (`docs/`)](#18-technical-documentation-suite-docs)

---

## 1. App & Platform Initialization (`lib/app`)

Controls bootstrap initialization, theming, design tokens, and application-wide routing:

```
lib/
├── firebase_options.dart                 # Auto-generated Firebase cross-platform configuration
├── main.dart                             # Application entrypoint
└── app/
    ├── app.dart                          # Root MaterialApp widget with dark/light theme binding
    ├── bootstrap.dart                    # App initialization (Supabase, Firebase, Offline Sync, Notifications)
    ├── config/
    │   ├── app_config.dart               # Environment configuration loader (.env)
    │   └── app_constants.dart            # Global timeout, app version and build tokens
    ├── router/
    │   ├── app_router.dart               # GoRouter route declarations and redirect logic
    │   ├── app_routes.dart               # Centralized type-safe route names constants
    │   └── route_guards.dart             # Role-based route authorization interceptors
    └── theme/
        ├── app_colors.dart               # Brand palette (Navy, Emerald, Coral, Slate, Card darks)
        ├── app_dimensions.dart           # Standard padding, margin, border-radius, and icon sizing tokens
        ├── app_theme.dart                # ThemeData definitions for Light & Dark mode
        └── app_typography.dart           # Inter typography scale (Display, Headline, Body, Caption)
```

---

## 2. Core Infrastructure & System Services (`lib/core`)

Cross-cutting system services, hardware interfaces, resilience engines, and formatters:

```
lib/core/
├── constants/
│   ├── app_assets.dart                   # Asset paths for logos, icons, illustrations, and audio files
│   ├── app_constants.dart                # Fixed limits, API endpoints, and platform standards
│   └── app_strings.dart                  # User-facing text constants (English standard)
├── errors/
│   ├── app_exception.dart                # Base domain exceptions (NetworkException, AuthException, etc.)
│   └── failure.dart                      # Clean Architecture Failure types returned by repositories
├── extensions/
│   ├── context_extensions.dart           # BuildContext helpers for theme, media query, and navigation
│   └── string_extensions.dart            # String manipulation, title casing, and masking helpers
├── helpers/
│   ├── formatters.dart                   # Currency (BDT ৳), date/time, and phone number formatting
│   └── validators.dart                   # Email, password, phone, and form field validators
├── network/
│   ├── network_connectivity_service.dart # 5-State network quality monitor (online, poor, offline, syncing, syncFailed)
│   ├── network_info.dart                 # Connectivity interface wrapper
│   └── offline_sync_queue_manager.dart   # FIFO offline sync queue with exponential backoff & UUID idempotency
├── services/
│   ├── app_language_service.dart         # Multi-language selection and persistence
│   ├── app_theme_service.dart            # Theme switching service (Light, Dark, System)
│   ├── device_permission_service.dart    # Graceful permission rationale dialogs (Camera, Location, Push)
│   ├── feature_eligibility_service.dart  # Centralized eligibility gatekeeper (bookService, acceptJob, etc.)
│   ├── location_service.dart             # GPS geolocator wrapper and geodetic coordinate queries
│   ├── logging_service.dart              # Structured developer console logger
│   ├── notification_service.dart         # Local sound channels & push notification handlers
│   ├── skavia_ai_service.dart            # Client interface for SKAVIA diagnostic AI
│   └── storage_service.dart              # Shared preferences wrapper
├── storage/
│   ├── local_cache_service.dart          # In-memory and persistent TTL cache
│   └── secure_storage_service.dart       # Encrypted keystore/keychain for tokens
└── utils/
    ├── formatters.dart                   # Common display formatters
    ├── ui_feedback_helper.dart           # Toasts, Snackbars, and haptic feedback triggers
    └── uuid_util.dart                    # RFC 4122 Version 4 UUID generators & validators
```

---

## 3. Authentication & Onboarding (`lib/features/authentication`)

User login, registration invariant, OTP verification, and role selection:

```
lib/features/authentication/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart    # Cached session and JWT token storage
│   │   └── auth_remote_datasource.dart   # Supabase Auth and Firebase Phone Auth APIs
│   ├── models/
│   │   └── user_model.dart               # User entity JSON serialization/deserialization
│   └── repositories/
│       └── auth_repository_impl.dart     # Repository implementation connecting data sources
├── domain/
│   └── repositories/
│       └── auth_repository.dart          # Abstract domain contract for authentication
└── presentation/
    ├── controllers/
    │   └── auth_controller.dart          # Reactive StateNotifier for login, OTP, and session
    ├── screens/
    │   ├── login_screen.dart             # Unified Phone & Email login tabbed view
    │   ├── otp_verification_screen.dart  # 6-Digit auto-focus SMS OTP verification screen
    │   ├── register_screen.dart          # 100% UNMODIFIED clean single-step registration form
    │   └── role_selection_screen.dart    # Customer vs Specialist worker role selection screen
    └── widgets/
        ├── email_login_form.dart         # Email + password input form
        ├── onboarding_auth_sheet.dart    # Guest-to-authenticated bottom sheet
        ├── phone_login_form.dart         # BD (+880) phone number input form
        └── platform_info_sheet.dart      # SKAVIA company and division overview modal
```

---

## 4. Customer & Service Marketplace (`lib/features/customer`)

Customer experience, fixed SKU catalog, post requirement stepper, booking confirmation, and active job tracking:

```
lib/features/customer/
├── data/
│   ├── datasources/
│   │   ├── catalog_remote_datasource.dart # Fetches trade categories & fixed SKU services
│   │   └── customer_remote_datasource.dart# Handles requirement posting, bookings, and tracking
│   ├── models/
│   │   ├── category_model.dart            # Trade category entity (Technical, Home, Corporate)
│   │   ├── service_model.dart             # Fixed-price SKU service item
│   │   └── service_request_model.dart     # Booking lifecycle and dispatch record
│   └── repositories/
│       └── customer_repository_impl.dart  # Data layer implementation of CustomerRepository
├── domain/
│   └── repositories/
│       └── customer_repository.dart       # Customer domain contract
└── presentation/
    ├── controllers/
    │   ├── customer_dashboard_controller.dart # Manages feed, active bookings, and search
    │   └── post_requirement_controller.dart   # Manages 4-step custom job posting stepper
    ├── screens/
    │   ├── booking_confirmation_screen.dart   # Order summary, address check & checkout navigation
    │   ├── booking_timeline_screen.dart       # Real-time lifecycle stepper (Matching -> Assigned -> In-Progress -> Done)
    │   ├── category_catalog_screen.dart       # 8 Trade categories and service browsing
    │   ├── customer_dashboard_screen.dart     # Main customer dashboard and discovery feed
    │   ├── post_requirement_screen.dart       # Custom requirement wizard with AI scope assistant
    │   └── service_detail_screen.dart         # Full SKU breakdown, pricing, and warranty details
    └── widgets/
        ├── booking_payment_details_card.dart  # Itemized bill card (Price + Platform Fee + VAT)
        ├── booking_payment_method_list.dart   # Payment method selector (bKash, Nagad, Cards)
        ├── booking_timeline_step.dart         # Individual timeline tracking node widget
        ├── catalog_filter_pill.dart           # Interactive category filter chips
        ├── catalog_search_bar.dart            # Real-time SKU and keyword search input
        ├── catalog_service_card.dart          # SKU card with image, title, price, and Book CTA
        ├── feed_card_actions.dart             # Card action buttons (View Details, Book Now)
        ├── feed_card_body.dart                # Service description and tag layout
        ├── feed_card_header.dart              # Service title, category badge, and icon
        ├── feed_category_chips.dart           # Horizontal scrolling category selector
        ├── feed_composer_prompt_card.dart     # "What service do you need today?" banner card
        ├── feed_filter_tabs.dart              # Urgent, Scheduled, and Popular service filter tabs
        ├── feed_search_urgent_bar.dart        # Search input with urgent dispatch toggle
        ├── feed_skeleton_loader.dart          # Shimmer placeholder during feed network fetch
        ├── job_otp_banner_card.dart           # Anti-fraud 4-digit completion OTP displayed to client
        ├── post_composer_fields.dart          # Requirement description and image upload fields
        ├── post_requirement_ai_button.dart    # One-tap AI diagnostic breakdown button
        ├── post_requirement_deadline_selector.dart # Date and time picker for service schedule
        ├── post_type_selector.dart            # Instant emergency vs scheduled appointment toggle
        └── timeline_worker_card.dart          # Assigned technician card with phone & chat actions
```

---

## 5. Specialist Worker & Field Operations (`lib/features/worker`)

Specialist dashboard, dispatch requests, active job execution, OTP handshake, shift availability, and earnings:

```
lib/features/worker/
├── data/
│   ├── datasources/
│   │   └── worker_remote_datasource.dart     # Worker jobs, earnings, availability, and verification APIs
│   ├── models/
│   │   ├── worker_earning_model.dart         # Detailed ledger of job earnings and withdrawals
│   │   └── worker_profile_model.dart         # Specialist skills, rating, shift schedule, and balance
│   └── repositories/
│       └── worker_repository_impl.dart       # Worker data repository implementation
├── domain/
│   └── repositories/
│       └── worker_repository.dart            # Worker domain contract
└── presentation/
    ├── controllers/
    │   ├── worker_dashboard_controller.dart  # Manages incoming requests, active job state, and balance
    │   └── worker_profile_controller.dart    # Manages trade skills, shifts, and KYC uploads
    ├── screens/
    │   ├── active_job_screen.dart            # Active job details, map route, and completion OTP prompt
    │   ├── availability_calendar_screen.dart # Weekly working shift scheduler grid
    │   ├── incoming_requests_screen.dart     # Nearby dispatch requests feed with Accept/Reject
    │   ├── portfolio_management_screen.dart  # Specialist past project photo gallery
    │   ├── worker_dashboard_screen.dart      # Specialist operational hub with job stats
    │   ├── worker_earnings_screen.dart       # 85% Net earnings balance & withdrawal request modal
    │   ├── worker_edit_profile_screen.dart   # Edit trade skills, hourly rate, and bio
    │   └── worker_profile_detail_screen.dart # Public view of specialist profile and customer reviews
    └── widgets/
        ├── active_job_client_card.dart       # Client contact, address, and special instructions
        ├── active_job_lifecycle_stepper.dart # On-the-way, Arrived, In-Progress status stepper
        ├── earnings_metric_tile.dart         # Total jobs, lifetime earnings, and pending payout cards
        ├── incoming_request_card.dart        # Request card with distance, payout, and timer
        ├── worker_balance_card.dart          # Total withdrawable balance card with Payout CTA
        ├── worker_dashboard_view.dart        # Top summary stats and active job banner
        ├── worker_incoming_requests_list.dart# Reactive list of pending dispatch broadcasts
        ├── worker_job_otp_sheet.dart         # Modal bottom sheet for entering customer's 4-digit OTP
        ├── worker_stat_cards.dart            # On-time rate, completion rate, and rating metrics
        ├── worker_verification_section.dart  # NID card front/back upload and KYC status badge
        ├── worker_weekly_schedule_selector.dart # 7-Day shift availability toggle matrix
        └── worker_withdrawal_sheet.dart      # bKash/Nagad/Bank payout request bottom sheet
```

---

## 6. Commercial Turnkey Projects & Kanban (`lib/features/team_project`)

Corporate fit-outs, milestone escrow contracts, multi-specialist team assembly, and Kanban task boards:

```
lib/features/team_project/
├── data/
│   ├── datasources/
│   │   └── project_remote_datasource.dart     # CRUD for projects, milestones, tasks, and team rosters
│   ├── models/
│   │   ├── project_fallback_data.dart         # Safe offline fallback data for corporate projects
│   │   ├── project_milestone_model.dart       # Milestone deliverables and escrow amount tranches
│   │   ├── project_model.dart                 # Commercial project entity (Budget, status, client)
│   │   ├── project_task_model.dart            # Kanban task model (Todo, In-Progress, Done, priority)
│   │   └── team_member_model.dart             # Cross-trade specialist member in project roster
│   └── repositories/
│       └── project_repository_impl.dart       # Data repository implementation
├── domain/
│   └── repositories/
│       └── project_repository.dart            # Domain contract
└── presentation/
    ├── controllers/
    │   └── project_controller.dart            # Manages Kanban task columns, milestones, and escrow releases
    ├── screens/
    │   ├── create_project_screen.dart         # Corporate RFP submission wizard with budget cap
    │   ├── project_dashboard_screen.dart      # Project overview, milestones progress, and tranches
    │   ├── task_board_screen.dart             # Interactive drag-and-drop Kanban task board
    │   └── team_roster_screen.dart            # Multi-trade team assembly (Lead, Electrician, Plumber)
    └── widgets/
        ├── milestone_progress_card.dart       # Funded milestone card with Release Escrow CTA
        ├── project_action_dialogs.dart        # Add task, release escrow tranche, and invite member dialogs
        ├── project_members_tab_view.dart      # List of assigned specialists with trade badges
        ├── project_task_item_card.dart        # Kanban card with priority badge, assignee, and checklist
        ├── project_top_tab_selector.dart      # Overview, Tasks, Team, and Invoices tab bar
        └── team_member_tile.dart              # Specialist tile with skills and contact button
```

---

## 7. Profile, Saved Locations & Lifecycle (`lib/features/profile`)

Progressive profiling, dynamic completion engine, saved geocoded addresses, privacy, and account deactivation:

```
lib/features/profile/
├── data/
│   ├── datasources/
│   │   └── profile_remote_datasource.dart     # Supabase profiles, addresses, and privacy settings APIs
│   └── models/
│       ├── user_address_model.dart            # Geocoded address model (Home, Office, zone, lat/lng)
│       └── user_profile_model.dart            # Full profile model (DOB, emergency contact, settings)
├── domain/
│   └── services/
│       └── profile_completion_engine.dart     # Dynamic role-weighted scoring (15% Name, 20% Address, etc.)
└── presentation/
    ├── controllers/
    │   └── profile_controller.dart            # StateNotifier for profile edits, address CRUD, and privacy
    ├── screens/
    │   ├── edit_detailed_profile_screen.dart  # Form for DOB, emergency contact, gender, and bio
    │   ├── notification_preferences_screen.dart# Push, SMS, and Email category notification toggles
    │   ├── privacy_security_screen.dart       # Password change, privacy settings, and 30-day deactivation
    │   └── saved_addresses_screen.dart        # Multi-location saved address list with Add/Delete
    └── widgets/
        └── profile_completion_banner_card.dart# Score percentage progress bar with Next Best Action button
```

---

## 8. In-App Notification Center (`lib/features/notifications`)

Multi-category in-app notifications, birthday perk alerts, and zero-spam deduplication:

```
lib/features/notifications/
├── data/
│   └── models/
│       └── app_notification_model.dart        # Notification entity (Category, dedup_key, is_read, route)
└── presentation/
    ├── controllers/
    │   └── notification_center_controller.dart # Manages notifications, unread badges, and birthday gifts
    └── screens/
        └── notification_center_screen.dart    # In-app feed with category filter chips and dismiss actions
```

---

## 9. Algorithmic Candidate Matching (`lib/features/matching`)

Mathematical 4-factor recommendation engine and candidate ranking:

```
lib/features/matching/
├── domain/
│   └── services/
│       └── matching_scoring_engine.dart       # 40% Skill, 25% Proximity, 20% Rating, 15% Budget formula
└── presentation/
    ├── screens/
    │   └── candidate_matches_screen.dart      # Ranked list of recommended specialists with match score
    └── widgets/
        ├── candidate_match_card.dart          # Specialist preview card with matched skills and rate
        └── match_score_badge.dart             # Colored percentage badge (e.g., "94% Match")
```

---

## 10. Real-Time WebSocket Chat (`lib/features/chat`)

Instant messaging between clients and technicians with Supabase Realtime WebSockets:

```
lib/features/chat/
├── data/
│   ├── datasources/
│   │   └── chat_remote_datasource.dart        # Realtime WebSocket stream, message persistence, and receipts
│   └── models/
│       ├── chat_message_model.dart            # Text, image attachment, sender, timestamp, and read status
│       └── conversation_model.dart            # Conversation entity linking client, worker, and job
└── presentation/
    ├── controllers/
    │   └── chat_controller.dart               # Message stream listener, send message, and unread count
    ├── screens/
    │   ├── chat_room_screen.dart              # Active conversation chat window with photo upload
    │   └── conversations_list_screen.dart     # Recent conversations list with last message snippet
    └── widgets/
        ├── chat_empty_state.dart              # Empty conversation placeholder
        ├── chat_input_bar.dart                # Text field with attachment and send icon buttons
        ├── chat_message_bubble.dart           # Incoming vs outgoing chat bubble with timestamp
        └── conversation_tile.dart             # Conversation item tile with avatar and unread count badge
```

---

## 11. Escrow Billing & Invoice Engine (`lib/features/billing`)

Simulated MFS checkouts, atomic financial settlements, and downloadable VAT invoices:

```
lib/features/billing/
├── domain/
│   └── services/
│       └── billing_calculator_service.dart    # 85/15 Revenue split and VAT calculation logic
└── presentation/
    ├── screens/
    │   ├── invoice_screen.dart                # Official VAT-compliant digital invoice with print/share
    │   ├── payment_success_screen.dart        # Escrow protection confirmation and receipt download
    │   └── simulated_checkout_screen.dart     # Direct bKash, Nagad, and Card checkout webview/UI
    └── widgets/
        ├── order_summary_card.dart            # Itemized checkout card with platform fee and tax
        ├── payment_disclaimer_card.dart       # Escrow guarantee and refund policy notice
        └── payment_method_selector.dart       # Radio selector for bKash, Nagad, Visa, Mastercard
```

---

## 12. Verified Reviews & Reputation (`lib/features/reviews`)

Post-service 1-5 star ratings, compliments, and specialist reputation scorecards:

```
lib/features/reviews/
├── data/
│   ├── datasources/
│   │   └── review_remote_datasource.dart      # Submits reviews and fetches specialist reputation
│   └── models/
│       ├── reputation_model.dart              # Overall score, on-time rate, and badge tier (Silver, Gold, Diamond)
│       └── review_model.dart                  # Rating, comment, compliments, and date
└── presentation/
    ├── controllers/
    │   └── review_controller.dart             # Review form state and submission handling
    ├── screens/
    │   └── submit_review_screen.dart          # Star rating selector, compliments, and text review screen
    └── widgets/
        ├── review_compliments_section.dart    # Quick tags (e.g., "Punctual", "Expert", "Polite")
        ├── review_rating_selector.dart        # Interactive 5-star rating selector widget
        └── review_worker_card.dart            # Specialist avatar and service summary card
```

---

## 13. SKAVIA AI Diagnostic Assistant (`lib/features/ai_assistant`)

Generative diagnostic assistant for automated job scope breakdown and cost estimation:

```
lib/features/ai_assistant/
└── presentation/
    ├── screens/
    │   └── skavia_ai_screen.dart              # AI Chat consultation screen with quick repair prompts
    └── widgets/
        ├── ai_chat_view.dart                  # Streaming response message bubble view
        └── ai_diagnostic_prompt_chips.dart    # One-tap symptom chips ("AC not cooling", "Pipe leaking")
```

---

## 14. Navigation Shell & Adaptive Switching (`lib/features/navigation`)

Main scaffold, role-adaptive bottom navigation bar, and persistent banners:

```
lib/features/navigation/
└── presentation/
    ├── screens/
    │   └── main_scaffold_screen.dart          # App scaffold hosting the OfflineSyncBanner and BottomNavBar
    └── widgets/
        ├── app_bottom_nav_bar.dart            # Standard customer bottom navigation bar
        └── role_adaptive_nav_bar.dart         # Adaptive nav bar switching between Customer and Worker tabs
```

---

## 15. Shared UI Widgets, Canvas & Dialogs (`lib/shared`)

Reusable atomic UI components, radar sweeps, modals, loaders, and empty states:

```
lib/shared/
├── dialogs/
│   ├── confirmation_dialog.dart               # Generic confirm/cancel alert modal
│   ├── error_dialog.dart                      # Friendly error popup with retry button
│   ├── feature_gate_dialog.dart               # Just-in-time modal prompting missing profile attributes
│   └── notification_permission_sheet.dart     # System permission rationale bottom sheet
├── empty_states/
│   └── empty_data_view.dart                   # Illustrated empty placeholder with CTA
├── error_states/
│   └── error_view.dart                        # Full-screen network or system error view
├── loaders/
│   ├── app_loading_indicator.dart             # Circular brand loading spinner
│   └── list_shimmer_skeleton.dart             # Skeleton shimmer loader for lists
└── widgets/
    ├── app_app_bar.dart                       # Standard branded top AppBar with back and actions
    ├── app_button.dart                        # Primary, Secondary, and Outlined brand buttons
    ├── app_card.dart                          # Rounded elevated surface card with custom borders
    ├── app_text_field.dart                    # Outlined form input with label, prefix, and validator
    ├── offline_sync_banner.dart               # Real-time top banner for offline status & syncing
    ├── radar_location_banner.dart             # Current zone and GPS accuracy banner
    ├── radar_map_canvas.dart                  # CustomPainter circular rotating sweep radar canvas
    ├── radar_map_controls.dart                # Zoom and filter controls for proximity radar
    ├── radar_map_sheet.dart                   # Bottom sheet presenting proximity radar
    ├── radar_technician_card.dart             # Specialist node card on radar sweep
    └── user_avatar.dart                       # Circular cached network image avatar with fallback initials
```

---

## 16. Supabase Database Migrations (`supabase/`)

PostgreSQL 15 database tables, RLS policies, and stored procedures:

```
supabase/
└── migrations/
    ├── 20261110000000_baseline_schema.sql     # Baseline 34 tables (users, services, requests, escrow)
    └── 20261110220000_complete_user_lifecycle_and_offline_sync.sql
        ├── 35. user_addresses                 # Saved customer service locations & coordinates
        ├── 36. user_sessions                  # Active device sessions and platform security audit
        ├── 37. offline_sync_queue             # Persistent offline sync queue with UUID idempotency
        ├── 38. user_notifications             # In-app notification store with dedup_key
        ├── RPC calculate_profile_completion   # Server-side profile score calculator
        └── RPC check_feature_eligibility      # Server-side JIT access gatekeeper
```

---

## 17. Automated Unit & Security Test Suite (`test/unit/`)

Automated tests guaranteeing 100% test pass rate and architectural integrity:

```
test/unit/
├── catalog_test.dart                          # 5 Tests: Taxonomy categories and SKU filtering
├── chat_review_test.dart                      # 4 Tests: Realtime chat serialization & review model
├── matching_scoring_test.dart                 # 12 Tests: 4-Factor candidate ranking mathematical formula
├── notification_service_test.dart             # 6 Tests: Sound channels and permission sheet rendering
├── phase_module_test.dart                     # 4 Tests: Clean Architecture modular repository tests
├── responsive_layout_test.dart                # 18 Tests: Zero-overflow UI tests on 320dp small screens
├── security_hardening_test.dart               # 15 Tests: Escrow protection, anti-tampering, 4-digit OTP
└── user_lifecycle_offline_test.dart           # 13 Tests: Profile completion, feature gate, offline sync, dedup
```

---

## 18. Technical Documentation Suite (`docs/`)

Engineering blueprints, security specifications, and operational manuals:

```
docs/
├── ADMIN_ROADMAP.md                           # Blueprint and deferred roadmap for future Admin Panel UI
├── API_AND_INTEGRATION_GUIDE.md               # Supabase REST/WebSocket APIs, bKash/Nagad MFS specs
├── ARCHITECTURE.md                            # Comprehensive Clean Architecture blueprint & diagrams
├── DATABASE_SCHEMA.md                         # Full PostgreSQL 15 ER schema, 38 tables, RLS, and RPCs
├── FEATURE_TRACEABILITY_MATRIX.md             # End-to-end SRS traceability & REA comparative matrix
├── PRODUCT_SPECIFICATION.md                   # Operational workflows, algorithms & specs
├── PROJECT_FILE_DIRECTORY.md                  # This master directory navigation guide
├── ROUTING_AND_NAVIGATION.md                  # Navigation topology & RBAC interceptors
└── SECURITY_AND_TESTING.md                    # OWASP MASVS compliance & 77/77 test report
```

