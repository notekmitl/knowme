param([switch]$Extract)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:OR5R_CAPTURE_BASELINE -eq '1') { throw 'Baseline capture is prohibited.' }
$logDir = 'build/pr115-or7-validation'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
  if ($Extract) {
    & powershell -ExecutionPolicy Bypass -File tool/pr115_or6_validation.ps1 -Extract 2>&1 | Tee-Object -FilePath "$logDir/or6-neutral-equivalence.log"
  } else {
    & powershell -ExecutionPolicy Bypass -File tool/pr115_or6_validation.ps1 2>&1 | Tee-Object -FilePath "$logDir/or6-neutral-equivalence.log"
  }
  $or6ExitCode = $LASTEXITCODE
} finally {
  $ErrorActionPreference = $previousErrorActionPreference
}
if ($or6ExitCode -ne 0) { throw 'Existing Neutral V2/evidence/oracle and OR6 schema/equivalence validation failed' }

& node tool/pr115_or7_content_candidate.mjs 2>&1 | Tee-Object -FilePath "$logDir/candidate-build.log"
if ($LASTEXITCODE -ne 0) { throw 'Candidate 0021 build/schema/editorial audit failed' }

& node --test --test-reporter=tap test/evidence/pr115_or7_content_candidate.test.mjs 2>&1 | Tee-Object -FilePath "$logDir/or7-tests.tap"
if ($LASTEXITCODE -ne 0) { throw 'OR7 content/evidence tests failed' }

& git diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed' }
