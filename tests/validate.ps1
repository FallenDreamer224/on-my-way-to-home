param(
    [string]$GodotPath = $env:GODOT_BIN,
    [switch]$IncludeRendering
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$outputPath = Join-Path $PSScriptRoot 'output'
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null
Set-Content -LiteralPath (Join-Path $outputPath '.gdignore') -Value ''

if (-not $GodotPath) {
    $workspaceSettings = Join-Path $projectRoot '.vscode\settings.json'
    if (Test-Path -LiteralPath $workspaceSettings) {
        $settings = Get-Content -Raw -LiteralPath $workspaceSettings | ConvertFrom-Json
        $GodotPath = $settings.'godotTools.editorPath.godot4'
    }
}
if (-not $GodotPath) {
    $command = Get-Command godot -ErrorAction SilentlyContinue
    if ($command) { $GodotPath = $command.Source }
}
if (-not $GodotPath -or -not (Test-Path -LiteralPath $GodotPath)) {
    throw 'Godot executable not found. Supply -GodotPath or set GODOT_BIN.'
}
$engineVersion = (& $GodotPath --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $engineVersion -notmatch '^4\.7\.2\.') {
    throw "Expected Godot 4.7.2; found: $engineVersion"
}
Write-Host "Engine: $engineVersion"
$script:warningLines = [System.Collections.Generic.List[string]]::new()
foreach ($jsonFile in @('art/asset_standards.json', 'assets/pixellab/import_manifest.example.json', 'art/placeholders/astronaut_placeholder.json', 'art/imports/pixelorama_characters.json', 'art/imports/pixelorama_runs.json', 'art/imports/moon_terrain.json', 'art/imports/props_pack_b.json', 'art/imports/phase_0_8A.json', 'resources/config/habitat_utilities.json')) {
    Get-Content -Raw -LiteralPath (Join-Path $projectRoot $jsonFile) | ConvertFrom-Json | Out-Null
}
Write-Host 'JSON syntax: valid (standards, intake template, placeholders, imports and utility configuration).'
Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'resources/config/daily_life.json') | ConvertFrom-Json | Out-Null
$profilePath = Join-Path $outputPath 'profile'
New-Item -ItemType Directory -Force -Path (Join-Path $profilePath 'roaming'), (Join-Path $profilePath 'local') | Out-Null

function Invoke-ValidationStep {
    param([string]$Name, [string[]]$EngineArguments)
    $logPath = Join-Path $outputPath "$Name.log"
    Write-Host "Running: $Name"
    # Isolate editor/user data inside the project; do not change the calling shell's profile.
    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $GodotPath
    $startInfo.WorkingDirectory = $projectRoot
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.Environment['APPDATA'] = Join-Path $profilePath 'roaming'
    $startInfo.Environment['LOCALAPPDATA'] = Join-Path $profilePath 'local'
    foreach ($argument in (@('--path', $projectRoot, '--audio-driver', 'Dummy', '--log-file', $logPath) + $EngineArguments)) {
        $startInfo.ArgumentList.Add($argument)
    }
    $engineProcess = [System.Diagnostics.Process]::Start($startInfo)
    $stdoutTask = $engineProcess.StandardOutput.ReadToEndAsync()
    $stderrTask = $engineProcess.StandardError.ReadToEndAsync()
    if (-not $engineProcess.WaitForExit(60000)) {
        $engineProcess.Kill($true)
        throw "Validation timed out: $Name"
    }
    $stdoutText = $stdoutTask.GetAwaiter().GetResult()
    $stderrText = $stderrTask.GetAwaiter().GetResult()
    $exitCode = $engineProcess.ExitCode
    $engineProcess.Dispose()
    Write-Host "Exit code: $exitCode"
    Write-Host $stdoutText
    if ($stderrText) { Write-Host $stderrText }
    Set-Content -LiteralPath (Join-Path $outputPath "$Name.console.log") -Value ($stdoutText + $stderrText)
    $logText = if (Test-Path -LiteralPath $logPath) { Get-Content -Raw -LiteralPath $logPath } else { '' }
    $logText += "`n$stdoutText`n$stderrText"
    if ($exitCode -ne 0 -or $logText -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|Parse Error:|FAIL:)') {
        throw "Validation failed: $Name (exit $exitCode). See $logPath"
    }
    foreach ($line in (($logText -split '\r?\n') | Select-Object -Unique)) {
        if ($line -match '(?i)WARNING:') { $script:warningLines.Add("${Name}: $line") }
    }
}

Invoke-ValidationStep 'import' @('--headless', '--editor', '--import')
Invoke-ValidationStep 'editor_headless_quit' @('--headless', '--editor', '--quit')
$scripts = Get-ChildItem -LiteralPath (Join-Path $projectRoot 'scripts'), $PSScriptRoot -Recurse -Filter '*.gd' |
    Where-Object { $_.FullName -notlike "$outputPath\*" }
foreach ($scriptFile in $scripts) {
    Invoke-ValidationStep "parse_$($scriptFile.BaseName)" @('--headless', '--check-only', '--script', $scriptFile.FullName)
}
Invoke-ValidationStep 'class_resolution' @('--headless', '--script', 'res://tests/class_resolution_test.gd')
Invoke-ValidationStep 'demo_d0' @('--headless', '--fixed-fps', '60', '--script', 'res://tests/demo_d0_test.gd')
Invoke-ValidationStep 'foundation' @('--headless', '--script', 'res://tests/foundation_test.gd')
Invoke-ValidationStep 'isometric_world' @('--headless', '--script', 'res://tests/isometric_world_test.gd')
Invoke-ValidationStep 'moon_terrain' @('--headless', '--script', 'res://tests/moon_terrain_test.gd')
Invoke-ValidationStep 'player_camera' @('--headless', '--script', 'res://tests/player_camera_test.gd')
Invoke-ValidationStep 'gameplay_modes' @('--headless', '--script', 'res://tests/gameplay_modes_test.gd')
Invoke-ValidationStep 'astronaut' @('--headless', '--script', 'res://tests/astronaut_test.gd')
Invoke-ValidationStep 'pixelorama_assets' @('--headless', '--script', 'res://tests/pixelorama_assets_test.gd')
Invoke-ValidationStep 'run_animation' @('--headless', '--script', 'res://tests/run_animation_test.gd')
Invoke-ValidationStep 'chiwis' @('--headless', '--script', 'res://tests/chiwis_test.gd')
Invoke-ValidationStep 'inventory' @('--headless', '--script', 'res://tests/inventory_test.gd')
Invoke-ValidationStep 'interaction_inventory' @('--headless', '--script', 'res://tests/interaction_inventory_test.gd')
Invoke-ValidationStep 'props_pack_b' @('--headless', '--script', 'res://tests/props_pack_b_test.gd')
Invoke-ValidationStep 'prop_integration' @('--headless', '--script', 'res://tests/prop_integration_test.gd')
Invoke-ValidationStep 'ui_foundation' @('--headless', '--script', 'res://tests/ui_foundation_test.gd')
Invoke-ValidationStep 'main_headless' @('--headless', '--quit-after', '10')
Invoke-ValidationStep 'lunar_tutorial' @('--headless', '--script', 'res://tests/lunar_tutorial_test.gd')
Invoke-ValidationStep 'eva_safety' @('--headless', '--script', 'res://tests/eva_safety_test.gd')
Invoke-ValidationStep 'habitat' @('--headless', '--script', 'res://tests/habitat_test.gd')
Invoke-ValidationStep 'utilities' @('--headless', '--script', 'res://tests/utilities_test.gd')
Invoke-ValidationStep 'daily_life' @('--headless', '--script', 'res://tests/daily_life_test.gd')
Invoke-ValidationStep 'utility_integration' @('--headless', '--script', 'res://tests/utility_integration_test.gd')

$productionFiles = @((Get-Item -LiteralPath (Join-Path $projectRoot 'project.godot'))) +
    @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'scenes'), (Join-Path $projectRoot 'scripts'), (Join-Path $projectRoot 'resources') -File -Recurse |
        Where-Object { $_.Extension -in '.gd', '.tscn', '.tres' })
$legacyMatches = $productionFiles | Select-String -Pattern 'Node3D|Camera3D|MeshInstance3D|CharacterBody3D|StaticBody3D|Vector3|\b3d/|Forward Plus|d3d12|Jolt Physics'
if ($legacyMatches) { throw "Obsolete architecture references found: $legacyMatches" }

if ($IncludeRendering) {
    Invoke-ValidationStep 'demo_d0_rendered' @('--fixed-fps', '60', '--script', 'res://tests/demo_d0_test.gd', '--', '--capture')
    Invoke-ValidationStep 'daily_life_rendered' @('--script', 'res://tests/daily_life_test.gd', '--', '--capture')
    Invoke-ValidationStep 'utility_integration_rendered' @('--script', 'res://tests/utility_integration_test.gd', '--', '--capture')
    Invoke-ValidationStep 'utility_integration_fullscreen' @('--fullscreen', '--script', 'res://tests/utility_integration_test.gd')
    Invoke-ValidationStep 'habitat_rendered' @('--script', 'res://tests/habitat_test.gd', '--', '--capture')
    Invoke-ValidationStep 'eva_safety_rendered' @('--script', 'res://tests/eva_safety_test.gd', '--', '--capture')
    Invoke-ValidationStep 'lunar_tutorial_rendered' @('--script', 'res://tests/lunar_tutorial_test.gd', '--', '--capture')
    Invoke-ValidationStep 'editor_graphical' @('--editor', '--quit-after', '120')
    Invoke-ValidationStep 'main_rendered' @('--script', 'res://tests/foundation_test.gd', '--', '--capture')
    if (-not (Test-Path -LiteralPath (Join-Path $outputPath 'foundation.png'))) { throw 'Rendered main scene capture is missing.' }
    Invoke-ValidationStep 'main_fullscreen' @('--fullscreen', '--quit-after', '10')
    Invoke-ValidationStep 'moon_terrain_rendered' @('--script', 'res://tests/moon_terrain_test.gd', '--', '--capture')
    Invoke-ValidationStep 'modes_rendered' @('--script', 'res://tests/gameplay_modes_test.gd', '--', '--capture')
    Invoke-ValidationStep 'modes_fullscreen' @('--fullscreen', '--script', 'res://tests/gameplay_modes_test.gd')
    # Fix rendering cadence while the test still exercises 30/60/120 Hz physics.
    Invoke-ValidationStep 'astronaut_rendered' @('--fixed-fps', '60', '--script', 'res://tests/astronaut_test.gd', '--', '--capture')
    Invoke-ValidationStep 'chiwis_rendered' @('--script', 'res://tests/chiwis_test.gd', '--', '--capture')
    Invoke-ValidationStep 'run_animation_rendered' @('--script', 'res://tests/run_animation_test.gd', '--', '--capture')
    Invoke-ValidationStep 'interaction_inventory_rendered' @('--script', 'res://tests/interaction_inventory_test.gd', '--', '--capture')
    Invoke-ValidationStep 'prop_integration_rendered' @('--script', 'res://tests/prop_integration_test.gd', '--', '--capture')
    Invoke-ValidationStep 'ui_foundation_rendered' @('--script', 'res://tests/ui_foundation_test.gd', '--', '--capture')
    Invoke-ValidationStep 'ui_foundation_fullscreen' @('--fullscreen', '--script', 'res://tests/ui_foundation_test.gd', '--', '--capture')
}

Write-Host 'Errors: 0'
Write-Host "Warnings: $($script:warningLines.Count)"
$script:warningLines | ForEach-Object { Write-Host $_ }
Write-Host 'PASS: Project validation complete.'
