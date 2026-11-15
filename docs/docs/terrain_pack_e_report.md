# Asset Pack E - Extra Terrain Overlays and Base Floors

Delivered on 2026-11-15 through PixelLab MCP: **13 separate native 64 x 32 images covering all ten requested categories**, including the optional hazard floor and four floor-edge orientations. An additional 256 x 128 atlas contains the same images as exact unscaled regions.

- Package: `art/exports/terrain_pack_e.zip`.
- Component preview: `art/exports/terrain_pack_e_preview.png` (each component shown at integer 2x over unchanged regolith).
- Native TileMapLayer assembly: `tests/output/terrain_pack_e_assembly_2x.png` and `_1x.png`.
- Completed metadata and exact recipes: `art/imports/terrain_pack_e.json`.

The existing Moon terrain pack, TileSet, layer scene/script and logical map Resource remain unchanged. This is an additive artwork delivery; no expansion layer is added to the production world.

## Contents

All individual canvases are **64 x 32**, with ground center **(32,16)** and a one-cell visual footprint. Canvas padding and transparent pixels are preserved.

| Requested category | PNG / variants | Composition |
| --- | --- | --- |
| Small crater overlay | small_crater_overlay.png | Transparent shallow gray crater feature |
| Rocky patch overlay | rocky_patch_overlay.png | Transparent embedded pebbles and dust |
| Dark basalt patch overlay | dark_basalt_patch_overlay.png | Transparent irregular dark ground patch |
| Worn path / footpath | worn_footpath_tile.png | Transparent straight strip along +column/-column |
| Base floor panel | base_floor_panel_tile.png | Full opaque metal-panel diamond |
| Base floor edge | base_floor_edge_tile.png, _sw, _nw, _ne | Four sparse exterior edge-strip overlays |
| Utility floor / pad | utility_floor_pad_tile.png | Full opaque flush service-grate diamond |
| Small dust/debris overlay | small_dust_debris_overlay.png | Transparent sparse grains/chips |
| Landing area / marked ground | landing_marked_ground_tile.png | Full regolith-like diamond with restrained corner paint |
| Optional hazard variant | hazard_stripe_floor_tile.png | Full floor panel with narrow muted amber/dark SE stripe band |

The nine transparent feature/path/edge images leave backing terrain or floor visible. The four full ground surfaces contain exactly **1,024 opaque diamond pixels**. Every image has zero opaque pixels outside the same canonical mask used by the seam-fixed lunar pack:

`abs(2*x - 63) + 2*abs(2*y - 31) <= 64`, using integer pixel indices x/y.

The atlas has four columns and four rows, zero margins/separation, thirteen used cells and three transparent unused cells `(1,3)`, `(2,3)`, `(3,3)`. Its region and center-anchor tables are explicit. Individual PNGs are unchanged provider copies; atlas creation only blits their native pixels into a technical container. It does not redraw or alter source artwork.

## Style and production

The original atlas was inspected and its dominant neutral grays sampled (including #989897, #969696, #9C9C9B and #868685). Organic features use this restrained lunar palette. Base surfaces use cool gray metal, muted blue-gray seams, small fastener details and minimal blue accents; hazard paint is confined to one narrow band. There are no characters, baked text labels or audio assets.

Four initial PixelLab Pixen candidates produced complete ground diamonds instead of transparent natural features. They were rejected for this role and retained unchanged in the source archive. They were not locally erased, masked, cropped or repainted.

All thirteen selected images were then authored **from scratch through PixelLab pixelart_workbench**: nine exact path/floor/edge/marking views in two batches, and four new organic-overlay views in a third. Pixel grids provide intentional shading/texture and exact mask coverage. This makes the delivered art reproducible without resampling or silently correcting provider artwork. The source archive holds seventeen PNGs: four rejected candidates and thirteen selected outputs. Exact valid draw recipes are retained and embedded once in the manifest under `recipes`; each asset names its recipe and view.

**Cost: 4 subscription generations** for the initial candidates. The thirteen selected exact-draw views were free. Authentication succeeded; `get_balance` confirmed 4077.55 before and 4073.55 after. No additional generation calls or credit fallback were used.

## Placement and assembly

Use a native isometric TileMapLayer with tile size `(64,32)`, Diamond Down layout and horizontal offset axis. Texture origins remain `(0,0)`. Align added layers to the same world basis and `(-32,-16)` layer position used by the current ground; do not apply the correction twice. The image center `(32,16)` represents the grid-cell ground origin. For standalone sprites use `centered = false`, offset `(-32,-16)` and unit scale.

Render floors above regolith, then features and edge strips above their backing surfaces, below actors/buildings. Art indices must not become gameplay terrain kinds. No physics/navigation or occupancy data is attached.

Floor-edge directions are explicit:

- Default `base_floor_edge_tile`: SE, outward grid direction `(1,0)`.
- `_sw`: SW, outward `(0,1)`.
- `_nw`: NW, outward `(-1,0)`.
- `_ne`: NE, outward `(0,-1)`.

Because edges are sparse overlays, two sides can compose at a corner using separate layers without replacing the floor underneath. The development preview demonstrates a 3 x 3 panel area, four boundary orientations, composed corners, a central utility grate, nearby organic features and a repeated straight footpath. Preview TileMapLayers exist only inside the test process; no production scene/TileSet is changed.

The path supports straight +column/-column continuation only. No turn, junction, end-cap or complete terrain-transition/Wang autotile set was requested or implemented. Floor outlines are opaque intentional seams, not transparent holes or raised walls. Hazard paint and marked landing ground have no gameplay behavior.

## Files created or modified

Created:

- `assets/terrain/expansion_e/`: thirteen selected PNGs, one derived atlas PNG, fourteen Godot import sidecars and README.
- `assets/pixellab/source/terrain_pack_e/`: seventeen unchanged original PNGs, production requests/IDs/hashes, three valid exact draw recipes and the original terrain hash record (relative project paths only).
- `art/briefs/terrain_pack_e.json`: production specification, roles, canonical mask, edge and path policies.
- `art/imports/terrain_pack_e.json`: completed asset and atlas metadata, native regions/anchors, alpha statistics, source/runtime hashes, generation/draw IDs, prompts, unique recipe table and composition policies. Selected production IDs are PixelLab drawing IDs, not paid AI-job counts.
- `art/exports/terrain_pack_e.zip` and `terrain_pack_e_preview.png`: delivery archive and review sheet, excluded from import by the existing export-folder `.gdignore`.
- `tools/terrain_pack_e/prepare_pack.ps1`: repeatable source/mask/hash checks, exact copying, atlas/metadata/preview/ZIP construction; no jobs or downloads.
- `tests/terrain_pack_e_test.gd` and its Godot UID sidecar: image/import/atlas/mask/seam/path checks and isolated graphical assembly.
- `docs/terrain_pack_e_report.md`: this report.

Modified:

- `AGENTS.md`: adds the authorized pack scope and handoff references while preserving existing instructions.

No production script, scene, Resource, InputMap or project rendering setting was modified. Hash checks confirm the original regolith PNG, Moon TileSet, TerrainLayer scene/script and logical lunar region Resource remain unchanged. Existing characters, props, cameras, interaction and inventory systems were not edited.

## Validation

| Check | Final result |
| --- | --- |
| JSON and required provenance fields | Valid; 13 unique component records plus derived atlas record |
| Native dimensions | Every component exactly 64 x 32; atlas 256 x 128 |
| Alpha | Binary, nonempty; transparent outside the canonical diamond; sparse overlays retain interior transparency |
| Full surfaces | Four exact 1,024-pixel diamonds |
| Source/runtime hashes | All selected PNGs byte-identical to provider originals |
| Atlas regions | All thirteen decoded regions exactly match individual PNG RGBA; unused cells transparent |
| Adjacent floor raster | Two adjacent diamonds cover exactly 2,048 unique pixels, with no duplicate coverage |
| Path continuation | Both column-axis shared-edge endpoints remain opaque |
| Headless pack validation | **2,176 checks passed** |
| Graphical pack validation | **2,178 checks passed**, including 1x and 2x captures |
| Existing isometric world regression | **33,961 checks passed** |
| Existing Moon terrain regression | **338 checks passed**; original 144-cell raster still has zero gaps/overlaps |
| Main scene startup | Passed, headless exit 0 |

Godot version: **4.7.2.stable.official.ed1daf0bf**. All fourteen PNG sidecars use lossless compression, mipmaps off, size limit zero, no premultiplication and no alpha-border RGB rewriting. Existing nearest filtering and integer viewport/camera presentation are preserved.

Final import, headless, graphical, regression and smoke logs: **0 errors, 0 warnings**. An initial metadata assertion compared JSON numeric arrays directly with integer-array literals; it was corrected to compare normalized integer values. The metadata was already correct and all original center/footprint assertions were retained. No failed check was skipped and no artwork was altered to pass validation.

Captures were visually inspected for overlay blending with the original regolith, readable restrained floor details, aligned continuous path, composed edge corners and sharp 1x/2x presentation. Full non-terrain gameplay regressions were not repeated for this standalone artwork pack.

## Evidence and recheck

- `tests/output/terrain_pack_e_test.log` and `terrain_pack_e_rendered.log`: pack validation.
- `tests/output/terrain_pack_e_assembly_2x.png` and `_1x.png`: actual native TileMapLayer assembly over unchanged Moon terrain.
- `tests/output/terrain_pack_e_world_regression.log` and `terrain_pack_e_moon_regression.log`: existing terrain/world suites.
- `tests/output/terrain_pack_e_main.log`: existing main-scene smoke run.

Rebuild artifacts with `./tools/terrain_pack_e/prepare_pack.ps1`. After importing, run Godot headless with `--script res://tests/terrain_pack_e_test.gd`; with a graphical renderer add `-- --capture` for the isolated assembly. Keep nearest filtering, full canvases and the recorded layer basis. Do not resize/crop/rotate images to force compatibility.

This pack does not replace the main regolith, introduce new terrain logic or create a tutorial/base-construction system. PixelLab usage terms are referenced at `https://pixellab.ai/termsofservice`; no new license or standards exception is asserted. No additional pack or development phase was started.
