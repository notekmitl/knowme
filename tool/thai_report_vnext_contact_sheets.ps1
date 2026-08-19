param(
  [Parameter(Mandatory = $true)]
  [string]$RendersRoot,
  [Parameter(Mandatory = $true)]
  [string]$OutputRoot
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$renderRoot = [System.IO.Path]::GetFullPath($RendersRoot)
$outputRoot = [System.IO.Path]::GetFullPath($OutputRoot)
[System.IO.Directory]::CreateDirectory($outputRoot) | Out-Null

foreach ($name in @('dedicated-known', 'dedicated-unknown', 'browser-known-final', 'browser-unknown-final')) {
  $source = [System.IO.Path]::Combine($renderRoot, $name)
  $pages = @(Get-ChildItem -LiteralPath $source -File -Filter '*.png' | Sort-Object Name)
  if ($pages.Count -eq 0) { throw "No rendered pages in $source" }
  $columns = 3
  $thumbWidth = 300
  $labelHeight = 34
  $first = [System.Drawing.Image]::FromFile($pages[0].FullName)
  try { $thumbHeight = [int][Math]::Round($first.Height * $thumbWidth / $first.Width) }
  finally { $first.Dispose() }
  $rows = [int][Math]::Ceiling($pages.Count / $columns)
  $sheet = [System.Drawing.Bitmap]::new($columns * $thumbWidth, $rows * ($thumbHeight + $labelHeight))
  $graphics = [System.Drawing.Graphics]::FromImage($sheet)
  try {
    $graphics.Clear([System.Drawing.Color]::FromArgb(238, 238, 238))
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $font = [System.Drawing.Font]::new('Arial', 14, [System.Drawing.FontStyle]::Bold)
    $brush = [System.Drawing.Brushes]::Black
    for ($index = 0; $index -lt $pages.Count; $index++) {
      $column = $index % $columns
      $row = [int][Math]::Floor($index / $columns)
      $x = $column * $thumbWidth
      $y = $row * ($thumbHeight + $labelHeight)
      $page = [System.Drawing.Image]::FromFile($pages[$index].FullName)
      try { $graphics.DrawImage($page, $x, $y, $thumbWidth, $thumbHeight) }
      finally { $page.Dispose() }
      $graphics.DrawString("$name / page $($index + 1)", $font, $brush, $x + 8, $y + $thumbHeight + 6)
    }
    $target = [System.IO.Path]::Combine($outputRoot, "$name-contact-sheet.png")
    $sheet.Save($target, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  finally {
    if ($font) { $font.Dispose() }
    $graphics.Dispose()
    $sheet.Dispose()
  }
}
