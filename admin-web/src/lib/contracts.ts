import { z } from 'zod';

export const PORTAL_SURFACES = ['public', 'superadmin', 'admin'] as const;

export type PortalSurface = (typeof PORTAL_SURFACES)[number];

export const ADMIN_ROLE_NAMES = [
  'Super Admin',
  'Company Admin',
  'Branch Manager',
] as const;

export type AdminRoleName = (typeof ADMIN_ROLE_NAMES)[number];

export const INVITABLE_ADMIN_ROLES = ['Company Admin', 'Branch Manager'] as const;

export type InvitableAdminRole = (typeof INVITABLE_ADMIN_ROLES)[number];

export const INVITATION_STATUSES = [
  'Draft',
  'Invited',
  'Delivered',
  'Opened',
  'SetupInProgress',
  'PendingApproval',
  'Active',
  'Expired',
  'Revoked',
  'Suspended',
] as const;

export type InvitationStatus = (typeof INVITATION_STATUSES)[number];

export const INVITATION_DELIVERY_STATUSES = [
  'Pending',
  'Sent',
  'Delivered',
  'DeliveryFailed',
  'NotConfigured',
] as const;

export type InvitationDeliveryStatus = (typeof INVITATION_DELIVERY_STATUSES)[number];

export const PERMISSION_KEYS = [
  'analytics.global.view',
  'branch.analytics.view',
  'branch.view',
  'branch.manage',
  'branch.staff.assign',
  'customer.view',
  'customer.update',
  'customer.suspend',
  'worker.view',
  'worker.verify',
  'worker.suspend',
  'worker.branch.assign',
  'worker.availability.view',
  'service.view',
  'service.manage',
  'service.branch.manage',
  'pricing.manage',
  'commission.manage',
  'booking.view',
  'booking.manage',
  'project.team.manage',
  'complaint.view',
  'complaint.manage',
  'dispute.view',
  'dispute.resolve',
  'payment.view',
  'payment.refund.request',
  'payment.refund.approve',
  'payout.view',
  'payout.request',
  'payout.approve',
  'report.view',
  'admin.view',
  'admin.invite',
  'admin.create',
  'admin.suspend',
  'admin.permission.update',
  'security.audit.view',
  'security.incident.manage',
  'security.session.revoke',
  'system.settings.manage',
  'system.backup.view',
  'release.view',
  'release.manage',
  'release.publish',
] as const;

export type PermissionKey = (typeof PERMISSION_KEYS)[number];

export const STEP_UP_REQUIRED_PERMISSIONS: ReadonlySet<PermissionKey> = new Set([
  'branch.manage',
  'branch.staff.assign',
  'customer.suspend',
  'worker.suspend',
  'pricing.manage',
  'commission.manage',
  'dispute.resolve',
  'payment.refund.request',
  'payment.refund.approve',
  'payout.request',
  'payout.approve',
  'admin.invite',
  'admin.create',
  'admin.suspend',
  'admin.permission.update',
  'security.audit.view',
  'security.incident.manage',
  'security.session.revoke',
  'system.settings.manage',
  'release.manage',
  'release.publish',
]);

export interface PermissionOverrideRecord {
  permission_key: PermissionKey;
  effect: 'ALLOW' | 'DENY';
  expires_at: string | null;
}

export interface BranchSummary {
  branch_id: string;
  name: string;
  code: string;
  description: string | null;
  manager_id: string | null;
  is_active: boolean;
  created_at: string;
}

export interface AdminSessionContext {
  sessionId: string;
  userId: string;
  email: string;
  fullName: string;
  roles: AdminRoleName[];
  primaryRole: AdminRoleName;
  isPrimarySuperAdmin: boolean;
  loginUsername?: string | null;
  portalSurface: PortalSurface;
  effectivePermissions: PermissionKey[];
  branchScoped: boolean;
  assignedBranches: BranchSummary[];
  permissionVersion: number;
  mfaVerified: boolean;
  mfaMethod: string | null;
  stepUpExpiresAt: string | null;
  expiresAt: string;
}

export const SessionExchangeInputSchema = z.object({
  idToken: z.string().min(20),
  deviceLabel: z.string().max(120).optional(),
  surface: z.enum(['superadmin', 'admin']).optional(),
});

export const StepUpInputSchema = z.object({
  idToken: z.string().min(20),
});

export const AdminInviteCreateSchema = z
  .object({
    fullName: z.string().trim().min(2).max(150),
    email: z.string().trim().email().max(150),
    roleName: z.enum(INVITABLE_ADMIN_ROLES),
    branchIds: z.array(z.string().uuid()).default([]),
    permissionProfile: z
      .array(
        z.object({
          permissionKey: z.enum(PERMISSION_KEYS),
          effect: z.enum(['ALLOW', 'DENY']),
        })
      )
      .default([]),
    note: z.string().trim().max(500).optional(),
    expiresInHours: z.number().int().min(1).max(168).default(24),
    requireApproval: z.boolean().default(true),
  })
  .refine(
    (data) => data.roleName !== 'Branch Manager' || data.branchIds.length >= 1,
    {
      message: 'Branch Manager invitations require at least one assigned branch.',
      path: ['branchIds'],
    }
  );

export const InvitationActivateSchema = z.object({
  token: z.string().trim().min(24).max(256),
  idToken: z.string().min(20),
  fullName: z.string().trim().min(2).max(150).optional(),
  acceptedTerms: z.literal(true),
  deviceLabel: z.string().max(120).optional(),
});

export const IdentifierLookupSchema = z.object({
  identifier: z.string().trim().min(2).max(150),
  surface: z.enum(['superadmin', 'admin']).optional(),
});

export const RecoveryCodeConsumeSchema = z.object({
  idToken: z.string().min(20),
  recoveryCode: z.string().trim().min(6).max(64),
  surface: z.enum(['superadmin', 'admin']).optional(),
  mode: z.enum(['login', 'step_up']).default('login'),
  deviceLabel: z.string().max(120).optional(),
});

export const BranchCreateSchema = z.object({
  name: z.string().trim().min(3).max(100),
  code: z.string().trim().toUpperCase().regex(/^[A-Z0-9_-]{2,20}$/),
  description: z.string().trim().max(500).optional(),
  managerId: z.string().trim().min(1).nullable().optional(),
});

export const BranchUpdateSchema = z.object({
  name: z.string().trim().min(3).max(100).optional(),
  description: z.string().trim().max(500).nullable().optional(),
  isActive: z.boolean().optional(),
  managerId: z.string().trim().min(1).nullable().optional(),
});

export const CustomerUpdateSchema = z.object({
  fullName: z.string().trim().min(2).max(150).optional(),
  location: z.string().trim().min(2).max(150).optional(),
  accountStatus: z.enum(['active', 'suspended', 'deactivated']).optional(),
  reason: z.string().trim().min(5).max(500).optional(),
});

export const WorkerActionSchema = z.object({
  action: z.enum(['suspend', 'reactivate', 'assign_branch']),
  branchId: z.string().uuid().optional(),
  reason: z.string().trim().min(5).max(500),
});

export const VerificationDecisionSchema = z.object({
  decision: z.enum(['Approved', 'Rejected']),
  reviewNotes: z.string().trim().min(5).max(1000),
  checklist: z
    .object({
      nidMatched: z.boolean(),
      documentLegible: z.boolean(),
      policeClearanceChecked: z.boolean().optional(),
    })
    .optional(),
});

export const BookingActionSchema = z.object({
  action: z.enum(['assign_worker', 'reschedule', 'cancel', 'complete']),
  workerProfileId: z.string().uuid().optional(),
  scheduledAt: z.string().datetime().optional(),
  reason: z.string().trim().min(5).max(500),
});

export const TeamAssemblyCreateSchema = z.object({
  projectId: z.string().uuid(),
  teamName: z.string().trim().min(3).max(150),
  members: z
    .array(
      z.object({
        workerProfileId: z.string().uuid(),
        roleInTeam: z.string().trim().min(2).max(100),
        isTeamLeader: z.boolean().default(false),
      })
    )
    .min(1),
  initialTasks: z
    .array(
      z.object({
        title: z.string().trim().min(3).max(200),
        description: z.string().max(1000).optional(),
        priority: z.enum(['Low', 'Medium', 'High']).default('Medium'),
        deadline: z.string().optional(),
        assignedWorkerProfileId: z.string().uuid().optional(),
      })
    )
    .default([]),
});

export const DisputeResolveSchema = z.object({
  resolution: z.string().trim().min(10).max(1500),
  status: z.enum(['Resolved', 'Dismissed']),
  noteType: z.enum(['Internal', 'Decision', 'RefundRecommendation']).default('Decision'),
  recommendedRefundAmount: z.number().nonnegative().optional(),
});

export const ServiceManageSchema = z.object({
  type: z.enum(['category', 'service', 'skill']),
  action: z.enum(['create', 'update', 'toggle']),
  id: z.string().uuid().optional(),
  branchId: z.string().uuid().optional(),
  categoryId: z.string().uuid().optional(),
  name: z.string().trim().min(2).max(150).optional(),
  slug: z.string().trim().min(2).max(100).optional(),
  iconName: z.string().trim().min(1).max(50).optional(),
  description: z.string().max(500).optional(),
  basePrice: z.number().nonnegative().optional(),
  isActive: z.boolean().optional(),
});

export const ApprovalRequestCreateSchema = z.object({
  actionType: z.enum([
    'PAYOUT_APPROVAL',
    'REFUND_APPROVAL',
    'COMMISSION_CHANGE',
    'SYSTEM_CONFIG',
  ]),
  entityId: z.string().min(1),
  reason: z.string().trim().min(8).max(500),
  idempotencyKey: z.string().min(12).max(120),
  amount: z.number().positive().optional(),
  feePercent: z.number().min(0).max(0.5).optional(),
  branchId: z.string().uuid().nullable().optional(),
});

export const ApprovalDecisionSchema = z.object({
  approvalId: z.string().uuid(),
  decision: z.enum(['Approved', 'Rejected']),
  checkerNotes: z.string().trim().min(5).max(500),
});

export const AdminProvisionSchema = z.object({
  userId: z.string().trim().min(4),
  email: z.string().email(),
  fullName: z.string().trim().min(2).max(150),
  roleName: z.enum(ADMIN_ROLE_NAMES),
  branchIds: z.array(z.string().uuid()).default([]),
});

export const AdminPermissionUpdateSchema = z.object({
  roleName: z.enum(ADMIN_ROLE_NAMES).optional(),
  branchIds: z.array(z.string().uuid()).optional(),
  override: z
    .object({
      permissionKey: z.enum(PERMISSION_KEYS),
      effect: z.enum(['ALLOW', 'DENY']),
      reason: z.string().trim().min(5).max(500),
      expiresAt: z.string().datetime().nullable().optional(),
    })
    .optional(),
  suspendReason: z.string().trim().min(5).max(500).optional(),
  reactivate: z.boolean().optional(),
});

export const IncidentCreateSchema = z.object({
  title: z.string().trim().min(5).max(200),
  severity: z.enum(['Low', 'Medium', 'High', 'Critical']),
  summary: z.string().trim().min(10).max(2000),
  affectedUserId: z.string().optional(),
  branchId: z.string().uuid().optional(),
});

export const IncidentUpdateSchema = z.object({
  incidentId: z.string().uuid(),
  status: z.enum(['Investigating', 'Contained', 'Resolved', 'Closed']),
  containmentNote: z.string().trim().min(5).max(1000).optional(),
});

export const APP_RELEASE_PLATFORMS = ['android', 'ios'] as const;
export type AppReleasePlatform = (typeof APP_RELEASE_PLATFORMS)[number];

export const APP_RELEASE_CHANNELS = ['stable', 'beta', 'internal'] as const;
export type AppReleaseChannel = (typeof APP_RELEASE_CHANNELS)[number];

export const APP_RELEASE_STATUSES = [
  'draft',
  'validated',
  'published',
  'suspended',
  'archived',
] as const;
export type AppReleaseStatus = (typeof APP_RELEASE_STATUSES)[number];

export const RELEASE_TELEMETRY_EVENT_TYPES = [
  'update_check',
  'download_started',
  'download_completed',
  'checksum_verified',
  'checksum_failed',
  'installer_launched',
  'install_failed',
  'app_active',
] as const;
export type ReleaseTelemetryEventType = (typeof RELEASE_TELEMETRY_EVENT_TYPES)[number];

export const ReleaseUploadSessionSchema = z.object({
  fileName: z
    .string()
    .trim()
    .min(5)
    .max(180)
    .regex(/\.apk$/i, 'Only .apk files are permitted for Android release uploads.'),
  fileSizeBytes: z
    .number()
    .int()
    .positive()
    .max(150 * 1024 * 1024, 'APK exceeds maximum 150 MB distribution cap.'),
  channel: z.enum(APP_RELEASE_CHANNELS).default('stable'),
});

export const ReleaseCreateSchema = z
  .object({
    storagePath: z.string().trim().min(5).max(300),
    fileName: z.string().trim().min(5).max(180),
    channel: z.enum(APP_RELEASE_CHANNELS).default('stable'),
    versionName: z
      .string()
      .trim()
      .min(1)
      .max(60)
      .regex(/^[0-9]+\.[0-9]+(\.[0-9]+)?([\-+._A-Za-z0-9]*)?$/, 'Invalid semantic version string.'),
    buildNumber: z.number().int().positive(),
    minSupportedBuild: z.number().int().positive(),
    releaseNotes: z.string().trim().min(10).max(5000),
    isMandatory: z.boolean().default(false),
    notifyUsers: z.boolean().default(true),
    publishImmediately: z.boolean().default(false),
    allowInitialSigningPin: z.boolean().default(false),
  })
  .refine((data) => data.minSupportedBuild <= data.buildNumber, {
    message: 'Minimum supported build cannot exceed the release build number.',
    path: ['minSupportedBuild'],
  });

export const ReleaseLifecycleActionSchema = z.discriminatedUnion('action', [
  z.object({
    action: z.literal('validate'),
    allowInitialSigningPin: z.boolean().optional(),
  }),
  z.object({
    action: z.literal('publish'),
    notifyUsers: z.boolean().optional(),
    confirmed: z.literal(true),
  }),
  z.object({
    action: z.literal('suspend'),
    reason: z.string().trim().min(5).max(500),
    confirmed: z.literal(true),
  }),
  z.object({
    action: z.literal('rollback'),
    targetReleaseId: z.string().uuid(),
    reason: z.string().trim().min(5).max(500),
    confirmed: z.literal(true),
  }),
  z.object({
    action: z.literal('archive'),
    confirmed: z.literal(true),
  }),
]);

export const ReleaseSigningPinSchema = z.object({
  expectedPackageName: z
    .string()
    .trim()
    .min(3)
    .max(150)
    .default('com.example.skavia'),
  pinnedSigningCertSha256: z
    .string()
    .trim()
    .toLowerCase()
    .regex(/^[a-f0-9]{64}$/, 'Certificate fingerprint must be a 64-character lowercase SHA-256 hex digest.'),
  notes: z.string().trim().max(300).optional(),
  confirmed: z.literal(true),
});

export const PublicReleaseTelemetrySchema = z.object({
  releaseId: z.string().uuid().optional().nullable(),
  platform: z.enum(APP_RELEASE_PLATFORMS).default('android'),
  channel: z.enum(APP_RELEASE_CHANNELS).default('stable'),
  installedBuild: z.number().int().nonnegative().optional(),
  installedVersion: z.string().trim().max(60).optional(),
  targetBuild: z.number().int().positive().optional(),
  eventType: z.enum(RELEASE_TELEMETRY_EVENT_TYPES),
  deviceFingerprintHash: z.string().trim().max(64).optional(),
  androidApiLevel: z.number().int().min(19).max(99).optional(),
  metadata: z.record(z.unknown()).optional(),
});

