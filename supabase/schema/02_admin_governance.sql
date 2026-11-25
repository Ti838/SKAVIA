-- ==============================================================================
-- PART 02: ADMIN GOVERNANCE, RBAC, PASSKEYS & SECURITY AUDIT
-- Domain: Enterprise Admin Portal Access Control, FIDO2 & Immutable Audit
-- Consumers: Admin Web Portal ONLY (Strictly isolated via RLS)
-- ==============================================================================

-- 2.1 PERMISSIONS & ROLE_PERMISSIONS
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

-- 2.2 ADMIN PROFILES & BRANCH SCOPING
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

CREATE TABLE IF NOT EXISTS public.admin_invitations (
    invitation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    role_name VARCHAR(40) NOT NULL CHECK (role_name IN ('Company Admin', 'Branch Manager')),
    assigned_branch_ids UUID[] NOT NULL DEFAULT '{}',
    permission_profile JSONB NOT NULL DEFAULT '[]'::jsonb,
    note TEXT,
    token_hash TEXT NOT NULL UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'Draft' CHECK (
        status IN ('Draft', 'Invited', 'Delivered', 'Opened', 'SetupInProgress', 'PendingApproval', 'Active', 'Expired', 'Revoked', 'Suspended')
    ),
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'Pending' CHECK (
        delivery_status IN ('Pending', 'Sent', 'Delivered', 'DeliveryFailed', 'NotConfigured')
    ),
    delivery_error TEXT,
    require_approval BOOLEAN NOT NULL DEFAULT TRUE,
    invited_by TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE RESTRICT,
    approved_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    activated_user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    opened_at TIMESTAMPTZ,
    setup_started_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    activated_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (role_name <> 'Branch Manager' OR COALESCE(array_length(assigned_branch_ids, 1), 0) >= 1)
);

-- 2.3 WEBAUTHN / FIDO2 PASSKEYS & CHALLENGES
CREATE TABLE IF NOT EXISTS public.admin_passkeys (
    credential_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    friendly_name VARCHAR(120) NOT NULL,
    public_key TEXT NOT NULL,
    counter BIGINT NOT NULL DEFAULT 0,
    transports TEXT[] NOT NULL DEFAULT '{}',
    device_type VARCHAR(30) NOT NULL DEFAULT 'singleDevice',
    backed_up BOOLEAN NOT NULL DEFAULT FALSE,
    aaguid VARCHAR(64),
    last_used_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ,
    revoked_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.webauthn_challenges (
    challenge_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES public.users(user_id) ON DELETE CASCADE,
    invitation_id UUID REFERENCES public.admin_invitations(invitation_id) ON DELETE CASCADE,
    challenge TEXT NOT NULL,
    purpose VARCHAR(30) NOT NULL CHECK (purpose IN ('register', 'authenticate', 'step_up', 'invite_activate')),
    expires_at TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2.4 SECURITY TELEMETRY, IMMUTABLE AUDIT LOGS & SYSTEM SETTINGS
CREATE TABLE IF NOT EXISTS public.admin_login_events (
    login_event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    email VARCHAR(150),
    surface VARCHAR(30),
    outcome VARCHAR(30) NOT NULL CHECK (outcome IN ('Success', 'Blocked_NoAdminRole', 'Blocked_NoMFA', 'Blocked_Suspended', 'Failed')),
    mfa_method VARCHAR(50),
    ip_address VARCHAR(64),
    user_agent TEXT,
    failure_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.audit_logs (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id TEXT,
    details JSONB,
    ip_address VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.security_incidents (
    incident_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(200) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('Low', 'Medium', 'High', 'Critical')),
    status VARCHAR(30) NOT NULL DEFAULT 'Open' CHECK (status IN ('Open', 'Investigating', 'Contained', 'Resolved', 'Closed')),
    source VARCHAR(50) NOT NULL DEFAULT 'Manual',
    affected_user_id TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    branch_id UUID,
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
