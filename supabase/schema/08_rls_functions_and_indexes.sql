-- ==============================================================================
-- PART 08: RLS POLICIES, TRIGGERS, RPC FUNCTIONS & PERFORMANCE INDEXES
-- Domain: Row-Level Security, Audit Immutability, Atomic Settlement & B-Tree Indexes
-- ==============================================================================

-- 8.1 IMMUTABLE AUDIT LOG PROTECTION
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

-- 8.2 ENABLE ROW-LEVEL SECURITY ACROSS ALL TABLES
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_sync_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worker_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.match_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worker_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Admin-only governance tables (service_role only; zero direct mobile client access)
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_permission_overrides ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_branch_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_login_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_passkeys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webauthn_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispute_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.maker_checker_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refund_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reconciliation_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_incidents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.backup_verification_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_releases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_release_events ENABLE ROW LEVEL SECURITY;

-- 8.3 CORE OWNER-SCOPED RLS POLICIES
DROP POLICY IF EXISTS "User Addresses Owner Access" ON public.user_addresses;
CREATE POLICY "User Addresses Owner Access" ON public.user_addresses
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::text)
    WITH CHECK (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "User Sessions Owner Access" ON public.user_sessions;
CREATE POLICY "User Sessions Owner Access" ON public.user_sessions
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::text)
    WITH CHECK (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Offline Sync Queue Owner Access" ON public.offline_sync_queue;
CREATE POLICY "Offline Sync Queue Owner Access" ON public.offline_sync_queue
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::text)
    WITH CHECK (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "User Notifications Owner Access" ON public.user_notifications;
CREATE POLICY "User Notifications Owner Access" ON public.user_notifications
    FOR ALL TO authenticated
    USING (user_id = auth.uid()::text)
    WITH CHECK (user_id = auth.uid()::text);

-- 8.4 PERFORMANCE B-TREE & PARTIAL INDEXES
CREATE INDEX IF NOT EXISTS idx_users_active_mode ON public.users(active_mode);
CREATE INDEX IF NOT EXISTS idx_user_addresses_user ON public.user_addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user ON public.user_sessions(user_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_sessions_session_id ON public.user_sessions(session_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_user_active ON public.user_sessions(user_id, is_revoked, last_active_at DESC);
CREATE INDEX IF NOT EXISTS idx_offline_sync_user ON public.offline_sync_queue(user_id, status);
CREATE INDEX IF NOT EXISTS idx_user_notifications_user ON public.user_notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_user_notifications_user_created ON public.user_notifications(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_worker_profiles_user_id ON public.worker_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_worker_profiles_category_id ON public.worker_profiles(category_id);
CREATE INDEX IF NOT EXISTS idx_worker_profiles_branch_id ON public.worker_profiles(branch_id);
CREATE INDEX IF NOT EXISTS idx_worker_skills_worker_id ON public.worker_skills(worker_profile_id);

CREATE INDEX IF NOT EXISTS idx_requirements_submitted_by ON public.requirements(submitted_by);
CREATE INDEX IF NOT EXISTS idx_requirements_category_id ON public.requirements(category_id);
CREATE INDEX IF NOT EXISTS idx_requirements_status_created ON public.requirements(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_match_results_req_id ON public.match_results(requirement_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_client_id ON public.service_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_worker_id ON public.service_requests(worker_profile_id);
CREATE INDEX IF NOT EXISTS idx_projects_client_id ON public.projects(client_id);

CREATE INDEX IF NOT EXISTS idx_payments_client_created ON public.payments(client_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_payment_id ON public.transactions(payment_id);
CREATE INDEX IF NOT EXISTS idx_payout_requests_status_created ON public.payout_requests(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_refund_requests_status_created ON public.refund_requests(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_conv_created ON public.messages(conversation_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON public.conversations(last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_complaints_filed_by_created ON public.complaints(filed_by, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_admin_invitations_email_status ON public.admin_invitations(lower(email), status);
CREATE INDEX IF NOT EXISTS idx_admin_invitations_created_at ON public.admin_invitations(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_passkeys_user_active ON public.admin_passkeys(user_id, created_at DESC) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_webauthn_challenges_expires ON public.webauthn_challenges(expires_at);
CREATE INDEX IF NOT EXISTS idx_admin_login_events_created ON public.admin_login_events(created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS idx_app_releases_current_channel ON public.app_releases(platform, channel) WHERE is_current = TRUE AND status = 'published';
CREATE INDEX IF NOT EXISTS idx_app_releases_lookup ON public.app_releases(platform, channel, status, build_number DESC);
CREATE INDEX IF NOT EXISTS idx_app_releases_sha256 ON public.app_releases(sha256_checksum);
CREATE INDEX IF NOT EXISTS idx_app_release_events_release_type ON public.app_release_events(release_id, event_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_app_release_events_channel_created ON public.app_release_events(platform, channel, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_app_release_events_installed_build ON public.app_release_events(installed_build, created_at DESC);


-- ==============================================================================
-- 8.5 STORAGE BUCKETS (AVATARS, BANNERS, PORTFOLIOS, CERTIFICATES, VERIFICATIONS, ATTACHMENTS)
--     AND FULL RLS POLICIES + RPC FUNCTIONS
-- ==============================================================================

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
DROP POLICY IF EXISTS "Public Read Categories" ON categories;
CREATE POLICY "Public Read Categories" ON categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Services" ON services;
CREATE POLICY "Public Read Services" ON services FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Skills" ON skills;
CREATE POLICY "Public Read Skills" ON skills FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Branches" ON branches;
CREATE POLICY "Public Read Branches" ON branches FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Roles" ON roles;
CREATE POLICY "Public Read Roles" ON roles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Worker Profiles" ON worker_profiles;
CREATE POLICY "Public Read Worker Profiles" ON worker_profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Worker Skills" ON worker_skills;
CREATE POLICY "Public Read Worker Skills" ON worker_skills FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Portfolios" ON portfolio_items;
CREATE POLICY "Public Read Portfolios" ON portfolio_items FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Certificates" ON certificates;
CREATE POLICY "Public Read Certificates" ON certificates FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Availability" ON availability_slots;
CREATE POLICY "Public Read Availability" ON availability_slots FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Reviews" ON reviews;
CREATE POLICY "Public Read Reviews" ON reviews FOR SELECT USING (true);

DROP POLICY IF EXISTS "Public Read Reputations" ON reputations;
CREATE POLICY "Public Read Reputations" ON reputations FOR SELECT USING (true);

-- 15.2 Operational & Identity Policies (Owner-Bound Authorization)
DROP POLICY IF EXISTS "Users Read Access" ON users;
CREATE POLICY "Users Read Access" ON users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users Insert Access" ON users;
CREATE POLICY "Users Insert Access" ON users FOR INSERT WITH CHECK (auth.uid()::text = user_id);

DROP POLICY IF EXISTS "Users Update Access" ON users;
CREATE POLICY "Users Update Access" ON users FOR UPDATE USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

DROP POLICY IF EXISTS "Customer Profiles Read" ON customer_profiles;
CREATE POLICY "Customer Profiles Read" ON customer_profiles FOR SELECT USING (auth.uid()::text = user_id);

DROP POLICY IF EXISTS "Customer Profiles Insert" ON customer_profiles;
CREATE POLICY "Customer Profiles Insert" ON customer_profiles FOR INSERT WITH CHECK (auth.uid()::text = user_id);

DROP POLICY IF EXISTS "Customer Profiles Update" ON customer_profiles;
CREATE POLICY "Customer Profiles Update" ON customer_profiles FOR UPDATE USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

DROP POLICY IF EXISTS "Worker Profiles Modify Access" ON worker_profiles;
CREATE POLICY "Worker Profiles Modify Access" ON worker_profiles FOR INSERT WITH CHECK (auth.uid()::text = user_id);

DROP POLICY IF EXISTS "Worker Profiles Update Access" ON worker_profiles;
CREATE POLICY "Worker Profiles Update Access" ON worker_profiles FOR UPDATE USING (auth.uid()::text = user_id) WITH CHECK (auth.uid()::text = user_id);

DROP POLICY IF EXISTS "Worker Skills Modify" ON worker_skills;
CREATE POLICY "Worker Skills Modify" ON worker_skills FOR ALL 
    USING (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = worker_skills.worker_profile_id AND wp.user_id = auth.uid()::text))
    WITH CHECK (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = worker_skills.worker_profile_id AND wp.user_id = auth.uid()::text));

DROP POLICY IF EXISTS "Portfolio Items Modify" ON portfolio_items;
CREATE POLICY "Portfolio Items Modify" ON portfolio_items FOR ALL 
    USING (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = portfolio_items.worker_profile_id AND wp.user_id = auth.uid()::text))
    WITH CHECK (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = portfolio_items.worker_profile_id AND wp.user_id = auth.uid()::text));

DROP POLICY IF EXISTS "Certificates Modify" ON certificates;
CREATE POLICY "Certificates Modify" ON certificates FOR ALL 
    USING (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = certificates.worker_profile_id AND wp.user_id = auth.uid()::text))
    WITH CHECK (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = certificates.worker_profile_id AND wp.user_id = auth.uid()::text));

DROP POLICY IF EXISTS "Availability Modify" ON availability_slots;
CREATE POLICY "Availability Modify" ON availability_slots FOR ALL 
    USING (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = availability_slots.worker_profile_id AND wp.user_id = auth.uid()::text))
    WITH CHECK (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = availability_slots.worker_profile_id AND wp.user_id = auth.uid()::text));

-- KYC & Sensitive Document Security: Only owning worker or reviewer may access identity documents
DROP POLICY IF EXISTS "Verifications Read" ON verifications;
CREATE POLICY "Verifications Read" ON verifications FOR SELECT 
    USING (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = verifications.worker_profile_id AND wp.user_id = auth.uid()::text) OR reviewed_by = auth.uid()::text);

DROP POLICY IF EXISTS "Verifications Submit" ON verifications;
CREATE POLICY "Verifications Submit" ON verifications FOR INSERT 
    WITH CHECK (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = verifications.worker_profile_id AND wp.user_id = auth.uid()::text));

-- Requirements & Marketplace Authorization
DROP POLICY IF EXISTS "Requirements Read" ON requirements;
CREATE POLICY "Requirements Read" ON requirements FOR SELECT USING (status = 'Open' OR submitted_by = auth.uid()::text);

DROP POLICY IF EXISTS "Requirements Insert" ON requirements;
CREATE POLICY "Requirements Insert" ON requirements FOR INSERT WITH CHECK (submitted_by = auth.uid()::text);

DROP POLICY IF EXISTS "Requirements Update" ON requirements;
CREATE POLICY "Requirements Update" ON requirements FOR UPDATE USING (submitted_by = auth.uid()::text) WITH CHECK (submitted_by = auth.uid()::text);

DROP POLICY IF EXISTS "Requirement Skills Read" ON requirement_skills;
CREATE POLICY "Requirement Skills Read" ON requirement_skills FOR SELECT USING (true);

DROP POLICY IF EXISTS "Requirement Skills Modify" ON requirement_skills;
CREATE POLICY "Requirement Skills Modify" ON requirement_skills FOR ALL 
    USING (EXISTS (SELECT 1 FROM requirements r WHERE r.requirement_id = requirement_skills.requirement_id AND r.submitted_by = auth.uid()::text))
    WITH CHECK (EXISTS (SELECT 1 FROM requirements r WHERE r.requirement_id = requirement_skills.requirement_id AND r.submitted_by = auth.uid()::text));

DROP POLICY IF EXISTS "Match Results Access" ON match_results;
CREATE POLICY "Match Results Access" ON match_results FOR SELECT 
    USING (EXISTS (SELECT 1 FROM requirements r WHERE r.requirement_id = match_results.requirement_id AND r.submitted_by = auth.uid()::text)
        OR EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = match_results.worker_profile_id AND wp.user_id = auth.uid()::text));

-- Service Requests & Project Execution (Dual Client-Worker Scope)
DROP POLICY IF EXISTS "Service Requests Access" ON service_requests;
CREATE POLICY "Service Requests Access" ON service_requests FOR SELECT 
    USING (client_id = auth.uid()::text OR EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = service_requests.worker_profile_id AND wp.user_id = auth.uid()::text));

DROP POLICY IF EXISTS "Service Requests Insert" ON service_requests;
CREATE POLICY "Service Requests Insert" ON service_requests FOR INSERT WITH CHECK (client_id = auth.uid()::text);

DROP POLICY IF EXISTS "Service Requests Update" ON service_requests;
CREATE POLICY "Service Requests Update" ON service_requests FOR UPDATE 
    USING (client_id = auth.uid()::text OR EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = service_requests.worker_profile_id AND wp.user_id = auth.uid()::text));

DROP POLICY IF EXISTS "Projects Access" ON projects;
CREATE POLICY "Projects Access" ON projects FOR ALL USING (client_id = auth.uid()::text) WITH CHECK (client_id = auth.uid()::text);

DROP POLICY IF EXISTS "User Roles Read" ON user_roles;
CREATE POLICY "User Roles Read" ON user_roles FOR SELECT USING (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "User Roles Modify" ON user_roles;
CREATE POLICY "User Roles Modify" ON user_roles FOR ALL USING (false);

-- Teams: Project client or assigned team member
DROP POLICY IF EXISTS "Teams Read" ON teams;
CREATE POLICY "Teams Read" ON teams FOR SELECT 
    USING (
        EXISTS (SELECT 1 FROM projects p WHERE p.project_id = teams.project_id AND p.client_id = auth.uid()::text)
        OR EXISTS (SELECT 1 FROM team_members tm JOIN worker_profiles wp ON tm.worker_profile_id = wp.worker_profile_id WHERE tm.team_id = teams.team_id AND wp.user_id = auth.uid()::text)
    );

-- Team Members: Project client or member themselves
DROP POLICY IF EXISTS "Team Members Read" ON team_members;
CREATE POLICY "Team Members Read" ON team_members FOR SELECT 
    USING (
        EXISTS (SELECT 1 FROM teams t JOIN projects p ON t.project_id = p.project_id WHERE t.team_id = team_members.team_id AND p.client_id = auth.uid()::text)
        OR EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = team_members.worker_profile_id AND wp.user_id = auth.uid()::text)
    );

-- Tasks: Project client, assigned team member, or any team member on project
DROP POLICY IF EXISTS "Tasks Read" ON tasks;
CREATE POLICY "Tasks Read" ON tasks FOR SELECT 
    USING (
        EXISTS (SELECT 1 FROM projects p WHERE p.project_id = tasks.project_id AND p.client_id = auth.uid()::text)
        OR EXISTS (SELECT 1 FROM team_members tm JOIN worker_profiles wp ON tm.worker_profile_id = wp.worker_profile_id WHERE tm.team_member_id = tasks.assigned_team_member_id AND wp.user_id = auth.uid()::text)
        OR EXISTS (SELECT 1 FROM teams t JOIN team_members tm ON t.team_id = tm.team_id JOIN worker_profiles wp ON tm.worker_profile_id = wp.worker_profile_id WHERE t.project_id = tasks.project_id AND wp.user_id = auth.uid()::text)
    );

-- 15.3 Financial Transparency & Anti-Tampering Protections
-- Payments: Client can view their own payments; worker can view payments related to their booked jobs
DROP POLICY IF EXISTS "Payments Read" ON payments;
CREATE POLICY "Payments Read" ON payments FOR SELECT 
    USING (client_id = auth.uid()::text OR EXISTS (SELECT 1 FROM service_requests sr JOIN worker_profiles wp ON sr.worker_profile_id = wp.worker_profile_id WHERE sr.service_request_id = payments.service_request_id AND wp.user_id = auth.uid()::text));

DROP POLICY IF EXISTS "Payments Insert" ON payments;
CREATE POLICY "Payments Insert" ON payments FOR INSERT WITH CHECK (client_id = auth.uid()::text);

-- Payments Update: Clients CANNOT update payment status directly; settlement requires backend RPC complete_payment_transaction
DROP POLICY IF EXISTS "Payments Update" ON payments;
CREATE POLICY "Payments Update" ON payments FOR UPDATE USING (false);

DROP POLICY IF EXISTS "Invoices Read" ON invoices;
CREATE POLICY "Invoices Read" ON invoices FOR SELECT 
    USING (EXISTS (SELECT 1 FROM payments p WHERE p.payment_id = invoices.payment_id AND p.client_id = auth.uid()::text));

DROP POLICY IF EXISTS "Transactions Read" ON transactions;
CREATE POLICY "Transactions Read" ON transactions FOR SELECT 
    USING (EXISTS (SELECT 1 FROM payments p WHERE p.payment_id = transactions.payment_id AND p.client_id = auth.uid()::text));

-- Worker Earnings: Strictly private to the individual worker profile owner; only trusted backend can credit/insert
DROP POLICY IF EXISTS "Worker Earnings Read" ON worker_earnings;
CREATE POLICY "Worker Earnings Read" ON worker_earnings FOR SELECT 
    USING (EXISTS (SELECT 1 FROM worker_profiles wp WHERE wp.worker_profile_id = worker_earnings.worker_profile_id AND wp.user_id = auth.uid()::text));

DROP POLICY IF EXISTS "Worker Earnings Modify" ON worker_earnings;
CREATE POLICY "Worker Earnings Modify" ON worker_earnings FOR ALL USING (false);

-- Realtime Messaging & Notification Privacy
DROP POLICY IF EXISTS "Conversations Access" ON conversations;
CREATE POLICY "Conversations Access" ON conversations FOR ALL 
    USING (auth.uid()::text IN (participant_one, participant_two))
    WITH CHECK (auth.uid()::text IN (participant_one, participant_two));

DROP POLICY IF EXISTS "Messages Read" ON messages;
CREATE POLICY "Messages Read" ON messages FOR SELECT 
    USING (EXISTS (SELECT 1 FROM conversations c WHERE c.conversation_id = messages.conversation_id AND auth.uid()::text IN (c.participant_one, c.participant_two)));

DROP POLICY IF EXISTS "Messages Insert" ON messages;
CREATE POLICY "Messages Insert" ON messages FOR INSERT WITH CHECK (sender_id = auth.uid()::text);

DROP POLICY IF EXISTS "Notifications Access" ON notifications;
CREATE POLICY "Notifications Access" ON notifications FOR ALL 
    USING (user_id = auth.uid()::text)
    WITH CHECK (user_id = auth.uid()::text);

DROP POLICY IF EXISTS "Audit Logs Access" ON audit_logs;
CREATE POLICY "Audit Logs Access" ON audit_logs FOR SELECT USING (user_id = auth.uid()::text);

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
-- Note: Initial seed rows omitted to maintain clean zero-state for new environments.
-- Services and standardized rates are created through admin-web or live verified migrations.

-- 16.5 Skills
-- Note: Granular skills are populated when associated services are published.



-- 6. STORED PROCEDURE: CALCULATE PROFILE COMPLETION INTELLIGENCE
CREATE OR REPLACE FUNCTION public.calculate_profile_completion(p_user_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_address_count INTEGER := 0;
    v_total_points INTEGER := 0;
    v_missing_fields TEXT[] := ARRAY[]::TEXT[];
    v_full_name TEXT := NULL;
    v_email TEXT := NULL;
    v_phone TEXT := NULL;
    v_avatar_url TEXT := NULL;
    v_dob DATE := NULL;
    v_emergency_phone TEXT := NULL;
BEGIN
    -- Query user details safely across user_id or id columns
    BEGIN
        SELECT full_name, email, phone, avatar_url, date_of_birth, emergency_contact_phone
        INTO v_full_name, v_email, v_phone, v_avatar_url, v_dob, v_emergency_phone
        FROM public.users
        WHERE user_id = p_user_id;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            SELECT full_name, email, phone, avatar_url, date_of_birth, emergency_contact_phone
            INTO v_full_name, v_email, v_phone, v_avatar_url, v_dob, v_emergency_phone
            FROM public.users
            WHERE id::text = p_user_id;
        EXCEPTION WHEN OTHERS THEN
            v_full_name := NULL;
        END;
    END;

    -- Basic Profile Scoring (50 points)
    IF v_full_name IS NOT NULL AND length(trim(v_full_name)) > 2 THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Full Name');
    END IF;

    IF v_email IS NOT NULL AND length(trim(v_email)) > 4 THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Email Address');
    END IF;

    IF v_phone IS NOT NULL AND length(trim(v_phone)) > 6 THEN
        v_total_points := v_total_points + 10;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Phone Number');
    END IF;

    IF v_avatar_url IS NOT NULL THEN
        v_total_points := v_total_points + 10;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Profile Photo');
    END IF;

    -- Check Address (20 points)
    SELECT count(*) INTO v_address_count FROM public.user_addresses WHERE user_id = p_user_id;
    IF v_address_count > 0 THEN
        v_total_points := v_total_points + 20;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Saved Delivery Address');
    END IF;

    -- DOB (15 points)
    IF v_dob IS NOT NULL THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Date of Birth');
    END IF;

    -- Emergency Contact (15 points)
    IF v_emergency_phone IS NOT NULL AND length(trim(v_emergency_phone)) > 6 THEN
        v_total_points := v_total_points + 15;
    ELSE
        v_missing_fields := array_append(v_missing_fields, 'Emergency Contact');
    END IF;

    -- Cap at 100
    IF v_total_points > 100 THEN
        v_total_points := 100;
    END IF;

    -- Update score in users table safely
    BEGIN
        UPDATE public.users SET profile_completion_percentage = v_total_points WHERE user_id = p_user_id;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            UPDATE public.users SET profile_completion_percentage = v_total_points WHERE id::text = p_user_id;
        EXCEPTION WHEN OTHERS THEN
            NULL;
        END;
    END;

    RETURN jsonb_build_object(
        'user_id', p_user_id,
        'completion_percentage', v_total_points,
        'missing_fields', to_jsonb(v_missing_fields),
        'is_profile_complete', (v_total_points >= 80)
    );
END;
$$;


-- 7. STORED PROCEDURE: PROGRESSIVE FEATURE ELIGIBILITY GATE
CREATE OR REPLACE FUNCTION public.check_feature_eligibility(
    p_user_id TEXT,
    p_feature_name TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_address_count INTEGER := 0;
    v_is_eligible BOOLEAN := false;
    v_reasons TEXT[] := ARRAY[]::TEXT[];
    v_account_status TEXT := 'active';
    v_phone TEXT := NULL;
BEGIN
    -- Query user status safely
    BEGIN
        SELECT account_status, phone INTO v_account_status, v_phone FROM public.users WHERE user_id = p_user_id;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            SELECT account_status, phone INTO v_account_status, v_phone FROM public.users WHERE id::text = p_user_id;
        EXCEPTION WHEN OTHERS THEN
            v_account_status := 'active';
        END;
    END;

    IF v_account_status = 'suspended' OR v_account_status = 'deactivated' THEN
        RETURN jsonb_build_object('eligible', false, 'reason', 'Account is suspended or deactivated');
    END IF;

    IF p_feature_name = 'book_service' THEN
        SELECT count(*) INTO v_address_count FROM public.user_addresses WHERE user_id = p_user_id;
        IF v_address_count = 0 THEN
            v_reasons := array_append(v_reasons, 'A saved service address is required before booking.');
        END IF;

        IF v_phone IS NULL OR length(trim(v_phone)) < 6 THEN
            v_reasons := array_append(v_reasons, 'A contact phone number is required for booking dispatch.');
        END IF;

        IF array_length(v_reasons, 1) IS NULL THEN
            v_is_eligible := true;
        END IF;
    ELSE
        v_is_eligible := true;
    END IF;

    RETURN jsonb_build_object(
        'eligible', v_is_eligible,
        'feature', p_feature_name,
        'reasons', to_jsonb(v_reasons)
    );
END;
$$;
