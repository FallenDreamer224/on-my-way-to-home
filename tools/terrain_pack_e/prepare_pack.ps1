param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
Set-Location -LiteralPath $projectRoot
Add-Type -AssemblyName System.Drawing
$brief = Get-Content art/briefs/terrain_pack_e.json -Raw | ConvertFrom-Json
$jobs = (Get-Content assets/pixellab/source/terrain_pack_e/generation_jobs.json -Raw | ConvertFrom-Json).jobs
foreach ($old in (Get-Content $brief.existing_terrain_hash_record -Raw | ConvertFrom-Json)) {
    if ((Get-FileHash -LiteralPath $old.path -Algorithm SHA256).Hash.ToLowerInvariant() -ne $old.sha256) { throw "Existing terrain changed: $($old.path)" }
}
New-Item -ItemType Directory -Force assets/terrain/expansion_e,art/imports,art/exports | Out-Null
$records = @()
$recipes = [ordered]@{}
$atlas = [System.Drawing.Bitmap]::new(256,128)
$atlasGraphics = [System.Drawing.Graphics]::FromImage($atlas)
$atlasGraphics.Clear([System.Drawing.Color]::Transparent)
foreach ($asset in $brief.assets) {
    $job = @($jobs | Where-Object asset_id -eq $asset.asset_id)[-1]
    $suffix = if ($job.attempt) { '_v' + $job.attempt } else { '' }
    $source = 'assets/pixellab/source/terrain_pack_e/' + ($asset.file_name -replace '\.png$', ($suffix + '.png'))
    $runtime = 'assets/terrain/expansion_e/' + $asset.file_name
    $image = [System.Drawing.Bitmap]::new((Join-Path $projectRoot $source))
    if ($image.Width -ne 64 -or $image.Height -ne 32) { throw "Native size mismatch: $source" }
    $transparent = 0; $partial = 0; $opaque = 0; $outside = 0
    for ($y = 0; $y -lt 32; $y++) {
        for ($x = 0; $x -lt 64; $x++) {
            $pixel = $image.GetPixel($x,$y)
            if ($pixel.A -eq 0) { $transparent++; continue }
            if ($pixel.A -lt 255) { $partial++ } else { $opaque++ }
            if ([Math]::Abs(2*$x-63) + 2*[Math]::Abs(2*$y-31) -gt 64) { $outside++ }
        }
    }
    if ($transparent -eq 0 -or $opaque -eq 0 -or $partial -ne 0 -or $outside -ne 0) { $image.Dispose(); throw "Alpha or mask mismatch: $source" }
    if ($opaque -ne $asset.expected_pixels) { $image.Dispose(); throw "Recipe pixel count mismatch: $source expected $($asset.expected_pixels), got $opaque" }
    if ($asset.role -like 'opaque_*' -and $opaque -ne 1024) { throw "Incomplete ground diamond: $source" }
    Copy-Item -LiteralPath $source -Destination $runtime -Force
    $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne (Get-FileHash -LiteralPath $runtime -Algorithm SHA256).Hash.ToLowerInvariant()) { throw "Copy mismatch: $runtime" }
    $index = $records.Count; $atlasX = ($index % 4) * 64; $atlasY = [int][Math]::Floor($index/4.0) * 32
    $atlasGraphics.DrawImageUnscaled($image,$atlasX,$atlasY)
    $image.Dispose()
    $recipe = Get-Content -LiteralPath $job.request.recipe_path -Raw | ConvertFrom-Json
    $recipes[$job.request.recipe_path] = $recipe
    $record = [ordered]@{
        asset_id = $asset.asset_id; standards_version = '1.0.0'; category = 'terrain_surface_or_overlay'; role = $asset.role
        source_provider = 'PixelLab.ai MCP'; source_files = @($source); runtime_files = @($runtime)
        usage_terms = 'https://pixellab.ai/termsofservice'; native_canvas_size_px = @(64,32)
        physical_scale_intent = $asset.description; review_status = 'reviewed_asset_only_not_production_integrated'; exception = $null
        generation_id = $job.response.job_id; production_tool = $job.tool; prompt = $job.request.description
        request_record = 'assets/pixellab/source/terrain_pack_e/generation_jobs.json'
        drawing_recipe_ref = $job.request.recipe_path; drawing_view = $job.request.view_id; sha256 = $hash
        ground_anchor_px_from_image_top_left = @(32,16); sprite2d_centered = $false; sprite2d_offset_px = @(-32,-16)
        explicit_footprint_grid_cells = @(1,1); occupied_cells = ,@(0,0); animation = $false
        opaque_pixels = $opaque; transparent_pixels = $transparent; partially_transparent_pixels = $partial; outside_diamond_pixels = $outside
        canonical_mask = 'abs(2*x-63)+2*abs(2*y-31)<=64; 1024 pixel centers'
        atlas_file = 'assets/terrain/expansion_e/terrain_expansion_atlas.png'; atlas_region_px = @($atlasX,$atlasY,64,32)
        margin_px = 0; separation_px = 0; tilemap_texture_origin_px = @(0,0)
        layer_policy = if ($asset.role -like 'opaque_*') { 'Optional floor/surface overlay above existing ground; no terrain-kind or walkability change.' } else { 'Transparent overlay above its backing terrain/floor. Keep source texture alpha; no collision.' }
    }
    if ($asset.role -eq 'overlay_edge') { $record['outward_grid_direction'] = $asset.outward_grid_direction }
    if ($asset.role -eq 'overlay_path') { $record['path_axis_grid'] = @(@(1,0),@(-1,0)) }
    $records += $record
}
$atlasPath = 'assets/terrain/expansion_e/terrain_expansion_atlas.png'
$atlas.Save((Join-Path $projectRoot $atlasPath)); $atlasGraphics.Dispose(); $atlas.Dispose()
if ($records.Count -ne 13) { throw 'Expected thirteen assets covering ten categories.' }
$manifest = [ordered]@{
    pack_id = 'terrain_pack_e'; standards_version = '1.0.0'; tile_size_px = @(64,32); assets = $records; gameplay_integration = $false
    atlas = [ordered]@{ asset_id = 'terrain_pack_e_atlas'; standards_version = '1.0.0'; category = 'terrain_atlas'; source_provider = 'Native lossless packing of PixelLab outputs'; source_files = @($records | ForEach-Object { $_.runtime_files[0] }); runtime_files = @($atlasPath); file = $atlasPath; usage_terms = 'https://pixellab.ai/termsofservice'; native_canvas_size_px = @(256,128); physical_scale_intent = 'Native 64x32 tile regions, unscaled; technical container only.'; review_status = 'exact_regions_verified_by_asset_test'; exception = $null; columns = 4; rows = 4; used_cells = 13; empty_cells = @(@(1,3),@(2,3),@(3,3)); margin_px = 0; separation_px = 0; sha256 = (Get-FileHash $atlasPath -Algorithm SHA256).Hash.ToLowerInvariant(); assembly_policy = 'Native unscaled PNG blits only; source files remain unchanged.'; derived_from_asset_ids = @($records | ForEach-Object { $_.asset_id }) }
    original_terrain_hash_record = $brief.existing_terrain_hash_record; edge_policy = $brief.edge_policy; footpath_policy = $brief.footpath_policy
    recipes = $recipes
}
$manifest.atlas['tile_regions'] = @($records | ForEach-Object { [ordered]@{ asset_id = $_.asset_id; region_px = $_.atlas_region_px } })
$manifest.atlas['center_anchors'] = @($records | ForEach-Object { [ordered]@{ asset_id = $_.asset_id; image_anchor_px = @(32,16) } })
$manifest | ConvertTo-Json -Depth 60 | Set-Content art/imports/terrain_pack_e.json -Encoding utf8NoBOM
$brief.status = 'generated'; $brief | ConvertTo-Json -Depth 40 | Set-Content art/briefs/terrain_pack_e.json -Encoding utf8NoBOM
# Review sheet: unchanged regolith is composited behind each asset at integer 2x.
$sheet = [System.Drawing.Bitmap]::new(960,540); $graphics = [System.Drawing.Graphics]::FromImage($sheet)
$graphics.Clear([System.Drawing.Color]::FromArgb(26,32,43)); $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor; $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$font = [System.Drawing.Font]::new('Consolas',10)
$ground = [System.Drawing.Bitmap]::new((Join-Path $projectRoot 'assets/terrain/moon/moon_regolith_atlas_4x3.png'))
$graphics.DrawString('MOON TERRAIN EXPANSION / E - 64x32 assets shown at 2x over original regolith', $font, [System.Drawing.Brushes]::White,12,8)
for ($index=0;$index -lt $records.Count;$index++) {
    $record=$records[$index];$x=12+($index%3)*316;$y=36+[Math]::Floor($index/3.0)*99
    $graphics.DrawString(($record.asset_id -replace '^terrain_pack_e_',''),$font,[System.Drawing.Brushes]::White,$x,$y)
    $destination=[System.Drawing.Rectangle]::new(($x+28),($y+22),128,64)
    $graphics.DrawImage($ground,$destination,0,0,64,32,[System.Drawing.GraphicsUnit]::Pixel)
    $image=[System.Drawing.Bitmap]::new((Join-Path $projectRoot $record.runtime_files[0]))
    $graphics.DrawImage($image,$destination,0,0,64,32,[System.Drawing.GraphicsUnit]::Pixel);$image.Dispose()
}
$sheet.Save((Join-Path $projectRoot 'art/exports/terrain_pack_e_preview.png'));$ground.Dispose();$graphics.Dispose();$sheet.Dispose();$font.Dispose()
if (Test-Path assets/terrain/expansion_e/README.md) {
    $files=@((Get-ChildItem assets/terrain/expansion_e/*.png).FullName)+@((Resolve-Path assets/terrain/expansion_e/README.md).Path,(Resolve-Path art/imports/terrain_pack_e.json).Path)
    Compress-Archive -LiteralPath $files -DestinationPath art/exports/terrain_pack_e.zip -Force
}
Write-Output 'PASS: 13 native masked assets; four full 1024-pixel surfaces; transparent features; exact source hashes; unscaled atlas; original terrain unchanged.'
