-- ==============================================================================
-- PART 05: FINANCE, ESCROW, PAYOUTS & MAKER-CHECKER GOVERNANCE
-- Domain: Payments, Invoices, Transactions, Worker Earnings & Reconciliation
-- Consumers: Flutter Mobile App + Admin Web Portal
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_request_id UUID REFERENCES public.service_requests(service_request_id) ON DELETE SET NULL,
    project_id UUID REFERENCES public.projects(project_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    skavia_fee DECIMAL(10, 2) NOT NULL,
    commission_percent_snapshot DECIMAL(5, 4) DEFAULT 0.1500,
    status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.invoices (
    invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL UNIQUE REFERENCES public.payments(payment_id) ON DELETE CASCADE,
    invoice_number VARCHAR(50) NOT NULL UNIQUE,
    client_name VARCHAR(150) NOT NULL,
    worker_amount DECIMAL(10, 2) NOT NULL,
    skavia_fee DECIMAL(10, 2) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    issued_at TIMESTAMPTZ DEFAULT NOW(),
    pdf_url TEXT
);

CREATE TABLE IF NOT EXISTS public.transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES public.payments(payment_id) ON DELETE CASCADE,
    gateway_name VARCHAR(50) NOT NULL,
    gateway_tx_id VARCHAR(100),
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Completed',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.worker_earnings (
    earning_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    payment_id UUID UNIQUE REFERENCES public.payments(payment_id) ON DELETE SET NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Available',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Financial Maker-Checker & Payout Governance (Admin Web)
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
