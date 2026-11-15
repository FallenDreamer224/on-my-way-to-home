# Phase 0.8B - NASA-Informed Lunar Tutorial Map

## Region and scope

The production world now uses `resources/data/lunar_tutorial_region.tres`: **40 columns x 40 rows, 1,600 logical cells**, origin **(-20, -20)** and inclusive cell range **(-20, -20) through (19, 19)**. Native 64x32 diamonds cover a world-space bounding rectangle **(-1280, -656), size (2560, 1280) pixels**. This is a fictional, compact tutorial site, not a reconstruction of a surveyed lunar landing site. Pixels and tile counts do not establish real-world meters or engineering clearance certification.

The astronaut still spawns at (0, 0), Chiwis at (0, 1). All four original pickup positions, stable IDs, Resources and quantities are unchanged. Player/Base Management modes, inventory and modal input, actor graphics/animation, physics speeds, nearest filtering and 960x540 logical resolution remain intact. No building services, construction, missions, survival, radiation, thermal, solar-output or resource-production simulation is introduced.

## Authored areas

Rectangles use (column, row), with inclusive origin and exclusive end. Reservations are clear planning areas rather than installed, occupied structures. Lightweight world labels and outlines identify them; they do not receive gameplay input or create obstacles. Remove `World/SiteLayout` to remove these development annotations.

| Area | Origin | Size in cells | Intent |
| --- | --- | --- | --- |
| Landing and unloading | (-4, -4) | 8x7 | Arrival and unloading clearance, surrounding preserved spawn/pickups |
| Habitat | (-12, -4) | 6x7 | Future pressurized habitat/airlock placement budget |
| Exterior utilities | (-12, 5) | 6x4 | Future atmosphere/water/power support equipment |
| Solar power | (-11, -14) | 9x5 | Separated array planning area; illumination is only an assumption |
| Equipment and cargo storage | (5, -4) | 5x7 | Storage and equipment staging |
| Rover parking and maintenance | (5, -13) | 8x6 | Reserved future mobility/servicing space |
| Greenhouse reservation | (-3, 7) | 7x6 | Reserved crop-research installation, no active food production |
| Western sampling site | (-16, 10) | 5x5 | Exploration/sampling reservation, no new collectible or mission |
| Eastern sampling site | (10, 8) | 5x5 | Second connected sampling reservation |

Three-cell-wide service corridors connect the spawn area to every zone using grid-edge adjacency. Broad deterministic spatial fields produce geographically clustered light/dark regolith, rather than random single-cell noise. The existing seam-fixed Moon atlas supplies all ground pixels and its three variants per stable terrain kind. Light terrain marks prepared planning areas/corridors; dark patches represent rougher regolith. No source PNG, TileSet, import provenance or atlas coordinates become gameplay terrain data.

Two small crater features have centers **(14, -4)** and **(-3, 16)** with logical radii **3** and **2** cells. Their cores are blocked, dusty interiors and dark rims remain rendered, and service routes avoid their centers. They are flat 2D terrain markings with categorical difficulty, not a height mesh, measured slope or physically modeled impact profile. The one-cell outer ring is a visible dark restricted perimeter; missing cells beyond the region also block travel.

## Environmental data and integration

`SurfaceCellData` defines terrain kind, qualitative difficulty (flat/uneven/crater rim), walkability, dust tendency (low/moderate/high), sunlight exposure (unsurveyed/open sky assumed), extensible hazard bits, an occupant ID and a reservation ID. `LunarTutorialRegion.surface_at(cell, kind)` supplies these descriptors for generated cells. All occupant IDs are empty in this phase. A future multi-cell object's footprint can share its owner ID across explicit occupied cells; reservation rectangles must not be mistaken for occupied or pressurized volumes.

Descriptors are game scenario assumptions, not NASA measurements, health multipliers, dust mass, slope degrees or verified solar irradiance. Only walkability affects movement now; roughness and dust do not change existing speeds. Sunlight does not generate energy and hazards do not apply damage. Future occupancy mutation/placement and environmental simulation require a separately authorized system.

`TerrainRegion.create_cells()` now provides the general authored/generated entry point. The legacy 12x12 Resource and its generator remain available as a focused mathematical/raster fixture. Production uses `LunarTutorialRegion`, while the isolated isometric regression explicitly loads the old fixture. Production assertions now derive cell counts from the declared region rather than 144/12x12 assumptions.

`TerrainLayer` renders all 1,600 cells once through its existing native TileMapLayer. It caches blocked cells during rebuild, keeping walkability queries constant-time without allocating environmental Resources during foot sweeps. `TerrainWalkability` and `TerrainRoutePlanner` both use that policy, including existing missing-cell and complete-foot checks. Rebuild after changing region policy; no live construction or occupancy editor is implemented. The existing 2,048-node route budget exceeds this region's total cell count and is unchanged.

Both camera rigs receive the measured `TerrainLayer.world_rect()` at composition time and retain their existing controls, zoom and handoff interfaces. These are viewport-aware rectangular bounds around a diamond-shaped map: empty corner space can still be visible, especially near the perimeter. Camera clamping is not a terrain collision boundary. The native-size whole-region capture uses a test-only SubViewport; game resolution/zoom rules are unchanged.

## Scientific basis and abstractions

Consulted the Science Bible, scientific gameplay rules and technology catalog. Relevant research IDs are **NASA-ENV-MOON**, **NASA-HAB-MOONBASE**, **NASA-AIRLOCK-QUEST**, **NASA-POWER-SOLAR**, **NASA-PLANT-VEGGIE**, **NASA-SCIENCE-LOG**, **NASA-SAMPLE-PROVENANCE** and **NASA-ROVER-LTV**. The existing registry remains the source of official URLs, maturity and test environments; no scientific status or readiness ratings were changed.

Accepted context: lunar terrain, localized geological observations, pressure-protected habitation needs, power/thermal dependencies and the distinction between crop research and a self-sufficient food system. Design abstractions: compact separation distances, categorical rough/dust descriptors, generous connected routes and future installation budgets. No uniform mineable ice, engineered shielding, operational NASA Moon base, guaranteed sunlight or full lunar oxygen factory is claimed. One human and Chiwis remain present; T and Mars remain outside this map.

## Files created or modified

Created `scripts/world/lunar_tutorial_region.gd`, `scripts/world/surface_cell_data.gd`, `scripts/world/lunar_site_layout.gd`, their Godot UID companions, `resources/data/lunar_tutorial_region.tres`, `tests/lunar_tutorial_test.gd` (and UID) and this report.

Modified `scripts/world/terrain_region.gd`, `terrain_layer.gd`, `terrain_walkability.gd`, `scripts/companions/terrain_route_planner.gd`, `scripts/core/main.gd`, `scenes/world/world.tscn`, `AGENTS.md`, and `tests/validate.ps1`. Updated map-count/generator assertions in `astronaut_test.gd`, `chiwis_test.gd`, `gameplay_modes_test.gd`, `interaction_inventory_test.gd`, `moon_terrain_test.gd`, `player_camera_test.gd`, `ui_foundation_test.gd`; `isometric_world_test.gd` explicitly retains the old fixture. Existing test behaviors and assertions beyond the changed map contract remain in place.

## Validation and review

Run `./tests/validate.ps1 -IncludeRendering` using the configured **Godot 4.7.2.stable.official.ed1daf0bf**. Profiles and logs stay under `tests/output`. Sandbox-only attempts encountered Windows certificate-store access errors; the final run uses the existing isolated-profile runner with certificate access permitted. Those environment failures are distinct from project script errors.

Final validation completed successfully with **0 engine errors and 0 engine warnings**. Evidence artifacts are `tests/output/phase_0_8B_validation.log`, `lunar_tutorial_summary.json`, `lunar_tutorial_management.png`, `lunar_tutorial_full_region.png` and the existing suite captures. The final annotation-only overview adjustment was additionally rerun through the graphical map acceptance test (`lunar_tutorial_final_capture.log`): 9,261 checks passed. Generated validation outputs remain ignored by version control.

| Validation | Result |
| --- | --- |
| Editor import and script syntax checks | Passed in Godot 4.7.2 |
| Existing headless suites | Foundation, isometric math/fixture, Moon raster, player camera, modes, astronaut, Pixelorama assets, run animations, Chiwis, inventory, interactions, prop assets/integration and UI all passed |
| New map acceptance | 9,261 checks passed headless and graphically |
| Complete-region topology | 1,402 walkable cells, all connected to spawn; 198 blocked cells including 156 perimeter cells and 42 crater-core cells |
| Ground kind counts | 469 regolith, 646 light regolith, 443 dark regolith, 42 dust cells; all four stable IDs retained |
| Native rendered ground raster | All 1,600 cells checked; zero gaps, overlaps or pixels outside the declared footprint |
| Navigation and full-foot clearance | All nine zone centers reachable by Chiwis; swept segments also accepted by astronaut footprint; crater requires and admits a real detour |
| Cameras and gameplay | Derived bounds, mode handoffs, movement, inventory/partial pickups, prompts and modal input regression checks passed |
| Graphical/fullscreen checks | Editor, main scene, terrain, modes, actor, Chiwis, run animations, interactions, props and UI passed; fullscreen checks passed |
| Visual inspection | Inspected 960x540 management capture and 2560x1280 native terrain/site overview; alignment and labels verified; overview has no actors/HUD by design |
| Scientific reference consistency | Registry/document checker passed with 0 errors; the existing eight research evidence warning lines remain unchanged and separate from engine warnings |

Warning context: initial sandbox editor attempts failed on certificate-store access (and the first direct invocation could not create default editor/profile paths). No successful project validation is claimed for those attempts; the subsequent isolated-profile runs passed. No Windows trust settings or project renderer settings were changed.

Manual review steps:

1. Launch the main scene at 960x540; inspect native terrain, astronaut, Chiwis and nearby unchanged pickups.
2. Collect with E; open/close inventory with I; confirm quantities, partial acceptance and modal movement blocking.
3. Walk between reservations, around crater cores and toward the perimeter. Confirm Chiwis can follow clear routes and detour without crossing blocked cells.
4. Switch with Tab, pan and zoom in Base Management Mode, inspect the nine site areas and confirm camera clamping; return to Player Mode with the same inventory and world state.
5. Toggle fullscreen using the existing action; check the HUD, labels and nearest-filtered ground remain readable. Review the whole-region capture for geographical layout, rather than expecting the entire map to fit the 960x540 view at 1x.

No audio, new artwork generation, PixelLab use, Mars map, commits or Phase 0.8C work is included.
