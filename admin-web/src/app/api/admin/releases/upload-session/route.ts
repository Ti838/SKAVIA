import { NextResponse } from 'next/server';
import { ReleaseUploadSessionSchema } from '@/lib/contracts';
import { withAdminRoute } from '@/server/http/guard';

export async function POST(req: Request) {
  return withAdminRoute(
    req,
    {
      permission: 'release.manage',
      requireStepUp: true,
      requirePrimarySuperAdmin: true,
    },
    async ({ repo }) => {
      const body = await req.json();
      const input = ReleaseUploadSessionSchema.parse(body);
      const session = await repo.createApkUploadSession({
        fileName: input.fileName,
        channel: input.channel,
      });

      return NextResponse.json({
        uploadSession: session,
      });
    }
  );
}

