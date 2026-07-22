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
    --dart-define=ASTROLOGY_API_BASE_URL=$ApiBaseUrl `
    --dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=invited_beta
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$Bundle = Join-Path $RepoRoot "build\web\main.dart.js"
if (-not (Test-Path $Bundle)) {
    throw "Build output missing: $Bundle"
}
$BundleText = Get-Content $Bundle -Raw
$ForbiddenPatterns = @(
    "http://127.0.0.1",
    "http://localhost",
    "127.0.0.1:8000",
    "localhost:8000"
)
foreach ($pattern in $ForbiddenPatterns) {
    if ($BundleText -match $pattern) {
        throw "Compiled bundle contains forbidden pattern '$pattern'. Deployment blocked."
    }
}
if ($BundleText -notmatch "knowme-astrology-api") {
    throw "Compiled bundle missing production Cloud Run API host."
}
Write-Host "Verified: production bundle passes API localhost guard and contains Cloud Run API host."

$ValidateScript = Join-Path $RepoRoot "scripts\validate_production_web_bundle.ps1"
& $ValidateScript -BundlePath $Bundle
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Bust immutable browser caches of main.dart.js. Firebase Hosting previously
# served entrypoint JS as `max-age=31536000, immutable`, so returning users kept
# old AuthGate/Login shells after Public Beta fixes. Query-pin the entrypoint to
# the deployed git SHA so flutter_bootstrap always fetches the new bundle.
$DeploySha = (& git rev-parse --short HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($DeploySha)) {
    throw "Unable to resolve git SHA for main.dart.js cache bust."
}
$BootstrapPath = Join-Path $RepoRoot "build\web\flutter_bootstrap.js"
if (-not (Test-Path $BootstrapPath)) {
    throw "Build output missing: $BootstrapPath"
}
$BootstrapText = Get-Content -LiteralPath $BootstrapPath -Raw
$Busted = "main.dart.js?v=$DeploySha"
if ($BootstrapText -notmatch [regex]::Escape('main.dart.js')) {
    throw "flutter_bootstrap.js does not reference main.dart.js"
}
$BootstrapText = $BootstrapText -replace 'main\.dart\.js(\?v=[0-9a-fA-F]+)?', $Busted
Set-Content -LiteralPath $BootstrapPath -Value $BootstrapText -NoNewline
Write-Host "Cache-bust entrypoint: $Busted"

$IndexPath = Join-Path $RepoRoot "build\web\index.html"
if (-not (Test-Path $IndexPath)) {
    throw "Build output missing: $IndexPath"
}
$IndexText = Get-Content -LiteralPath $IndexPath -Raw
$BootstrapRef = "flutter_bootstrap.js?v=$DeploySha"
if ($IndexText -notmatch 'flutter_bootstrap\.js') {
    throw "index.html does not reference flutter_bootstrap.js"
}
$IndexText = $IndexText -replace 'flutter_bootstrap\.js(\?v=[0-9a-fA-F]+)?', $BootstrapRef
Set-Content -LiteralPath $IndexPath -Value $IndexText -NoNewline
Write-Host "Cache-bust bootstrap: $BootstrapRef"

Write-Host "Deploying Firestore rules (knowme-app-694e1)..."
firebase deploy --only firestore:rules --project knowme-app-694e1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Deploying to Firebase Hosting (knowme-app-694e1)..."
firebase deploy --only hosting --project knowme-app-694e1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Done. Public URLs:"
Write-Host "  https://knowme-app-694e1.web.app"
Write-Host "  https://knowme-app-694e1.firebaseapp.com"
Write-Host "Astrology API: $ApiBaseUrl"
