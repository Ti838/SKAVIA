-- ==============================================================================
-- SKAVIA PLATFORM — ADDITIVE PERFORMANCE INDEX MIGRATION
-- Migration Name: 20261114000000_performance_indexes.sql
-- Purpose: Eliminate hot-path sequential scans across mobile & admin web queries.
-- Safety: Strictly additive (CREATE INDEX IF NOT EXISTS); zero schema or data loss.
-- ==============================================================================

-- 1. Notifications feed & badge sorting
CREATE INDEX IF NOT EXISTS idx_user_notifications_user_created
    ON public.user_notifications(user_id, created_at DESC);

-- 2. Device session revocation & listing
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_active
    ON public.user_sessions(user_id, last_active_at DESC);

-- 3. Customer payment history & gateway transaction batching
CREATE INDEX IF NOT EXISTS idx_payments_client_created
    ON public.payments(client_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_transactions_payment_id
    ON public.transactions(payment_id);

-- 4. Messaging timeline, conversation list & unread counter
CREATE INDEX IF NOT EXISTS idx_messages_conv_created
    ON public.messages(conversation_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_conv_unread
    ON public.messages(conversation_id, sender_id)
    WHERE is_read = FALSE;

CREATE INDEX IF NOT EXISTS idx_conversations_last_message
    ON public.conversations(last_message_at DESC);

-- 5. Live Job Feed open requirements & complaints timeline
CREATE INDEX IF NOT EXISTS idx_requirements_status_created
    ON public.requirements(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_complaints_filed_by_created
    ON public.complaints(filed_by, created_at DESC);

-- 6. Profile stats & dispatch lookup indexes
CREATE INDEX IF NOT EXISTS idx_service_requests_client
    ON public.service_requests(client_id);

CREATE INDEX IF NOT EXISTS idx_service_requests_worker
    ON public.service_requests(worker_profile_id);

CREATE INDEX IF NOT EXISTS idx_projects_client
    ON public.projects(client_id);

-- 7. Admin Portal governance queues & login audit feeds
CREATE INDEX IF NOT EXISTS idx_payout_requests_status_created
    ON public.payout_requests(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_refund_requests_status_created
    ON public.refund_requests(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_admin_login_events_created
    ON public.admin_login_events(created_at DESC);

