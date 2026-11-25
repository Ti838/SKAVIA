-- ==============================================================================
-- PART 01: IDENTITY, ROLES, SESSIONS & NID VERIFICATIONS
-- Domain: Core Authentication, Multi-Role Access, Addresses & KYC
-- Consumers: Flutter Mobile App + Admin Web Portal
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1.1 USERS (Mapped to Firebase Auth UID)
CREATE TABLE IF NOT EXISTS public.users (
    user_id TEXT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30) UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'Active',
    avatar_url TEXT,
    cover_url TEXT,
    active_mode VARCHAR(20) NOT NULL DEFAULT 'client',
    location VARCHAR(150) DEFAULT 'Dhaka, Bangladesh',
    date_of_birth DATE,
    birthday_notifications_enabled BOOLEAN DEFAULT TRUE,
    gender TEXT DEFAULT 'unspecified',
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    preferred_language TEXT DEFAULT 'en',
    timezone TEXT DEFAULT 'Asia/Dhaka',
    account_status TEXT DEFAULT 'active',
    verification_status TEXT DEFAULT 'unverified',
    privacy_settings JSONB DEFAULT '{"profile_visibility": "public", "share_phone_with_assigned_specialist": true, "data_sharing_consent": true}'::jsonb,
    notification_preferences JSONB DEFAULT '{"push_enabled": true, "sms_enabled": true, "email_enabled": true, "urgent_alerts": true, "birthday_reminders": true, "promotional": false}'::jsonb,
    profile_completion_percentage INTEGER DEFAULT 30,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.2 ROLES
CREATE TABLE IF NOT EXISTS public.roles (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.3 USER_ROLES (Many-to-Many Bridge)
CREATE TABLE IF NOT EXISTS public.user_roles (
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES public.roles(role_id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

-- 1.4 USER_ADDRESSES (Saved Multi-Location Delivery & Dispatch Addresses)
CREATE TABLE IF NOT EXISTS public.user_addresses (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    label TEXT NOT NULL DEFAULT 'Home',
    recipient_name TEXT,
    recipient_phone TEXT,
    address_line TEXT NOT NULL,
    zone TEXT NOT NULL DEFAULT 'Dhaka North',
    city TEXT NOT NULL DEFAULT 'Dhaka',
    postal_code TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.5 USER_SESSIONS (Mobile Devices, Admin Web Step-Up & Pending Phone OTP Challenges)
CREATE TABLE IF NOT EXISTS public.user_sessions (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    session_id TEXT DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL, -- Auth UID or 'otp_pending:<e164_phone>' for pre-auth OTP challenges
    device_id TEXT,
    device_name TEXT,
    device_os TEXT,
    device_info TEXT,
    app_version TEXT,
    app_scope VARCHAR(30) DEFAULT 'mobile_app',
    ip_address TEXT,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    step_up_expires_at TIMESTAMPTZ,
    is_revoked BOOLEAN DEFAULT FALSE,
    revoked_at TIMESTAMPTZ,
    revoked_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    permission_version_snapshot INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 1.6 VERIFICATIONS (NID, Trade License & Police Clearance KYC Queue)
CREATE TABLE IF NOT EXISTS public.verifications (
    verification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL, -- FK added cleanly after worker_profiles in Part 04
    document_type VARCHAR(50) NOT NULL,
    document_number VARCHAR(100) NOT NULL,
    document_file_url TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    reviewed_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    review_notes TEXT,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
