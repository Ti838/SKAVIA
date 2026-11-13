import type {
  AdminRoleName,
  AdminSessionContext,
  BranchSummary,
  InvitationDeliveryStatus,
  InvitationStatus,
  InvitableAdminRole,
  PermissionKey,
  PermissionOverrideRecord,
} from './contracts';

export type {
  AdminRoleName,
  AdminSessionContext,
  BranchSummary,
  InvitationDeliveryStatus,
  InvitationStatus,
  InvitableAdminRole,
  PermissionKey,
  PermissionOverrideRecord,
};

export interface AdminAccountDto {
  user_id: string;
  full_name: string;
  email: string | null;
  phone: string | null;
  status: string;
  account_status: string | null;
  verification_status: string | null;
  active_mode: string;
  location: string | null;
  created_at: string;
  roles: AdminRoleName[];
  isPrimarySuperAdmin: boolean;
  loginUsername: string | null;
  assignedBranches: BranchSummary[];
  permissionVersion: number;
  mfaEnforced: boolean;
  passkeyEnrolled: boolean;
  lastLoginAt: string | null;
  lastLoginIp: string | null;
  overrides: PermissionOverrideRecord[];
}

export interface AdminInvitationDto {
  invitation_id: string;
  full_name: string;
  email: string;
  role_name: InvitableAdminRole;
  assigned_branch_ids: string[];
  assigned_branch_names: string[];
  permission_profile: Array<{ permissionKey: PermissionKey; effect: 'ALLOW' | 'DENY' }>;
  note: string | null;
  status: InvitationStatus;
  delivery_status: InvitationDeliveryStatus;
  delivery_error: string | null;
  require_approval: boolean;
  invited_by: string;
  approved_by: string | null;
  activated_user_id: string | null;
  expires_at: string;
  sent_at: string | null;
  opened_at: string | null;
  setup_started_at: string | null;
  approved_at: string | null;
  activated_at: string | null;
  revoked_at: string | null;
  created_at: string;
}

export interface AdminPasskeyDto {
  credential_id: string;
  user_id: string;
  friendly_name: string;
  device_type: string;
  backed_up: boolean;
  transports: string[];
  last_used_at: string | null;
  revoked_at: string | null;
  created_at: string;
}

export interface AdminLoginEventDto {
  event_id: string;
  user_id: string | null;
  email: string | null;
  surface: string | null;
  outcome: string;
  mfa_method: string | null;
  ip_address: string | null;
  user_agent: string | null;
  failure_reason: string | null;
  created_at: string;
}

export interface AdminSessionDto {
  session_id: string;
  user_id: string;
  app_scope: string;
  ip_address: string | null;
  device_label: string | null;
  permission_version_snapshot: number;
  step_up_expires_at: string | null;
  revoked_at: string | null;
  revoked_by: string | null;
  created_at: string;
  expires_at: string;
}

export interface CustomerDirectoryDto {
  user_id: string;
  full_name: string;
  email: string | null;
  phone: string | null;
  status: string;
  account_status: string;
  location: string | null;
  customer_type: 'Individual' | 'Business Client' | 'Organization';
  company_name: string | null;
  trade_license: string | null;
  booking_count: number;
  branch_ids: string[];
  created_at: string;
}

export interface WorkerDirectoryDto {
  worker_profile_id: string;
  user_id: string;
  full_name: string;
  email: string | null;
  phone: string | null;
  branch_id: string | null;
  branch_name: string | null;
  category_id: string | null;
  category_name: string | null;
  title: string;
  location: string;
  expected_rate: number;
  verification_status: string;
  account_status: string;
  rating_average: number;
  total_reviews: number;
  completed_jobs: number;
  is_available: boolean;
  skills: string[];
  created_at: string;
}

export interface VerificationQueueDto {
  verification_id: string;
  worker_profile_id: string;
  worker_user_id: string;
  worker_name: string;
  branch_id: string | null;
  branch_name: string | null;
  document_type: string;
  document_number: string;
  document_file_url: string;
  status: 'Pending' | 'Approved' | 'Rejected';
  reviewed_by: string | null;
  review_notes: string | null;
  reviewed_at: string | null;
  created_at: string;
}

export interface BookingListDto {
  service_request_id: string;
  requirement_id: string | null;
  branch_id: string | null;
  branch_name: string | null;
  client_id: string;
  client_name: string;
  worker_profile_id: string;
  worker_name: string;
  status: string;
  scheduled_at: string | null;
  agreed_price: number;
  service_notes: string | null;
  cancellation_reason: string | null;
  created_at: string;
}

export interface ProjectSummaryDto {
  project_id: string;
  client_id: string;
  client_name: string;
  branch_id: string | null;
  branch_name: string | null;
  title: string;
  description: string | null;
  status: string;
  deadline: string | null;
  total_budget: number;
  teams: Array<{
    team_id: string;
    name: string;
    status: string;
    members: Array<{
      team_member_id: string;
      worker_profile_id: string;
      worker_name: string;
      role_in_team: string;
      is_team_leader: boolean;
    }>;
  }>;
  tasks: Array<{
    task_id: string;
    title: string;
    status: string;
    priority: string;
    deadline: string | null;
  }>;
}

export interface DisputeDto {
  dispute_id: string;
  complaint_id: string;
  branch_id: string | null;
  branch_name: string | null;
  filed_by: string;
  filed_by_name: string;
  service_request_id: string | null;
  category: string;
  complaint_description: string;
  assigned_admin_id: string | null;
  status: string;
  resolution: string | null;
  resolved_at: string | null;
  created_at: string;
  notes: Array<{
    note_id: string;
    author_id: string;
    note_type: string;
    content: string;
    created_at: string;
  }>;
}

export interface ServiceTaxonomyDto {
  categories: Array<{
    category_id: string;
    branch_id: string | null;
    branch_name: string | null;
    name: string;
    slug: string;
    icon_name: string;
    is_active: boolean;
  }>;
  services: Array<{
    service_id: string;
    category_id: string;
    name: string;
    description: string | null;
    base_price: number;
  }>;
  skills: Array<{
    skill_id: string;
    category_id: string | null;
    service_id: string | null;
    name: string;
  }>;
}

export interface FinanceLedgerDto {
  summary: {
    completedPaymentsTotal: number;
    skaviaFeeTotal: number;
    workerEarningsTotal: number;
    pendingApprovalsCount: number;
    pendingPayoutsAmount: number;
    pendingRefundsAmount: number;
  };
  payments: Array<{
    payment_id: string;
    branch_id: string | null;
    client_id: string;
    client_name: string;
    total_amount: number;
    skavia_fee: number;
    commission_percent_snapshot: number;
    status: string;
    paid_at: string | null;
    created_at: string;
    gateway_name: string | null;
    gateway_tx_id: string | null;
    invoice_number: string | null;
  }>;
  approvals: Array<{
    approval_id: string;
    action_type: string;
    entity_type: string;
    entity_id: string;
    branch_id: string | null;
    payload: Record<string, unknown>;
    idempotency_key: string;
    status: string;
    maker_user_id: string;
    checker_user_id: string | null;
    maker_reason: string;
    checker_notes: string | null;
    created_at: string;
    decided_at: string | null;
  }>;
  commissionRules: Array<{
    rule_id: string;
    branch_id: string | null;
    category_id: string | null;
    fee_percent: number;
    is_active: boolean;
    effective_from: string;
    approved_by: string | null;
  }>;
}

export interface AuditLogDto {
  audit_id: string;
  user_id: string | null;
  action: string;
  entity_type: string;
  entity_id: string | null;
  details: Record<string, unknown> | null;
  ip_address: string | null;
  created_at: string;
}

export interface SecurityIncidentDto {
  incident_id: string;
  title: string;
  severity: string;
  status: string;
  source: string;
  affected_user_id: string | null;
  branch_id: string | null;
  summary: string;
  created_at: string;
  resolved_at: string | null;
}

export interface DashboardMetricsDto {
  totalCustomers: number;
  totalWorkers: number;
  verifiedWorkers: number;
  pendingVerifications: number;
  activeBookings: number;
  openDisputes: number;
  completedPaymentsVolume: number;
  pendingFinancialApprovals: number;
  openSecurityIncidents: number;
  branchBreakdown: Array<{
    branch_id: string;
    code: string;
    name: string;
    activeBookings: number;
    workersCount: number;
    volumeBdt: number;
  }>;
  recentAuditLogs: AuditLogDto[];
}

export interface GlobalSearchResultDto {
  type: 'customer' | 'worker' | 'booking' | 'branch';
  id: string;
  title: string;
  subtitle: string;
  href: string;
}

export interface ApkInspectionSummaryDto {
  packageName: string;
  versionName: string;
  buildNumber: number;
  minSdkVersion: number | null;
  targetSdkVersion: number | null;
  fileSizeBytes: number;
  sha256Checksum: string;
  signingCertSha256: string | null;
  signingCertSubject: string | null;
  signingSchemes: string[];
  hasAndroidManifest: boolean;
  hasDex: boolean;
}

export interface AppReleaseDto {
  release_id: string;
  platform: 'android' | 'ios';
  channel: 'stable' | 'beta' | 'internal';
  package_name: string;
  version_name: string;
  build_number: number;
  min_supported_build: number;
  min_sdk_version: number | null;
  target_sdk_version: number | null;
  release_notes: string;
  is_mandatory: boolean;
  status: 'draft' | 'validated' | 'published' | 'suspended' | 'archived';
  is_current: boolean;
  storage_bucket: string;
  storage_path: string;
  file_name: string;
  file_size_bytes: number;
  sha256_checksum: string;
  signing_cert_sha256: string | null;
  signing_schemes: string[];
  notify_users: boolean;
  notifications_dispatched_at: string | null;
  rolled_back_from_release_id: string | null;
  suspension_reason: string | null;
  created_by: string | null;
  validated_by: string | null;
  published_by: string | null;
  validated_at: string | null;
  published_at: string | null;
  suspended_at: string | null;
  archived_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface ReleaseSigningPolicyDto {
  expectedPackageName: string;
  pinnedSigningCertSha256: string | null;
  updatedAt: string | null;
  updatedBy: string | null;
}

export interface AppReleaseAnalyticsDto {
  totalCheckIns: number;
  totalDownloadsStarted: number;
  totalDownloadsCompleted: number;
  totalChecksumVerified: number;
  totalChecksumFailed: number;
  totalInstallerLaunched: number;
  totalInstallFailed: number;
  recentEvents: Array<{
    event_id: string;
    release_id: string | null;
    channel: string;
    installed_build: number | null;
    installed_version: string | null;
    target_build: number | null;
    event_type: string;
    android_api_level: number | null;
    created_at: string;
  }>;
  versionDistribution: Array<{
    installedBuild: number;
    installedVersion: string;
    checkIns: number;
  }>;
}

