# Asset inventory — Phase 0.9 world integration

Snapshot: Phase 0.9 production integration. Artwork counts and source records below are retained; the current production-use section supersedes earlier preparation-only status. No new artwork, generation or redistribution permission is implied.

## Current totals

| Measure | Count |
| --- | --- |
| Files under assets/ | 715 |
| PNG files | 407 |
| PNG runtime/prepared library | 237 |
| PNG retained source/provenance mirrors | 170 |
| Font binaries | 3 |

Godot .import sidecars and folder READMEs are included in total file counts. Source alternatives and technical atlases are not additional gameplay objects.

## Integration status

| Group | Current use / limitation |
| --- | --- |
| Astronaut and Chiwis | Native 64×64 frames in eight directions; idle/walk/run SpriteFrames preserved. Phase 0.9.1 activates hold-to-run for the astronaut and speed-based autonomous walk/run for Chiwis. No paths, PNGs, timing or import metadata changed. |
| Moon regolith | Production 256×96 seam-fixed atlas with native 64×32 cells; four stable logical terrain source IDs. |
| UI Pack A | 23 frames/states/icons. Reused by Mission OS controls and fallback icons; underlying gameplay data stays separate. |
| Props Pack B | Ten 64×64 props. Three item appearances on existing pickups; seven additional presentation resources/gallery assets. |
| Base Pack C | Ten modular base/equipment images with explicit footprint and anchor metadata; reused in title diorama. Not an exterior construction system. |
| Lander Pack D | Craft, ramp, landing decal and cargo; reused in title composition. No vehicle gameplay. |
| Terrain Pack E | Thirteen overlays/floor components plus technical atlas; retained for future world assembly. No new production terrain overlay simulation. |
| UI Pack F | 24 unique native 32×32 icons and two existing menu illustrations. Nine icons recovered from completed jobs in this continuation; fifteen icons and both illustrations inherited. |
| Failed Pack F jobs | Prepared Meal and Helmet failed previously at provider. Registry explicitly aliases them to approved Pack A supply_tool and health icons; no replacement job submitted. |
| Fonts | Departure Mono regular OTF, Silkscreen regular/bold TTF, matching local OFL texts. Antialiasing, MSDF and mipmaps disabled by inherited font imports. |
| Placeholder specifications | art/placeholders/astronaut_placeholder.json and habitat_interior.json; legacy/room development art retained. |

## Character animation clips

Counts below come from each current SpriteFrames resource, not from dividing sheet dimensions. Foot offsets, existing FPS/order and image bytes were not changed.

### astronaut

| Clip | Frames | FPS |
| --- | --- | --- |
| idle_e | 1 | 6.0 |
| idle_n | 1 | 6.0 |
| idle_ne | 1 | 6.0 |
| idle_nw | 1 | 6.0 |
| idle_s | 1 | 6.0 |
| idle_se | 1 | 3.4 |
| idle_sw | 1 | 6.0 |
| idle_w | 1 | 3.9 |
| run_e | 7 | 6.0 |
| run_n | 7 | 6.0 |
| run_ne | 7 | 6.0 |
| run_nw | 7 | 6.0 |
| run_s | 7 | 6.0 |
| run_se | 7 | 6.0 |
| run_sw | 7 | 3.0 |
| run_w | 7 | 3.0 |
| walk_e | 7 | 6.0 |
| walk_n | 7 | 6.0 |
| walk_ne | 7 | 6.0 |
| walk_nw | 7 | 6.0 |
| walk_s | 7 | 6.0 |
| walk_se | 7 | 3.4 |
| walk_sw | 7 | 6.0 |
| walk_w | 7 | 3.9 |

### chiwis

| Clip | Frames | FPS |
| --- | --- | --- |
| idle_e | 1 | 6.0 |
| idle_n | 1 | 6.0 |
| idle_ne | 1 | 6.0 |
| idle_nw | 1 | 6.0 |
| idle_s | 1 | 6.0 |
| idle_se | 1 | 6.0 |
| idle_sw | 1 | 6.0 |
| idle_w | 1 | 6.0 |
| run_e | 4 | 6.0 |
| run_n | 4 | 6.0 |
| run_ne | 4 | 6.0 |
| run_nw | 4 | 6.0 |
| run_s | 4 | 6.0 |
| run_se | 4 | 6.0 |
| run_sw | 4 | 6.0 |
| run_w | 4 | 6.0 |
| walk_e | 4 | 6.0 |
| walk_n | 4 | 6.0 |
| walk_ne | 4 | 6.0 |
| walk_nw | 4 | 6.0 |
| walk_s | 4 | 6.0 |
| walk_se | 4 | 6.0 |
| walk_sw | 4 | 6.0 |
| walk_w | 4 | 6.0 |

## Pack F intake and recovery

Canonical import manifest: `art/imports/ui_pack_f.json`. Original job/request record: `assets/pixellab/source/ui_pack_f/generation_jobs.json`. Original requests and job IDs remain intact. Existing selection PNGs now also have byte-identical source mirrors; those mirrors are identified as inherited runtime selections rather than independently verified remote downloads. Newly recovered candidates were downloaded without resampling, cropping or palette changes and copied byte-for-byte to source/runtime locations.

| Asset | Candidate | Native pixels | Origin |
| --- | --- | --- | --- |
| `ui_pack_f_icon_oxygen` | 23 | 32×32 | Inherited selection |
| `ui_pack_f_icon_carbon_dioxide` | 0 | 32×32 | Inherited selection |
| `ui_pack_f_icon_battery` | 7 | 32×32 | Inherited selection |
| `ui_pack_f_icon_fatigue` | 42 | 32×32 | Inherited selection |
| `ui_pack_f_icon_warning` | 12 | 32×32 | Inherited selection |
| `ui_pack_f_icon_power` | 43 | 32×32 | Inherited selection |
| `ui_pack_f_icon_water` | 5 | 32×32 | Inherited selection |
| `ui_pack_f_icon_air` | 16 | 32×32 | Inherited selection |
| `ui_pack_f_icon_greenhouse` | 3 | 32×32 | Inherited selection |
| `ui_pack_f_icon_gear` | 9 | 32×32 | Inherited selection |
| `ui_pack_f_icon_wrench` | 8 | 32×32 | Inherited selection |
| `ui_pack_f_icon_research` | 0 | 32×32 | Inherited selection |
| `ui_pack_f_icon_mission` | 0 | 32×32 | Inherited selection |
| `ui_pack_f_icon_location` | 36 | 32×32 | Inherited selection |
| `ui_pack_f_icon_temperature` | 1 | 32×32 | Inherited selection |
| `ui_pack_f_icon_pressure` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_solar` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_habitat` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_greens_seed` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_fresh_greens` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_dry_ration` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_check` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_database` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_icon_comms` | 0 | 32×32 | Recovered completed job |
| `ui_pack_f_menu_earth` | 0 | 96×96 | Inherited selection |
| `ui_pack_f_menu_lunar_ridge` | 0 | 792×96 | Inherited selection |

No generation jobs or paid image transformations were requested in this recovery. Validation checks native sizes, binary icon alpha, absence of mipmaps, source/runtime hashes and exact decoded RGBA after Godot import. Disabled Godot alpha-border rewriting on Pack F imports; PNG artwork bytes remain unchanged. Each reference uses native nearest filtering.

## Complete native PNG list

Dimensions are full file canvases: animation sheet widths do not represent character frame widths; building canvases do not determine ground footprints.

### assets/buildings/base_pack_c

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `airlock_module.png` | 160×160 | 12536 |
| `battery_power_unit.png` | 96×96 | 3290 |
| `communications_antenna.png` | 96×160 | 4208 |
| `light_beacon_pole.png` | 64×128 | 1837 |
| `small_connector_utility_box.png` | 64×64 | 2325 |
| `small_habitat_module.png` | 192×192 | 17679 |
| `solar_panel_array.png` | 160×128 | 13706 |
| `storage_crate_large.png` | 128×128 | 5232 |
| `utility_oxygen_tank.png` | 96×128 | 4098 |
| `work_control_console.png` | 96×96 | 2189 |

### assets/characters/astronaut/run

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `e.png` | 448×64 | 9717 |
| `n.png` | 448×64 | 8830 |
| `ne.png` | 448×64 | 9766 |
| `nw.png` | 448×64 | 10959 |
| `s.png` | 448×64 | 11316 |
| `se.png` | 448×64 | 11206 |
| `sw.png` | 448×64 | 14507 |
| `w.png` | 448×64 | 10214 |

### assets/characters/astronaut/walk

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `e.png` | 448×64 | 8684 |
| `n.png` | 448×64 | 8718 |
| `ne.png` | 448×64 | 8598 |
| `nw.png` | 448×64 | 8846 |
| `s.png` | 448×64 | 9482 |
| `se.png` | 448×64 | 9503 |
| `sw.png` | 448×64 | 11424 |
| `w.png` | 448×64 | 10415 |

### assets/characters/chiwis/run

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `e.png` | 256×64 | 9446 |
| `n.png` | 256×64 | 7040 |
| `ne.png` | 256×64 | 9976 |
| `nw.png` | 256×64 | 7930 |
| `s.png` | 256×64 | 7548 |
| `se.png` | 256×64 | 8823 |
| `sw.png` | 256×64 | 9401 |
| `w.png` | 256×64 | 9841 |

### assets/characters/chiwis/walk

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `e.png` | 256×64 | 10351 |
| `n.png` | 256×64 | 7149 |
| `ne.png` | 256×64 | 9568 |
| `nw.png` | 256×64 | 7571 |
| `s.png` | 256×64 | 7275 |
| `se.png` | 256×64 | 9484 |
| `sw.png` | 256×64 | 10395 |
| `w.png` | 256×64 | 8396 |

### assets/environment/props_pack_b

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `beacon_marker.png` | 64×64 | 1213 |
| `broken_machine_part.png` | 64×64 | 2501 |
| `lunar_sample.png` | 64×64 | 1766 |
| `metal_scrap.png` | 64×64 | 2006 |
| `rock_cluster.png` | 64×64 | 2277 |
| `small_equipment_box.png` | 64×64 | 1862 |
| `small_resource_canister.png` | 64×64 | 1543 |
| `supply_pack.png` | 64×64 | 1999 |
| `tool_case.png` | 64×64 | 2626 |
| `utility_crate.png` | 64×64 | 2308 |

### assets/pixellab/source/base_pack_c

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `airlock_module.png` | 160×160 | 7362 |
| `airlock_module_v2.png` | 160×160 | 12536 |
| `astronaut_style_reference.png` | 64×64 | 1492 |
| `battery_power_unit.png` | 96×96 | 3290 |
| `communications_antenna.png` | 96×160 | 4208 |
| `light_beacon_pole.png` | 64×128 | 1837 |
| `small_connector_utility_box.png` | 64×64 | 2325 |
| `small_habitat_module.png` | 192×192 | 7587 |
| `small_habitat_module_v2.png` | 192×192 | 17679 |
| `solar_panel_array.png` | 160×128 | 4622 |
| `solar_panel_array_v2.png` | 160×128 | 13706 |
| `storage_crate_large.png` | 128×128 | 5232 |
| `utility_oxygen_tank.png` | 96×128 | 4098 |
| `work_control_console.png` | 96×96 | 2189 |

### assets/pixellab/source/lander_pack_d

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `deployed_ramp.png` | 128×128 | 1039 |
| `landing_marker_decal.png` | 288×160 | 1050 |
| `moon_lander.png` | 320×320 | 33011 |
| `support_cargo_container.png` | 64×64 | 1518 |

### assets/pixellab/source/props_pack_b

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `astronaut_style_reference.png` | 64×64 | 1492 |
| `beacon_marker.png` | 64×64 | 1213 |
| `broken_machine_part.png` | 64×64 | 2816 |
| `broken_machine_part_v2.png` | 64×64 | 2501 |
| `lunar_sample.png` | 64×64 | 1766 |
| `metal_scrap.png` | 64×64 | 2006 |
| `rock_cluster.png` | 64×64 | 2272 |
| `rock_cluster_v2.png` | 64×64 | 2040 |
| `rock_cluster_v3.png` | 64×64 | 1494 |
| `rock_cluster_v4.png` | 64×64 | 2277 |
| `small_equipment_box.png` | 64×64 | 1862 |
| `small_resource_canister.png` | 64×64 | 1543 |
| `supply_pack.png` | 64×64 | 1972 |
| `supply_pack_v2.png` | 64×64 | 1999 |
| `tool_case.png` | 64×64 | 2403 |
| `tool_case_v2.png` | 64×64 | 2626 |
| `utility_crate.png` | 64×64 | 2308 |

### assets/pixellab/source/terrain_pack_e

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `base_floor_edge_tile.png` | 64×32 | 252 |
| `base_floor_edge_tile_ne.png` | 64×32 | 242 |
| `base_floor_edge_tile_nw.png` | 64×32 | 218 |
| `base_floor_edge_tile_sw.png` | 64×32 | 253 |
| `base_floor_panel_tile.png` | 64×32 | 417 |
| `dark_basalt_patch_overlay.png` | 64×32 | 2309 |
| `dark_basalt_patch_overlay_v2.png` | 64×32 | 434 |
| `hazard_stripe_floor_tile.png` | 64×32 | 557 |
| `landing_marked_ground_tile.png` | 64×32 | 644 |
| `rocky_patch_overlay.png` | 64×32 | 1346 |
| `rocky_patch_overlay_v2.png` | 64×32 | 404 |
| `small_crater_overlay.png` | 64×32 | 2054 |
| `small_crater_overlay_v2.png` | 64×32 | 493 |
| `small_dust_debris_overlay.png` | 64×32 | 2121 |
| `small_dust_debris_overlay_v2.png` | 64×32 | 272 |
| `utility_floor_pad_tile.png` | 64×32 | 518 |
| `worn_footpath_tile.png` | 64×32 | 370 |

### assets/pixellab/source/ui_pack_a

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `button_hover.png` | 96×32 | 488 |
| `button_hover_v2.png` | 96×32 | 497 |
| `button_hover_v3.png` | 96×32 | 853 |
| `button_normal.png` | 96×32 | 517 |
| `button_pressed.png` | 96×32 | 563 |
| `button_pressed_v2.png` | 96×32 | 561 |
| `button_pressed_v3.png` | 96×32 | 1293 |
| `cursor_selector.png` | 16×16 | 271 |
| `divider.png` | 128×16 | 591 |
| `divider_v2.png` | 128×16 | 265 |
| `icon_cardiac.png` | 32×32 | 444 |
| `icon_defense.png` | 32×32 | 432 |
| `icon_emotion.png` | 32×32 | 292 |
| `icon_frame.png` | 40×40 | 585 |
| `icon_frame_v2.png` | 40×40 | 364 |
| `icon_health.png` | 32×32 | 259 |
| `icon_inventory.png` | 32×32 | 469 |
| `icon_lunar_sample.png` | 32×32 | 402 |
| `icon_metal_scrap.png` | 32×32 | 525 |
| `icon_radiation.png` | 32×32 | 440 |
| `icon_sleep.png` | 32×32 | 415 |
| `icon_supply_tool.png` | 32×32 | 377 |
| `interaction_prompt.png` | 160×32 | 508 |
| `inventory_slot_normal.png` | 48×48 | 458 |
| `inventory_slot_selected.png` | 48×48 | 516 |
| `inventory_slot_selected_v2.png` | 48×48 | 345 |
| `inventory_slot_selected_v3.png` | 48×48 | 568 |
| `notification_panel.png` | 192×64 | 795 |
| `notification_panel_v2.png` | 192×64 | 587 |
| `panel_large.png` | 256×192 | 785 |
| `panel_large_v2.png` | 256×192 | 1558 |
| `panel_small.png` | 128×64 | 575 |
| `tab_marker.png` | 32×16 | 258 |

### assets/pixellab/source/ui_pack_f

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `icon_air_candidate_16.png` | 32×32 | 509 |
| `icon_battery_candidate_7.png` | 32×32 | 267 |
| `icon_carbon_dioxide_candidate_0.png` | 32×32 | 361 |
| `icon_check_candidate_0.png` | 32×32 | 242 |
| `icon_comms_candidate_0.png` | 32×32 | 332 |
| `icon_database_candidate_0.png` | 32×32 | 369 |
| `icon_dry_ration_candidate_0.png` | 32×32 | 371 |
| `icon_fatigue_candidate_42.png` | 32×32 | 336 |
| `icon_fresh_greens_candidate_0.png` | 32×32 | 439 |
| `icon_gear_candidate_9.png` | 32×32 | 478 |
| `icon_greenhouse_candidate_3.png` | 32×32 | 383 |
| `icon_greens_seed_candidate_0.png` | 32×32 | 326 |
| `icon_habitat_candidate_0.png` | 32×32 | 395 |
| `icon_location_candidate_36.png` | 32×32 | 429 |
| `icon_mission_candidate_0.png` | 32×32 | 293 |
| `icon_oxygen_candidate_23.png` | 32×32 | 381 |
| `icon_power_candidate_43.png` | 32×32 | 326 |
| `icon_pressure_candidate_0.png` | 32×32 | 464 |
| `icon_research_candidate_0.png` | 32×32 | 303 |
| `icon_solar_candidate_0.png` | 32×32 | 466 |
| `icon_temperature_candidate_1.png` | 32×32 | 403 |
| `icon_warning_candidate_12.png` | 32×32 | 343 |
| `icon_water_candidate_5.png` | 32×32 | 411 |
| `icon_wrench_candidate_8.png` | 32×32 | 422 |
| `menu_earth_candidate_0.png` | 96×96 | 5277 |
| `menu_lunar_ridge_candidate_0.png` | 792×96 | 3324 |

### assets/terrain/expansion_e

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `base_floor_edge_tile.png` | 64×32 | 252 |
| `base_floor_edge_tile_ne.png` | 64×32 | 242 |
| `base_floor_edge_tile_nw.png` | 64×32 | 218 |
| `base_floor_edge_tile_sw.png` | 64×32 | 253 |
| `base_floor_panel_tile.png` | 64×32 | 417 |
| `dark_basalt_patch_overlay.png` | 64×32 | 434 |
| `hazard_stripe_floor_tile.png` | 64×32 | 557 |
| `landing_marked_ground_tile.png` | 64×32 | 644 |
| `rocky_patch_overlay.png` | 64×32 | 404 |
| `small_crater_overlay.png` | 64×32 | 493 |
| `small_dust_debris_overlay.png` | 64×32 | 272 |
| `terrain_expansion_atlas.png` | 256×128 | 3371 |
| `utility_floor_pad_tile.png` | 64×32 | 518 |
| `worn_footpath_tile.png` | 64×32 | 370 |

### assets/terrain/moon

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `moon_regolith_atlas_4x3.png` | 256×96 | 15774 |

### assets/ui/ui_pack_a

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `button_hover.png` | 96×32 | 853 |
| `button_normal.png` | 96×32 | 517 |
| `button_pressed.png` | 96×32 | 1293 |
| `cursor_selector.png` | 16×16 | 271 |
| `divider.png` | 128×16 | 265 |
| `icon_cardiac.png` | 32×32 | 444 |
| `icon_defense.png` | 32×32 | 432 |
| `icon_emotion.png` | 32×32 | 292 |
| `icon_frame.png` | 40×40 | 364 |
| `icon_health.png` | 32×32 | 259 |
| `icon_inventory.png` | 32×32 | 469 |
| `icon_lunar_sample.png` | 32×32 | 402 |
| `icon_metal_scrap.png` | 32×32 | 525 |
| `icon_radiation.png` | 32×32 | 440 |
| `icon_sleep.png` | 32×32 | 415 |
| `icon_supply_tool.png` | 32×32 | 377 |
| `interaction_prompt.png` | 160×32 | 508 |
| `inventory_slot_normal.png` | 48×48 | 458 |
| `inventory_slot_selected.png` | 48×48 | 568 |
| `notification_panel.png` | 192×64 | 587 |
| `panel_large.png` | 256×192 | 1558 |
| `panel_small.png` | 128×64 | 575 |
| `tab_marker.png` | 32×16 | 258 |

### assets/ui/ui_pack_f

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `icon_air.png` | 32×32 | 509 |
| `icon_battery.png` | 32×32 | 267 |
| `icon_carbon_dioxide.png` | 32×32 | 361 |
| `icon_check.png` | 32×32 | 242 |
| `icon_comms.png` | 32×32 | 332 |
| `icon_database.png` | 32×32 | 369 |
| `icon_dry_ration.png` | 32×32 | 371 |
| `icon_fatigue.png` | 32×32 | 336 |
| `icon_fresh_greens.png` | 32×32 | 439 |
| `icon_gear.png` | 32×32 | 478 |
| `icon_greenhouse.png` | 32×32 | 383 |
| `icon_greens_seed.png` | 32×32 | 326 |
| `icon_habitat.png` | 32×32 | 395 |
| `icon_location.png` | 32×32 | 429 |
| `icon_mission.png` | 32×32 | 293 |
| `icon_oxygen.png` | 32×32 | 381 |
| `icon_power.png` | 32×32 | 326 |
| `icon_pressure.png` | 32×32 | 464 |
| `icon_research.png` | 32×32 | 303 |
| `icon_solar.png` | 32×32 | 466 |
| `icon_temperature.png` | 32×32 | 403 |
| `icon_warning.png` | 32×32 | 343 |
| `icon_water.png` | 32×32 | 411 |
| `icon_wrench.png` | 32×32 | 422 |
| `menu_earth.png` | 96×96 | 5277 |
| `menu_lunar_ridge.png` | 792×96 | 3324 |

### assets/vehicles/lander_pack_d

| Filename | Canvas | Bytes |
| --- | --- | --- |
| `deployed_ramp.png` | 128×128 | 1039 |
| `landing_marker_decal.png` | 288×160 | 1050 |
| `moon_lander.png` | 320×320 | 33011 |
| `support_cargo_container.png` | 64×64 | 1518 |

## Standards, sources and licensing

Read docs/ART_BIBLE.md, art/asset_standards.json, docs/isometric_standards.md and assets/pixellab/README.md before changes. Existing briefs/imports for Packs A–E, Moon terrain and Pixelorama characters/runs remain in art/. Do not modify original external PXO or asset-pack files. Source PNGs under assets/pixellab/source are excluded from Godot scanning by the existing .gdignore marker.

| Font / license | Path |
| --- | --- |
| departure_mono_OFL.txt | `assets/ui/fonts/departure_mono_OFL.txt` |
| departure_mono_regular.otf | `assets/ui/fonts/departure_mono_regular.otf` |
| silkscreen_bold.ttf | `assets/ui/fonts/silkscreen_bold.ttf` |
| silkscreen_OFL.txt | `assets/ui/fonts/silkscreen_OFL.txt` |
| silkscreen_regular.ttf | `assets/ui/fonts/silkscreen_regular.ttf` |

Godot engine credit and scientific citations are retained. Font OFL files stay with the fonts. NASA/JPL are reference sources, not endorsers. Public redistribution clearance for independently supplied art and project-wide licensing remain separate publisher decisions; this phase did not publish, re-export or alter the protected demo.


<!-- lunar-exterior-library:start -->

## Lunar exterior library — Phase 0.8G1

Prepared **41 reusable native 2D prefabs and 41 metadata Resources**: 24 reused objects, four accepted new exterior sprites and thirteen existing terrain/overlay components. Production map, startup, controllers, UI, inventory, tile atlas and scientific registry are unchanged. Native sprite frames remain 64×64 and ground tiles 64×32.

### Asset readiness and geometry

| Asset / prefab | Category | Origin | Canvas px | Footprint tiles | Ground pivot px | Collision |
| --- | --- | --- | --- | --- | --- | --- |
| [Small Habitat Module](../scenes/exterior/small_habitat_module.tscn) | base | Reused | 192×192 | 3×2 | 93, 169 | Ground-clearance envelope |
| [Airlock Module](../scenes/exterior/airlock_module.tscn) | base | Reused | 160×160 | 2×2 | 81, 154 | Ground-clearance envelope |
| [Solar Panel Array](../scenes/exterior/solar_panel_array.tscn) | base | Reused | 160×128 | 2×2 | 67, 118 | Ground-clearance envelope |
| [Battery Power Unit](../scenes/exterior/battery_power_unit.tscn) | base | Reused | 96×96 | 1×1 | 42, 75 | Ground-clearance envelope |
| [Storage Crate Large](../scenes/exterior/storage_crate_large.tscn) | base | Reused | 128×128 | 2×1 | 46, 92 | Ground-clearance envelope |
| [Utility Oxygen Tank](../scenes/exterior/utility_oxygen_tank.tscn) | base | Reused | 96×128 | 1×1 | 45, 106 | Ground-clearance envelope |
| [Communications Antenna](../scenes/exterior/communications_antenna.tscn) | base | Reused | 96×160 | 1×1 | 43, 122 | Ground-clearance envelope |
| [Work Control Console](../scenes/exterior/work_control_console.tscn) | base | Reused | 96×96 | 1×1 | 43, 73 | Ground-clearance envelope |
| [Light Beacon Pole](../scenes/exterior/light_beacon_pole.tscn) | base | Reused | 64×128 | 1×1 | 41, 99 | Ground-clearance envelope |
| [Small Connector Utility Box](../scenes/exterior/small_connector_utility_box.tscn) | base | Reused | 64×64 | 1×1 | 32, 51 | Ground-clearance envelope |
| [Lunar Sample](../scenes/exterior/lunar_sample.tscn) | prop | Reused | 64×64 | 1×1 | 32, 52 | None |
| [Metal Scrap](../scenes/exterior/metal_scrap.tscn) | prop | Reused | 64×64 | 1×1 | 32, 48 | None |
| [Supply Pack](../scenes/exterior/supply_pack.tscn) | prop | Reused | 64×64 | 1×1 | 32, 49 | None |
| [Small Equipment Box](../scenes/exterior/small_equipment_box.tscn) | prop | Reused | 64×64 | 1×1 | 31, 53 | Ground-clearance envelope |
| [Tool Case](../scenes/exterior/tool_case.tscn) | prop | Reused | 64×64 | 1×1 | 32, 53 | Ground-clearance envelope |
| [Small Resource Canister](../scenes/exterior/small_resource_canister.tscn) | prop | Reused | 64×64 | 1×1 | 31, 54 | Ground-clearance envelope |
| [Utility Crate](../scenes/exterior/utility_crate.tscn) | prop | Reused | 64×64 | 1×1 | 31, 56 | Ground-clearance envelope |
| [Rock Cluster](../scenes/exterior/rock_cluster.tscn) | prop | Reused | 64×64 | 1×1 | 32, 51 | Ground-clearance envelope |
| [Broken Machine Part](../scenes/exterior/broken_machine_part.tscn) | prop | Reused | 64×64 | 1×1 | 31, 52 | Ground-clearance envelope |
| [Beacon Marker](../scenes/exterior/beacon_marker.tscn) | prop | Reused | 64×64 | 1×1 | 32, 57 | None |
| [Moon Lander](../scenes/exterior/moon_lander.tscn) | lander | Reused | 320×320 | 4×4 | 160, 284 | Ground-clearance envelope |
| [Deployed Ramp](../scenes/exterior/deployed_ramp.tscn) | lander | Reused | 128×128 | 2×1 | 86, 106 | None |
| [Landing Marker Decal](../scenes/exterior/landing_marker_decal.tscn) | lander | Reused | 288×160 | 4×4 | 144, 144 | None |
| [Support Cargo Container](../scenes/exterior/support_cargo_container.tscn) | lander | Reused | 64×64 | 1×1 | 33, 53 | Ground-clearance envelope |
| [Small Crater Overlay](../scenes/exterior/small_crater_overlay.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Rocky Patch Overlay](../scenes/exterior/rocky_patch_overlay.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Dark Basalt Patch Overlay](../scenes/exterior/dark_basalt_patch_overlay.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Worn Footpath Tile](../scenes/exterior/worn_footpath_tile.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Base Floor Panel Tile](../scenes/exterior/base_floor_panel_tile.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Base Floor Edge Tile](../scenes/exterior/base_floor_edge_tile.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Base Floor Edge Tile Sw](../scenes/exterior/base_floor_edge_tile_sw.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Base Floor Edge Tile Nw](../scenes/exterior/base_floor_edge_tile_nw.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Base Floor Edge Tile Ne](../scenes/exterior/base_floor_edge_tile_ne.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Utility Floor Pad Tile](../scenes/exterior/utility_floor_pad_tile.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Small Dust Debris Overlay](../scenes/exterior/small_dust_debris_overlay.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Landing Marked Ground Tile](../scenes/exterior/landing_marked_ground_tile.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Hazard Stripe Floor Tile](../scenes/exterior/hazard_stripe_floor_tile.tscn) | ground | Reused | 64×32 | 1×1 | 32, 16 | None |
| [Radiator Bank](../scenes/exterior/radiator_bank.tscn) | new_equipment | New PixelLab | 128×128 | 2×1 | 62, 103 | Ground-clearance envelope |
| [Eclss Service Cabinet](../scenes/exterior/eclss_service_cabinet.tscn) | new_equipment | New PixelLab | 96×96 | 1×1 | 51, 79 | Ground-clearance envelope |
| [Field Sensor Tripod](../scenes/exterior/field_sensor_tripod.tscn) | new_equipment | New PixelLab | 96×96 | 1×1 | 43, 82 | Ground-clearance envelope |
| [Greenhouse Module](../scenes/exterior/greenhouse_module.tscn) | new_equipment | New PixelLab | 192×192 | 3×2 | 92, 168 | Ground-clearance envelope |

All rows are **READY for the isolated library/preview**, visually reviewed at native scale. Final production placement is Phase 0.9 work. Full sprite bounds, logical occupied cells, GridOrigin, collider polygon, navigation_reserved_cells, access/service markers, state support and optional future binding IDs are explicit in [lunar_exterior_library.json](../art/imports/lunar_exterior_library.json) and the corresponding resources/exterior files. Footprints are declared design budgets, not NASA dimensions. Collision has half-cell ground-hardware clearance; navigation must reserve the intersected outer cell ring. Markers are not working interaction scripts. Fifteen equipment prefabs support optional static service-state indicators; pure decorative roots have no scripts.

### Original sources and runtime paths

| Asset | Original / preserved source | Runtime PNG |
| --- | --- | --- |
| `small_habitat_module` | `assets/pixellab/source/base_pack_c/small_habitat_module_v2.png` | `assets/buildings/base_pack_c/small_habitat_module.png` |
| `airlock_module` | `assets/pixellab/source/base_pack_c/airlock_module_v2.png` | `assets/buildings/base_pack_c/airlock_module.png` |
| `solar_panel_array` | `assets/pixellab/source/base_pack_c/solar_panel_array_v2.png` | `assets/buildings/base_pack_c/solar_panel_array.png` |
| `battery_power_unit` | `assets/pixellab/source/base_pack_c/battery_power_unit.png` | `assets/buildings/base_pack_c/battery_power_unit.png` |
| `storage_crate_large` | `assets/pixellab/source/base_pack_c/storage_crate_large.png` | `assets/buildings/base_pack_c/storage_crate_large.png` |
| `utility_oxygen_tank` | `assets/pixellab/source/base_pack_c/utility_oxygen_tank.png` | `assets/buildings/base_pack_c/utility_oxygen_tank.png` |
| `communications_antenna` | `assets/pixellab/source/base_pack_c/communications_antenna.png` | `assets/buildings/base_pack_c/communications_antenna.png` |
| `work_control_console` | `assets/pixellab/source/base_pack_c/work_control_console.png` | `assets/buildings/base_pack_c/work_control_console.png` |
| `light_beacon_pole` | `assets/pixellab/source/base_pack_c/light_beacon_pole.png` | `assets/buildings/base_pack_c/light_beacon_pole.png` |
| `small_connector_utility_box` | `assets/pixellab/source/base_pack_c/small_connector_utility_box.png` | `assets/buildings/base_pack_c/small_connector_utility_box.png` |
| `lunar_sample` | `assets/pixellab/source/props_pack_b/lunar_sample.png` | `assets/environment/props_pack_b/lunar_sample.png` |
| `metal_scrap` | `assets/pixellab/source/props_pack_b/metal_scrap.png` | `assets/environment/props_pack_b/metal_scrap.png` |
| `supply_pack` | `assets/pixellab/source/props_pack_b/supply_pack_v2.png` | `assets/environment/props_pack_b/supply_pack.png` |
| `small_equipment_box` | `assets/pixellab/source/props_pack_b/small_equipment_box.png` | `assets/environment/props_pack_b/small_equipment_box.png` |
| `tool_case` | `assets/pixellab/source/props_pack_b/tool_case_v2.png` | `assets/environment/props_pack_b/tool_case.png` |
| `small_resource_canister` | `assets/pixellab/source/props_pack_b/small_resource_canister.png` | `assets/environment/props_pack_b/small_resource_canister.png` |
| `utility_crate` | `assets/pixellab/source/props_pack_b/utility_crate.png` | `assets/environment/props_pack_b/utility_crate.png` |
| `rock_cluster` | `assets/pixellab/source/props_pack_b/rock_cluster_v4.png` | `assets/environment/props_pack_b/rock_cluster.png` |
| `broken_machine_part` | `assets/pixellab/source/props_pack_b/broken_machine_part_v2.png` | `assets/environment/props_pack_b/broken_machine_part.png` |
| `beacon_marker` | `assets/pixellab/source/props_pack_b/beacon_marker.png` | `assets/environment/props_pack_b/beacon_marker.png` |
| `moon_lander` | `assets/pixellab/source/lander_pack_d/moon_lander.png` | `assets/vehicles/lander_pack_d/moon_lander.png` |
| `deployed_ramp` | `assets/pixellab/source/lander_pack_d/deployed_ramp.png` | `assets/vehicles/lander_pack_d/deployed_ramp.png` |
| `landing_marker_decal` | `assets/pixellab/source/lander_pack_d/landing_marker_decal.png` | `assets/vehicles/lander_pack_d/landing_marker_decal.png` |
| `support_cargo_container` | `assets/pixellab/source/lander_pack_d/support_cargo_container.png` | `assets/vehicles/lander_pack_d/support_cargo_container.png` |
| `small_crater_overlay` | `assets/pixellab/source/terrain_pack_e/small_crater_overlay_v2.png` | `assets/terrain/expansion_e/small_crater_overlay.png` |
| `rocky_patch_overlay` | `assets/pixellab/source/terrain_pack_e/rocky_patch_overlay_v2.png` | `assets/terrain/expansion_e/rocky_patch_overlay.png` |
| `dark_basalt_patch_overlay` | `assets/pixellab/source/terrain_pack_e/dark_basalt_patch_overlay_v2.png` | `assets/terrain/expansion_e/dark_basalt_patch_overlay.png` |
| `worn_footpath_tile` | `assets/pixellab/source/terrain_pack_e/worn_footpath_tile.png` | `assets/terrain/expansion_e/worn_footpath_tile.png` |
| `base_floor_panel_tile` | `assets/pixellab/source/terrain_pack_e/base_floor_panel_tile.png` | `assets/terrain/expansion_e/base_floor_panel_tile.png` |
| `base_floor_edge_tile` | `assets/pixellab/source/terrain_pack_e/base_floor_edge_tile.png` | `assets/terrain/expansion_e/base_floor_edge_tile.png` |
| `base_floor_edge_tile_sw` | `assets/pixellab/source/terrain_pack_e/base_floor_edge_tile_sw.png` | `assets/terrain/expansion_e/base_floor_edge_tile_sw.png` |
| `base_floor_edge_tile_nw` | `assets/pixellab/source/terrain_pack_e/base_floor_edge_tile_nw.png` | `assets/terrain/expansion_e/base_floor_edge_tile_nw.png` |
| `base_floor_edge_tile_ne` | `assets/pixellab/source/terrain_pack_e/base_floor_edge_tile_ne.png` | `assets/terrain/expansion_e/base_floor_edge_tile_ne.png` |
| `utility_floor_pad_tile` | `assets/pixellab/source/terrain_pack_e/utility_floor_pad_tile.png` | `assets/terrain/expansion_e/utility_floor_pad_tile.png` |
| `small_dust_debris_overlay` | `assets/pixellab/source/terrain_pack_e/small_dust_debris_overlay_v2.png` | `assets/terrain/expansion_e/small_dust_debris_overlay.png` |
| `landing_marked_ground_tile` | `assets/pixellab/source/terrain_pack_e/landing_marked_ground_tile.png` | `assets/terrain/expansion_e/landing_marked_ground_tile.png` |
| `hazard_stripe_floor_tile` | `assets/pixellab/source/terrain_pack_e/hazard_stripe_floor_tile.png` | `assets/terrain/expansion_e/hazard_stripe_floor_tile.png` |
| `radiator_bank` | `assets/pixellab/source/exterior_g1/radiator_bank.png` | `assets/buildings/exterior_g1/radiator_bank.png` |
| `eclss_service_cabinet` | `assets/pixellab/source/exterior_g1/eclss_service_cabinet.png` | `assets/buildings/exterior_g1/eclss_service_cabinet.png` |
| `field_sensor_tripod` | `assets/pixellab/source/exterior_g1/field_sensor_tripod.png` | `assets/buildings/exterior_g1/field_sensor_tripod.png` |
| `greenhouse_module` | `assets/pixellab/source/exterior_g1/greenhouse_module_v2.png` | `assets/buildings/exterior_g1/greenhouse_module.png` |

Existing sources were preserved byte-for-byte. The source archive contains five new candidates but only four were promoted: the first 192×192 greenhouse candidate has 92×82 visible bounds and an undersized crew hatch, is NEEDS_REFINEMENT, and remains unintegrated. A one-generation Pixen replacement has 160×141 visible bounds on its unchanged 192×192 canvas. Accepted new canvases/anchors: greenhouse 192×192/(92,168), radiator 128×128/(62,103), ECLSS cabinet 96×96/(51,79), field sensor 96×96/(43,82). No local resizing, crop, erasure or recoloring was applied.

### External/source audit and concept coverage

[exterior_source_audit.json](../art/imports/exterior_source_audit.json) classifies 162 relevant local/external source files: 118 READY, 43 UNUSED, 1 NEEDS_REFINEMENT. 43 hash-identical groups are marked DUPLICATE_CANDIDATE without deleting anything. Selected source/runtime mirrors remain intentional. External files use external:// relative references; originals are read-only. External character/run/walk PXO sources and the original Moon terrain source are available; unused standard/seam-fixed formats and source alternatives remain retained. The existing 4×3 terrain atlas still supplies all twelve variants.

| Concept | Status | Prepared solution / gap |
| --- | --- | --- |
| main habitat / research / engineering / emergency shelter | READY | Reuse the existing small habitat shell for these shared module roles; rooms remain the existing independent cutaway architecture, not a one-to-one exterior blueprint. |
| external pressure door | READY | Closed doors are embedded in the supplied habitat/airlock artwork; InteractionAnchor reserves an access point. No new vacuum door logic. |
| pressurized connecting passage | MISSING | Separate tube/corridor PNG is not available; do not imply utility_box is a pressurized corridor. Reserve a clear linkage area for Phase 0.9. |
| open/closed hatch animation | MISSING | Only closed supplied texture is prepared; no opening/gas/collision toggling is invented. |
| exterior cables and cable supports | MISSING | Reuse connector/utility box for junctions; continuous cable runs remain an explicit noncritical art gap. |
| transport pallet / packaged ground support | NEEDS_INTEGRATION | Existing crates, tool cases, canisters and support cargo provide reusable components; no new pallet artwork is essential. |
| airlock approach / safety / navigation / service paths | READY | Existing beacon, pole light, hazard stripe pad and footpath overlays; labels are Godot controls. |
| water / pressure / monitoring / maintenance equipment | READY | Tank, sealed ECLSS cabinet, console, sensor and service markers are fictional near-future presentations; no engineering ratings. |

Greenhouse exterior, radiators, ECLSS service cabinet and a field sensor now cover the measured gaps. Storage uses crates/cargo rather than an unnecessary new warehouse; communications uses the existing dish/console; scientific kits reuse cases/canisters. Research, engineering and shelter may reuse the existing habitat shell in future module placement. No claim is made that one exterior sprite contains every abstract cutaway room.

### Preview and integration contract

F6 `scenes/development/lunar_exterior_preview.tscn`. Keys 1–8 select Habitat, Power, Lander, Science, Props, Safety, Sorting and States; G toggles guides. White = measured pivot; green = logical footprint; terracotta = collision clearance; cyan = access; amber = service. Original character sprites are repeated only as gallery scale references, not new gameplay characters. The ramp is shown separately; its source attachment metadata is retained for later assembly.

The graphical test records eight 960×540 views and a separate 1920×2160 full native-pixel atlas. No fractional zoom or whole-art downscaling is used. Single-root Y-sorting is demonstrated; detailed leg/underbody traversal, split roof occlusion, pressure passage art, open-hatch animation, continuous cables and final habitat/lander assembly remain explicit integration/art gaps.

Rebuild/measure/audit commands: [tools/exterior/README.md](../tools/exterior/README.md). New source provenance: [exterior_g1.json](../art/imports/exterior_g1.json), [generation jobs](../assets/pixellab/source/exterior_g1/generation_jobs.json). Five submitted jobs cost **23 subscription generations**, including one rejected six-generation candidate and its one-generation replacement; USD credit charge was zero. No suitable existing asset was regenerated.

<!-- lunar-exterior-library:end -->


<!-- INTERIORS_G2_BEGIN -->

## Phase 0.8G2 — Current furnished interior library

Nine isolated compartments cover thirteen production categories. **34 native prop scenes/Resources** use 18 previously accepted G2 images, seven new furnishings from this extension, and nine reused Pack B/C/G1 props. Four of the previous 18 are plant overlays. Existing three Pack E floor components remain native 64×32 tiles. Twelve reusable module scenes comprise three floors and nine wall/door/cable types. The renderer now uses actual baked structural PNGs.

| Asset | Origin | Canvas (px) | Footprint / anchor | Readiness |
| --- | --- | --- | --- | --- |
| `sleep_bunk` | Previous accepted G2 | 96×96 | 2×1 / 28, 85 | READY in isolated preview |
| `galley_station` | Previous accepted G2 | 96×96 | 2×1 / 44, 89 | READY in isolated preview |
| `sanitation_station` | Previous accepted G2 | 96×96 | 1×1 / 47, 90 | READY in isolated preview |
| `habitat_table` | Previous accepted G2 | 96×96 | 2×1 / 36, 83 | READY in isolated preview |
| `eva_rack` | Previous accepted G2 | 96×96 | 2×1 / 48, 89 | READY in isolated preview |
| `medical_station` | Previous accepted G2 | 96×96 | 2×1 / 41, 86 | READY in isolated preview |
| `sample_bench` | Previous accepted G2 | 96×96 | 2×1 / 49, 86 | READY in isolated preview |
| `maintenance_bench` | Previous accepted G2 | 96×96 | 2×1 / 36, 77 | READY in isolated preview |
| `storage_rack_empty` | Previous accepted G2 | 96×96 | 2×1 / 48, 83 | READY in isolated preview |
| `storage_rack_loaded` | Previous accepted G2 | 96×96 | 2×1 / 37, 87 | READY in isolated preview |
| `exercise_station` | Previous accepted G2 | 96×96 | 1×1 / 47, 93 | READY in isolated preview |
| `growing_tray_empty` | Previous accepted G2 | 96×96 | 2×1 / 62, 88 | READY in isolated preview |
| `water_dispenser` | Previous accepted G2 | 64×96 | 1×1 / 30, 92 | READY in isolated preview |
| `greens_germinating` | Previous accepted G2 | 64×64 | 0×0 / 26, 48 | READY in isolated preview |
| `greens_small` | Previous accepted G2 | 64×64 | 0×0 / 20, 51 | READY in isolated preview |
| `greens_intermediate` | Previous accepted G2 | 64×64 | 0×0 / 16, 53 | READY in isolated preview |
| `greens_mature` | Previous accepted G2 | 64×64 | 0×0 / 51, 58 | READY in isolated preview |
| `habitat_seat` | Previous accepted G2 | 64×64 | 1×1 / 31, 59 | READY in isolated preview |
| `service_wall_panel` | New extended G2 | 64×96 | 1×1 / 31, 82 | READY in isolated preview |
| `overhead_lamp` | New extended G2 | 64×32 | 0×0 / 32, 31 | READY in isolated preview |
| `filter_cartridges` | New extended G2 | 64×64 | 1×1 / 31, 58 | READY in isolated preview |
| `medical_storage` | New extended G2 | 64×96 | 1×1 / 28, 84 | READY in isolated preview |
| `nutrient_unit` | New extended G2 | 64×64 | 1×1 / 28, 55 | READY in isolated preview |
| `irrigation_unit` | New extended G2 | 64×64 | 1×1 / 31, 58 | READY in isolated preview |
| `personal_locker` | New extended G2 | 64×96 | 1×1 / 26, 87 | READY in isolated preview |
| `work_control_console` | Existing Pack B/C/G1 | 96×96 | 1×1 / 43, 73 | READY in isolated preview |
| `battery_power_unit` | Existing Pack B/C/G1 | 96×96 | 1×1 / 42, 75 | READY in isolated preview |
| `eclss_service_cabinet` | Existing Pack B/C/G1 | 96×96 | 1×1 / 51, 79 | READY in isolated preview |
| `utility_oxygen_tank` | Existing Pack B/C/G1 | 96×128 | 1×1 / 45, 106 | READY in isolated preview |
| `tool_case` | Existing Pack B/C/G1 | 64×64 | 1×1 / 32, 53 | READY in isolated preview |
| `supply_pack` | Existing Pack B/C/G1 | 64×64 | 1×1 / 32, 49 | READY in isolated preview |
| `small_resource_canister` | Existing Pack B/C/G1 | 64×64 | 1×1 / 31, 54 | READY in isolated preview |
| `small_equipment_box` | Existing Pack B/C/G1 | 64×64 | 1×1 / 31, 53 | READY in isolated preview |
| `small_connector_utility_box` | Existing Pack B/C/G1 | 64×64 | 1×1 / 32, 51 | READY in isolated preview |

All furnishing/plant sources and full runtime images remain byte-identical at unit scale. Bounds, individual static frame regions, ground/attachment anchors and provenance are in [interior_library.json](../art/imports/interior_library.json). Quantities, interactions and resource state remain in the existing services.

| Room | Grid size including boundary | Functional facilities |
| --- | --- | --- |
| `crew_airlock` | 8×7 | Crew airlock |
| `equipment_lock` | 8×7 | Equipment lock; Suit maintenance; Dust-removal station |
| `hub` | 8×9 | Main habitat / central corridor; Mission operations / communications |
| `living` | 8×8 | Sleeping quarters; Galley / food storage; Hygiene / waste compartment |
| `engineering` | 8×8 | Environmental control / ECLSS; Water processing / storage; Power distribution / engineering |
| `health_lab` | 8×8 | Medical / health monitoring; Exercise / rehabilitation; Science lab / sample storage |
| `greenhouse` | 8×7 | Greenhouse / hydroponics lab |
| `cargo` | 8×7 | Cargo / spare-parts storage |
| `shelter` | 6×6 | Protected emergency shelter |

The extended [spatial plan](../resources/data/lunar_base_art_layout.json) declares nine matching exterior envelopes, eight links and isolated port overrides. Room IDs/dimensions remain unchanged. Living galley moves to clear a doorway; health/science retains its prepared clear approach. The production habitat_layout.json is unchanged. Envelopes are explicit game placement budgets rather than measured pressurized volumes.

The two DailyLife trays display empty, seeded, germinating, small, intermediate and mature states. The four actual foliage PNGs represent one generic leafy-greens crop; there are no extra species, dead plants or invented health states. Existing resource consumption and finite yield are unchanged. Interior open/closed doors observe the existing interlock and shared collision/route thresholds.

The previous production batch used 24 generations (18 accepted, six rejected). This extension uses a separate 30-generation authorization. All original candidates and hashes are retained. Detailed prop/floor/room evidence is in [interior_source_audit.json](../art/imports/interior_source_audit.json); final limitations and validation are in [phase_0_8G2_lunar_base_art.md](phase_0_8G2_lunar_base_art.md). Alternate furniture facings and optional detailed accessories remain MISSING.

F6: `scenes/development/lunar_interior_preview.tscn`; F1–F9 selects rooms. WASD/E/Tab/I use the existing astronaut/session. Prepared rooms are registered only in an isolated fresh HabitatDirector. Normal startup and production world remain intact.

<!-- INTERIORS_G2_END -->


<!-- BASE_G2_EXTENDED_BEGIN -->

## Extended G2 — Modular lunar outpost

The [native transparent base image](../assets/buildings/base_g2/compositions/lunar_base_complete.png) and [terrain showcase](../assets/buildings/base_g2/compositions/lunar_base_showcase.png) are 2688×1536 PNG compositions rendered at 1×. They are presentation exports excluded from runtime scanning. The modular scene remains the gameplay-ready representation.

| Deliverable | Exact count / meaning |
| --- | --- |
| New finished art | 51 unique PNGs: 18 accepted PixelLab images and 33 original structural components |
| New PixelLab images | Five shell designs + six exterior connections/states + seven interior furnishings |
| Structural PNGs | 40 total: 33 READY; seven preserved roof/hull-wall draft supports UNUSED |
| Exterior prefabs | 15 definitions/scenes: nine module roles reusing five unique shells; six passage/hatch components |
| Existing exterior art in assembly | 15 original native images: twelve equipment/lander/cargo objects and three attached facade bays |
| Interior prefabs | 34; source origins listed above |
| Room scenes | Nine; dimensions retained |
| Manual exterior drafts | 35 PNGs retained: nine hulls, nine roof copies, sixteen technical passage cells and one atlas; excluded from finished count |
| Composition exports | Two; never counted as newly painted component art |
| New PNG files physically added | 125 including raw sources, runtime mirrors, rejected masks, drafts and composites; this is not a unique-finished-art count |
| Supplemental source audit | 125 PNG files; 17 intentional duplicate groups retained |

| Exterior role / asset | Native canvas | Logical footprint | Runtime source |
| --- | --- | --- | --- |
| `hull_crew_airlock` | 512×368 | 8×7 | `assets/buildings/base_g2/shells/shell_service.png` |
| `hull_equipment_lock` | 512×368 | 8×7 | `assets/buildings/base_g2/shells/shell_service.png` |
| `hull_hub` | 576×384 | 8×9 | `assets/buildings/base_g2/shells/shell_core.png` |
| `hull_living` | 544×384 | 8×8 | `assets/buildings/base_g2/shells/shell_habitat.png` |
| `hull_engineering` | 544×384 | 8×8 | `assets/buildings/base_g2/shells/shell_habitat.png` |
| `hull_health_lab` | 544×384 | 8×8 | `assets/buildings/base_g2/shells/shell_habitat.png` |
| `hull_greenhouse` | 512×400 | 8×7 | `assets/buildings/base_g2/shells/shell_greenhouse.png` |
| `hull_cargo` | 512×368 | 8×7 | `assets/buildings/base_g2/shells/shell_service.png` |
| `hull_shelter` | 416×320 | 6×6 | `assets/buildings/base_g2/shells/shell_shelter.png` |
| `pressure_junction` | 128×128 | 2×2 | `assets/buildings/base_g2/pressure_junction.png` |
| `pressure_hatch_closed` | 64×96 | 1×1 | `assets/buildings/base_g2/pressure_hatch_closed.png` |
| `pressure_passage` | 128×128 | 2×1 | `assets/buildings/base_g2/pressure_passage.png` |
| `pressure_hatch_open` | 64×96 | 1×1 | `assets/buildings/base_g2/pressure_hatch_open.png` |
| `pressure_passage_sw` | 128×128 | 1×2 | `assets/buildings/base_g2/pressure_passage_sw.png` |
| `pressure_elbow` | 128×128 | 2×2 | `assets/buildings/base_g2/pressure_elbow.png` |

Two oriented straight pressure sprites, one elbow, one junction and aligned open/closed exterior hatches are present. Fifteen cable-mask PNGs and a vertical riser are reusable; the final assembly uses visible native rounded passages. The angular atlas remains a hidden technical guide. Large shells use shared-texture depth strips and an actor cutaway guard. Exact coupling seals for every shell port and additional elbow/end-cap facings remain NEEDS_INTEGRATION/optional refinement.

PixelLab expenditure: **30 jobs / 30 subscription generations**: 15 small image requests, five shell creations and ten failed background-removal operations. Eighteen new creative images accepted, two creative candidates rejected, all ten provider masks rejected. Balance 3739.15 → 3709.15; $0.00 USD credits spent; phase budget remaining **0**. The large shell originals are untouched; local alpha preparation preserves canvas dimensions and every retained RGB value. [Generation ledger](../art/imports/base_generation_ledger.json), [native shell metadata](../art/imports/native_shells.json), [source audit](../art/imports/base_source_audit.json).

F6: `scenes/development/lunar_base_preview.tscn`. F1 entrance, F2 core, F3 greenhouse, F4 power, F5 lander; Tab/WASD/E/I remain existing controls. The exterior entrance traverses the real airlock into the prepared interior scenes with the same astronaut, Chiwis and inventory. The copied 40×40 surface retains original terrain kinds; occupancy changes are preview-only. EVA warning suppression is isolated to this inspection scene. Final normal-world placement and service/mission binding remain NEEDS_INTEGRATION.

<!-- BASE_G2_EXTENDED_END -->

<!-- PRODUCTION_0_9_BEGIN -->

## Phase 0.9 — Current production use

Normal Main Menu → New Game now instantiates the modular outpost under the real Y-sorted World and uses all nine existing furnished room scenes through HabitatDirector. No development gallery or complete-base PNG substitutes for gameplay. The astronaut, Chiwis, inventory, mission, utilities, airlock and two greenhouse trays are the existing instances/systems.

There are **zero new production PNGs and zero PixelLab jobs/credits** in this phase. The 51 unique G2 components, 34 prepared interior prop definitions, nine rooms, G1 library and prior source/rejection records are preserved. Production uses nine shell roles, the existing native passage/hatch components, twelve existing equipment/lander/cargo images and the existing greenhouse bay. The small cube airlock and small habitat facade remain available but are omitted from this placement to keep the entrance and southern route open.

Eight existing utility-floor tiles supply native maintenance aprons; they are TileMapLayer placements, not new artwork. Current cargo, utility wiring, pickup staging and footprint/access data are in [lunar_outpost_layout.json](../resources/data/lunar_outpost_layout.json). Its generated [native outpost scene](../scenes/world/lunar_outpost.tscn) inherits the existing assembly. All nine approved room envelopes fit the 40×40 rendered surface; the per-session static mission area includes the eastern shelter column. All 772 advertised safe exterior cells are connected.

Prepared art is now READY in the actual gameplay path. Optional extra facings and exact socket/collar polish remain cosmetic work; they do not block room access, interactions or the pressure interlock. Delivered composition PNGs remain unchanged. Regression captures write ignored test evidence, not replacement artwork.

See [Phase 0.9 integration report](phase_0_9_lunar_base_world_integration.md) for exact coordinates, supported station bindings, normal gameplay screenshots, test results and remaining limitations. No later phase, new artwork or publication has begun.

<!-- PRODUCTION_0_9_END -->
