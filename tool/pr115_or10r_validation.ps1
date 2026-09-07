[CmdletBinding()]
param(
  [string]$ImplementationFullSha = "6d4d4d1a4a03d2a97d8d1c11afd67baa05f4e48d"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($ImplementationFullSha -notmatch '^[0-9a-f]{40}$') {
  throw "ImplementationFullSha must be a full lowercase Git SHA"
}
$implementationShortSha = $ImplementationFullSha.Substring(0, 7)
$repo = [IO.Path]::GetFullPath((& git rev-parse --show-toplevel).Trim())
& git cat-file -e "$ImplementationFullSha^{commit}" 2>$null
if ($LASTEXITCODE -ne 0) { throw "Implementation commit is not available" }

$buildRoot = [IO.Path]::GetFullPath((Join-Path $repo "build"))
$staging = [IO.Path]::GetFullPath((Join-Path $buildRoot "or10r-r1-owner-review"))
$extract = [IO.Path]::GetFullPath((Join-Path $buildRoot "or10r-r1-owner-review-extracted"))
$zipName = "OWNER_REVIEW_THAI_PREDICTIVE_NARRATIVE_V2_RUNTIME_V2_OR10R_R1_${implementationShortSha}.zip"
$zipPath = [IO.Path]::GetFullPath((Join-Path (Split-Path $repo -Parent) $zipName))

foreach ($path in @($staging, $extract)) {
  if (-not $path.StartsWith($buildRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe generated directory: $path"
  }
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
  [IO.Directory]::CreateDirectory($path) | Out-Null
}
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

$productDir = Join-Path $staging "artifacts/product"
$beforeDir = Join-Path $staging "artifacts/before"
$rasterDir = Join-Path $staging "artifacts/pdf-raster"
$sheetDir = Join-Path $staging "artifacts/contact-sheets"
$pdfEvidenceDir = Join-Path $staging "evidence/actual-pdf"
$docsDir = Join-Path $staging "evidence/docs"
foreach ($path in @($productDir, $beforeDir, $rasterDir, $sheetDir, $pdfEvidenceDir, $docsDir)) {
  [IO.Directory]::CreateDirectory($path) | Out-Null
}

function Copy-RequiredDirectory([string]$Source, [string]$Destination) {
  if (-not (Test-Path -LiteralPath $Source -PathType Container)) { throw "Missing directory: $Source" }
  Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

Copy-RequiredDirectory (Join-Path $buildRoot "or10r-r1-owner-product") $productDir
Copy-RequiredDirectory (Join-Path $buildRoot "or10r-r1-raster") $rasterDir
Copy-RequiredDirectory (Join-Path $buildRoot "or10r-r1-contact-sheets") $sheetDir

$beforeProduct = Join-Path $buildRoot "or10r-r1-before/artifacts/product"
foreach ($name in @(
  "known-0003-360-infographic.png",
  "known-0003-390-infographic.png",
  "known-0035-360-infographic.png",
  "known-0035-390-infographic.png"
)) {
  $source = Join-Path $beforeProduct $name
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing before artifact: $source" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $beforeDir $name) -Force
}

foreach ($name in @(
  "or10r-r1-known-0003-dedicated-text.json",
  "or10r-r1-known-0035-dedicated-text.json",
  "or10r-r1-unknown-dedicated-text.json"
)) {
  $source = Join-Path $buildRoot $name
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing PDF evidence: $source" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $pdfEvidenceDir $name) -Force
}

$evidenceDocs = @(
  "docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md",
  "docs/CANDIDATE_0023_CLAIM_MAP.json",
  "docs/CANDIDATE_0023_CONTENT_AUDIT.json",
  "docs/PR115_OR10_CONTRACT_CONFLICT_TRUTH_CORRECTION.json",
  "docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json",
  "docs/PR115_OR10R_R1_BEFORE_EVIDENCE.json",
  "docs/PR115_OR10R_R1_VISUAL_REVIEW.json",
  "docs/PR115_OR10R_R1_VALIDATION.json"
)
foreach ($relative in $evidenceDocs) {
  $source = Join-Path $repo $relative
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing evidence document: $source" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $docsDir ([IO.Path]::GetFileName($source))) -Force
}

$guideSource = Join-Path $repo "docs/PR115_OR10R_R1_OWNER_REVIEW.md"
$ownerReview = [IO.File]::ReadAllText($guideSource, [Text.Encoding]::UTF8)
[IO.File]::WriteAllText((Join-Path $staging "OWNER_REVIEW.md"), $ownerReview, [Text.UTF8Encoding]::new($false))

$testSummary = [ordered]@{
  implementationFullSha = $ImplementationFullSha
  implementationShortSha = $implementationShortSha
  nodeSignatureAndFoundation = "9/9"
  runtimeFixtureAndExport = "26/26"
  focusedNarrativeExportInfographicArtifact = "283/283"
  copyAudit = "1/1; 300 profiles; Known 225/225; Unknown 75/75; impacts 0"
  fullRequiredFlutterSuite = "1646/1646"
  analyzer = "PASS; 298 baseline diagnostics; 0 new OR10R-R1 diagnostics"
  preCommit = "PASS"
  implementationPostCommit = "PASS"
}
[IO.File]::WriteAllText((Join-Path $staging "TEST_SUMMARY.json"), (($testSummary | ConvertTo-Json -Depth 5) + "`n"), [Text.UTF8Encoding]::new($false))

function RelativePath([string]$Root, [string]$Path) {
  $rootPrefix = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
  $fullPath = [IO.Path]::GetFullPath($Path)
  if (-not $fullPath.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Path is outside package root: $fullPath"
  }
  return $fullPath.Substring($rootPrefix.Length).Replace('\', '/')
}

$payloadFiles = @(Get-ChildItem -LiteralPath $staging -Recurse -File | Sort-Object FullName)
$payload = @(
  foreach ($file in $payloadFiles) {
    [ordered]@{
      path = RelativePath $staging $file.FullName
      bytes = $file.Length
      sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToUpperInvariant()
    }
  }
)
$manifest = [ordered]@{
  schema = "pr115-or10r-r1-owner-review-manifest/1"
  implementationFullSha = $ImplementationFullSha
  implementationShortSha = $implementationShortSha
  payloadCount = $payload.Count
  payload = $payload
}
$manifestPath = Join-Path $staging "MANIFEST.json"
[IO.File]::WriteAllText($manifestPath, (($manifest | ConvertTo-Json -Depth 8) + "`n"), [Text.UTF8Encoding]::new($false))

$sumItems = @($payload) + @([ordered]@{
  path = "MANIFEST.json"
  bytes = (Get-Item -LiteralPath $manifestPath).Length
  sha256 = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToUpperInvariant()
})
$sumLines = @($sumItems | ForEach-Object { "$($_.sha256)  $($_.path)" })
[IO.File]::WriteAllText((Join-Path $staging "SHA256SUMS.txt"), (($sumLines -join "`n") + "`n"), [Text.UTF8Encoding]::new($false))

Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -CompressionLevel Optimal

Add-Type -AssemblyName System.IO.Compression.FileSystem
$unsafePathCount = 0
$crcErrorCount = 0
$archive = [IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  foreach ($entry in $archive.Entries) {
    $name = $entry.FullName.Replace('\', '/')
    if ([IO.Path]::IsPathRooted($name) -or $name -match '(^|/)\.\.(/|$)') { $unsafePathCount++ }
    if (-not $name.EndsWith('/')) {
      try {
        $stream = $entry.Open()
        try { $stream.CopyTo([IO.Stream]::Null) } finally { $stream.Dispose() }
      } catch { $crcErrorCount++ }
    }
  }
} finally { $archive.Dispose() }

Expand-Archive -LiteralPath $zipPath -DestinationPath $extract -Force
$manifestExtractedPath = Join-Path $extract "MANIFEST.json"
$extractedManifest = [IO.File]::ReadAllText($manifestExtractedPath, [Text.Encoding]::UTF8) | ConvertFrom-Json
$expected = @{}
foreach ($item in @($extractedManifest.payload)) { $expected[[string]$item.path] = $item }
$actualFiles = @(Get-ChildItem -LiteralPath $extract -Recurse -File | ForEach-Object { RelativePath $extract $_.FullName })
$actualPayload = @($actualFiles | Where-Object { $_ -notin @("MANIFEST.json", "SHA256SUMS.txt") })
$missing = @($expected.Keys | Where-Object { $_ -notin $actualPayload })
$extra = @($actualPayload | Where-Object { -not $expected.ContainsKey($_) })
$hashMismatchCount = 0
$sizeMismatchCount = 0
foreach ($path in $expected.Keys) {
  $full = Join-Path $extract $path
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { continue }
  $item = $expected[$path]
  if ((Get-Item -LiteralPath $full).Length -ne [long]$item.bytes) { $sizeMismatchCount++ }
  if ((Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToUpperInvariant() -ne [string]$item.sha256) { $hashMismatchCount++ }
}

$shaSumMismatchCount = 0
$shaSumLineCount = 0
foreach ($line in [IO.File]::ReadAllLines((Join-Path $extract "SHA256SUMS.txt"), [Text.Encoding]::UTF8)) {
  if ([string]::IsNullOrWhiteSpace($line)) { continue }
  $shaSumLineCount++
  if ($line -notmatch '^([A-F0-9]{64})  (.+)$') { $shaSumMismatchCount++; continue }
  $full = Join-Path $extract $Matches[2]
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { $shaSumMismatchCount++; continue }
  if ((Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToUpperInvariant() -ne $Matches[1]) { $shaSumMismatchCount++ }
}
if ($shaSumLineCount -ne ($expected.Count + 1)) { $shaSumMismatchCount++ }

$encodingErrorCount = 0
$controlCharacterCount = 0
$replacementCharacterCount = 0
$templateTokenCount = 0
$mojibakeSignatureCount = 0
$brokenLinkCount = 0
$secretFindingCount = 0
$absoluteLocalPathCount = 0
$jsonErrorCount = 0
$utf8 = [Text.UTF8Encoding]::new($false, $true)
$textExtensions = @('.md', '.json', '.txt', '.html')
$secretPatterns = @('AIza[0-9A-Za-z_-]{35}', '-----BEGIN [A-Z ]*PRIVATE KEY-----', '(?i)password\s*[:=]\s*[^\s]+', '(?i)authorization\s*:\s*bearer\s+[^\s]+')
$templatePatterns = @('\{\{[A-Z0-9_]+\}\}', '\$Implementation(?:Full|Short)Sha', '<shortsha>')
$mojibakePatterns = @('à¸', 'à¹', 'â€', 'Ã', 'Â', 'เน€', 'โ€”', 'เธ', 'เธ', 'เธญ', 'เธ²', 'เธ”')
$absolutePatterns = @('(?i)(?<![A-Za-z0-9+.-])[A-Z]:[\\/]', '(?i)file://', '/Users/', '/home/')
foreach ($file in Get-ChildItem -LiteralPath $extract -Recurse -File) {
  if ($textExtensions -notcontains $file.Extension.ToLowerInvariant()) { continue }
  try { $text = $utf8.GetString([IO.File]::ReadAllBytes($file.FullName)) }
  catch { $encodingErrorCount++; continue }
  foreach ($char in $text.ToCharArray()) {
    $code = [int][char]$char
    if (($code -lt 32 -and $code -notin @(9, 10, 13)) -or ($code -ge 127 -and $code -le 159)) { $controlCharacterCount++ }
    if ($code -eq 0xFFFD) { $replacementCharacterCount++ }
  }
  foreach ($pattern in $templatePatterns) { $templateTokenCount += [regex]::Matches($text, $pattern).Count }
  foreach ($pattern in $mojibakePatterns) { $mojibakeSignatureCount += [regex]::Matches($text, [regex]::Escape($pattern)).Count }
  foreach ($pattern in $absolutePatterns) { $absoluteLocalPathCount += [regex]::Matches($text, $pattern).Count }
  foreach ($pattern in $secretPatterns) { $secretFindingCount += [regex]::Matches($text, $pattern).Count }
  if ($file.Extension.ToLowerInvariant() -eq '.json') {
    try { $null = $text | ConvertFrom-Json } catch { $jsonErrorCount++ }
  }
  if ($file.Extension.ToLowerInvariant() -eq '.md') {
    foreach ($match in [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')) {
      $target = $match.Groups[1].Value.Trim()
      if ($target -match '^(?:https?://|mailto:|#)') { continue }
      $target = [Uri]::UnescapeDataString(($target -split '#')[0])
      $resolved = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $target))
      if (-not $resolved.StartsWith($extract + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or -not (Test-Path -LiteralPath $resolved)) {
        $brokenLinkCount++
      }
    }
  }
}

$guide = [IO.File]::ReadAllText((Join-Path $extract "OWNER_REVIEW.md"), [Text.Encoding]::UTF8)
$signatureMismatchCount = 0
if (-not $guide.Contains("Implementation full SHA: ``$ImplementationFullSha``")) { $signatureMismatchCount++ }
if (-not $guide.Contains("Implementation short SHA: ``$implementationShortSha``")) { $signatureMismatchCount++ }
if ([string]$extractedManifest.implementationFullSha -ne $ImplementationFullSha) { $signatureMismatchCount++ }
if ([string]$extractedManifest.implementationShortSha -ne $implementationShortSha) { $signatureMismatchCount++ }

$errorTotal = $missing.Count + $extra.Count + $hashMismatchCount + $sizeMismatchCount + $shaSumMismatchCount + $unsafePathCount + $crcErrorCount + $encodingErrorCount + $controlCharacterCount + $replacementCharacterCount + $templateTokenCount + $mojibakeSignatureCount + $brokenLinkCount + $secretFindingCount + $absoluteLocalPathCount + $jsonErrorCount + $signatureMismatchCount
$result = [ordered]@{
  status = if ($errorTotal -eq 0) { "PASS" } else { "FAIL" }
  zipPath = $zipPath
  zipBytes = (Get-Item -LiteralPath $zipPath).Length
  zipSha256 = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToUpperInvariant()
  implementationFullSha = $ImplementationFullSha
  implementationShortSha = $implementationShortSha
  payloadCount = [int]$extractedManifest.payloadCount
  missingCount = $missing.Count
  extraCount = $extra.Count
  hashMismatchCount = $hashMismatchCount
  sizeMismatchCount = $sizeMismatchCount
  sha256SumsMismatchCount = $shaSumMismatchCount
  unsafePathCount = $unsafePathCount
  crcErrorCount = $crcErrorCount
  encodingErrorCount = $encodingErrorCount
  controlCharacterCount = $controlCharacterCount
  replacementCharacterCount = $replacementCharacterCount
  templateTokenCount = $templateTokenCount
  mojibakeSignatureCount = $mojibakeSignatureCount
  brokenLinkCount = $brokenLinkCount
  signatureMismatchCount = $signatureMismatchCount
  secretFindingCount = $secretFindingCount
  absoluteLocalPathCount = $absoluteLocalPathCount
  jsonErrorCount = $jsonErrorCount
}
$resultPath = Join-Path $buildRoot "or10r-r1-package-validation.json"
[IO.File]::WriteAllText($resultPath, (($result | ConvertTo-Json -Depth 5) + "`n"), [Text.UTF8Encoding]::new($false))
$result | ConvertTo-Json -Depth 5
if ($result.status -ne "PASS") { exit 1 }
