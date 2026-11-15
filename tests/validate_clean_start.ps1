param([string]$GodotPath = $env:GODOT_BIN)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $GodotPath) {
    $GodotPath = (Get-Content -LiteralPath (Join-Path $projectRoot '.vscode/settings.json') -Raw | ConvertFrom-Json).'godotTools.editorPath.godot4'
}
if (-not (Test-Path -LiteralPath $GodotPath)) { throw 'Supply the Godot 4.7.2 executable.' }
$outputRoot = Join-Path $PSScriptRoot 'output'
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
Set-Content -LiteralPath (Join-Path $outputRoot '.gdignore') -Value ''
$fixture = Join-Path $outputRoot ('clean_start_' + [DateTime]::UtcNow.ToString('yyyyMMdd_HHmmss_fff'))
New-Item -ItemType Directory -Path $fixture | Out-Null
# Copy only project inputs. Never delete or rename the live .godot directory.
foreach ($entry in @('project.godot', 'icon.svg', 'scripts', 'scenes', 'resources', 'assets', 'art')) {
    Copy-Item -LiteralPath (Join-Path $projectRoot $entry) -Destination $fixture -Recurse
}
New-Item -ItemType Directory -Path (Join-Path $fixture 'tests') | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'class_resolution_test.gd') -Destination (Join-Path $fixture 'tests')
if (Test-Path -LiteralPath (Join-Path $fixture '.godot')) { throw 'Fixture must start without generated cache.' }
$profile = Join-Path $fixture 'validation_profile'
New-Item -ItemType Directory -Path $profile, (Join-Path $profile 'roaming'), (Join-Path $profile 'local') | Out-Null
Set-Content -LiteralPath (Join-Path $profile '.gdignore') -Value ''
$summary = [System.Collections.Generic.List[object]]::new()
function Invoke-CleanStep {
    param([string]$Name, [string[]]$EngineArguments)
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $GodotPath
    $start.WorkingDirectory = $fixture
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.Environment['APPDATA'] = Join-Path $profile 'roaming'
    $start.Environment['LOCALAPPDATA'] = Join-Path $profile 'local'
    foreach ($argument in (@('--path', $fixture, '--audio-driver', 'Dummy') + $EngineArguments)) { $start.ArgumentList.Add($argument) }
    $engine = [Diagnostics.Process]::Start($start)
    $stdout = $engine.StandardOutput.ReadToEndAsync()
    $stderr = $engine.StandardError.ReadToEndAsync()
    if (-not $engine.WaitForExit(60000)) { $engine.Kill($true); throw "Timed out: $Name" }
    $log = $stdout.GetAwaiter().GetResult() + $stderr.GetAwaiter().GetResult()
    $exitCode = $engine.ExitCode
    $engine.Dispose()
    Set-Content -LiteralPath (Join-Path $fixture "$Name.log") -Value $log
    $failed = $exitCode -ne 0 -or $log -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|Parse Error:|FAIL:)'
    $warnings = @($log -split '\r?\n' | Where-Object { $_ -match '(?i)WARNING:' }).Count
    $summary.Add([pscustomobject]@{step=$Name; exit_code=$exitCode; errors_detected=$failed; warnings=$warnings})
    $summary | ConvertTo-Json -AsArray | Set-Content -LiteralPath (Join-Path $fixture 'results.json')
    Write-Host "$Name : exit $exitCode, errors $failed, warnings $warnings"
    if ($failed) { throw "Clean startup failed. See $fixture/$Name.log" }
}
Invoke-CleanStep 'import' @('--headless', '--editor', '--import')
Invoke-CleanStep 'editor_quit' @('--headless', '--editor', '--quit')
Invoke-CleanStep 'class_resolution' @('--headless', '--script', 'res://tests/class_resolution_test.gd')
Invoke-CleanStep 'main' @('--headless', '--quit-after', '120')
Write-Host "PASS: uncached import, editor, typed startup and Main. Evidence: $fixture"

