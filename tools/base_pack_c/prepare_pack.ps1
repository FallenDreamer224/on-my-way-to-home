param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location -LiteralPath $projectRoot
Add-Type -AssemblyName System.Drawing
$brief = Get-Content art/briefs/base_pack_c.json -Raw | ConvertFrom-Json
$jobs = (Get-Content assets/pixellab/source/base_pack_c/generation_jobs.json -Raw | ConvertFrom-Json).jobs
New-Item -ItemType Directory -Force assets/buildings/base_pack_c,art/imports,art/exports | Out-Null
$records = @()
foreach ($asset in $brief.assets) {
    $job = @($jobs | Where-Object asset_id -eq $asset.asset_id)[-1]
    $suffix = if ($job.attempt) { '_v' + $job.attempt } else { '' }
    $source = 'assets/pixellab/source/base_pack_c/' + ($asset.file_name -replace '\.png$', ($suffix + '.png'))
    $runtime = 'assets/buildings/base_pack_c/' + $asset.file_name
    $image = [System.Drawing.Bitmap]::new((Join-Path $projectRoot $source))
    $width = $image.Width; $height = $image.Height
    if ($width -ne $asset.native_canvas_size_px[0] -or $height -ne $asset.native_canvas_size_px[1]) { throw "Native size mismatch: $source" }
    $transparent = 0; $partial = 0; $opaque = 0
    $left = $width; $top = $height; $right = -1; $bottom = -1
    $colors = [System.Collections.Generic.HashSet[int]]::new()
    for ($y = 0; $y -lt $height; $y++) {
        for ($x = 0; $x -lt $width; $x++) {
            $pixel = $image.GetPixel($x, $y)
            if ($pixel.A -eq 0) { $transparent++; continue }
            if ($pixel.A -lt 255) { $partial++ } else { $opaque++ }
            $null = $colors.Add($pixel.ToArgb())
            $left = [Math]::Min($left, $x); $top = [Math]::Min($top, $y)
            $right = [Math]::Max($right, $x); $bottom = [Math]::Max($bottom, $y)
        }
    }
    if ($transparent -eq 0 -or $opaque -eq 0 -or $partial -ne 0) { $image.Dispose(); throw "Non-crisp or empty alpha: $source" }
    if ($left -eq 0 -or $top -eq 0 -or $right -eq $width - 1 -or $bottom -eq $height - 1) { $image.Dispose(); throw "Review canvas-edge clipping: $source" }
    $baseLeft = $width; $baseRight = -1
    for ($x = 0; $x -lt $width; $x++) {
        if ($image.GetPixel($x, $bottom).A -ne 0) { $baseLeft = [Math]::Min($baseLeft, $x); $baseRight = [Math]::Max($baseRight, $x) }
    }
    $anchor = @([int][Math]::Floor(($baseLeft + $baseRight + 1) / 2.0), ($bottom + 1))
    $image.Dispose()
    Copy-Item -LiteralPath $source -Destination $runtime -Force
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne (Get-FileHash -LiteralPath $runtime -Algorithm SHA256).Hash.ToLowerInvariant()) { throw "Copy mismatch: $runtime" }
    $records += [ordered]@{
        asset_id = $asset.asset_id; standards_version = '1.0.0'; category = 'base_structure_or_equipment'
        source_provider = 'PixelLab.ai MCP'; source_files = @($source); runtime_files = @($runtime)
        usage_terms = 'https://pixellab.ai/termsofservice'; native_canvas_size_px = @($width, $height)
        physical_scale_intent = $asset.physical_scale_intent
        review_status = 'reviewed_asset_only_grid_fit_requires_scene_review'; exception = $null
        generation_id = $job.response.job_id; provider_image_id = $job.response.source_image_id
        prompt = $job.request.description; request_record = 'assets/pixellab/source/base_pack_c/generation_jobs.json'
        sha256 = $hash; opaque_bounds_px = @($left, $top, ($right - $left + 1), ($bottom - $top + 1))
        transparent_pixels = $transparent; partially_transparent_pixels = $partial; visible_color_count = $colors.Count
        ground_anchor_px_from_image_top_left = $anchor
        anchor_policy = 'Frontmost visible base row + 1; integer center of contact pixels on that row. Full native canvas retained. Visually review asymmetric contacts before construction integration.'
        sprite2d_centered = $false; sprite2d_offset_px = @(-$anchor[0], -$anchor[1]); sprite2d_scale = @(1, 1)
        explicit_footprint_grid_cells = $asset.explicit_footprint_grid_cells; occupied_cells = $asset.occupied_cells
        footprint_reference_cell = @(0, 0)
        footprint_outline_relative_to_reference_cell_px = $asset.footprint_outline_relative_to_reference_cell_px
        sorting_origin_relative_to_reference_cell_px = $asset.footprint_front_vertex_relative_to_reference_cell_px
        footprint_policy = 'Design placement budget, independent of canvas/overhang; not a collision mask or claim of exact sprite-to-grid perimeter fit. Verify final grid fit before construction integration.'
        placement_policy = 'Project cell (0,0) center is the footprint reference. Proposed sort root is the front footprint vertex, given separately. Sprite offset is negative image anchor. Guide preview uses this convention without altering source pixels.'
        orientation = 'Single orthographic 2:1 isometric-compatible view; upper-left lighting.'
        animation = $false; occlusion_split = 'Single sprite; tall and multi-cell occlusion must be reviewed before gameplay placement.'
    }
}
if ($records.Count -ne 10) { throw 'Expected ten assets.' }
$manifest = [ordered]@{ pack_id = 'base_pack_c'; standards_version = '1.0.0'; assets = $records; gameplay_integration = $false; style_reference = $brief.style_reference }
$manifest | ConvertTo-Json -Depth 40 | Set-Content art/imports/base_pack_c.json -Encoding utf8NoBOM
$brief.status = 'generated'
$brief | ConvertTo-Json -Depth 40 | Set-Content art/briefs/base_pack_c.json -Encoding utf8NoBOM
# Standalone review only: native 1x canvases, with optional footprint guides behind each asset.
foreach ($showGrid in @($false, $true)) {
    $sheet = [System.Drawing.Bitmap]::new(1200, 640)
    $graphics = [System.Drawing.Graphics]::FromImage($sheet)
    $graphics.Clear([System.Drawing.Color]::FromArgb(26, 32, 43))
    $font = [System.Drawing.Font]::new('Consolas', 10)
    $graphics.DrawString('MOON BASE ESSENTIALS / PACK C - native 1x / declared footprint budgets', $font, [System.Drawing.Brushes]::White, 12, 10)
    for ($index = 0; $index -lt $records.Count; $index++) {
        $record = $records[$index]
        $x = 12 + ($index % 5) * 238; $y = 45 + [Math]::Floor($index / 5) * 295
        $image = [System.Drawing.Bitmap]::new((Join-Path $projectRoot $record.runtime_files[0]))
        $anchor = $record.ground_anchor_px_from_image_top_left
        $groundX = $x + 110; $groundY = $y + 205
        $graphics.DrawString(($record.asset_id -replace '^base_pack_c_', ''), $font, [System.Drawing.Brushes]::White, $x, $y)
        if ($showGrid) {
            $front = $record.sorting_origin_relative_to_reference_cell_px
            $points = @($record.footprint_outline_relative_to_reference_cell_px | ForEach-Object { [System.Drawing.Point]::new(($groundX + $_[0] - $front[0]), ($groundY + $_[1] - $front[1])) })
            $graphics.DrawPolygon([System.Drawing.Pens]::SlateGray, [System.Drawing.Point[]]$points)
        }
        $graphics.DrawImageUnscaled($image, ($groundX - $anchor[0]), ($groundY - $anchor[1]))
        $graphics.DrawString((($record.explicit_footprint_grid_cells -join 'x') + ' tiles / ' + ($record.native_canvas_size_px -join 'x') + ' px'), $font, [System.Drawing.Brushes]::LightSteelBlue, $x, ($y + 230))
        $graphics.DrawString(('anchor: ' + ($anchor -join ', ')), $font, [System.Drawing.Brushes]::LightSteelBlue, $x, ($y + 250))
        $image.Dispose()
    }
    $name = if ($showGrid) { 'base_pack_c_footprints.png' } else { 'base_pack_c_preview.png' }
    $sheet.Save((Join-Path $projectRoot ('art/exports/' + $name)))
    $graphics.Dispose(); $sheet.Dispose(); $font.Dispose()
}
if (Test-Path assets/buildings/base_pack_c/README.md) {
    $files = @((Get-ChildItem assets/buildings/base_pack_c/*.png).FullName) + @((Resolve-Path assets/buildings/base_pack_c/README.md).Path, (Resolve-Path art/imports/base_pack_c.json).Path)
    Compress-Archive -LiteralPath $files -DestinationPath art/exports/base_pack_c.zip -Force
}
Write-Output 'PASS: ten native PNGs, binary alpha, unclipped bounds, exact hashes, measured anchors and explicit footprint budgets.'
