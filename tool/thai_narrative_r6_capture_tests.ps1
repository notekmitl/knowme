param(
  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$encoding = [System.Text.UTF8Encoding]::new($false)
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
$outputDirectory = [System.IO.Path]::GetDirectoryName($resolvedOutput)
[System.IO.Directory]::CreateDirectory($outputDirectory) | Out-Null

$lines = & flutter test `
  'test/validation/thai_beta/narrative' `
  'test/validation/thai_beta/core_reading' `
  'test/validation/thai_beta/thai_beta_report_export_test.dart' `
  'test/validation/thai_beta/synthetic_audit/thai_beta_synthetic_audit_300_test.dart' `
  --reporter expanded 2>&1
$exitCode = $LASTEXITCODE
$text = ($lines | ForEach-Object { $_.ToString() }) -join "`n"
[System.IO.File]::WriteAllText($resolvedOutput, "$text`n", $encoding)
$lines | ForEach-Object { Write-Output $_ }
exit $exitCode
