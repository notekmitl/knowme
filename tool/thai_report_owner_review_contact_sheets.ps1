param(
  [Parameter(Mandatory = $true)]
  [string]$ArtifactRoot,
  [Parameter(Mandatory = $true)]
  [string]$RenderRoot,
  [Parameter(Mandatory = $true)]
  [string]$OutputRoot
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$artifactPath = [System.IO.Path]::GetFullPath($ArtifactRoot)
$renderPath = [System.IO.Path]::GetFullPath($RenderRoot)
$outputPath = [System.IO.Path]::GetFullPath($OutputRoot)
[System.IO.Directory]::CreateDirectory($outputPath) | Out-Null

function New-ReadableVerticalSheet {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo[]]$Files,
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [Parameter(Mandatory = $true)]
    [int]$Width
  )
  if ($Files.Count -eq 0) { throw "No images supplied for $Target" }
  $labelHeight = 42
  $heights = @()
  foreach ($file in $Files) {
    $image = [System.Drawing.Image]::FromFile($file.FullName)
    try { $heights += [int][Math]::Round($image.Height * $Width / $image.Width) }
    finally { $image.Dispose() }
  }
  $sheetHeight = ($heights | Measure-Object -Sum).Sum + $Files.Count * $labelHeight
  $sheet = [System.Drawing.Bitmap]::new($Width, $sheetHeight)
  $graphics = [System.Drawing.Graphics]::FromImage($sheet)
  $font = [System.Drawing.Font]::new('Arial', 15, [System.Drawing.FontStyle]::Bold)
  try {
    $graphics.Clear([System.Drawing.Color]::FromArgb(238, 238, 238))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $y = 0
    for ($index = 0; $index -lt $Files.Count; $index++) {
      $file = $Files[$index]
      $image = [System.Drawing.Image]::FromFile($file.FullName)
      try { $graphics.DrawImage($image, 0, $y, $Width, $heights[$index]) }
      finally { $image.Dispose() }
      $y += $heights[$index]
      $graphics.FillRectangle([System.Drawing.Brushes]::White, 0, $y, $Width, $labelHeight)
      $graphics.DrawString($file.BaseName, $font, [System.Drawing.Brushes]::Black, 10, $y + 8)
      $y += $labelHeight
    }
    $sheet.Save($Target, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  finally {
    $font.Dispose()
    $graphics.Dispose()
    $sheet.Dispose()
  }
}

$canonicalIds = @(
  'owner-known-0035',
  'owner-unknown',
  'regression-known-0003',
  'comparison-known-bangkok',
  'comparison-known-khon-kaen'
)
$canonicalFiles = @(
  foreach ($id in $canonicalIds) {
    Get-Item -LiteralPath ([System.IO.Path]::Combine($artifactPath, "annual-infographic-$id.png"))
  }
)
New-ReadableVerticalSheet -Files $canonicalFiles -Target ([System.IO.Path]::Combine($outputPath, 'infographic-canonical-five-contact-sheet.png')) -Width 720

$stressIds = @(
  'known',
  'unknown',
  'stress-known-longest',
  'stress-unknown-longest',
  'stress-thai-multiline',
  'stress-opportunity-caution-longest',
  'stress-disclaimer-longest',
  'stress-regression-1972',
  'year-boundary-2569',
  'year-boundary-2570'
)
$stressFiles = @(
  foreach ($id in $stressIds) {
    Get-Item -LiteralPath ([System.IO.Path]::Combine($artifactPath, "annual-infographic-$id.png"))
  }
)
New-ReadableVerticalSheet -Files $stressFiles -Target ([System.IO.Path]::Combine($outputPath, 'infographic-stress-contact-sheet.png')) -Width 720

$pdfSheetRoot = [System.IO.Path]::Combine($outputPath, 'pdf-contact-sheets')
[System.IO.Directory]::CreateDirectory($pdfSheetRoot) | Out-Null
foreach ($directory in Get-ChildItem -LiteralPath $renderPath -Directory | Sort-Object Name) {
  $pages = @(Get-ChildItem -LiteralPath $directory.FullName -Filter '*.png' -File | Sort-Object Name)
  New-ReadableVerticalSheet -Files $pages -Target ([System.IO.Path]::Combine($pdfSheetRoot, "$($directory.Name)-contact-sheet.png")) -Width 760
}
