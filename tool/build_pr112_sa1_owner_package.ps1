param(
  [Parameter(Mandatory = $true)][string]$ShortSha,
  [string]$OutputParent = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$name = "OWNER_REVIEW_THAI_REPORT_PREDICTIVE_NARRATIVE_V2_PHASE1_SA1_$ShortSha"
$packageRoot = Join-Path $OutputParent $name
$zipPath = "$packageRoot.zip"
$verifyRoot = Join-Path $OutputParent "$name`_verify"
$validationPath = Join-Path $OutputParent "$name.validation.json"

foreach ($target in @($packageRoot, $zipPath, $verifyRoot, $validationPath)) {
  if (Test-Path -LiteralPath $target) {
    throw "Refusing to overwrite existing package target: $target"
  }
}

New-Item -ItemType Directory -Path $packageRoot | Out-Null

$payload = [ordered]@{
  'OWNER_REVIEW.md' = 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_PHASE1_SA1_OWNER_REVIEW.md'
  'THAI_MAHABHUT_CANON_SOURCE_TRUTH_RECONCILIATION_V1.md' = 'docs/THAI_MAHABHUT_CANON_SOURCE_TRUTH_RECONCILIATION_V1.md'
  'THAI_MAHABHUT_PREDICTIVE_CANON_V2_CHARTER.md' = 'docs/THAI_MAHABHUT_PREDICTIVE_CANON_V2_CHARTER.md'
  'mahabhut_predictive_rules_v2.schema.json' = 'knowledge/canon/proposed/mahabhut_predictive_rules_v2.schema.json'
  'THAI_MAHABHUT_PREDICTIVE_RULE_EXTRACTION_MATRIX_V1.md' = 'docs/THAI_MAHABHUT_PREDICTIVE_RULE_EXTRACTION_MATRIX_V1.md'
  'mahabhut_predictive_rules_v2.json' = 'knowledge/canon/proposed/mahabhut_predictive_rules_v2.json'
  'THAI_MAHABHUT_DEEP_SEARCH_SUPPORTING_EVIDENCE_REGISTER_V1.md' = 'docs/THAI_MAHABHUT_DEEP_SEARCH_SUPPORTING_EVIDENCE_REGISTER_V1.md'
  'THAI_MAHABHUT_PREDICTIVE_EVENT_ONTOLOGY_MAPPING_V1.md' = 'docs/THAI_MAHABHUT_PREDICTIVE_EVENT_ONTOLOGY_MAPPING_V1.md'
  'THAI_MAHABHUT_PREDICTIVE_TIMING_MAPPING_V1.md' = 'docs/THAI_MAHABHUT_PREDICTIVE_TIMING_MAPPING_V1.md'
  'THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0007.md' = 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0007.md'
  'THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0007_UNKNOWN.md' = 'docs/THAI_REPORT_PREDICTIVE_NARRATIVE_V2_TARGET_CANDIDATE_0007_UNKNOWN.md'
  'THAI_MAHABHUT_PREDICTIVE_CANON_V2_GAP_BLOCKER_REPORT.md' = 'docs/THAI_MAHABHUT_PREDICTIVE_CANON_V2_GAP_BLOCKER_REPORT.md'
  'THAI_MAHABHUT_PREDICTIVE_CANON_V2_FINAL_DECISION.md' = 'docs/THAI_MAHABHUT_PREDICTIVE_CANON_V2_FINAL_DECISION.md'
  'THAI_MAHABHUT_PREDICTIVE_CANON_V2_SA1_VALIDATION.md' = 'docs/THAI_MAHABHUT_PREDICTIVE_CANON_V2_SA1_VALIDATION.md'
  'mahabhut_predictive_v2_validation.json' = 'tool/output/mahabhut_predictive_v2_validation.json'
}

foreach ($entry in $payload.GetEnumerator()) {
  Copy-Item -LiteralPath (Join-Path $repo $entry.Value) -Destination (Join-Path $packageRoot $entry.Key)
}

function FileRecord([string]$Path, [string]$RelativePath) {
  $item = Get-Item -LiteralPath $Path
  [ordered]@{
    path = $RelativePath.Replace('\', '/')
    size = $item.Length
    sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash
  }
}

$manifestRecords = @()
foreach ($nameInPackage in $payload.Keys) {
  $manifestRecords += FileRecord (Join-Path $packageRoot $nameInPackage) $nameInPackage
}
$manifest = [ordered]@{
  package = $name
  artifactCommit = $ShortSha
  decision = 'PARTIAL — SPECIFIC PAGES/OCR/MODELING BLOCKED'
  files = $manifestRecords
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $packageRoot 'MANIFEST.json') -Encoding UTF8

$sumTargets = @($payload.Keys) + @('MANIFEST.json')
$sumLines = foreach ($fileName in $sumTargets) {
  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $packageRoot $fileName)).Hash
  "$hash  $fileName"
}
$sumLines | Set-Content -LiteralPath (Join-Path $packageRoot 'SHA256SUMS.txt') -Encoding UTF8

Compress-Archive -LiteralPath $packageRoot -DestinationPath $zipPath -CompressionLevel Optimal

Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
$crcErrors = 0
try {
  foreach ($entry in $archive.Entries) {
    $stream = $entry.Open()
    try {
      $buffer = New-Object byte[] 65536
      while ($stream.Read($buffer, 0, $buffer.Length) -gt 0) {}
    } catch {
      $crcErrors++
    } finally {
      $stream.Dispose()
    }
  }
} finally {
  $archive.Dispose()
}

Expand-Archive -LiteralPath $zipPath -DestinationPath $verifyRoot
$extractedRoot = Join-Path $verifyRoot $name
$actualFiles = @(Get-ChildItem -LiteralPath $extractedRoot -File | Select-Object -ExpandProperty Name | Sort-Object)
$expectedFiles = @($payload.Keys) + @('MANIFEST.json', 'SHA256SUMS.txt') | Sort-Object
$missing = @($expectedFiles | Where-Object { $_ -notin $actualFiles })
$extra = @($actualFiles | Where-Object { $_ -notin $expectedFiles })

$manifestCheck = Get-Content -Raw -LiteralPath (Join-Path $extractedRoot 'MANIFEST.json') | ConvertFrom-Json
$manifestMissing = 0
$manifestHashMismatch = 0
$manifestSizeMismatch = 0
foreach ($record in $manifestCheck.files) {
  $path = Join-Path $extractedRoot $record.path
  if (-not (Test-Path -LiteralPath $path)) {
    $manifestMissing++
    continue
  }
  $item = Get-Item -LiteralPath $path
  if ($item.Length -ne $record.size) { $manifestSizeMismatch++ }
  if ((Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash -ne $record.sha256) { $manifestHashMismatch++ }
}

$sumMismatch = 0
foreach ($line in Get-Content -LiteralPath (Join-Path $extractedRoot 'SHA256SUMS.txt')) {
  if ($line -notmatch '^([A-F0-9]{64})  (.+)$') {
    $sumMismatch++
    continue
  }
  $expectedHash = $Matches[1]
  $relative = $Matches[2]
  $sumPath = Join-Path $extractedRoot $relative
  if (-not (Test-Path -LiteralPath $sumPath) -or (Get-FileHash -Algorithm SHA256 -LiteralPath $sumPath).Hash -ne $expectedHash) {
    $sumMismatch++
  }
}

$secretHits = 0
$placeholderHits = 0
$absolutePathHits = 0
foreach ($file in Get-ChildItem -LiteralPath $extractedRoot -File) {
  if ($file.Extension -notin @('.md', '.json', '.txt')) { continue }
  $text = Get-Content -Raw -LiteralPath $file.FullName
  $secretHits += @([regex]::Matches($text, 'AIza[0-9A-Za-z_-]{20,}|-----BEGIN [A-Z ]+PRIVATE KEY-----|(?i)(password|api[_-]?key)\s*[:=]\s*[^\s]+')).Count
  $placeholderHits += @([regex]::Matches($text, '(?i)\b(TODO|TBD|FIXME|REPLACE_ME)\b|<(shortsha|configured[^>]*)>')).Count
  $absolutePathHits += @([regex]::Matches($text, '(?m)(?:(?<![A-Za-z])[A-Za-z]:[\\/]|(?:^|[\s`"''])/(?:Users|home|tmp|var)/)')).Count
}

$validation = [ordered]@{
  package = $name
  zipSha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash
  zipBytes = (Get-Item -LiteralPath $zipPath).Length
  entries = $expectedFiles.Count
  crcErrors = $crcErrors
  extractionMissing = $missing.Count
  extractionExtra = $extra.Count
  manifestMissing = $manifestMissing
  manifestHashMismatch = $manifestHashMismatch
  manifestSizeMismatch = $manifestSizeMismatch
  sha256SumsMismatch = $sumMismatch
  secretHits = $secretHits
  placeholderHits = $placeholderHits
  absolutePathHits = $absolutePathHits
}
$validation | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $validationPath -Encoding UTF8

$errorCount = $crcErrors + $missing.Count + $extra.Count + $manifestMissing + $manifestHashMismatch + $manifestSizeMismatch + $sumMismatch + $secretHits + $placeholderHits + $absolutePathHits
if ($errorCount -ne 0) {
  $validation | ConvertTo-Json -Depth 4
  throw "Owner package validation failed with $errorCount error(s)."
}

$validation | ConvertTo-Json -Depth 4
