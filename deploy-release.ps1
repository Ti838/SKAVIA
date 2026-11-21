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

Copy-Item $apkSource "admin-web\public\downloads\skavia-latest.apk" -Force
Copy-Item $apkSource "admin-web\public\downloads\skavia-v$versionName.apk" -Force
Write-Host "   ✅ Copied to skavia-latest.apk and skavia-v$versionName.apk" -ForegroundColor Green

# Generate staged-release.json for zero-friction 1-click admin approval
$stagedManifest = @{
    versionName = $versionName
    buildNumber = $buildNumber
    channel = "stable"
    apkUrl = "https://skavia-bd.vercel.app/downloads/skavia-v$versionName.apk"
    latestApkUrl = "https://skavia-bd.vercel.app/downloads/skavia-latest.apk"
    fileName = "skavia-v$versionName.apk"
    fileSizeBytes = $fileSizeBytes
    deployedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    releaseNotes = "- SKAVIA production release v$versionName (Build #$buildNumber)`n- Core reliability, low-latency API dispatch, and UI polish"
} | ConvertTo-Json -Depth 4
Set-Content -Path "admin-web\public\downloads\staged-release.json" -Value $stagedManifest -Encoding UTF8
Write-Host "   ✅ Generated staged-release.json for 1-click Admin Portal approval" -ForegroundColor Green

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
