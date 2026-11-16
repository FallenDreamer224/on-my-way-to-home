# Phase 0.9 — Lunar base production integration

Status: **COMPLETE**, with the cosmetic and packaging limitations recorded below. All required production visibility, access and navigation checks pass.

The completed modular base and furnished interiors now load through the configured **Main Menu → New Game** path. No development preview or flattened base image is used by production. One astronaut, Chiwis, the original inventory, mission tracker, utilities, daily-life model and airlock remain authoritative.

## Original cause and production changes

`project.godot` already launched `scenes/app_root.tscn`. AppRoot's New Game button already created `scenes/main.tscn` through GameEntry. Main composed the older empty Buildings group and site-reservation annotations; HabitatDirector's factory always instantiated `scenes/habitat/habitat_room.tscn`, the placeholder room. Only development-preview scripts placed the G2 assembly and registered the furnished scenes. The asset paths were valid; production never instantiated them.

Main now creates `LunarBaseWorld` by default. It instantiates `scenes/world/lunar_outpost.tscn` under `World/Entities/Buildings`, installs per-session occupancy, stages the existing actors/pickups and connects the existing director. That native scene inherits the modular G2 assembly with an explicit production layout. `project.godot`, `scenes/main.tscn`, `scenes/app_root.tscn` and the World source scene remain unchanged.

HabitatDirector registers the nine existing furnished scenes with its original persistent states. Rooms are instantiated lazily by its existing prepare/transition path; scene creation does not create another astronaut, companion, inventory or simulation. G2 previews explicitly opt out of production placement before attaching Main and keep their independent art fixtures. Normal Main/New Game leaves integration enabled.

## Map, placement and access

The surface remains **40×40**, logical coordinates -20…19 on both axes, with the exact original 1,600 terrain-kind entries and seam-fixed Moon TileSet. Native bounds remain `Rect2(-1280,-656,2560,1280)`. All world placement uses the existing IsometricGrid/native TileMapLayer conversion and 64×32 basis.

| Point | Logical cell | World pixels |
| --- | --- | --- |
| Astronaut arrival beside lander | -16,11 | -864,-80 |
| Chiwis arrival | -17,10 | -864,-112 |
| Crew-airlock exterior interaction | -5,-7 | 64,-192 |
| Lunar Sample A, quantity 6 | -17,11 | -896,-96 |
| Lunar Sample B, quantity 8 | -18,11 | -928,-112 |
| Metal Scrap, quantity 3 | -18,10 | -896,-128 |
| Supply Pack, quantity 1 | -19,10 | -928,-144 |

Pickup IDs, item Resources, quantities, stack rules and partial-acceptance behavior are retained. Runtime placement moves these four objects from the original source-scene fixture to safe landing approaches. The existing mission guidance now describes the crew hatch on the north-east side of the base rather than the old north-west placeholder location.

The static production mission rectangle is `Rect2i(-19,-19,39,38)`: column 19 is included for the reviewed eastern shelter, within the unchanged surface. This is a tutorial design boundary, not a calculated EVA distance. The source EVA Resource remains its original 38×38 configuration. A per-session duplicate keeps its messages, cooldowns, enabled warnings and safety logic; return guidance targets the actual hatch. It is active outdoors and suspended/resumed by the original habitat transitions.

Physical footprint identities, navigation-clearance exclusions and prepared access are separate per-session data. Shared source Resources remain unchanged. Eight sealed service-void cells are blocked rather than advertised as reachable floor. Existing utility-floor art supplies eight native maintenance-apron cells around two rim approaches; four authored access overrides complete the route while both crater cores remain excluded. Underlying terrain kinds are preserved, and the floor overlay uses a separate native TileMapLayer.

The installed map has **772 walkable exterior cells**, all connected to the arrival area. Every preserved pickup and the hatch have a full-foot route. Safety guidance can route from the real boundary back around the installed structures.

## Base modules and native artwork

All nine G2 room-sized module origins and dimensions are retained. Canvas dimensions and measured pivots remain independent of logical footprints. Five native shell designs serve nine module roles; no artwork is resized, rotated, redrawn or regenerated.

| Module / furnished room | Origin | Logical envelope |
| --- | --- | --- |
| Crew airlock | -13,-10 | 8×7 |
| Equipment / suit lock | -13,-2 | 8×7 |
| Main habitat / mission hub | -4,-2 | 8×9 |
| Living, sleeping, galley, hygiene | -4,8 | 8×8 |
| Engineering, ECLSS and water | -13,8 | 8×8 |
| Health, exercise and science | 5,-2 | 8×8 |
| Greenhouse | 5,-10 | 8×7 |
| Cargo / workshop | 5,7 | 8×7 |
| Emergency shelter | 14,-2 | 6×6 |

Eight logical links use 32 pressure-passage cells and the existing oriented straight/junction/elbow sprites. The assembly retains independent prefabs, collision bodies, textures, hatch states, cable tiles and equipment. The complete-base PNG is not a runtime backdrop.

Twelve existing exterior equipment/lander/cargo images and the existing greenhouse bay are used alongside the G2 shells/connections. The small cube airlock facade is omitted because it duplicated the entrance and blocked the approach; the small habitat facade is omitted because it closed southern circulation. Their original files and G1 prefabs remain intact. The large room-sized shells provide those functions without scaling the small sprites.

Solar, battery, radiator, oxygen, distribution box, antenna, lander, cargo, tool case, beacon and sensor remain modular. Power/lander equipment moves inward; the oxygen unit clears the western service court. Exterior crate/support cargo/tool case use cells (7,-15), (10,-15), (13,-15). Cable tiles follow current equipment positions and under-run the module boundary; this is visual wiring, not another power model.

Large shells keep their native shared-texture depth strips. The existing cutaway helper temporarily places a faded occluder behind opaque actors, then restores its normal depth. It now safely handles a freed actor during camera/session teardown. The hatch uses a wall-side sorting datum while preserving its exact rendered mounting position and native pixels. Actor roots remain at their original feet and Z convention.

## Furnished rooms, doors and persistent state

Production uses the existing scenes under `scenes/interiors/rooms/`: crew_airlock, equipment_lock, hub, living, engineering, health_lab, greenhouse, cargo and shelter. Their real floor/wall PNGs, independent furnishings, occupied-cell collision, doors, cutaways and interaction anchors are retained.

The director registers prepared layout data before any entry. Engineering's hub doorway approach is moved to (6,3), threshold (7,3), because the inherited (6,2) location coincided with the power-terminal interaction. Other approved prepared-room port overrides remain aligned with the exterior plan. The builder rejects furniture-blocked or duplicate doorway/station target positions.

Room changes use the existing transaction, arrival anchors, actor reparenting and camera-view cache. Visited room instances, facility-inspection state, inventory, acquired pickups, utility/crop state and mission progress survive the round trip. Inactive rooms/world scopes are retained and disabled, not recreated as separate game sessions.

Exterior entry uses the same HabitatAirlock: vacuum matching, outer opening, seal, suit/dust checks, pressure match and inner passage. Return requires the existing outbound inspection/cycle and outer-hatch sequence. No ordinary pressurized-room door opens directly to vacuum. Open/closed exterior PNGs read the real interlock. The interlock remains a discrete presentation abstraction; no quantitative chamber gas/energy solver is implied.

## Existing equipment and greenhouse

| Area | Existing functional connection |
| --- | --- |
| Engineering power / ECLSS / water | Original UtilityPanel, UtilityService and equipment IDs; actual state and units |
| Exterior compatible equipment | Read-only markers observe the original UtilityEquipment state |
| Cargo | Finite delivered seeds/rations transfer to the existing inventory |
| Greenhouse | Two original DailyLife trays, seed use, actual power/light/environment checks, water/nutrients, finite harvest |
| Galley | Existing finite ration/greens preparation and drinking actions |
| Sleep, hygiene, exercise, medical | Existing lightweight activity interfaces, without new physiological effects |
| Operations / maintenance | Existing routine/inspection behavior; no new repair model |
| Science | Existing powered sample examination and original mission completion tracking |
| Shelter / other decorative furniture | Existing inspection or static appearance; no invented operational data |

The production greenhouse contains the actual tray and plant-stage views bound to the same DailyLife instance. The journey collects finite cargo seeds, plants through the actual station button, observes real early progress/light status and charges actual water/nutrients during normal simulation time. It does not inject a mature plant or accelerate the graphical journey. Existing dedicated regression suites retain full-cycle/harvest/failure coverage.

Generic leafy greens remain the only crop. Growth configuration, losses, resource accounting, power dispatch and UI artwork remain unchanged. No new oxygen production, free food, medical outcome, survival system or NASA claim was introduced. Static painted panel details are artwork; actual telemetry comes from the dedicated markers and original interfaces.

## Cameras and interface

AppRoot's menu, New Game ownership and disabled Continue behavior remain. Player Mode retains direct walking, astronaut camera, HUD, Chiwis guidance, prompts and modal inventory. Base Management retains its independent pan/zoom and existing read-only dashboard/equipment selection. Screenshot review identified clipped dashboard readings at 960×540; captions and values now wrap vertically within the existing dock. All eleven categories are clicked and checked for content bounds and input ownership. Both modes continue through the existing coordinator; interiors use existing compact bounds and location-specific view restoration.

Normal captures remain 960×540 with nearest filtering and integer camera zoom. The full-base evidence overview is a separate 2688×1536 native 1× view of the **same running production World2D**, not a preview world or changed gameplay resolution. A whole outpost cannot fit the normal viewport at native 1×; ordinary management pan surveys it without downsampling sprites.

## Validation and real runtime evidence

The final Godot 4.7.2 aggregate workflow passed **191 steps: 165 headless/import/parse steps and 26 graphical steps**, with **zero errors and zero warnings**. An independent uncached import, editor startup, typed class-resolution test and real Main startup also passed all four steps with zero errors/warnings. Final logs are `tests/output/phase_0_9/delivery_validation.log` and `delivery_clean_start_after_ui.log`; the latter identifies the isolated clean-start evidence directory.

The configured-scene journey runner loads AppRoot from ProjectSettings, clicks its actual New Game button, walks using the original controller, interacts through E and actual UI buttons, visits all nine rooms and returns outdoors. It uses no teleports, preview scenes, mocked services or accelerated crop maturation. The final journey passed **514 headless checks and 555 graphical checks**. Production occupancy/topology/EVA passed **4,522 checks**, the habitat suite passed **1,087 headless checks**, and class resolution/startup passed **32 checks**. Existing character, animation, interaction/inventory, utilities, daily-life, camera, UI, terrain and prefab regressions passed within the aggregate workflow.

Data/document validation separately passed: all **98** nonignored project JSON files parse; exterior integrity passed **1,509 checks**, interior integrity **507 checks / 74 references**, current base documentation **33 checks**, and science consistency **69 entries / 60 sources / 16 categories / 12 invalid-fixture rejection checks**. Science validation reports **eight pre-existing evidence warnings** concerning publication dates and null TRLs, separately from the zero-warning Godot run. `git diff --check` passes.

All **21** actual runtime captures were inspected for assets, placement, sorting, camera/UI clipping and room access. The dashboard clipping found during review was repaired and all relevant suites plus the entire aggregate workflow were rerun successfully. Logs and screenshots live under `tests/output/phase_0_9/`; they are intentionally ignored.

Capture directory: `tests/output/phase_0_9/captures/`.

| File | Evidence from normal gameplay |
| --- | --- |
| `01_main_menu.png` | Configured AppRoot title screen |
| `02_initial_moon_spawn.png`, `03_base_from_spawn.png` | Normal New Game arrival beside lander and base |
| `04_base_overview_native.png` | Full native overview of the actual runtime world |
| `05_astronaut_beside_base.png`, `06_chiwis_exterior_following.png` | Actual exterior movement/following |
| `07_airlock_entrance.png`, `20_crew_airlock.png` | Actual entrance and interlocked chamber |
| `08_interior_entry.png` | Furnished equipment lock after pressure-matched entry |
| `09_living_area.png` | Furnished living/galley/sleep/hygiene room |
| `10_engineering_equipment.png`, `19_actual_utility_terminal.png` | Furnished engineering and real utility UI |
| `11_mission_control.png`, `14_player_mode_interior_hud.png` | Mission hub and active Player Mode HUD |
| `12_greenhouse.png`, `18_greenhouse_planted.png` | Real greenhouse and resource-backed early crop state |
| `13_research_area.png`, `13_storage_area.png` | Furnished laboratory and cargo/workshop |
| `15_base_management_dashboard.png` | Real management camera/dashboard interaction |
| `16_returning_outdoors.png` | Return through the existing airlock |
| `17_emergency_shelter.png` | Accessible furnished shelter |

Regression interpretation: six historical component suites explicitly use their original unassembled fixtures because they author obstacle maps, fixed policy bands or old pickup coordinates. Every assertion remains. Separate default-enabled production tests cover the installed world and actual menu journey. Camera startup assertions now use the approved arrival cell and compare immutable runtime/source snapshots. Habitat floor checks distinguish traversable floor from rendered floor beneath furniture/closed hatches and assert both cases. The UI system whitelist explicitly includes the authorized compositor. D0 route timeouts derive from path length/speed while retaining endpoint accuracy and real controller movement.

Art regressions write ignored capture evidence only. Delivered G2 composition PNGs require an explicit separately authorized authoring flag to overwrite. This phase generates no new assets and preserves prior art bytes.

## Historical documentation and preservation

The requested F/G1 Markdown completion reports and CLAUDE.md are absent in the working tree; no contents were invented. Current Art Bible, standards, inventory, G2 report and existing gameplay/source documents were used. `docs/phase_0_8R_report.md` was recovered byte-identically from commit 148df51 as expressly requested. Science registry/document validation now succeeds: 69 entries, 60 official sources, 16 categories and 12 invalid-fixture checks. Eight established date/null-TRL warnings remain; scientific evidence and research data were not changed.

Baseline: branch `dev/phase-0.8f-ui-overhaul`, HEAD `7aca5b2a8db3164f5a4a3495cc782e1c5196e129`, protected Alpha `2942b0502d1a53a78651044319bbd86392497198`. The inherited G2 uncommitted work is preserved. No commits, reset, checkout, push, release or export were performed. No user editor was closed. Project/main/world scene configuration remains unchanged; integration is through the existing composition code and a new inherited outpost scene.

Final preservation evidence is recorded in `tests/output/phase_0_9/preservation.json`, against the saved 1,412-file baseline: zero original artwork changes, zero changes to the 64 external originals, unchanged HEAD/Alpha and unchanged project/main/AppRoot/World source scenes. The recovered science report matches its historical blob exactly. The two delivered complete-base composition PNGs are unchanged. PixelLab calls, generation jobs, artwork generated and credits spent during Phase 0.9: **zero**. Runtime evidence screenshots are not new game assets. No audio, additional characters, planetary maps or new simulation systems were added.

## Remaining limitations and next-phase preparation

- Some pre-existing passage socket/end-cap facings and baked sealed service-port details remain cosmetic limitations. They do not create extra interactive entrances or bypass pressure boundaries. No artwork was regenerated to conceal them.
- Grid envelopes, apron grading and collider clearances are game design geometry, not certified structural volume, terrain surveying or engineering performance.
- The existing airlock, utility, medical and daily-life abstractions retain their documented limits. Disk save/load, quantitative chamber gas coupling, advanced physiology and other systems remain deferred.
- Whole-base viewing at native density requires management pan; the large overview is evidence rather than a new zoom mode.
- Existing queued companion remarks can arrive after their original context during rapid traversal; dialogue timing polish remains optional. Menu branding retains its historical Phase 0.8F footer.
- A future Windows export/clean-machine acceptance remains separate; this phase validates the Godot project and publishes nothing. Optional source-only probes with the existing official Windows release template could not run: that template disables `--path` and requires an adjacent packaged PCK. They are not counted as passing release tests. No export/PCK was created. Required room registration was explicitly kept outside assertions so release builds do not discard it.

To play: run the project normally (F5), choose **New Game**, collect the nearby sample, survey with Tab, then follow the exterior route to the crew hatch on the north-east side. Seal, inspect and pressure-match before entering. The Equipment lock leads to the hub and the furnished living, engineering, greenhouse, cargo and science rooms; science connects to the shelter. Complete the existing outbound checks/cycle to return outside. No special development scene is needed.

Primary changed/new paths: `scripts/core/main.gd`, `scripts/core/game_entry.gd`, `scripts/world/lunar_base_world.gd`, `lunar_base_assembly.gd`, `lunar_tutorial_region.gd`, existing cutaway helper, HabitatDirector, two gallery opt-outs, `scripts/ui/management_dashboard.gd`, `scenes/world/lunar_outpost.tscn`, `resources/data/lunar_outpost_layout.json`, `tools/world/build_lunar_outpost.mjs`, mission guidance, focused production tests and regression harness/assertion updates, restored science report, inventory/README/AGENTS and this report/worklog. Original artwork and gameplay service/controller implementations are preserved. No subsequent phase has begun.
