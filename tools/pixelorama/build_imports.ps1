param([switch]$SkipExport, [string]$SourceRoot, [string]$PixeloramaPack, [string]$GodotPath, [ValidateSet('walk','run')][string]$AnimationType = 'run')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not $SourceRoot) { $SourceRoot = Join-Path $projectRoot '..\assets' }
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
if (-not $GodotPath) { $GodotPath=(Get-Content (Join-Path $projectRoot '.vscode/settings.json') -Raw | ConvertFrom-Json).'godotTools.editorPath.godot4' }
if (-not $SkipExport) {
    $options=@{GodotPath=$GodotPath;AnimationType=$AnimationType}
    if ($SourceRoot) {$options.SourceRoot=$SourceRoot}
    if ($PixeloramaPack) {$options.PixeloramaPack=$PixeloramaPack}
    & (Join-Path $PSScriptRoot 'export_characters.ps1') @options
}
$output=Join-Path $projectRoot 'tests/output/pixelorama_export'
New-Item -ItemType Directory -Force -Path $output | Out-Null
foreach ($importFile in (Get-ChildItem -LiteralPath (Join-Path $projectRoot 'assets/characters') -Filter '*.png.import' -Recurse)) {
    $text=Get-Content -LiteralPath $importFile.FullName -Raw
    if ($text.Contains('process/fix_alpha_border=true')) { $text.Replace('process/fix_alpha_border=true','process/fix_alpha_border=false') | Set-Content -LiteralPath $importFile.FullName }
}
foreach ($step in @('import','reimport','verify')) {
    if ($step -eq 'reimport') {
        foreach ($importFile in (Get-ChildItem -LiteralPath (Join-Path $projectRoot 'assets/characters') -Filter '*.png.import' -Recurse)) {
            $text=Get-Content -LiteralPath $importFile.FullName -Raw
            if ($text.Contains('process/fix_alpha_border=true')) { $text.Replace('process/fix_alpha_border=true','process/fix_alpha_border=false') | Set-Content -LiteralPath $importFile.FullName }
        }
    }
    $info=[Diagnostics.ProcessStartInfo]::new()
    $info.FileName=$GodotPath; $info.UseShellExecute=$false; $info.CreateNoWindow=$true
    $info.RedirectStandardOutput=$true; $info.RedirectStandardError=$true
    $info.WorkingDirectory=$projectRoot
    $profile=Join-Path $output 'profile'
    New-Item -ItemType Directory -Force -Path $profile | Out-Null
    $info.Environment['APPDATA']=$profile; $info.Environment['LOCALAPPDATA']=$profile
    $log=Join-Path $output "$step.log"
    $arguments=@('--headless','--path',$projectRoot,'--log-file',$log)
    if($step -ne 'verify') {$arguments+=@('--editor','--import')} else {$arguments+=@('--script','res://tools/pixelorama/verify_exports.gd','--','--source-root',$SourceRoot,'--animation-type',$AnimationType)}
    foreach($argument in $arguments) {$info.ArgumentList.Add($argument)}
    $process=[Diagnostics.Process]::Start($info)
    $stdout=$process.StandardOutput.ReadToEndAsync(); $stderr=$process.StandardError.ReadToEndAsync()
    if(-not $process.WaitForExit(60000)) {$process.Kill($true); throw "Import pipeline timed out: $step"}
    $console=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult()
    Write-Host $console
    if($process.ExitCode -ne 0 -or $console -match '(?im)^\s*(SCRIPT ERROR:|ERROR:)') {throw "Import pipeline failed: $step"}
    $process.Dispose()
}
