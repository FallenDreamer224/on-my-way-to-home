param(
    [string]$SourceRoot = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) '..\assets'),
    [string]$PixeloramaPack = (Join-Path $env:APPDATA 'Orama Interactive\Pixelorama\Pixelorama.pck'),
    [string]$GodotPath,
    [ValidateSet('walk','run')][string]$AnimationType = 'walk'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$SourceRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
if (-not $GodotPath) { $GodotPath = (Get-Content (Join-Path $projectRoot '.vscode/settings.json') -Raw | ConvertFrom-Json).'godotTools.editorPath.godot4' }
if (-not (Test-Path -LiteralPath $PixeloramaPack)) { throw 'Supply the installed Pixelorama.pck with -PixeloramaPack.' }
$output = Join-Path $projectRoot 'tests/output/pixelorama_export'
New-Item -ItemType Directory -Force -Path $output | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$directions = @{north='n'; north_east='ne'; east='e'; south_east='se'; south='s'; south_west='sw'; west='w'; north_west='nw'}
$records = [Collections.Generic.List[object]]::new()
$walkInventory = [Collections.Generic.List[object]]::new()
$folders = @((Join-Path $SourceRoot 'animations'))
if ($AnimationType -eq 'walk') { $folders += Join-Path $SourceRoot 'characters' }
foreach ($source in (Get-ChildItem -LiteralPath $folders -Filter '*.pxo' -File | Sort-Object FullName)) {
    if ($source.Directory.Name -eq 'animations' -and $source.BaseName -notmatch '^(astronaut|chiwis?)_(walk|run)_(north_east|north_west|south_east|south_west|north|east|south|west)$') { continue }
    $before = (Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $zip = [IO.Compression.ZipFile]::OpenRead($source.FullName)
    try { $reader = [IO.StreamReader]::new($zip.GetEntry('data.json').Open()); $data = $reader.ReadToEnd() | ConvertFrom-Json; $reader.Dispose() } finally { $zip.Dispose() }
    if ($data.size_x -ne 64 -or $data.size_y -ne 64 -or $data.color_mode -ne 5) { throw "Unsupported source dimensions/format: $($source.Name)" }
    $record = [ordered]@{source=($source.Directory.Name+'/'+$source.Name); sha256=$before; canvas=@(64,64); source_frame_count=$data.frames.Count; fps=$data.fps; original_layers=$data.layers; durations=@($data.frames.duration); status='reference_character_sheet_inspected'; reference_only=($source.Directory.Name -eq 'characters')}
    if ($source.BaseName -match '^(astronaut|chiwis?)_(walk|run)_(north_east|north_west|south_east|south_west|north|east|south|west)$') {
        $character = if ($Matches[1] -eq 'astronaut') {'astronaut'} else {'chiwis'}
        $sourceType = $Matches[2]
        $direction = $directions[$Matches[3]]
        $record.character=$character; $record.direction=$direction; $record.animation_type=$sourceType
        if ($sourceType -ne $AnimationType) {
            if ($AnimationType -eq 'run' -and $sourceType -eq 'walk') {
                $record.existing_png="assets/characters/$character/walk/$direction.png"
                $record.status='inspected_only_preserve_existing_walk'
                $walkInventory.Add($record)
            }
            continue
        }
        $working = Join-Path $output $source.Name
        Copy-Item -LiteralPath $source.FullName -Destination $working -Force
        $copyData = $data | ConvertTo-Json -Depth 40 | ConvertFrom-Json
        foreach ($layer in $copyData.layers) { if ($layer.name -match '(?i)skeleton') { $layer.visible = $false } }
        $copyZip = [IO.Compression.ZipFile]::Open($working, [IO.Compression.ZipArchiveMode]::Update)
        try { $copyZip.GetEntry('data.json').Delete(); $entry=$copyZip.CreateEntry('data.json'); $writer=[IO.StreamWriter]::new($entry.Open(),[Text.UTF8Encoding]::new($false)); $writer.Write(($copyData | ConvertTo-Json -Depth 40 -Compress)); $writer.Dispose() } finally { $copyZip.Dispose() }
        $assetDir = Join-Path $projectRoot "assets/characters/$character/$AnimationType"
        New-Item -ItemType Directory -Force -Path $assetDir | Out-Null
        $png = Join-Path $assetDir "$direction.png"
        $log = Join-Path $output "$($source.BaseName).log"
        $profile = Join-Path $output 'profile'
        New-Item -ItemType Directory -Force -Path $profile | Out-Null
        $info = [Diagnostics.ProcessStartInfo]::new()
        $info.FileName=$GodotPath; $info.WorkingDirectory=$output; $info.UseShellExecute=$false; $info.CreateNoWindow=$true
        $info.RedirectStandardOutput=$true; $info.RedirectStandardError=$true
        $info.Environment['APPDATA']=$profile; $info.Environment['LOCALAPPDATA']=$profile
        foreach ($argument in @('--main-pack',$PixeloramaPack,'--headless','--quit','--log-file',$log,'--','--version','--size','--framecount','--export','--spritesheet','--output',$png,'--scale','1','--direction','0','--frames',"1-$($data.frames.Count)",$working)) { $info.ArgumentList.Add($argument) }
        $process=[Diagnostics.Process]::Start($info)
        $stdout=$process.StandardOutput.ReadToEndAsync(); $stderr=$process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(30000)) { $process.Kill($true); throw "Pixelorama timeout: $($source.Name)" }
        $console=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult()
        Set-Content -LiteralPath (Join-Path $output "$($source.BaseName).console.log") -Value $console
        if ($process.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $png)) { throw "Pixelorama export failed: $($source.Name); see $log" }
        $toolErrors=@($console -split '\r?\n' | Where-Object {$_ -match '^ERROR:'})
        $unexpectedErrors=@($toolErrors | Where-Object {$_ -notmatch 'actions\.custom_samplers|Signal .keyframe_(set|unset). is already connected|RID allocations of type .* were leaked at exit|resources still in use at exit'})
        if ($unexpectedErrors.Count -gt 0 -or $console -match '(?m)^SCRIPT ERROR:') { throw "Unexpected Pixelorama diagnostic: $($source.Name); see $log" }
        $record.export_tool_diagnostics=@{errors=$toolErrors.Count; warnings=@($console -split '\r?\n' | Where-Object {$_ -match '^WARNING:'}).Count; messages=$toolErrors; classification='Pixelorama shader/signal and shutdown-resource diagnostics; exact PNG verification still required'}
        $process.Dispose()
        $record.png="assets/characters/$character/$AnimationType/$direction.png"
        $record.status='exported_pending_pixel_verification'; $record.source_frame_indices=@(1..$data.frames.Count)
        $record.excluded_layers=@($data.layers | Where-Object {$_.name -match '(?i)skeleton'} | ForEach-Object name)
        if ($AnimationType -eq 'walk') { $record.idle_source_frame=1 }
        Write-Host "Exported $($source.Name): $($data.frames.Count) frames at $($data.fps) FPS"
    }
    $after=(Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($after -ne $before) { throw "Source changed during export: $($source.Name). Reinspect before integration." }
    $records.Add($record)
}
if (@($records | Where-Object png).Count -ne 16 -or ($AnimationType -eq 'walk' -and $records.Count -ne 18) -or ($AnimationType -eq 'run' -and $walkInventory.Count -ne 16)) { throw 'Expected sixteen distinct directional exports and complete source coverage.' }
$keys=@($records | Where-Object png | ForEach-Object {"$($_.character)/$($_.direction)"} | Select-Object -Unique)
if ($keys.Count -ne 16) {throw 'Duplicate or missing character/direction source.'}
$manifestDir=Join-Path $projectRoot 'art/imports'
New-Item -ItemType Directory -Force -Path $manifestDir | Out-Null
$manifest=[ordered]@{standards_version='1.0.0'; animation_type=$AnimationType; exporter='Installed Pixelorama 1.2.4 resource pack through Godot 4.7.2 CLI'; source_root_hint='Pass -SourceRoot to reproduce'; sources=$records}
$manifestName = if ($AnimationType -eq 'run') {'pixelorama_runs.json'} else {'pixelorama_characters.json'}
if ($AnimationType -eq 'run') {$manifest.walk_source_inventory=$walkInventory}
$manifest | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath (Join-Path $manifestDir $manifestName) -Encoding utf8
Write-Host "Exported sixteen native $AnimationType sheets. Mandatory pixel verification/resource merge follows in build_imports.ps1."
if (@($records | Where-Object {$_.export_tool_diagnostics.errors -gt 0}).Count -gt 0) {
    Write-Warning 'Pixelorama emitted shader/signal or shutdown-resource errors. Logs are in tests/output/pixelorama_export; run build_imports.ps1 for mandatory pixel verification.'
}
