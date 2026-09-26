# SKAVIA — Production Architecture Documentation

**System:** SKAVIA Solution-Oriented Service & Workforce Platform  
**Target Platform:** Flutter (Android / iOS / Web)  
**Standard:** Feature-First Clean Architecture (Presentation → Domain → Data)  
**Document Classification:** Internal Technical Architecture Specification  
**Version:** 1.0.0 (Production Blueprint)  
**Status:** Approved Standard

---

## 1. Architectural Philosophy & Principles

The SKAVIA mobile application is organized using **Feature-First Domain-Driven Clean Architecture**. 

Every file has a single, testable responsibility. Rather than grouping all models or all screens in giant global folders, files are grouped strictly by **Feature and User Role**:

* **Presentation Layer:** Contains UI Screens, Custom Feature Widgets, and State Controllers (`ChangeNotifier`). It depends ONLY on the Domain layer and shared UI widgets.
* **Domain Layer:** Contains pure Dart entities, repository contracts, and algorithmic business logic (such as the rule-based matching engine). It has ZERO dependencies on external frameworks or databases.
* **Data Layer:** Implements repository contracts, defines JSON data transfer objects (models), and interfaces directly with Supabase via remote data sources.

---

## 2. Complete Directory & File Structure

```text
lib/
│
├── main.dart                                      # Minimal app entry point
│
├── app/                                           # App-level orchestration
│   ├── app.dart                                   # MaterialApp root configuration
│   ├── bootstrap.dart                             # Async service initialization
│   ├── router/
│   │   ├── app_routes.dart                        # Route name string constants
│   │   ├── app_router.dart                        # Central Route generator
│   │   └── route_guards.dart                      # Auth and role permissions verification
│   ├── theme/
│   │   ├── app_theme.dart                         # ThemeData configuration
│   │   ├── app_colors.dart                        # Color palette tokens
│   │   ├── app_typography.dart                    # Font & text style tokens
│   │   └── app_dimensions.dart                    # Padding, margin, and radius tokens
│   └── config/
│       ├── app_config.dart                        # Environment variables (Supabase URL, Keys)
│       └── app_constants.dart                     # Universal platform constants (Fees, SLA)
│
├── core/                                          # Core infrastructure & utilities
│   ├── constants/
│   │   ├── app_strings.dart                       # Global UI text and error strings
│   │   └── app_assets.dart                        # Asset paths (images, SVGs, icons)
│   ├── errors/
│   │   ├── app_exception.dart                     # Custom application exceptions
│   │   └── failure.dart                           # Domain-level failure representations
│   ├── network/
│   │   └── network_info.dart                      # Network connectivity checker
│   ├── storage/
│   │   └── secure_storage_service.dart            # Local token & session cache
│   ├── utils/
│   │   ├── formatters.dart                        # Currency and date/time formatters
│   │   ├── validators.dart                        # Form validation logic
│   │   └── ui_feedback_helper.dart                # Snackbars, toasts, and alert dialogs
│   └── extensions/
│       ├── context_extensions.dart                # BuildContext shortcuts
│       └── string_extensions.dart                 # String utilities
│
├── shared/                                        # Shared reusable UI components
│   ├── widgets/
│   │   ├── app_button.dart                        # Universal primary & secondary button
│   │   ├── app_text_field.dart                    # Standard input field
│   │   ├── app_card.dart                          # Standard surface card
│   │   ├── app_app_bar.dart                       # Global header bar
│   │   └── user_avatar.dart                       # Avatar with verified badge
│   ├── dialogs/
│   │   ├── confirmation_dialog.dart               # Generic confirmation dialog
│   │   └── error_dialog.dart                      # Error modal with retry
│   ├── loaders/
│   │   ├── app_loading_indicator.dart             # Branded loading spinner
│   │   └── list_shimmer_skeleton.dart             # Skeleton loader for feeds
│   ├── error_states/
│   │   └── error_view.dart                        # Full-screen error state with retry
│   └── empty_states/
│       └── empty_data_view.dart                   # Illustrated empty state
│
├── data/                                          # Global database infrastructure
│   ├── datasources/
│   │   ├── supabase_datasource.dart               # PostgREST query client
│   │   └── remote_storage_datasource.dart         # File and media storage client
│   ├── services/
│   │   └── logging_service.dart                   # Logging and audit service
│   └── tables/
│       └── database_tables.dart                   # Supabase table name constants
│
└── features/                                      # Feature modules by role & domain
    │
    ├── authentication/                            # Login, Register & Session
    │   ├── data/
    │   │   ├── datasources/auth_remote_datasource.dart
    │   │   ├── models/user_account_model.dart
    │   │   └── repositories/auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/user_entity.dart
    │   │   └── repositories/auth_repository.dart
    │   └── presentation/
    │       ├── controllers/auth_controller.dart
    │       └── screens/
    │           ├── splash_screen.dart
    │           ├── onboarding_screen.dart
    │           ├── login_screen.dart
    │           ├── register_screen.dart
    │           ├── otp_verification_screen.dart
    │           └── role_selection_screen.dart
    │
    ├── navigation/                                # Mode Switcher & Navigation Shell
    │   └── presentation/
    │       ├── controllers/navigation_mode_controller.dart
    │       ├── screens/main_scaffold_screen.dart
    │       └── widgets/
    │           ├── role_mode_switcher_button.dart
    │           └── role_bottom_nav_bar.dart
    │
    ├── customer/                                  # [ROLE 1] Customer / Client Workflows
    │   ├── data/
    │   │   ├── datasources/customer_remote_datasource.dart
    │   │   ├── models/requirement_model.dart
    │   │   ├── models/category_model.dart
    │   │   └── repositories/customer_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/requirement_entity.dart
    │   │   └── repositories/customer_repository.dart
    │   └── presentation/
    │       ├── controllers/
    │       │   ├── customer_dashboard_controller.dart
    │       │   └── post_requirement_controller.dart
    │       ├── screens/
    │       │   ├── customer_dashboard_screen.dart
    │       │   ├── category_catalog_screen.dart
    │       │   ├── post_requirement_screen.dart
    │       │   ├── candidate_matches_screen.dart
    │       │   ├── worker_public_profile_screen.dart
    │       │   ├── booking_confirmation_screen.dart
    │       │   └── booking_timeline_screen.dart
    │       └── widgets/
    │           ├── match_score_badge.dart
    │           └── requirement_type_selector.dart
    │
    ├── worker/                                    # [ROLE 2] Worker / Provider Workflows
    │   ├── data/
    │   │   ├── datasources/worker_remote_datasource.dart
    │   │   ├── models/worker_profile_model.dart
    │   │   ├── models/worker_earning_model.dart
    │   │   └── repositories/worker_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/worker_profile_entity.dart
    │   │   └── repositories/worker_repository.dart
    │   └── presentation/
    │       ├── controllers/
    │       │   ├── worker_dashboard_controller.dart
    │       │   └── worker_profile_controller.dart
    │       ├── screens/
    │       │   ├── worker_dashboard_screen.dart
    │       │   ├── incoming_requests_screen.dart
    │       │   ├── active_job_screen.dart
    │       │   ├── availability_calendar_screen.dart
    │       │   ├── portfolio_management_screen.dart
    │       │   ├── worker_earnings_screen.dart
    │       │   └── worker_edit_profile_screen.dart
    │       └── widgets/
    │           ├── incoming_request_card.dart
    │           └── earnings_metric_tile.dart
    │
    ├── matching/                                  # Rule-Based Matching Engine
    │   ├── domain/
    │   │   ├── entities/match_result_entity.dart
    │   │   └── services/matching_scoring_engine.dart
    │   └── presentation/
    │       └── controllers/matching_controller.dart
    │
    ├── team_project/                              # [ROLE 3] Team Leader & Complex Project
    │   ├── data/
    │   │   ├── datasources/project_remote_datasource.dart
    │   │   ├── models/project_model.dart
    │   │   ├── models/task_item_model.dart
    │   │   └── repositories/project_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/project_entity.dart
    │   │   └── repositories/project_repository.dart
    │   └── presentation/
    │       ├── controllers/project_controller.dart
    │       ├── screens/
    │       │   ├── project_dashboard_screen.dart
    │       │   ├── team_roster_screen.dart
    │       │   ├── task_board_screen.dart
    │       │   └── assign_task_screen.dart
    │       └── widgets/
    │           ├── team_progress_bar.dart
    │           └── team_member_tile.dart
    │
    ├── admin/                                     # [ROLE 4] Operations & Platform Governance
    │   ├── data/
    │   │   ├── datasources/admin_remote_datasource.dart
    │   │   └── repositories/admin_repository_impl.dart
    │   ├── domain/
    │   │   └── repositories/admin_repository.dart
    │   └── presentation/
    │       ├── controllers/admin_controller.dart
    │       └── screens/
    │           ├── admin_dashboard_screen.dart
    │           ├── team_assembly_screen.dart
    │           ├── verification_queue_screen.dart
    │           └── dispute_resolution_screen.dart
    │
    ├── billing/                                   # Financial Transparency & Checkout
    │   ├── data/
    │   │   ├── datasources/payment_remote_datasource.dart
    │   │   └── models/payment_transaction_model.dart
    │   └── presentation/
    │       ├── controllers/payment_controller.dart
    │       └── screens/
    │           ├── invoice_screen.dart
    │           ├── simulated_checkout_screen.dart
    │           └── payment_success_screen.dart
    │
    ├── reviews/                                   # Reputation & Quality Control
    │   ├── data/
    │   │   └── models/review_model.dart
    │   └── presentation/
    │       ├── controllers/review_controller.dart
    │       └── screens/
    │           ├── submit_review_screen.dart
    │           └── worker_reputation_screen.dart
    │
    └── chat/                                      # In-App Role-to-Role Communication
        ├── data/
        │   ├── datasources/chat_remote_datasource.dart
        │   └── models/chat_message_model.dart
        └── presentation/
            ├── controllers/chat_controller.dart
            └── screens/
                ├── chat_list_screen.dart
                └── chat_room_screen.dart
```

---

## 3. How to Add a New Feature

When adding a new feature in the future, follow this standard pattern:

1. **Domain:**
   * Create `domain/entities/<feature>_entity.dart`.
   * Create `domain/repositories/<feature>_repository.dart` declaring the contract interface.
2. **Data:**
   * Create `data/models/<feature>_model.dart` extending/mapping to the domain entity.
   * Create `data/datasources/<feature>_remote_datasource.dart` executing Supabase queries.
   * Create `data/repositories/<feature>_repository_impl.dart` implementing the domain repository.
3. **Presentation:**
   * Create `presentation/controllers/<feature>_controller.dart` extending `ChangeNotifier`.
   * Create UI screens in `presentation/screens/`.
   * Register the new route in `app/router/app_routes.dart` and `app/router/app_router.dart`.
