import { createHash } from 'node:crypto';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { SignJWT } from 'jose';
import { POST as loginSession } from '@/app/api/admin/auth/session/route';
import { POST as verifyStepUp } from '@/app/api/admin/auth/step-up/route';
import { GET as listReleasesRoute, POST as createReleaseRoute } from '@/app/api/admin/releases/route';
import { POST as uploadSessionRoute } from '@/app/api/admin/releases/upload-session/route';
import { PUT as uploadProxyRoute } from '@/app/api/admin/releases/upload-proxy/route';
import { POST as inspectReleaseRoute } from '@/app/api/admin/releases/inspect/route';
import { POST as releaseActionRoute } from '@/app/api/admin/releases/[releaseId]/action/route';
import { DELETE as deleteReleaseRoute } from '@/app/api/admin/releases/[releaseId]/route';
import { GET as publicDistributionRoute } from '@/app/api/public/distribution/route';
import { GET as publicUpdateCheckRoute, POST as publicUpdateTelemetryRoute } from '@/app/api/public/app-update/route';
import { GET as publicApkDownloadRoute } from '@/app/api/public/releases/[releaseId]/download/route';
import { setTestAdminRepository } from '@/server/db/store-factory';
import { inspectApkBuffer } from '@/server/releases/apk-inspector';
import { InMemoryAdminRepository, TEST_IDS } from '../helpers/in-memory-store';
import {
  buildTestApkBuffer,
  TEST_CERT_A_DER,
  TEST_CERT_A_SHA256,
  TEST_CERT_B_DER,
} from '../helpers/apk-fixture';

const TEST_SECRET = 'vitest-admin-session-secret-minimum-32-chars-ok';

async function makeTestFirebaseToken(
  uid: string,
  email: string,
  mfaMethod: string | null = 'totp'
): Promise<string> {
  const key = new TextEncoder().encode(TEST_SECRET);
  const jwt = await new SignJWT({
    email,
    ...(mfaMethod ? { mfa_method: mfaMethod } : {}),
  })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(uid)
    .setIssuer('skavia-test-harness')
    .setAudience('skavia-113a3')
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(key);

  return `test-harness.${jwt}`;
}

async function loginWithStepUp(options: {
  uid: string;
  email: string;
  host: string;
  surface: 'superadmin' | 'admin';
}) {
  const token = await makeTestFirebaseToken(options.uid, options.email, 'totp');
  const loginRes = await loginSession(
    new Request(`http://${options.host}/api/admin/auth/session`, {
      method: 'POST',
      headers: {
        host: options.host,
        'content-type': 'application/json',
        'x-forwarded-for': '203.0.113.10',
      },
      body: JSON.stringify({
        idToken: token,
        deviceLabel: 'Vitest Release Runner',
        surface: options.surface,
      }),
    })
  );
  expect(loginRes.status).toBe(200);
  const rawCookie = (loginRes.headers.get('set-cookie') || '').split(';')[0] || '';

  const stepRes = await verifyStepUp(
    new Request(`http://${options.host}/api/admin/auth/step-up`, {
      method: 'POST',
      headers: {
        host: options.host,
        cookie: rawCookie,
        'content-type': 'application/json',
      },
      body: JSON.stringify({ idToken: token }),
    })
  );
  expect(stepRes.status).toBe(200);
  const stepCookie = (stepRes.headers.get('set-cookie') || '').split(';')[0] || rawCookie;
  return { cookie: stepCookie };
}

async function uploadApkViaSession(
  cookie: string,
  fileName: string,
  apkBytes: Buffer,
  channel: 'stable' | 'beta' | 'internal' = 'stable'
): Promise<string> {
  const sessRes = await uploadSessionRoute(
    new Request('http://superadmin.skavia.com/api/admin/releases/upload-session', {
      method: 'POST',
      headers: {
        host: 'superadmin.skavia.com',
        cookie,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        fileName,
        fileSizeBytes: apkBytes.length,
        channel,
      }),
    })
  );
  expect(sessRes.status).toBe(200);
  const { uploadSession } = (await sessRes.json()) as {
    uploadSession: { storagePath: string };
  };

  const putRes = await uploadProxyRoute(
    new Request(
      `http://superadmin.skavia.com/api/admin/releases/upload-proxy?storagePath=${encodeURIComponent(
        uploadSession.storagePath
      )}`,
      {
        method: 'PUT',
        headers: {
          host: 'superadmin.skavia.com',
          cookie,
          'content-type': 'application/vnd.android.package-archive',
        },
        body: new Uint8Array(apkBytes),
      }
    )
  );
  expect(putRes.status).toBe(200);
  return uploadSession.storagePath;
}

describe('SKAVIA App Release Management & APK Distribution', () => {
  let repo: InMemoryAdminRepository;

  beforeEach(() => {
    process.env.ADMIN_SESSION_SECRET = TEST_SECRET;
    process.env.PRIMARY_SUPER_ADMIN_UID = TEST_IDS.users.superAdmin;
    repo = new InMemoryAdminRepository();
    setTestAdminRepository(repo);
  });

  afterEach(() => {
    setTestAdminRepository(null);
  });

  it('cryptographically inspects valid signed APK metadata and rejects corrupted/unsigned APKs', () => {
    const validApk = buildTestApkBuffer({
      packageName: 'com.example.skavia',
      versionName: '1.2.0',
      buildNumber: 12,
      minSdkVersion: 23,
      targetSdkVersion: 35,
      certDer: TEST_CERT_A_DER,
    });

    const parsed = inspectApkBuffer(validApk);
    expect(parsed.packageName).toBe('com.example.skavia');
    expect(parsed.versionName).toBe('1.2.0');
    expect(parsed.buildNumber).toBe(12);
    expect(parsed.minSdkVersion).toBe(23);
    expect(parsed.targetSdkVersion).toBe(35);
    expect(parsed.fileSizeBytes).toBe(validApk.length);
    expect(parsed.sha256Checksum).toBe(
      createHash('sha256').update(validApk).digest('hex').toLowerCase()
    );
    expect(parsed.signingCertSha256).toBe(TEST_CERT_A_SHA256);
    expect(parsed.signingSchemes).toContain('v2');
    expect(parsed.hasAndroidManifest).toBe(true);
    expect(parsed.hasDex).toBe(true);

    const unsignedApk = buildTestApkBuffer({ certDer: null });
    const parsedUnsigned = inspectApkBuffer(unsignedApk);
    expect(parsedUnsigned.signingCertSha256).toBeNull();

    expect(() => inspectApkBuffer(Buffer.from('not-a-zip-file'))).toThrow();
  });

  it('blocks non-Super-Admin roles, wrong package IDs, mismatched signing certificates, duplicate builds, and unpublished APK downloads', async () => {
    const superAdmin = await loginWithStepUp({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'superadmin.skavia.com',
      surface: 'superadmin',
    });

    const companyAdmin = await loginWithStepUp({
      uid: TEST_IDS.users.companyAdmin,
      email: 'ops@skavia.com',
      host: 'admin.skavia.com',
      surface: 'admin',
    });

    // Company Admin cannot view or manage releases
    const caListRes = await listReleasesRoute(
      new Request('http://admin.skavia.com/api/admin/releases', {
        headers: { host: 'admin.skavia.com', cookie: companyAdmin.cookie },
      })
    );
    expect(caListRes.status).toBe(403);

    // 1. Wrong package name rejected
    const wrongPkgApk = buildTestApkBuffer({
      packageName: 'com.evil.clone',
      versionName: '1.0.0',
      buildNumber: 1,
      certDer: TEST_CERT_A_DER,
    });
    const wrongPkgPath = await uploadApkViaSession(superAdmin.cookie, 'wrong.apk', wrongPkgApk);
    const wrongPkgCreate = await createReleaseRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases', {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          storagePath: wrongPkgPath,
          fileName: 'wrong.apk',
          channel: 'stable',
          versionName: '1.0.0',
          buildNumber: 1,
          minSupportedBuild: 1,
          releaseNotes: 'First official build release notes',
          allowInitialSigningPin: true,
        }),
      })
    );
    expect(wrongPkgCreate.status).toBe(422);
    expect(((await wrongPkgCreate.json()) as { error: { code: string } }).error.code).toBe(
      'WRONG_PACKAGE_ID'
    );

    // 2. Valid build #1 saved as validated draft -> public download MUST be blocked (403)
    const v1Apk = buildTestApkBuffer({
      packageName: 'com.example.skavia',
      versionName: '1.0.0',
      buildNumber: 1,
      certDer: TEST_CERT_A_DER,
    });
    const v1Path = await uploadApkViaSession(superAdmin.cookie, 'skavia-1.0.0.apk', v1Apk);
    const v1Inspect = await inspectReleaseRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases/inspect', {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({ storagePath: v1Path, channel: 'stable' }),
      })
    );
    expect(v1Inspect.status).toBe(200);

    const v1Create = await createReleaseRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases', {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          storagePath: v1Path,
          fileName: 'skavia-1.0.0.apk',
          channel: 'stable',
          versionName: '1.0.0',
          buildNumber: 1,
          minSupportedBuild: 1,
          releaseNotes: 'Initial verified release v1.0.0',
          publishImmediately: false,
          allowInitialSigningPin: true,
        }),
      })
    );
    expect(v1Create.status).toBe(201);
    const v1ReleaseId = ((await v1Create.json()) as { release: { release_id: string } }).release
      .release_id;

    // Draft / validated APK MUST NOT be publicly downloadable
    const blockedDraftDl = await publicApkDownloadRoute(
      new Request(`http://www.skavia.com/api/public/releases/${v1ReleaseId}/download`),
      { params: Promise.resolve({ releaseId: v1ReleaseId }) }
    );
    expect(blockedDraftDl.status).toBe(403);

    // Publish v1 -> now downloadable & live on /api/public/distribution
    const pubV1 = await releaseActionRoute(
      new Request(`http://superadmin.skavia.com/api/admin/releases/${v1ReleaseId}/action`, {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({ action: 'publish', notifyUsers: true, confirmed: true }),
      }),
      { params: Promise.resolve({ releaseId: v1ReleaseId }) }
    );
    expect(pubV1.status).toBe(200);

    // Historical published releases cannot be deleted
    const delPublished = await deleteReleaseRoute(
      new Request(`http://superadmin.skavia.com/api/admin/releases/${v1ReleaseId}`, {
        method: 'DELETE',
        headers: { host: 'superadmin.skavia.com', cookie: superAdmin.cookie },
      }),
      { params: Promise.resolve({ releaseId: v1ReleaseId }) }
    );
    expect(delPublished.status).toBe(409);

    // 3. Duplicate build #1 rejected
    const dupPath = await uploadApkViaSession(superAdmin.cookie, 'dup.apk', v1Apk);
    const dupRes = await createReleaseRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases', {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          storagePath: dupPath,
          fileName: 'dup.apk',
          channel: 'stable',
          versionName: '1.0.0',
          buildNumber: 1,
          minSupportedBuild: 1,
          releaseNotes: 'Duplicate build check',
        }),
      })
    );
    expect(dupRes.status).toBe(409);

    // 4. Signing certificate mismatch rejected now that Cert A is pinned
    const wrongCertApk = buildTestApkBuffer({
      packageName: 'com.example.skavia',
      versionName: '1.1.0',
      buildNumber: 2,
      certDer: TEST_CERT_B_DER,
    });
    const wrongCertPath = await uploadApkViaSession(
      superAdmin.cookie,
      'skavia-wrong-cert.apk',
      wrongCertApk
    );
    const wrongCertRes = await createReleaseRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases', {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          storagePath: wrongCertPath,
          fileName: 'skavia-wrong-cert.apk',
          channel: 'stable',
          versionName: '1.1.0',
          buildNumber: 2,
          minSupportedBuild: 1,
          releaseNotes: 'Signed with mismatched certificate',
        }),
      })
    );
    expect(wrongCertRes.status).toBe(422);
    expect(((await wrongCertRes.json()) as { error: { code: string } }).error.code).toBe(
      'SIGNING_CERT_MISMATCH'
    );
  });

  it('serves live public distribution, optional/mandatory update rules, safe rollback, and real analytics without redeploy', async () => {
    const superAdmin = await loginWithStepUp({
      uid: TEST_IDS.users.superAdmin,
      email: 'superadmin@skavia.com',
      host: 'superadmin.skavia.com',
      surface: 'superadmin',
    });

    // Publish v1.0.0+1
    const v1Apk = buildTestApkBuffer({
      packageName: 'com.example.skavia',
      versionName: '1.0.0',
      buildNumber: 1,
      certDer: TEST_CERT_A_DER,
    });
    const v1Path = await uploadApkViaSession(superAdmin.cookie, 'skavia-v1.0.0.apk', v1Apk);
    const v1Res = await createReleaseRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases', {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          storagePath: v1Path,
          fileName: 'skavia-v1.0.0.apk',
          channel: 'stable',
          versionName: '1.0.0',
          buildNumber: 1,
          minSupportedBuild: 1,
          releaseNotes: 'Initial production release',
          publishImmediately: true,
          allowInitialSigningPin: true,
        }),
      })
    );
    expect(v1Res.status).toBe(201);
    const v1Id = ((await v1Res.json()) as { release: { release_id: string } }).release.release_id;

    // Publish v2.0.0+3 with minSupportedBuild=2 and mandatory=true
    const v2Apk = buildTestApkBuffer({
      packageName: 'com.example.skavia',
      versionName: '2.0.0',
      buildNumber: 3,
      certDer: TEST_CERT_A_DER,
    });
    const v2Path = await uploadApkViaSession(superAdmin.cookie, 'skavia-v2.0.0.apk', v2Apk);
    const v2Res = await createReleaseRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases', {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          storagePath: v2Path,
          fileName: 'skavia-v2.0.0.apk',
          channel: 'stable',
          versionName: '2.0.0',
          buildNumber: 3,
          minSupportedBuild: 2,
          isMandatory: true,
          releaseNotes: 'Critical booking & escrow reliability upgrade.',
          publishImmediately: true,
        }),
      })
    );
    expect(v2Res.status).toBe(201);
    const v2Id = ((await v2Res.json()) as { release: { release_id: string } }).release.release_id;

    // Website /api/public/distribution serves v2.0.0+3 immediately
    const distV2 = await publicDistributionRoute(
      new Request('https://www.skavia.com/api/public/distribution')
    );
    const distV2Json = (await distV2.json()) as {
      android: { published: boolean; version: string; buildNumber: number; apkUrl: string; sha256Checksum: string };
    };
    expect(distV2Json.android.published).toBe(true);
    expect(distV2Json.android.version).toBe('2.0.0');
    expect(distV2Json.android.buildNumber).toBe(3);
    expect(distV2Json.android.apkUrl).toContain(`/api/public/releases/${v2Id}/download`);

    // Build 1 client checks in -> unsupported_installed_build (mandatory)
    const chk1 = await publicUpdateCheckRoute(
      new Request('https://www.skavia.com/api/public/app-update?platform=android&channel=stable&build=1&version=1.0.0&apiLevel=34')
    );
    const chk1Json = (await chk1.json()) as {
      updateStatus: string;
      isMandatory: boolean;
      latestRelease: { buildNumber: number };
    };
    expect(chk1Json.updateStatus).toBe('unsupported_installed_build');
    expect(chk1Json.isMandatory).toBe(true);
    expect(chk1Json.latestRelease.buildNumber).toBe(3);

    // Download v2 APK bytes & confirm checksum header
    const dlV2 = await publicApkDownloadRoute(
      new Request(`https://www.skavia.com/api/public/releases/${v2Id}/download`),
      { params: Promise.resolve({ releaseId: v2Id }) }
    );
    expect(dlV2.status).toBe(200);
    expect(dlV2.headers.get('content-type')).toBe('application/vnd.android.package-archive');
    const dlBuf = Buffer.from(await dlV2.arrayBuffer());
    expect(createHash('sha256').update(dlBuf).digest('hex').toLowerCase()).toBe(
      distV2Json.android.sha256Checksum
    );

    // Report telemetry event
    const telRes = await publicUpdateTelemetryRoute(
      new Request('https://www.skavia.com/api/public/app-update', {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          releaseId: v2Id,
          platform: 'android',
          channel: 'stable',
          installedBuild: 1,
          installedVersion: '1.0.0',
          targetBuild: 3,
          eventType: 'checksum_verified',
          androidApiLevel: 34,
        }),
      })
    );
    expect(telRes.status).toBe(200);

    // Rollback from v2 to v1
    const rbRes = await releaseActionRoute(
      new Request(`http://superadmin.skavia.com/api/admin/releases/${v2Id}/action`, {
        method: 'POST',
        headers: {
          host: 'superadmin.skavia.com',
          cookie: superAdmin.cookie,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          action: 'rollback',
          targetReleaseId: v1Id,
          reason: 'Regression detected on low-memory devices; rolling back to v1.0.0',
          confirmed: true,
        }),
      }),
      { params: Promise.resolve({ releaseId: v2Id }) }
    );
    expect(rbRes.status).toBe(200);

    // Public distribution immediately reverts to v1.0.0+1, and v2 APK download is now forbidden
    const distAfterRollback = await publicDistributionRoute(
      new Request('https://www.skavia.com/api/public/distribution')
    );
    const distRbJson = (await distAfterRollback.json()) as {
      android: { version: string; buildNumber: number };
    };
    expect(distRbJson.android.version).toBe('1.0.0');
    expect(distRbJson.android.buildNumber).toBe(1);

    const dlV2Blocked = await publicApkDownloadRoute(
      new Request(`https://www.skavia.com/api/public/releases/${v2Id}/download`),
      { params: Promise.resolve({ releaseId: v2Id }) }
    );
    expect(dlV2Blocked.status).toBe(403);

    // Devices running suspended build 3 get honest suspended notification
    const chkSuspended = await publicUpdateCheckRoute(
      new Request('https://www.skavia.com/api/public/app-update?platform=android&channel=stable&build=3&version=2.0.0')
    );
    const chkSuspendedJson = (await chkSuspended.json()) as {
      installedBuildSuspended: boolean;
      updateStatus: string;
    };
    expect(chkSuspendedJson.installedBuildSuspended).toBe(true);
    expect(chkSuspendedJson.updateStatus).toBe('suspended_installed_build');

    // Admin analytics reflect genuine telemetry events
    const listRes = await listReleasesRoute(
      new Request('http://superadmin.skavia.com/api/admin/releases', {
        headers: { host: 'superadmin.skavia.com', cookie: superAdmin.cookie },
      })
    );
    const listJson = (await listRes.json()) as {
      analytics: { totalCheckIns: number; totalDownloadsStarted: number; totalChecksumVerified: number };
    };
    expect(listJson.analytics.totalCheckIns).toBe(2);
    expect(listJson.analytics.totalDownloadsStarted).toBe(1);
    expect(listJson.analytics.totalChecksumVerified).toBe(1);
  });
});

