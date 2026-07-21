# Validates a Flutter web release bundle does not ship localhost API endpoints.
# Usage: .\scripts\validate_production_web_bundle.ps1 [-BundlePath build\web\main.dart.js]

param(
    [string]$BundlePath = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = Join-Path $PSScriptRoot ".."
if ([string]::IsNullOrWhiteSpace($BundlePath)) {
    $BundlePath = Join-Path $RepoRoot "build\web\main.dart.js"
}

if (-not (Test-Path $BundlePath)) {
    throw "Bundle not found: $BundlePath"
}

$BundleText = Get-Content $BundlePath -Raw
# Block astrology API leakage (P0 incident), not generic "localhost" in deps.
$ForbiddenPatterns = @(
    "http://127.0.0.1",
    "http://localhost",
    "127.0.0.1:8000",
    "localhost:8000"
)

$Hits = @()
foreach ($pattern in $ForbiddenPatterns) {
    if ($BundleText -match $pattern) {
        $Hits += $pattern
    }
}

if ($Hits.Count -gt 0) {
    Write-Error "Production bundle validation FAILED. Forbidden patterns found: $($Hits -join ', '). Bundle: $BundlePath"
    exit 1
}

if ($BundleText -notmatch "knowme-astrology-api") {
    Write-Error "Production bundle validation FAILED. Expected production Cloud Run host in bundle."
    exit 1
}

Write-Host "Production bundle validation PASSED."
Write-Host "  Bundle: $BundlePath"
Write-Host "  Forbidden patterns absent: $($ForbiddenPatterns -join ', ')"
Write-Host "  Production API host present: knowme-astrology-api"
exit 0
