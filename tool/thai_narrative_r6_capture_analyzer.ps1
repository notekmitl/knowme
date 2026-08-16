param(
  [Parameter(Mandatory = $true)]
  [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$encoding = [System.Text.UTF8Encoding]::new($false)
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)
[System.IO.Directory]::CreateDirectory(
  [System.IO.Path]::GetDirectoryName($resolvedOutput)
) | Out-Null

$files = @(
  'lib/features/thai_beta/application/core_reading/thai_birth_profile_core_reading.dart',
  'lib/features/thai_beta/application/narrative/thai_beta_clause_repetition_audit.dart',
  'lib/features/thai_beta/application/narrative/thai_beta_narrative_composer.dart',
  'lib/features/thai_beta/application/narrative/thai_beta_past_reflection.dart',
  'lib/features/thai_beta/application/narrative/thai_beta_report_narrative_plan.dart',
  'test/validation/thai_beta/narrative/thai_beta_narrative_v15_r6_reader_quality_test.dart',
  'test/validation/thai_beta/narrative/thai_beta_v15_r4_acceptance_audit.dart',
  'test/validation/thai_beta/narrative/thai_consumer_narrative_acceptance_artifact_test.dart'
)
$lines = & dart analyze @files 2>&1
$exitCode = $LASTEXITCODE
$text = ($lines | ForEach-Object { $_.ToString() }) -join "`n"
[System.IO.File]::WriteAllText($resolvedOutput, "$text`n", $encoding)
$lines | ForEach-Object { Write-Output $_ }
exit $exitCode
