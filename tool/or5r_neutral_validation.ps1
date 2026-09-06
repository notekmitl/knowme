param([switch]$Extract)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:OR5R_CAPTURE_BASELINE -eq '1') { throw 'Baseline capture is prohibited for this read-only evidence task.' }
$logDir = 'build/or5r-neutral-validation'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
if ($Extract) {
  $previousOutput = $env:OR5_OUTPUT_DIR
  try {
    foreach ($run in 1,2) {
      $env:OR5_OUTPUT_DIR = "build/or5r-neutral-v2-run$run"
      & flutter test --no-pub --concurrency=1 test/evidence/predictive_runtime_v2_or5_actual_input_export_test.dart --name 'OR5 actual raw extraction|OR5 accepted Candidate0011' 2>&1 | Tee-Object -FilePath "$logDir/extraction-$run.log"
      if ($LASTEXITCODE -ne 0) { throw "Extraction $run failed" }
    }
  } finally { $env:OR5_OUTPUT_DIR = $previousOutput }
}
& node --test --test-reporter=tap test/evidence/or5r_actual_authority_v2.test.mjs test/evidence/candidate_0011_oracle.test.mjs test/evidence/candidate_0011_rule_map.test.mjs test/evidence/thai_predictive_evidence_v1.test.mjs 2>&1 | Tee-Object -FilePath "$logDir/node-tests.tap"
if ($LASTEXITCODE -ne 0) { throw 'Evidence/oracle tests failed' }
& git diff --check
if ($LASTEXITCODE -ne 0) { throw 'Diff check failed' }
