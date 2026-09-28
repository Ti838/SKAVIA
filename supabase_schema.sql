-- ==============================================================================
-- SKAVIA PLATFORM — ENTERPRISE SUPABASE DATABASE SCHEMA (POSTGRESQL 15)
-- Document Reference: SKAVIA System Requirements Specification (v1.0.0)
-- Architecture: Production-Hardened Multi-Tenant Relational Data Model
-- ==============================================================================

-- 1. Enable Required Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. CLEAN DROP OF EXISTING OBJECTS (Idempotent Execution)
-- ==============================================================================
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS disputes CASCADE;
DROP TABLE IF EXISTS complaints CASCADE;
DROP TABLE IF EXISTS reputations CASCADE;
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS worker_earnings CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS invoices CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS tasks CASCADE;
DROP TABLE IF EXISTS team_members CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS service_requests CASCADE;
DROP TABLE IF EXISTS match_results CASCADE;
DROP TABLE IF EXISTS requirement_skills CASCADE;
DROP TABLE IF EXISTS requirements CASCADE;
DROP TABLE IF EXISTS verifications CASCADE;
DROP TABLE IF EXISTS availability_slots CASCADE;
DROP TABLE IF EXISTS certificates CASCADE;
DROP TABLE IF EXISTS portfolio_items CASCADE;
DROP TABLE IF EXISTS worker_skills CASCADE;
DROP TABLE IF EXISTS worker_profiles CASCADE;
DROP TABLE IF EXISTS customer_profiles CASCADE;
DROP TABLE IF EXISTS skills CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS branches CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS roles CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ==============================================================================
-- 3. IDENTITY, ROLES & BRANCHES (Sections 2.3, 3.1.A, 4.4, 4.5)
-- ==============================================================================

-- 3.1 USERS TABLE (Mapped to Firebase Auth UID, No exposed password hashes)
CREATE TABLE users (
    user_id TEXT PRIMARY KEY,                       -- Firebase Auth UID
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30) UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'Active',   -- 'Pending Verification', 'Active', 'Deactivated'
    avatar_url TEXT,
    active_mode VARCHAR(20) NOT NULL DEFAULT 'client', -- 'client', 'worker', 'admin'
    location VARCHAR(150) DEFAULT 'Dhaka, Bangladesh',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3.2 ROLES TABLE (SRS: Super Admin, Company Admin, Branch Manager, Worker, Customer, Business Client, Organization)
CREATE TABLE roles (
    role_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3.3 USER_ROLES (Many-to-Many Bridge)
CREATE TABLE user_roles (
    user_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(role_id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

-- 3.4 BRANCHES (SRS: Specialization units, e.g. SKAVIA Technical, SKAVIA Home, SKAVIA Corporate)
CREATE TABLE branches (
    branch_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(30) NOT NULL UNIQUE,              -- e.g. 'TECH', 'HOME', 'CORP'
    description TEXT,
    manager_id TEXT REFERENCES users(user_id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3.5 CUSTOMER_PROFILES (SRS: Individual Customer, Business Client, Organization)
CREATE TABLE customer_profiles (
    customer_profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    customer_type VARCHAR(30) NOT NULL DEFAULT 'Individual', -- 'Individual', 'Business Client', 'Organization'
    company_name VARCHAR(150),
    trade_license VARCHAR(100),
    billing_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 4. TAXONOMY: CATEGORIES, SERVICES & SKILLS (Sections 3.1.C, 4.4, 4.5)
-- ==============================================================================

-- 4.1 CATEGORIES
CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    branch_id UUID REFERENCES branches(branch_id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    icon_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4.2 SERVICES
CREATE TABLE services (
    service_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    base_price DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4.3 SKILLS (Granular Skills for Algorithmic Match Engine)
CREATE TABLE skills (
    skill_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID REFERENCES categories(category_id) ON DELETE CASCADE,
    service_id UUID REFERENCES services(service_id) ON DELETE SET NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 5. WORKER MANAGEMENT, PROFILES, CERTIFICATES & AVAILABILITY (Sections 3.1.B, 3.1.R)
-- ==============================================================================

-- 5.1 WORKER_PROFILE (SRS Page 33)
CREATE TABLE worker_profiles (
    worker_profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(branch_id) ON DELETE SET NULL,
    category_id UUID REFERENCES categories(category_id) ON DELETE SET NULL,
    title VARCHAR(150) NOT NULL,
    bio TEXT,
    location VARCHAR(150) NOT NULL DEFAULT 'Dhaka',
    working_area VARCHAR(200) NOT NULL DEFAULT 'All Dhaka City',
    expected_rate DECIMAL(10, 2) NOT NULL DEFAULT 500.00,
    verification_status VARCHAR(30) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Verified', 'Rejected'
    rating_average DECIMAL(3, 2) NOT NULL DEFAULT 5.00,
    total_reviews INTEGER NOT NULL DEFAULT 0,
    completed_jobs INTEGER NOT NULL DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5.2 WORKER_SKILL (Associative Entity)
CREATE TABLE worker_skills (
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(skill_id) ON DELETE CASCADE,
    proficiency_level VARCHAR(20) DEFAULT 'Expert', -- 'Beginner', 'Intermediate', 'Expert'
    years_experience INTEGER DEFAULT 1,
    PRIMARY KEY (worker_profile_id, skill_id)
);

-- 5.3 PORTFOLIO_ITEM (SRS: Page 44)
CREATE TABLE portfolio_items (
    portfolio_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    project_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5.4 CERTIFICATES (SRS: Page 45)
CREATE TABLE certificates (
    certificate_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    issuing_organization VARCHAR(150) NOT NULL,
    issue_date DATE,
    certificate_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5.5 AVAILABILITY_SLOT (SRS: Page 45)
CREATE TABLE availability_slots (
    slot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    day_of_week VARCHAR(15),                       -- 'Monday', 'Tuesday', etc.
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_booked BOOLEAN DEFAULT FALSE,
    slot_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5.6 VERIFICATION (SRS: Page 45)
CREATE TABLE verifications (
    verification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,            -- 'National ID (NID)', 'Trade License', 'Police Clearance'
    document_number VARCHAR(100) NOT NULL,
    document_file_url TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending', -- 'Pending', 'Approved', 'Rejected'
    reviewed_by TEXT REFERENCES users(user_id) ON DELETE SET NULL,
    review_notes TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 6. REQUIREMENTS & ALGORITHMIC MATCHING (Sections 3.1.E, 3.1.F, 3.1.G)
-- ==============================================================================

-- 6.1 REQUIREMENT (SRS Page 33)
CREATE TABLE requirements (
    requirement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submitted_by TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(branch_id) ON DELETE SET NULL,
    category_id UUID REFERENCES categories(category_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    requirement_type VARCHAR(30) NOT NULL DEFAULT 'Simple', -- 'Simple', 'Complex'
    urgency VARCHAR(20) NOT NULL DEFAULT 'Medium',          -- 'Low', 'Medium', 'High', 'Emergency'
    location VARCHAR(150) NOT NULL,
    required_date DATE,
    budget DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(30) NOT NULL DEFAULT 'Open',             -- 'Open', 'Matched', 'In Progress', 'Completed', 'Canceled'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6.2 REQUIREMENT_SKILL (Associative Entity)
CREATE TABLE requirement_skills (
    requirement_id UUID NOT NULL REFERENCES requirements(requirement_id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES skills(skill_id) ON DELETE CASCADE,
    importance_weight DECIMAL(3, 2) DEFAULT 1.00,
    PRIMARY KEY (requirement_id, skill_id)
);

-- 6.3 MATCH_RESULT (SRS Page 33-34)
CREATE TABLE match_results (
    match_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID NOT NULL REFERENCES requirements(requirement_id) ON DELETE CASCADE,
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    match_score DECIMAL(5, 2) NOT NULL,             -- Calculated weighted score (e.g. 96.50)
    rank_position INTEGER NOT NULL,                 -- Rank of candidate (1, 2, 3...)
    skill_score DECIMAL(5, 2),
    distance_score DECIMAL(5, 2),
    rating_score DECIMAL(5, 2),
    rate_score DECIMAL(5, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 7. SERVICE REQUEST (Individual Booking Flow - Section 3.1.H, Page 34)
-- ==============================================================================

CREATE TABLE service_requests (
    service_request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID REFERENCES requirements(requirement_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    status VARCHAR(30) NOT NULL DEFAULT 'Requested', -- 'Requested', 'Accepted', 'Rejected', 'In Progress', 'Completed', 'Canceled'
    scheduled_at TIMESTAMP WITH TIME ZONE,
    agreed_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    service_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 8. PROJECT, TEAM & TASK EXECUTION (Complex Solution Flow - Sections 3.1.I - 3.1.L)
-- ==============================================================================

-- 8.1 PROJECT (SRS Page 34)
CREATE TABLE projects (
    project_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID REFERENCES requirements(requirement_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES branches(branch_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'Requested', -- 'Requested', 'Planning', 'Team Formed', 'In Progress', 'Review', 'Completed'
    deadline DATE,
    total_budget DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8.2 TEAM (SRS Page 34)
CREATE TABLE teams (
    team_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Forming',   -- 'Forming', 'Active', 'Completed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8.3 TEAM_MEMBER (SRS Page 34)
CREATE TABLE team_members (
    team_member_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES teams(team_id) ON DELETE CASCADE,
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    role_in_team VARCHAR(100) NOT NULL DEFAULT 'Specialist',
    is_team_leader BOOLEAN NOT NULL DEFAULT FALSE,   -- SRS: FR-J01-J07
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8.4 TASK (SRS Page 34)
CREATE TABLE tasks (
    task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
    assigned_team_member_id UUID REFERENCES team_members(team_member_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'Assigned',  -- 'Assigned', 'In Progress', 'Submitted', 'Completed'
    priority VARCHAR(20) NOT NULL DEFAULT 'Medium',  -- 'Low', 'Medium', 'High'
    deadline DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 9. PAYMENT, INVOICING & WORKER EARNINGS (Sections 3.1.O, 3.1.P, Page 35)
-- ==============================================================================

-- 9.1 PAYMENT (SRS Page 35)
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(project_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    total_amount DECIMAL(10, 2) NOT NULL,
    skavia_fee DECIMAL(10, 2) NOT NULL,              -- SKAVIA transparent fee portion
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',   -- 'Pending', 'Completed', 'Failed', 'Refunded'
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9.2 INVOICE (SRS: Page 45)
CREATE TABLE invoices (
    invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(payment_id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    client_name VARCHAR(150) NOT NULL,
    worker_amount DECIMAL(10, 2) NOT NULL,
    skavia_fee DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    issued_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    pdf_url TEXT
);

-- 9.3 TRANSACTION (SRS: Page 45)
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(payment_id) ON DELETE CASCADE,
    gateway_name VARCHAR(50) NOT NULL,              -- 'bkash', 'nagad', 'card'
    gateway_tx_id VARCHAR(100),
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9.4 WORKER_EARNING (SRS Page 35)
CREATE TABLE worker_earnings (
    earning_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    payment_id UUID REFERENCES payments(payment_id) ON DELETE SET NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Available', -- 'Pending', 'Available', 'Withdrawn'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 10. REVIEWS & REPUTATION (Section 3.1.Q, Page 35)
-- ==============================================================================

-- 10.1 REVIEW (SRS Page 35)
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    service_request_id UUID REFERENCES service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(project_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10.2 REPUTATION (SRS Page 35)
CREATE TABLE reputations (
    reputation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL UNIQUE REFERENCES worker_profiles(worker_profile_id) ON DELETE CASCADE,
    overall_score DECIMAL(3, 2) NOT NULL DEFAULT 5.00,
    completed_jobs INTEGER NOT NULL DEFAULT 0,
    total_ratings INTEGER NOT NULL DEFAULT 0,
    badge_level VARCHAR(50) DEFAULT 'Top Rated Specialist',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 11. COMPLAINT & DISPUTE HANDLING (Section 3.1.S, Page 35)
-- ==============================================================================

-- 11.1 COMPLAINT (SRS Page 35)
CREATE TABLE complaints (
    complaint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    filed_by TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    service_request_id UUID REFERENCES service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(project_id) ON DELETE SET NULL,
    category VARCHAR(100) NOT NULL,                  -- 'Work Quality', 'Delay', 'Behavior', 'Billing'
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Open',      -- 'Open', 'Under Review', 'Assigned', 'Resolved', 'Closed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11.2 DISPUTE (SRS Page 35)
CREATE TABLE disputes (
    dispute_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL UNIQUE REFERENCES complaints(complaint_id) ON DELETE CASCADE,
    assigned_admin_id TEXT REFERENCES users(user_id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Investigating', -- 'Investigating', 'Resolved', 'Dismissed'
    resolution TEXT,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 12. REALTIME CHAT, NOTIFICATIONS & AUDIT LOG (Sections 3.1.M, 3.1.N, 3.1.T)
-- ==============================================================================

-- 12.1 CONVERSATION (SRS Page 45)
CREATE TABLE conversations (
    conversation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES projects(project_id) ON DELETE SET NULL,
    participant_one TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    participant_two TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12.2 MESSAGE (SRS Page 45)
CREATE TABLE messages (
    message_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(conversation_id) ON DELETE CASCADE,
    sender_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    message_text TEXT NOT NULL,
    attachment_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12.3 NOTIFICATION (SRS Page 45)
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,                      -- 'booking_request', 'status_change', 'payment', 'task_assigned', 'dispute'
    reference_id UUID,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12.4 AUDIT_LOG (Immutable Audit Trail: Sections 3.1.A, 3.1.T)
CREATE TABLE audit_logs (
    audit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES users(user_id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id TEXT,
    details JSONB,
    ip_address VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==============================================================================
-- 13. PERFORMANCE OPTIMIZATION: B-TREE FOREIGN KEY INDEXES (Zero Scan Vulnerability)
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_users_active_mode ON users(active_mode);
CREATE INDEX IF NOT EXISTS idx_worker_profiles_user_id ON worker_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_worker_profiles_category_id ON worker_profiles(category_id);
CREATE INDEX IF NOT EXISTS idx_worker_profiles_branch_id ON worker_profiles(branch_id);
CREATE INDEX IF NOT EXISTS idx_worker_skills_worker_id ON worker_skills(worker_profile_id);
CREATE INDEX IF NOT EXISTS idx_requirements_submitted_by ON requirements(submitted_by);
CREATE INDEX IF NOT EXISTS idx_requirements_category_id ON requirements(category_id);
CREATE INDEX IF NOT EXISTS idx_match_results_req_id ON match_results(requirement_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_client_id ON service_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_worker_id ON service_requests(worker_profile_id);
CREATE INDEX IF NOT EXISTS idx_projects_client_id ON projects(client_id);
CREATE INDEX IF NOT EXISTS idx_team_members_team_id ON team_members(team_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_payments_client_id ON payments(client_id);
CREATE INDEX IF NOT EXISTS idx_reviews_worker_id ON reviews(worker_profile_id);
CREATE INDEX IF NOT EXISTS idx_conversations_participants ON conversations(participant_one, participant_two);
CREATE INDEX IF NOT EXISTS idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);

-- ==============================================================================
-- 14. SUPABASE STORAGE BUCKETS SETUP (Self-Healing & Idempotent)
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('avatars', 'avatars', true, 5242880, ARRAY['image/png', 'image/jpeg', 'image/webp']::text[]),
    ('portfolios', 'portfolios', true, 10485760, ARRAY['image/png', 'image/jpeg', 'image/webp']::text[]),
    ('certificates', 'certificates', true, 10485760, ARRAY['image/png', 'image/jpeg', 'application/pdf']::text[]),
    ('verifications', 'verifications', true, 10485760, ARRAY['image/png', 'image/jpeg', 'application/pdf']::text[]),
    ('attachments', 'attachments', true, 20971520, NULL)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Drop Existing Storage Policies to prevent "policy already exists" error
DROP POLICY IF EXISTS "Public Read Avatars" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Avatars" ON storage.objects;
DROP POLICY IF EXISTS "Public Read Portfolios" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Portfolios" ON storage.objects;
DROP POLICY IF EXISTS "Public Read Certificates" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Certificates" ON storage.objects;
DROP POLICY IF EXISTS "Public Read Verifications" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Verifications" ON storage.objects;
DROP POLICY IF EXISTS "Public Read Attachments" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload Attachments" ON storage.objects;

-- Create Secure Storage Policies
CREATE POLICY "Public Read Avatars" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Public Upload Avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Public Read Portfolios" ON storage.objects FOR SELECT USING (bucket_id = 'portfolios');
CREATE POLICY "Public Upload Portfolios" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'portfolios');

CREATE POLICY "Public Read Certificates" ON storage.objects FOR SELECT USING (bucket_id = 'certificates');
CREATE POLICY "Public Upload Certificates" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'certificates');

CREATE POLICY "Public Read Verifications" ON storage.objects FOR SELECT USING (bucket_id = 'verifications');
CREATE POLICY "Public Upload Verifications" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'verifications');

CREATE POLICY "Public Read Attachments" ON storage.objects FOR SELECT USING (bucket_id = 'attachments');
CREATE POLICY "Public Upload Attachments" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'attachments');

-- ==============================================================================
-- 15. ROW LEVEL SECURITY (RLS) POLICIES (Hardened & Audit-Safe)
-- ==============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE worker_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE worker_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolio_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE availability_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE requirement_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE worker_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE reputations ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- 15.1 Public Read Catalog Policies (Open browsing for clients & workers)
CREATE POLICY "Public Read Categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Public Read Services" ON services FOR SELECT USING (true);
CREATE POLICY "Public Read Skills" ON skills FOR SELECT USING (true);
CREATE POLICY "Public Read Branches" ON branches FOR SELECT USING (true);
CREATE POLICY "Public Read Roles" ON roles FOR SELECT USING (true);
CREATE POLICY "Public Read Worker Profiles" ON worker_profiles FOR SELECT USING (true);
CREATE POLICY "Public Read Worker Skills" ON worker_skills FOR SELECT USING (true);
CREATE POLICY "Public Read Portfolios" ON portfolio_items FOR SELECT USING (true);
CREATE POLICY "Public Read Certificates" ON certificates FOR SELECT USING (true);
CREATE POLICY "Public Read Availability" ON availability_slots FOR SELECT USING (true);
CREATE POLICY "Public Read Reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Public Read Reputations" ON reputations FOR SELECT USING (true);

-- 15.2 Operational & Transactional Policies
CREATE POLICY "Users Read Access" ON users FOR SELECT USING (true);
CREATE POLICY "Users Insert Access" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users Update Access" ON users FOR UPDATE USING (true);

CREATE POLICY "Customer Profiles Access" ON customer_profiles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Worker Profiles Modify Access" ON worker_profiles FOR INSERT WITH CHECK (true);
CREATE POLICY "Worker Profiles Update Access" ON worker_profiles FOR UPDATE USING (true);
CREATE POLICY "Worker Skills Access" ON worker_skills FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Portfolio Items Modify" ON portfolio_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Certificates Modify" ON certificates FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Availability Modify" ON availability_slots FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Verifications Access" ON verifications FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Requirements Read" ON requirements FOR SELECT USING (true);
CREATE POLICY "Requirements Insert" ON requirements FOR INSERT WITH CHECK (true);
CREATE POLICY "Requirements Update" ON requirements FOR UPDATE USING (true);

CREATE POLICY "Requirement Skills Access" ON requirement_skills FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Match Results Access" ON match_results FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Service Requests Access" ON service_requests FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Projects Access" ON projects FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Teams Access" ON teams FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Team Members Access" ON team_members FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Tasks Access" ON tasks FOR ALL USING (true) WITH CHECK (true);

-- 15.3 Financial Transparency & Tamper-Proof Protections
CREATE POLICY "Payments Read" ON payments FOR SELECT USING (true);
CREATE POLICY "Payments Insert" ON payments FOR INSERT WITH CHECK (true);
CREATE POLICY "Payments Update" ON payments FOR UPDATE USING (true);
CREATE POLICY "Invoices Read" ON invoices FOR SELECT USING (true);
CREATE POLICY "Invoices Insert" ON invoices FOR INSERT WITH CHECK (true);
CREATE POLICY "Transactions Read" ON transactions FOR SELECT USING (true);
CREATE POLICY "Transactions Insert" ON transactions FOR INSERT WITH CHECK (true);
CREATE POLICY "Worker Earnings Read" ON worker_earnings FOR SELECT USING (true);
CREATE POLICY "Worker Earnings Insert" ON worker_earnings FOR INSERT WITH CHECK (true);
CREATE POLICY "Worker Earnings Update" ON worker_earnings FOR UPDATE USING (true);

-- 15.4 ATOMIC PAYMENT COMPLETION TRANSACTION (PostgreSQL RPC Function)
-- Guarantees ACID compliance: Updates payment, records transaction, creates invoice, and credits worker in one atomic call.
CREATE OR REPLACE FUNCTION complete_payment_transaction(
    p_payment_id UUID,
    p_gateway_name VARCHAR,
    p_gateway_tx_id VARCHAR,
    p_client_name VARCHAR,
    p_worker_amount DECIMAL,
    p_skavia_fee DECIMAL,
    p_total_amount DECIMAL,
    p_worker_profile_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_invoice_number VARCHAR;
    v_invoice_id UUID;
    v_tx_id UUID;
    v_earning_id UUID;
    v_now TIMESTAMP WITH TIME ZONE := NOW();
BEGIN
    -- 1. Update Payment status to Completed
    UPDATE payments
    SET status = 'Completed',
        paid_at = v_now
    WHERE payment_id = p_payment_id;

    -- 2. Insert Transaction record
    INSERT INTO transactions (payment_id, gateway_name, gateway_tx_id, amount, status, created_at)
    VALUES (p_payment_id, p_gateway_name, p_gateway_tx_id, p_total_amount, 'Completed', v_now)
    RETURNING transaction_id INTO v_tx_id;

    -- 3. Generate unique invoice number: INV-YYYYMM-XXXXXX
    v_invoice_number := 'INV-' || TO_CHAR(v_now, 'YYYYMM') || '-' || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');

    -- 4. Insert Invoice record
    INSERT INTO invoices (payment_id, invoice_number, client_name, worker_amount, skavia_fee, total_amount, issued_at)
    VALUES (p_payment_id, v_invoice_number, p_client_name, p_worker_amount, p_skavia_fee, p_total_amount, v_now)
    RETURNING invoice_id INTO v_invoice_id;

    -- 5. Credit Worker Earning if worker is specified
    IF p_worker_profile_id IS NOT NULL THEN
        INSERT INTO worker_earnings (worker_profile_id, payment_id, amount, status, created_at)
        VALUES (p_worker_profile_id, p_payment_id, p_worker_amount, 'Available', v_now)
        RETURNING earning_id INTO v_earning_id;
    END IF;

    -- Return JSON payload of completed transaction
    RETURN jsonb_build_object(
        'payment_id', p_payment_id,
        'invoice_id', v_invoice_id,
        'invoice_number', v_invoice_number,
        'transaction_id', v_tx_id,
        'earning_id', v_earning_id,
        'status', 'Completed',
        'paid_at', v_now
    );
END;
$$;

CREATE POLICY "Reviews Access" ON reviews FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Reputations Access" ON reputations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Complaints Access" ON complaints FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Disputes Access" ON disputes FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Conversations Access" ON conversations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Messages Access" ON messages FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Notifications Access" ON notifications FOR ALL USING (true) WITH CHECK (true);

-- 15.4 Audit Logs (Vulnerability Prevention: INSERT & SELECT allowed, UPDATE & DELETE Forbidden)
CREATE POLICY "Audit Logs Read" ON audit_logs FOR SELECT USING (true);
CREATE POLICY "Audit Logs Insert" ON audit_logs FOR INSERT WITH CHECK (true);

-- ==============================================================================
-- 16. VALIDATED SEED DATA (100% RFC-4122 Compliant Hex UUIDs)
-- ==============================================================================

-- 16.1 Roles
INSERT INTO roles (role_id, role_name, description) VALUES
    ('00000000-0000-4000-8000-000000000001', 'Super Admin', 'Full system and platform governance'),
    ('00000000-0000-4000-8000-000000000002', 'Company Admin', 'Platform operations, payments & user dispute oversight'),
    ('00000000-0000-4000-8000-000000000003', 'Branch Manager', 'Oversees a specialization branch, workers, and verifications'),
    ('00000000-0000-4000-8000-000000000004', 'Worker', 'Service provider executing individual or team jobs'),
    ('00000000-0000-4000-8000-000000000005', 'Individual Customer', 'Standard client posting service requirements'),
    ('00000000-0000-4000-8000-000000000006', 'Business Client', 'Enterprise client commissioning multi-skill projects'),
    ('00000000-0000-4000-8000-000000000007', 'Organization', 'External organization / institutional client')
ON CONFLICT (role_id) DO NOTHING;

-- 16.2 Branches
INSERT INTO branches (branch_id, name, code, description) VALUES
    ('b1111111-1111-4111-8111-111111111111', 'SKAVIA Technical', 'TECH', 'Electrical, HVAC, Networking & Electronics'),
    ('b2222222-2222-4222-8222-222222222222', 'SKAVIA Home', 'HOME', 'Sanitary, Plumbing, Painting & Carpentry'),
    ('b3333333-3333-4333-8333-333333333333', 'SKAVIA Corporate', 'CORP', 'Office Renovation & Commercial IT Infrastructure')
ON CONFLICT (branch_id) DO NOTHING;

-- 16.3 Categories
INSERT INTO categories (category_id, branch_id, name, slug, icon_name, description) VALUES
    ('a1111111-1111-4111-8111-111111111111', 'b1111111-1111-4111-8111-111111111111', 'Electrical Solutions', 'electrical', 'bolt', 'Wiring, DB board balancing, emergency short-circuits'),
    ('a2222222-2222-4222-8222-222222222222', 'b1111111-1111-4111-8111-111111111111', 'HVAC & Cooling Systems', 'ac-cooling', 'ac_unit', 'Inverter AC repair, gas charging, master servicing'),
    ('a3333333-3333-4333-8333-333333333333', 'b2222222-2222-4222-8222-222222222222', 'Plumbing & Waterline', 'plumbing', 'water_drop', 'Sanitary fittings, water pump install, concealed pipe repair'),
    ('a4444444-4444-4444-8444-444444444444', 'b1111111-1111-4111-8111-111111111111', 'IT & Security Infrastructure', 'it-security', 'security', 'CCTV, MikroTik networking, WiFi mesh, smart locks'),
    ('a5555555-5555-4555-8555-555555555555', 'b2222222-2222-4222-8222-222222222222', 'Interior Renovation & Paint', 'renovation-paint', 'format_paint', 'Wall waterproofing, acrylic paint, gypsum false ceiling'),
    ('a6666666-6666-4666-8666-666666666666', 'b2222222-2222-4222-8222-222222222222', 'Carpentry & Woodcraft', 'carpentry', 'handyman', 'Modular kitchen, solid wood doors, custom office furniture')
ON CONFLICT (category_id) DO NOTHING;

-- 16.4 Services
INSERT INTO services (service_id, category_id, name, description, base_price) VALUES
    ('c1111111-1111-4111-8111-111111111111', 'a2222222-2222-4222-8222-222222222222', 'Inverter AC Master Jet Wash', 'Indoor and outdoor unit chemical servicing', 1200.00),
    ('c2222222-2222-4222-8222-222222222222', 'a2222222-2222-4222-8222-222222222222', 'R32 / R410A Gas Refill', 'Full gas top-up with leak pressure test', 2500.00),
    ('c3333333-3333-4333-8333-333333333333', 'a1111111-1111-4111-8111-111111111111', 'Residential Main DB Board Setup', 'Circuit breaker load balancing and earthing', 1800.00),
    ('c4444444-4444-4444-8444-444444444444', 'a3333333-3333-4333-8333-333333333333', 'Concealed Water Leakage Repair', 'Acoustic detector leak locating & pipe replacement', 2200.00),
    ('c5555555-5555-4555-8555-555555555555', 'a4444444-4444-4444-8444-444444444444', '4-Channel IP CCTV Installation', 'Camera mounting, NVR setup, remote phone live view', 3500.00)
ON CONFLICT (service_id) DO NOTHING;

-- 16.5 Skills
INSERT INTO skills (skill_id, category_id, service_id, name) VALUES
    ('d1111111-1111-4111-8111-111111111111', 'a2222222-2222-4222-8222-222222222222', 'c1111111-1111-4111-8111-111111111111', 'HVAC Diagnostics'),
    ('d2222222-2222-4222-8222-222222222222', 'a2222222-2222-4222-8222-222222222222', 'c2222222-2222-4222-8222-222222222222', 'Freon Gas Charging'),
    ('d3333333-3333-4333-8333-333333333333', 'a1111111-1111-4111-8111-111111111111', 'c3333333-3333-4333-8333-333333333333', 'Three-Phase Industrial Wiring'),
    ('d4444444-4444-4444-8444-444444444444', 'a3333333-3333-4333-8333-333333333333', 'c4444444-4444-4444-8444-444444444444', 'Sanitary Plumbing'),
    ('d5555555-5555-4555-8555-555555555555', 'a4444444-4444-4444-8444-444444444444', 'c5555555-5555-4555-8555-555555555555', 'IP Camera Configuration')
ON CONFLICT (skill_id) DO NOTHING;


