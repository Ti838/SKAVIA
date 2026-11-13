import { randomUUID } from 'node:crypto';
import type {
  AdminRoleName,
  AppReleaseChannel,
  AppReleasePlatform,
  AppReleaseStatus,
  BranchSummary,
  InvitableAdminRole,
  InvitationDeliveryStatus,
  InvitationStatus,
  PermissionKey,
  PermissionOverrideRecord,
  ReleaseTelemetryEventType,
} from '@/lib/contracts';
import type {
  AppReleaseAnalyticsDto,
  AppReleaseDto,
  ReleaseSigningPolicyDto,
} from '@/lib/types';
import {
  DEFAULT_SKAVIA_PACKAGE_NAME,
  ReleaseValidationError,
} from '@/server/releases/release-validator';
import { AuthorizationError, DEFAULT_ROLE_PERMISSION_TEMPLATES } from '@/server/auth/rbac';
import type {
  AdminAccountRecord,
  AdminInvitationRecord,
  AdminLoginEventRecord,
  AdminPasskeyRecord,
  AdminRepository,
  AdminSessionRecord,
  AuditLogEntry,
  AuditWriteInput,
  BookingListItem,
  CustomerDirectoryItem,
  DashboardMetrics,
  DisputeItem,
  FinanceLedgerSnapshot,
  LoginEventOutcome,
  ProjectSummaryItem,
  SecurityIncidentItem,
  ServiceTaxonomyItem,
  UserIdentityRecord,
  VerificationQueueItem,
  WebAuthnChallengeRecord,
  WorkerDirectoryItem,
} from '@/server/db/repository';

export const TEST_IDS = {
  branches: {
    TECH: 'b1111111-1111-4111-8111-111111111111',
    HOME: 'b2222222-2222-4222-8222-222222222222',
    CORP: 'b3333333-3333-4333-8333-333333333333',
  },
  users: {
    superAdmin: 'admin-super-001',
    companyAdmin: 'admin-company-001',
    branchManagerTech: 'admin-bm-tech-001',
    suspendedAdmin: 'admin-suspended-001',
    customerIndividual: 'cust-indiv-001',
    customerBusiness: 'cust-biz-001',
    workerTechUser: 'worker-tech-user-001',
    workerHomeUser: 'worker-home-user-001',
  },
  workerProfiles: {
    tech: '11111111-aaaa-4aaa-8aaa-111111111111',
    home: '22222222-bbbb-4bbb-8bbb-222222222222',
  },
  verifications: {
    techPending: '33333333-aaaa-4aaa-8aaa-333333333333',
    homePending: '44444444-bbbb-4bbb-8bbb-444444444444',
  },
  bookings: {
    techBooking: '55555555-aaaa-4aaa-8aaa-555555555555',
    homeBooking: '66666666-bbbb-4bbb-8bbb-666666666666',
  },
  projects: {
    techProject: '77777777-aaaa-4aaa-8aaa-777777777777',
    homeProject: '88888888-bbbb-4bbb-8bbb-888888888888',
  },
  disputes: {
    techDispute: '99999999-aaaa-4aaa-8aaa-999999999999',
    homeDispute: 'aaaaaaaa-bbbb-4bbb-8bbb-aaaaaaaaaaaa',
  },
  payments: {
    techPayment: 'bbbbbbbb-aaaa-4aaa-8aaa-bbbbbbbbbbbb',
    homePayment: 'cccccccc-bbbb-4bbb-8bbb-cccccccccccc',
  },
  categories: {
    hvac: 'dddddddd-aaaa-4aaa-8aaa-dddddddddddd',
    home: 'eeeeeeee-bbbb-4bbb-8bbb-eeeeeeeeeeee',
  },
};

interface InternalUserState {
  identity: UserIdentityRecord;
  roles: AdminRoleName[];
  isPrimarySuperAdmin?: boolean;
  loginUsername?: string | null;
  branchIds: string[];
  overrides: PermissionOverrideRecord[];
  permissionVersion: number;
  mfaEnforced: boolean;
  lastLoginAt: string | null;
  lastLoginIp: string | null;
  devices?: string[];
  recoveryHashes?: string[];
  recoveryGeneratedAt?: string | null;
}

export class InMemoryAdminRepository implements AdminRepository {
  public branches: BranchSummary[];
  public users: Map<string, InternalUserState>;
  public sessions: Map<string, AdminSessionRecord> = new Map();
  public loginEvents: AdminLoginEventRecord[] = [];
  public invitations: AdminInvitationRecord[] = [];
  public passkeys: AdminPasskeyRecord[] = [];
  public webauthnChallenges: Map<string, WebAuthnChallengeRecord> = new Map();
  public auditLogs: AuditLogEntry[] = [];
  public workers: WorkerDirectoryItem[];
  public verifications: VerificationQueueItem[];
  public bookings: BookingListItem[];
  public projects: ProjectSummaryItem[];
  public disputes: DisputeItem[];
  public taxonomy: ServiceTaxonomyItem;
  public payments: FinanceLedgerSnapshot['payments'];
  public approvals: FinanceLedgerSnapshot['approvals'] = [];
  public commissionRules: FinanceLedgerSnapshot['commissionRules'];
  public incidents: SecurityIncidentItem[] = [];
  public releases: AppReleaseDto[] = [];
  public releaseEvents: AppReleaseAnalyticsDto['recentEvents'] = [];
  public releaseBlobs: Map<string, Buffer> = new Map();
  public releaseSigningPolicy: ReleaseSigningPolicyDto = {
    expectedPackageName: DEFAULT_SKAVIA_PACKAGE_NAME,
    pinnedSigningCertSha256: null,
    updatedAt: null,
    updatedBy: null,
  };
  public settings: Array<{ setting_key: string; setting_value: unknown; description: string | null; updated_at: string }> = [
    {
      setting_key: 'default_commission_percent',
      setting_value: { percent: 0.12 },
      description: 'Default SKAVIA commission rate',
      updated_at: '2026-11-11T00:00:00Z',
    },
  ];
  public backupLogs: Array<{ verification_id: string; environment: string; restore_target: string; status: string; verified_at: string; rpo_minutes: number | null; rto_minutes: number | null }> = [
    {
      verification_id: randomUUID(),
      environment: 'production',
      restore_target: 'supabase-pit-restore-test',
      status: 'Passed',
      verified_at: '2026-11-10T03:00:00Z',
      rpo_minutes: 5,
      rto_minutes: 14,
    },
  ];

  constructor() {
    const now = '2026-11-11T08:00:00.000Z';
    this.branches = [
      {
        branch_id: TEST_IDS.branches.TECH,
        name: 'SKAVIA Technical',
        code: 'TECH',
        description: 'Engineering, MEP, HVAC, electrical & IT installations',
        manager_id: TEST_IDS.users.branchManagerTech,
        is_active: true,
        created_at: now,
      },
      {
        branch_id: TEST_IDS.branches.HOME,
        name: 'SKAVIA Home',
        code: 'HOME',
        description: 'Home maintenance, plumbing & appliance servicing',
        manager_id: null,
        is_active: true,
        created_at: now,
      },
      {
        branch_id: TEST_IDS.branches.CORP,
        name: 'SKAVIA Corporate',
        code: 'CORP',
        description: 'Enterprise contracts & turnkey facility management',
        manager_id: null,
        is_active: true,
        created_at: now,
      },
    ];

    this.users = new Map<string, InternalUserState>([
      [
        TEST_IDS.users.superAdmin,
        {
          identity: {
            user_id: TEST_IDS.users.superAdmin,
            full_name: 'Tariq SuperAdmin',
            email: 'superadmin@skavia.com',
            phone: '+8801700000001',
            status: 'Active',
            account_status: 'active',
            verification_status: 'Verified',
            active_mode: 'admin',
            location: 'Dhaka HQ',
            created_at: now,
          },
          roles: ['Super Admin'],
          isPrimarySuperAdmin: true,
          loginUsername: 'tariq_superadmin',
          branchIds: [],
          overrides: [],
          permissionVersion: 1,
          mfaEnforced: true,
          lastLoginAt: null,
          lastLoginIp: null,
        },
      ],
      [
        TEST_IDS.users.companyAdmin,
        {
          identity: {
            user_id: TEST_IDS.users.companyAdmin,
            full_name: 'Nadia CompanyAdmin',
            email: 'ops@skavia.com',
            phone: '+8801700000002',
            status: 'Active',
            account_status: 'active',
            verification_status: 'Verified',
            active_mode: 'admin',
            location: 'Dhaka HQ',
            created_at: now,
          },
          roles: ['Company Admin'],
          branchIds: [],
          overrides: [],
          permissionVersion: 1,
          mfaEnforced: false,
          lastLoginAt: null,
          lastLoginIp: null,
        },
      ],
      [
        TEST_IDS.users.branchManagerTech,
        {
          identity: {
            user_id: TEST_IDS.users.branchManagerTech,
            full_name: 'Kamal TechManager',
            email: 'tech.manager@skavia.com',
            phone: '+8801700000003',
            status: 'Active',
            account_status: 'active',
            verification_status: 'Verified',
            active_mode: 'admin',
            location: 'Banani',
            created_at: now,
          },
          roles: ['Branch Manager'],
          branchIds: [TEST_IDS.branches.TECH],
          overrides: [],
          permissionVersion: 1,
          mfaEnforced: false,
          lastLoginAt: null,
          lastLoginIp: null,
        },
      ],
      [
        TEST_IDS.users.suspendedAdmin,
        {
          identity: {
            user_id: TEST_IDS.users.suspendedAdmin,
            full_name: 'Suspended Admin',
            email: 'suspended@skavia.com',
            phone: null,
            status: 'Suspended',
            account_status: 'suspended',
            verification_status: 'Verified',
            active_mode: 'admin',
            location: 'Dhaka',
            created_at: now,
          },
          roles: ['Branch Manager'],
          branchIds: [TEST_IDS.branches.HOME],
          overrides: [],
          permissionVersion: 1,
          mfaEnforced: false,
          lastLoginAt: null,
          lastLoginIp: null,
        },
      ],
      [
        TEST_IDS.users.customerIndividual,
        {
          identity: {
            user_id: TEST_IDS.users.customerIndividual,
            full_name: '=SUM(A1:A2) Arif Customer',
            email: 'arif@example.com',
            phone: '+8801800000010',
            status: 'Active',
            account_status: 'active',
            verification_status: 'Verified',
            active_mode: 'client',
            location: 'Gulshan',
            created_at: now,
          },
          roles: [],
          branchIds: [],
          overrides: [],
          permissionVersion: 1,
          mfaEnforced: false,
          lastLoginAt: null,
          lastLoginIp: null,
        },
      ],
      [
        TEST_IDS.users.customerBusiness,
        {
          identity: {
            user_id: TEST_IDS.users.customerBusiness,
            full_name: 'Delta Garments Ltd.',
            email: 'facilities@delta.bd',
            phone: '+8801800000011',
            status: 'Active',
            account_status: 'active',
            verification_status: 'Verified',
            active_mode: 'client',
            location: 'Gazipur',
            created_at: now,
          },
          roles: [],
          branchIds: [],
          overrides: [],
          permissionVersion: 1,
          mfaEnforced: false,
          lastLoginAt: null,
          lastLoginIp: null,
        },
      ],
    ]);

    this.workers = [
      {
        worker_profile_id: TEST_IDS.workerProfiles.tech,
        user_id: TEST_IDS.users.workerTechUser,
        full_name: 'Rafiq HVAC Engineer',
        email: 'rafiq@skavia.workers',
        phone: '+8801900000001',
        branch_id: TEST_IDS.branches.TECH,
        branch_name: 'SKAVIA Technical',
        category_id: 'cat-hvac',
        category_name: 'HVAC & Electrical',
        title: 'Senior Chiller Technician',
        location: 'Tejgaon',
        expected_rate: 2500,
        verification_status: 'Pending',
        account_status: 'active',
        rating_average: 4.9,
        total_reviews: 42,
        completed_jobs: 60,
        is_available: true,
        skills: ['VRF Diagnostics', 'Chiller Maintenance'],
        created_at: now,
      },
      {
        worker_profile_id: TEST_IDS.workerProfiles.home,
        user_id: TEST_IDS.users.workerHomeUser,
        full_name: 'Salma Home Specialist',
        email: 'salma@skavia.workers',
        phone: '+8801900000002',
        branch_id: TEST_IDS.branches.HOME,
        branch_name: 'SKAVIA Home',
        category_id: 'cat-home',
        category_name: 'Home Plumbing',
        title: 'Lead Home Plumber',
        location: 'Dhanmondi',
        expected_rate: 1200,
        verification_status: 'Pending',
        account_status: 'active',
        rating_average: 4.7,
        total_reviews: 18,
        completed_jobs: 24,
        is_available: true,
        skills: ['Pipe Fitting'],
        created_at: now,
      },
    ];

    this.verifications = [
      {
        verification_id: TEST_IDS.verifications.techPending,
        worker_profile_id: TEST_IDS.workerProfiles.tech,
        worker_user_id: TEST_IDS.users.workerTechUser,
        worker_name: 'Rafiq HVAC Engineer',
        branch_id: TEST_IDS.branches.TECH,
        branch_name: 'SKAVIA Technical',
        document_type: 'NID',
        document_number: '1991269000111',
        document_file_url: 'verifications/tech/nid-rafiq.pdf',
        status: 'Pending',
        reviewed_by: null,
        review_notes: null,
        reviewed_at: null,
        created_at: now,
      },
      {
        verification_id: TEST_IDS.verifications.homePending,
        worker_profile_id: TEST_IDS.workerProfiles.home,
        worker_user_id: TEST_IDS.users.workerHomeUser,
        worker_name: 'Salma Home Specialist',
        branch_id: TEST_IDS.branches.HOME,
        branch_name: 'SKAVIA Home',
        document_type: 'NID',
        document_number: '1993269000222',
        document_file_url: 'verifications/home/nid-salma.pdf',
        status: 'Pending',
        reviewed_by: null,
        review_notes: null,
        reviewed_at: null,
        created_at: now,
      },
    ];

    this.bookings = [
      {
        service_request_id: TEST_IDS.bookings.techBooking,
        requirement_id: null,
        branch_id: TEST_IDS.branches.TECH,
        branch_name: 'SKAVIA Technical',
        client_id: TEST_IDS.users.customerBusiness,
        client_name: 'Delta Garments Ltd.',
        worker_profile_id: TEST_IDS.workerProfiles.tech,
        worker_name: 'Rafiq HVAC Engineer',
        status: 'Accepted',
        scheduled_at: '2026-11-12T10:00:00Z',
        agreed_price: 15000,
        service_notes: 'Annual chiller inspection',
        cancellation_reason: null,
        created_at: now,
      },
      {
        service_request_id: TEST_IDS.bookings.homeBooking,
        requirement_id: null,
        branch_id: TEST_IDS.branches.HOME,
        branch_name: 'SKAVIA Home',
        client_id: TEST_IDS.users.customerIndividual,
        client_name: '=SUM(A1:A2) Arif Customer',
        worker_profile_id: TEST_IDS.workerProfiles.home,
        worker_name: 'Salma Home Specialist',
        status: 'Requested',
        scheduled_at: '2026-11-13T11:00:00Z',
        agreed_price: 2500,
        service_notes: 'Kitchen sink valve leak',
        cancellation_reason: null,
        created_at: now,
      },
    ];

    this.projects = [
      {
        project_id: TEST_IDS.projects.techProject,
        client_id: TEST_IDS.users.customerBusiness,
        client_name: 'Delta Garments Ltd.',
        branch_id: TEST_IDS.branches.TECH,
        branch_name: 'SKAVIA Technical',
        title: 'Factory Line-2 HVAC Retrofit',
        description: 'Multi-unit HVAC installation',
        status: 'Planning',
        deadline: '2026-12-01',
        total_budget: 250000,
        teams: [],
        tasks: [],
      },
      {
        project_id: TEST_IDS.projects.homeProject,
        client_id: TEST_IDS.users.customerIndividual,
        client_name: 'Arif Customer',
        branch_id: TEST_IDS.branches.HOME,
        branch_name: 'SKAVIA Home',
        title: 'Apartment Full Repiping',
        description: 'Home plumbing overhaul',
        status: 'Planning',
        deadline: '2026-11-30',
        total_budget: 45000,
        teams: [],
        tasks: [],
      },
    ];

    this.disputes = [
      {
        dispute_id: TEST_IDS.disputes.techDispute,
        complaint_id: 'comp-tech-001',
        branch_id: TEST_IDS.branches.TECH,
        branch_name: 'SKAVIA Technical',
        filed_by: TEST_IDS.users.customerBusiness,
        filed_by_name: 'Delta Garments Ltd.',
        service_request_id: TEST_IDS.bookings.techBooking,
        category: 'Service Quality',
        complaint_description: 'Pressure gauge not recalibrated cleanly.',
        assigned_admin_id: null,
        status: 'Open',
        resolution: null,
        resolved_at: null,
        created_at: now,
        notes: [],
      },
      {
        dispute_id: TEST_IDS.disputes.homeDispute,
        complaint_id: 'comp-home-001',
        branch_id: TEST_IDS.branches.HOME,
        branch_name: 'SKAVIA Home',
        filed_by: TEST_IDS.users.customerIndividual,
        filed_by_name: 'Arif Customer',
        service_request_id: TEST_IDS.bookings.homeBooking,
        category: 'Billing',
        complaint_description: 'Spare part surcharge questioned.',
        assigned_admin_id: null,
        status: 'Open',
        resolution: null,
        resolved_at: null,
        created_at: now,
        notes: [],
      },
    ];

    this.taxonomy = {
      categories: [
        {
          category_id: TEST_IDS.categories.hvac,
          branch_id: TEST_IDS.branches.TECH,
          branch_name: 'SKAVIA Technical',
          name: 'HVAC & Electrical',
          slug: 'hvac-electrical',
          icon_name: 'build',
          is_active: true,
        },
        {
          category_id: TEST_IDS.categories.home,
          branch_id: TEST_IDS.branches.HOME,
          branch_name: 'SKAVIA Home',
          name: 'Home Plumbing',
          slug: 'home-plumbing',
          icon_name: 'plumbing',
          is_active: true,
        },
      ],
      services: [
        {
          service_id: 'ffffffff-aaaa-4aaa-8aaa-ffffffffffff',
          category_id: TEST_IDS.categories.hvac,
          name: 'Chiller Annual Maintenance',
          description: null,
          base_price: 15000,
        },
      ],
      skills: [
        {
          skill_id: '12121212-aaaa-4aaa-8aaa-121212121212',
          category_id: TEST_IDS.categories.hvac,
          service_id: 'ffffffff-aaaa-4aaa-8aaa-ffffffffffff',
          name: 'VRF Diagnostics',
        },
      ],
    };

    this.payments = [
      {
        payment_id: TEST_IDS.payments.techPayment,
        branch_id: TEST_IDS.branches.TECH,
        client_id: TEST_IDS.users.customerBusiness,
        client_name: 'Delta Garments Ltd.',
        total_amount: 15000,
        skavia_fee: 1800,
        commission_percent_snapshot: 0.12,
        status: 'Completed',
        paid_at: now,
        created_at: now,
        gateway_name: 'SSLCommerz',
        gateway_tx_id: 'SSL-TECH-001',
        invoice_number: 'INV-2026-001',
      },
      {
        payment_id: TEST_IDS.payments.homePayment,
        branch_id: TEST_IDS.branches.HOME,
        client_id: TEST_IDS.users.customerIndividual,
        client_name: 'Arif Customer',
        total_amount: 2500,
        skavia_fee: 300,
        commission_percent_snapshot: 0.12,
        status: 'Completed',
        paid_at: now,
        created_at: now,
        gateway_name: 'bKash',
        gateway_tx_id: 'BK-HOME-001',
        invoice_number: 'INV-2026-002',
      },
    ];

    this.commissionRules = [
      {
        rule_id: randomUUID(),
        branch_id: null,
        category_id: null,
        fee_percent: 0.12,
        is_active: true,
        effective_from: now,
        approved_by: TEST_IDS.users.superAdmin,
      },
    ];
  }

  async resolveAdminIdentity(userId: string) {
    const u = this.users.get(userId);
    if (!u || u.roles.length === 0) return null;

    const perms = new Set<PermissionKey>();
    for (const r of u.roles) {
      for (const p of DEFAULT_ROLE_PERMISSION_TEMPLATES[r].permissions) {
        perms.add(p);
      }
    }

    const assignedBranches =
      u.roles.includes('Branch Manager')
        ? this.branches.filter((b) => u.branchIds.includes(b.branch_id))
        : this.branches;

    const passkeyCount = this.passkeys.filter(
      (p) => p.user_id === userId && !p.revoked_at
    ).length;

    return {
      user: u.identity,
      roles: u.roles,
      isPrimarySuperAdmin: Boolean(u.isPrimarySuperAdmin),
      loginUsername: u.loginUsername ?? null,
      rolePermissions: Array.from(perms),
      branchScoped: u.roles.includes('Branch Manager'),
      assignedBranches,
      overrides: u.overrides,
      permissionVersion: u.permissionVersion,
      mfaEnforced: u.mfaEnforced,
      lastLoginAt: u.lastLoginAt,
      lastLoginIp: u.lastLoginIp,
      passkeyCount,
    };
  }

  async lookupPrimarySuperAdminByUsername(username: string) {
    const clean = username.trim().toLowerCase();
    for (const u of this.users.values()) {
      if (
        u.isPrimarySuperAdmin &&
        u.loginUsername?.toLowerCase() === clean &&
        u.identity.email &&
        u.identity.status === 'Active'
      ) {
        return {
          userId: u.identity.user_id,
          email: u.identity.email,
          loginUsername: u.loginUsername,
        };
      }
    }
    return null;
  }

  async recordLoginEvent(event: {
    userId: string | null;
    email: string | null;
    surface?: string | null;
    outcome: LoginEventOutcome;
    mfaMethod?: string | null;
    ipAddress?: string | null;
    userAgent?: string | null;
    failureReason?: string | null;
  }) {
    this.loginEvents.unshift({
      event_id: randomUUID(),
      user_id: event.userId,
      email: event.email,
      surface: event.surface ?? null,
      outcome: event.outcome,
      mfa_method: event.mfaMethod ?? null,
      ip_address: event.ipAddress ?? null,
      user_agent: event.userAgent ?? null,
      failure_reason: event.failureReason ?? null,
      created_at: new Date().toISOString(),
    });
    if (event.userId && event.outcome === 'Success') {
      const u = this.users.get(event.userId);
      if (u) {
        u.lastLoginAt = new Date().toISOString();
        u.lastLoginIp = event.ipAddress ?? null;
      }
    }
  }

  async listLoginEvents(limit = 100): Promise<AdminLoginEventRecord[]> {
    return this.loginEvents.slice(0, limit);
  }

  async checkAndRegisterDevice(input: {
    userId: string;
    fingerprint: string;
  }): Promise<{ isNewDevice: boolean }> {
    const u = this.users.get(input.userId);
    if (!u) return { isNewDevice: false };
    const existing = u.devices ?? [];
    const isNewDevice = existing.length > 0 && !existing.includes(input.fingerprint);
    if (!existing.includes(input.fingerprint)) {
      u.devices = [input.fingerprint, ...existing].slice(0, 15);
    }
    return { isNewDevice };
  }

  async createAdminSession(input: {
    userId: string;
    deviceLabel?: string;
    ipAddress?: string | null;
    permissionVersion: number;
    stepUpExpiresAt: string | null;
    expiresAt: string;
  }): Promise<AdminSessionRecord> {
    const record: AdminSessionRecord = {
      session_id: randomUUID(),
      user_id: input.userId,
      app_scope: 'admin_web',
      ip_address: input.ipAddress ?? null,
      device_label: input.deviceLabel ?? null,
      permission_version_snapshot: input.permissionVersion,
      step_up_expires_at: input.stepUpExpiresAt,
      revoked_at: null,
      revoked_by: null,
      created_at: new Date().toISOString(),
      expires_at: input.expiresAt,
    };
    this.sessions.set(record.session_id, record);
    return record;
  }

  async getAdminSession(sessionId: string) {
    return this.sessions.get(sessionId) ?? null;
  }

  async refreshSessionStepUp(sessionId: string, stepUpExpiresAt: string) {
    const s = this.sessions.get(sessionId);
    if (s) s.step_up_expires_at = stepUpExpiresAt;
  }

  async revokeSession(sessionId: string, revokedBy: string) {
    const s = this.sessions.get(sessionId);
    if (s) {
      s.revoked_at = new Date().toISOString();
      s.revoked_by = revokedBy;
    }
  }

  async listSessions(userId?: string) {
    const list = Array.from(this.sessions.values());
    return userId ? list.filter((s) => s.user_id === userId) : list;
  }

  async writeAuditLog(entry: AuditWriteInput) {
    this.auditLogs.unshift({
      audit_id: randomUUID(),
      user_id: entry.userId,
      action: entry.action,
      entity_type: entry.entityType,
      entity_id: entry.entityId ?? null,
      details: entry.details ?? null,
      ip_address: entry.ipAddress ?? null,
      created_at: new Date().toISOString(),
    });
  }

  async listAuditLogs(filters: { action?: string; userId?: string; limit?: number }) {
    return this.auditLogs
      .filter((l) => (!filters.action || l.action.includes(filters.action)) && (!filters.userId || l.user_id === filters.userId))
      .slice(0, filters.limit ?? 100);
  }

  async getDashboardMetrics(branchFilter: string[] | null): Promise<DashboardMetrics> {
    const visibleBranches = branchFilter
      ? this.branches.filter((b) => branchFilter.includes(b.branch_id))
      : this.branches;
    const workers = branchFilter
      ? this.workers.filter((w) => w.branch_id && branchFilter.includes(w.branch_id))
      : this.workers;
    const bookings = branchFilter
      ? this.bookings.filter((b) => b.branch_id && branchFilter.includes(b.branch_id))
      : this.bookings;
    const payments = branchFilter
      ? this.payments.filter((p) => p.branch_id && branchFilter.includes(p.branch_id))
      : this.payments;
    const verifications = branchFilter
      ? this.verifications.filter((v) => v.branch_id && branchFilter.includes(v.branch_id))
      : this.verifications;
    const disputes = branchFilter
      ? this.disputes.filter((d) => d.branch_id && branchFilter.includes(d.branch_id))
      : this.disputes;

    return {
      totalCustomers: (await this.listCustomers({ branchFilter })).length,
      totalWorkers: workers.length,
      verifiedWorkers: workers.filter((w) => w.verification_status === 'Verified').length,
      pendingVerifications: verifications.filter((v) => v.status === 'Pending').length,
      activeBookings: bookings.filter((b) => !['Completed', 'Canceled', 'Cancelled', 'Rejected'].includes(b.status)).length,
      openDisputes: disputes.filter((d) => !['Resolved', 'Dismissed'].includes(d.status)).length,
      completedPaymentsVolume: payments.reduce((sum, p) => sum + p.total_amount, 0),
      pendingFinancialApprovals: this.approvals.filter((a) => a.status === 'Pending').length,
      openSecurityIncidents: this.incidents.filter((i) => !['Resolved', 'Closed'].includes(i.status)).length,
      branchBreakdown: visibleBranches.map((b) => ({
        branch_id: b.branch_id,
        code: b.code,
        name: b.name,
        activeBookings: bookings.filter((bk) => bk.branch_id === b.branch_id && !['Completed', 'Canceled', 'Cancelled', 'Rejected'].includes(bk.status)).length,
        workersCount: workers.filter((w) => w.branch_id === b.branch_id).length,
        volumeBdt: payments.filter((p) => p.branch_id === b.branch_id).reduce((s, p) => s + p.total_amount, 0),
      })),
      recentAuditLogs: this.auditLogs.slice(0, 10),
    };
  }

  async globalSearch(query: string, branchFilter: string[] | null) {
    const q = query.toLowerCase();
    const branches = (await this.listBranches(branchFilter))
      .filter((b) => b.name.toLowerCase().includes(q) || b.code.toLowerCase().includes(q))
      .map((b) => ({ type: 'branch' as const, id: b.branch_id, title: b.name, subtitle: b.code, href: '/branches' }));
    const workers = (await this.listWorkers({ branchFilter, search: q }))
      .map((w) => ({ type: 'worker' as const, id: w.worker_profile_id, title: w.full_name, subtitle: w.title, href: '/workers' }));
    return [...branches, ...workers];
  }

  async listBranches(branchFilter: string[] | null) {
    return branchFilter
      ? this.branches.filter((b) => branchFilter.includes(b.branch_id))
      : [...this.branches];
  }

  async createBranch(input: { name: string; code: string; description?: string; managerId?: string | null }) {
    const b: BranchSummary = {
      branch_id: randomUUID(),
      name: input.name,
      code: input.code,
      description: input.description ?? null,
      manager_id: input.managerId ?? null,
      is_active: true,
      created_at: new Date().toISOString(),
    };
    this.branches.push(b);
    return b;
  }

  async updateBranch(branchId: string, patch: { name?: string; description?: string | null; isActive?: boolean; managerId?: string | null }) {
    const b = this.branches.find((x) => x.branch_id === branchId);
    if (!b) throw new Error('Branch not found');
    if (patch.name !== undefined) b.name = patch.name;
    if (patch.description !== undefined) b.description = patch.description;
    if (patch.isActive !== undefined) b.is_active = patch.isActive;
    if (patch.managerId !== undefined) b.manager_id = patch.managerId;
    return b;
  }

  async listCustomers(filters: { branchFilter: string[] | null; customerType?: string; search?: string }): Promise<CustomerDirectoryItem[]> {
    const all: CustomerDirectoryItem[] = [];
    for (const u of this.users.values()) {
      if (u.roles.length > 0) continue;
      const clientBookings = this.bookings.filter((b) => b.client_id === u.identity.user_id);
      const bIds = clientBookings.map((b) => b.branch_id).filter((x): x is string => Boolean(x));
      if (filters.branchFilter && !bIds.some((id) => filters.branchFilter?.includes(id))) continue;
      const isBiz = u.identity.user_id === TEST_IDS.users.customerBusiness;
      const cType: CustomerDirectoryItem['customer_type'] = isBiz ? 'Business Client' : 'Individual';
      if (filters.customerType && filters.customerType !== cType) continue;
      if (filters.search && !u.identity.full_name.toLowerCase().includes(filters.search.toLowerCase())) continue;
      all.push({
        user_id: u.identity.user_id,
        full_name: u.identity.full_name,
        email: u.identity.email,
        phone: u.identity.phone,
        status: u.identity.status,
        account_status: u.identity.account_status || 'active',
        location: u.identity.location,
        customer_type: cType,
        company_name: isBiz ? 'Delta Garments Ltd.' : null,
        trade_license: isBiz ? 'TL-88921' : null,
        booking_count: clientBookings.length,
        branch_ids: bIds,
        created_at: u.identity.created_at,
      });
    }
    return all;
  }

  async updateCustomer(customerId: string, patch: { fullName?: string; location?: string; accountStatus?: string }) {
    const u = this.users.get(customerId);
    if (!u) throw new Error('Customer not found');
    if (patch.fullName) u.identity.full_name = patch.fullName;
    if (patch.location) u.identity.location = patch.location;
    if (patch.accountStatus) {
      u.identity.account_status = patch.accountStatus;
      u.identity.status = patch.accountStatus === 'active' ? 'Active' : 'Suspended';
    }
    return (await this.listCustomers({ branchFilter: null })).find((c) => c.user_id === customerId)!;
  }

  async listWorkers(filters: { branchFilter: string[] | null; verificationStatus?: string; search?: string }) {
    return this.workers.filter((w) => {
      if (filters.branchFilter && (!w.branch_id || !filters.branchFilter.includes(w.branch_id))) return false;
      if (filters.verificationStatus && w.verification_status !== filters.verificationStatus) return false;
      if (filters.search && !w.full_name.toLowerCase().includes(filters.search.toLowerCase())) return false;
      return true;
    });
  }

  async updateWorker(workerProfileId: string, action: 'suspend' | 'reactivate' | 'assign_branch', branchId?: string) {
    const w = this.workers.find((x) => x.worker_profile_id === workerProfileId);
    if (!w) throw new Error('Worker not found');
    if (action === 'suspend') w.account_status = 'suspended';
    if (action === 'reactivate') w.account_status = 'active';
    if (action === 'assign_branch' && branchId) {
      w.branch_id = branchId;
      w.branch_name = this.branches.find((b) => b.branch_id === branchId)?.name ?? null;
    }
    return w;
  }

  async listVerifications(filters: { branchFilter: string[] | null; status?: string }) {
    return this.verifications.filter((v) => {
      if (filters.branchFilter && (!v.branch_id || !filters.branchFilter.includes(v.branch_id))) return false;
      if (filters.status && v.status !== filters.status) return false;
      return true;
    });
  }

  async getVerificationById(verificationId: string) {
    return this.verifications.find((v) => v.verification_id === verificationId) ?? null;
  }

  async decideVerification(input: { verificationId: string; adminUserId: string; decision: 'Approved' | 'Rejected'; reviewNotes: string }) {
    const v = await this.getVerificationById(input.verificationId);
    if (!v) throw new Error('Verification not found');
    v.status = input.decision;
    v.reviewed_by = input.adminUserId;
    v.review_notes = input.reviewNotes;
    v.reviewed_at = new Date().toISOString();
    const w = this.workers.find((x) => x.worker_profile_id === v.worker_profile_id);
    if (w) w.verification_status = input.decision === 'Approved' ? 'Verified' : 'Rejected';
    return v;
  }

  async createVerificationSignedUrl(fileUrlOrPath: string) {
    return `https://signed.skavia.test/storage/v1/object/sign/verifications/${encodeURIComponent(fileUrlOrPath)}?token=60s-test-token`;
  }

  async listBookings(filters: { branchFilter: string[] | null; status?: string }) {
    return this.bookings.filter((b) => {
      if (filters.branchFilter && (!b.branch_id || !filters.branchFilter.includes(b.branch_id))) return false;
      if (filters.status && b.status !== filters.status) return false;
      return true;
    });
  }

  async updateBooking(bookingId: string, patch: { action: 'assign_worker' | 'reschedule' | 'cancel' | 'complete'; workerProfileId?: string; scheduledAt?: string; reason: string; actorUserId: string }) {
    const b = this.bookings.find((x) => x.service_request_id === bookingId);
    if (!b) throw new Error('Booking not found');
    if (patch.action === 'assign_worker' && patch.workerProfileId) {
      b.worker_profile_id = patch.workerProfileId;
      b.worker_name = this.workers.find((w) => w.worker_profile_id === patch.workerProfileId)?.full_name ?? b.worker_name;
      b.status = 'Accepted';
    }
    if (patch.action === 'cancel') {
      b.status = 'Canceled';
      b.cancellation_reason = patch.reason;
    }
    if (patch.action === 'complete') b.status = 'Completed';
    if (patch.action === 'reschedule' && patch.scheduledAt) b.scheduled_at = patch.scheduledAt;
    return b;
  }

  async listProjects(branchFilter: string[] | null) {
    return branchFilter
      ? this.projects.filter((p) => p.branch_id && branchFilter.includes(p.branch_id))
      : this.projects;
  }

  async assembleProjectTeam(input: {
    projectId: string;
    teamName: string;
    members: Array<{ workerProfileId: string; roleInTeam: string; isTeamLeader: boolean }>;
    initialTasks: Array<{ title: string; description?: string; priority: 'Low' | 'Medium' | 'High'; deadline?: string; assignedWorkerProfileId?: string }>;
  }) {
    const p = this.projects.find((x) => x.project_id === input.projectId);
    if (!p) throw new Error('Project not found');
    p.teams.push({
      team_id: randomUUID(),
      name: input.teamName,
      status: 'Active',
      members: input.members.map((m) => ({
        team_member_id: randomUUID(),
        worker_profile_id: m.workerProfileId,
        worker_name: this.workers.find((w) => w.worker_profile_id === m.workerProfileId)?.full_name ?? 'Specialist',
        role_in_team: m.roleInTeam,
        is_team_leader: m.isTeamLeader,
      })),
    });
    for (const t of input.initialTasks) {
      p.tasks.push({
        task_id: randomUUID(),
        title: t.title,
        status: 'Pending',
        priority: t.priority,
        deadline: t.deadline ?? null,
      });
    }
    return p;
  }

  async listDisputes(filters: { branchFilter: string[] | null; status?: string }) {
    return this.disputes.filter((d) => {
      if (filters.branchFilter && (!d.branch_id || !filters.branchFilter.includes(d.branch_id))) return false;
      if (filters.status && d.status !== filters.status) return false;
      return true;
    });
  }

  async resolveDispute(input: { disputeId: string; adminUserId: string; status: 'Resolved' | 'Dismissed'; resolution: string; noteType: 'Internal' | 'Decision' | 'RefundRecommendation' }) {
    const d = this.disputes.find((x) => x.dispute_id === input.disputeId);
    if (!d) throw new Error('Dispute not found');
    d.status = input.status;
    d.resolution = input.resolution;
    d.resolved_at = new Date().toISOString();
    d.assigned_admin_id = input.adminUserId;
    d.notes.push({
      note_id: randomUUID(),
      author_id: input.adminUserId,
      note_type: input.noteType,
      content: input.resolution,
      created_at: new Date().toISOString(),
    });
    return d;
  }

  async getServiceTaxonomy() {
    return this.taxonomy;
  }

  async mutateServiceTaxonomy(input: Record<string, unknown>) {
    if (input.type === 'category' && input.action === 'create') {
      const branchId = input.branchId ? String(input.branchId) : null;
      this.taxonomy.categories.push({
        category_id: randomUUID(),
        branch_id: branchId,
        branch_name: branchId
          ? this.branches.find((b) => b.branch_id === branchId)?.name ?? null
          : null,
        name: String(input.name),
        slug: String(input.slug ?? 'category'),
        icon_name: String(input.iconName ?? 'build'),
        is_active: true,
      });
    } else if (input.type === 'category' && input.action === 'toggle' && input.id) {
      const cat = this.taxonomy.categories.find((c) => c.category_id === String(input.id));
      if (cat) cat.is_active = Boolean(input.isActive);
    } else if (input.type === 'service' && input.action === 'create') {
      this.taxonomy.services.push({
        service_id: randomUUID(),
        category_id: String(input.categoryId),
        name: String(input.name),
        description: null,
        base_price: Number(input.basePrice ?? 0),
      });
    } else if (input.type === 'skill' && input.action === 'create') {
      this.taxonomy.skills.push({
        skill_id: randomUUID(),
        category_id: input.categoryId ? String(input.categoryId) : null,
        service_id: null,
        name: String(input.name),
      });
    }
  }

  async getFinanceSnapshot(branchFilter: string[] | null): Promise<FinanceLedgerSnapshot> {
    const payments = branchFilter
      ? this.payments.filter((p) => p.branch_id && branchFilter.includes(p.branch_id))
      : this.payments;
    const approvals = branchFilter
      ? this.approvals.filter((a) => !a.branch_id || branchFilter.includes(a.branch_id))
      : this.approvals;
    const completedTotal = payments.reduce((s, p) => s + p.total_amount, 0);
    const feeTotal = payments.reduce((s, p) => s + p.skavia_fee, 0);
    return {
      summary: {
        completedPaymentsTotal: completedTotal,
        skaviaFeeTotal: feeTotal,
        workerEarningsTotal: completedTotal - feeTotal,
        pendingApprovalsCount: approvals.filter((a) => a.status === 'Pending').length,
        pendingPayoutsAmount: 0,
        pendingRefundsAmount: 0,
      },
      payments,
      approvals,
      commissionRules: this.commissionRules,
    };
  }

  async createApprovalRequest(input: {
    actionType: 'PAYOUT_APPROVAL' | 'REFUND_APPROVAL' | 'COMMISSION_CHANGE' | 'SYSTEM_CONFIG';
    entityType: string;
    entityId: string;
    branchId: string | null;
    payload: Record<string, unknown>;
    idempotencyKey: string;
    makerUserId: string;
    makerReason: string;
  }) {
    const existing = this.approvals.find((a) => a.idempotency_key === input.idempotencyKey);
    if (existing) return { approval_id: existing.approval_id, status: existing.status };

    const approval_id = randomUUID();
    this.approvals.unshift({
      approval_id,
      action_type: input.actionType,
      entity_type: input.entityType,
      entity_id: input.entityId,
      branch_id: input.branchId,
      payload: input.payload,
      idempotency_key: input.idempotencyKey,
      status: 'Pending',
      maker_user_id: input.makerUserId,
      checker_user_id: null,
      maker_reason: input.makerReason,
      checker_notes: null,
      created_at: new Date().toISOString(),
      decided_at: null,
    });
    return { approval_id, status: 'Pending' };
  }

  async decideApprovalRequest(input: {
    approvalId: string;
    checkerUserId: string;
    decision: 'Approved' | 'Rejected';
    checkerNotes: string;
  }) {
    const a = this.approvals.find((x) => x.approval_id === input.approvalId);
    if (!a) throw new Error('Approval not found');
    a.status = input.decision;
    a.checker_user_id = input.checkerUserId;
    a.checker_notes = input.checkerNotes;
    a.decided_at = new Date().toISOString();
    return { approval_id: a.approval_id, status: a.status };
  }

  async runReconciliation() {
    return { run_id: randomUUID(), status: 'Matched', variance_amount: 0 };
  }

  async listAdmins(): Promise<AdminAccountRecord[]> {
    const out: AdminAccountRecord[] = [];
    for (const u of this.users.values()) {
      if (u.roles.length === 0) continue;
      const passkeyEnrolled = this.passkeys.some(
        (p) => p.user_id === u.identity.user_id && !p.revoked_at
      );
      out.push({
        ...u.identity,
        roles: u.roles,
        isPrimarySuperAdmin: Boolean(u.isPrimarySuperAdmin),
        loginUsername: u.loginUsername ?? null,
        assignedBranches: u.roles.includes('Branch Manager')
          ? this.branches.filter((b) => u.branchIds.includes(b.branch_id))
          : this.branches,
        permissionVersion: u.permissionVersion,
        mfaEnforced: u.mfaEnforced,
        passkeyEnrolled,
        lastLoginAt: u.lastLoginAt,
        lastLoginIp: u.lastLoginIp,
        overrides: u.overrides,
      });
    }
    return out;
  }

  async provisionAdmin(input: { userId: string; email: string; fullName: string; roleName: AdminRoleName; branchIds: string[] }) {
    if (input.roleName === 'Super Admin') {
      throw new AuthorizationError(
        'SINGLE_SUPERADMIN_ENFORCED',
        'Additional Super Admin accounts cannot be provisioned.',
        403
      );
    }
    this.users.set(input.userId, {
      identity: {
        user_id: input.userId,
        full_name: input.fullName,
        email: input.email,
        phone: null,
        status: 'Active',
        account_status: 'active',
        verification_status: 'Verified',
        active_mode: 'admin',
        location: 'Dhaka',
        created_at: new Date().toISOString(),
      },
      roles: [input.roleName],
      isPrimarySuperAdmin: false,
      loginUsername: null,
      branchIds: input.branchIds,
      overrides: [],
      permissionVersion: 1,
      mfaEnforced: true,
      lastLoginAt: null,
      lastLoginIp: null,
    });
    return (await this.listAdmins()).find((a) => a.user_id === input.userId)!;
  }

  async updateAdminPermissions(targetUserId: string, input: Record<string, unknown>) {
    const u = this.users.get(targetUserId);
    if (!u) throw new Error('Admin not found');
    if (u.isPrimarySuperAdmin) {
      throw new AuthorizationError(
        'PRIMARY_SUPERADMIN_PROTECTED',
        'The primary Super Admin account cannot be modified, demoted, suspended, or deleted.',
        403
      );
    }
    if (input.roleName === 'Super Admin') {
      throw new AuthorizationError(
        'SINGLE_SUPERADMIN_ENFORCED',
        'Cannot escalate internal admin accounts to Super Admin.',
        403
      );
    }
    if (typeof input.roleName === 'string') {
      u.roles = [input.roleName as AdminRoleName];
    }
    if (Array.isArray(input.branchIds)) {
      u.branchIds = input.branchIds.map(String);
    }
    if (input.override && typeof input.override === 'object') {
      const ov = input.override as { permissionKey: PermissionKey; effect: 'ALLOW' | 'DENY'; expiresAt?: string | null };
      u.overrides = [
        ...u.overrides.filter((x) => x.permission_key !== ov.permissionKey),
        {
          permission_key: ov.permissionKey,
          effect: ov.effect,
          expires_at: ov.expiresAt ?? null,
        },
      ];
    }
    if (typeof input.suspendReason === 'string') {
      u.identity.account_status = 'suspended';
      u.identity.status = 'Suspended';
    }
    if (input.reactivate === true) {
      u.identity.account_status = 'active';
      u.identity.status = 'Active';
    }
    u.permissionVersion += 1;
    return (await this.listAdmins()).find((a) => a.user_id === targetUserId)!;
  }

  async createAdminInvitation(input: {
    fullName: string;
    email: string;
    roleName: InvitableAdminRole;
    branchIds: string[];
    permissionProfile: Array<{ permissionKey: PermissionKey; effect: 'ALLOW' | 'DENY' }>;
    note?: string;
    tokenHash: string;
    requireApproval: boolean;
    expiresAt: string;
    invitedBy: string;
  }): Promise<AdminInvitationRecord> {
    const inv: AdminInvitationRecord = {
      invitation_id: randomUUID(),
      full_name: input.fullName,
      email: input.email.toLowerCase(),
      role_name: input.roleName,
      assigned_branch_ids: input.branchIds,
      assigned_branch_names: input.branchIds.map(
        (id) => this.branches.find((b) => b.branch_id === id)?.name || id
      ),
      permission_profile: input.permissionProfile,
      note: input.note ?? null,
      token_hash: input.tokenHash,
      status: 'Invited',
      delivery_status: 'Pending',
      delivery_error: null,
      require_approval: input.requireApproval,
      invited_by: input.invitedBy,
      approved_by: null,
      activated_user_id: null,
      expires_at: input.expiresAt,
      sent_at: null,
      opened_at: null,
      setup_started_at: null,
      approved_at: null,
      activated_at: null,
      revoked_at: null,
      created_at: new Date().toISOString(),
    };
    this.invitations.unshift(inv);
    return inv;
  }

  private refreshExpiredStatus(inv: AdminInvitationRecord): AdminInvitationRecord {
    const isExpired =
      inv.status !== 'Active' &&
      inv.status !== 'Revoked' &&
      inv.status !== 'Suspended' &&
      new Date(inv.expires_at).getTime() <= Date.now();
    return isExpired ? { ...inv, status: 'Expired' } : inv;
  }

  async listAdminInvitations(): Promise<AdminInvitationRecord[]> {
    return this.invitations.map((inv) => this.refreshExpiredStatus(inv));
  }

  async getInvitationById(invitationId: string): Promise<AdminInvitationRecord | null> {
    const inv = this.invitations.find((x) => x.invitation_id === invitationId);
    return inv ? this.refreshExpiredStatus(inv) : null;
  }

  async getInvitationByTokenHash(tokenHash: string): Promise<AdminInvitationRecord | null> {
    const inv = this.invitations.find((x) => x.token_hash === tokenHash);
    return inv ? this.refreshExpiredStatus(inv) : null;
  }

  async updateInvitationState(
    invitationId: string,
    patch: Partial<{
      token_hash: string;
      status: InvitationStatus;
      delivery_status: InvitationDeliveryStatus;
      delivery_error: string | null;
      approved_by: string | null;
      activated_user_id: string | null;
      expires_at: string;
      sent_at: string | null;
      opened_at: string | null;
      setup_started_at: string | null;
      approved_at: string | null;
      activated_at: string | null;
      revoked_at: string | null;
    }>
  ): Promise<AdminInvitationRecord> {
    const idx = this.invitations.findIndex((x) => x.invitation_id === invitationId);
    const existing = idx !== -1 ? this.invitations[idx] : undefined;
    if (!existing) throw new Error('Invitation not found');
    const updated: AdminInvitationRecord = {
      ...existing,
      ...patch,
    };
    this.invitations[idx] = updated;
    return this.refreshExpiredStatus(updated);
  }

  async activateInvitedAdmin(input: {
    invitationId: string;
    userId: string;
    email: string;
    fullName: string;
    status: 'PendingApproval' | 'Active';
  }): Promise<void> {
    const inv = this.invitations.find((x) => x.invitation_id === input.invitationId);
    if (!inv) throw new Error('Invitation not found');
    const active = input.status === 'Active';
    this.users.set(input.userId, {
      identity: {
        user_id: input.userId,
        full_name: input.fullName,
        email: input.email.toLowerCase(),
        phone: null,
        status: active ? 'Active' : 'Inactive',
        account_status: active ? 'active' : 'pending_approval',
        verification_status: 'Verified',
        active_mode: 'admin',
        location: 'Dhaka',
        created_at: new Date().toISOString(),
      },
      roles: [inv.role_name],
      isPrimarySuperAdmin: false,
      loginUsername: null,
      branchIds: inv.assigned_branch_ids,
      overrides: inv.permission_profile.map((o) => ({
        permission_key: o.permissionKey,
        effect: o.effect,
        expires_at: null,
      })),
      permissionVersion: 1,
      mfaEnforced: true,
      lastLoginAt: null,
      lastLoginIp: null,
    });
    const now = new Date().toISOString();
    await this.updateInvitationState(input.invitationId, {
      status: input.status,
      activated_user_id: input.userId,
      activated_at: active ? now : null,
      setup_started_at: inv.setup_started_at ?? now,
    });
  }

  async createWebAuthnChallenge(input: {
    userId: string | null;
    invitationId?: string | null;
    challenge: string;
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate';
    expiresAt: string;
  }): Promise<WebAuthnChallengeRecord> {
    const rec: WebAuthnChallengeRecord = {
      challenge_id: randomUUID(),
      user_id: input.userId,
      invitation_id: input.invitationId ?? null,
      challenge: input.challenge,
      purpose: input.purpose,
      expires_at: input.expiresAt,
      consumed_at: null,
    };
    this.webauthnChallenges.set(rec.challenge_id, rec);
    return rec;
  }

  async consumeWebAuthnChallenge(
    challengeId: string,
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate'
  ): Promise<WebAuthnChallengeRecord | null> {
    const rec = this.webauthnChallenges.get(challengeId);
    if (!rec || rec.purpose !== purpose || rec.consumed_at) return null;
    if (new Date(rec.expires_at).getTime() <= Date.now()) return null;
    rec.consumed_at = new Date().toISOString();
    return rec;
  }

  async savePasskeyCredential(input: {
    credentialId: string;
    userId: string;
    friendlyName: string;
    publicKey: string;
    counter: number;
    transports: string[];
    deviceType: string;
    backedUp: boolean;
    aaguid: string | null;
  }): Promise<AdminPasskeyRecord> {
    const rec: AdminPasskeyRecord = {
      credential_id: input.credentialId,
      user_id: input.userId,
      friendly_name: input.friendlyName,
      public_key: input.publicKey,
      counter: input.counter,
      transports: input.transports,
      device_type: input.deviceType,
      backed_up: input.backedUp,
      aaguid: input.aaguid,
      last_used_at: null,
      revoked_at: null,
      created_at: new Date().toISOString(),
    };
    this.passkeys = [
      rec,
      ...this.passkeys.filter((p) => p.credential_id !== input.credentialId),
    ];
    return rec;
  }

  async listPasskeysForUser(userId: string): Promise<AdminPasskeyRecord[]> {
    return this.passkeys.filter((p) => p.user_id === userId);
  }

  async listAllPasskeys(): Promise<AdminPasskeyRecord[]> {
    return this.passkeys;
  }

  async getPasskeyById(credentialId: string): Promise<AdminPasskeyRecord | null> {
    return (
      this.passkeys.find((p) => p.credential_id === credentialId && !p.revoked_at) ?? null
    );
  }

  async touchPasskeyUsage(credentialId: string, newCounter: number): Promise<void> {
    const rec = this.passkeys.find((p) => p.credential_id === credentialId);
    if (rec) {
      rec.counter = newCounter;
      rec.last_used_at = new Date().toISOString();
    }
  }

  async revokePasskey(credentialId: string): Promise<void> {
    const rec = this.passkeys.find((p) => p.credential_id === credentialId);
    if (rec) rec.revoked_at = new Date().toISOString();
  }

  async setRecoveryCodeHashes(userId: string, hashes: string[]): Promise<void> {
    const u = this.users.get(userId);
    if (u) {
      u.recoveryHashes = hashes;
      u.recoveryGeneratedAt = new Date().toISOString();
    }
  }

  async getRecoveryCodeHashes(userId: string) {
    const u = this.users.get(userId);
    return {
      hashes: u?.recoveryHashes ?? [],
      generatedAt: u?.recoveryGeneratedAt ?? null,
    };
  }

  async listIncidents() {
    return this.incidents;
  }

  async createIncident(input: { title: string; severity: string; summary: string; affectedUserId?: string; branchId?: string }) {
    const inc: SecurityIncidentItem = {
      incident_id: randomUUID(),
      title: input.title,
      severity: input.severity,
      status: 'Open',
      source: 'Manual',
      affected_user_id: input.affectedUserId ?? null,
      branch_id: input.branchId ?? null,
      summary: input.summary,
      created_at: new Date().toISOString(),
      resolved_at: null,
    };
    this.incidents.unshift(inc);
    return inc;
  }

  async updateIncident(input: { incidentId: string; status: string }) {
    const inc = this.incidents.find((x) => x.incident_id === input.incidentId);
    if (!inc) throw new Error('Incident not found');
    inc.status = input.status;
    if (input.status === 'Resolved' || input.status === 'Closed') {
      inc.resolved_at = new Date().toISOString();
    }
    return inc;
  }

  async getSystemSettings() {
    return this.settings;
  }

  async upsertSystemSetting(key: string, value: unknown) {
    const existing = this.settings.find((s) => s.setting_key === key);
    if (existing) {
      existing.setting_value = value;
      existing.updated_at = new Date().toISOString();
    } else {
      this.settings.push({
        setting_key: key,
        setting_value: value,
        description: null,
        updated_at: new Date().toISOString(),
      });
    }
  }

  async listBackupLogs() {
    return this.backupLogs;
  }

  async getReleaseSigningPolicy(): Promise<ReleaseSigningPolicyDto> {
    return { ...this.releaseSigningPolicy };
  }

  async upsertReleaseSigningPolicy(input: {
    expectedPackageName: string;
    pinnedSigningCertSha256: string | null;
    actorUserId: string;
  }): Promise<ReleaseSigningPolicyDto> {
    this.releaseSigningPolicy = {
      expectedPackageName: input.expectedPackageName.trim() || DEFAULT_SKAVIA_PACKAGE_NAME,
      pinnedSigningCertSha256: input.pinnedSigningCertSha256
        ? input.pinnedSigningCertSha256.trim().toLowerCase()
        : null,
      updatedAt: new Date().toISOString(),
      updatedBy: input.actorUserId,
    };
    return { ...this.releaseSigningPolicy };
  }

  async createApkUploadSession(input: { fileName: string; channel: AppReleaseChannel }) {
    const safeName = input.fileName.replace(/[^A-Za-z0-9._-]+/g, '_');
    const storagePath = `staging/${input.channel}/${Date.now()}-${randomUUID()}-${safeName}`;
    return {
      storagePath,
      signedUploadUrl: `memory://upload/${encodeURIComponent(storagePath)}`,
      token: randomUUID(),
      bucket: 'app-releases',
    };
  }

  async uploadApkObjectDirect(input: {
    storagePath: string;
    bytes: Buffer;
    contentType?: string;
  }): Promise<void> {
    this.releaseBlobs.set(input.storagePath, Buffer.from(input.bytes));
  }

  async readApkObjectBytes(storagePath: string): Promise<Buffer> {
    const blob = this.releaseBlobs.get(storagePath);
    if (!blob) {
      throw new ReleaseValidationError(
        'APK_OBJECT_NOT_FOUND',
        'Uploaded APK binary was not found in private storage.',
        404
      );
    }
    return blob;
  }

  async listReleases(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
    status?: AppReleaseStatus;
  }): Promise<AppReleaseDto[]> {
    return this.releases
      .filter((r) => {
        if (filters?.platform && r.platform !== filters.platform) return false;
        if (filters?.channel && r.channel !== filters.channel) return false;
        if (filters?.status && r.status !== filters.status) return false;
        return true;
      })
      .sort((a, b) => b.build_number - a.build_number);
  }

  async getReleaseById(releaseId: string): Promise<AppReleaseDto | null> {
    return this.releases.find((r) => r.release_id === releaseId) ?? null;
  }

  async getCurrentPublishedRelease(params: {
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
  }): Promise<AppReleaseDto | null> {
    return (
      this.releases.find(
        (r) =>
          r.platform === params.platform &&
          r.channel === params.channel &&
          r.status === 'published' &&
          r.is_current
      ) ?? null
    );
  }

  async createReleaseRecord(input: {
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
    packageName: string;
    versionName: string;
    buildNumber: number;
    minSupportedBuild: number;
    minSdkVersion: number | null;
    targetSdkVersion: number | null;
    releaseNotes: string;
    isMandatory: boolean;
    notifyUsers: boolean;
    status: AppReleaseStatus;
    storagePath: string;
    fileName: string;
    fileSizeBytes: number;
    sha256Checksum: string;
    signingCertSha256: string;
    signingSchemes: string[];
    actorUserId: string;
  }): Promise<AppReleaseDto> {
    const now = new Date().toISOString();
    const record: AppReleaseDto = {
      release_id: randomUUID(),
      platform: input.platform,
      channel: input.channel,
      package_name: input.packageName,
      version_name: input.versionName,
      build_number: input.buildNumber,
      min_supported_build: input.minSupportedBuild,
      min_sdk_version: input.minSdkVersion,
      target_sdk_version: input.targetSdkVersion,
      release_notes: input.releaseNotes,
      is_mandatory: input.isMandatory,
      status: input.status,
      is_current: false,
      storage_bucket: 'app-releases',
      storage_path: input.storagePath,
      file_name: input.fileName,
      file_size_bytes: input.fileSizeBytes,
      sha256_checksum: input.sha256Checksum,
      signing_cert_sha256: input.signingCertSha256,
      signing_schemes: input.signingSchemes,
      notify_users: input.notifyUsers,
      notifications_dispatched_at: null,
      rolled_back_from_release_id: null,
      suspension_reason: null,
      created_by: input.actorUserId,
      validated_by: input.status === 'validated' ? input.actorUserId : null,
      published_by: null,
      validated_at: input.status === 'validated' ? now : null,
      published_at: null,
      suspended_at: null,
      archived_at: null,
      created_at: now,
      updated_at: now,
    };
    this.releases.unshift(record);
    return record;
  }

  async markReleaseValidated(input: {
    releaseId: string;
    packageName: string;
    versionName: string;
    buildNumber: number;
    minSdkVersion: number | null;
    targetSdkVersion: number | null;
    fileSizeBytes: number;
    sha256Checksum: string;
    signingCertSha256: string;
    signingSchemes: string[];
    actorUserId: string;
  }): Promise<AppReleaseDto> {
    const rec = this.releases.find((r) => r.release_id === input.releaseId);
    if (!rec) throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
    const now = new Date().toISOString();
    rec.package_name = input.packageName;
    rec.version_name = input.versionName;
    rec.build_number = input.buildNumber;
    rec.min_sdk_version = input.minSdkVersion;
    rec.target_sdk_version = input.targetSdkVersion;
    rec.file_size_bytes = input.fileSizeBytes;
    rec.sha256_checksum = input.sha256Checksum;
    rec.signing_cert_sha256 = input.signingCertSha256;
    rec.signing_schemes = input.signingSchemes;
    rec.status = 'validated';
    rec.validated_by = input.actorUserId;
    rec.validated_at = now;
    rec.updated_at = now;
    return rec;
  }

  async publishRelease(input: {
    releaseId: string;
    actorUserId: string;
    notifyUsers?: boolean;
  }): Promise<{ release: AppReleaseDto; notifiedUsersCount: number }> {
    const rec = this.releases.find((r) => r.release_id === input.releaseId);
    if (!rec) throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
    const now = new Date().toISOString();
    for (const other of this.releases) {
      if (
        other.platform === rec.platform &&
        other.channel === rec.channel &&
        other.release_id !== rec.release_id
      ) {
        other.is_current = false;
      }
    }
    const shouldNotify = input.notifyUsers ?? rec.notify_users;
    rec.status = 'published';
    rec.is_current = true;
    rec.notify_users = shouldNotify;
    rec.published_by = input.actorUserId;
    rec.published_at = rec.published_at ?? now;
    rec.updated_at = now;
    let notifiedUsersCount = 0;
    if (shouldNotify && !rec.notifications_dispatched_at) {
      notifiedUsersCount = Array.from(this.users.values()).filter(
        (u) => !u.roles.includes('Super Admin') && !u.roles.includes('Company Admin') && !u.roles.includes('Branch Manager')
      ).length;
      rec.notifications_dispatched_at = now;
    }
    return { release: rec, notifiedUsersCount };
  }

  async suspendRelease(input: {
    releaseId: string;
    actorUserId: string;
    reason: string;
  }): Promise<AppReleaseDto> {
    const rec = this.releases.find((r) => r.release_id === input.releaseId);
    if (!rec) throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
    const now = new Date().toISOString();
    rec.status = 'suspended';
    rec.is_current = false;
    rec.suspension_reason = input.reason;
    rec.suspended_at = now;
    rec.updated_at = now;
    return rec;
  }

  async rollbackRelease(input: {
    targetReleaseId: string;
    actorUserId: string;
    reason: string;
  }): Promise<{ activeRelease: AppReleaseDto; suspendedReleaseId: string | null }> {
    const target = this.releases.find((r) => r.release_id === input.targetReleaseId);
    if (!target) throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Target release not found.', 404);
    if (target.status === 'draft') {
      throw new ReleaseValidationError('ROLLBACK_TARGET_UNVALIDATED', 'Cannot rollback to draft release.', 422);
    }
    const now = new Date().toISOString();
    const current = await this.getCurrentPublishedRelease({
      platform: target.platform,
      channel: target.channel,
    });
    if (current && current.release_id === target.release_id) {
      return { activeRelease: target, suspendedReleaseId: null };
    }
    if (current) {
      current.status = 'suspended';
      current.is_current = false;
      current.suspension_reason = `Rolled back to v${target.version_name} (#${target.build_number}): ${input.reason}`;
      current.suspended_at = now;
      current.updated_at = now;
    }
    target.status = 'published';
    target.is_current = true;
    target.rolled_back_from_release_id = current?.release_id ?? null;
    target.published_by = input.actorUserId;
    target.published_at = target.published_at ?? now;
    target.updated_at = now;
    return { activeRelease: target, suspendedReleaseId: current?.release_id ?? null };
  }

  async archiveRelease(input: { releaseId: string }): Promise<AppReleaseDto> {
    const rec = this.releases.find((r) => r.release_id === input.releaseId);
    if (!rec) throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
    if (rec.is_current && rec.status === 'published') {
      throw new ReleaseValidationError(
        'CANNOT_ARCHIVE_ACTIVE_RELEASE',
        'Cannot archive active published release.',
        409
      );
    }
    const now = new Date().toISOString();
    rec.status = 'archived';
    rec.is_current = false;
    rec.archived_at = now;
    rec.updated_at = now;
    return rec;
  }

  async deleteDraftRelease(input: { releaseId: string }): Promise<void> {
    const idx = this.releases.findIndex((r) => r.release_id === input.releaseId);
    const rec = idx >= 0 ? this.releases[idx] : undefined;
    if (!rec) throw new ReleaseValidationError('RELEASE_NOT_FOUND', 'Release not found.', 404);
    if (rec.status !== 'draft' && rec.status !== 'validated') {
      throw new ReleaseValidationError(
        'CANNOT_DELETE_HISTORICAL_RELEASE',
        'Cannot delete published, suspended, or archived release.',
        409
      );
    }
    this.releaseBlobs.delete(rec.storage_path);
    this.releases.splice(idx, 1);
  }

  async createPublishedApkSignedUrl(storagePath: string): Promise<string> {
    return `memory://download/${encodeURIComponent(storagePath)}`;
  }

  async recordReleaseTelemetryEvent(input: {
    releaseId?: string | null;
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
    installedBuild?: number | null;
    installedVersion?: string | null;
    targetBuild?: number | null;
    eventType: ReleaseTelemetryEventType;
    deviceFingerprintHash?: string | null;
    androidApiLevel?: number | null;
    userId?: string | null;
    metadata?: Record<string, unknown>;
  }): Promise<void> {
    this.releaseEvents.unshift({
      event_id: randomUUID(),
      release_id: input.releaseId ?? null,
      channel: input.channel,
      installed_build: input.installedBuild ?? null,
      installed_version: input.installedVersion ?? null,
      target_build: input.targetBuild ?? null,
      event_type: input.eventType,
      android_api_level: input.androidApiLevel ?? null,
      created_at: new Date().toISOString(),
    });
  }

  async getReleaseAnalytics(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
  }): Promise<AppReleaseAnalyticsDto> {
    const filtered = this.releaseEvents.filter(
      (ev) => !filters?.channel || ev.channel === filters.channel
    );
    const versionMap = new Map<string, { installedBuild: number; installedVersion: string; checkIns: number }>();
    let totalCheckIns = 0;
    let totalDownloadsStarted = 0;
    let totalDownloadsCompleted = 0;
    let totalChecksumVerified = 0;
    let totalChecksumFailed = 0;
    let totalInstallerLaunched = 0;
    let totalInstallFailed = 0;

    for (const ev of filtered) {
      if (ev.event_type === 'update_check' || ev.event_type === 'app_active') {
        totalCheckIns++;
        if (ev.installed_build != null) {
          const ver = ev.installed_version || `build-${ev.installed_build}`;
          const key = `${ev.installed_build}::${ver}`;
          const cur = versionMap.get(key) ?? {
            installedBuild: ev.installed_build,
            installedVersion: ver,
            checkIns: 0,
          };
          cur.checkIns += 1;
          versionMap.set(key, cur);
        }
      } else if (ev.event_type === 'download_started') totalDownloadsStarted++;
      else if (ev.event_type === 'download_completed') totalDownloadsCompleted++;
      else if (ev.event_type === 'checksum_verified') totalChecksumVerified++;
      else if (ev.event_type === 'checksum_failed') totalChecksumFailed++;
      else if (ev.event_type === 'installer_launched') totalInstallerLaunched++;
      else if (ev.event_type === 'install_failed') totalInstallFailed++;
    }

    return {
      totalCheckIns,
      totalDownloadsStarted,
      totalDownloadsCompleted,
      totalChecksumVerified,
      totalChecksumFailed,
      totalInstallerLaunched,
      totalInstallFailed,
      recentEvents: filtered.slice(0, 50),
      versionDistribution: Array.from(versionMap.values()).sort(
        (a, b) => b.installedBuild - a.installedBuild
      ),
    };
  }
}

