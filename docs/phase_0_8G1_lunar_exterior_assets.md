# Phase 0.8G1 — Lunar exterior assets and production pipeline

Date: 2026-11-15. Result: **COMPLETE WITH LIMITATIONS**.

Prepared a reusable native 2D exterior library without rebuilding the Moon map: **41 prefab scenes, 41 metadata Resources, four new accepted sprites, an eight-bay preview and a reproducible measurement/build/audit workflow**. Main-world placement remains Phase 0.9 work. Pressure-passage art, open-hatch animation and continuous cables remain noncritical gaps. Phase 0.8G2 was not started.

## Preservation and inspection

- Remained on `dev/phase-0.8f-ui-overhaul`, HEAD `b4f00e10384fdde97423ba90fa7481dbbee03e1d`. Existing uncommitted Phase F work was retained.
- `Alpha` remains `2942b0502d1a53a78651044319bbd86392497198`. No commit, push, reset, tag change, export or publication was performed.
- Reviewed Phase F completion/inventory, AGENTS, README, Art Bible/JSON, isometric/intake rules, habitat layout/report, Science Bible/gameplay rules, import records and native artwork. No `CLAUDE.md` exists.
- Read all **64 external original files**, including 27 terrain PNGs and 35 PXO authoring files. The directory contains character/run/walk sources and Moon terrain, not an undiscovered greenhouse/radiator pack. Nothing outside the project was written.
- Reviewed the existing PixelLab gallery's 94 image records and eight object records before submitting new artwork. Relevant completed world assets corresponded to the existing Packs B–E; unrelated gallery art was left alone.
- A baseline recorded **807 existing project files**. After preparation, only three inherited files changed: AGENTS.md, ASSET_INVENTORY.md and the validator entry list. All existing code, scenes, settings, art/font binaries, source manifests and scientific registry remained byte-identical to the G1 baseline. All 64 external originals also remained byte-identical.
- The production region remains 40×40, origin (-20,-20), with native 64×32 tiles, twelve visual atlas variants and unchanged logical terrain/walkability. Normal startup remains the Phase F AppRoot menu, at 960×540 nearest/integer presentation.

Private preservation evidence is in `tests/output/phase_0_8g1/baseline.json` and `preservation.json`.

## Existing assets reused

The 24 existing objects comprise ten Base Pack C assets, ten Props Pack B assets and four Lander Pack D assets. Thirteen existing Terrain Pack E components are also prepared as native ground/decorative prefabs. The technical Pack E atlas and main regolith atlas are preserved, not counted as additional object prefabs.

| Requirement group | Prepared coverage |
| --- | --- |
| Habitat / research / engineering / shelter | Existing habitat shell can be reused for module roles; existing airlock provides closed pressure doors. Final module count/connections are not specified by this gallery. The nine-room cutaway remains an abstraction, not a blueprint for one small exterior sprite. |
| Greenhouse | New closed glazed research module with visible muted plant trays, native crew-scale hatch and measured ground origin. Fictional exterior, not flight-qualified hardware. |
| Power | Existing solar array/supports, battery unit, connector/junction box and control console. |
| Utilities | Existing tank/console plus new sealed ECLSS service cabinet and pale radiator bank; no equipment ratings or new resource simulation. |
| Communications | Existing antenna/dish and console, with future access/service points. |
| Lander / cargo | Existing lander, separate ramp, landing decal, cargo pod, crate/cases/canister. Lander identity and pixels remain unchanged. |
| Scientific field work | New tripod sensor with existing instrument cases, sample and canister; shared console supports a future monitoring/analysis role. No sampling procedure or measurement mechanics added. |
| Safety / paths / floors | Existing beacon, pole light, worn path, marked pad, hazard stripe, base floor/edges and terrain overlays. Labels remain Godot text, not baked into art. |

[ASSET_INVENTORY.md](ASSET_INVENTORY.md) lists every prepared asset's category, source/runtime paths, native size, footprint, pivot, collision need, status, origin and readiness. [exterior_source_audit.json](../art/imports/exterior_source_audit.json) classifies 162 relevant project/external files: 118 READY, 43 UNUSED and one NEEDS_REFINEMENT, with 43 hash-identical groups explicitly marked DUPLICATE_CANDIDATE. No unused or duplicate file was deleted. NEEDS_INTEGRATION/MISSING concept gaps are recorded separately in the library coverage table.

## New artwork and cost

PixelLab authentication succeeded through read-only `get_balance` before production. Four single-candidate jobs were proposed at approximately 22 subscription generations. A native-scale review rejected the first greenhouse, leading to one documented one-generation replacement rather than local pixel enlargement.

| Accepted sprite | Native canvas | Visible bounds (x,y,w,h) | Measured ground anchor | Footprint |
| --- | --- | --- | --- | --- |
| Greenhouse module | 192×192 | (16,27,160,141) | (92,168) | 3×2 |
| Radiator bank | 128×128 | (21,23,85,80) | (62,103) | 2×1 |
| ECLSS service cabinet | 96×96 | (13,17,65,62) | (51,79) | 1×1 |
| Field sensor tripod | 96×96 | (24,20,39,62) | (43,82) | 1×1 |

All four have binary alpha, transparent padding and one static isometric view. The accepted greenhouse visually matches the existing habitat's human pixel density. The first greenhouse's 92×82 visible object/undersized hatch failed the intended module scale; it remains unchanged in the source archive and is not integrated. No original or generated PNG was resized, stretched, cropped, recolored or erased locally.

**Actual cost: 23 subscription generations, USD credit spend $0.00.** Balance moved from 3786.15 to 3763.15. Pro Flash charged 6+6+5+5, and the Pixen replacement charged 1. Five jobs produced four selected assets and one retained rejected candidate. No dozens-of-candidates batches, repeated speculative variants or replacements of suitable existing assets were requested.

Requests, seeds, receipts, IDs, selections and rejected-candidate reason are retained under `assets/pixellab/source/exterior_g1/`. [exterior_g1.json](../art/imports/exterior_g1.json) records the accepted source/runtime paths, sizes, hashes, prompts and pivots. Full native PNGs were copied unchanged into `assets/buildings/exterior_g1/`. Import settings are lossless, mipmaps off, no rescaling and alpha-border rewriting off.

Scientific design references are the existing NASA-HAB-MOONBASE, NASA-GAS-CONTROL, NASA-PLANT-VEGGIE, NASA-PLANT-APH, NASA-THERMAL-LOOPS and NASA-SCIENCE-LOG records. They inform fictional function/silhouette only. No status, TRL, pressure, power rating, crop output, radiator performance or claim of deployed NASA lunar infrastructure was invented. The research registry was not expanded or revised.

## Reusable scene and metadata contract

Each asset has a script-free native Node2D prefab under `scenes/exterior/`, backed by an ExteriorAssetDefinition under `resources/exterior/`. These generated files preserve full texture canvases. The shared Resource stores identity, texture/bounds, front ground pivot, logical footprint/cells, grid origin, collision polygon, navigation reservation cells, access/service points and provenance. It defines no simulation.

```text
Exterior object (Node2D; same Y-sort/Z policy as actors)
  Sprite2D (native size; centered=false; offset=-measured anchor)
  GroundPivot (Marker2D; zero)
  GridOrigin (Marker2D; reference cell center offset)
  InteractionAnchor / ServiceAnchor (Marker2D; outside blocking geometry)
  Body / CollisionPolygon2D (22 solid assets only)
  StateIndicator (15 equipment assets only; hidden until explicitly bound)
```

- GridOrigin is placed on the native TileMapLayer grid; the padded canvas and front contact vertex are not mistaken for a cell center. The preview tests this for every instance.
- Logical footprint polygons retain the established design budgets. Solid collision adds **half a grid cell of ground-hardware clearance**, which covers untraced landing/support hardware rather than pretending to be an exact pixel silhouette. Future navigation must reserve `navigation_reserved_cells`, including the intersected outer cell ring. Production placement still needs neighbor/approach checks for both characters.
- Access/service markers sit outside the envelope. They are not active Interactables, doors, inventory registries or terminals. Optional IDs name possible future bindings without creating another utility manager.
- The status adapter reads existing UtilityEquipment flags into four static service-marker colors: operational, disabled, damaged, maintenance. It never changes equipment flags/resources, blinks, recolors source art or simulates damage. Markers are opt-in; library objects do not display fabricated powered state by default.
- Ground/decal sprites render below actors. Object pivots share the actor Y-sort parent and native scale. The gallery demonstrates the astronaut behind a shell and Chiwis in front. Fine leg/underbody passage and split-roof occlusion remain future integration choices; the current envelope prevents treating the whole transparent canvas as a collider.
- Existing ramp attachment metadata is retained. The ramp is displayed separately for inspection, not falsely presented as completed boarding or airlock hardware.

## Production tools and preview

New tools under `tools/exterior/` measure decoded PNG bounds/alpha/hashes, reproducibly build prefabs, audit project/external sources and update the marked exterior inventory section. They never alter original PNGs. Measurement tables and source classifications are versioned in `art/imports/`. Commands and geometry semantics are documented in [tools/exterior/README.md](../tools/exterior/README.md).

Run **`scenes/development/lunar_exterior_preview.tscn` with F6**. Keys 1–8 select Habitat, Power, Lander, Science, Props, Safety, Sorting and States; G toggles guides. White = measured pivot, green = logical footprint, terracotta = clearance collision, cyan = access, amber = service. Original character sprites are repeated only as gallery scale references, not new gameplay actors.

The preview reuses existing TileMapLayer/terrain resources in independent inspection bays. It does not load the production gameplay world, rebuild its map, change the application entry or install scenery into the tutorial. All bay views are 960×540 at native 1×. A separate 1920×2160 viewport captures the complete eight-bay atlas without fractional zoom or downscaling artwork.

## Validation results

Godot: **4.7.2.stable.official.ed1daf0bf**. Rendered checks: OpenGL Compatibility on NVIDIA GeForce RTX 3050 Laptop GPU.

| Executed check | Final result |
| --- | --- |
| New library headless | **662 checks passed** |
| New library graphical/captures | **687 checks passed** |
| New library fullscreen | **662 checks passed** |
| Resource/editor import / UID scan | Exit 0; zero errors, zero warnings |
| Cache-free source copy | Import, editor exit, typed startup and configured application all pass; zero errors/warnings |
| Main class resolution | 23 checks passed |
| Existing sample-to-science demo route | 115 checks passed |
| Astronaut / Chiwis | 234 / 44 checks passed |
| Player camera / camera modes | 49 / 93 checks passed |
| Moon terrain / tutorial | 3250 / 9261 checks passed; terrain remains 1600 cells |
| Inventory / interaction integration | 38 / 95 checks passed |
| Existing UI foundation / Phase F focused | 331 / 170 checks passed |
| Existing Phase F graphical capture | **65 checks passed**; menu, New Game and return flow retained |
| Utility model | 922 conservation/failure checks passed |
| Existing Packs C/D/E | All exact native/hash/anchor tests pass; 3778 terrain-expansion checks |
| New image measurement | 43 runtime images measured; four accepted new PNGs have no partial alpha |
| Preservation | All 64 external originals and all inherited gameplay/art/configuration files unchanged; only documentation/instructions and validator list extended |

The new suite checks resource validity, native texture/pivot/filtering, source/imported RGBA equality, absent mipmaps, script-free prefab roots, real Physics2D ground hits, access-point clearance, navigation reservations, read-only state mapping, shared Y-sort parenting and exact reference-cell alignment. These tests do not assert that full-world placement or new equipment interactions are implemented.

Nine final images were generated and inspected: `habitat.png`, `power.png`, `lander.png`, `science.png`, `props.png`, `safety.png`, `sorting.png`, `states.png`, and `full_showcase.png`, under `tests/output/phase_0_8g1/captures/`. Corrected an isolated-preview ground-Z error that initially hid guide/decal layers, and adjusted crowded labels/ramp/reference positions. Existing artwork was not edited to fix preview layout.

During development, an initial test fixture omitted UtilityEquipment's required definition, a serializer edit temporarily replaced a footprint field with collision geometry, and the first raw-image loader emitted export-context warnings. All were corrected and affected checks rerun. Final import, measurement, library and regression runs report no engine errors or warnings. Initial diagnostic logs are retained rather than represented as passed runs. The already-completed Phase F's full 162-step workflow was not needlessly repeated; its high-value affected regression areas were executed here.

Logs, baseline/preservation hashes and result summaries are under ignored `tests/output/phase_0_8g1/`. No unexecuted check is counted as successful.

## Files created or updated

- Four runtime PNGs and matching imports under `assets/buildings/exterior_g1/`; five original candidate PNGs and request/receipt records under `assets/pixellab/source/exterior_g1/`.
- `art/imports/exterior_g1.json`, `exterior_measurements.json`, `lunar_exterior_library.json`, `exterior_source_audit.json`.
- 41 `.tres` Resources under `resources/exterior/` and 41 `.tscn` prefabs under `scenes/exterior/`.
- `scripts/world/exterior_asset_definition.gd`, `exterior_state_indicator.gd`, `scripts/development/exterior_guides.gd`, `lunar_exterior_preview.gd`, and generated script UID sidecars.
- `scenes/development/lunar_exterior_preview.tscn`.
- `tools/exterior/measure_images.gd`, `build_library.mjs`, `audit_sources.mjs`, `update_inventory.mjs`, `image_paths.json`, README and tool UID sidecar.
- `tests/lunar_exterior_library_test.gd` and UID; two new entries in the existing `tests/validate.ps1` workflow.
- Updated `docs/ASSET_INVENTORY.md`, this report, and additive current-phase AGENTS instructions. Prior Phase F work remains intact.

## Remaining gaps and readiness

**Ready for review and a separately authorized Phase 0.8G2.** The native exterior library, metadata, preview and validation pipeline are operational. Noncritical gaps are explicit:

1. No separate pressurized passage/tube, open-hatch variant or hatch animation. Closed doors are embedded in existing shells. A utility box is not substituted for a pressure corridor.
2. No continuous cable runs/support sprites or unique pallet image. Junctions and cargo reuse existing suitable assets.
3. The main habitat shell can serve several module roles, but final exterior module count, greenhouse placement, emergency access, room-to-shell correspondence and complete lander/ramp arrangement remain Phase 0.9 decisions.
4. Single supplied facings are retained; no interpolated rotation or fabricated additional direction is used. Native collider envelopes and navigation clearance require placement review before enabling production occupancy/routing. Fine roof/leg splitting and underbody traversal are not implemented.
5. New artwork is fictional near-future hardware, not a pressure/thermal/radiation engineering design or a claim of NASA deployment. Font/provider/original-art licensing records remain intact; public redistribution decisions are separate from local asset preparation.

No interior production, new simulation, new companion, other planetary gameplay, audio, protected-demo change, commit or publication was performed. Phase 0.8G2 and Phase 0.9 were not started.
