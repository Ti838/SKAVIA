-- ==============================================================================
-- PART 06: ENGAGEMENT, REVIEWS, DISPUTES, CHAT & OFFLINE SYNC
-- Domain: Messaging, Reviews, Complaints, Disputes, Notifications & Sync Queue
-- Consumers: Flutter Mobile App + Admin Web Portal
-- ==============================================================================

-- 6.1 REVIEWS & REPUTATION
CREATE TABLE IF NOT EXISTS public.reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    service_request_id UUID REFERENCES public.service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES public.projects(project_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.reputations (
    reputation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL UNIQUE REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    overall_score DECIMAL(3, 2) NOT NULL DEFAULT 5.00,
    completed_jobs INTEGER NOT NULL DEFAULT 0,
    total_ratings INTEGER NOT NULL DEFAULT 0,
    badge_level VARCHAR(50) DEFAULT 'Top Rated Specialist',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6.2 COMPLAINTS, DISPUTES & REFUNDS
CREATE TABLE IF NOT EXISTS public.complaints (
    complaint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filed_by TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    service_request_id UUID REFERENCES public.service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES public.projects(project_id) ON DELETE SET NULL,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    assigned_to TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Open',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.disputes (
    dispute_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL UNIQUE REFERENCES public.complaints(complaint_id) ON DELETE CASCADE,
    assigned_admin_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Investigating',
    resolution TEXT,
    resolved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.dispute_notes (
    note_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES public.disputes(dispute_id) ON DELETE CASCADE,
    author_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    note_type VARCHAR(30) NOT NULL DEFAULT 'Internal' CHECK (note_type IN ('Internal', 'Decision', 'RefundRecommendation')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.refund_requests (
    refund_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES public.payments(payment_id) ON DELETE RESTRICT,
    dispute_id UUID REFERENCES public.disputes(dispute_id) ON DELETE SET NULL,
    refund_amount DECIMAL(12, 2) NOT NULL CHECK (refund_amount > 0),
    reason TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Requested' CHECK (status IN ('Requested', 'Approved', 'Refunded', 'Rejected', 'Failed')),
    approval_id UUID REFERENCES public.maker_checker_approvals(approval_id) ON DELETE SET NULL,
    gateway_refund_id VARCHAR(120),
    idempotency_key VARCHAR(120) UNIQUE NOT NULL,
    requested_by TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    refunded_at TIMESTAMPTZ
);

-- 6.3 REALTIME CHAT
CREATE TABLE IF NOT EXISTS public.conversations (
    conversation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES public.projects(project_id) ON DELETE SET NULL,
    participant_one TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    participant_two TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(conversation_id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6.4 NOTIFICATIONS & OFFLINE SYNC QUEUE
CREATE TABLE IF NOT EXISTS public.notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    reference_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_notifications (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    dedup_key TEXT UNIQUE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    action_route TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.offline_sync_queue (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    idempotency_key TEXT NOT NULL UNIQUE,
    operation_type TEXT NOT NULL,
    payload JSONB NOT NULL,
    status TEXT DEFAULT 'pending',
    retry_count INTEGER DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);
