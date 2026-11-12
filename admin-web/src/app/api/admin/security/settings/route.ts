import { NextResponse } from 'next/server';
import { z } from 'zod';
import { recordAdminAudit } from '@/server/audit/logger';
import { withAdminRoute } from '@/server/http/guard';

const SettingUpsertSchema = z.object({
  settingKey: z.string().trim().min(2).max(100),
  settingValue: z.unknown(),
});

export async function GET(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'system.backup.view', requireStepUp: false },
    async ({ repo }) => {
      const [settings, backups] = await Promise.all([
        repo.getSystemSettings(),
        repo.listBackupLogs(),
      ]);
      return NextResponse.json({ settings, backups });
    }
  );
}

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    { permission: 'system.settings.manage', requireStepUp: true },
    async ({ session, repo, correlationId, ipAddress }) => {
      const input = SettingUpsertSchema.parse(await req.json());
      await repo.upsertSystemSetting(
        input.settingKey,
        input.settingValue,
        session.userId
      );

      await recordAdminAudit(repo, {
        userId: session.userId,
        action: 'system.setting.updated',
        entityType: 'system_setting',
        entityId: input.settingKey,
        details: { setting_value: input.settingValue },
        ipAddress,
        correlationId,
      });

      const settings = await repo.getSystemSettings();
      return NextResponse.json({ settings });
    }
  );
}

