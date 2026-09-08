param([switch]$Extract)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
if ($env:OR5R_CAPTURE_BASELINE -eq '1') { throw 'Baseline capture is prohibited.' }
$logDir = 'build/pr115-or6-validation'
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
if ($Extract) {
  $flutterCommand = Get-Command flutter -ErrorAction Stop
  $flutterRoot = Split-Path (Split-Path $flutterCommand.Source -Parent) -Parent
  $flutterTools = Join-Path $flutterRoot 'packages/flutter_tools'
  $flutterSnapshot = Join-Path $flutterRoot 'bin/cache/flutter_tools.snapshot'
  $dart = Join-Path $flutterRoot 'bin/cache/dart-sdk/bin/dart.exe'
  $flutterAppData = Join-Path $logDir 'flutter-appdata'
  New-Item -ItemType Directory -Force -Path $flutterAppData | Out-Null
  $previousAppData = $env:APPDATA
  $previousAlreadyLocked = $env:FLUTTER_ALREADY_LOCKED
  $previousCi = $env:CI
  $previousOutput = $env:OR5_OUTPUT_DIR
  try {
    $env:APPDATA = (Resolve-Path $flutterAppData).Path
    $env:FLUTTER_ALREADY_LOCKED = 'true'
    $env:CI = 'true'
    foreach ($run in 1,2) {
      $env:OR5_OUTPUT_DIR = "build/or5r-neutral-v2-run$run"
      & $dart --packages="$flutterTools/.dart_tool/package_config.json" $flutterSnapshot test --no-pub --concurrency=1 test/evidence/predictive_runtime_v2_or5_actual_input_export_test.dart --name 'OR5 actual raw extraction|OR5 accepted Candidate0011' 2>&1 | Tee-Object -FilePath "$logDir/extraction-$run.log"
      if ($LASTEXITCODE -ne 0) { throw "Extraction $run failed" }
    }
  } finally {
    $env:APPDATA = $previousAppData
    $env:FLUTTER_ALREADY_LOCKED = $previousAlreadyLocked
    $env:CI = $previousCi
    $env:OR5_OUTPUT_DIR = $previousOutput
  }
}
$previousErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
  & powershell -ExecutionPolicy Bypass -File tool/or5r_neutral_validation.ps1 2>&1 | Tee-Object -FilePath "$logDir/neutral-v2.log"
  $neutralExitCode = $LASTEXITCODE
} finally {
  $ErrorActionPreference = $previousErrorActionPreference
}
if ($neutralExitCode -ne 0) { throw 'Neutral V2 / existing evidence-oracle validation failed' }
& node tool/pr115_or6_content_candidate.mjs 2>&1 | Tee-Object -FilePath "$logDir/candidate-build.log"
if ($LASTEXITCODE -ne 0) { throw 'Candidate build/schema/content audit failed' }
& node --test --test-reporter=tap test/evidence/pr115_or6_content_candidate.test.mjs 2>&1 | Tee-Object -FilePath "$logDir/or6-tests.tap"
if ($LASTEXITCODE -ne 0) { throw 'OR6 candidate/equivalence tests failed' }
& git diff --check
if ($LASTEXITCODE -ne 0) { throw 'git diff --check failed' }
