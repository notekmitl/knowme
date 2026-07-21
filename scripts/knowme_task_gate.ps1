[CmdletBinding()]
param(
  [string]$ScopeFile = "task_scope.json",
  [ValidateSet("PreCommit", "PostCommit")]
  [string]$Phase = "PreCommit"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Fail([string]$Message, [int]$Code = 1) {
  Write-Host "[FAIL] $Message" -ForegroundColor Red
  exit $Code
}

function Pass([string]$Message) {
  Write-Host "[PASS] $Message" -ForegroundColor Green
}

function Invoke-Configured([string]$Command, [string]$Label) {
  if ([string]::IsNullOrWhiteSpace($Command) -or $Command -eq 'SKIP') {
    Pass "$Label skipped"
    return
  }
  & powershell.exe -NoProfile -NonInteractive -Command $Command
  if ($LASTEXITCODE -ne 0) { Fail "$Label failed with exit code $LASTEXITCODE" 22 }
  Pass $Label
}

function Normalize-Path([string]$Path) {
  return ($Path.Trim() -replace '\\', '/').TrimStart([char[]]'./')
}

function Test-Glob([string]$Path, [string]$Pattern) {
  $p = Normalize-Path $Pattern
  $escaped = [regex]::Escape($p).Replace('\*\*', '§§DOUBLE§§').Replace('\*', '[^/]*').Replace('§§DOUBLE§§', '.*').Replace('\?', '[^/]')
  return $Path -match "^$escaped$"
}

$repo = (& git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repo)) { Fail "Not inside a git worktree" 2 }
$repo = [IO.Path]::GetFullPath($repo.Trim()).TrimEnd('\', '/')
Set-Location $repo

$scopePath = [IO.Path]::GetFullPath((Join-Path $repo $ScopeFile))
if (-not $scopePath.StartsWith($repo, [StringComparison]::OrdinalIgnoreCase)) { Fail "Scope file escapes repo" 3 }
if (-not (Test-Path -LiteralPath $scopePath -PathType Leaf)) { Fail "Missing scope file: $ScopeFile" 3 }
try { $scope = Get-Content -LiteralPath $scopePath -Raw | ConvertFrom-Json }
catch { Fail "Invalid JSON in scope file: $($_.Exception.Message)" 3 }

$required = @('schema_version','task_id','expected_branch','expected_worktree','base_ref','allowed_files','allowed_globs','forbidden_files','generated_output_globs','forbidden_text_patterns','focused_tests','full_test_policy','full_test_command','analyze_command','commit_message_regex','require_clean_tree_after_commit')
foreach ($key in $required) { if (-not $scope.PSObject.Properties.Name.Contains($key)) { Fail "Missing scope key: $key" 3 } }
if ($scope.schema_version -ne 1) { Fail "Unsupported schema_version" 3 }
if ($scope.base_ref -notmatch '^[0-9a-fA-F]{40}$') { Fail "base_ref must be a full 40-character commit SHA" 3 }

$actualWorktree = [IO.Path]::GetFullPath($repo).TrimEnd('\', '/')
$expectedWorktree = [IO.Path]::GetFullPath([string]$scope.expected_worktree).TrimEnd('\', '/')
if (-not $actualWorktree.Equals($expectedWorktree, [StringComparison]::OrdinalIgnoreCase)) { Fail "Wrong worktree. Expected '$expectedWorktree', got '$actualWorktree'" 4 }

$branch = (& git branch --show-current).Trim()
if ($LASTEXITCODE -ne 0 -or $branch -ne [string]$scope.expected_branch) { Fail "Wrong branch. Expected '$($scope.expected_branch)', got '$branch'" 5 }

& git cat-file -e "$($scope.base_ref)^{commit}" 2>$null
if ($LASTEXITCODE -ne 0) { Fail "base_ref does not exist" 6 }
& git merge-base --is-ancestor $scope.base_ref HEAD
if ($LASTEXITCODE -ne 0) { Fail "base_ref is not an ancestor of HEAD" 6 }

$paths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
$sources = @(
  @('diff','--name-only','--diff-filter=ACMRDTUXB',"$($scope.base_ref)..HEAD"),
  @('diff','--name-only','--diff-filter=ACMRDTUXB'),
  @('diff','--cached','--name-only','--diff-filter=ACMRDTUXB'),
  @('ls-files','--others','--exclude-standard')
)
foreach ($args in $sources) {
  $output = & git @args
  if ($LASTEXITCODE -ne 0) { Fail "Unable to enumerate changed files: git $($args -join ' ')" 7 }
  foreach ($line in $output) { if (-not [string]::IsNullOrWhiteSpace($line)) { [void]$paths.Add((Normalize-Path $line)) } }
}

$allowedExact = @($scope.allowed_files | ForEach-Object { Normalize-Path ([string]$_) })
$allowedGlobs = @($scope.allowed_globs | ForEach-Object { [string]$_ })
foreach ($path in $paths) {
  $allowed = $allowedExact -contains $path
  if (-not $allowed) { foreach ($glob in $allowedGlobs) { if (Test-Glob $path $glob) { $allowed = $true; break } } }
  if (-not $allowed) { Fail "Changed file outside allow-list: $path" 8 }
  foreach ($glob in @($scope.forbidden_files)) { if (Test-Glob $path ([string]$glob)) { Fail "Forbidden file changed: $path" 9 } }
  foreach ($glob in @($scope.generated_output_globs)) { if (Test-Glob $path ([string]$glob)) { Fail "Generated output changed: $path" 10 } }
}
Pass "Branch, worktree, base and changed-file scope"

if ($Phase -eq 'PreCommit') {
  $textScanExclude = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
  [void]$textScanExclude.Add('task_scope.json')
  [void]$textScanExclude.Add('scripts/knowme_task_gate_selftest.ps1')
  $pathList = @($paths | Where-Object { -not $textScanExclude.Contains($_) })
  if ($pathList.Count -gt 0) {
    $rawDiff = (& git diff --no-ext-diff --text $scope.base_ref -- @pathList) -join "`n"
    if ($LASTEXITCODE -ne 0) { Fail "Unable to scan changed text" 11 }
    $addedLines = ($rawDiff -split "`n" | Where-Object { $_ -like '+' + '*' -and $_ -notlike '+++' + '*' }) -join "`n"
    $diff = $addedLines
  } else {
    $diff = ''
  }
  $untracked = & git ls-files --others --exclude-standard
  if ($LASTEXITCODE -ne 0) { Fail "Unable to enumerate untracked text" 11 }
  foreach ($file in $untracked) {
    $norm = Normalize-Path $file
    if ($textScanExclude.Contains($norm)) { continue }
    $full = Join-Path $repo $file
    if ((Test-Path -LiteralPath $full -PathType Leaf) -and ((Get-Item -LiteralPath $full).Length -le 5MB)) {
      try { $diff += "`n" + (Get-Content -LiteralPath $full -Raw -ErrorAction Stop) } catch { }
    }
  }
  foreach ($pattern in @($scope.forbidden_text_patterns)) {
    try { if ($diff -match [string]$pattern) { Fail "Forbidden text pattern found: $pattern" 12 } }
    catch { Fail "Invalid forbidden_text_pattern: $pattern" 3 }
  }
  Pass "Forbidden text scan"
  Invoke-Configured ([string]$scope.analyze_command) 'Analyze'
  foreach ($test in @($scope.focused_tests)) { Invoke-Configured ([string]$test) "Focused test: $test" }
  $policy = [string]$scope.full_test_policy
  if ($policy -notin @('required','skip','auto')) { Fail "Invalid full_test_policy: $policy" 3 }
  $runFull = $policy -eq 'required'
  if ($policy -eq 'auto') { $runFull = @($paths | Where-Object { $_ -match '\.(dart|yaml|yml)$' }).Count -gt 0 }
  if ($runFull) { Invoke-Configured ([string]$scope.full_test_command) 'Full tests' } else { Pass "Full tests skipped by policy '$policy'" }
  Pass "PreCommit Gate complete"
  exit 0
}

$message = (& git log -1 --pretty=%B) -join "`n"
if ($LASTEXITCODE -ne 0) { Fail "Unable to read commit message" 13 }
$subject = ($message -split "`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1).Trim()
try { if ($subject -notmatch [string]$scope.commit_message_regex) { Fail "Commit message does not match required regex" 14 } }
catch { Fail "Invalid commit_message_regex" 3 }

if ([bool]$scope.require_clean_tree_after_commit) {
  $dirty = & git status --porcelain --untracked-files=all
  if ($LASTEXITCODE -ne 0) { Fail "Unable to inspect worktree status" 15 }
  $nonResult = @($dirty | Where-Object { (Normalize-Path $_.Substring(3)) -ne 'TASK_RESULT.md' })
  if ($nonResult.Count -gt 0) { Fail "Worktree is not clean after commit (excluding TASK_RESULT.md)" 16 }
}
Pass "Commit message and post-commit cleanliness"
Pass "PostCommit Gate complete"
exit 0
