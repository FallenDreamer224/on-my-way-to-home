param([string]$GodotPath)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$privateRoot=Join-Path $projectRoot 'tests/output/release_d2_5_private'
$probe=Join-Path $privateRoot 'public_source_probe'
if(-not $GodotPath){$GodotPath=$env:GODOT_BIN}
if(-not $GodotPath){$GodotPath=(Get-Content (Join-Path $projectRoot '.vscode/settings.json') -Raw|ConvertFrom-Json).'godotTools.editorPath.godot4'}
if(-not(Test-Path -LiteralPath (Join-Path $probe 'project.godot'))){throw 'Prepare the public-source probe from public_manifest.json first.'}
$profile=Join-Path $probe 'tests/output/profile'
New-Item -ItemType Directory -Force -Path (Join-Path $profile 'roaming'),(Join-Path $profile 'local')|Out-Null
Set-Content -LiteralPath (Join-Path $probe 'tests/output/.gdignore') -Value ''
$results=[Collections.Generic.List[object]]::new()
foreach($step in @('import','editor','main','foundation','demo_d0','ui_pack_a','base_pack_c','lander_pack_d','terrain_pack_e')){
 $arguments=@('--headless','--path',$probe,'--audio-driver','Dummy')
 switch($step){
  import {$arguments+=@('--editor','--import')}
  editor {$arguments+=@('--editor','--quit')}
  main {$arguments+=@('--quit-after','120')}
  default {$arguments+=@('--fixed-fps','60','--script',("res://tests/"+$step+"_test.gd"))}
 }
 $start=[Diagnostics.ProcessStartInfo]::new()
 $start.FileName=$GodotPath
 $start.WorkingDirectory=$probe
 $start.UseShellExecute=$false
 $start.CreateNoWindow=$true
 $start.RedirectStandardOutput=$true
 $start.RedirectStandardError=$true
 $start.Environment['APPDATA']=Join-Path $profile 'roaming'
 $start.Environment['LOCALAPPDATA']=Join-Path $profile 'local'
 foreach($arg in $arguments){$start.ArgumentList.Add($arg)}
 $engine=[Diagnostics.Process]::Start($start)
 $stdout=$engine.StandardOutput.ReadToEndAsync();$stderr=$engine.StandardError.ReadToEndAsync()
 if(-not $engine.WaitForExit(60000)){$engine.Kill($true);throw "Timed out: $step"}
 $log=$stdout.GetAwaiter().GetResult()+$stderr.GetAwaiter().GetResult()
 $exitCode=$engine.ExitCode
 $engine.Dispose()
 Set-Content -LiteralPath (Join-Path $privateRoot ("public_"+$step+".log")) -Value $log
 $errors=$exitCode -ne 0 -or $log -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|Parse Error:|FAIL:)'
 $results.Add([pscustomobject]@{step=$step;exit_code=$exitCode;errors_detected=$errors})
 $results|ConvertTo-Json -AsArray|Set-Content -LiteralPath (Join-Path $privateRoot 'public_source_validation.json')
 Write-Host "$step : exit $exitCode, errors $errors"
 if($errors){throw "Public source probe failed: $step"}
}
Write-Host 'PASS: proposed source candidate imports and runs without local configuration or generated handoffs.'

