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
$versionName = $currentVersion.Split('+')[0]
Copy-Item $apkSource "admin-web\public\downloads\skavia-latest.apk" -Force
Copy-Item $apkSource "admin-web\public\downloads\skavia-v$versionName.apk" -Force
Write-Host "   ✅ Copied to skavia-latest.apk and skavia-v$versionName.apk" -ForegroundColor Green

# 4. Commit and push to git
Write-Host "`n[4/4] Deploying to Vercel via Git..." -ForegroundColor Cyan
git add "admin-web\public\downloads\skavia-latest.apk" "admin-web\public\downloads\skavia-v$versionName.apk" pubspec.yaml
git commit -m "deploy: update production release APK to v$currentVersion"
git push

Write-Host "`n===========================================================" -ForegroundColor Green
Write-Host " 🎉 SUCCESS! New APK deployed to Vercel CDN!" -ForegroundColor Green
Write-Host " Now open Admin Portal -> Releases -> Publish New APK:" -ForegroundColor White
Write-Host " URL: https://skavia-bd.vercel.app/downloads/skavia-latest.apk" -ForegroundColor Yellow
Write-Host " Click: [Inspect & Verify URL] -> [Publish Release]" -ForegroundColor White
Write-Host "===========================================================`n" -ForegroundColor Green
