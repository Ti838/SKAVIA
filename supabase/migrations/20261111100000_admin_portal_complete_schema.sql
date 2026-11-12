-- ==============================================================================
-- SKAVIA ADMIN WEB PORTAL — ADDITIVE MIGRATION (PHASES 0, 2, 5, 6, 7, 8)
-- Preserves all 38 existing tables and user-side Flutter workflows.
-- Idempotent & safe for staged rollout.
-- ==============================================================================

-- ==============================================================================
-- SECTION 0: HARDEN LEGACY SECURITY DEFINER RPCs & COMPLAINTS/DISPUTES RLS
-- ==============================================================================

-- 0.1 Harden calculate_profile_completion with explicit search_path & caller verification
-- Drop prior JSONB-returning signature from 20261110220000 before recreating cleanly
DROP FUNCTION IF EXISTS public.calculate_profile_completion(TEXT);
CREATE OR REPLACE FUNCTION public.calculate_profile_completion(p_user_id TEXT)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_score INTEGER := 0;
    v_user RECORD;
    v_addr_count INTEGER := 0;
    v_caller TEXT := auth.uid()::text;
BEGIN
    -- Allow service_role (NULL auth.uid() in RPC invoked with service_role) or owner only
    IF current_user <> 'postgres' AND current_user <> 'service_role' AND v_caller IS DISTINCT FROM p_user_id THEN
        RAISE EXCEPTION 'Unauthorized: cannot calculate profile completion for another user';
    END IF;

    SELECT * INTO v_user FROM public.users WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    IF v_user.full_name IS NOT NULL AND length(trim(v_user.full_name)) >= 2 THEN v_score := v_score + 15; END IF;
    IF v_user.phone IS NOT NULL AND length(trim(v_user.phone)) >= 8 THEN v_score := v_score + 20; END IF;
    IF v_user.avatar_url IS NOT NULL AND length(trim(v_user.avatar_url)) > 0 THEN v_score := v_score + 15; END IF;
    IF v_user.date_of_birth IS NOT NULL THEN v_score := v_score + 15; END IF;
    IF v_user.gender IS NOT NULL THEN v_score := v_score + 10; END IF;
    IF v_user.emergency_contact_phone IS NOT NULL AND length(trim(v_user.emergency_contact_phone)) >= 8 THEN v_score := v_score + 10; END IF;

    SELECT count(*) INTO v_addr_count FROM public.user_addresses WHERE user_id = p_user_id;
    IF v_addr_count > 0 THEN v_score := v_score + 15; END IF;

    IF v_score > 100 THEN v_score := 100; END IF;

    UPDATE public.users
    SET profile_completion_percentage = v_score,
        updated_at = NOW()
    WHERE user_id = p_user_id;

    RETURN v_score;
END;
$$;

REVOKE ALL ON FUNCTION public.calculate_profile_completion(TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.calculate_profile_completion(TEXT) TO authenticated, service_role;

-- 0.2 Harden check_feature_eligibility with explicit search_path & caller verification
CREATE OR REPLACE FUNCTION public.check_feature_eligibility(p_user_id TEXT, p_feature_name TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_user RECORD;
    v_addr_count INTEGER := 0;
    v_reasons TEXT[] := '{}';
    v_is_eligible BOOLEAN := TRUE;
    v_caller TEXT := auth.uid()::text;
BEGIN
    IF current_user <> 'postgres' AND current_user <> 'service_role' AND v_caller IS DISTINCT FROM p_user_id THEN
        RAISE EXCEPTION 'Unauthorized: cannot evaluate feature eligibility for another user';
    END IF;

    SELECT * INTO v_user FROM public.users WHERE user_id = p_user_id;
    IF NOT FOUND THEN
        RETURN jsonb_build_object('eligible', FALSE, 'reasons', jsonb_build_array('Account not found'));
    END IF;

    IF v_user.account_status <> 'active' THEN
        RETURN jsonb_build_object('eligible', FALSE, 'reasons', jsonb_build_array('Account is ' || v_user.account_status));
    END IF;

    SELECT count(*) INTO v_addr_count FROM public.user_addresses WHERE user_id = p_user_id;

    IF p_feature_name = 'book_service' THEN
        IF v_addr_count = 0 THEN
            v_is_eligible := FALSE;
            v_reasons := array_append(v_reasons, 'A saved delivery address is required before booking.');
        END IF;
        IF v_user.phone IS NULL OR length(trim(v_user.phone)) < 8 THEN
            v_is_eligible := FALSE;
            v_reasons := array_append(v_reasons, 'A verified phone number is required so specialists can reach you.');
        END IF;
    ELSIF p_feature_name = 'accept_job' THEN
        IF v_user.verification_status <> 'verified' THEN
            v_is_eligible := FALSE;
            v_reasons := array_append(v_reasons, 'National ID and police clearance verification are required before accepting jobs.');
        END IF;
    ELSIF p_feature_name = 'request_payout' THEN
        IF v_user.phone IS NULL OR length(trim(v_user.phone)) < 8 THEN
            v_is_eligible := FALSE;
            v_reasons := array_append(v_reasons, 'A verified payout mobile number is required for withdrawals.');
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'eligible', v_is_eligible,
        'feature', p_feature_name,
        'reasons', to_jsonb(v_reasons)
    );
END;
$$;

REVOKE ALL ON FUNCTION public.check_feature_eligibility(TEXT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.check_feature_eligibility(TEXT, TEXT) TO authenticated, service_role;

-- 0.3 Restore Complaints & Disputes RLS for participants (previously 0 policies blocked everyone except service_role)
DROP POLICY IF EXISTS "Complaints Owner Read" ON public.complaints;
CREATE POLICY "Complaints Owner Read" ON public.complaints
    FOR SELECT TO authenticated
    USING (
        filed_by = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM public.service_requests sr
            LEFT JOIN public.worker_profiles wp ON wp.worker_profile_id = sr.worker_profile_id
            WHERE sr.service_request_id = complaints.service_request_id
              AND (sr.client_id = auth.uid()::text OR wp.user_id = auth.uid()::text)
        )
    );

DROP POLICY IF EXISTS "Complaints Owner Insert" ON public.complaints;
CREATE POLICY "Complaints Owner Insert" ON public.complaints
    FOR INSERT TO authenticated
    WITH CHECK (filed_by = auth.uid()::text);

DROP POLICY IF EXISTS "Disputes Participant Read" ON public.disputes;
CREATE POLICY "Disputes Participant Read" ON public.disputes
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.complaints c
            WHERE c.complaint_id = disputes.complaint_id
              AND c.filed_by = auth.uid()::text
        )
        OR assigned_admin_id = auth.uid()::text
    );

-- ==============================================================================
-- SECTION 1: IAM, RBAC + ABAC & SESSION GOVERNANCE (PHASES 1, 2, 8)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.permissions (
    permission_key VARCHAR(100) PRIMARY KEY,
    domain VARCHAR(50) NOT NULL,
    risk_tier VARCHAR(20) NOT NULL CHECK (risk_tier IN ('Low', 'Medium', 'High', 'Critical')),
    requires_step_up BOOLEAN NOT NULL DEFAULT FALSE,
    requires_maker_checker BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.role_permissions (
    role_id UUID NOT NULL REFERENCES public.roles(role_id) ON DELETE CASCADE,
    permission_key VARCHAR(100) NOT NULL REFERENCES public.permissions(permission_key) ON DELETE CASCADE,
    branch_scoped BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (role_id, permission_key)
);

CREATE TABLE IF NOT EXISTS public.user_permission_overrides (
    override_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    permission_key VARCHAR(100) NOT NULL REFERENCES public.permissions(permission_key) ON DELETE CASCADE,
    effect VARCHAR(10) NOT NULL CHECK (effect IN ('ALLOW', 'DENY')),
    reason TEXT NOT NULL,
    granted_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (granted_by IS NULL OR granted_by <> user_id)
);

CREATE TABLE IF NOT EXISTS public.admin_branch_assignments (
    assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    branch_id UUID NOT NULL REFERENCES public.branches(branch_id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    assigned_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, branch_id)
);

CREATE TABLE IF NOT EXISTS public.admin_profiles (
    user_id TEXT PRIMARY KEY REFERENCES public.users(user_id) ON DELETE CASCADE,
    mfa_enforced BOOLEAN NOT NULL DEFAULT TRUE,
    passkey_enrolled BOOLEAN NOT NULL DEFAULT FALSE,
    permission_version INTEGER NOT NULL DEFAULT 1,
    last_step_up_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ,
    last_login_ip VARCHAR(64),
    suspended_reason TEXT,
    suspended_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    suspended_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.admin_login_events (
    login_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    email VARCHAR(150),
    outcome VARCHAR(30) NOT NULL CHECK (outcome IN ('Success', 'Blocked_NoAdminRole', 'Blocked_NoMFA', 'Blocked_Suspended', 'Failed')),
    mfa_method VARCHAR(50),
    ip_address VARCHAR(64),
    user_agent TEXT,
    failure_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Extend user_sessions cleanly for admin web session revocation, step-up TTL & identity columns
ALTER TABLE public.user_sessions
    ADD COLUMN IF NOT EXISTS session_id TEXT DEFAULT gen_random_uuid()::text,
    ADD COLUMN IF NOT EXISTS device_info TEXT,
    ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS app_scope VARCHAR(30) DEFAULT 'mobile_app',
    ADD COLUMN IF NOT EXISTS step_up_expires_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS revoked_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS revoked_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS permission_version_snapshot INTEGER DEFAULT 1;

UPDATE public.user_sessions SET session_id = id WHERE session_id IS NULL AND id IS NOT NULL;
DO $$
BEGIN
    ALTER TABLE public.user_sessions ALTER COLUMN device_id DROP NOT NULL;
EXCEPTION
    WHEN undefined_column THEN NULL;
END $$;
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_sessions_session_id ON public.user_sessions(session_id);

-- ==============================================================================
-- SECTION 2: OPERATIONS & BRANCH LINKAGE EXTENSIONS (PHASES 4, 5, 6)
-- ==============================================================================

ALTER TABLE public.service_requests
    ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS cancellation_reason TEXT,
    ADD COLUMN IF NOT EXISTS cancelled_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL;

ALTER TABLE public.complaints
    ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS assigned_to TEXT REFERENCES public.users(user_id) ON DELETE SET NULL;

ALTER TABLE public.payments
    ADD COLUMN IF NOT EXISTS branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS commission_percent_snapshot DECIMAL(5, 4) DEFAULT 0.1500;

CREATE TABLE IF NOT EXISTS public.dispute_notes (
    note_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES public.disputes(dispute_id) ON DELETE CASCADE,
    author_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    note_type VARCHAR(30) NOT NULL DEFAULT 'Internal' CHECK (note_type IN ('Internal', 'Decision', 'RefundRecommendation')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- SECTION 3: FINANCIAL GOVERNANCE & MAKER-CHECKER (PHASE 7)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.maker_checker_approvals (
    approval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action_type VARCHAR(60) NOT NULL CHECK (action_type IN ('PAYOUT_APPROVAL', 'REFUND_APPROVAL', 'COMMISSION_CHANGE', 'PRIVILEGE_ESCALATION', 'SYSTEM_CONFIG')),
    entity_type VARCHAR(50) NOT NULL,
    entity_id TEXT NOT NULL,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    payload JSONB NOT NULL,
    idempotency_key VARCHAR(120) UNIQUE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Executed', 'Expired', 'Failed')),
    maker_user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE RESTRICT,
    checker_user_id TEXT REFERENCES public.users(user_id) ON DELETE RESTRICT,
    maker_reason TEXT NOT NULL,
    checker_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    decided_at TIMESTAMPTZ,
    executed_at TIMESTAMPTZ,
    CHECK (checker_user_id IS NULL OR checker_user_id <> maker_user_id)
);

CREATE TABLE IF NOT EXISTS public.payout_requests (
    payout_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE RESTRICT,
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    channel VARCHAR(30) NOT NULL CHECK (channel IN ('bKash', 'Nagad', 'Bank')),
    destination_masked VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Requested' CHECK (status IN ('Requested', 'PendingApproval', 'Approved', 'Disbursed', 'Rejected', 'Failed')),
    approval_id UUID REFERENCES public.maker_checker_approvals(approval_id) ON DELETE SET NULL,
    gateway_payout_ref VARCHAR(120),
    idempotency_key VARCHAR(120) UNIQUE NOT NULL,
    requested_by TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ
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

CREATE TABLE IF NOT EXISTS public.commission_rules (
    rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(category_id) ON DELETE CASCADE,
    fee_percent DECIMAL(5, 4) NOT NULL CHECK (fee_percent >= 0.0000 AND fee_percent <= 0.5000),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    approved_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    approval_id UUID REFERENCES public.maker_checker_approvals(approval_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.reconciliation_runs (
    run_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_start TIMESTAMPTZ NOT NULL,
    period_end TIMESTAMPTZ NOT NULL,
    total_payments DECIMAL(14, 2) NOT NULL DEFAULT 0,
    total_worker_earnings DECIMAL(14, 2) NOT NULL DEFAULT 0,
    total_skavia_fee DECIMAL(14, 2) NOT NULL DEFAULT 0,
    total_refunds DECIMAL(14, 2) NOT NULL DEFAULT 0,
    total_payouts DECIMAL(14, 2) NOT NULL DEFAULT 0,
    variance_amount DECIMAL(14, 2) NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL CHECK (status IN ('Matched', 'VarianceDetected')),
    run_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- SECTION 4: SECURITY MONITORING, SETTINGS & AUDIT IMMUTABILITY (PHASE 8)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.security_incidents (
    incident_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    status VARCHAR(30) NOT NULL DEFAULT 'Open' CHECK (status IN ('Open', 'Investigating', 'Contained', 'Resolved', 'Closed')),
    source VARCHAR(50) NOT NULL DEFAULT 'Manual',
    affected_user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    assigned_to TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    summary TEXT NOT NULL,
    containment_actions JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.system_settings (
    setting_key VARCHAR(100) PRIMARY KEY,
    setting_value JSONB NOT NULL,
    description TEXT,
    updated_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.backup_verification_logs (
    verification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    environment VARCHAR(30) NOT NULL,
    restore_target VARCHAR(150) NOT NULL,
    rpo_minutes INTEGER,
    rto_minutes INTEGER,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Passed', 'Failed')),
    verified_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    notes TEXT,
    verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Append-only tamper protection for audit_logs
CREATE OR REPLACE FUNCTION public.prevent_audit_log_mutation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
    RAISE EXCEPTION 'Security Violation: public.audit_logs is strictly append-only; UPDATE and DELETE are prohibited.';
END;
$$;

DROP TRIGGER IF EXISTS trg_audit_logs_immutable ON public.audit_logs;
CREATE TRIGGER trg_audit_logs_immutable
    BEFORE UPDATE OR DELETE ON public.audit_logs
    FOR EACH ROW
    EXECUTE FUNCTION public.prevent_audit_log_mutation();

-- Strict RLS on all newly created admin tables (server-side service_role access only from Admin Portal API)
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_permission_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_branch_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_login_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispute_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maker_checker_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refund_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reconciliation_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.backup_verification_logs ENABLE ROW LEVEL SECURITY;

-- Worker can view and submit own payout requests; admins act via server service_role
DROP POLICY IF EXISTS "Payout Requests Worker Read" ON public.payout_requests;
CREATE POLICY "Payout Requests Worker Read" ON public.payout_requests
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.worker_profiles wp
            WHERE wp.worker_profile_id = payout_requests.worker_profile_id
              AND wp.user_id = auth.uid()::text
        )
    );

-- Admin performance indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_verifications_status_created ON public.verifications(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_status_created ON public.payments(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sr_branch_status ON public.service_requests(branch_id, status);
CREATE INDEX IF NOT EXISTS idx_complaints_branch_status ON public.complaints(branch_id, status);
CREATE INDEX IF NOT EXISTS idx_admin_branches_user ON public.admin_branch_assignments(user_id, branch_id);
CREATE INDEX IF NOT EXISTS idx_approvals_status_created ON public.maker_checker_approvals(status, created_at DESC);

-- ==============================================================================
-- SECTION 5: ATOMIC ADMIN STORED PROCEDURES (SERVICE ROLE ONLY)
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.admin_review_verification(
    p_verification_id UUID,
    p_admin_user_id TEXT,
    p_decision VARCHAR(30),
    p_review_notes TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
    v_row RECORD;
    v_worker_user_id TEXT;
BEGIN
    IF p_decision NOT IN ('Approved', 'Rejected') THEN
        RAISE EXCEPTION 'Invalid verification decision: %', p_decision;
    END IF;

    SELECT v.*, wp.user_id AS worker_uid
    INTO v_row
    FROM public.verifications v
    JOIN public.worker_profiles wp ON wp.worker_profile_id = v.worker_profile_id
    WHERE v.verification_id = p_verification_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Verification record not found';
    END IF;

    v_worker_user_id := v_row.worker_uid;
    IF v_worker_user_id = p_admin_user_id THEN
        RAISE EXCEPTION 'Separation of Duties violation: admin cannot verify own worker profile';
    END IF;

    UPDATE public.verifications
    SET status = p_decision,
        reviewed_by = p_admin_user_id,
        review_notes = p_review_notes,
        reviewed_at = NOW()
    WHERE verification_id = p_verification_id;

    UPDATE public.worker_profiles
    SET verification_status = CASE WHEN p_decision = 'Approved' THEN 'Verified' ELSE 'Rejected' END,
        updated_at = NOW()
    WHERE worker_profile_id = v_row.worker_profile_id;

    UPDATE public.users
    SET verification_status = CASE WHEN p_decision = 'Approved' THEN 'verified' ELSE 'rejected' END,
        updated_at = NOW()
    WHERE user_id = v_worker_user_id;

    RETURN jsonb_build_object(
        'verification_id', p_verification_id,
        'worker_profile_id', v_row.worker_profile_id,
        'decision', p_decision
    );
END;
$$;

REVOKE ALL ON FUNCTION public.admin_review_verification(UUID, TEXT, VARCHAR, TEXT) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.admin_review_verification(UUID, TEXT, VARCHAR, TEXT) TO service_role;

-- ==============================================================================
-- SECTION 6: SEED PERMISSION CATALOG & ROLE MAPPINGS
-- ==============================================================================

INSERT INTO public.permissions (permission_key, domain, risk_tier, requires_step_up, requires_maker_checker, description) VALUES
    ('analytics.global.view', 'Dashboard', 'Medium', FALSE, FALSE, 'View company-wide executive KPIs across all branches'),
    ('branch.analytics.view', 'Dashboard', 'Low', FALSE, FALSE, 'View operational metrics per authorized branch'),
    ('branch.view', 'Branch', 'Low', FALSE, FALSE, 'View internal SKAVIA branches'),
    ('branch.manage', 'Branch', 'High', TRUE, TRUE, 'Create, edit, or deactivate internal SKAVIA branches'),
    ('branch.staff.assign', 'Branch', 'High', TRUE, FALSE, 'Assign Branch Managers to internal branches'),
    ('customer.view', 'Customer', 'Medium', FALSE, FALSE, 'View customer, business client, and organization accounts'),
    ('customer.update', 'Customer', 'Medium', FALSE, FALSE, 'Update authorized customer support attributes'),
    ('customer.suspend', 'Customer', 'High', TRUE, FALSE, 'Suspend or reactivate customer accounts'),
    ('worker.view', 'Worker', 'Low', FALSE, FALSE, 'View worker profiles, ratings, and skills'),
    ('worker.verify', 'Worker', 'High', FALSE, FALSE, 'Inspect private KYC docs and approve/reject worker credentials'),
    ('worker.suspend', 'Worker', 'High', TRUE, FALSE, 'Suspend or reactivate specialist accounts'),
    ('worker.branch.assign', 'Worker', 'Medium', FALSE, FALSE, 'Assign or transfer a worker across SKAVIA branches'),
    ('worker.availability.view', 'Worker', 'Low', FALSE, FALSE, 'View specialist availability schedules'),
    ('service.view', 'Service', 'Low', FALSE, FALSE, 'View service categories, packages, and skills'),
    ('service.manage', 'Service', 'Medium', FALSE, FALSE, 'Manage global service taxonomy'),
    ('service.branch.manage', 'Service', 'Medium', FALSE, FALSE, 'Toggle/manage branch-approved service operations'),
    ('pricing.manage', 'Finance', 'High', TRUE, FALSE, 'Modify base service prices'),
    ('commission.manage', 'Finance', 'Critical', TRUE, TRUE, 'Modify platform commission rules'),
    ('booking.view', 'Operations', 'Low', FALSE, FALSE, 'View requirements, bookings, and turnkey projects'),
    ('booking.manage', 'Operations', 'High', FALSE, FALSE, 'Assign workers, reschedule, or cancel bookings'),
    ('project.team.manage', 'Operations', 'Medium', FALSE, FALSE, 'Assemble teams, team members, and tasks for turnkey projects'),
    ('complaint.view', 'Disputes', 'Medium', FALSE, FALSE, 'View filed complaints'),
    ('complaint.manage', 'Disputes', 'Medium', FALSE, FALSE, 'Triage, assign, and close complaints'),
    ('dispute.view', 'Disputes', 'Medium', FALSE, FALSE, 'View escalated disputes and evidence'),
    ('dispute.resolve', 'Disputes', 'High', TRUE, FALSE, 'Record mediation decision and recommend settlement'),
    ('payment.view', 'Finance', 'High', FALSE, FALSE, 'View payments, gateway transactions, and invoices'),
    ('payment.refund.request', 'Finance', 'High', TRUE, TRUE, 'Create refund request (Maker)'),
    ('payment.refund.approve', 'Finance', 'Critical', TRUE, TRUE, 'Approve refund request (Checker != Maker)'),
    ('payout.view', 'Finance', 'High', FALSE, FALSE, 'View worker earnings and withdrawal queue'),
    ('payout.request', 'Finance', 'High', TRUE, TRUE, 'Submit or review worker payout request (Maker)'),
    ('payout.approve', 'Finance', 'Critical', TRUE, TRUE, 'Approve worker payout disbursement (Checker != Maker)'),
    ('report.view', 'Reports', 'Medium', FALSE, FALSE, 'View operational and financial reports'),
    ('admin.view', 'IAM', 'Medium', FALSE, FALSE, 'View internal administrator accounts and roles'),
    ('admin.create', 'IAM', 'Critical', TRUE, FALSE, 'Provision internal SKAVIA administrator accounts'),
    ('admin.suspend', 'IAM', 'Critical', TRUE, FALSE, 'Suspend or reactivate admin accounts'),
    ('admin.permission.update', 'IAM', 'Critical', TRUE, FALSE, 'Manage admin role assignments and individual overrides'),
    ('security.audit.view', 'Security', 'High', TRUE, FALSE, 'Inspect immutable audit logs and access trails'),
    ('security.incident.manage', 'Security', 'Critical', TRUE, FALSE, 'Triage and contain security incidents'),
    ('security.session.revoke', 'Security', 'Critical', TRUE, FALSE, 'Force-revoke active admin or user sessions'),
    ('system.settings.manage', 'Security', 'Critical', TRUE, TRUE, 'Modify global system and security configuration'),
    ('system.backup.view', 'Security', 'High', FALSE, FALSE, 'Inspect backup and recovery verification drills')
ON CONFLICT (permission_key) DO NOTHING;

-- Ensure core admin roles exist before mapping permissions
INSERT INTO public.roles (role_id, role_name, description) VALUES
    ('00000000-0000-4000-8000-000000000001', 'Super Admin', 'Full system and platform governance'),
    ('00000000-0000-4000-8000-000000000002', 'Company Admin', 'Platform operations, payments & user dispute oversight'),
    ('00000000-0000-4000-8000-000000000003', 'Branch Manager', 'Oversees a specialization branch, workers, and verifications')
ON CONFLICT (role_id) DO NOTHING;

-- Map permissions to seeded roles: Super Admin (0001), Company Admin (0002), Branch Manager (0003)
INSERT INTO public.role_permissions (role_id, permission_key, branch_scoped)
SELECT '00000000-0000-4000-8000-000000000001'::uuid, permission_key, FALSE
FROM public.permissions
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_key, branch_scoped)
SELECT '00000000-0000-4000-8000-000000000002'::uuid, permission_key, FALSE
FROM public.permissions
WHERE permission_key IN (
    'analytics.global.view', 'branch.analytics.view', 'branch.view',
    'customer.view', 'customer.update', 'customer.suspend',
    'worker.view', 'worker.verify', 'worker.suspend', 'worker.branch.assign', 'worker.availability.view',
    'service.view', 'service.manage', 'service.branch.manage',
    'booking.view', 'booking.manage', 'project.team.manage',
    'complaint.view', 'complaint.manage', 'dispute.view', 'dispute.resolve',
    'payment.view', 'payment.refund.request', 'payout.view', 'payout.request',
    'report.view'
)
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_key, branch_scoped)
SELECT '00000000-0000-4000-8000-000000000003'::uuid, permission_key, TRUE
FROM public.permissions
WHERE permission_key IN (
    'branch.analytics.view', 'branch.view',
    'customer.view',
    'worker.view', 'worker.verify', 'worker.suspend', 'worker.availability.view',
    'service.view', 'service.branch.manage',
    'booking.view', 'booking.manage', 'project.team.manage',
    'complaint.view', 'complaint.manage', 'dispute.view',
    'report.view'
)
ON CONFLICT DO NOTHING;

