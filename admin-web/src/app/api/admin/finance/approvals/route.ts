import { NextResponse } from 'next/server';
import {
  ApprovalDecisionSchema,
  ApprovalRequestCreateSchema,
  PermissionKey,
} from '@/lib/contracts';
import {
  AuthorizationError,
  assertAuthorized,
  assertMakerCheckerSeparation,
} from '@/server/auth/rbac';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

function makerPermissionForAction(
  actionType: 'PAYOUT_APPROVAL' | 'REFUND_APPROVAL' | 'COMMISSION_CHANGE' | 'SYSTEM_CONFIG'
): { permission: PermissionKey; entityType: string } {
  switch (actionType) {
    case 'PAYOUT_APPROVAL':
      return { permission: 'payout.request', entityType: 'payout_request' };
    case 'REFUND_APPROVAL':
      return { permission: 'payment.refund.request', entityType: 'refund_request' };
    case 'COMMISSION_CHANGE':
      return { permission: 'commission.manage', entityType: 'commission_rule' };
    case 'SYSTEM_CONFIG':
      return { permission: 'system.settings.manage', entityType: 'system_setting' };
  }
}

function checkerPermissionForAction(actionType: string): PermissionKey {
  switch (actionType) {
    case 'PAYOUT_APPROVAL':
      return 'payout.approve';
    case 'REFUND_APPROVAL':
      return 'payment.refund.approve';
    case 'COMMISSION_CHANGE':
      return 'commission.manage';
    default:
      return 'system.settings.manage';
  }
}

export async function POST(req: Request) {
  return withAdminRoute(req, { permission: 'payment.view' }, async ({ session, repo, correlationId, ipAddress }) => {
    const input = ApprovalRequestCreateSchema.parse(await req.json());
    const { permission, entityType } = makerPermissionForAction(input.actionType);

    assertAuthorized(session, {
      permission,
      requireStepUp: true,
      targetBranchId: input.branchId ?? null,
    });

    const created = await repo.createApprovalRequest({
      actionType: input.actionType,
      entityType,
      entityId: input.entityId,
      branchId: input.branchId ?? null,
      payload: {
        amount: input.amount ?? null,
        fee_percent: input.feePercent ?? null,
      },
      idempotencyKey: input.idempotencyKey,
      makerUserId: session.userId,
      makerReason: input.reason,
    });

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: `finance.approval.requested.${input.actionType.toLowerCase()}`,
      entityType,
      entityId: created.approval_id,
      details: {
        target_entity_id: input.entityId,
        idempotency_key: input.idempotencyKey,
        reason: input.reason,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ approval: created }, { status: 201 });
  });
}

export async function PATCH(req: Request) {
  return withAdminRoute(req, { permission: 'payment.view' }, async ({ session, repo, correlationId, ipAddress }) => {
    const input = ApprovalDecisionSchema.parse(await req.json());
    const snapshot = await repo.getFinanceSnapshot(null);
    const approval = snapshot.approvals.find(
      (a) => a.approval_id === input.approvalId
    );

    if (!approval) {
      throw new AuthorizationError('NOT_FOUND', 'Approval request not found.', 404);
    }

    const requiredCheckerPerm = checkerPermissionForAction(approval.action_type);
    assertAuthorized(session, {
      permission: requiredCheckerPerm,
      requireStepUp: true,
      targetBranchId: approval.branch_id,
    });

    assertMakerCheckerSeparation(approval.maker_user_id, session.userId);

    const decided = await repo.decideApprovalRequest({
      approvalId: input.approvalId,
      checkerUserId: session.userId,
      decision: input.decision,
      checkerNotes: input.checkerNotes,
    });

    await recordAdminAudit(repo, {
      userId: session.userId,
      action: `finance.approval.${input.decision.toLowerCase()}`,
      entityType: approval.entity_type,
      entityId: approval.approval_id,
      details: {
        action_type: approval.action_type,
        maker_user_id: approval.maker_user_id,
        checker_notes: input.checkerNotes,
      },
      ipAddress,
      correlationId,
    });

    return NextResponse.json({ approval: decided });
  });
}

