# Phase 0.2 - Isometric world foundation

Phase 0.2 is complete. Phase 0.3 is not started. This adds a visible lunar terrain fixture and reusable mathematical/native coordinate APIs, without player or gameplay systems.

## Inspection and preserved decisions

Read the existing project instructions, Art Bible, machine-readable standards, isometric conventions, Phase 0.1 report, main/world/UI scenes, settings, core scripts, and tests before changes. Preserved Godot **4.7.2**, GDScript, native 2D architecture, GL Compatibility, **960 x 540** viewport, integer presentation scaling, nearest filtering, English, existing input declarations, core development configuration, and future entity attachment points. The locked Art Bible and standards JSON remain unchanged. No dependencies, commits, third-party artwork, or PixelLab operations were added.

## Implemented architecture

```text
Main (existing composition root)
  Systems (future services)
  World (independently instantiable Node2D)
    Terrain (Node2D, z_index -10)
      Ground (reusable terrain_layer.tscn, TerrainLayer : TileMapLayer)
        region -> lunar_test_region.tres : TerrainRegion
    Entities (existing Y-sort roots: Players, NPCs, Buildings, Props)
  CameraRig -> Camera2D (static display only)
  UI -> DevelopmentScreen (small development heading/footer)
```

- `TerrainRegion` is texture/camera/node independent. It describes region origin, size, and optional authored `Vector2i -> terrain kind` data. Empty data requests the deterministic lunar test fixture; nonempty data is an explicit sparse authored region. Validation rejects nonpositive size, out-of-bounds cells, and unsupported kinds. It does not require a fixed map size.
- `TerrainLayer` reads that configuration once at startup, duplicates authored cells or creates the fixture, constructs its TileSet, and populates native cells. `rebuild()` clears/repopulates explicitly; no per-frame work or per-tile nodes. Shared Resources are never mutated during startup. There is no complete persistent-state system yet.
- `PlaceholderTerrain` creates four temporary native-size RGBA ImageTextures in memory and maps stable kind IDs to TileSet source IDs. No PNG asset or audio file is created. Each source is a 64 x 32, one-tile atlas, with center alignment and zero extra texture-origin offset.
- `IsometricGrid` separates pure coordinate math from native layer world-coordinate adapters. No camera, input, player, or mode implementation is required for the world to initialize.

## Coordinates and tile alignment

Logical cells use `Vector2i(column, row)`. Increasing column moves down-right and increasing row moves down-left. Centers are `x = (column - row) * 32`, `y = (column + row) * 16`. Fractional inverse is `column = x/64 + y/32`, `row = y/32 - x/64`. Pure `position_to_tile()` applies `floor(component + 0.5)` to choose a discrete cell, including negatives, with exact-half ties assigned to the higher index. All inputs must be finite positions within useful floating-point precision.

Native TileSet configuration is **Isometric / Diamond Down / horizontal offset axis / 64 x 32**. Godot's raw `map_to_local(0, 0)` is `(32, 16)`. Ground alone is offset `(-32, -16)` under identity World/Terrain transforms, so grid `(0, 0)` centers at world `(0, 0)`. This preserves the already established origin rule rather than adding a new convention.

`tile_to_position()` returns a grid-basis center. `tile_to_world(cell, layer)` returns `layer.to_global(layer.map_to_local(cell))`; `world_to_tile(world_position, layer)` uses `layer.local_to_map(layer.to_local(world_position))`. Use these native adapters for actual terrain picking, including exact edges. Godot's edge tie policy is authoritative for terrain and may differ from pure half-open rounding; no epsilon is added to bias native picking. Tests cover stable edge selection and transformed parents. Convert camera/window input to world coordinates before these calls.

`neighbors()` returns four edge-sharing neighbors in +column, +row, -column, -row order. These are grid axes, not the eight screen-facing character directions. Negative cells are supported; conceptual and native round trips are tested for every cell from -20 through +20 on both axes.

## Lunar fixture and presentation

The default region is **12 x 12 = 144 tiles**, origin `(-6, -6)`, covering both axes from -6 to +5. The suggestion of approximately 20 x 20 would span 1280 pixels horizontally, exceeding the locked 960-pixel viewport at native scale. The chosen smaller configurable fixture spans **768 x 384 pixels**, keeping the entire map visible without fractional sprite/camera scale or a standards exception.

Variant assignment uses a deterministic integer pattern, three gray regolith tones, and a small dust patch. Each image fills a pixel-center-sampled diamond, with a subtle darker edge and sparse deterministic speckles. These are strictly temporary development graphics. The static camera is at `(0, -16)`, the fixture's visual center, with unit zoom and no controller/smoothing. World origin remains unchanged. The heading/footer never covers the terrain; hide them with `show_development_screen` in the existing development Resource. No mouse picking overlay or gameplay input handler was added.

Ground stays below entities. Existing Y-sort containers retain zero offsets, unit scale, and equal Z; future actor/building roots must use foot/ground anchors. Full tall-object occlusion is deferred. Additional ground/decorative TileMapLayer scenes can use the same basis; obstacles, buildings, interactions, elevation, navigation, and pathfinding need their own approved data/rendering policies later.

## Replacing the placeholder graphics later

After explicit asset authorization, import approved transparent **64 x 32 PNGs** with lossless compression, no mipmaps or rescaling, nearest filtering, and the documented center anchor. Assign four textures to Ground's `replacement_textures`, in regolith/light regolith/dark regolith/dust patch order. Renderer and coordinate code need no changes. The factory validates list length and exact dimensions, reports incompatible inputs, and never crops/resizes artwork. The same approved texture may be assigned to multiple variants if appropriate. Keep normal provenance/metadata and approvals; no final lunar assets are supplied here.

## Performance and future size limits

There is one native TileMapLayer for all 144 cells, four small textures/sources, and no per-tile node, terrain process callback, autoload, or update signal. Generation and rebuild are explicit O(number of cells), appropriate for this small fixture. Each layer currently owns its TileSet/textures; measure and share resources deliberately if many layers/regions are introduced.

Region size/origin and optional sparse authored data are configurable independently of rendering. Rendering data is a copied logical dictionary rather than authoritative scene-tree state; future save data should version region IDs, stable kind IDs, and logical cell changes. Streaming, chunk loading, infinite terrain, and complex generation are not implemented. Before very large maps, assess native layer coordinate/storage limits and Vector2 precision; prefer region-local rendering and explicit global region IDs. A larger configured region will need separate camera framing in a future approved camera phase, not fractional scaling of its tiles.

## Files

Created:

- `scripts/world/isometric_grid.gd`
- `scripts/world/terrain_region.gd`
- `scripts/world/placeholder_terrain.gd`
- `scripts/world/terrain_layer.gd`
- `resources/data/lunar_test_region.tres`
- `scenes/world/terrain_layer.tscn`
- `tests/isometric_world_test.gd`
- `docs/phase_0_2_report.md`
- Godot-generated `.gd.uid` sidecars for the four new scripts and new test; retain these with source.

Modified:

- `scenes/world/world.tscn`: instance Ground under existing Terrain.
- `scenes/main.tscn`: static fixture camera position.
- `scenes/ui/development_screen.tscn`: replace the large central card with a nonblocking heading/footer.
- `scripts/core/main.gd`: Phase 0.2 startup log text.
- `tests/validate.ps1`: run world tests and report the current phase; all existing checks retained.
- `AGENTS.md`: record explicitly authorized Phase 0.2 scope without changing art rules.
- `README.md`, `docs/architecture.md`, `docs/isometric_standards.md`: current world architecture, APIs, conventions, and run instructions.
- `resources/data/README.md`, `assets/terrain/README.md`: terrain configuration and future texture replacement contracts.

No project rendering/resolution/input settings were changed. Existing foundation tests remain intact and automatically inspect the expanded world hierarchy/resources. Ignored Godot cache, logs, profile, and screenshot are local validation output.

## Actual validation results

Executed `./tests/validate.ps1 -IncludeRendering` using **4.7.2.stable.official.ed1daf0bf**. The runner isolates editor/user data under `tests/output/profile/`; Windows certificate-store access is needed in this restricted environment. Logs stay under `tests/output/`. No movie/audio recording is used.

| Validation | Result |
| --- | --- |
| Both existing JSON files | Valid syntax |
| Headless editor import | Passed |
| Eight GDScript check-only parses | Passed |
| Foundation headless integration | 169 checks passed |
| Isometric world integration | 33,961 checks passed |
| Main scene headless startup | Passed |
| Graphical editor, OpenGL Compatibility | Passed |
| Graphical main-scene integration/capture | 170 checks passed |
| Fullscreen main startup | Passed |
| Visual QA of 960 x 540 capture | Entire map centered, sharp, visible boundaries, no clipping |
| Production scan/native hierarchy | No obsolete spatial architecture or audio nodes |

World tests verify positive/negative cell centers, inverse math, interior points, round trips, native basis/origin, repeatable exact-edge selection, transformed parent coordinates, reciprocal neighbors, edge displacement, independent world initialization, deterministic kind data, data/render agreement, authored sparse regions, resource isolation, dimension changes, validation failures, idempotent rebuild, native unmipped textures, and replacement texture identity without resizing. Raster coverage verifies every pixel-center sample across the default region's bounding box is covered exactly once inside the logical region and never outside: **zero gaps and zero overlaps**.

Final errors: **0**. Final warnings: **0**. The current screenshot is `tests/output/foundation.png`. Release export, arbitrary monitor/DPI configurations, large-map performance, and final imported PixelLab art are not validated by this phase.

## Manual checks and Phase 0.3 recommendations

1. Open the project in Godot 4.7.2, run F5 (or F6 on `scenes/main.tscn`). Expect the complete gray diamond region, subtle variations, a dust patch, and small English heading/footer.
2. Confirm tiles meet along clean stair-stepped diamond edges; the origin cell is within the negative/positive coordinate region. No character, moving camera, interaction, construction, survival, companion, audio, or multiplayer behavior should occur.
3. Resize a standalone window or launch with `--fullscreen`; check sharp integer-scaled pixels and letterboxing. The minimum remains 960 x 540.
4. Disable `show_development_screen` and rerun: heading/footer should disappear while terrain remains. Re-enable for development as desired.
5. Run `./tests/validate.ps1 -IncludeRendering` to reproduce import, syntax, data/coordinate tests, screenshot, and startup checks. The reusable world scene can also run independently, without Main's framing camera/UI.

For the next explicitly assigned phase, preserve this grid basis and native picking adapters. Introduce a placeholder actor at its foot anchor only if that phase requests it; verify draw ordering and pixel motion before gameplay cameras. Define future terrain collision/navigation/elevation and persistent state contracts from concrete gameplay needs. Keep the Moon-first priority and obtain explicit authorization before any PixelLab generation. Phase 0.3 has not begun.
