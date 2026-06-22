# KnowMe Public Web Deploy — Firebase Hosting
# Usage: .\scripts\deploy_web.ps1

$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

Write-Host "Building Flutter web (release)..."
flutter build web --release --no-wasm-dry-run
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Deploying to Firebase Hosting (knowme-app-694e1)..."
firebase deploy --only hosting --project knowme-app-694e1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Done. Public URLs:"
Write-Host "  https://knowme-app-694e1.web.app"
Write-Host "  https://knowme-app-694e1.firebaseapp.com"
