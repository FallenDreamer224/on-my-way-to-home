# Asset Pack D - Moon Rocket / Lander

Delivered on 2026-11-15 through PixelLab MCP: the Moon Lander / Transport Craft plus all three optional support assets as **four separate transparent PNGs**. The lander is a major arrival-vehicle landmark with a practical white/light-gray cabin, dark cockpit windows, blue details, articulated landing legs and broad footpads matching the Moon base style.

- Package: `art/exports/lander_pack_d.zip`.
- Native-size assembly/parts preview: `art/exports/lander_pack_d_preview.png`.
- Complete metadata: `art/imports/lander_pack_d.json`.
- Selected PNGs: `assets/vehicles/lander_pack_d/`.

Preview labels and dark background are annotations only. They are not baked into any asset. All delivered components retain transparent backgrounds and native canvases.

## Assets

| Asset | Canvas | Footprint budget | Ground/contact anchor |
| --- | --- | --- | --- |
| Moon Lander / Transport Craft | 320 x 320 | 4 x 4 | (160,284), front footpad center |
| Deployed Ramp | 128 x 128 | 2 x 1 | (86,106), front contact |
| Landing Marker Decal | 288 x 160 | 4 x 4 | (144,144), front diamond vertex |
| Support Cargo Container | 64 x 64 | 1 x 1 | (33,53), measured base contact |

Footprints are separate from canvas dimensions, visible bounds, hull height and leg/pad overhang. Each record enumerates occupied column/row cells relative to reference cell (0,0), stores the four projected perimeter vertices, and records the proposed sorting-origin offset. No collision or gameplay occupancy is added.

## Production and cost

PixelLab Create Image Pro produced one 320 x 320 lander using the Pack C habitat as its style reference. The larger native canvas leaves room for the landmark silhouette at the project's existing human pixel density. Pro Flash generated the small cargo pod in the same hardware style using the Pack C utility box as reference.

The optional ramp and decal were drawn as new artwork through **PixelLab pixelart_workbench** with exact native coordinates. The ramp has a segmented gray deck, pale edges and blue details. The flat decal has a nominal 256 x 128 diamond centerline with muted dashed paint and cyan corner brackets. Its empty center and exact 2:1 geometry make it a separate ground overlay. Thick corner strokes extend the visible bounds slightly beyond that nominal centerline, as recorded in metadata.

All four original PixelLab PNGs are preserved unchanged. No local erasing, recoloring, cropping, trimming, resizing, stretching or distortion was applied. The manually authored components were drawn from scratch, not corrections to generated artwork. Exact draw recipes are retained in the source folder and embedded in the completed manifest.

Total use: **20 subscription generations** (15 for the hero craft, 5 for cargo; both exact-draw operations were free). No replacement jobs were needed. Authentication succeeded; `get_balance` confirmed 4097.55 before and 4077.55 after. Only static PNGs were exported; no animation or audio assets were added.

## Ground and attachment conventions

The craft root contact is the visually reviewed center of the foremost landing footpad, `(160,284)`, rather than the bottom canvas edge. Its proposed 4 x 4 ground-diamond vertices in image space are `(160,156)`, `(288,220)`, `(160,284)` and `(32,220)`. Footpad geometry extends around these contact centers.

The decal's corresponding vertices are `(144,16)`, `(272,80)`, `(144,144)` and `(16,80)`. Sharing the same front-contact root aligns its nominal diamond with the craft's footprint guide without scaling either PNG. The two guides follow the project's 64 x 32 tile projection.

Use the full PNG with `Sprite2D.centered = false`, native unit scale and the recorded negative-anchor offset. For a 4-column/4-row footprint, the proposed front sorting origin is `(0,112)` relative to reference cell (0,0)'s center. Logical placement and Sprite2D drawing offsets remain distinct.

The ramp upper attachment is `(34,24)` in its image. The review composition aligns it with the craft hatch threshold `(205,207)` in craft image space. It descends screen down-right and has a separately recorded ground-contact anchor. The hatch is closed. This is a static visual connection, not a verified boarding route or opening mechanism.

The preview draws decal, craft, separate ramp and cargo at native 1x. The decal belongs above terrain and below raised entities in a future scene. Tall/multi-cell occlusion, actual collision, doorway clearance, ramp snapping and walkability require explicit scene integration review. These art budgets are not automatic construction or collision definitions.

At native 1x, the complete craft fits in a 960 x 540 hero composition. At player-camera 2x, a full 320-pixel canvas occupies 640 screen pixels vertically; future framing should use an appropriate existing integer camera zoom or partial landmark view. The source sprite must not be shrunk to force a full-height shot.

## Files created or modified

Created:

- `assets/vehicles/lander_pack_d/`: four selected PNGs, four Godot import sidecars and README.
- `assets/pixellab/source/lander_pack_d/`: four unchanged provider PNGs, `generation_jobs.json`, `deployed_ramp_recipe.json` and `landing_decal_recipe.json`.
- `art/briefs/lander_pack_d.json`: native sizes, footprint allocations, contact/attachment specifications and style-reference provenance.
- `art/imports/lander_pack_d.json`: complete asset records with source/runtime hashes, actual dimensions, visible bounds, alpha/color statistics, prompts or draw recipes, provider IDs, production methods, footprint cells, ground anchors and preview coordinates. Workbench `generation_id` values identify the exact-draw render, not a paid AI job.
- `art/exports/lander_pack_d.zip` and `lander_pack_d_preview.png`: delivery archive and review image. The existing export-folder `.gdignore` keeps these out of Godot import.
- `tools/lander_pack_d/prepare_pack.ps1`: repeatable native/alpha/source validation, metadata, native assembly preview and ZIP packaging. It submits no jobs and downloads nothing.
- `tests/lander_pack_d_test.gd` and its Godot UID sidecar: PNG/import integrity, footprint and attachment checks.
- `docs/lander_pack_d_report.md`: this report.

Modified:

- `AGENTS.md`: adds the authorized pack scope and handoff references while preserving prior instructions.

Existing production scenes, gameplay scripts, item definitions, terrain, prop integration, characters, cameras, UI and project settings were not changed. No landing, launch, vehicle, boarding, storage, physics or interaction system was implemented. No additional phase, pack or commit was started.

## Validation

- Four unique PNGs at their declared native sizes, with nonempty artwork and transparent margins.
- Zero partially transparent pixels in all four selected assets; no canvas-edge clipping detected.
- All delivered PNG SHA-256 hashes match the unchanged provider originals.
- Complete-canvas visual review checked the landmark silhouette, consistent materials, ramp connection, decal alignment and separate cargo readability.
- Manifest and brief parse as JSON; mandatory provenance fields and explicit footprint/occupied-cell records are present.
- Godot **4.7.2.stable.official.ed1daf0bf** headless import/reimport succeeded.
- All four imports use lossless compression, mipmaps off, size limit zero, no alpha-border RGB rewriting and no premultiplication. Existing nearest filtering/integer presentation remain unchanged.
- `tests/lander_pack_d_test.gd` passed: exact imported RGBA pixels and PNG hashes, native dimensions, no mipmaps, valid contact offsets, complete footprint cells, opaque ramp connection and matching craft/decal guide coordinates.
- Existing main-scene headless smoke check passed, exit 0.
- Final import, texture-test and main-smoke logs: **0 errors, 0 warnings**.
- ZIP contents and PNG hashes verified against the selected runtime files.

Logs are under ignored `tests/output/lander_pack_d_*.log`. Full gameplay regression suites were not repeated for this standalone art delivery. The assembly preview is an artifact composition rather than a new production gameplay scene.

## Recheck and integration limits

1. Inspect the preview and individual PNGs at 100% and integer magnification on dark/light backgrounds.
2. Run `./tools/lander_pack_d/prepare_pack.ps1` to rebuild metadata, preview and ZIP from preserved sources.
3. Open Godot, import with supplied sidecars and run headless with `--script res://tests/lander_pack_d_test.gd`.
4. Before gameplay placement, verify contact centers, occupancy, actor clearance, Y-sorting/occlusion, decal draw order and camera framing. Keep the ramp and cargo independently placeable.

There is no open-hatch variant, boarding animation, launch state, powered landing light, smoke/exhaust, sound or cargo-transfer behavior. PixelLab usage terms are referenced at `https://pixellab.ai/termsofservice`; no new license is asserted. No source modification or locked-standard exception was applied.
