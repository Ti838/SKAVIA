import { createClient, type SupabaseClient } from '@supabase/supabase-js';
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
  ReleaseTelemetryEventType,
} from '@/lib/contracts';
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
  VerificationQueueItem,
  WebAuthnChallengeRecord,
  WorkerDirectoryItem,
} from './repository';
import { SupabaseFinanceStore } from './stores/finance-store';
import { SupabaseGovernanceStore } from './stores/governance-store';
import { SupabaseIdentityStore } from './stores/identity-store';
import { SupabaseInvitationsStore } from './stores/invitations-store';
import { SupabaseOperationsDirectoryStore } from './stores/operations-directory-store';
import { SupabaseOperationsDispatchStore } from './stores/operations-dispatch-store';
import { SupabasePasskeysStore } from './stores/passkeys-store';
import { SupabaseReleasesStore } from './stores/releases-store';
import { SupabaseReleasesTelemetryStore } from './stores/releases-telemetry-store';

/**
 * Facade implementing [AdminRepository] by composing cohesive domain stores
 * ([SupabaseIdentityStore], [SupabaseInvitationsStore], [SupabasePasskeysStore],
 *  [SupabaseOperationsDirectoryStore], [SupabaseOperationsDispatchStore],
 *  [SupabaseFinanceStore], [SupabaseGovernanceStore], [SupabaseReleasesStore],
 *  [SupabaseReleasesTelemetryStore]).
 */
export class SupabaseAdminRepository implements AdminRepository {
  private readonly db: SupabaseClient;
  private readonly identity: SupabaseIdentityStore;
  private readonly invitations: SupabaseInvitationsStore;
  private readonly passkeys: SupabasePasskeysStore;
  private readonly directory: SupabaseOperationsDirectoryStore;
  private readonly dispatch: SupabaseOperationsDispatchStore;
  private readonly finance: SupabaseFinanceStore;
  private readonly governance: SupabaseGovernanceStore;
  private readonly releases: SupabaseReleasesStore;
  private readonly releaseTelemetry: SupabaseReleasesTelemetryStore;

  constructor(supabaseUrl: string, serviceRoleKey: string) {
    this.db = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
    this.identity = new SupabaseIdentityStore(this.db);
    this.invitations = new SupabaseInvitationsStore(this.db);
    this.passkeys = new SupabasePasskeysStore(this.db);
    this.directory = new SupabaseOperationsDirectoryStore(this.db);
    this.dispatch = new SupabaseOperationsDispatchStore(this.db);
    this.finance = new SupabaseFinanceStore(this.db);
    this.governance = new SupabaseGovernanceStore(this.db, this.identity, this.directory, this.dispatch);
    this.releases = new SupabaseReleasesStore(this.db);
    this.releaseTelemetry = new SupabaseReleasesTelemetryStore(this.db);
  }

  // Auth & Session + Admin IAM + Audit
  resolveAdminIdentity(userId: string) {
    return this.identity.resolveAdminIdentity(userId);
  }
  lookupPrimarySuperAdminByUsername(username: string) {
    return this.identity.lookupPrimarySuperAdminByUsername(username);
  }
  recordLoginEvent(event: {
    userId: string | null;
    email: string | null;
    surface?: string | null;
    outcome: LoginEventOutcome;
    mfaMethod?: string | null;
    ipAddress?: string | null;
    userAgent?: string | null;
    failureReason?: string | null;
  }): Promise<void> {
    return this.identity.recordLoginEvent(event);
  }
  listLoginEvents(limit?: number): Promise<AdminLoginEventRecord[]> {
    return this.identity.listLoginEvents(limit);
  }
  checkAndRegisterDevice(input: {
    userId: string;
    fingerprint: string;
    deviceLabel: string;
    ipAddress: string;
  }) {
    return this.identity.checkAndRegisterDevice(input);
  }
  createAdminSession(input: {
    userId: string;
    deviceLabel?: string;
    ipAddress?: string | null;
    permissionVersion: number;
    stepUpExpiresAt: string | null;
    expiresAt: string;
  }): Promise<AdminSessionRecord> {
    return this.identity.createAdminSession(input);
  }
  getAdminSession(sessionId: string): Promise<AdminSessionRecord | null> {
    return this.identity.getAdminSession(sessionId);
  }
  refreshSessionStepUp(sessionId: string, stepUpExpiresAt: string): Promise<void> {
    return this.identity.refreshSessionStepUp(sessionId, stepUpExpiresAt);
  }
  revokeSession(sessionId: string, revokedBy: string): Promise<void> {
    return this.identity.revokeSession(sessionId, revokedBy);
  }
  listSessions(userId?: string): Promise<AdminSessionRecord[]> {
    return this.identity.listSessions(userId);
  }
  writeAuditLog(entry: AuditWriteInput): Promise<void> {
    return this.identity.writeAuditLog(entry);
  }
  listAuditLogs(filters: { action?: string; userId?: string; limit?: number }): Promise<AuditLogEntry[]> {
    return this.identity.listAuditLogs(filters);
  }
  listAdmins(): Promise<AdminAccountRecord[]> {
    return this.identity.listAdmins();
  }
  provisionAdmin(input: { userId: string; email: string; fullName: string; roleName: AdminRoleName; branchIds: string[]; actorUserId: string }): Promise<AdminAccountRecord> {
    return this.identity.provisionAdmin(input);
  }
  updateAdminPermissions(targetUserId: string, input: Record<string, unknown>, actorUserId: string): Promise<AdminAccountRecord> {
    return this.identity.updateAdminPermissions(targetUserId, input, actorUserId);
  }

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
  }): Promise<AdminInvitationRecord> {
    return this.invitations.createAdminInvitation(input);
  }
  listAdminInvitations(): Promise<AdminInvitationRecord[]> {
    return this.invitations.listAdminInvitations();
  }
  getInvitationById(invitationId: string): Promise<AdminInvitationRecord | null> {
    return this.invitations.getInvitationById(invitationId);
  }
  getInvitationByTokenHash(tokenHash: string): Promise<AdminInvitationRecord | null> {
    return this.invitations.getInvitationByTokenHash(tokenHash);
  }
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
  ): Promise<AdminInvitationRecord> {
    return this.invitations.updateInvitationState(invitationId, patch);
  }
  activateInvitedAdmin(input: {
    invitationId: string;
    userId: string;
    email: string;
    fullName: string;
    status: 'PendingApproval' | 'Active';
  }): Promise<void> {
    return this.invitations.activateInvitedAdmin(input);
  }

  // WebAuthn / Passkeys & Recovery Codes
  createWebAuthnChallenge(input: {
    userId: string | null;
    invitationId?: string | null;
    challenge: string;
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate';
    expiresAt: string;
  }): Promise<WebAuthnChallengeRecord> {
    return this.passkeys.createWebAuthnChallenge(input);
  }
  consumeWebAuthnChallenge(
    challengeId: string,
    purpose: 'register' | 'authenticate' | 'step_up' | 'invite_activate'
  ): Promise<WebAuthnChallengeRecord | null> {
    return this.passkeys.consumeWebAuthnChallenge(challengeId, purpose);
  }
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
  }): Promise<AdminPasskeyRecord> {
    return this.passkeys.savePasskeyCredential(input);
  }
  listPasskeysForUser(userId: string): Promise<AdminPasskeyRecord[]> {
    return this.passkeys.listPasskeysForUser(userId);
  }
  listAllPasskeys(): Promise<AdminPasskeyRecord[]> {
    return this.passkeys.listAllPasskeys();
  }
  getPasskeyById(credentialId: string): Promise<AdminPasskeyRecord | null> {
    return this.passkeys.getPasskeyById(credentialId);
  }
  touchPasskeyUsage(credentialId: string, newCounter: number): Promise<void> {
    return this.passkeys.touchPasskeyUsage(credentialId, newCounter);
  }
  revokePasskey(credentialId: string, revokedBy: string): Promise<void> {
    return this.passkeys.revokePasskey(credentialId, revokedBy);
  }
  setRecoveryCodeHashes(userId: string, hashes: string[]): Promise<void> {
    return this.passkeys.setRecoveryCodeHashes(userId, hashes);
  }
  getRecoveryCodeHashes(userId: string) {
    return this.passkeys.getRecoveryCodeHashes(userId);
  }

  // Dashboard, Search & Security Governance
  getDashboardMetrics(branchFilter: string[] | null): Promise<DashboardMetrics> {
    return this.governance.getDashboardMetrics(branchFilter);
  }
  globalSearch(query: string, branchFilter: string[] | null) {
    return this.governance.globalSearch(query, branchFilter);
  }
  listIncidents(): Promise<SecurityIncidentItem[]> {
    return this.governance.listIncidents();
  }
  createIncident(input: { title: string; severity: string; summary: string; affectedUserId?: string; branchId?: string }): Promise<SecurityIncidentItem> {
    return this.governance.createIncident(input);
  }
  updateIncident(input: { incidentId: string; status: string }): Promise<SecurityIncidentItem> {
    return this.governance.updateIncident(input);
  }
  getSystemSettings() {
    return this.governance.getSystemSettings();
  }
  upsertSystemSetting(key: string, value: unknown, actorUserId: string) {
    return this.governance.upsertSystemSetting(key, value, actorUserId);
  }
  listBackupLogs() {
    return this.governance.listBackupLogs();
  }

  // Operations (Branches, Customers, Workers, Verifications, Bookings, Teams, Disputes, Taxonomy)
  listBranches(branchFilter: string[] | null): Promise<BranchSummary[]> {
    return this.directory.listBranches(branchFilter);
  }
  createBranch(input: { name: string; code: string; description?: string; managerId?: string | null }): Promise<BranchSummary> {
    return this.directory.createBranch(input);
  }
  updateBranch(branchId: string, patch: { name?: string; description?: string | null; isActive?: boolean; managerId?: string | null }): Promise<BranchSummary> {
    return this.directory.updateBranch(branchId, patch);
  }
  listCustomers(filters: { branchFilter: string[] | null; customerType?: string; search?: string }): Promise<CustomerDirectoryItem[]> {
    return this.directory.listCustomers(filters);
  }
  updateCustomer(customerId: string, patch: { fullName?: string; location?: string; accountStatus?: string }): Promise<CustomerDirectoryItem> {
    return this.directory.updateCustomer(customerId, patch);
  }
  listWorkers(filters: { branchFilter: string[] | null; verificationStatus?: string; search?: string }): Promise<WorkerDirectoryItem[]> {
    return this.directory.listWorkers(filters);
  }
  updateWorker(workerProfileId: string, action: 'suspend' | 'reactivate' | 'assign_branch', branchId?: string): Promise<WorkerDirectoryItem> {
    return this.directory.updateWorker(workerProfileId, action, branchId);
  }
  listVerifications(filters: { branchFilter: string[] | null; status?: string }): Promise<VerificationQueueItem[]> {
    return this.directory.listVerifications(filters);
  }
  getVerificationById(verificationId: string): Promise<VerificationQueueItem | null> {
    return this.directory.getVerificationById(verificationId);
  }
  decideVerification(input: { verificationId: string; adminUserId: string; decision: 'Approved' | 'Rejected'; reviewNotes: string }): Promise<VerificationQueueItem> {
    return this.directory.decideVerification(input);
  }
  createVerificationSignedUrl(fileUrlOrPath: string): Promise<string> {
    return this.directory.createVerificationSignedUrl(fileUrlOrPath);
  }
  listBookings(filters: { branchFilter: string[] | null; status?: string }): Promise<BookingListItem[]> {
    return this.dispatch.listBookings(filters);
  }
  updateBooking(bookingId: string, patch: { action: 'assign_worker' | 'reschedule' | 'cancel' | 'complete'; workerProfileId?: string; scheduledAt?: string; reason: string; actorUserId: string }): Promise<BookingListItem> {
    return this.dispatch.updateBooking(bookingId, patch);
  }
  listProjects(branchFilter: string[] | null): Promise<ProjectSummaryItem[]> {
    return this.dispatch.listProjects(branchFilter);
  }
  assembleProjectTeam(input: {
    projectId: string;
    teamName: string;
    members: Array<{ workerProfileId: string; roleInTeam: string; isTeamLeader: boolean }>;
    initialTasks: Array<{ title: string; description?: string; priority: 'Low' | 'Medium' | 'High'; deadline?: string; assignedWorkerProfileId?: string }>;
  }): Promise<ProjectSummaryItem> {
    return this.dispatch.assembleProjectTeam(input);
  }
  listDisputes(filters: { branchFilter: string[] | null; status?: string }): Promise<DisputeItem[]> {
    return this.dispatch.listDisputes(filters);
  }
  resolveDispute(input: { disputeId: string; adminUserId: string; status: 'Resolved' | 'Dismissed'; resolution: string; noteType: 'Internal' | 'Decision' | 'RefundRecommendation' }): Promise<DisputeItem> {
    return this.dispatch.resolveDispute(input);
  }
  getServiceTaxonomy(): Promise<ServiceTaxonomyItem> {
    return this.dispatch.getServiceTaxonomy();
  }
  mutateServiceTaxonomy(input: Record<string, unknown>): Promise<void> {
    return this.dispatch.mutateServiceTaxonomy(input);
  }

  // Finance & Reconciliation
  getFinanceSnapshot(branchFilter: string[] | null): Promise<FinanceLedgerSnapshot> {
    return this.finance.getFinanceSnapshot(branchFilter);
  }
  createApprovalRequest(input: {
    actionType: 'PAYOUT_APPROVAL' | 'REFUND_APPROVAL' | 'COMMISSION_CHANGE' | 'SYSTEM_CONFIG';
    entityType: string;
    entityId: string;
    branchId: string | null;
    payload: Record<string, unknown>;
    idempotencyKey: string;
    makerUserId: string;
    makerReason: string;
  }) {
    return this.finance.createApprovalRequest(input);
  }
  decideApprovalRequest(input: { approvalId: string; checkerUserId: string; decision: 'Approved' | 'Rejected'; checkerNotes: string }) {
    return this.finance.decideApprovalRequest(input);
  }
  runReconciliation(actorUserId: string) {
    return this.finance.runReconciliation(actorUserId);
  }

  // App Release Management & APK Distribution
  getReleaseSigningPolicy() {
    return this.releases.getReleaseSigningPolicy();
  }
  upsertReleaseSigningPolicy(input: {
    expectedPackageName: string;
    pinnedSigningCertSha256: string | null;
    actorUserId: string;
  }) {
    return this.releases.upsertReleaseSigningPolicy(input);
  }
  createApkUploadSession(input: { fileName: string; channel: AppReleaseChannel }) {
    return this.releases.createApkUploadSession(input);
  }
  uploadApkObjectDirect(input: {
    storagePath: string;
    bytes: Buffer;
    contentType?: string;
  }) {
    return this.releases.uploadApkObjectDirect(input);
  }
  readApkObjectBytes(storagePath: string) {
    return this.releases.readApkObjectBytes(storagePath);
  }
  listReleases(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
    status?: AppReleaseStatus;
  }) {
    return this.releases.listReleases(filters);
  }
  getReleaseById(releaseId: string) {
    return this.releases.getReleaseById(releaseId);
  }
  getCurrentPublishedRelease(params: {
    platform: AppReleasePlatform;
    channel: AppReleaseChannel;
  }) {
    return this.releases.getCurrentPublishedRelease(params);
  }
  createReleaseRecord(input: Parameters<SupabaseReleasesStore['createReleaseRecord']>[0]) {
    return this.releases.createReleaseRecord(input);
  }
  markReleaseValidated(input: Parameters<SupabaseReleasesStore['markReleaseValidated']>[0]) {
    return this.releases.markReleaseValidated(input);
  }
  publishRelease(input: {
    releaseId: string;
    actorUserId: string;
    notifyUsers?: boolean;
  }) {
    return this.releases.publishRelease(input);
  }
  suspendRelease(input: { releaseId: string; actorUserId: string; reason: string }) {
    return this.releases.suspendRelease(input);
  }
  rollbackRelease(input: { targetReleaseId: string; actorUserId: string; reason: string }) {
    return this.releases.rollbackRelease(input);
  }
  archiveRelease(input: { releaseId: string; actorUserId: string }) {
    return this.releases.archiveRelease(input);
  }
  deleteDraftRelease(input: { releaseId: string; actorUserId: string }) {
    return this.releases.deleteDraftRelease(input);
  }
  createPublishedApkSignedUrl(storagePath: string, fileName?: string) {
    return this.releaseTelemetry.createPublishedApkSignedUrl(storagePath, fileName);
  }
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
  }) {
    return this.releaseTelemetry.recordReleaseTelemetryEvent(input);
  }
  getReleaseAnalytics(filters?: {
    platform?: AppReleasePlatform;
    channel?: AppReleaseChannel;
  }) {
    return this.releaseTelemetry.getReleaseAnalytics(filters);
  }
}
