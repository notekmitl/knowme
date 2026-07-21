# KnowMe Astrology API — Cloud Run deploy
# Usage: .\scripts\deploy_astrology_api.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Join-Path $PSScriptRoot ".."
Set-Location $RepoRoot

$ProjectId = "knowme-app-694e1"
$Region = "asia-southeast1"
$ServiceName = "knowme-astrology-api"

$Gcloud = "gcloud"
if (-not (Get-Command $Gcloud -ErrorAction SilentlyContinue)) {
    $Candidates = @(
        "${env:ProgramFiles(x86)}\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd",
        "$env:LOCALAPPDATA\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd"
    )
    foreach ($candidate in $Candidates) {
        if (Test-Path $candidate) {
            $Gcloud = $candidate
            break
        }
    }
    if ($Gcloud -eq "gcloud") {
        throw "gcloud CLI not found. Install Google Cloud SDK and run: gcloud auth login"
    }
}

Write-Host "Using gcloud: $Gcloud"
& $Gcloud config set project $ProjectId | Out-Null

Write-Host "Enabling required Google Cloud APIs..."
& $Gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com --project $ProjectId

Write-Host "Deploying to Cloud Run ($ServiceName)..."
& $Gcloud run deploy $ServiceName `
    --source (Join-Path $RepoRoot "backend") `
    --platform managed `
    --region $Region `
    --project $ProjectId `
    --allow-unauthenticated `
    --memory 512Mi `
    --cpu 1 `
    --min-instances 0 `
    --max-instances 10 `
    --timeout 120 `
    --port 8080 `
    --quiet `
    --set-env-vars "GOOGLE_CLOUD_PROJECT=$ProjectId"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$ServiceUrl = (& $Gcloud run services describe $ServiceName --region $Region --project $ProjectId --format "value(status.url)").Trim()
if ([string]::IsNullOrWhiteSpace($ServiceUrl)) {
    throw "Cloud Run deploy succeeded but service URL is empty"
}

$BaseUrl = $ServiceUrl.TrimEnd("/")
Write-Host "Production API URL: $BaseUrl"

$ConfigPath = Join-Path $RepoRoot "config\astrology_api_base_url.txt"
Set-Content -Path $ConfigPath -Value $BaseUrl -NoNewline
Write-Host "Wrote $ConfigPath"

$ProjectNumber = (& $Gcloud projects describe $ProjectId --format "value(projectNumber)").Trim()
$RunServiceAccount = "$ProjectNumber-compute@developer.gserviceaccount.com"
Write-Host "Granting Firestore access to $RunServiceAccount ..."
& $Gcloud projects add-iam-policy-binding $ProjectId `
    --member "serviceAccount:$RunServiceAccount" `
    --role "roles/datastore.user" `
    --quiet | Out-Null

Write-Host "Running backend verification..."
& (Join-Path $PSScriptRoot "verify_astrology_api.ps1") -BaseUrl $BaseUrl
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Done. Astrology API: $BaseUrl"
