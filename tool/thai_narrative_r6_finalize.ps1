param(
  [string]$PacketRoot = 'product-acceptance/thai-narrative-v1.5-r6',
  [string]$PdfInfo = 'C:\Users\USER\.cache\codex-runtimes\codex-primary-runtime\dependencies\native\poppler\Library\bin\pdfinfo.exe'
)

$ErrorActionPreference = 'Stop'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$repositoryRoot = (Resolve-Path -LiteralPath '.').Path
$packet = (Resolve-Path -LiteralPath $PacketRoot).Path
$expectedPacket = [System.IO.Path]::GetFullPath(
  (Join-Path $repositoryRoot 'product-acceptance/thai-narrative-v1.5-r6')
)
if ($packet -ne $expectedPacket) {
  throw "Unexpected packet root: $packet"
}
if (-not (Test-Path -LiteralPath $PdfInfo -PathType Leaf)) {
  throw "pdfinfo not found: $PdfInfo"
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Replace-IdentityBlock([string]$Path, [string]$Block) {
  $start = '<!-- R6_ARTIFACT_IDENTITIES:START -->'
  $end = '<!-- R6_ARTIFACT_IDENTITIES:END -->'
  $content = [System.IO.File]::ReadAllText($Path)
  $pattern = [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
  if (-not [regex]::IsMatch($content, $pattern, [Text.RegularExpressions.RegexOptions]::Singleline)) {
    throw "Identity markers missing: $Path"
  }
  $replacement = "$start`n$Block`n$end"
  $updated = [regex]::Replace(
    $content,
    $pattern,
    [Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement },
    [Text.RegularExpressions.RegexOptions]::Singleline
  )
  Write-Utf8NoBom $Path $updated
}

$pdfRows = @()
Get-ChildItem -LiteralPath (Join-Path $packet 'evidence') -Filter '*-report.pdf' -File |
  Sort-Object Name |
  ForEach-Object {
    $info = & $PdfInfo $_.FullName
    if ($LASTEXITCODE -ne 0) {
      throw "pdfinfo failed: $($_.FullName)"
    }
    $pageLine = $info | Select-String '^Pages:' | Select-Object -First 1
    if (-not $pageLine) {
      throw "Page count missing: $($_.FullName)"
    }
    $pdfRows += [ordered]@{
      artifact = $_.Name
      pages = [int](($pageLine.ToString()) -replace '^Pages:\s*', '')
      bytes = [int64]$_.Length
      sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $_.FullName).Hash
    }
  }
if ($pdfRows.Count -ne 5) {
  throw "Expected five PDFs, found $($pdfRows.Count)"
}

$identityJson = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r6-artifact-identities-v1'
  generatedFrom = 'final packet PDF files'
  artifacts = $pdfRows
}
$identityJsonPath = Join-Path $packet 'evidence/artifact-identities.json'
Write-Utf8NoBom $identityJsonPath (($identityJson | ConvertTo-Json -Depth 5) + "`n")

$tableLines = @(
  '| Artifact | Pages | Bytes | SHA-256 |',
  '|---|---:|---:|---|'
)
foreach ($row in $pdfRows) {
  $tableLines += "| $($row.artifact) | $($row.pages) | $($row.bytes) | ``$($row.sha256)`` |"
}
$identityBlock = @"
ค่าชุดนี้สร้างอัตโนมัติจาก final PDF files โดย `tool/thai_narrative_r6_finalize.ps1`; source-of-truth คือ `evidence/artifact-identities.json`.

$($tableLines -join "`n")
"@.Trim()
Write-Utf8NoBom (Join-Path $packet 'evidence/artifact-identities.md') ($identityBlock + "`n")

foreach ($relative in @('README.th.md', 'MANIFEST.md', 'HANDOFF.md', 'visual-qa.md')) {
  Replace-IdentityBlock (Join-Path $packet $relative) $identityBlock
}

$portableReport = Join-Path $packet 'evidence/portable-path-validation.txt'
$relativePaths = @(
  Get-ChildItem -LiteralPath $packet -Recurse -File |
    Where-Object { $_.FullName -ne (Join-Path $packet 'SHA256SUMS.txt') } |
    ForEach-Object { $_.FullName.Substring($packet.Length + 1).Replace('\', '/') } |
    Sort-Object
)
$backslash = @($relativePaths | Where-Object { $_ -match '\\' }).Count
$absolute = @($relativePaths | Where-Object { $_ -match '^/' }).Count
$drive = @($relativePaths | Where-Object { $_ -match '^[A-Za-z]:' }).Count
$traversal = @($relativePaths | Where-Object { ($_ -split '/') -contains '..' }).Count
$duplicates = $relativePaths.Count - (@($relativePaths | Sort-Object -Unique).Count)
$portableText = @"
portable-path-validation: PASS
entries-before-SHA256SUMS: $($relativePaths.Count)
backslash-entries: $backslash
absolute-entries: $absolute
drive-qualified-entries: $drive
traversal-entries: $traversal
duplicate-entries: $duplicates
"@
if (($backslash + $absolute + $drive + $traversal + $duplicates) -ne 0) {
  throw 'Portable path validation failed'
}
Write-Utf8NoBom $portableReport $portableText

$checksumPath = Join-Path $packet 'SHA256SUMS.txt'
$checksumFiles = @(
  Get-ChildItem -LiteralPath $packet -Recurse -File |
    Where-Object { $_.FullName -ne $checksumPath } |
    Sort-Object FullName
)
$checksumLines = foreach ($file in $checksumFiles) {
  $relative = $file.FullName.Substring($packet.Length + 1).Replace('\', '/')
  $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
  "$hash  $relative"
}
Write-Utf8NoBom $checksumPath (($checksumLines -join "`n") + "`n")

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipPath = Join-Path (Split-Path -Parent $packet) 'thai-narrative-v1.5-r6.zip'
$expectedZip = [System.IO.Path]::GetFullPath(
  (Join-Path $repositoryRoot 'product-acceptance/thai-narrative-v1.5-r6.zip')
)
if ([System.IO.Path]::GetFullPath($zipPath) -ne $expectedZip) {
  throw "Unexpected ZIP path: $zipPath"
}
if ([System.IO.File]::Exists($zipPath)) {
  [System.IO.File]::Delete($zipPath)
}
$stream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::CreateNew)
try {
  $archive = [System.IO.Compression.ZipArchive]::new(
    $stream,
    [System.IO.Compression.ZipArchiveMode]::Create,
    $false
  )
  try {
    foreach ($file in (Get-ChildItem -LiteralPath $packet -Recurse -File | Sort-Object FullName)) {
      $entryName = $file.FullName.Substring($packet.Length + 1).Replace('\', '/')
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $archive,
        $file.FullName,
        $entryName,
        [System.IO.Compression.CompressionLevel]::Optimal
      ) | Out-Null
    }
  } finally {
    $archive.Dispose()
  }
} finally {
  $stream.Dispose()
}

$verifyRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("knowme-r6-verify-" + [guid]::NewGuid().ToString('N'))
[System.IO.Directory]::CreateDirectory($verifyRoot) | Out-Null
try {
  [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $verifyRoot)
  foreach ($line in $checksumLines) {
    if ($line -notmatch '^([0-9A-F]{64})  (.+)$') {
      throw "Malformed checksum line: $line"
    }
    $expectedHash = $Matches[1]
    $relative = $Matches[2]
    $extracted = Join-Path $verifyRoot ($relative.Replace('/', [IO.Path]::DirectorySeparatorChar))
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $extracted).Hash
    if ($actualHash -ne $expectedHash) {
      throw "Checksum mismatch: $relative"
    }
  }
} finally {
  if ([System.IO.Directory]::Exists($verifyRoot)) {
    [System.IO.Directory]::Delete($verifyRoot, $true)
  }
}

$zipItem = Get-Item -LiteralPath $zipPath
$zipArchive = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  $entryCount = $zipArchive.Entries.Count
  $unsafeEntries = @(
    $zipArchive.Entries | Where-Object {
      $_.FullName -match '\\' -or
      $_.FullName -match '^/' -or
      $_.FullName -match '^[A-Za-z]:' -or
      (($_.FullName -split '/') -contains '..')
    }
  ).Count
  $duplicateEntries = $entryCount - (@($zipArchive.Entries.FullName | Sort-Object -Unique).Count)
} finally {
  $zipArchive.Dispose()
}
if (($unsafeEntries + $duplicateEntries) -ne 0) {
  throw 'Final ZIP path validation failed'
}

$packageIdentity = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r6-package-identity-v1'
  artifact = $zipItem.Name
  bytes = [int64]$zipItem.Length
  sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipPath).Hash
  entries = $entryCount
  checksumEntries = $checksumLines.Count
  checksumVerified = $checksumLines.Count
  unsafeEntries = $unsafeEntries
  duplicateEntries = $duplicateEntries
  cleanExtraction = 'PASS'
}
$packageIdentityPath = Join-Path (Split-Path -Parent $packet) 'thai-narrative-v1.5-r6-package-identity.json'
Write-Utf8NoBom $packageIdentityPath (($packageIdentity | ConvertTo-Json -Depth 4) + "`n")
$packageIdentity | ConvertTo-Json -Depth 4
