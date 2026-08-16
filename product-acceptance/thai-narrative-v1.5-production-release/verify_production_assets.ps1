$ErrorActionPreference = 'Stop'

$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$manifestPath = Join-Path $PSScriptRoot 'build-manifest.tsv'
$manifest = Import-Csv -LiteralPath $manifestPath -Delimiter "`t"
$deployable = @($manifest | Where-Object { -not $_.Path.StartsWith('.') })
$baseUrl = 'https://knowme-app-694e1.web.app'
$cacheBust = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AutomaticDecompression = [System.Net.DecompressionMethods]::GZip -bor [System.Net.DecompressionMethods]::Deflate -bor [System.Net.DecompressionMethods]::Brotli
$client = [System.Net.Http.HttpClient]::new($handler)
$client.DefaultRequestHeaders.CacheControl = [System.Net.Http.Headers.CacheControlHeaderValue]::Parse('no-cache, no-store, max-age=0')
$client.Timeout = [TimeSpan]::FromSeconds(30)

function Get-RemoteAsset([string]$relativePath, [string]$expectedSha256, [long]$expectedBytes) {
  $encodedPath = (($relativePath -split '/') | ForEach-Object { [Uri]::EscapeDataString($_) }) -join '/'
  $url = "$baseUrl/$encodedPath`?release_verify=$cacheBust"
  $response = $client.GetAsync($url).GetAwaiter().GetResult()
  $data = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
  $sha256 = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($data))
  [ordered]@{
    path = $relativePath
    status = [int]$response.StatusCode
    expectedBytes = $expectedBytes
    actualBytes = $data.Length
    expectedSha256 = $expectedSha256
    actualSha256 = $sha256
    cacheControl = if ($response.Headers.CacheControl) { $response.Headers.CacheControl.ToString() } else { $null }
    contentType = if ($response.Content.Headers.ContentType) { $response.Content.Headers.ContentType.ToString() } else { $null }
    match = ($response.IsSuccessStatusCode -and $data.Length -eq $expectedBytes -and $sha256 -eq $expectedSha256)
  }
}

try {
  $assets = foreach ($entry in $deployable) {
    Get-RemoteAsset -relativePath $entry.Path -expectedSha256 $entry.SHA256 -expectedBytes ([long]$entry.Bytes)
  }

  $index = $manifest | Where-Object Path -eq 'index.html'
  $routes = foreach ($route in @('/', '/beta/thai')) {
    $url = "$baseUrl$route`?release_verify=$cacheBust"
    $response = $client.GetAsync($url).GetAwaiter().GetResult()
    $data = $response.Content.ReadAsByteArrayAsync().GetAwaiter().GetResult()
    $sha256 = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($data))
    [ordered]@{
      route = $route
      status = [int]$response.StatusCode
      bytes = $data.Length
      sha256 = $sha256
      expectedIndexSha256 = $index.SHA256
      cacheControl = if ($response.Headers.CacheControl) { $response.Headers.CacheControl.ToString() } else { $null }
      contentType = if ($response.Content.Headers.ContentType) { $response.Content.Headers.ContentType.ToString() } else { $null }
      match = ($response.IsSuccessStatusCode -and $sha256 -eq $index.SHA256)
    }
  }

  $mismatches = @($assets | Where-Object { -not $_.match })
  $routeMismatches = @($routes | Where-Object { -not $_.match })
  $result = [ordered]@{
    verifiedUtc = (Get-Date).ToUniversalTime().ToString('o')
    baseUrl = $baseUrl
    sourceHead = '7a2bdea4d88ebd3e87ee7268641a37a70a7a959f'
    buildManifestSha256 = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToUpperInvariant()
    buildManifestEntries = $manifest.Count
    firebaseIgnoredEntries = @('.last_build_id')
    deployableEntries = $deployable.Count
    matchedAssets = $deployable.Count - $mismatches.Count
    assetMismatches = $mismatches.Count
    matchedRoutes = $routes.Count - $routeMismatches.Count
    routeMismatches = $routeMismatches.Count
    assets = $assets
    routes = $routes
    status = if ($mismatches.Count -eq 0 -and $routeMismatches.Count -eq 0) { 'PASS' } else { 'BLOCKED' }
  }
  $result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'production-asset-verification.json') -Encoding utf8NoBOM
  [pscustomobject]$result | Select-Object verifiedUtc,deployableEntries,matchedAssets,assetMismatches,matchedRoutes,routeMismatches,status | ConvertTo-Json
  if ($result.status -ne 'PASS') { exit 1 }
}
finally {
  $client.Dispose()
  $handler.Dispose()
}
