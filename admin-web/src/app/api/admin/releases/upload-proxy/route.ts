import { NextResponse } from 'next/server';
import { withAdminRoute } from '@/server/http/guard';

export async function PUT(req: Request) {
  return withAdminRoute(
    req,
    {
      permission: 'release.manage',
      requireStepUp: true,
      requirePrimarySuperAdmin: true,
    },
    async ({ repo }) => {
      const url = new URL(req.url);
      const storagePath = url.searchParams.get('storagePath')?.trim() ?? '';
      if (!storagePath.startsWith('staging/') || storagePath.includes('..')) {
        return NextResponse.json(
          { error: { code: 'INVALID_STORAGE_PATH', message: 'Invalid staging upload path.' } },
          { status: 400 }
        );
      }

      const arr = await req.arrayBuffer();
      const bytes = Buffer.from(arr);
      if (bytes.length === 0 || bytes.length > 150 * 1024 * 1024) {
        return NextResponse.json(
          { error: { code: 'INVALID_APK_SIZE', message: 'APK size must be between 1 byte and 150 MB.' } },
          { status: 400 }
        );
      }

      await repo.uploadApkObjectDirect({
        storagePath,
        bytes,
        contentType: 'application/vnd.android.package-archive',
      });

      return NextResponse.json({ ok: true, storagePath, fileSizeBytes: bytes.length });
    }
  );
}

