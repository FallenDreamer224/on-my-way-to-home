# DEMO READINESS REPORT — D0

Audit date: 2026-11-15. Baseline: completed Phase 0.8E2 plus the startup repair. Main development roadmap is **suspended**. D0 freezes a small Moon-only demonstration; it does not authorize D1 or Phase 0.8F1.

## 1. Readiness decision

**Ready to begin demo assembly; not ready for public Windows distribution.**

The existing prototype has a complete, tested sample-to-science route. Its real Main scene initializes the terrain, single astronaut, Chiwis, both cameras, interaction/inventory UI, EVA policy, interiors, utility model and daily-life model together. Fresh session construction works without inheriting the previous session's inventory, pickups or routine completion.

No blocking gameplay/source-class defect was reproduced in D0. The earlier missing-class errors do not currently exist. Release gaps are presentation/onboarding, an explicit player-facing objective/completion flow, control of development-only terminal operations, menu/session ownership and a validated Windows export. These are demo-assembly requirements, not justification for new major systems.

Engine/runtime constraints remain Godot **4.7.2**, GDScript, fully native 2D, 2:1 isometric **64x32** ground tiles, **960x540** logical viewport, nearest filtering, one human, one Chiwis, Moon only, no multiplayer and no audio implementation.

## 2. Startup and previous class failures

Inspection and runtime validation confirm the existing classes EvaSafetyMonitor, UtilityService, UtilityPanel, DailyLife and DailyLifePanel have matching files/declarations and initialize in Main. Type inference for their constructors succeeds. There is no replacement stub.

`LunarTutorialRegion.eva_limits` remains an exported **EvaSafetyLimits instance Resource**. `resources/data/lunar_tutorial_region.tres` assigns the authored `lunar_eva_safety.tres`; Main passes that exact object to the monitor. The 23-check startup contract verifies this identity and real service/panel construction.

The prior failure was resolved by reloading external changes in the already-open editor. D0's independent uncached import/editor/startup pass and full-project tests confirm that the current disk implementation is sound. An old editor's retained error messages are not evidence of a new source failure; accept Reload from disk and finish its class scan. See [the repair report](emergency_gdscript_repair_report.md). No dynamic property lookup, arbitrary eva_limits field, class alias workaround or removed subsystem was needed.

## 3. Feature audit

Status meanings: **WORKING** means the stated existing capability works under the tested configuration; **PARTIALLY WORKING** means a usable foundation exists but the larger feature has explicit gaps. Neither label asserts scientific certification, final artwork or public-release completeness.

| # | Feature | Status | Actual implementation / limits |
| --- | --- | --- | --- |
| 1 | Lunar terrain | **WORKING** | Production 40x40 logical region, 1,600 native TileMapLayer cells, finished regolith atlas, clustered variation and terrain-aware walkability. Terrain/render checks detect no gaps/overlaps. This is a fictional site, not a real landing-site reconstruction. |
| 2 | Astronaut movement | **WORKING** | CharacterBody2D walking, normalized eight-direction facing, complete-foot boundaries/collisions, modal input safety and room rebinding. D0 actually walks the selected route through the controller. |
| 3 | Astronaut walk/run animations | **PARTIALLY WORKING** | Eight idle/walk/run clips are imported and run clips can be previewed. Normal gameplay selects idle/walk. **Sprint input and sprint movement are NOT IMPLEMENTED**; do not advertise running as a demo control. |
| 4 | Chiwis navigation/animations | **WORKING** | Terrain-aware following, obstacle routing, idle/walk playback, retained companion through portals and access-clear interior parking. Run clips are imported but normal following does not automatically select them. No advanced companion commands. |
| 5 | Player camera | **WORKING** | Native Camera2D following, pixel alignment, derived map/room bounds and retained per-location settings. |
| 6 | Base Management camera | **WORKING** | Tab mode switching, continuous pan, discrete nearest-pixel zoom and room/exterior bounds. This is a camera mode, not implemented base construction/management gameplay. |
| 7 | Interaction | **WORKING** | Nearby detection, nearest valid target, contextual E/left-click action, held-input protection, station/portal validation and inactive-room rejection. |
| 8 | Inventory | **WORKING** | Astronaut-owned 20-slot runtime inventory, stacking, exact partial pickup/harvest acceptance, full-capacity feedback, inspection UI and modal movement gate. Persists across modes/rooms in the same session; no disk saves. |
| 9 | Perimeter/warnings | **WORKING** | Static normal/warning/boundary zones, Chiwis notices with cooldowns, return direction and blocked full-foot movement beyond the designated area. Management-camera movement does not generate astronaut warnings. No quantitative EVA consumables/range solver. |
| 10 | Moon base exteriors | **PARTIALLY WORKING** | Accessible habitat entry marker and annotated outpost reservations exist. Finished base/lander artwork is available in asset packs but **is not assembled into production exterior buildings**. Reservation outlines/labels are not functioning habitat hulls, landing craft or solar installations. |
| 11 | Interior rooms | **WORKING** | Nine reusable cutaway rooms, 260 connected walkable cells, eighteen stations covering sixteen facility groups, walls/partitions, room metadata, collision, actor routing and retained room state. Visuals are development placeholders. |
| 12 | Airlock | **PARTIALLY WORKING** | Playable two-hatch interlock, seal/inspection/cycle sequence, incompatible-pressure denial and entry/exit with the same actors. Pressure is a discrete presentation state; chamber gas volume, pumping energy, recovery/loss and physiological EVA procedure are not simulated. |
| 13 | Greenhouse | **PARTIALLY WORKING** | Two logical trays, finite Cargo seeds/nutrients, real utility water/power dependencies, light switches, conditional progress, finite yields and partial harvesting work. Default cycle is 1,800 utility seconds; crop appearance/chemistry and full biological simulation are not implemented. No plant oxygen credit or complete diet. |
| 14 | Power/utilities | **PARTIALLY WORKING** | Working fixed-step battery/generation/distribution/load model, atmosphere estimates, heat accounting, equipment flags/alarms and engineering terminals. Solar input is a configured/manual scenario source; installed exterior geometry does not drive it. Full hardware physics/airlock coupling are absent. |
| 15 | Water/resources | **PARTIALLY WORKING** | Finite kg pools, bounded powered treatment, wastewater/reject accounting and explicit activity/crop water transfers work. Recovery yield and timings are game assumptions; purity/contaminant chemistry, mining and general resource-processing gameplay are absent. |
| 16 | UI | **PARTIALLY WORKING** | HUD, mode/hint/prompt, notifications, inventory, utility and daily-life panels work at 960x540 with modal safety. Reserved health fields remain empty. No main menu, New Game button, objective tracker, completion screen or in-game fullscreen toggle. Text, empty status fields and developer controls need demo presentation work. |

No audited item was classified BROKEN after validation. This does **not** convert the partial features above into finished systems.

Additional **NOT IMPLEMENTED** release capabilities: public demo menu/restart/quit flow, player-facing objective progression/completion, Windows export preset/package and installed-build acceptance on a machine without Godot. Disk saves and detailed survival remain outside the frozen demo rather than release requirements. No packaged executable was produced or tested in D0.

## 4. Frozen minimum Moon experience

**Single objective: Collect a Lunar Sample, bring it safely inside the outpost, and record a science examination.**

Use existing behavior:

1. Spawn on the Moon with Chiwis. Walk/explore, collect the nearby Lunar Sample with E and inspect it with I.
2. Switch to Base Management view with Tab, pan/zoom, then return to Player Mode. Neither mode change nor inventory use changes item ownership.
3. Reach the existing Habitat crew airlock at logical cell (-8, 0), northwest of spawn. Follow the actual seal, suit/dust inspection and pressure-match interlock.
4. Enter Equipment lock → Hub → Health/science. Reach the Science station by walking around its partition.
5. Use E, choose **Examine sample**, keep the panel open for the existing five-second powered routine, then close it. The sample is preserved.
6. Return to the Moon if desired; Chiwis, acquired items and session state remain intact.

The authoritative success facts already exist: `DailyLife.completed["science"] >= 1` and the sample remains in RuntimeInventory. D0 validates these facts; it **does not add a mission controller or pretend a player-facing objective/completion display already exists**. D1 can present this existing interaction with a short instruction and completion acknowledgement.

Required demonstration features are walking, companionship, lunar exploration, both camera modes, one resource pickup, inventory, accessible habitat entry/interiors and one meaningful powered interior activity. No complete greenhouse harvest, utility fault, new building or advanced system is needed to finish it. Public play duration has not been measured; D1 should time a fresh-player pass before promising a length.

Retain other implemented systems in the project. Optional rooms/terminals can remain exploratory or receive simple release gating later. The frozen required route never depends on development acceleration, manually creating inventory, force-teleporting actors or bypassing the airlock.

## 5. Exclusions and release safeguards

Excluded from the promised demo experience:

- Sprint gameplay despite imported run artwork.
- Fully assembled base/lander exteriors, placement/construction and management simulation.
- Waiting for an entire crop cycle or changing growth/solar acceleration.
- Detailed ECLSS, gas physics, crop chemistry, physiology, medical outcomes or survival progression.
- New NASA systems, Mars, multiplayer, new companions, complex crafting, extra terrain/buildings, artwork/animation generation, trailer tooling and audio.
- Disk persistence and a campaign-length session.

Existing utility **Test fault**, maintenance and sunlight scenario controls remain accessible in the prototype. D0 preserves them; it does not claim they have been hidden. Before a public build, D1 must decide a release-safe inspection presentation/gate so an uninformed visitor cannot accidentally disable the power needed by the objective. This should reuse the current model/UI rather than fabricate a second utility simulation.

Development zone outlines/labels, blank health placeholders, generic routine messages (including the science panel's irrelevant physiology sentence), and discoverability of the offscreen habitat entry are presentation gaps. Do not solve them by adding survival mechanics or new buildings.

## 6. Changes and blocking issues

No blocking source/runtime bug was reproduced in the current selected route. No working system was removed or rebuilt merely to produce a green audit.

D0 changes:

- Added **scripts/core/game_entry.gd** and UID: `GameEntry.new_game()` constructs the existing Main scene as an unattached fresh Node. The future menu caller owns teardown/attachment; there is no autoload, duplicate inventory, menu UI or implicit save/load.
- Added **tests/demo_d0_test.gd** and UID: complete sample-to-science-and-back acceptance through actual walking, existing E actions, inventory/mode keys, real station button and normal utility time. It waits for Chiwis and tests a subsequent fresh session.
- Updated **tests/validate.ps1** to include headless/rendered D0 acceptance and use a phase-neutral completion message.
- Corrected **README.md**'s stale 12x12/current-phase description to the actual 40x40 / Phase 0.8E2 baseline, documented the future entry boundary and linked this audit.
- Added D0 scope-freeze instructions to **AGENTS.md**.
- Created this report.

An initial new route-test failure was its navigator's inconsistent stopping tolerance, not a gameplay collision bug: both axis offsets could be under two pixels while radial distance remained over two. The test steering threshold was corrected and the entire route then passed without changing movement, collisions or the map.

Main remains `res://scenes/main.tscn` in project.godot. Existing production code, configuration, map data, original PNG/PXO artwork and scientific/art standards are preserved. No Git commit or out-of-project asset edit was made.

## 7. Validation

Reproduce:

~~~powershell
./tests/validate_clean_start.ps1
./tests/validate.ps1 -IncludeRendering
node tools/habitat/validate_layout.mjs
node tools/research/validate_science_catalog.mjs --self-test
~~~

Actual executable: **Godot 4.7.2.stable.official.ed1daf0bf**. Test profiles/logs live under ignored tests/output; engine processes use the established certificate-store read access and Dummy audio for validation. Exit codes and output error markers are checked together.

**Final result: 126 current-project engine invocations, all exit code 0; 0 engine errors and 0 engine warnings.** The independent clean-start workflow also completed its four engine steps with exit 0, no detected errors and no warnings.

### Headless results

| Check | Result |
| --- | --- |
| Fresh import → editor --quit → real Main | Passed in an isolated copy without initial .godot metadata; no class-resolution errors |
| Current project import/editor and all script checks | Passed; startup/class contract **23 checks** |
| Selected D0 route and fresh-session entry | **115 checks passed**; actual walking, existing pickup/inventory/mode actions, complete airlock ingress/egress, powered examination and clean session reset |
| Lunar map / EVA | **9,261 / 405 checks passed** |
| Astronaut / Chiwis | **234 / 44 checks passed** |
| Interiors | **971 checks passed**, including navigation/collision and same-actor state preservation |
| Utilities / daily life | **922 conservation/failure checks / 304 daily-life checks passed** |
| Other existing suites | Resource loading/scene instantiation, foundation, isometric fixture, Moon terrain, walk/run assets, camera rigs/modes, inventory/interactions, props and UI passed |

### Graphical results

| Check | Result |
| --- | --- |
| Actual D0 gameplay route | **119 checks passed** with GPU-rendered captures of spawn, management mode, completed science interaction and surface return |
| Editor/Main and fullscreen | Passed with the configured Compatibility renderer; no missing scene/resource or runtime errors |
| Astronaut / Chiwis | **244 / 46 checks passed**; existing rendered movement test uses fixed rendering cadence while still checking different physics rates |
| Interiors / daily life | **975 / 306 checks passed** |
| Utility panels / modes / UI | Existing rendered and fullscreen suites passed |
| Visual inspection | D0 spawn, management and science-completion captures inspected at 960x540; sharp source pixels and readable functional panels, with development labels/wording still visible |

Additional checks: habitat layout remains nine rooms, eighteen stations and 260 connected floor cells. Research JSON/generated-document consistency passed for 69 entries, 60 official sources and sixteen categories, with twelve invalid-fixture checks. **Eight existing research-evidence warnings** remain separate from engine warnings: six unconfirmed source dates, the recorded CHAPEA date discrepancy and null TRLs rather than invented achieved ratings. No scientific baseline was revised.

Evidence under ignored tests/output:

- demo_d0_validation.log: all 126 recorded engine exit codes and suite results.
- demo_d0_clean_start.log; clean_start_20261115_135641_103/results.json and step logs: fresh-cache startup results.
- demo_d0_targeted.log and demo_d0_rendered_targeted.log: focused route acceptance.
- demo_d0_spawn.png, demo_d0_management.png, demo_d0_science_complete.png, demo_d0_return.png: actual rendered route stages.
- demo_d0_baseline.json: pre-existing project/script/scene/resource/art/settings hashes. Final comparison found **no changes to any pre-existing production or art input**.

Scope of evidence: the full resource scan loads every gd/tscn/tres under production script/scene/resource directories and instantiates scenes. All production/test GDScript is individually parsed. Native input/physics automation and actual GPU captures exercise the real Main composition, not a stripped demo replacement. This is not a public-user usability test, Windows exported-build test or hardware compatibility certification.

D0 inspected the complete script/scene/resource inventory through these checks; source review focused on Main/class wiring, terrain/site annotations, movement/animation controllers, Chiwis routing, cameras/mode/modal policy, interaction/inventory, HabitatDirector/room/airlock, utility/daily-life state and UI, project settings, existing phase reports and export/menu availability.

## 8. Entry boundary and remaining requirements

D1 can call `GameEntry.new_game()`, attach its returned node to an owned gameplay container, and explicitly dispose the previous session when restarting. It must preserve unsaved-session semantics, handle in-progress transitions/modal focus, and keep only one active gameplay session. D0 tests sequential fresh construction and original Main startup; menu navigation, restart-during-transition and application exit remain D1 responsibilities.

Before public distribution:

1. Present the one objective and short controls/airlock guidance; show completion using existing science/inventory state.
2. Provide a minimal menu/New Game/restart/quit ownership flow through the prepared entry boundary, without expanding the roadmap.
3. Gate development fault/scenario operations and reduce misleading development presentation; keep inactive medical/survival fields clearly outside scope.
4. Configure a Windows export using matching engine templates; test the exported game from a clean user profile without an editor and record real missing-resource/startup results.
5. Test cold launch, full objective, return/restart, modal cancellation, camera/fullscreen/window behavior and Chiwis access on the intended Windows machines. Re-run conservation, startup and full regressions.
6. Conduct a short fresh-player usability pass to verify habitat/airlock discovery and objective clarity.

These are **recommendations for Demo D1**, not implemented deliverables or authorization to begin it. D0 stops with a stable prototype and a frozen, tested assembly target. The main roadmap remains paused.

