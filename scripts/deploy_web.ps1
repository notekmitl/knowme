# KnowMe Public Web Deploy — Firebase Hosting
# Usage: .\scripts\deploy_web.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Join-Path $PSScriptRoot ".."
Set-Location $RepoRoot

$ConfigPath = Join-Path $RepoRoot "config\astrology_api_base_url.txt"
if (-not (Test-Path $ConfigPath)) {
    throw "Missing $ConfigPath. Run .\scripts\deploy_astrology_api.ps1 first."
}

$ApiBaseUrl = (Get-Content $ConfigPath -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($ApiBaseUrl)) {
    throw "config/astrology_api_base_url.txt is empty. Deploy astrology API first."
}
if ($ApiBaseUrl -match "127\.0\.0\.1|localhost") {
    throw "Production API URL must not be localhost. Current value: $ApiBaseUrl"
}

Write-Host "Building Flutter web (release) with ASTROLOGY_API_BASE_URL=$ApiBaseUrl"
flutter build web --release --no-wasm-dry-run `
    --dart-define=ASTROLOGY_API_BASE_URL=$ApiBaseUrl
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$Bundle = Join-Path $RepoRoot "build\web\main.dart.js"
if (-not (Test-Path $Bundle)) {
    throw "Build output missing: $Bundle"
}
$BundleText = Get-Content $Bundle -Raw
if ($BundleText -match "127\.0\.0\.1:8000") {
    throw "Compiled bundle still contains localhost API URL. Build injection failed."
}
Write-Host "Verified: production bundle does not contain localhost API URL."

Write-Host "Deploying to Firebase Hosting (knowme-app-694e1)..."
firebase deploy --only hosting --project knowme-app-694e1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Done. Public URLs:"
Write-Host "  https://knowme-app-694e1.web.app"
Write-Host "  https://knowme-app-694e1.firebaseapp.com"
Write-Host "Astrology API: $ApiBaseUrl"
