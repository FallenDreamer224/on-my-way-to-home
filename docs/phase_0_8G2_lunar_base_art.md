# Phase 0.8G2 — Lunar base exterior, interiors and greenhouse art

Snapshot: November 15, 2026. Godot 4.7.2.stable.official.ed1daf0bf; native 2D, 64×32 isometric ground, 960×540 logical viewport, nearest sampling and native 1× sprites. This report covers the extended assignment following the earlier furnished-interior milestone.

## A. Development result

**COMPLETE WITH LIMITATIONS.** A modular illustrated outpost, transparent complete-base image, terrain showcase, nine furnished navigable rooms and reusable structural/equipment PNGs are delivered. The exterior entrance reaches the prepared interiors through the existing airlock with the same astronaut, Chiwis and inventory. These are isolated preparation scenes; the production Moon map and startup are preserved.

There are **51 unique new finished PNG components**: 18 accepted PixelLab images and 33 original structural components. They are distinct from source mirrors, discarded candidates, drafts, composition exports and previously accepted art. Interior preparation now contains **34 prop scenes/Resources**, nine room scenes and twelve construction/floor module scenes. Exterior preparation adds fifteen asset scenes/Resources and the modular assembly scene.

Final normal-world placement, exact sealing/collar correspondence at every illustrated pressure socket, alternate connection/furniture facings and secondary detailed accessories remain. The base is fictional future lunar architecture; conservative grid envelopes do not certify physical interior volume, pressure performance, radiation shielding or NASA deployment. No new simulation, gameplay manager, character, audio, export, commit or subsequent phase was added.

## B. Exterior base

### Delivered images and modular scene

- [Complete transparent base](../assets/buildings/base_g2/compositions/lunar_base_complete.png), 2688×1536, native 1×.
- [Terrain showcase with astronaut and Chiwis](../assets/buildings/base_g2/compositions/lunar_base_showcase.png), 2688×1536, native 1×.
- [Modular assembly scene](../scenes/exterior/base_g2/lunar_base_assembly.tscn).
- [Playable exterior inspection scene](../scenes/development/lunar_base_preview.tscn).
- [Explicit spatial plan](../resources/data/lunar_base_art_layout.json) and [native exterior definitions](../art/imports/lunar_base_art_library.json).

Compositions are rendered by a separate native-resolution SubViewport, without resampling or changing project resolution. Their folder is excluded from runtime asset scanning. They are presentation deliverables, not a replacement for separate sprites, bodies, pivots, entrances and interactions.

### Exterior/interior correspondence

The copied logical surface is **40×40**, origin (-20,-20), with all 1,600 original terrain-kind entries retained. The plan defines nine pressure envelopes, eight connection routes and 31 corridor cells. It preserves room IDs and sizes including boundary cells; furniture occupies explicit additional cells. Envelopes are game placement budgets separate from canvas extents, overhang and real engineering dimensions.

| Module / room | Origin (i,j) | Grid envelope | Native shell source |
| --- | --- | --- | --- |
| Crew airlock | -13,-10 | 8×7 | `shell_service`, 512×368 |
| Equipment lock | -13,-2 | 8×7 | `shell_service`, 512×368 |
| Central hub | -4,-2 | 8×9 | `shell_core`, 576×384 |
| Living | -4,8 | 8×8 | `shell_habitat`, 544×384 |
| Engineering | -13,8 | 8×8 | `shell_habitat`, 544×384 |
| Health/science | 5,-2 | 8×8 | `shell_habitat`, 544×384 |
| Greenhouse | 5,-10 | 8×7 | `shell_greenhouse`, 512×400 |
| Cargo/workshop | 5,7 | 8×7 | `shell_service`, 512×368 |
| Emergency shelter | 14,-2 | 6×6 | `shell_shelter`, 416×320 |

Five unique new shell PNGs serve nine module roles. Fifteen original G1/Pack B/C/D images are reused in the assembly: twelve equipment/lander/cargo objects and three small facade bays. The existing habitat, airlock and greenhouse sprites remain native attached bays; they are not enlarged or described as containers for oversized rooms. Lander, solar panels, battery, radiator, oxygen tank, antenna, storage, tool case, beacon and sensor source files remain unchanged.

### Passages, hatches and utilities

Six separate native exterior images are available: two straight pressure-passage orientations, an elbow, a four-way junction, and the open/closed hatch pair. Hatches are both 64×96 with identical visible bounds (5,18,54,61) and measured ground anchor (31,79); scene placement adds the shared mounting offset. The existing HabitatDirector airlock owns their state. Static shell service ports are artwork, not additional interactive vacuum doors.

Pressure links use individual rounded PNG sprites at unit scale. Route cells are sorted before pairing, fixing an insertion-order bug that turned reverse-directed links into repeated junctions. The 64×32 TileMapLayer/atlas geometry remains a hidden technical alignment guide. No image is rotated, mirrored, stretched or trimmed to invent another facing. The single supplied elbow facing and sealed/junction interfaces are reusable; additional elbow/end-cap facings and exact collar sealing at all shell ports remain refinement work.

Fifteen connected cable-mask PNGs provide endpoints, straight runs, corners and junctions. A separate vertical conduit PNG is available. The outdoor service trunk visually links the prepared power equipment; it does not create electrical throughput or replace UtilityService. Gear remains individually inspectable/reusable.

### Visibility and source recovery

Initial original full-hull drafts failed visual review and were superseded by the illustrated shells. All 35 draft PNGs remain: nine full hulls, nine roof copies, sixteen technical passage cells and one atlas. Seven of the forty structural files support those unused drafts; none is counted as finished art.

Large provider images arrived with opaque colored backgrounds. Ten provider background-removal results erased building surfaces and were rejected. Local alpha preparation operates only on separate new outputs: flood connected red/purple background, retain the largest subject component, preserve canvas dimensions and verify every retained RGBA value against the complete raw image. Original opaque PNGs remain intact. The recipe, raw/output hashes and measured anchors are in [native_shells.json](../art/imports/native_shells.json). This is the technical preparation authorized in the extended request's sections 24/27, not a silent modification of older artwork.

Runtime shells share complete textures through 32-pixel depth regions for sorting. ExteriorOcclusionGuard caches alpha bitmaps once and applies a presentation cutaway where an existing actor would otherwise disappear. It changes no sprite source or movement controller. Native entrance captures show both actors; complete art compositions disable that temporary actor cutaway. No per-frame image decoding or image generation is used.

## C. Interior base

Every row below has actual separate object/structural PNGs, a reusable room scene, cell-based collision and navigation validation for both actors. Several functions share a room. The suite walks the existing astronaut to room approaches and uses the existing Chiwis planner; closed thresholds and airlock state are shared by collision and navigation. Decorative equipment does not acquire an invented gameplay function.

| Functional category | Room scene under `scenes/interiors/rooms/` | Actual artwork / state | Collision and navigation | Remaining detail/facing gaps |
| --- | --- | --- | --- | --- |
| Main habitat / circulation | `hub.tscn` | Shared panel floors, wall/window/door PNGs, independent table, seat and console | Validated; approaches and crossings clear | Additional compact shelving and personal decor optional |
| Airlock / EVA preparation | `crew_airlock.tscn`, `equipment_lock.tscn` | Suit/helmet rack, supplies, technical dust/service panel, aligned hatch/door treatments | Validated; exterior→crew→equipment transition uses existing inspection/pressure interlock | More independent helmet/tool/emergency stowage details; additional hatch facings |
| Living / sleeping | `living.tscn` | Bunk with bedding, personal locker, work/table/seating components | Validated; existing sleep anchor accessible | More personal supplies, small shelving and alternate furniture facings |
| Food preparation / dining | `living.tscn` | Separate galley, dispenser and shared dining assets | Validated; galley moved away from doorway; existing activity UI works | Individual packaged-meal/tray accessories beyond baked details |
| Hygiene / sanitation | `living.tscn` | Separate sanitation station, service wall and compact cutaway compartment | Validated; existing hygiene action retained | Dedicated privacy-screen variant and separate cleaning accessories |
| ECLSS / water | `engineering.tscn` | Reused ECLSS cabinet and tank, new filter cartridge assembly, console | Validated; actual existing utility terminal accessible | Individual subsystem facings/maintenance internals; no new equipment simulation |
| Power / engineering | `engineering.tscn` | Battery/power unit, service equipment, floor/cable artwork | Validated; utility state binding retained | Additional wall distribution variants and separate spare-tool details |
| Mission operations | `hub.tscn` | Existing independent work/control console, table, seat | Validated; shared hub circulation remains open | More monitor/shelf variants; no new mission-controller system |
| Medical / exercise | `health_lab.tscn` | Medical chair, new medical storage and reused exercise equipment | Validated; equipment approaches remain reachable | More independent diagnostic/rehabilitation accessories; no clinical effects |
| Research / sampling | `health_lab.tscn` | Separate sample bench and storage/equipment components | Validated; prepared science approach retained at (6,3) | More discrete sample-container variants; no new research process |
| Cargo / workshop | `cargo.tscn` | Independent loaded/empty rack, maintenance bench, tool/equipment cases | Validated; finite cargo service remains authoritative | Additional spare-part sprites and working repair animation |
| Greenhouse | `greenhouse.tscn` | Two tray instances, four plant-stage PNGs, original open supports, new lamps/nutrient/irrigation equipment | Validated; both tray approaches and door clearance | Alternate crop species/facings, optional rack variants |
| Emergency shelter | `shelter.tscn` | Shared control, supplies, reinforced treatment and compact floor plan | Validated; door and safe approach retained | Dedicated shelter-specific stowage/door art; no shielding-performance claim |

Thirty-four prop prefabs comprise 18 previously accepted G2 images, seven new furnishings and nine existing Pack B/C/G1 images. The previous eighteen include four plant overlays; they are not eighteen newly generated furnishings in this extension. Important equipment stays separate from room floors and walls.

Forty original structural PNGs are delivered; **33 unique components are READY**: sixteen wall/window/service/support/cutaway/frame/open/closed treatments across two axes, one corner, fifteen cable masks and one vertical conduit. Seven roof/hull-wall draft supports are UNUSED. Floors reuse three finished Pack E 64×32 images. Twelve construction/floor scenes retain the existing component API. Foreground walls use cutaways; doorway leaves read shared state. Door canvases/origins are stable across open/closed states. Detailed inspection shots show actor visibility behind walls.

The spatial plan applies isolated port overrides, moves one galley placement and retains the prepared health/science approach/partition adjustment. It does not rewrite production `habitat_layout.json`. Existing scenes are reusable prepared rooms; the normal game continues using its prior room factory.

## D. Greenhouse

The delivered greenhouse reuses the two DailyLife trays, empty tray sprite, four accepted plant overlays, monitor and storage art. This extension adds independent overhead lamps, nutrient equipment and irrigation equipment. Open support frames remain original native 2D elements and do not flatten plants into a greenhouse background.

One generic crop, **leafy greens**, is represented. Empty and seeded states use the tray/seed-marker presentation. Four actual overlay PNGs show germinating, small, intermediate and mature plants; all full canvases and measured tray-attachment anchors are preserved. Six states observe the real planted/progress/yield fields. No extra species, wilted plants or crop death state is invented.

Planting, finite seeds, water/nutrients, dispatched lighting/power, pause, progress, harvesting, partial inventory acceptance and yield remain owned by DailyLife/UtilityService. Existing configured 1,800-second game growth and development acceleration are unchanged abstractions, not biological claims. No plant oxygen, free food, new production rate or physiological benefit is asserted.

Scientific design context remains the existing registry records NASA-PLANT-VEGGIE, NASA-PLANT-APH, NASA-AIRLOCK-QUEST and NASA-ANALOG-CHAPEA. Their documented environments/status and limitations are unchanged. This art assignment adds no current NASA research claims or technology-status revisions.

## E. PixelLab and exact asset accounting

| Operation group | Jobs / generations | Accepted result |
| --- | --- | --- |
| Small asset creation/edit/replacements | 15 / 15 | 13 unique images: seven indoor, six exterior |
| Large native shell creation | 5 / 5 | Five unique shells after local source-preserving alpha preparation |
| Provider background removal | 10 / 10 | Zero; all ten masks rejected for deleting vessel surfaces |
| **Extended total** | **30 / 30** | **18 accepted creative images**, two rejected creative candidates, ten rejected preprocessing outputs |

Read-only account balance: **3739.15 → 3709.15**, exactly 30 subscription generations. USD credits spent: **$0.00**. Remaining authorization for this assignment: **0**. No more paid request was submitted after the cap. Previous G2's 24 generations are a separate historical authorization, not counted in these thirty. Original selected assets are reused without regenerating them.

Physical new PNG count is **125**, not 125 new finished drawings: 51 unique accepted component images, 13 byte-identical small-image source mirrors, five complete opaque shell originals, two rejected creative PNGs, ten rejected mask PNGs, 42 preserved technical/draft support PNGs, and two composed presentation PNGs. Five unique shells are reused by nine module prefabs. The source audit retains seventeen intentional duplicate groups; no duplicates or candidates were deleted.

Current complete assets tree: 715 files including imports/READMEs, 407 PNGs (237 prepared/runtime/presentation and 170 source/provenance), three fonts. These filesystem counts include historical packs and rejected/draft files. They do not imply 407 approved gameplay assets.

Canonical records: [generation ledger](../art/imports/base_generation_ledger.json), [small asset intake](../art/imports/base_g2.json), [shell intake](../art/imports/native_shells.json), [structural intake](../art/imports/base_structure.json), [supplemental source audit](../art/imports/base_source_audit.json), and the preserved submission/decision records under `assets/pixellab/source/base_g2/`.

## F. Validation

### Headless and data checks

- Full `tests/validate.ps1 -IncludeRendering`: **185 steps**, split into **160 headless/import/parse steps** and **25 graphical steps**; all passed, zero Godot errors. The final run recorded one graphical-editor shutdown warning, `Scan thread aborted...`; the earlier full run recorded zero warnings. Targeted suites and uncached startup recorded zero warnings.
- Focused graphical-editor rerun with 600 quit frames completed with **zero errors/warnings**. The warning occurred during the shorter editor shutdown; it is retained in the full-run evidence rather than erased.
- Final base suite: **847 headless checks**; validates native imported RGBA, all structural PNG decoding, metadata, room envelopes, unchanged terrain kinds, actual actor movement, companion follow, reversed-route straight sections, actor cutaway and real airlock/inventory transitions.
- Furnished interior suite: **582 headless checks**; validates prop Resources/PNGs, thresholds, approaches, original actors, service/UI and tray state bindings.
- Base JSON/dimension/hash/provenance/budget validator: **1,509 checks**.
- Interior JSON/path/dimension/footprint/provenance validator: **507 checks**, 74 source/runtime references.
- **97** tracked/new nonignored JSON files parse. **30** current report/inventory count, budget, limitation and relative-link checks pass through `tools/exterior/validate_base_documents.mjs`.
- Final isolated uncached import, editor exit, typed class-resolution and Main startup: **four steps passed**, zero errors/warnings; live `.godot` was not deleted.
- Native alpha recipe verifies retained shell pixels exactly against originals; Godot raw/imported RGBA equality verifies native texture imports. No nearest-filter assumption substitutes for these checks.

Evidence: `tests/output/phase_0_8g2_base/final_full_validation.log`, `final_clean_start.log`, targeted logs and `results.jsonl`; per-suite engine logs remain under `tests/output/`. Output folders are intentionally ignored by Git.

### Graphical review

- Final modular base suite: **871 checks**, including eight 960×540 views and two full native compositions.
- Furnished interior suite: **648 graphical checks**, 32 screenshot files (33 capture calls include one overwritten state view).
- Existing exterior library: 687 graphical checks; prior UI, both cameras/fullscreen, animation, interaction/inventory, perimeter, habitat, utilities and daily-life suites remain passing in the full workflow.
- Base captures: entrance, core, greenhouse, power/utilities, lander, pressure links, open hatch, closed hatch, transparent composition and terrain showcase.
- Interior evidence covers all nine compartments and the requested functional areas, wall/doorway navigation, equipment UI and six crop states. Representative native-scale images were inspected directly, including all nine compartments, both hatch states, power/greenhouse/connection close-ups, cutaway and crop stages.

Visual review rejected the first full-hull drafts and destructive provider masks. Fixes included native shell recovery, shared-texture depth sorting, actor cutaway, corrected hatch placement, exact import settings, the vertical conduit component, and reversed-route straight-section assembly. The new assembly's Vector2i dot-product parser error was corrected before passing final runs; earlier failed logs remain preserved. No existing assertion was weakened.

### Errors and warnings outside the game run

The untouched research registry validates **69 entries / 60 sources** with **12 invalid-fixture rejection tests** and zero registry errors. Eight existing evidence warnings remain: seven missing/inconsistent source-date notices and the aggregate null-TRL notice. They do not become invented dates or readiness ratings.

The standalone research **documentation** validator still exits with two errors from one pre-existing missing file: `docs/phase_0_8R_report.md` was removed by the prior `Less` commit, so its presence and totals text cannot be checked. This is documented rather than restoring unrelated historical reports or weakening that validator. Registry facts and the three required science documents agree; the latter were restored byte-identically from prior history. Godot results and the editor shutdown warning above are separate from this known historical documentation debt.

### Preservation and conflicts

Baseline: branch `dev/phase-0.8f-ui-overhaul`, HEAD `7aca5b2a8db3164f5a4a3495cc782e1c5196e129`; Alpha `2942b0502d1a53a78651044319bbd86392497198`. No commit, reset, checkout, push or release action was performed. Existing source PNGs/PXO/fonts, G1 prefabs/Resources, production map, habitat layout, astronaut/Chiwis controllers and clips, cameras, UI, utility/daily-life services and project.godot remain unchanged. All **64 external originals** match the initial hashes. Changes among the 1,069-file baseline are restricted to the prepared interior library, its renderer/build tooling, validation, inventory tooling/READMEs and additive AGENTS instructions.

The `Less` commit had removed required art/science Markdown and inventory files while leaving current tooling/instructions dependent on them. Only the authoritative Art Bible, three science references and requested inventory were restored; standards/science references are byte-identical to `148df51`. Existing standards JSON and research data were not revised. Earlier G1/initial-G2 gap/budget descriptions are historical; the current AGENTS paragraph, inventory and this report state which gaps are now resolved and the separate thirty-generation cap. Missing old reports are not silently represented as present.

## G. Remaining dependencies and manual acceptance

1. Integrate the prepared assembly deliberately into the normal Moon world: resolve existing zone reservations, pickup/mission positions, perimeter constraints and production entrance placement. This phase keeps that world unchanged.
2. Review each illustrated socket against the authored interior port and finish exact sealing collars/end-cap facings. The graph is connected, but logical budgets are not proof of watertight physical engineering. Do not scale art to hide a mismatch.
3. Choose additional furniture/door/connection facings and optional detailed personal/tool/medical/shelter accessories if required for final production polish. No new generation is authorized by this report.
4. Decide whether repeated module shells need unique decals/variants. Three native small facade bays are retained and distinct from full room envelopes. Avoid interpreting baked service fittings as extra ordinary vacuum entrances.
5. Preserve existing resource/airlock abstractions. Future quantitative pressure coupling, disease, new crops, disk save/load and other simulations require their own scope. This phase provides artwork and existing-service bindings only.
6. Restore/reconcile the missing historical research report in a separately authorized documentation cleanup if a completely green legacy research-doc check is desired. Do not alter scientific data merely to satisfy a missing-file check.
7. Measure final production-scene performance after placement; this phase verifies rendering and navigation but makes no FPS or low-end hardware guarantee.

Manual inspection:

1. Open Godot 4.7.2 and run `scenes/development/lunar_base_preview.tscn` with F6. Use F1–F5 to inspect each exterior area at native scale. Walk with WASD; verify both actors remain visible and footprints block entry into hulls.
2. Use Tab for management mode and its existing pan/zoom controls. I opens the same modal inventory. Return to Player Mode before interacting.
3. Approach the visible hatch and use E. In the chamber, use the existing seal, inspection, pressure-cycle and inner-door actions. Confirm no simultaneous open pressure boundaries and that the original inventory persists into equipment lock.
4. Run `scenes/development/lunar_interior_preview.tscn` separately. F1–F9 selects rooms when no modal/transition is active. Reach each action marker; inspect floor alignment, furniture clearances, wall cutaways, doors and Chiwis following.
5. Open the existing galley, utility and greenhouse interfaces. Plant/inspect/harvest using finite existing resources; compare stage sprites and grow-light state to actual tray state. No new biological rate is implied.
6. Run the normal project. Confirm the application/menu and existing Moon tutorial still start with their original systems and production layout.

### Files created or modified

| Group | Files / paths |
| --- | --- |
| New art and provenance | `assets/buildings/base_g2/`, `assets/pixellab/source/base_g2/`, `assets/environment/interiors_g2/structure/`, seven new furnishing PNGs/imports in `assets/environment/interiors_g2/` |
| New metadata | `art/imports/base_g2.json`, `base_generation_ledger.json`, `base_hulls.json`, `base_measurements.json`, `base_source_audit.json`, `base_structure.json`, `native_shells.json`, `lunar_base_art_library.json` |
| New spatial/scene data | `resources/data/lunar_base_art_layout.json`, fifteen exterior definitions/scenes under `resources/exterior/base_g2/` and `scenes/exterior/base_g2/`, pressure TileSet, assembly scene and development preview |
| New interior prefabs | Seven matching prop definitions/scenes for service wall, overhead lamp, filters, medical storage, nutrient, irrigation and locker |
| New runtime presentation | `scripts/world/lunar_base_assembly.gd`, `scripts/development/exterior_art_region.gd`, `exterior_occlusion_guard.gd`, `lunar_base_preview.gd` and generated UID sidecars |
| New local tools/tests | Base build/resource/audit/review/validation/inventory tools, original structure/hull painting, reversible split/background-alpha preparation, production plan/source lists, `tests/lunar_base_art_test.gd` |
| Existing prepared interior changes | `scripts/interiors/interior_module.gd`, `interior_room.gd`, nine prepared room scenes, `room_library.json`, interior library/audit, `tools/interiors/build_library.mjs` and inventory wrapper |
| Validation/docs | `tests/validate.ps1`, both tooling READMEs, additive `AGENTS.md`, restored/updated inventory, this report and worklog; restored byte-identical authoritative art/science Markdown |

See the manifests and inventory for individual PNG paths, hashes, measured anchors and per-asset origins. Phase 0.8G3 and Phase 0.9 have not begun.
