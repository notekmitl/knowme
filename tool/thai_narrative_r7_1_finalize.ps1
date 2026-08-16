param(
  [string]$R7Root = 'product-acceptance/thai-narrative-v1.5-r7',
  [string]$R71Root = 'product-acceptance/thai-narrative-v1.5-r7.1',
  [string]$PdfInfo = 'C:\Users\USER\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\poppler\Library\bin\pdfinfo.exe'
)

$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSVersion.Major -lt 7) {
  throw 'R7.1 finalizer requires PowerShell 7 or newer.'
}
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$repositoryRoot = (Resolve-Path -LiteralPath '.').Path
$productRoot = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'product-acceptance'))
$r7 = (Resolve-Path -LiteralPath $R7Root).Path
$r71 = (Resolve-Path -LiteralPath $R71Root).Path
$expectedR7 = [System.IO.Path]::GetFullPath((Join-Path $productRoot 'thai-narrative-v1.5-r7'))
$expectedR71 = [System.IO.Path]::GetFullPath((Join-Path $productRoot 'thai-narrative-v1.5-r7.1'))
$staging = [System.IO.Path]::GetFullPath((Join-Path $productRoot '.thai-narrative-v1.5-r7.1-staging'))
$zipPath = [System.IO.Path]::GetFullPath((Join-Path $productRoot 'thai-narrative-v1.5-r7.1.zip'))
$packageIdentityPath = [System.IO.Path]::GetFullPath((Join-Path $productRoot 'thai-narrative-v1.5-r7.1-package-identity.json'))
$extractedValidationPath = [System.IO.Path]::GetFullPath((Join-Path $productRoot 'thai-narrative-v1.5-r7.1-extracted-validation.json'))
$validator = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'tool/thai_narrative_r7_1_validate_utf8.ps1'))
$negativeFixture = [System.IO.Path]::GetFullPath((Join-Path $repositoryRoot 'tool/fixtures/thai_narrative_r7_1_broken_identity.base64.txt'))

if ($r7 -ne $expectedR7) { throw "Unexpected R7 root: $r7" }
if ($r71 -ne $expectedR71) { throw "Unexpected R7.1 root: $r71" }
foreach ($required in @($PdfInfo, $validator, $negativeFixture)) {
  if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Missing required file: $required" }
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $parent = Split-Path -Parent $Path
  if ($parent) { [System.IO.Directory]::CreateDirectory($parent) | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Read-Utf8Strict([string]$Path) {
  $bytes = [System.IO.File]::ReadAllBytes($Path)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    throw "UTF-8 BOM is not allowed: $Path"
  }
  return $utf8Strict.GetString($bytes)
}

function Replace-IdentityBlock([string]$Path, [string]$Block) {
  $start = '<!-- R7_1_ARTIFACT_IDENTITIES:START -->'
  $end = '<!-- R7_1_ARTIFACT_IDENTITIES:END -->'
  $content = Read-Utf8Strict $Path
  $pattern = [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
  if (-not [regex]::IsMatch($content, $pattern, [Text.RegularExpressions.RegexOptions]::Singleline)) {
    throw "Identity markers missing: $Path"
  }
  $replacement = $start + "`n" + $Block + "`n" + $end
  $updated = [regex]::Replace(
    $content,
    $pattern,
    [Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement },
    [Text.RegularExpressions.RegexOptions]::Singleline
  )
  Write-Utf8NoBom $Path $updated
}

function Copy-FileExact([string]$Source, [string]$Destination) {
  $parent = Split-Path -Parent $Destination
  [System.IO.Directory]::CreateDirectory($parent) | Out-Null
  [System.IO.File]::Copy($Source, $Destination, $true)
}

function Remove-ExactDirectory([string]$Path, [string]$Expected) {
  if ([System.IO.Path]::GetFullPath($Path) -ne [System.IO.Path]::GetFullPath($Expected)) {
    throw "Refusing unexpected directory removal: $Path"
  }
  if ([System.IO.Directory]::Exists($Path)) { [System.IO.Directory]::Delete($Path, $true) }
}

$canonicalBase64 = '4LiE4LmI4Liy4LiK4Li44LiU4LiZ4Li14LmJ4Liq4Lij4LmJ4Liy4LiH4Lit4Lix4LiV4LmC4LiZ4Lih4Lix4LiV4Li04LiI4Liy4LiBIGZpbmFsIFBERiBmaWxlcyDguYLguJTguKIgdG9vbC90aGFpX25hcnJhdGl2ZV9yN18xX2ZpbmFsaXplLnBzMTsgc291cmNlLW9mLXRydXRoIOC4hOC4t+C4rSBldmlkZW5jZS9hcnRpZmFjdC1pZGVudGl0aWVzLmpzb24='
$canonicalLine = $utf8Strict.GetString([Convert]::FromBase64String($canonicalBase64))
$expectedPdfs = [ordered]@{
  'comparison-known-bangkok-report.pdf' = [ordered]@{ pages = 7; bytes = 38336; sha256 = 'AA66312F30D7ED47E223CF4E94EB74FBF00573F3B438B11EBBCC125BDE217963' }
  'comparison-known-khon-kaen-report.pdf' = [ordered]@{ pages = 7; bytes = 38823; sha256 = 'E07F071E275AFB8291D27D32C520D69B3370088C5A2C400D9B345E2C2380AAFE' }
  'owner-known-0035-report.pdf' = [ordered]@{ pages = 7; bytes = 39080; sha256 = '23D7AEBC40F27C29BDA55F521688BCC7D156FDE928173BE435BB7033EB8535B6' }
  'owner-unknown-report.pdf' = [ordered]@{ pages = 6; bytes = 37021; sha256 = 'CD1704B2F84EE6C3AAA89EC0A011969CFAFA02C4B1318BC209D57EF972865CFF' }
  'regression-known-0003-report.pdf' = [ordered]@{ pages = 7; bytes = 39072; sha256 = 'D9A43853DBC8F9A173A2342EC0B2180E6F3DD33CA59D7CB819660E4B72CFE377' }
}

$pdfRows = @()
foreach ($name in $expectedPdfs.Keys) {
  $source = Join-Path $r7 "evidence/$name"
  $item = Get-Item -LiteralPath $source
  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash
  $info = & $PdfInfo $source
  if ($LASTEXITCODE -ne 0) { throw "pdfinfo failed: $source" }
  $pageLine = $info | Select-String '^Pages:' | Select-Object -First 1
  if (-not $pageLine) { throw "Page count missing: $source" }
  $pages = [int](($pageLine.ToString()) -replace '^Pages:\s*', '')
  $expected = $expectedPdfs[$name]
  if ($pages -ne $expected.pages -or $item.Length -ne $expected.bytes -or $hash -ne $expected.sha256) {
    throw "R7 PDF identity mismatch: $name"
  }
  $pdfRows += [ordered]@{ artifact = $name; pages = $pages; bytes = [int64]$item.Length; sha256 = $hash }
}

$identityJson = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r7.1-artifact-identities-v1'
  source = 'R7 byte-identical final PDF files'
  artifacts = $pdfRows
}
$r71Evidence = Join-Path $r71 'evidence'
[System.IO.Directory]::CreateDirectory($r71Evidence) | Out-Null
Write-Utf8NoBom (Join-Path $r71Evidence 'artifact-identities.json') (($identityJson | ConvertTo-Json -Depth 6) + "`n")
$table = @('| Artifact | Pages | Bytes | SHA-256 |', '|---|---:|---:|---|')
foreach ($row in $pdfRows) { $table += "| $($row.artifact) | $($row.pages) | $($row.bytes) | $($row.sha256) |" }
$identityBlock = $canonicalLine + "`n`n" + ($table -join "`n")
Write-Utf8NoBom (Join-Path $r71Evidence 'artifact-identities.md') ($identityBlock + "`n")
foreach ($relative in @('README.th.md', 'HANDOFF.md', 'MANIFEST.md', 'visual-qa.md')) {
  Replace-IdentityBlock (Join-Path $r71 $relative) $identityBlock
}

Remove-ExactDirectory $staging ([System.IO.Path]::GetFullPath((Join-Path $productRoot '.thai-narrative-v1.5-r7.1-staging')))
[System.IO.Directory]::CreateDirectory($staging) | Out-Null
$acceptanceDocs = @(
  'README.th.md', 'CURRENT_STATUS.md', 'HANDOFF.md', 'MANIFEST.md', 'acceptance-log.md',
  'reader-quality-review.md', 'repetition-distinctness.md', 'root-cause.md', 'validation-summary.md', 'visual-qa.md'
)
foreach ($relative in $acceptanceDocs) {
  Copy-FileExact (Join-Path $r71 $relative) (Join-Path $staging $relative)
}
Copy-FileExact (Join-Path $r71Evidence 'artifact-identities.json') (Join-Path $staging 'evidence/artifact-identities.json')
Copy-FileExact (Join-Path $r71Evidence 'artifact-identities.md') (Join-Path $staging 'evidence/artifact-identities.md')

$immutableRelativePaths = @(
  'evidence/analyzer-results.txt',
  'evidence/claim-coverage-matrix.json',
  'evidence/claim-ledger.json',
  'evidence/claim-render-traceability.json',
  'evidence/comparison-known-bangkok-pdf-text.txt',
  'evidence/comparison-known-bangkok-report.pdf',
  'evidence/comparison-known-bangkok-web-text.txt',
  'evidence/comparison-known-khon-kaen-pdf-text.txt',
  'evidence/comparison-known-khon-kaen-report.pdf',
  'evidence/comparison-known-khon-kaen-web-text.txt',
  'evidence/consumer-unit-audit.json',
  'evidence/engine-factual-result.json',
  'evidence/owner-known-0035-pdf-text.txt',
  'evidence/owner-known-0035-report.pdf',
  'evidence/owner-known-0035-web-text.txt',
  'evidence/owner-unknown-pdf-text.txt',
  'evidence/owner-unknown-report.pdf',
  'evidence/owner-unknown-web-text.txt',
  'evidence/r7-audit-metrics.json',
  'evidence/regression-known-0003-pdf-text.txt',
  'evidence/regression-known-0003-report.pdf',
  'evidence/regression-known-0003-web-text.txt',
  'evidence/test-focused-result.txt'
)
$renderFiles = @(Get-ChildItem -LiteralPath (Join-Path $r7 'renders') -Recurse -File | Sort-Object FullName)
foreach ($file in $renderFiles) {
  $immutableRelativePaths += 'renders/' + $file.FullName.Substring((Join-Path $r7 'renders').Length + 1).Replace('\', '/')
}
$identityRows = @()
foreach ($relative in $immutableRelativePaths) {
  $source = Join-Path $r7 $relative
  $destination = Join-Path $staging $relative
  Copy-FileExact $source $destination
  $sourceItem = Get-Item -LiteralPath $source
  $destinationItem = Get-Item -LiteralPath $destination
  $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $source).Hash
  $destinationHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $destination).Hash
  $identityRows += [ordered]@{
    path = $relative
    r7Bytes = [int64]$sourceItem.Length
    r71Bytes = [int64]$destinationItem.Length
    r7Sha256 = $sourceHash
    r71Sha256 = $destinationHash
    match = ($sourceItem.Length -eq $destinationItem.Length -and $sourceHash -eq $destinationHash)
  }
}
$mismatches = @($identityRows | Where-Object { -not $_.match })
if ($mismatches.Count -ne 0) { throw "Immutable artifact mismatch count: $($mismatches.Count)" }
$identityComparison = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r7-to-r7.1-identity-comparison-v1'
  comparedFiles = $identityRows.Count
  mismatchCount = $mismatches.Count
  files = $identityRows
}
Write-Utf8NoBom (Join-Path $staging 'evidence/r7-to-r7.1-identity-comparison.json') (($identityComparison | ConvertTo-Json -Depth 7) + "`n")

$audit = (Read-Utf8Strict (Join-Path $r7 'evidence/r7-audit-metrics.json')) | ConvertFrom-Json
$expectedClauseFlags = [ordered]@{
  'owner-known-0035' = 0
  'owner-unknown' = 0
  'regression-known-0003' = 0
  'comparison-known-bangkok' = 0
  'comparison-known-khon-kaen' = 1
}
$auditRows = @()
foreach ($fixture in $expectedClauseFlags.Keys) {
  $row = $audit.clauseSentenceSkeletonAudit.$fixture
  if ($row.flaggedPairCount -ne $expectedClauseFlags[$fixture] -or $row.callbackFailureCount -ne 0) {
    throw "R7 audit accuracy mismatch: $fixture"
  }
  $auditRows += [ordered]@{
    fixture = $fixture
    clauseFlags = [int]$row.flaggedPairCount
    callbackFailures = [int]$row.callbackFailureCount
  }
}
$khonKaen = $audit.clauseSentenceSkeletonAudit.'comparison-known-khon-kaen'.flaggedPairs
if ($khonKaen.Count -ne 1 -or -not $khonKaen[0].repeatedSuffix) {
  throw 'Khon Kaen repeated-suffix evidence mismatch'
}
$freshness = $audit.freshness.afterR7
if ($freshness.instances -ne 219 -or $freshness.reusedInstances -ne 71 -or
    [math]::Abs([double]$freshness.exactReuseRate - 0.3242009132420091) -gt 0.0000000001 -or
    $freshness.reuseGroupCount -ne 26) {
  throw 'R7 broad reuse evidence mismatch'
}
$auditAccuracy = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r7.1-audit-accuracy-v1'
  source = 'evidence/r7-audit-metrics.json'
  sourceModified = $false
  fixtures = $auditRows
  khonKaenFinding = [ordered]@{
    flagType = 'repeated-suffix'
    count = 1
    callbackClassification = 'non-blocking summary-to-detail callback with new detail'
    leftUnitId = $khonKaen[0].leftUnitId
    rightUnitId = $khonKaen[0].rightUnitId
  }
  broadReuse = [ordered]@{
    reused = 71
    denominator = 219
    percent = 32.4201
    groups = 26
  }
  passed = $true
}
Write-Utf8NoBom (Join-Path $staging 'evidence/r7-audit-accuracy-summary.json') (($auditAccuracy | ConvertTo-Json -Depth 7) + "`n")

$negativeRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('knowme-r7-1-negative-' + [guid]::NewGuid().ToString('N'))
[System.IO.Directory]::CreateDirectory($negativeRoot) | Out-Null
try {
  $fixtureBase64 = (Read-Utf8Strict $negativeFixture).Trim()
  [System.IO.File]::WriteAllBytes((Join-Path $negativeRoot 'broken-identity.md'), [Convert]::FromBase64String($fixtureBase64))
  $negativeOutput = & pwsh -NoProfile -File $validator -Root $negativeRoot 2>&1 | Out-String
  $negativeExit = $LASTEXITCODE
  if ($negativeExit -eq 0) { throw 'Negative UTF-8 fixture was not rejected' }
} finally {
  if ([System.IO.Directory]::Exists($negativeRoot)) { [System.IO.Directory]::Delete($negativeRoot, $true) }
}
$negativeResult = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r7.1-negative-fixture-v1'
  fixture = 'tool/fixtures/thai_narrative_r7_1_broken_identity.base64.txt'
  source = 'R7 broken generated identity block'
  rejected = $true
  validatorExitCode = $negativeExit
  passed = $true
}
Write-Utf8NoBom (Join-Path $staging 'evidence/utf8-negative-fixture-result.txt') (($negativeResult | ConvertTo-Json -Depth 4) + "`n")

$stagingReport = Join-Path $staging 'evidence/utf8-validation.txt'
$stagingOutput = & pwsh -NoProfile -File $validator -Root $staging -ReportPath $stagingReport -RequireIdentityTargets 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) { throw "Staging UTF-8 validation failed:`n$stagingOutput" }
$stagingValidation = Get-Content -Raw -Encoding utf8 -LiteralPath $stagingReport | ConvertFrom-Json

$checksumPath = Join-Path $staging 'SHA256SUMS.txt'
$checksumFiles = @(Get-ChildItem -LiteralPath $staging -Recurse -File | Where-Object { $_.FullName -ne $checksumPath } | Sort-Object FullName)
$checksumLines = foreach ($file in $checksumFiles) {
  $relative = $file.FullName.Substring($staging.Length + 1).Replace('\', '/')
  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
  "$hash  $relative"
}
Write-Utf8NoBom $checksumPath (($checksumLines -join "`n") + "`n")
foreach ($line in $checksumLines) {
  if ($line -notmatch '^([0-9A-F]{64})  (.+)$') { throw "Malformed checksum line: $line" }
  $file = Join-Path $staging ($Matches[2].Replace('/', [IO.Path]::DirectorySeparatorChar))
  if ((Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash -ne $Matches[1]) { throw "Staging checksum mismatch: $($Matches[2])" }
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
if ([System.IO.File]::Exists($zipPath)) { [System.IO.File]::Delete($zipPath) }
$stream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::CreateNew)
try {
  $archive = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
  try {
    foreach ($file in (Get-ChildItem -LiteralPath $staging -Recurse -File | Sort-Object FullName)) {
      $entryName = $file.FullName.Substring($staging.Length + 1).Replace('\', '/')
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $file.FullName, $entryName, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
  } finally { $archive.Dispose() }
} finally { $stream.Dispose() }

$zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  $entryCount = $zipArchive.Entries.Count
  $unsafeEntries = @($zipArchive.Entries | Where-Object {
    $_.FullName -match '\\' -or $_.FullName -match '^/' -or $_.FullName -match '^[A-Za-z]:' -or (($_.FullName -split '/') -contains '..')
  }).Count
  $duplicateEntries = $entryCount - (@($zipArchive.Entries.FullName | Sort-Object -Unique).Count)
} finally { $zipArchive.Dispose() }
if (($unsafeEntries + $duplicateEntries) -ne 0) { throw 'ZIP path validation failed' }

$extractRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('knowme-r7-1-extract-' + [guid]::NewGuid().ToString('N'))
[System.IO.Directory]::CreateDirectory($extractRoot) | Out-Null
try {
  [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractRoot)
  foreach ($line in $checksumLines) {
    if ($line -notmatch '^([0-9A-F]{64})  (.+)$') { throw "Malformed checksum line: $line" }
    $file = Join-Path $extractRoot ($Matches[2].Replace('/', [IO.Path]::DirectorySeparatorChar))
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash -ne $Matches[1]) { throw "Extracted checksum mismatch: $($Matches[2])" }
  }
  $extractedOutput = & pwsh -NoProfile -File $validator -Root $extractRoot -RequireIdentityTargets 2>&1 | Out-String
  if ($LASTEXITCODE -ne 0) { throw "Extracted UTF-8 validation failed:`n$extractedOutput" }
  $extractedValidation = $extractedOutput | ConvertFrom-Json
} finally {
  if ([System.IO.Directory]::Exists($extractRoot)) { [System.IO.Directory]::Delete($extractRoot, $true) }
}
Write-Utf8NoBom $extractedValidationPath (($extractedValidation | ConvertTo-Json -Depth 6) + "`n")

Remove-ExactDirectory $r71 $expectedR71
[System.IO.Directory]::Move($staging, $r71)
$zipItem = Get-Item -LiteralPath $zipPath
$packageIdentity = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r7.1-package-identity-v1'
  artifact = $zipItem.Name
  bytes = [int64]$zipItem.Length
  sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash
  entries = $entryCount
  checksumEntries = $checksumLines.Count
  checksumVerified = $checksumLines.Count
  unsafeEntries = $unsafeEntries
  duplicateEntries = $duplicateEntries
  cleanExtraction = 'PASS'
  immutableFilesCompared = $identityRows.Count
  immutableArtifactMismatch = $mismatches.Count
  negativeFixtureRejected = $true
  stagingUtf8Validation = $stagingValidation
  extractedUtf8Validation = $extractedValidation
}
Write-Utf8NoBom $packageIdentityPath (($packageIdentity | ConvertTo-Json -Depth 8) + "`n")
$packageIdentity | ConvertTo-Json -Depth 8
