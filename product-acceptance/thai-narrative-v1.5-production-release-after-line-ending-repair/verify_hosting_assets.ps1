param(
  [Parameter(Mandatory = $true)][string]$BaseUrl,
  [Parameter(Mandatory = $true)][ValidatePattern('^[a-z0-9-]+$')][string]$Label
)

$ErrorActionPreference = 'Stop'
$manifestPath = Join-Path $PSScriptRoot 'hosting-asset-manifest.json'
$manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
$cacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor
  [System.Net.DecompressionMethods]::Deflate -bor
  [System.Net.DecompressionMethods]::Brotli
$client = [System.Net.Http.HttpClient]::new($handler)
$client.DefaultRequestHeaders.CacheControl =
  [System.Net.Http.Headers.CacheControlHeaderValue]::Parse(
    'no-cache, no-store, max-age=0'
  )
$client.Timeout = [TimeSpan]::FromSeconds(45)

function Get-RemoteAsset($entry) {
  $encodedPath = (($entry.path -split '/') | ForEach-Object {
      [Uri]::EscapeDataString($_)
    }) -join '/'
  $url = "$BaseUrl/$encodedPath`?release_verify=$cacheBust"
  $response = $client.GetAsync($url).GetAwaiter().GetResult()
  $data = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
  $sha256 = [Convert]::ToHexString(
    [Security.Cryptography.SHA256]::HashData($data)
  )
  [ordered]@{
    path = $entry.path
    status = [int]$response.StatusCode
    expectedBytes = [long]$entry.bytes
    actualBytes = $data.Length
    expectedSha256 = $entry.sha256
    actualSha256 = $sha256
    contentType = if ($response.Content.Headers.ContentType) {
      $response.Content.Headers.ContentType.ToString()
    } else { $null }
    match = (
      $response.IsSuccessStatusCode -and
      $data.Length -eq [long]$entry.bytes -and
      $sha256 -eq $entry.sha256
    )
  }
}

try {
  $assets = foreach ($entry in $manifest.entries) {
    Get-RemoteAsset $entry
  }
  $index = $manifest.entries | Where-Object path -eq 'index.html'
  $routes = foreach ($route in @('/', '/beta/thai')) {
    $url = "$BaseUrl$route`?release_verify=$cacheBust"
    $response = $client.GetAsync($url).GetAwaiter().GetResult()
    $data = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
    $sha256 = [Convert]::ToHexString(
      [Security.Cryptography.SHA256]::HashData($data)
    )
    [ordered]@{
      route = $route
      status = [int]$response.StatusCode
      actualBytes = $data.Length
      actualSha256 = $sha256
      expectedIndexSha256 = $index.sha256
      match = ($response.IsSuccessStatusCode -and $sha256 -eq $index.sha256)
    }
  }
  $assetMismatches = @($assets | Where-Object { -not $_.match })
  $routeMismatches = @($routes | Where-Object { -not $_.match })
  $result = [ordered]@{
    schema = 'knowme-v15-hosting-asset-verification-v1'
    verifiedUtc = (Get-Date).ToUniversalTime().ToString('o')
    baseUrl = $BaseUrl
    sourceCommit = '642069f0f298bc8a1f86b795f043e02e914aa97d'
    hostingManifestSha256 = (
      Get-FileHash -Algorithm SHA256 -LiteralPath $manifestPath
    ).Hash
    deployableEntries = $manifest.fileCount
    matchedAssets = $manifest.fileCount - $assetMismatches.Count
    assetMismatches = $assetMismatches.Count
    matchedRoutes = $routes.Count - $routeMismatches.Count
    routeMismatches = $routeMismatches.Count
    assets = $assets
    routes = $routes
    status = if (
      $assetMismatches.Count -eq 0 -and $routeMismatches.Count -eq 0
    ) { 'PASS' } else { 'BLOCKED' }
  }
  $output = Join-Path $PSScriptRoot "$Label-asset-verification.json"
  [IO.File]::WriteAllText(
    $output,
    (($result | ConvertTo-Json -Depth 8) + "`n"),
    [Text.UTF8Encoding]::new($false)
  )
  [pscustomobject]$result |
    Select-Object verifiedUtc,deployableEntries,matchedAssets,assetMismatches,
      matchedRoutes,routeMismatches,status |
    ConvertTo-Json
  if ($result.status -ne 'PASS') { exit 1 }
}
finally {
  $client.Dispose()
  $handler.Dispose()
}
