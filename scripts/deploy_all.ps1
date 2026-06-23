# KnowMe full production deploy — Cloud Run API + Firebase Hosting web
# Usage: .\scripts\deploy_all.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Join-Path $PSScriptRoot ".."
Set-Location $RepoRoot

Write-Host "Step 1/2: Deploy astrology API to Cloud Run..."
& (Join-Path $PSScriptRoot "deploy_astrology_api.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Step 2/2: Build and deploy Flutter web..."
& (Join-Path $PSScriptRoot "deploy_web.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Full production deploy complete."
