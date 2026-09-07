[CmdletBinding()]
param(
  [string]$ImplementationShortSha = "8d6dde1"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repo = [IO.Path]::GetFullPath((& git rev-parse --show-toplevel).Trim())
$buildRoot = [IO.Path]::GetFullPath((Join-Path $repo "build"))
$staging = [IO.Path]::GetFullPath((Join-Path $buildRoot "or10r-owner-review"))
$extract = [IO.Path]::GetFullPath((Join-Path $buildRoot "or10r-owner-review-extracted"))
$zipName = "OWNER_REVIEW_THAI_PREDICTIVE_NARRATIVE_V2_RUNTIME_V2_OR10R_${ImplementationShortSha}.zip"
$zipPath = [IO.Path]::GetFullPath((Join-Path (Split-Path $repo -Parent) $zipName))

foreach ($path in @($staging, $extract)) {
  if (-not $path.StartsWith($buildRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Unsafe generated directory: $path"
  }
  if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
  New-Item -ItemType Directory -Path $path -Force | Out-Null
}
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

$productDir = Join-Path $staging "artifacts/product"
$rasterDir = Join-Path $staging "artifacts/pdf-raster"
$sheetDir = Join-Path $staging "artifacts/contact-sheets"
$runtimeDir = Join-Path $staging "evidence/runtime"
$docsDir = Join-Path $staging "evidence/docs"
foreach ($path in @($productDir, $rasterDir, $sheetDir, $runtimeDir, $docsDir)) {
  New-Item -ItemType Directory -Path $path -Force | Out-Null
}

Copy-Item -Path (Join-Path $buildRoot "or10r-owner-product/*") -Destination $productDir -Recurse -Force
Copy-Item -Path (Join-Path $buildRoot "or10r-pdf-raster/*") -Destination $rasterDir -Recurse -Force
Copy-Item -Path (Join-Path $buildRoot "or10r-contact-sheets/*") -Destination $sheetDir -Recurse -Force

$runtimeEvidence = @(
  "OR5_ACTUAL_0035_RUNTIME_EVIDENCE.json",
  "OR5_DETERMINISM.json",
  "OR5_INPUT_BOUND_MATERIALS_49.json",
  "OR5_NEGATIVE_CONTROLS.json",
  "OR5_RAW_0003_20260807.json",
  "OR5_RAW_0003_20260829.json",
  "OR5_SENTINEL_CONTAINMENT.json",
  "OR5_UNKNOWN_CONTROL.json",
  "OR5_UNKNOWN_RUNTIME_EVIDENCE.json",
  "OR5R_UNKNOWN_75_PLACEHOLDERS.json"
)
foreach ($name in $runtimeEvidence) {
  $source = Join-Path $buildRoot "or10r-runtime-evidence/$name"
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing runtime evidence: $source" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $runtimeDir $name) -Force
}

$evidenceDocs = @(
  "docs/CANDIDATE_0022_TO_0023_BEFORE_AFTER.md",
  "docs/CANDIDATE_0023_ACTUAL_0035_FULL_READER_COPY.md",
  "docs/CANDIDATE_0023_CLAIM_MAP.json",
  "docs/CANDIDATE_0023_CLAIM_MAP.md",
  "docs/CANDIDATE_0023_CONTENT_AUDIT.json",
  "docs/CANDIDATE_0023_CONTENT_AUDIT.md",
  "docs/CANDIDATE_0023_EXACT_COPY_EVIDENCE.json",
  "docs/CANDIDATE_0023_EXACT_COPY_EVIDENCE.md",
  "docs/CANDIDATE_0023_SEMANTIC_OWNERSHIP.json",
  "docs/CANDIDATE_0023_SEMANTIC_OWNERSHIP.md",
  "docs/PR115_OR10_CONTRACT_CONFLICT_TRUTH_CORRECTION.json",
  "docs/PR115_OR10_CONTRACT_CONFLICT_TRUTH_CORRECTION.md",
  "docs/PREDICTIVE_SIGNATURE_OUTPUT_CONTRACT_V1.md",
  "docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.json",
  "docs/PREDICTIVE_RUNTIME_V2_GENERALIZATION_AUDIT.md",
  "docs/PR115_OR10R_VALIDATION.json"
)
foreach ($relative in $evidenceDocs) {
  $source = Join-Path $repo $relative
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing evidence document: $source" }
  Copy-Item -LiteralPath $source -Destination (Join-Path $docsDir ([IO.Path]::GetFileName($source))) -Force
}

$validation = Get-Content -Raw -LiteralPath (Join-Path $repo "docs/PR115_OR10R_VALIDATION.json") | ConvertFrom-Json
$ownerReview = @"
# PR115 OR10R Owner Product Review

สถานะ: **ENGINEERING VALIDATION COMPLETE — PENDING OWNER PRODUCT RE-REVIEW — DRAFT — NOT MERGED — NOT DEPLOYED**

ชุดนี้สร้างจาก implementation commit `$ImplementationShortSha` หลังแก้ contract ให้ Candidate 0023 เป็น runtime target ของ predictive signature ไม่ใช่ target ของนาทีเกิดเฉพาะ fixture

## จุดที่ Owner ต้องตรวจ

- Known 00:03 และ 00:35 ต้องได้เนื้อหาคำทำนาย Candidate 0023 ชุดเดียวกัน เพราะ signature เท่ากัน
- ตัวตนและ provenance ต้องยังต่างกัน: 00:03 = Aquarius 9°24′, 00:35 = Aquarius 19°19′
- Candidate 0023 เต็มฉบับต้องตรง SHA-256 `FDA1DA8917CD5ADCA4650AECF87414DCFCDEE7F13019DF0794ECF76DFD91E7F2`
- Candidate 0011 ต้องคงเป็น historical golden oracle เท่านั้น และคง SHA-256 `6AA94C7A01555310C5189FAAF711597057C5DF2F102246A0DF3946DAB2B62A1E`
- Unknown ต้อง fail-closed: ไม่มีลัคนา เรือน Known copy หรือ infographic
- Web, Dedicated PDF, browser print และ infographic ต้องอ่านเรื่องเดียวกัน ไม่มีข้อความขาด ซ้ำ ล้น ทับ หรือถูกตัด

## ไฟล์หลัก

- `artifacts/product/`: Web captures ที่ 1440/390/360, canonical JSON, print DOM, infographic และ PDF จริง
- `artifacts/pdf-raster/`: raster ทุกหน้าของ PDF ทั้ง 6 ฉบับ รวม 22 หน้า
- `artifacts/contact-sheets/`: contact sheet 16 ไฟล์ ครอบคลุม Web, infographic และ PDF ทุกหน้า
- `evidence/docs/`: Candidate 0023 full copy, Before/After, claim/evidence/semantic audit, contract correction และ validation
- `evidence/runtime/`: actual input-bound materials, raw forecast, determinism, negative controls และ Unknown containment

## จำนวนหน้าจริง

| Surface | Dedicated PDF | Chrome browser print |
|---|---:|---:|
| Known 00:03 | 5 | 5 |
| Known 00:35 | 5 | 5 |
| Unknown | 1 | 1 |

Known หน้า 3 เป็น infographic แบบ image-only จึงมีข้อความ extract ได้ 0 ตัวอักษร แต่ไม่ใช่หน้าว่าง การตรวจใช้ raster จริงร่วมกับ exact canonical-to-print-DOM parity

## ผล engineering validation

- 49/49 contexts, 392/392 periods, 300 profiles
- Known complete 225/225; Unknown fail-closed 75/75; fixture-specific branch 0; unsupported claim 0
- Node 9/9; runtime/input/evidence 24/24; focused narrative/export/infographic/artifact 281/281
- copy audit 300 profiles / 24,186 fields / semantic-omission-addition-traceability impacts 0
- Full required Flutter suite 1,644/1,644; Analyzer 298 baseline diagnostics / new OR10R diagnostics 0
- PDF 6/6 opened; raster 22/22 opened; contact sheet 16/16 opened; blank/clipping/overlap/overflow 0
- `product-acceptance/`, Firebase, Production และ deployment delta = 0

ผลนี้เป็น technical evidence เพื่อ Owner review เท่านั้น ไม่ใช่การประกาศ Owner Product Acceptance
"@
Set-Content -LiteralPath (Join-Path $staging "OWNER_REVIEW.md") -Value $ownerReview -Encoding utf8

$testSummary = [ordered]@{
  implementationCommit = $ImplementationShortSha
  fullRequiredFlutterSuite = "1644/1644"
  nodeSignatureAndFoundation = "9/9"
  runtimeInputAndEvidence = "24/24"
  focusedNarrativeExportInfographicArtifact = "281/281"
  pdfTitleOnlyRegression = "4/4"
  analyzerBaselineDiagnostics = 298
  analyzerNewOr10rDiagnostics = 0
  contexts = "49/49"
  periods = "392/392"
  profiles = 300
  knownComplete = "225/225"
  unknownFailClosed = "75/75"
  preCommit = [string]$validation.tests.preCommit
  postCommit = [string]$validation.tests.postCommit
}
Set-Content -LiteralPath (Join-Path $staging "TEST_SUMMARY.json") -Value (($testSummary | ConvertTo-Json -Depth 5) + "`n") -Encoding utf8

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
  schema = "pr115-or10r-owner-review-manifest/1"
  implementationCommit = $ImplementationShortSha
  payloadCount = $payload.Count
  payload = $payload
}
$manifestPath = Join-Path $staging "MANIFEST.json"
Set-Content -LiteralPath $manifestPath -Value (($manifest | ConvertTo-Json -Depth 8) + "`n") -Encoding utf8

$sumItems = @($payload) + @([ordered]@{
  path = "MANIFEST.json"
  bytes = (Get-Item -LiteralPath $manifestPath).Length
  sha256 = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToUpperInvariant()
})
$sumLines = @($sumItems | ForEach-Object { "$($_.sha256)  $($_.path)" })
Set-Content -LiteralPath (Join-Path $staging "SHA256SUMS.txt") -Value ($sumLines -join "`n") -Encoding utf8

Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -CompressionLevel Optimal

Add-Type -AssemblyName System.IO.Compression.FileSystem
$unsafePathErrors = 0
$crcErrors = 0
$archive = [IO.Compression.ZipFile]::OpenRead($zipPath)
try {
  foreach ($entry in $archive.Entries) {
    $name = $entry.FullName.Replace('\', '/')
    if ([IO.Path]::IsPathRooted($name) -or $name -match '(^|/)\.\.(/|$)') { $unsafePathErrors++ }
    if (-not $name.EndsWith('/')) {
      try {
        $stream = $entry.Open()
        try { $stream.CopyTo([IO.Stream]::Null) } finally { $stream.Dispose() }
      } catch { $crcErrors++ }
    }
  }
} finally { $archive.Dispose() }

Expand-Archive -LiteralPath $zipPath -DestinationPath $extract -Force
$extractedManifest = Get-Content -Raw -LiteralPath (Join-Path $extract "MANIFEST.json") | ConvertFrom-Json
$expected = @{}
foreach ($item in @($extractedManifest.payload)) { $expected[[string]$item.path] = $item }
$actualFiles = @(Get-ChildItem -LiteralPath $extract -Recurse -File | ForEach-Object { RelativePath $extract $_.FullName })
$actualPayload = @($actualFiles | Where-Object { $_ -notin @("MANIFEST.json", "SHA256SUMS.txt") })
$missing = @($expected.Keys | Where-Object { $_ -notin $actualPayload })
$extra = @($actualPayload | Where-Object { -not $expected.ContainsKey($_) })
$hashMismatch = 0
$sizeMismatch = 0
foreach ($path in $expected.Keys) {
  $full = Join-Path $extract $path
  if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { continue }
  $item = $expected[$path]
  if ((Get-Item -LiteralPath $full).Length -ne [long]$item.bytes) { $sizeMismatch++ }
  if ((Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToUpperInvariant() -ne [string]$item.sha256) { $hashMismatch++ }
}

$secretPatterns = @(
  'AIza[0-9A-Za-z_-]{35}',
  '-----BEGIN [A-Z ]*PRIVATE KEY-----',
  '(?i)password\s*[:=]\s*[^\s]+',
  '(?i)authorization\s*:\s*bearer\s+[^\s]+'
)
$secretHits = 0
$textExtensions = @('.md', '.json', '.txt', '.html')
foreach ($file in Get-ChildItem -LiteralPath $extract -Recurse -File) {
  if ($textExtensions -notcontains $file.Extension.ToLowerInvariant()) { continue }
  $text = Get-Content -Raw -LiteralPath $file.FullName
  foreach ($pattern in $secretPatterns) { if ($text -match $pattern) { $secretHits++ } }
}

$result = [ordered]@{
  status = if (($missing.Count + $extra.Count + $hashMismatch + $sizeMismatch + $unsafePathErrors + $crcErrors + $secretHits) -eq 0) { "PASS" } else { "FAIL" }
  zipPath = $zipPath
  zipBytes = (Get-Item -LiteralPath $zipPath).Length
  zipSha256 = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash.ToUpperInvariant()
  payloadCount = [int]$extractedManifest.payloadCount
  missingCount = $missing.Count
  extraCount = $extra.Count
  hashMismatchCount = $hashMismatch
  sizeMismatchCount = $sizeMismatch
  unsafePathCount = $unsafePathErrors
  crcErrorCount = $crcErrors
  secretHitCount = $secretHits
}
$resultPath = Join-Path $buildRoot "or10r-package-validation.json"
Set-Content -LiteralPath $resultPath -Value (($result | ConvertTo-Json -Depth 5) + "`n") -Encoding utf8
$result | ConvertTo-Json -Depth 5
if ($result.status -ne "PASS") { exit 1 }
