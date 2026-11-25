-- ==============================================================================
-- PART 04: MARKETPLACE PROFILES, MATCHING, BOOKINGS & TEAM PROJECTS
-- Domain: Customer & Worker Profiles, Algorithmic Matching, Service Requests
-- Consumers: Flutter Mobile App + Admin Web Portal
-- ==============================================================================

-- 4.1 CUSTOMER & WORKER PROFILES
CREATE TABLE IF NOT EXISTS public.customer_profiles (
    customer_profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE REFERENCES public.users(user_id) ON DELETE CASCADE,
    customer_type VARCHAR(30) NOT NULL DEFAULT 'Individual',
    company_name VARCHAR(150),
    trade_license VARCHAR(100),
    billing_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.worker_profiles (
    worker_profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE REFERENCES public.users(user_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    category_id UUID REFERENCES public.categories(category_id) ON DELETE SET NULL,
    title VARCHAR(150) NOT NULL,
    bio TEXT,
    location VARCHAR(150) NOT NULL DEFAULT 'Dhaka',
    working_area VARCHAR(200) NOT NULL DEFAULT 'All Dhaka City',
    expected_rate DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    verification_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    rating_average DECIMAL(3, 2) NOT NULL DEFAULT 0.00,
    total_reviews INTEGER NOT NULL DEFAULT 0,
    completed_jobs INTEGER NOT NULL DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.worker_skills (
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES public.skills(skill_id) ON DELETE CASCADE,
    proficiency_level VARCHAR(20) DEFAULT 'Expert',
    years_experience INTEGER DEFAULT 1,
    PRIMARY KEY (worker_profile_id, skill_id)
);

CREATE TABLE IF NOT EXISTS public.portfolio_items (
    portfolio_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    project_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.certificates (
    certificate_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    issuing_organization VARCHAR(150) NOT NULL,
    issue_date DATE,
    certificate_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.availability_slots (
    slot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    day_of_week VARCHAR(15),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_booked BOOLEAN DEFAULT FALSE,
    slot_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4.2 REQUIREMENTS & ALGORITHMIC MATCHING
CREATE TABLE IF NOT EXISTS public.requirements (
    requirement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submitted_by TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    category_id UUID REFERENCES public.categories(category_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    requirement_type VARCHAR(30) NOT NULL DEFAULT 'Simple',
    urgency VARCHAR(20) NOT NULL DEFAULT 'Medium',
    location VARCHAR(150) NOT NULL,
    required_date DATE,
    budget DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(30) NOT NULL DEFAULT 'Open',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.requirement_skills (
    requirement_id UUID NOT NULL REFERENCES public.requirements(requirement_id) ON DELETE CASCADE,
    skill_id UUID NOT NULL REFERENCES public.skills(skill_id) ON DELETE CASCADE,
    importance_weight DECIMAL(3, 2) DEFAULT 1.00,
    PRIMARY KEY (requirement_id, skill_id)
);

CREATE TABLE IF NOT EXISTS public.match_results (
    match_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID NOT NULL REFERENCES public.requirements(requirement_id) ON DELETE CASCADE,
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    match_score DECIMAL(5, 2) NOT NULL,
    rank_position INTEGER NOT NULL,
    skill_score DECIMAL(5, 2),
    distance_score DECIMAL(5, 2),
    rating_score DECIMAL(5, 2),
    rate_score DECIMAL(5, 2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4.3 SERVICE REQUESTS (DISPATCH & BOOKING)
CREATE TABLE IF NOT EXISTS public.service_requests (
    service_request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID REFERENCES public.requirements(requirement_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Requested',
    scheduled_at TIMESTAMPTZ,
    agreed_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    service_notes TEXT,
    cancellation_reason TEXT,
    cancelled_by TEXT REFERENCES public.users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4.4 COMMERCIAL PROJECTS, TEAMS & KANBAN TASKS
CREATE TABLE IF NOT EXISTS public.projects (
    project_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requirement_id UUID REFERENCES public.requirements(requirement_id) ON DELETE SET NULL,
    client_id TEXT NOT NULL REFERENCES public.users(user_id) ON DELETE CASCADE,
    branch_id UUID REFERENCES public.branches(branch_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'Requested',
    deadline DATE,
    total_budget DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.teams (
    team_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(project_id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'Forming',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.team_members (
    team_member_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES public.teams(team_id) ON DELETE CASCADE,
    worker_profile_id UUID NOT NULL REFERENCES public.worker_profiles(worker_profile_id) ON DELETE CASCADE,
    role_in_team VARCHAR(100) NOT NULL DEFAULT 'Specialist',
    is_team_leader BOOLEAN NOT NULL DEFAULT FALSE,
    assigned_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tasks (
    task_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(project_id) ON DELETE CASCADE,
    assigned_team_member_id UUID REFERENCES public.team_members(team_member_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'Assigned',
    priority VARCHAR(20) NOT NULL DEFAULT 'Medium',
    deadline DATE,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
