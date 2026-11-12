import type {
  AdminRoleName,
  AdminSessionContext,
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

export interface UserIdentityRecord {
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
}

export interface AdminAccountRecord extends UserIdentityRecord {
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

export interface AdminInvitationRecord {
  invitation_id: string;
  full_name: string;
  email: string;
  role_name: InvitableAdminRole;
  assigned_branch_ids: string[];
  assigned_branch_names: string[];
  permission_profile: Array<{ permissionKey: PermissionKey; effect: 'ALLOW' | 'DENY' }>;
  note: string | null;
  token_hash: string;
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

export interface AdminPasskeyRecord {
  credential_id: string;
  user_id: string;
  friendly_name: string;
  public_key: string;
  counter: number;
  transports: string[];
  device_type: string;
  backed_up: boolean;
  aaguid: string | null;
  last_used_at: string | null;
  revoked_at: string | null;
  created_at: string;
}

export interface WebAuthnChallengeRecord {
  challenge_id: string;
  user_id: string | null;
  invitation_id: string | null;
  challenge: string;
  purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate';
  expires_at: string;
  consumed_at: string | null;
}

export type LoginEventOutcome =
  | 'Success'
  | 'Blocked_NoAdminRole'
  | 'Blocked_NoMFA'
  | 'Blocked_Suspended'
  | 'Blocked_WrongSurface'
  | 'Blocked_PendingApproval'
  | 'Passkey_Success'
  | 'Passkey_Failed'
  | 'RecoveryCode_Used'
  | 'New_Device_Detected'
  | 'Invite_Activated'
  | 'Failed';

export interface AdminLoginEventRecord {
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

export interface AdminSessionRecord {
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

export interface CustomerDirectoryItem {
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

export interface WorkerDirectoryItem {
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

export interface VerificationQueueItem {
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

export interface BookingListItem {
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

export interface ProjectSummaryItem {
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

export interface DisputeItem {
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

export interface ServiceTaxonomyItem {
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

export interface FinanceLedgerSnapshot {
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

export interface AuditLogEntry {
  audit_id: string;
  user_id: string | null;
  action: string;
  entity_type: string;
  entity_id: string | null;
  details: Record<string, unknown> | null;
  ip_address: string | null;
  created_at: string;
}

export interface SecurityIncidentItem {
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

export interface DashboardMetrics {
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
  recentAuditLogs: AuditLogEntry[];
}

export interface AuditWriteInput {
  userId: string | null;
  action: string;
  entityType: string;
  entityId?: string | null;
  details?: Record<string, unknown>;
  ipAddress?: string | null;
}

export interface AdminRepository {
  // Auth & Session
  resolveAdminIdentity(userId: string): Promise<{
    user: UserIdentityRecord;
    roles: AdminRoleName[];
    isPrimarySuperAdmin: boolean;
    loginUsername: string | null;
    rolePermissions: PermissionKey[];
    branchScoped: boolean;
    assignedBranches: BranchSummary[];
    overrides: PermissionOverrideRecord[];
    permissionVersion: number;
    mfaEnforced: boolean;
    lastLoginAt: string | null;
    lastLoginIp: string | null;
    passkeyCount: number;
  } | null>;
  lookupPrimarySuperAdminByUsername(username: string): Promise<{
    userId: string;
    email: string;
    loginUsername: string;
  } | null>;
  recordLoginEvent(event: {
    userId: string | null;
    email: string | null;
    surface?: string | null;
    outcome: LoginEventOutcome;
    mfaMethod?: string | null;
    ipAddress?: string | null;
    userAgent?: string | null;
    failureReason?: string | null;
  }): Promise<void>;
  listLoginEvents(limit?: number): Promise<AdminLoginEventRecord[]>;
  checkAndRegisterDevice(input: {
    userId: string;
    fingerprint: string;
    deviceLabel: string;
    ipAddress: string;
  }): Promise<{ isNewDevice: boolean }>;
  createAdminSession(input: {
    userId: string;
    deviceLabel?: string;
    ipAddress?: string | null;
    permissionVersion: number;
    stepUpExpiresAt: string | null;
    expiresAt: string;
  }): Promise<AdminSessionRecord>;
  getAdminSession(sessionId: string): Promise<AdminSessionRecord | null>;
  refreshSessionStepUp(sessionId: string, stepUpExpiresAt: string): Promise<void>;
  revokeSession(sessionId: string, revokedBy: string): Promise<void>;
  listSessions(userId?: string): Promise<AdminSessionRecord[]>;

  // Invitations & Activation Lifecycle
  createAdminInvitation(input: {
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
  }): Promise<AdminInvitationRecord>;
  listAdminInvitations(): Promise<AdminInvitationRecord[]>;
  getInvitationById(invitationId: string): Promise<AdminInvitationRecord | null>;
  getInvitationByTokenHash(tokenHash: string): Promise<AdminInvitationRecord | null>;
  updateInvitationState(
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
  ): Promise<AdminInvitationRecord>;
  activateInvitedAdmin(input: {
    invitationId: string;
    userId: string;
    email: string;
    fullName: string;
    status: 'PendingApproval' | 'Active';
  }): Promise<void>;

  // WebAuthn / Passkeys & Recovery Codes
  createWebAuthnChallenge(input: {
    userId: string | null;
    invitationId?: string | null;
    challenge: string;
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate';
    expiresAt: string;
  }): Promise<WebAuthnChallengeRecord>;
  consumeWebAuthnChallenge(
    challengeId: string,
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate'
  ): Promise<WebAuthnChallengeRecord | null>;
  savePasskeyCredential(input: {
    credentialId: string;
    userId: string;
    friendlyName: string;
    publicKey: string;
    counter: number;
    transports: string[];
    deviceType: string;
    backedUp: boolean;
    aaguid: string | null;
  }): Promise<AdminPasskeyRecord>;
  listPasskeysForUser(userId: string): Promise<AdminPasskeyRecord[]>;
  listAllPasskeys(): Promise<AdminPasskeyRecord[]>;
  getPasskeyById(credentialId: string): Promise<AdminPasskeyRecord | null>;
  touchPasskeyUsage(credentialId: string, newCounter: number): Promise<void>;
  revokePasskey(credentialId: string, revokedBy: string): Promise<void>;
  setRecoveryCodeHashes(userId: string, hashes: string[]): Promise<void>;
  getRecoveryCodeHashes(userId: string): Promise<{ hashes: string[]; generatedAt: string | null }>;

  // Audit
  writeAuditLog(entry: AuditWriteInput): Promise<void>;
  listAuditLogs(filters: { action?: string; userId?: string; limit?: number }): Promise<AuditLogEntry[]>;

  // Dashboard & Search
  getDashboardMetrics(branchFilter: string[] | null): Promise<DashboardMetrics>;
  globalSearch(query: string, branchFilter: string[] | null): Promise<
    Array<{ type: 'customer' | 'worker' | 'booking' | 'branch'; id: string; title: string; subtitle: string; href: string }>
  >;

  // Branches
  listBranches(branchFilter: string[] | null): Promise<BranchSummary[]>;
  createBranch(input: { name: string; code: string; description?: string; managerId?: string | null }): Promise<BranchSummary>;
  updateBranch(branchId: string, patch: { name?: string; description?: string | null; isActive?: boolean; managerId?: string | null }): Promise<BranchSummary>;

  // Customers & Workers
  listCustomers(filters: { branchFilter: string[] | null; customerType?: string; search?: string }): Promise<CustomerDirectoryItem[]>;
  updateCustomer(customerId: string, patch: { fullName?: string; location?: string; accountStatus?: string }): Promise<CustomerDirectoryItem>;
  listWorkers(filters: { branchFilter: string[] | null; verificationStatus?: string; search?: string }): Promise<WorkerDirectoryItem[]>;
  updateWorker(workerProfileId: string, action: 'suspend' | 'reactivate' | 'assign_branch', branchId?: string): Promise<WorkerDirectoryItem>;

  // Verifications
  listVerifications(filters: { branchFilter: string[] | null; status?: string }): Promise<VerificationQueueItem[]>;
  getVerificationById(verificationId: string): Promise<VerificationQueueItem | null>;
  decideVerification(input: { verificationId: string; adminUserId: string; decision: 'Approved' | 'Rejected'; reviewNotes: string }): Promise<VerificationQueueItem>;
  createVerificationSignedUrl(fileUrlOrPath: string): Promise<string>;

  // Bookings & Turnkey Teams
  listBookings(filters: { branchFilter: string[] | null; status?: string }): Promise<BookingListItem[]>;
  updateBooking(bookingId: string, patch: { action: 'assign_worker' | 'reschedule' | 'cancel' | 'complete'; workerProfileId?: string; scheduledAt?: string; reason: string; actorUserId: string }): Promise<BookingListItem>;
  listProjects(branchFilter: string[] | null): Promise<ProjectSummaryItem[]>;
  assembleProjectTeam(input: {
    projectId: string;
    teamName: string;
    members: Array<{ workerProfileId: string; roleInTeam: string; isTeamLeader: boolean }>;
    initialTasks: Array<{ title: string; description?: string; priority: 'Low' | 'Medium' | 'High'; deadline?: string; assignedWorkerProfileId?: string }>;
  }): Promise<ProjectSummaryItem>;

  // Disputes
  listDisputes(filters: { branchFilter: string[] | null; status?: string }): Promise<DisputeItem[]>;
  resolveDispute(input: { disputeId: string; adminUserId: string; status: 'Resolved' | 'Dismissed'; resolution: string; noteType: 'Internal' | 'Decision' | 'RefundRecommendation' }): Promise<DisputeItem>;

  // Services & Finance
  getServiceTaxonomy(): Promise<ServiceTaxonomyItem>;
  mutateServiceTaxonomy(input: Record<string, unknown>): Promise<void>;
  getFinanceSnapshot(branchFilter: string[] | null): Promise<FinanceLedgerSnapshot>;
  createApprovalRequest(input: {
    actionType: 'PAYOUT_APPROVAL' | 'REFUND_APPROVAL' | 'COMMISSION_CHANGE' | 'SYSTEM_CONFIG';
    entityType: string;
    entityId: string;
    branchId: string | null;
    payload: Record<string, unknown>;
    idempotencyKey: string;
    makerUserId: string;
    makerReason: string;
  }): Promise<{ approval_id: string; status: string }>;
  decideApprovalRequest(input: {
    approvalId: string;
    checkerUserId: string;
    decision: 'Approved' | 'Rejected';
    checkerNotes: string;
  }): Promise<{ approval_id: string; status: string }>;
  runReconciliation(actorUserId: string): Promise<{ run_id: string; status: string; variance_amount: number }>;

  // Admin IAM & Security
  listAdmins(): Promise<AdminAccountRecord[]>;
  provisionAdmin(input: { userId: string; email: string; fullName: string; roleName: AdminRoleName; branchIds: string[]; actorUserId: string }): Promise<AdminAccountRecord>;
  updateAdminPermissions(targetUserId: string, input: Record<string, unknown>, actorUserId: string): Promise<AdminAccountRecord>;
  listIncidents(): Promise<SecurityIncidentItem[]>;
  createIncident(input: { title: string; severity: string; summary: string; affectedUserId?: string; branchId?: string }): Promise<SecurityIncidentItem>;
  updateIncident(input: { incidentId: string; status: string }): Promise<SecurityIncidentItem>;
  getSystemSettings(): Promise<Array<{ setting_key: string; setting_value: unknown; description: string | null; updated_at: string }>>;
  upsertSystemSetting(key: string, value: unknown, actorUserId: string): Promise<void>;
  listBackupLogs(): Promise<Array<{ verification_id: string; environment: string; restore_target: string; status: string; verified_at: string; rpo_minutes: number | null; rto_minutes: number | null }>>;

  // App Release Management & APK Distribution
  getReleaseSigningPolicy(): Promise<ReleaseSigningPolicyDto>;
  upsertReleaseSigningPolicy(input: {
    expectedPackageName: string;
    pinnedSigningCertSha256: string | null;
    actorUserId: string;
  }): Promise<ReleaseSigningPolicyDto>;
  createApkUploadSession(input: {
    fileName: string;
    channel: AppReleaseChannel;
  }): Promise<{
    storagePath: string;
    signedUploadUrl: string;
    token: string;
    bucket: string;
  }>;
  uploadApkObjectDirect(input: {
    storagePath: string;
    bytes: Buffer;
    contentType?: string;
  }): Promise<void>;
  readApkObjectBytes(storagePath: string): Promise<Buffer>;
  listReleases(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
    status?: AppReleaseStatus;
  }): Promise<AppReleaseDto[]>;
  getReleaseById(releaseId: string): Promise<AppReleaseDto | null>;
  getCurrentPublishedRelease(params: {
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
  }): Promise<AppReleaseDto | null>;
  createReleaseRecord(input: {
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
  }): Promise<AppReleaseDto>;
  markReleaseValidated(input: {
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
  }): Promise<AppReleaseDto>;
  publishRelease(input: {
    releaseId: string;
    actorUserId: string;
    notifyUsers?: boolean;
  }): Promise<{ release: AppReleaseDto; notifiedUsersCount: number }>;
  suspendRelease(input: {
    releaseId: string;
    actorUserId: string;
    reason: string;
  }): Promise<AppReleaseDto>;
  rollbackRelease(input: {
    targetReleaseId: string;
    actorUserId: string;
    reason: string;
  }): Promise<{ activeRelease: AppReleaseDto; suspendedReleaseId: string | null }>;
  archiveRelease(input: {
    releaseId: string;
    actorUserId: string;
  }): Promise<AppReleaseDto>;
  deleteDraftRelease(input: {
    releaseId: string;
    actorUserId: string;
  }): Promise<void>;
  createPublishedApkSignedUrl(storagePath: string, fileName?: string): Promise<string>;
  recordReleaseTelemetryEvent(input: {
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
  }): Promise<void>;
  getReleaseAnalytics(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
  }): Promise<AppReleaseAnalyticsDto>;
}

export type AdminSessionWithPermissions = AdminSessionContext;

