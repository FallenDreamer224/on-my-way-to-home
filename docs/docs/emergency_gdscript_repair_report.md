# Emergency Repair — GDScript Class Resolution and Startup

Date: 2026-11-15. Project: On My Way to Home. Engine verified: **Godot 4.7.2.stable.official.ed1daf0bf**.

## Diagnosis and repair

The reported classes and their implementations already existed. Their declarations, capitalization, resource paths and initialization interfaces were correct. The current on-disk project compiled before any production-code edits, and an independent copy starting without a .godot directory imported and launched successfully.

The already-open Godot editor was waiting at **Files have been modified outside Godot**, offering Reload from disk. Its output still contained the reported old Main parse failures. Accepting **Reload from disk**, completing the scan and running Main restored successful startup in that same editor. The game displayed the lunar terrain, astronaut, Chiwis and initialized HUD; a mouse interaction collected the nearby sample. After stopping that run, the editor's current Output showed **0 errors and 0 warnings**.

The evidence supports stale **in-memory editor class/dependency state during external project updates**, rather than missing gameplay implementations or broken source files. The exact historical symbol table was not captured, so this report does not claim a proven corrupt on-disk cache entry. No failing class dependency or source-level parse error was reproducible in the current files.

No production code was changed to hide these errors. In particular, no subsystem was removed, no global class was replaced with a dummy, no arbitrary eva_limits property was added, and no dynamic property lookup or untyped constructor was substituted for the intended typed architecture.

| Reported error | Verified intended implementation |
| --- | --- |
| EvaSafetyMonitor missing | scripts/gameplay/eva_safety_monitor.gd declares class_name EvaSafetyMonitor and extends Node. Main's existing Systems/EvaSafety node uses this script. |
| eva_limits unresolved | scripts/world/lunar_tutorial_region.gd explicitly declares **@export var eva_limits: EvaSafetyLimits**. This is an **instance Resource property**, not a static member. |
| EVA policy integration | resources/data/lunar_tutorial_region.tres assigns resources/config/lunar_eva_safety.tres to that property. scenes/world/world.tscn assigns that region to Ground. Main passes tutorial.eva_limits to the existing monitor's configure method. The new startup check verifies object identity through the entire chain. |
| UtilityService missing | scripts/utilities/utility_service.gd declares the correct global class; Main's Utilities node initializes its real model before composition completes. |
| UtilityPanel missing / inference failure | scripts/ui/utility_panel.gd declares UtilityPanel, extends PanelContainer and implements configure. Its inherited constructor and existing inferred variable declaration work after registration. |
| DailyLife missing / inference failure | scripts/habitat/daily_life.gd declares DailyLife, extends Node and configures its inventory/utility bindings. No replacement implementation was needed. |
| DailyLifePanel missing / inference failure | scripts/ui/daily_life_panel.gd declares DailyLifePanel and configures the real DailyLife instance. Its constructor and typed dependency resolve normally. |

No missing files, duplicate global class declarations, spelling mismatches, invalid static access, missing required constructor, missing configuration path or incomplete integration was identified for these errors. Fresh import, individual script parsing and runtime construction resolved the dependency graph; no circular dependency prevented compilation. The type-inference errors were downstream symptoms of unresolved class identifiers in the stale editor session.

## Durable validation changes

Created:

- **tests/class_resolution_test.gd** and its Godot UID: 23 checks for the seven relevant registered script names, successful script construction, real EVA policy identity, initialized utilities/daily life, panel wiring and original actors.
- **tests/validate_clean_start.ps1**: creates an isolated project-input copy under ignored tests/output, starting without generated cache. It imports, runs the headless editor, executes the startup contract and launches Main. It records each engine exit code, error detection and warning count in results.json, plus separate logs. It neither deletes nor renames the live .godot directory.
- This report.

Modified:

- **tests/validate.ps1**: adds the explicit headless editor --quit check and class-resolution regression; records actual process exit codes alongside existing output/error scanning.
- **AGENTS.md**: adds the external-reload and clean-start validation procedure while preserving existing phase/art/science instructions.

Godot regenerated ordinary ignored editor/import metadata. The existing project inputs—project.godot, icon.svg, production scripts, scenes, resources, assets and art—were compared with the pre-repair snapshot and remained **byte-identical**. No art generation, PixelLab jobs/credits, audio implementation, new gameplay, Mars work, external source edits or commits occurred.

## Inspection inventory

Direct inspection and project-wide symbol/reference searches covered:

- AGENTS.md, project.godot, .vscode/settings.json and .gitignore.
- scripts/core/main.gd; scenes/main.tscn; scenes/world/world.tscn.
- scripts/gameplay/eva_safety_monitor.gd, eva_safety_limits.gd; scripts/world/lunar_tutorial_region.gd.
- resources/data/lunar_tutorial_region.tres and its existing EVA configuration reference.
- scripts/utilities/utility_service.gd; scripts/ui/utility_panel.gd.
- scripts/habitat/daily_life.gd; scripts/ui/daily_life_panel.gd; the HabitatDirector composition bindings.
- The generated .godot/global_script_class_cache.cfg and class declarations throughout production scripts.
- tests/validate.ps1 and the established test suite. The complete production/test GDScript inventory was inspected by Godot import/individual parsing; its exact file list appears below.

The new check also loads/constructs the real Main scene rather than verifying class names alone. Existing regression suites exercise actual actor, camera, inventory, safety, interior, utility and daily-life behavior.

## Validation and evidence

Commands:

~~~powershell
./tests/validate_clean_start.ps1
./tests/validate.ps1 -IncludeRendering
~~~

The headless editor step is equivalent to:

~~~text
Godot_v4.7.2-stable_win64.exe --headless --path . --editor --quit
~~~

Validation adds --audio-driver Dummy and project-isolated APPDATA/LOCALAPPDATA. Engine execution uses the established outside-sandbox certificate-store read access; all test profiles, copies and logs remain under the project directory.

All validation completed successfully. **Remaining script errors: 0. Remaining engine warnings in final validation: 0.**

| Validation | Result / exit status |
| --- | --- |
| Uncached project copy: import | 0; no script errors or engine warnings |
| Uncached headless editor --quit | 0; no script errors or engine warnings |
| Uncached typed startup contract | 0; **23 checks passed** |
| Uncached Main startup | 0; no script errors or engine warnings |
| Current-project import and headless editor --quit | 0 for both |
| Production/test script parsing | All individual checks exited 0 |
| Current-project startup contract | 0; **23 checks passed** |
| EVA safety / lunar map | 0; **405 / 9,261 checks** passed |
| Habitat interiors | 0; **971 headless / 975 rendered checks** passed |
| Utilities | 0; **922 conservation/failure checks**, plus terminal integration/rendering/fullscreen checks passed |
| Daily life / greenhouse | 0; **304 headless / 306 rendered checks** passed |
| Remaining regressions | Foundation, isometric fixture, terrain, astronaut, Chiwis, walk/run art, both cameras/modes, inventory/interactions, props and UI all exited 0 |
| Graphical editor/Main and fullscreen | All exited 0; actual scene/actor/UI rendering verified |
| Open-editor repair | Reloaded changed files, launched Main, observed real actors/map/UI and successful pickup; current Output showed zero errors/warnings |

No implementation was missing for the affected features. Existing placeholder/abstraction limits documented in Phases 0.8D–0.8E2 remain intentional and unchanged.

Key evidence under tests/output:

- emergency_editor_before.log: current on-disk editor startup already succeeded before production changes.
- emergency_clean_import.log and emergency_clean_main.log: initial independent uncached-copy evidence.
- emergency_clean_validation.log.
- clean_start_20261115_134714_898/results.json and import.log, editor_quit.log, class_resolution.log, main.log: each step exited 0 with no detected errors/warnings.
- emergency_regressions.log: full current-project checks with recorded process exit statuses.

A successful process launch alone was not accepted as success: both exit statuses and captured output were checked for SCRIPT ERROR, ERROR, Parse Error and FAIL lines.

The live editor had historical WASAPI output-device messages alongside the old parse errors before reload. No audio setting or subsystem was changed. The newly launched game and its current Output were clean; automated checks use Dummy audio. Existing research evidence caveats remain in their original research reports and are unrelated to GDScript startup.

## Readiness and resume point

**The project compiles and launches with all Phase 0.8E2 systems retained.** No missing gameplay system had to be invented to restore startup. The project runs Main directly; a separate main-menu flow was not present or added.

Resume from the **completed Phase 0.8E2 checkpoint**. Phase 0.8F1 is merely the next named boundary in the development sequence and requires a separate user assignment. This repair does not start it.

For later external edits, accept the editor's Reload from disk prompt and allow its filesystem/class scan to finish. If stale unresolved-class messages remain, stop the test game and reopen the editor/project after preserving any unsaved work; run the clean-start command to distinguish editor-session state from an actual source failure. Do not delete working systems or rewrite typed properties to silence old registration errors.

## Automated script inspection inventory

The full regression recorded **122 engine invocations, all exit code 0**. The following 79 source/test files were individually parsed by Godot:

<details>
<summary>Parsed GDScript files</summary>

~~~text
scripts/camera/base_management_camera_rig.gd
scripts/camera/camera_framing.gd
scripts/camera/player_camera_rig.gd
scripts/camera/temporary_camera_target.gd
scripts/companions/chiwis.gd
scripts/companions/terrain_route_planner.gd
scripts/core/development_settings.gd
scripts/core/main.gd
scripts/gameplay/eva_range_provider.gd
scripts/gameplay/eva_safety_limits.gd
scripts/gameplay/eva_safety_monitor.gd
scripts/gameplay/gameplay_mode_coordinator.gd
scripts/gameplay/player_session.gd
scripts/habitat/daily_life.gd
scripts/habitat/habitat_action.gd
scripts/habitat/habitat_airlock.gd
scripts/habitat/habitat_director.gd
scripts/habitat/habitat_room_region.gd
scripts/habitat/habitat_room_state.gd
scripts/habitat/habitat_room.gd
scripts/interaction/interactable.gd
scripts/interaction/interaction_detector.gd
scripts/interaction/pickup_interaction.gd
scripts/inventory/item_definition.gd
scripts/inventory/runtime_inventory.gd
scripts/player/astronaut_animation.gd
scripts/player/astronaut_directions.gd
scripts/player/astronaut_placeholder.gd
scripts/player/astronaut.gd
scripts/player/character_art_profile.gd
scripts/ui/daily_life_panel.gd
scripts/ui/game_hud.gd
scripts/ui/game_ui.gd
scripts/ui/input_hint.gd
scripts/ui/interaction_prompt.gd
scripts/ui/inventory_window.gd
scripts/ui/item_placeholder.gd
scripts/ui/notification_area.gd
scripts/ui/utility_panel.gd
scripts/utilities/utility_config.gd
scripts/utilities/utility_equipment.gd
scripts/utilities/utility_model.gd
scripts/utilities/utility_service.gd
scripts/world/isometric_grid.gd
scripts/world/lunar_site_layout.gd
scripts/world/lunar_tutorial_region.gd
scripts/world/placeholder_terrain.gd
scripts/world/prop_appearance.gd
scripts/world/surface_cell_data.gd
scripts/world/terrain_layer.gd
scripts/world/terrain_region.gd
scripts/world/terrain_walkability.gd
scripts/world/world_pickup.gd
scripts/world/world_prop.gd
tests/astronaut_test.gd
tests/base_pack_c_test.gd
tests/chiwis_test.gd
tests/class_resolution_test.gd
tests/daily_life_test.gd
tests/eva_safety_test.gd
tests/foundation_test.gd
tests/gameplay_modes_test.gd
tests/habitat_test.gd
tests/interaction_inventory_test.gd
tests/inventory_test.gd
tests/isometric_world_test.gd
tests/lander_pack_d_test.gd
tests/lunar_tutorial_test.gd
tests/moon_terrain_test.gd
tests/pixelorama_assets_test.gd
tests/player_camera_test.gd
tests/prop_integration_test.gd
tests/props_pack_b_test.gd
tests/run_animation_test.gd
tests/terrain_pack_e_test.gd
tests/ui_foundation_test.gd
tests/ui_pack_a_test.gd
tests/utilities_test.gd
tests/utility_integration_test.gd
~~~

</details>

