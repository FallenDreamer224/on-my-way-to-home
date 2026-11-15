# Phase 0.7A - Moon Terrain Import

Implemented and validated in **Godot 4.7.2.stable.official.ed1daf0bf**. The finished Moon regolith pack now supplies the lunar ground visuals. The world remains native 2D, with the original 64 x 32 diamond grid, 960 x 540 viewport, nearest filtering, 144-cell layout, logical terrain kinds, walkability, astronaut, Chiwis and cameras. The existing Phase 0.7 interaction/inventory features were also preserved. No other phase, gameplay feature, audio, artwork generation or PixelLab credit use was introduced.

## Pack inspection and source choice

The authorized external `assets/tiles/moon_terrain/` pack contains **29 files**: 12 standard individual tiles, 12 optional seam-fixed individual tiles, two 4 x 3 atlases, a preview, README and manifest. Both atlases are **256 x 96 RGBA** with twelve static **64 x 32** ground variants, zero margins and zero separation. These are terrain variations, not animation frames.

The supplied manifest identifies `moon_terrain_2.pxo` as the upstream source, with a 64 x 64 canvas and an existing crop box `(0, 16, 64, 48)`. This phase imports the supplied finished PNGs; it does not open, crop, export or modify that upstream PXO. Its source hash/crop information is preserved as supplier metadata rather than claimed as a new PXO verification.

**Chosen source: `optional_seam_fixed/moon_regolith_atlas_4x3.png`.** The imported atlas is a byte-identical copy, not a new correction or resampled image. The user explicitly authorized choosing between the supplied standard and seam-fixed versions.

The read-only audit verified all 24 individual PNGs against their corresponding atlas regions. Each seam-fixed tile contains exactly **1,024 fully opaque diamond pixels**, with transparent pixels outside the mathematically tessellating mask. Shared opaque pixels match the standard source exactly. The supplied fixes add 2-8 missing edge pixels and remove 30-31 outside-mask pixels per variant; every count agrees with the pack's manifest. Interior pixels are unchanged. No additional fixes, recoloring, trimming, stretching or resizing were applied here.

Both sources were tested with the same native TileMapLayer layout, logical map and deterministic variant choices:

| Source | Uncovered expected pixel positions | Overlapping or outside-footprint pixel positions |
| --- | --- | --- |
| Standard supplied atlas | 62 | 3,669 |
| Supplied seam-fixed atlas | **0** | **0** |

These counts compare the full 144-cell native-size raster with the existing logical diamond footprint. The second column counts missing coverage; the third counts pixel positions with excess coverage or artwork outside the expected footprint, not a count of broken logical cells. The comparison also ran graphically at the original player/management camera scales. The fixed set provides the cleanest continuous surface without changing the map.

`art/imports/moon_terrain.json` records all 29 original file hashes, the selected atlas hash, supplied manifest, per-variant regions/anchors/edge audits, standards version, usage context and import settings. All **29 external files still matched their initial SHA-256 hashes** after implementation. External files were never written, renamed, moved or deleted. No external asset is needed for normal play or regression validation.

## Imported assets and TileSet

Runtime art is one PNG: `assets/terrain/moon/moon_regolith_atlas_4x3.png`, with its Godot `.png.import` sidecar. Individual tiles and the unused standard atlas are not duplicated into runtime assets. The reusable native resource is `resources/terrain/moon_terrain.tres`.

The TileSet preserves:

- Tile size **64 x 32**, shape **Isometric**, layout **Diamond Down**, offset axis **Horizontal**.
- Ground's original position **(-32, -16)**, unit scale and zero rotation; cell (0, 0) remains centered at world (0, 0).
- Four logical kind/source IDs. Each source references the same imported atlas and owns three 64 x 32 regions.
- Texture origin **(0, 0)** on every TileData, retaining the native ground center at image **(32, 16)**.
- No new physics/navigation layers, terrain behavior, processing effects or collision geometry.

| Existing logical kind/source ID | Atlas coordinates | Supplied variants |
| --- | --- | --- |
| 0: Regolith | (0, 0), (0, 1), (0, 2) | 01, 05, 09 |
| 1: Light regolith | (1, 0), (1, 1), (1, 2) | 02, 06, 10 |
| 2: Dark regolith | (2, 0), (2, 1), (2, 2) | 03, 07, 11 |
| 3: Dust patch | (3, 0), (3, 1), (3, 2) | 04, 08, 12 |

These remain the existing logical classifications. The supplied pack is a regolith variation set rather than four separately authored gameplay materials; no tinting or material reinterpretation was introduced to force a visual distinction.

Ground's new optional `terrain_art` export references the TileSet. During the existing rebuild, a stable hash of cell coordinates and kind selects one of the source's three atlas rows. The renderer still assigns `source_id == logical_kind`. All **12 variants** appear on the current map. Rebuilding reproduces identical atlas coordinates and does not consume the global gameplay RNG. Nothing is randomized per frame, and no new logical terrain kinds, cells or world generator were added.

The original `replacement_textures` API is preserved: a nonempty array of four native 64 x 32 textures overrides `terrain_art`, retaining kind order and dimensional validation. If neither is configured, the procedural placeholder factory remains available as a test/fallback. It is not the active runtime lunar art source.

Ground explicitly uses nearest filtering and disabled texture repeat. PNG compression is lossless, with mipmaps, size limits/rescaling, alpha premultiplication and alpha-border modification disabled. Imported texture RGBA matches the copied PNG exactly. Existing integer viewport/camera presentation and lack of smoothing remain unchanged; no project rendering setting was changed.

Future ground/decorative overlays can remain sibling TileMapLayers sharing the same grid basis and explicit Z ownership. This import adds no overlay layer, obstacle semantics, terrain blending system or speculative overlay artwork.

## Files created or modified

Created:

- `assets/terrain/moon/moon_regolith_atlas_4x3.png` and `.png.import`.
- `resources/terrain/moon_terrain.tres`.
- `art/imports/moon_terrain.json`.
- `tools/terrain/prepare_moon_terrain.gd` and its `.gd.uid`: read-only pack audit and reproducible TileSet construction.
- `tests/moon_terrain_test.gd` and its `.gd.uid`: atlas, mask, map, deterministic variation, raster and graphical checks.
- This report.

Modified:

- `scripts/world/terrain_layer.gd`: optional art TileSet selection and render-only atlas variation; existing logical initialization/replacement behavior preserved.
- `scenes/world/terrain_layer.tscn`: Moon TileSet reference and explicit nearest/no-repeat presentation; layer transform unchanged.
- `tests/isometric_world_test.gd`: inspect the actual selected atlas region instead of assuming a whole texture is one tile; keep coverage/coordinate/data assertions and exercise the original four-texture replacement API with its native fixture.
- `tests/validate.ps1`: validate import JSON, add headless/rendered Moon checks and retain every existing suite/fullscreen check.
- `AGENTS.md`, `README.md`, `assets/terrain/README.md`, `docs/architecture.md`: current terrain source, rendering/data boundary and phase scope.

A before/after hash comparison of pre-existing production scripts, scenes, resources, asset PNGs and art JSON found changes only in the intended TerrainLayer script and scene. TerrainRegion, `lunar_test_region.tres`, walkability/routing, player/companion controllers, character art, camera/mode/input/UI/inventory implementations and previous reports remain unchanged. Project settings and InputMap were not edited. No commits or repository initialization were performed. Ignored logs, snapshots, profiles and screenshots remain inside `tests/output/`.

## Validation results

Executed the read-only pack audit, resource build, standard/fixed graphical comparison and complete `./tests/validate.ps1 -IncludeRendering` run with Godot 4.7.2. Engine editor/user data was isolated inside the project as in previous phases; existing Windows certificate-store access was allowed for engine startup. No dependencies were installed.

| Validation | Final result |
| --- | --- |
| External file audit | All 29 hashes unchanged; both atlases and all 24 individual tile images verified |
| Imported atlas pixels | Byte-identical source copy; imported RGBA unchanged |
| JSON syntax | Standards, intake, placeholders, character and Moon manifests valid |
| Headless editor import / script checks | Passed; all 39 runtime/test GDScript check-only parses passed; preparation tool executed successfully |
| Foundation/native hierarchy | 380 headless / 382 graphical checks passed |
| Isometric world regression | 33,961 checks passed, including whole-map gap/overlap coverage and original replacement API |
| Moon terrain | 338 headless / 342 graphical checks passed |
| Explicit standard/fixed comparison | 345 checks passed; fixed raster has zero gaps/overlap/outside pixels |
| Player camera | 49 checks passed |
| Gameplay modes | 93 headless / 99 graphical / 93 fullscreen checks passed |
| Astronaut movement/animation | 234 headless / 244 graphical checks passed |
| Real character assets | 696 checks passed |
| Chiwis movement/routing | 44 headless / 46 graphical checks passed |
| Inventory | 38 checks passed |
| Interaction/inventory integration | 64 headless / 67 graphical checks passed |
| Main headless, graphical editor and main fullscreen startup | Passed |
| Production architecture scan | No obsolete spatial architecture references |

Existing movement tests exercise actual astronaut walking, full-foot map boundaries, sparse holes, directional animation, camera follow and mode handoff. Existing Chiwis tests include following/stopping, rate independence, safe barrier routing, diagonal-gap waiting and mode preservation. Interaction/inventory tests verify the already implemented pickup/modal behavior remains intact. No assertion was skipped to accommodate the new art.

The new Moon suite verifies all 12 masks/regions/anchors, native dimensions/import settings, four stable source IDs, original logical cells, all variants in use, deterministic rebuilds, no gameplay RNG consumption and complete native raster coverage. Graphical captures include Player Mode at 2x and management at **1x, 2x and 3x**. The explicit comparison uses temporary test-only TileSet copies for the standard atlas, then restores the runtime resource; the standard atlas is not a production dependency.

**Final validation errors: 0. Warnings: 0.** An initial editor import was run before the newly referenced TileSet had been saved and reported missing-resource/editor diagnostics. The resource was then saved, a clean import completed, and the entire final regression run passed. No unresolved import failure remains; initial diagnostic logs stay under ignored output.

## Graphical evidence and limitations

The game ran through the existing Compatibility/OpenGL renderer. Screenshots were inspected for continuous regolith, correct boundary alignment, crisp pixel edges, native character scale and both camera modes. The large placeholder tile outlines are gone; there is no visible transparent grid, broken tile alignment or overlap on the selected surface. The existing lunar footprint and actors/pickups remain in place.

Evidence under `tests/output/`:

- `moon_terrain_player_2x.png`.
- `moon_terrain_management_1x.png`, `moon_terrain_management_2x.png`, `moon_terrain_management_3x.png`.
- `moon_terrain_standard_player_2x.png`, `moon_terrain_standard_management_1x.png`: comparison-only standard pack captures.
- `moon_terrain_comparison.json` and `.log`: quantitative source comparison.
- `moon_terrain.log`, `moon_terrain_rendered.log` and all existing suite logs/captures.

This is automated native input/physics/rendering validation plus screenshot inspection, not a physical keyboard/mouse play session. All 12 masks tessellate geometrically; artistic texture patterns can still repeat because this is a finite twelve-variant pack. Black space outside the original map diamond is intentional. No new elevation, craters, overlays, transitions, obstacles or gameplay materials were fabricated. Display/DPI combinations and release exports beyond the existing suite are not certified.

## Reproduction and manual checks

Normal play/tests require only committed project-local PNG/resource files; the external pack is needed only for source auditing or rebuilding this import. The preparation script accepts `--source-root <pack-folder>` after Godot's `--`; its default is the authorized Documents asset-pack location. It writes only project metadata/resources, never source files. Use the configured Godot 4.7.2 executable with project-local user/editor profile isolation as in `tests/validate.ps1`.

For an intentional re-import: run `tools/terrain/prepare_moon_terrain.gd` to audit the source pack, copy its existing `optional_seam_fixed/moon_regolith_atlas_4x3.png` byte-for-byte to the internal atlas path, preserve the supplied `.import` settings, run the headless editor import, then run the preparation script with `--build`. Re-run the full validation suite. For a graphical comparison, run `tests/moon_terrain_test.gd` with `-- --capture --compare-pack <authorized-pack-folder>`. Reinspect any changed source pack rather than silently accepting a different layout or editing artwork.

Manual procedure:

1. Open `project.godot` with Godot 4.7.2 and press F5. Expect the same lunar footprint with finished regolith, one astronaut, Chiwis and the existing development pickups. Confirm continuous ground without transparent cracks.
2. Walk with WASD/arrows in all directions and toward the map edges. Movement, character feet, camera follow and full-foot stopping should behave as before. Let Chiwis follow and settle nearby.
3. Press Tab. Pan with WASD/arrows and cycle management zoom through 1x/2x/3x using the wheel. Inspect seams at each scale. Return to Player Mode and verify actor positions and original player framing.
4. Collect a nearby pickup with E/left-click, inspect inventory with I and close with I/Esc. Confirm the existing modal/input rules and collected state survive mode changes; this terrain import must add no new gameplay behavior.
5. Resize or launch fullscreen and inspect sharpness/letterboxing. The map edge remains the original diamond; empty space outside is expected.
6. Inspect `resources/terrain/moon_terrain.tres` and Ground's `terrain_art` reference. Verify four source IDs, three regions each, 64 x 32 size, zero tile origin offsets and unchanged Ground transform. Do not change terrain kinds to control art variation.
7. Run `./tests/validate.ps1 -IncludeRendering` in PowerShell 7. Review current suite logs separately from optional source-comparison and initial setup diagnostics.

No subsequent phase was started. Future terrain overlays should preserve the existing logical grid and renderer/data separation and require their own explicit scope.
