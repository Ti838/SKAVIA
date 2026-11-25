# PostgreSQL Database Schema & Table Reference

> **Master Reference:** See [docs/DATA_DESIGN.md](../DATA_DESIGN.md) for the complete End-to-End Entity-Relationship Diagram, User vs. Admin access boundaries, and all 54 tables.

## Structured SQL Modules (`supabase/schema/`)

All database definitions are organized cleanly by domain instead of fragmented migration files:

1. `supabase/schema/01_identity_and_rbac.sql` — `users`, `roles`, `user_roles`, `user_addresses`, `user_sessions`, `verifications`
2. `supabase/schema/02_admin_governance.sql` — `permissions`, `role_permissions`, `user_permission_overrides`, `admin_profiles`, `admin_invitations`, `admin_passkeys`, `webauthn_challenges`, `admin_login_events`, `audit_logs`, `security_incidents`, `system_settings`, `backup_verification_logs`
3. `supabase/schema/03_catalog_and_branches.sql` — `branches`, `categories`, `services`, `skills`, `admin_branch_assignments`
4. `supabase/schema/04_marketplace_and_operations.sql` — `customer_profiles`, `worker_profiles`, `worker_skills`, `portfolio_items`, `certificates`, `availability_slots`, `requirements`, `requirement_skills`, `match_results`, `service_requests`, `projects`, `teams`, `team_members`, `tasks`
5. `supabase/schema/05_finance_and_escrow.sql` — `payments`, `invoices`, `transactions`, `worker_earnings`, `maker_checker_approvals`, `payout_requests`, `commission_rules`, `reconciliation_runs`
6. `supabase/schema/06_engagement_and_sync.sql` — `reviews`, `reputations`, `complaints`, `disputes`, `dispute_notes`, `refund_requests`, `conversations`, `messages`, `notifications`, `user_notifications`, `offline_sync_queue`
7. `supabase/schema/07_releases_and_ota.sql` — `app_releases`, `app_release_events`, `app-releases` private storage bucket
8. `supabase/schema/08_rls_functions_and_indexes.sql` — Row-Level Security (RLS) policies, `prevent_audit_log_mutation` trigger, and performance B-Tree indexes.
