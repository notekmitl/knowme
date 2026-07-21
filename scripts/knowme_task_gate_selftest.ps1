[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$GateSource = Join-Path $PSScriptRoot 'knowme_task_gate.ps1'
if (-not (Test-Path -LiteralPath $GateSource)) {
  Write-Host "[SELFTEST FAIL] Missing gate script: $GateSource" -ForegroundColor Red
  exit 1
}

$Passed = 0
$Failed = 0

function Write-Case([string]$Name, [bool]$Ok) {
  if ($Ok) {
    Write-Host "[SELFTEST PASS] $Name" -ForegroundColor Green
    $script:Passed++
  } else {
    Write-Host "[SELFTEST FAIL] $Name" -ForegroundColor Red
    $script:Failed++
  }
}

function New-TestRepo {
  $root = Join-Path $env:TEMP ("knowme-gate-selftest-{0}" -f [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $root -Force | Out-Null
  Push-Location $root
  git init -q | Out-Null
  git config user.email "gate-selftest@test.local"
  git config user.name "Gate Selftest"
  "seed" | Out-File -FilePath 'seed.txt' -Encoding utf8
  git add seed.txt | Out-Null
  git commit -m "seed" -q | Out-Null
  $base = (git rev-parse HEAD).Trim()
  $branch = (git branch --show-current).Trim()
  Pop-Location

  $scriptDir = Join-Path $root 'scripts'
  New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
  Copy-Item -LiteralPath $GateSource -Destination (Join-Path $scriptDir 'knowme_task_gate.ps1') -Force
  Push-Location $root
  git add scripts/knowme_task_gate.ps1 | Out-Null
  git commit -m 'add gate script for selftest' -q | Out-Null
  $base = (git rev-parse HEAD).Trim()
  Pop-Location

  return [pscustomobject]@{
    Root = $root
    BaseRef = $base
    Branch = $branch
  }
}

function Remove-TestRepo([string]$Root) {
  if (Test-Path -LiteralPath $Root) {
    Remove-Item -LiteralPath $Root -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Write-Scope {
  param(
    [string]$Root,
    [hashtable]$Overrides = @{}
  )
  $scope = @{
    schema_version = 1
    task_id = 'selftest'
    expected_branch = $Overrides['expected_branch']
    expected_worktree = $Overrides['expected_worktree']
    base_ref = $Overrides['base_ref']
    allowed_files = @($Overrides['allowed_files']) + @('task_scope.json')
    allowed_globs = @($Overrides['allowed_globs'])
    forbidden_files = @('.env', '.env.*')
    generated_output_globs = @('build/**')
    forbidden_text_patterns = @('OPENAI_API_KEY', 'api.openai.com')
    focused_tests = @($Overrides['focused_tests'])
    full_test_policy = $Overrides['full_test_policy']
    full_test_command = $Overrides['full_test_command']
    analyze_command = $Overrides['analyze_command']
    commit_message_regex = $Overrides['commit_message_regex']
    require_clean_tree_after_commit = $true
  }
  $json = $scope | ConvertTo-Json -Depth 6
  Set-Content -LiteralPath (Join-Path $Root 'task_scope.json') -Value $json -Encoding utf8
}

function Invoke-Gate {
  param(
    [string]$Root,
    [ValidateSet('PreCommit','PostCommit')]
    [string]$Phase = 'PreCommit'
  )
  Push-Location $Root
  & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass `
    -File (Join-Path $Root 'scripts/knowme_task_gate.ps1') `
    -ScopeFile 'task_scope.json' -Phase $Phase | Out-Null
  $code = $LASTEXITCODE
  Pop-Location
  return $code
}

function Test-ExpectFail {
  param([string]$Name, [scriptblock]$Setup)
  $repo = $null
  try {
    $repo = New-TestRepo
    & $Setup $repo
    $code = Invoke-Gate -Root $repo.Root -Phase PreCommit
    Write-Case $Name ($code -ne 0)
  } catch {
    Write-Case $Name $true
  } finally {
    if ($repo) { Remove-TestRepo $repo.Root }
  }
}

function Test-ExpectPass {
  param([string]$Name, [scriptblock]$Setup)
  $repo = $null
  try {
    $repo = New-TestRepo
    & $Setup $repo
    $pre = Invoke-Gate -Root $repo.Root -Phase PreCommit
    if ($pre -ne 0) {
      Write-Case $Name $false
      return
    }
    Push-Location $repo.Root
    git add -A | Out-Null
    git commit -m "selftest: happy path commit message" -q | Out-Null
    Pop-Location
    $post = Invoke-Gate -Root $repo.Root -Phase PostCommit
    Write-Case $Name ($post -eq 0)
  } catch {
    Write-Case $Name $false
  } finally {
    if ($repo) { Remove-TestRepo $repo.Root }
  }
}

$commonScope = {
  param($repo)
  Write-Scope -Root $repo.Root -Overrides @{
    expected_branch = $repo.Branch
    expected_worktree = $repo.Root
    base_ref = $repo.BaseRef
    allowed_files = @('allowed.txt')
    allowed_globs = @()
    focused_tests = @('exit 0')
    full_test_policy = 'skip'
    full_test_command = 'SKIP'
    analyze_command = 'SKIP'
    commit_message_regex = '^selftest: .{10,72}$'
  }
}

Test-ExpectFail 'wrong branch' {
  param($repo)
  Write-Scope -Root $repo.Root -Overrides @{
    expected_branch = 'wrong-branch-name'
    expected_worktree = $repo.Root
    base_ref = $repo.BaseRef
    allowed_files = @('allowed.txt')
    allowed_globs = @()
    focused_tests = @('exit 0')
    full_test_policy = 'skip'
    full_test_command = 'SKIP'
    analyze_command = 'SKIP'
    commit_message_regex = '^selftest: .{10,72}$'
  }
  'x' | Out-File -FilePath (Join-Path $repo.Root 'allowed.txt') -Encoding utf8
}

Test-ExpectFail 'wrong worktree' {
  param($repo)
  Write-Scope -Root $repo.Root -Overrides @{
    expected_branch = $repo.Branch
    expected_worktree = 'C:\wrong\worktree\path'
    base_ref = $repo.BaseRef
    allowed_files = @('allowed.txt')
    allowed_globs = @()
    focused_tests = @('exit 0')
    full_test_policy = 'skip'
    full_test_command = 'SKIP'
    analyze_command = 'SKIP'
    commit_message_regex = '^selftest: .{10,72}$'
  }
  'x' | Out-File -FilePath (Join-Path $repo.Root 'allowed.txt') -Encoding utf8
}

Test-ExpectFail 'outside allow-list' {
  param($repo)
  & $commonScope $repo
  'x' | Out-File -FilePath (Join-Path $repo.Root 'outside.txt') -Encoding utf8
}

Test-ExpectFail 'forbidden file' {
  param($repo)
  & $commonScope $repo
  'secret' | Out-File -FilePath (Join-Path $repo.Root '.env') -Encoding utf8
}

Test-ExpectFail 'generated output' {
  param($repo)
  Write-Scope -Root $repo.Root -Overrides @{
    expected_branch = $repo.Branch
    expected_worktree = $repo.Root
    base_ref = $repo.BaseRef
    allowed_files = @('build/output.txt')
    allowed_globs = @()
    focused_tests = @('exit 0')
    full_test_policy = 'skip'
    full_test_command = 'SKIP'
    analyze_command = 'SKIP'
    commit_message_regex = '^selftest: .{10,72}$'
  }
  $buildDir = Join-Path $repo.Root 'build'
  New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
  'gen' | Out-File -FilePath (Join-Path $buildDir 'output.txt') -Encoding utf8
}

Test-ExpectFail 'forbidden text' {
  param($repo)
  & $commonScope $repo
  'OPENAI_API_KEY=bad' | Out-File -FilePath (Join-Path $repo.Root 'allowed.txt') -Encoding utf8
}

Test-ExpectFail 'failed command exit code' {
  param($repo)
  Write-Scope -Root $repo.Root -Overrides @{
    expected_branch = $repo.Branch
    expected_worktree = $repo.Root
    base_ref = $repo.BaseRef
    allowed_files = @('allowed.txt')
    allowed_globs = @()
    focused_tests = @('exit 0')
    full_test_policy = 'skip'
    full_test_command = 'SKIP'
    analyze_command = 'exit 1'
    commit_message_regex = '^selftest: .{10,72}$'
  }
  'ok' | Out-File -FilePath (Join-Path $repo.Root 'allowed.txt') -Encoding utf8
}

$invalidMsgRepo = $null
try {
  $invalidMsgRepo = New-TestRepo
  Write-Scope -Root $invalidMsgRepo.Root -Overrides @{
    expected_branch = $invalidMsgRepo.Branch
    expected_worktree = $invalidMsgRepo.Root
    base_ref = $invalidMsgRepo.BaseRef
    allowed_files = @('allowed.txt')
    allowed_globs = @()
    focused_tests = @('exit 0')
    full_test_policy = 'skip'
    full_test_command = 'SKIP'
    analyze_command = 'SKIP'
    commit_message_regex = '^selftest: .{10,72}$'
  }
  'ok' | Out-File -FilePath (Join-Path $invalidMsgRepo.Root 'allowed.txt') -Encoding utf8
  $pre = Invoke-Gate -Root $invalidMsgRepo.Root -Phase PreCommit
  if ($pre -ne 0) {
    Write-Case 'invalid commit message' $false
  } else {
    Push-Location $invalidMsgRepo.Root
    git add -A | Out-Null
    git commit -m "bad message without prefix" -q | Out-Null
    Pop-Location
    $post = Invoke-Gate -Root $invalidMsgRepo.Root -Phase PostCommit
    Write-Case 'invalid commit message' ($post -ne 0)
  }
} catch {
  Write-Case 'invalid commit message' $false
} finally {
  if ($invalidMsgRepo) { Remove-TestRepo $invalidMsgRepo.Root }
}

Test-ExpectPass 'happy path' {
  param($repo)
  & $commonScope $repo
  'ok content' | Out-File -FilePath (Join-Path $repo.Root 'allowed.txt') -Encoding utf8
}

Write-Host ""
Write-Host "Self-test summary: $Passed passed, $Failed failed" -ForegroundColor Cyan
if ($Failed -gt 0) { exit 1 }
exit 0
