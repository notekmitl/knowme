# Verify KnowMe astrology API endpoints (health + generate-bazi + generate-chart)
# Usage:
#   .\scripts\verify_astrology_api.ps1
#   .\scripts\verify_astrology_api.ps1 -BaseUrl https://your-service.run.app

param(
    [string]$BaseUrl = ""
)

$ErrorActionPreference = "Stop"
$RepoRoot = Join-Path $PSScriptRoot ".."

if ([string]::IsNullOrWhiteSpace($BaseUrl)) {
    $ConfigPath = Join-Path $RepoRoot "config\astrology_api_base_url.txt"
    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Missing config/astrology_api_base_url.txt. Deploy API first or pass -BaseUrl."
    }
    $BaseUrl = (Get-Content $ConfigPath -Raw).Trim()
}

$BaseUrl = $BaseUrl.TrimEnd("/")
$VerifyScript = Join-Path $PSScriptRoot "verify_astrology_backend.py"

python $VerifyScript --base-url $BaseUrl
exit $LASTEXITCODE
