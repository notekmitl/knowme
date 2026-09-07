param([switch]$Extract)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:OR5R_CAPTURE_BASELINE -eq '1') { throw 'Baseline capture is prohibited.' }
$logDir = 'build/pr115-or8-validation'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
  if ($Extract) {
    & powershell -ExecutionPolicy Bypass -File tool/pr115_or7_validation.ps1 -Extract 2>&1 | Tee-Object -FilePath "$logDir/or7-neutral-equivalence.log"
  } else {
    & powershell -ExecutionPolicy Bypass -File tool/pr115_or7_validation.ps1 2>&1 | Tee-Object -FilePath "$logDir/or7-neutral-equivalence.log"
  }
  $or7ExitCode = $LASTEXITCODE
} finally {
  $ErrorActionPreference = $previousErrorActionPreference
}
if ($or7ExitCode -ne 0) { throw 'Existing Neutral V2/evidence/oracle, OR6 and OR7 validation failed' }

& node tool/pr115_or8_content_candidate.mjs 2>&1 | Tee-Object -FilePath "$logDir/candidate-build.log"
if ($LASTEXITCODE -ne 0) { throw 'Candidate 0022 exact-copy evidence build failed' }

& node --test --test-reporter=tap test/evidence/pr115_or8_content_candidate.test.mjs 2>&1 | Tee-Object -FilePath "$logDir/or8-tests.tap"
if ($LASTEXITCODE -ne 0) { throw 'OR8 content/evidence tests failed' }

& git diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed' }
