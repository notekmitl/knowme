param(
  [Parameter(Mandatory = $true)]
  [string]$RenderRoot,
  [Parameter(Mandatory = $true)]
  [string]$OriginalRenderRoot,
  [Parameter(Mandatory = $true)]
  [string]$OutputRoot
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$renderPath = [System.IO.Path]::GetFullPath($RenderRoot)
$originalPath = [System.IO.Path]::GetFullPath($OriginalRenderRoot)
$outputPath = [System.IO.Path]::GetFullPath($OutputRoot)
[System.IO.Directory]::CreateDirectory($outputPath) | Out-Null

function New-ReviewSheet {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo[]]$Files,
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [Parameter(Mandatory = $true)]
    [string]$Title
  )
  if ($Files.Count -eq 0) { throw "No images supplied for $Target" }
  $cellWidth = 760
  $labelHeight = 58
  $titleHeight = 64
  $columns = 2
  $scaledHeights = @()
  foreach ($file in $Files) {
    $image = [System.Drawing.Image]::FromFile($file.FullName)
    try { $scaledHeights += [int][Math]::Round($image.Height * $cellWidth / $image.Width) }
    finally { $image.Dispose() }
  }
  $cellHeight = ($scaledHeights | Measure-Object -Maximum).Maximum + $labelHeight
  $rows = [int][Math]::Ceiling($Files.Count / $columns)
  $sheet = [System.Drawing.Bitmap]::new($cellWidth * $columns, $titleHeight + $rows * $cellHeight)
  $graphics = [System.Drawing.Graphics]::FromImage($sheet)
  $titleFont = [System.Drawing.Font]::new('Arial', 22, [System.Drawing.FontStyle]::Bold)
  $labelFont = [System.Drawing.Font]::new('Arial', 12, [System.Drawing.FontStyle]::Bold)
  try {
    $graphics.Clear([System.Drawing.Color]::FromArgb(230, 230, 230))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.FillRectangle([System.Drawing.Brushes]::White, 0, 0, $sheet.Width, $titleHeight)
    $graphics.DrawString($Title, $titleFont, [System.Drawing.Brushes]::Black, 14, 14)
    for ($index = 0; $index -lt $Files.Count; $index++) {
      $column = $index % $columns
      $row = [int][Math]::Floor($index / $columns)
      $x = $column * $cellWidth
      $y = $titleHeight + $row * $cellHeight
      $file = $Files[$index]
      $image = [System.Drawing.Image]::FromFile($file.FullName)
      try { $graphics.DrawImage($image, $x, $y, $cellWidth, $scaledHeights[$index]) }
      finally { $image.Dispose() }
      $labelY = $y + $scaledHeights[$index]
      $graphics.FillRectangle([System.Drawing.Brushes]::White, $x, $labelY, $cellWidth, $labelHeight)
      $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash.Substring(0, 12)
      $graphics.DrawString("$($file.BaseName)  SHA256:$hash", $labelFont, [System.Drawing.Brushes]::Black, $x + 8, $labelY + 13)
    }
    $sheet.Save($Target, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  finally {
    $labelFont.Dispose()
    $titleFont.Dispose()
    $graphics.Dispose()
    $sheet.Dispose()
  }
}

function New-ChunkedSheets {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo[]]$Files,
    [Parameter(Mandatory = $true)]
    [string]$Stem,
    [Parameter(Mandatory = $true)]
    [string]$Title
  )
  $chunkSize = 4
  for ($offset = 0; $offset -lt $Files.Count; $offset += $chunkSize) {
    $last = [Math]::Min($offset + $chunkSize - 1, $Files.Count - 1)
    $chunk = @($Files[$offset..$last])
    $number = [int]($offset / $chunkSize) + 1
    $target = [System.IO.Path]::Combine($outputPath, ('{0}-{1:D2}.png' -f $Stem, $number))
    New-ReviewSheet -Files $chunk -Target $target -Title "$Title — sheet $number"
  }
}

$all = @(Get-ChildItem -LiteralPath $renderPath -Filter '*.png' -File | Sort-Object Name)
$browserKnown = @($all | Where-Object Name -Like 'browser-print-*.png' | Where-Object Name -NotMatch 'owner-unknown|browser-print-unknown')
$browserUnknown = @($all | Where-Object Name -Match '^browser-print-(owner-unknown|unknown)-page-')
$dedicatedKnown = @($all | Where-Object Name -Like 'dedicated-report-*.png' | Where-Object Name -NotMatch 'owner-unknown|dedicated-report-unknown')
$dedicatedUnknown = @($all | Where-Object Name -Match '^dedicated-report-(owner-unknown|unknown)-page-')
$firstPages = @($all | Where-Object Name -Like '*-page-01.png')

New-ChunkedSheets -Files $browserKnown -Stem 'browser-print-known' -Title 'Browser-print Known PDFs'
New-ChunkedSheets -Files $browserUnknown -Stem 'browser-print-unknown' -Title 'Browser-print Unknown PDFs'
New-ChunkedSheets -Files $dedicatedKnown -Stem 'dedicated-known' -Title 'Dedicated Known PDFs'
New-ChunkedSheets -Files $dedicatedUnknown -Stem 'dedicated-unknown' -Title 'Dedicated Unknown PDFs'
New-ChunkedSheets -Files $firstPages -Stem 'all-fixture-first-page' -Title 'All fixture first pages'

$beforeAfter = @(
  Get-Item -LiteralPath ([System.IO.Path]::Combine($originalPath, 'browser-print-owner-known-0035', 'page-1.png'))
  Get-Item -LiteralPath ([System.IO.Path]::Combine($renderPath, 'browser-print-owner-known-0035-page-01.png'))
  Get-Item -LiteralPath ([System.IO.Path]::Combine($originalPath, 'dedicated-report-owner-known-0035', 'page-1.png'))
  Get-Item -LiteralPath ([System.IO.Path]::Combine($renderPath, 'dedicated-report-owner-known-0035-page-01.png'))
)
New-ReviewSheet -Files $beforeAfter -Target ([System.IO.Path]::Combine($outputPath, 'owner-known-page-1-before-after.png')) -Title 'Owner Known page 1 — original bytes vs identity-bound rerender'

"sheets=$((Get-ChildItem -LiteralPath $outputPath -Filter '*.png' -File).Count)"
