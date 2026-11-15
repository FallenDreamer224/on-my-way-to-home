param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location -LiteralPath $projectRoot
Add-Type -AssemblyName System.Drawing
$brief = Get-Content art/briefs/lander_pack_d.json -Raw | ConvertFrom-Json
$jobs = (Get-Content assets/pixellab/source/lander_pack_d/generation_jobs.json -Raw | ConvertFrom-Json).jobs
New-Item -ItemType Directory -Force assets/vehicles/lander_pack_d,art/imports,art/exports | Out-Null
$records = @()
foreach ($asset in $brief.assets) {
    $job = @($jobs | Where-Object asset_id -eq $asset.asset_id)[-1]
    $source = 'assets/pixellab/source/lander_pack_d/' + $asset.file_name
    $runtime = 'assets/vehicles/lander_pack_d/' + $asset.file_name
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
    $anchor = if ($asset.ground_anchor_override_px) { @($asset.ground_anchor_override_px) } else { @([int][Math]::Floor(($baseLeft + $baseRight + 1) / 2.0), ($bottom + 1)) }
    $image.Dispose()
    Copy-Item -LiteralPath $source -Destination $runtime -Force
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne (Get-FileHash -LiteralPath $runtime -Algorithm SHA256).Hash.ToLowerInvariant()) { throw "Copy mismatch: $runtime" }
    $cols = $asset.explicit_footprint_grid_cells[0]; $rows = $asset.explicit_footprint_grid_cells[1]
    $record = [ordered]@{
        asset_id = $asset.asset_id; standards_version = '1.0.0'; category = 'lander_or_support_asset'
        source_provider = 'PixelLab.ai MCP'; source_files = @($source); runtime_files = @($runtime)
        usage_terms = 'https://pixellab.ai/termsofservice'; native_canvas_size_px = @($width, $height)
        physical_scale_intent = $asset.physical_scale_intent
        review_status = 'reviewed_asset_only_not_gameplay_integrated'; exception = $null
        generation_id = $job.response.job_id; provider_image_id = $job.response.source_image_id; production_tool = $job.tool
        prompt = $job.request.description; request_record = 'assets/pixellab/source/lander_pack_d/generation_jobs.json'
        sha256 = $hash; opaque_bounds_px = @($left, $top, ($right - $left + 1), ($bottom - $top + 1))
        transparent_pixels = $transparent; partially_transparent_pixels = $partial; visible_color_count = $colors.Count
        ground_anchor_px_from_image_top_left = $anchor
        anchor_policy = $brief.anchor_policy
        sprite2d_centered = $false; sprite2d_offset_px = @(-$anchor[0], -$anchor[1]); sprite2d_scale = @(1, 1)
        explicit_footprint_grid_cells = $asset.explicit_footprint_grid_cells; occupied_cells = $asset.occupied_cells
        footprint_reference_cell = @(0, 0)
        footprint_outline_relative_to_reference_cell_px = @(@(0, -16), @(($cols * 32), (($cols - 1) * 16)), @((($cols - $rows) * 32), (($cols + $rows - 1) * 16)), @((-$rows * 32), (($rows - 1) * 16)))
        sorting_origin_relative_to_reference_cell_px = @((($cols - $rows) * 32), (($cols + $rows - 1) * 16))
        footprint_policy = $brief.footprint_policy
        orientation = 'Single native 2:1 isometric-compatible view; upper-left lighting for raised objects.'
        animation = $false; gameplay_behavior = 'None added; standalone artwork.'
        occlusion_policy = 'Review tall/multi-cell occlusion, ramp clearance and actual collision during future scene integration.'
    }
    foreach ($field in @('attachment_anchor_px', 'entry_hatch_threshold_px', 'image_footprint_vertices_px')) {
        if ($asset.PSObject.Properties.Name -contains $field) { $record[$field] = $asset.$field }
    }
    if ($job.request.PSObject.Properties.Name -contains 'recipe_path') {
        $record['drawing_recipe'] = Get-Content -LiteralPath $job.request.recipe_path -Raw | ConvertFrom-Json
    }
    $records += $record
}
if ($records.Count -ne 4) { throw 'Expected four assets.' }
$manifest = [ordered]@{ pack_id = 'lander_pack_d'; standards_version = '1.0.0'; assets = $records; gameplay_integration = $false; style_reference = $brief.style_reference; assembly_preview = $brief.assembly_preview }
$manifest | ConvertTo-Json -Depth 40 | Set-Content art/imports/lander_pack_d.json -Encoding utf8NoBOM
$brief.status = 'generated'
$brief | ConvertTo-Json -Depth 40 | Set-Content art/briefs/lander_pack_d.json -Encoding utf8NoBOM
# Review composition only: native pixels, decal beneath vehicle, separate optional parts.
$sheet = [System.Drawing.Bitmap]::new(960, 540)
$graphics = [System.Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([System.Drawing.Color]::FromArgb(26, 32, 43))
$font = [System.Drawing.Font]::new('Consolas', 11)
$graphics.DrawString('MOON LANDER / PACK D - native 1x / optional parts remain separate PNGs', $font, [System.Drawing.Brushes]::White, 16, 14)
$images = @{}
foreach ($asset in $brief.assets) { $images[$asset.file_name] = [System.Drawing.Bitmap]::new((Join-Path $projectRoot ('assets/vehicles/lander_pack_d/' + $asset.file_name))) }
$ground = $brief.assembly_preview.lander_front_contact_px
$craft = $records | Where-Object asset_id -eq 'lander_pack_d_moon_lander'
$ramp = $records | Where-Object asset_id -eq 'lander_pack_d_deployed_ramp'
$decal = $records | Where-Object asset_id -eq 'lander_pack_d_landing_marker_decal'
$cargo = $records | Where-Object asset_id -eq 'lander_pack_d_support_cargo_container'
$craftOrigin = @(($ground[0] - $craft.ground_anchor_px_from_image_top_left[0]), ($ground[1] - $craft.ground_anchor_px_from_image_top_left[1]))
$graphics.DrawImageUnscaled($images['landing_marker_decal.png'], ($ground[0] - $decal.ground_anchor_px_from_image_top_left[0]), ($ground[1] - $decal.ground_anchor_px_from_image_top_left[1]))
$graphics.DrawImageUnscaled($images['moon_lander.png'], $craftOrigin[0], $craftOrigin[1])
$rampOrigin = @(($craftOrigin[0] + $craft.entry_hatch_threshold_px[0] - $ramp.attachment_anchor_px[0]), ($craftOrigin[1] + $craft.entry_hatch_threshold_px[1] - $ramp.attachment_anchor_px[1]))
$graphics.DrawImageUnscaled($images['deployed_ramp.png'], $rampOrigin[0], $rampOrigin[1])
$cargoGround = $brief.assembly_preview.cargo_front_contact_px
$graphics.DrawImageUnscaled($images['support_cargo_container.png'], ($cargoGround[0] - $cargo.ground_anchor_px_from_image_top_left[0]), ($cargoGround[1] - $cargo.ground_anchor_px_from_image_top_left[1]))
$graphics.DrawString('4x4 footprint / 320x320 craft canvas', $font, [System.Drawing.Brushes]::LightSteelBlue, 182, 478)
$graphics.DrawString('Separate ramp', $font, [System.Drawing.Brushes]::White, 642, 68)
$graphics.DrawImageUnscaled($images['deployed_ramp.png'], 650, 96)
$graphics.DrawString('Landing decal - empty center', $font, [System.Drawing.Brushes]::White, 610, 260)
$graphics.DrawImageUnscaled($images['landing_marker_decal.png'], 604, 290)
$graphics.DrawString('Preview assembly only; no collision/boarding system', $font, [System.Drawing.Brushes]::LightSteelBlue, 16, 512)
$sheet.Save((Join-Path $projectRoot 'art/exports/lander_pack_d_preview.png'))
foreach ($image in $images.Values) { $image.Dispose() }
$graphics.Dispose(); $sheet.Dispose(); $font.Dispose()
if (Test-Path assets/vehicles/lander_pack_d/README.md) {
    $files = @((Get-ChildItem assets/vehicles/lander_pack_d/*.png).FullName) + @((Resolve-Path assets/vehicles/lander_pack_d/README.md).Path, (Resolve-Path art/imports/lander_pack_d.json).Path)
    Compress-Archive -LiteralPath $files -DestinationPath art/exports/lander_pack_d.zip -Force
}
Write-Output 'PASS: four native PNGs, binary alpha, exact source/runtime hashes, explicit footprints and measured/design anchors.'
