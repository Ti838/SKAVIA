import { expect, test } from '@playwright/test';

const EIGHT_BRANCH_NAMES = [
  'SKAVIA Home',
  'SKAVIA Agriculture',
  'SKAVIA Technical',
  'SKAVIA Logistics',
  'SKAVIA Digital',
  'SKAVIA Business',
  'SKAVIA Construction',
  'SKAVIA Events',
];

test.describe('SKAVIA 4-Surface Architecture E2E Security & UI', () => {
  test('public website renders official branding, 8 branches, download info & legal links with zero admin exposure', async ({
    page,
  }) => {
    await page.goto('/');
    await expect(page.getByRole('heading', { name: /Explain Your Requirement\./i })).toBeVisible();
    await expect(page.getByAltText('SKAVIA Official Emblem').first()).toBeVisible();
    await expect(page.getByRole('link', { name: /Download SKAVIA App/i })).toBeVisible();

    // Verify all 8 specialization branches are displayed
    for (const branchName of EIGHT_BRANCH_NAMES) {
      await expect(page.getByText(branchName).first()).toBeVisible();
    }

    // Zero admin login or dashboard links on public site
    await expect(page.locator('a[href*="/login"], a[href*="/dashboard"], a[href*="/admins"]')).toHaveCount(0);

    // Legal pages accessible
    await page.getByRole('link', { name: 'Privacy Policy' }).click();
    await expect(page).toHaveURL(/\/privacy$/);
    await expect(page.getByRole('heading', { name: /Privacy Policy/i })).toBeVisible();

    await page.goto('/');
    await page.getByRole('link', { name: 'Terms & Conditions' }).click();
    await expect(page).toHaveURL(/\/terms$/);
    await expect(page.getByRole('heading', { name: /Terms/i })).toBeVisible();

    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth > window.innerWidth
    );
    expect(overflow).toBe(false);
  });

  test('/login renders surface-aware Super Admin & Internal Admin modes without public signup', async ({
    page,
  }) => {
    await page.goto('/login');
    await expect(page.getByRole('heading', { name: 'SKAVIA Admin Portal' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Super Admin Portal' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Internal Admin Portal' })).toBeVisible();
    await expect(page.getByLabel('Invited Admin Email')).toBeVisible();
    await expect(page.getByLabel('Password')).toBeVisible();
    await expect(page.getByRole('button', { name: /Passkey \/ Biometric/i })).toBeVisible();
    await expect(page.getByRole('button', { name: /Google Workspace/i })).toBeVisible();

    // Toggle to Super Admin surface view locally
    await page.getByRole('button', { name: 'Super Admin Portal' }).click();
    await expect(page.getByRole('heading', { name: 'SKAVIA Super Admin' })).toBeVisible();
    await expect(page.getByLabel('Super Admin Username or Email')).toBeVisible();

    // No public self-signup routes on admin login
    await expect(page.getByText(/Create Account|Register Now/i)).toHaveCount(0);

    const overflow = await page.evaluate(
      () => document.documentElement.scrollWidth > window.innerWidth
    );
    expect(overflow).toBe(false);
  });

  test('/activate cleanly rejects missing or invalid invitation tokens', async ({ page }) => {
    await page.goto('/activate');
    await expect(page.getByText(/Invitation Unavailable/i)).toBeVisible();
    await expect(page.getByText(/No activation token found in this link/i)).toBeVisible();

    await page.goto('/activate?token=invalid_token_value_1234567890123456');
    await expect(page.getByText(/Invitation Unavailable/i)).toBeVisible();
    await expect(page.getByLabel('Confirm Password')).toHaveCount(0);
  });

  test('unauthenticated /dashboard redirects to /login without exposing portal chrome', async ({
    page,
  }) => {
    await page.goto('/dashboard');
    await expect(page).toHaveURL(/\/login$/);
    await expect(page.getByRole('heading', { name: 'SKAVIA Admin Portal' })).toBeVisible();
    // Unauthenticated /releases redirects to /login
    await page.goto('/releases');
    await expect(page).toHaveURL(/\/login$/);
  });

  test('protected API routes fail closed and www.skavia.com blocks admin surfaces', async ({
    request,
  }) => {
    for (const endpoint of [
      '/api/admin/dashboard',
      '/api/admin/customers',
      '/api/admin/workers',
      '/api/admin/verifications',
      '/api/admin/finance',
      '/api/admin/admins',
      '/api/admin/invitations',
      '/api/admin/security/overview',
      '/api/admin/releases',
    ]) {
      const res = await request.get(endpoint);
      expect([401, 503]).toContain(res.status());
      const body = await res.json();
      expect(body.error).toBeTruthy();
      expect(body.error.correlationId).toBeTruthy();
    }

    // Strict public hostname checks via Edge middleware
    const publicDashboard = await request.get('/dashboard', {
      headers: { 'x-forwarded-host': 'www.skavia.com' },
      maxRedirects: 0,
    });
    expect(publicDashboard.status()).toBe(404);

    const publicReleases = await request.get('/releases', {
      headers: { 'x-forwarded-host': 'www.skavia.com' },
      maxRedirects: 0,
    });
    expect(publicReleases.status()).toBe(404);

    const publicAdminApi = await request.get('/api/admin/dashboard', {
      headers: { 'x-forwarded-host': 'www.skavia.com' },
      maxRedirects: 0,
    });
    expect(publicAdminApi.status()).toBe(403);
    const body = await publicAdminApi.json();
    expect(body.error.code).toBe('SURFACE_FORBIDDEN');

    const publicDist = await request.get('/api/public/distribution');
    expect(publicDist.status()).toBe(200);
    const distJson = await publicDist.json();
    expect(distJson.android).toBeTruthy();

    const publicUpdate = await request.get(
      '/api/public/app-update?platform=android&channel=stable&build=1'
    );
    expect([200, 503]).toContain(publicUpdate.status());
  });
});
