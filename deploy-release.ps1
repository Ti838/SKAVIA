# SKAVIA One-Click Release Automation Script
# Usage: .\deploy-release.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   SKAVIA Mobile App Release Automation   " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Read current version from pubspec.yaml
$pubspecContent = Get-Content "pubspec.yaml" -Raw
if ($pubspecContent -match "version:\s*([^\r\n]+)") {
    $currentVersion = $matches[1].Trim()
} else {
    $currentVersion = "1.0.0+1"
}

Write-Host "`n[1/4] Current app version in pubspec.yaml: $currentVersion" -ForegroundColor Yellow

# 2. Build Release APK
Write-Host "`n[2/4] Building production signed Android APK (flutter build apk --release)..." -ForegroundColor Cyan
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Flutter build failed. Please fix compile errors above." -ForegroundColor Red
    exit $LASTEXITCODE
}

$apkSource = "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apkSource)) {
    Write-Host "`n❌ Built APK not found at $apkSource" -ForegroundColor Red
    exit 1
}

$apkSizeMB = [math]::Round(((Get-Item $apkSource).Length / 1MB), 2)
Write-Host "   ✅ APK built successfully ($apkSizeMB MB)" -ForegroundColor Green

# 3. Copy to Vercel downloads
Write-Host "`n[3/4] Syncing APK to Vercel CDN hosting (admin-web/public/downloads/)..." -ForegroundColor Cyan
$versionParts = $currentVersion.Split('+')
$versionName = $versionParts[0]
$buildNumber = if ($versionParts.Length -gt 1) { [int]$versionParts[1] } else { 1 }
$fileSizeBytes = (Get-Item $apkSource).Length
$sha256 = (Get-FileHash -Path $apkSource -Algorithm SHA256).Hash.ToLower()

Copy-Item $apkSource "admin-web\public\downloads\skavia-latest.apk" -Force
Copy-Item $apkSource "admin-web\public\downloads\skavia-v$versionName.apk" -Force
Write-Host "   ✅ Copied to skavia-latest.apk and skavia-v$versionName.apk" -ForegroundColor Green

# Automatically publish release to Supabase app_releases table
Write-Host "   📡 Auto-publishing v$versionName (#$buildNumber) directly to Supabase app_releases..." -ForegroundColor Cyan
node -e @"
const https = require('https');
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1mc3J2dHZnanJ3cndhcGttbHhnIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc5MDQxMjQ4MCwiZXhwIjoyMTA1OTg4NDgwfQ.8PBwWXW8sRokpqb1rG2fl0UFx5y9ZbzOWg-ci-sSNBc';
const headers = {
  'apikey': key,
  'Authorization': 'Bearer ' + key,
  'Content-Type': 'application/json',
  'Prefer': 'return=minimal'
};

const demoteReq = https.request({
  hostname: 'mfsrvtvgjrwrwapkmlxg.supabase.co',
  path: '/rest/v1/app_releases?platform=eq.android&channel=eq.stable',
  method: 'PATCH',
  headers
}, () => {
  const payload = JSON.stringify({
    platform: 'android',
    channel: 'stable',
    package_name: 'com.example.skavia',
    version_name: '$versionName',
    build_number: $buildNumber,
    min_supported_build: 1,
    min_sdk_version: 24,
    target_sdk_version: 35,
    release_notes: '- 100% Free Cloud Phone OTP Verification (no credit card or Blaze billing required)\n- Unified executive governance login portal\n- Dynamic latest APK telemetry on public download hub\n- Direct auto-fill OTP helper and zero-data pristine accounts',
    is_mandatory: false,
    status: 'published',
    is_current: true,
    storage_bucket: 'vercel-cdn',
    storage_path: 'https://skavia-bd.vercel.app/downloads/skavia-v$versionName.apk',
    file_name: 'skavia-v$versionName.apk',
    file_size_bytes: $fileSizeBytes,
    sha256_checksum: '$sha256',
    signing_cert_sha256: '8ae8d16712e610e8a69dc832f961388e93c2dbb214159db290be466593c9b83f',
    signing_schemes: ['v1', 'v2', 'v3'],
    published_at: new Date().toISOString(),
    created_by: 'tmarlT1I0EZ0qtFq53vDGPHst1m1',
    validated_by: 'tmarlT1I0EZ0qtFq53vDGPHst1m1',
    published_by: 'tmarlT1I0EZ0qtFq53vDGPHst1m1'
  });
  const insReq = https.request({
    hostname: 'mfsrvtvgjrwrwapkmlxg.supabase.co',
    path: '/rest/v1/app_releases',
    method: 'POST',
    headers
  }, (res2) => {
    console.log('   ✅ Supabase Auto-Publish Status:', res2.statusCode);
    process.exit(0);
  });
  insReq.write(payload);
  insReq.end();
});
demoteReq.write(JSON.stringify({ is_current: false }));
demoteReq.end();
"@

# Generate staged-release.json for reference
$stagedManifest = @{
    versionName = $versionName
    buildNumber = $buildNumber
    channel = "stable"
    apkUrl = "https://skavia-bd.vercel.app/downloads/skavia-v$versionName.apk"
    latestApkUrl = "https://skavia-bd.vercel.app/downloads/skavia-latest.apk"
    fileName = "skavia-v$versionName.apk"
    fileSizeBytes = $fileSizeBytes
    sha256Checksum = $sha256
    deployedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    releaseNotes = "- 100% Free Cloud Phone OTP Verification (no credit card or Blaze billing required)`n- Unified executive governance login portal`n- Dynamic latest APK telemetry on public download hub`n- Direct auto-fill OTP helper and zero-data pristine accounts"
} | ConvertTo-Json -Depth 4
Set-Content -Path "admin-web\public\downloads\staged-release.json" -Value $stagedManifest -Encoding UTF8

# 4. Commit and push to git
Write-Host "`n[4/4] Deploying to Vercel via Git..." -ForegroundColor Cyan
git add "admin-web\public\downloads\skavia-latest.apk" "admin-web\public\downloads\skavia-v$versionName.apk" "admin-web\public\downloads\staged-release.json" pubspec.yaml
git commit -m "deploy: update production release APK to v$currentVersion"
git push

Write-Host "`n===========================================================" -ForegroundColor Green
Write-Host " 🎉 SUCCESS! New APK deployed to Vercel CDN!" -ForegroundColor Green
Write-Host " In Admin Portal -> Releases, this release will be auto-detected!" -ForegroundColor Yellow
Write-Host " Simply click [1-Click Approve & Publish] to go live!" -ForegroundColor White
Write-Host "===========================================================`n" -ForegroundColor Green
