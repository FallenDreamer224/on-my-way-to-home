param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location -LiteralPath $projectRoot
Add-Type -AssemblyName System.Drawing
$brief = Get-Content art/briefs/ui_pack_a.json -Raw | ConvertFrom-Json
$jobs = (Get-Content assets/pixellab/source/ui_pack_a/generation_jobs.json -Raw | ConvertFrom-Json).jobs
$records = @()
New-Item -ItemType Directory -Force assets/ui/ui_pack_a,art/imports,art/exports | Out-Null
foreach ($asset in $brief.assets) {
    $job = @($jobs | Where-Object asset_id -eq $asset.asset_id)[-1]
    $suffix = if ($job.attempt) { '_v' + $job.attempt } else { '' }
    $source = 'assets/pixellab/source/ui_pack_a/' + ($asset.file_name -replace '\.png$', ($suffix + '.png'))
    $runtime = 'assets/ui/ui_pack_a/' + $asset.file_name
    $image = [System.Drawing.Bitmap]::new((Join-Path $projectRoot $source))
    if ($image.Width -ne $asset.native_canvas_size_px[0] -or $image.Height -ne $asset.native_canvas_size_px[1]) { throw "Native size mismatch: $source" }
    $transparent = 0; $partial = 0; $opaque = 0
    $left = $image.Width; $top = $image.Height; $right = -1; $bottom = -1
    $colors = [System.Collections.Generic.HashSet[int]]::new()
    for ($y = 0; $y -lt $image.Height; $y++) {
        for ($x = 0; $x -lt $image.Width; $x++) {
            $pixel = $image.GetPixel($x, $y)
            if ($pixel.A -eq 0) { $transparent++; continue }
            if ($pixel.A -lt 255) { $partial++ } else { $opaque++ }
            $null = $colors.Add($pixel.ToArgb())
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        }
    }
    $image.Dispose()
    if ($transparent -eq 0 -or $opaque -eq 0 -or $partial -ne 0) { throw "Non-crisp or empty alpha: $source" }
    Copy-Item -LiteralPath $source -Destination $runtime -Force
    $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($sourceHash -ne (Get-FileHash -LiteralPath $runtime -Algorithm SHA256).Hash.ToLowerInvariant()) { throw "Copy mismatch: $runtime" }
    $records += [ordered]@{
        asset_id = $asset.asset_id; standards_version = '1.0.0'; category = $asset.category
        source_provider = 'PixelLab.ai MCP'; source_files = @($source); runtime_files = @($runtime)
        usage_terms = 'https://pixellab.ai/termsofservice'; native_canvas_size_px = $asset.native_canvas_size_px
        physical_scale_intent = $asset.physical_scale_intent; review_status = 'reviewed_native_asset_not_gameplay_integrated'
        exception = $null; generation_id = $job.response.job_id; provider_image_id = $job.response.source_image_id
        prompt = $job.request.description; request_record = 'assets/pixellab/source/ui_pack_a/generation_jobs.json'
        sha256 = $sourceHash; opaque_bounds_px = @($left, $top, ($right - $left + 1), ($bottom - $top + 1))
        transparent_pixels = $transparent; partially_transparent_pixels = $partial; visible_color_count = $colors.Count
        nine_slice = $null; nine_slice_status = 'Not configured; proposed brief margins are not verified against generated border geometry.'
        draw_policy = 'Keep the complete native canvas and padding; nearest filtering. Do not auto-trim, resize or stretch.'
    }
}
if ($records.Count -ne 23) { throw 'Expected 23 assets.' }
$manifest = [ordered]@{ pack_id = 'ui_pack_a'; standards_version = '1.0.0'; provider = 'PixelLab.ai MCP'; assets = $records; gameplay_integration = $false }
$manifest | ConvertTo-Json -Depth 30 | Set-Content art/imports/ui_pack_a.json -Encoding utf8NoBOM
$brief.status = 'generated'; $brief.PSObject.Properties.Remove('blocker')
$brief.resume_action = 'Generation complete. See art/imports/ui_pack_a.json for measured metadata and docs/ui_pack_a_report.md for validation and limitations.'
foreach ($asset in $brief.assets) { $asset.review_status = 'generated_see_import_manifest' }
$brief | ConvertTo-Json -Depth 30 | Set-Content art/briefs/ui_pack_a.json -Encoding utf8NoBOM
# Review-only contact sheet: blit complete native images without changing any asset.
$sheet = [System.Drawing.Bitmap]::new(960, 900)
$graphics = [System.Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([System.Drawing.Color]::FromArgb(24, 30, 38))
$font = [System.Drawing.Font]::new('Consolas', 10)
for ($index = 0; $index -lt $records.Count; $index++) {
    $record = $records[$index]
    $x = 12 + (($index - 1) % 4) * 236; $y = 230 + [Math]::Floor(($index - 1) / 4) * 105
    if ($index -eq 0) { $x = 12; $y = 10 }
    $image = [System.Drawing.Bitmap]::new((Join-Path $projectRoot $record.runtime_files[0]))
    $graphics.DrawString(($record.asset_id -replace '^ui_pack_a_', ''), $font, [System.Drawing.Brushes]::White, $x, $y)
    $graphics.DrawImageUnscaled($image, $x, ($y + 20))
    $image.Dispose()
}
$sheet.Save((Join-Path $projectRoot 'art/exports/ui_pack_a_preview.png'))
$graphics.Dispose(); $sheet.Dispose(); $font.Dispose()
Write-Output ('PASS: ' + $records.Count + ' native PNGs; binary alpha; byte-identical source/runtime hashes; provenance recorded.')
