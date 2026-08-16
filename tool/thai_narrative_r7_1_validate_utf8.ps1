param(
  [Parameter(Mandatory = $true)]
  [string]$Root,
  [string]$ReportPath,
  [switch]$RequireIdentityTargets
)

$ErrorActionPreference = 'Stop'
$utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$rootPath = (Resolve-Path -LiteralPath $Root).Path
$canonicalBase64 = '4LiE4LmI4Liy4LiK4Li44LiU4LiZ4Li14LmJ4Liq4Lij4LmJ4Liy4LiH4Lit4Lix4LiV4LmC4LiZ4Lih4Lix4LiV4Li04LiI4Liy4LiBIGZpbmFsIFBERiBmaWxlcyDguYLguJTguKIgdG9vbC90aGFpX25hcnJhdGl2ZV9yN18xX2ZpbmFsaXplLnBzMTsgc291cmNlLW9mLXRydXRoIOC4hOC4t+C4rSBldmlkZW5jZS9hcnRpZmFjdC1pZGVudGl0aWVzLmpzb24='
$canonicalLine = $utf8Strict.GetString([Convert]::FromBase64String($canonicalBase64))
$identityTargets = @(
  'README.th.md',
  'HANDOFF.md',
  'MANIFEST.md',
  'visual-qa.md',
  'evidence/artifact-identities.md'
)

$result = [ordered]@{
  schema = 'knowme-thai-narrative-v1.5-r7.1-utf8-validation-v1'
  root = $rootPath
  filesChecked = 0
  utf8Bom = 0
  invalidUtf8 = 0
  replacementCharacter = 0
  c0ControlCharacters = 0
  c1ControlCharacters = 0
  markdownTabs = 0
  mojibakeSequences = 0
  doubleEncodedThai = 0
  generatedIdentityMismatch = 0
  invalidGeneratedToolPath = 0
  failures = @()
  passed = $false
}

$textFiles = @(
  Get-ChildItem -LiteralPath $rootPath -Recurse -File |
    Where-Object { $_.Extension.ToLowerInvariant() -in @('.md', '.json', '.txt') } |
    Sort-Object FullName
)
$result.filesChecked = $textFiles.Count
$decoded = @{}
$mojibakePatterns = @(
  ([string][char]0x0E40 + [char]0x0E18 + [char]0x0084),
  ([string][char]0x0E40 + [char]0x0E19 + [char]0x0088),
  ([string][char]0x0E40 + [char]0x0E19 + [char]0x0089),
  ([string][char]0x00C3),
  ([string][char]0x00E2 + [char]0x20AC),
  ([string][char]0x00E0 + [char]0x00B8),
  ([string][char]0x00E0 + [char]0x00B9)
)
foreach ($file in $textFiles) {
  $relative = $file.FullName.Substring($rootPath.Length + 1).Replace('\', '/')
  $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $result.utf8Bom++
    $result.failures += "${relative}: UTF-8 BOM"
  }
  try {
    $text = $utf8Strict.GetString($bytes)
    $decoded[$relative] = $text
  } catch {
    $result.invalidUtf8++
    $result.failures += "${relative}: invalid UTF-8"
    continue
  }
  if ($text.IndexOf([char]0xFFFD) -ge 0) {
    $result.replacementCharacter++
    $result.failures += "${relative}: U+FFFD"
  }
  $hasC0 = $false
  $hasC1 = $false
  foreach ($character in $text.ToCharArray()) {
    $code = [int]$character
    if ($code -lt 32 -and $code -notin @(10, 13)) { $hasC0 = $true }
    if ($code -ge 128 -and $code -le 159) { $hasC1 = $true }
  }
  if ($hasC0) {
    $result.c0ControlCharacters++
    $result.failures += "${relative}: C0 control character"
  }
  if ($hasC1) {
    $result.c1ControlCharacters++
    $result.failures += "${relative}: C1 control character"
  }
  if ($file.Extension.ToLowerInvariant() -eq '.md' -and $text.IndexOf([char]9) -ge 0) {
    $result.markdownTabs++
    $result.failures += "${relative}: Markdown tab"
  }
  $hasMojibake = $false
  foreach ($pattern in $mojibakePatterns) {
    if ($text.Contains($pattern)) { $hasMojibake = $true; break }
  }
  if ($hasMojibake) {
    $result.mojibakeSequences++
    $result.failures += "${relative}: common mojibake sequence"
  }
  $hasDoubleEncodedThai = $hasC1 -and $hasMojibake
  if ($hasDoubleEncodedThai) {
    $result.doubleEncodedThai++
    $result.failures += "${relative}: double-encoded Thai signature"
  }
}

$targetsToCheck = @()
if ($RequireIdentityTargets) {
  $targetsToCheck = $identityTargets
} else {
  $targetsToCheck = @($decoded.Keys | Where-Object { $decoded[$_].Contains('source-of-truth') })
}
foreach ($relative in $targetsToCheck) {
  if (-not $decoded.ContainsKey($relative)) {
    $result.generatedIdentityMismatch++
    $result.failures += "${relative}: missing identity target"
    continue
  }
  $text = $decoded[$relative]
  $canonicalCount = ([regex]::Matches($text, [regex]::Escape($canonicalLine))).Count
  if ($canonicalCount -ne 1) {
    $result.generatedIdentityMismatch++
    $result.failures += "${relative}: canonical generated identity count $canonicalCount"
  }
  $identityLines = @($text -split "`r?`n" | Where-Object { $_.Contains('source-of-truth') })
  foreach ($line in $identityLines) {
    $toolIndex = $line.IndexOf('tool/')
    if ($toolIndex -lt 0 -or $line.Contains([char]9)) {
      $result.invalidGeneratedToolPath++
      $result.failures += "${relative}: generated tool path does not begin with tool/"
      break
    }
  }
}

$result.passed = $result.failures.Count -eq 0
$json = ($result | ConvertTo-Json -Depth 6) + "`n"
if ($ReportPath) {
  $reportFullPath = [System.IO.Path]::GetFullPath($ReportPath)
  [System.IO.Directory]::CreateDirectory((Split-Path -Parent $reportFullPath)) | Out-Null
  [System.IO.File]::WriteAllText($reportFullPath, $json, $utf8NoBom)
}
$json
if (-not $result.passed) { throw "UTF-8 validation failed with $($result.failures.Count) finding(s)" }
