# Build a Cloud Run source directory containing only PR149's calculation API.
$ErrorActionPreference = 'Stop'
$RepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$BackendRoot = Join-Path $RepoRoot 'backend'
$StageRoot = Join-Path $RepoRoot '.preview-build-pr149'
if (-not $StageRoot.StartsWith($RepoRoot + [System.IO.Path]::DirectorySeparatorChar,
        [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Unsafe preview staging path'
}
if (Test-Path -LiteralPath $StageRoot) {
    Remove-Item -LiteralPath $StageRoot -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $StageRoot 'app/services') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $BackendRoot 'Dockerfile.preview') -Destination (Join-Path $StageRoot 'Dockerfile')
Copy-Item -LiteralPath (Join-Path $BackendRoot 'requirements-preview.txt') -Destination $StageRoot
Copy-Item -LiteralPath (Join-Path $BackendRoot 'app/preview_main.py') -Destination (Join-Path $StageRoot 'app')
Copy-Item -LiteralPath (Join-Path $BackendRoot 'app/services/overall_summary_service.py') -Destination (Join-Path $StageRoot 'app/services')
Copy-Item -LiteralPath (Join-Path $BackendRoot 'app/services/astrology') -Destination (Join-Path $StageRoot 'app/services/astrology') -Recurse
Copy-Item -LiteralPath (Join-Path $BackendRoot 'app/services/bazi') -Destination (Join-Path $StageRoot 'app/services/bazi') -Recurse
Remove-Item -LiteralPath (Join-Path $StageRoot 'app/services/astrology/save_chart_service.py')
Remove-Item -LiteralPath (Join-Path $StageRoot 'app/services/bazi/save_bazi_service.py')
$Files = Get-ChildItem -LiteralPath $StageRoot -Recurse -File
if ($Files | Where-Object { $_.Name -match 'firebase|firestore|save_(chart|bazi)' }) {
    throw 'Preview source includes a persistence module'
}
$ImportMatches = $Files | Where-Object Extension -eq '.py' | Select-String -Pattern '^\s*(from|import)\s+(firebase|google\.cloud|app\.services\.firebase)'
if ($ImportMatches) {
    throw 'Preview source imports Firebase or Google Cloud data libraries'
}
Write-Output $StageRoot
