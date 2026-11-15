param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location -LiteralPath $projectRoot
Add-Type -AssemblyName System.Drawing
$brief = Get-Content art/briefs/props_pack_b.json -Raw | ConvertFrom-Json
$jobs = (Get-Content assets/pixellab/source/props_pack_b/generation_jobs.json -Raw | ConvertFrom-Json).jobs
New-Item -ItemType Directory -Force assets/environment/props_pack_b,art/imports,art/exports | Out-Null
$records = @()
foreach ($asset in $brief.assets) {
    $job = @($jobs | Where-Object asset_id -eq $asset.asset_id)[-1]
    $suffix = if ($job.attempt) { '_v' + $job.attempt } else { '' }
    $source = 'assets/pixellab/source/props_pack_b/' + ($asset.file_name -replace '\.png$', ($suffix + '.png'))
    $runtime = 'assets/environment/props_pack_b/' + $asset.file_name
    $image = [System.Drawing.Bitmap]::new((Join-Path $projectRoot $source))
    if ($image.Width -ne 64 -or $image.Height -ne 64) { throw "Native size mismatch: $source" }
    $transparent = 0; $partial = 0; $opaque = 0
    $left = 64; $top = 64; $right = -1; $bottom = -1
    $colors = [System.Collections.Generic.HashSet[int]]::new()
    for ($y = 0; $y -lt 64; $y++) {
        for ($x = 0; $x -lt 64; $x++) {
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
    if ($left -eq 0 -or $top -eq 0 -or $right -eq 63 -or $bottom -eq 63) { throw "Artwork touches canvas boundary; review clipping: $source" }
    # Ground contact is at the center of the visible base and just below its last row.
    # Preserve image pixels; callers place the complete texture using this anchor.
    $anchor = @([int][Math]::Floor(($left + $right + 1) / 2.0), ($bottom + 1))
    Copy-Item -LiteralPath $source -Destination $runtime -Force
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne (Get-FileHash -LiteralPath $runtime -Algorithm SHA256).Hash.ToLowerInvariant()) { throw "Copy mismatch: $runtime" }
    $records += [ordered]@{
        asset_id = $asset.asset_id; standards_version = '1.0.0'; category = 'world_prop'
        source_provider = 'PixelLab.ai MCP'; source_files = @($source); runtime_files = @($runtime)
        usage_terms = 'https://pixellab.ai/termsofservice'; native_canvas_size_px = @(64, 64)
        physical_scale_intent = $asset.physical_scale_intent
        review_status = 'reviewed_native_asset_not_gameplay_integrated'; exception = $null
        generation_id = $job.response.job_id; provider_image_id = $job.response.source_image_id
        prompt = $job.request.description; request_record = 'assets/pixellab/source/props_pack_b/generation_jobs.json'
        sha256 = $hash; opaque_bounds_px = @($left, $top, ($right - $left + 1), ($bottom - $top + 1))
        transparent_pixels = $transparent; partially_transparent_pixels = $partial; visible_color_count = $colors.Count
        ground_anchor_px_from_image_top_left = $anchor
        ground_anchor_convention = 'Integer center of visible bounds in X; lowest opaque row + 1 in Y. Includes any tiny contact shadow. Visually review base center for asymmetric props.'
        sprite2d_centered = $false; sprite2d_offset_px = @(-$anchor[0], -$anchor[1]); sprite2d_scale = @(1, 1)
        proposed_footprint_grid_cells = $asset.logical_footprint_grid_cells
        footprint_status = $asset.footprint_status
        orientation = 'Single isometric-compatible view, lit from upper left; not a directional set.'
        occlusion_split = 'None; compact single-sprite prop. Root uses ground contact in existing Y-sort hierarchy.'
    }
}
if ($records.Count -ne 10) { throw 'Expected ten props.' }
$manifest = [ordered]@{ pack_id = 'props_pack_b'; standards_version = '1.0.0'; assets = $records; gameplay_integration = $false; style_reference = $brief.style_reference }
$manifest | ConvertTo-Json -Depth 30 | Set-Content art/imports/props_pack_b.json -Encoding utf8NoBOM
$brief.status = 'generated'
$brief | ConvertTo-Json -Depth 30 | Set-Content art/briefs/props_pack_b.json -Encoding utf8NoBOM
# Contact sheet only: integer 2x magnification, complete native canvases, no artwork changes.
$sheet = [System.Drawing.Bitmap]::new(960, 540)
$graphics = [System.Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([System.Drawing.Color]::FromArgb(27, 32, 43))
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font = [System.Drawing.Font]::new('Consolas', 10)
$graphics.DrawString('MOON PROPS / PACK B - native 64x64 canvases shown at 2x', $font, [System.Drawing.Brushes]::White, 12, 10)
for ($index = 0; $index -lt $records.Count; $index++) {
    $record = $records[$index]
    $x = 12 + ($index % 5) * 190; $y = 45 + [Math]::Floor($index / 5) * 225
    $image = [System.Drawing.Bitmap]::new((Join-Path $projectRoot $record.runtime_files[0]))
    $graphics.DrawString(($record.asset_id -replace '^props_pack_b_', ''), $font, [System.Drawing.Brushes]::White, $x, $y)
    $anchor = $record.ground_anchor_px_from_image_top_left
    $groundX = $x + 64; $groundY = $y + 154
    $graphics.DrawLine([System.Drawing.Pens]::DimGray, ($x + 8), $groundY, ($x + 130), $groundY)
    $graphics.DrawImage($image, [System.Drawing.Rectangle]::new(($groundX - $anchor[0] * 2), ($groundY - $anchor[1] * 2), 128, 128), 0, 0, 64, 64, [System.Drawing.GraphicsUnit]::Pixel)
    $graphics.DrawString(('anchor: ' + ($record.ground_anchor_px_from_image_top_left -join ', ')), $font, [System.Drawing.Brushes]::LightSteelBlue, $x, ($y + 165))
    $image.Dispose()
}
$sheet.Save((Join-Path $projectRoot 'art/exports/props_pack_b_preview.png'))
$graphics.Dispose(); $sheet.Dispose(); $font.Dispose()
$archiveFiles = @((Get-ChildItem assets/environment/props_pack_b/*.png).FullName) + @((Resolve-Path assets/environment/props_pack_b/README.md).Path, (Resolve-Path art/imports/props_pack_b.json).Path)
Compress-Archive -LiteralPath $archiveFiles -DestinationPath art/exports/props_pack_b.zip -Force
Write-Output 'PASS: ten 64x64 props; binary alpha; unclipped bounds; measured anchors; exact source/runtime hashes.'
