# Asset inventory — Phase 0.8G2

Snapshot: 2026-11-15, after Phase 0.8G2 interior preparation. Existing exterior and UI records remain preserved below. This inventory does not authorize generation or establish redistribution rights.

## Current totals

| Measure | Count |
| --- | --- |
| Files under assets/ | 462 |
| PNG files | 282 |
| PNG runtime/prepared library | 142 |
| PNG retained source/provenance mirrors | 140 |
| Font binaries | 3 |

Godot .import sidecars and folder READMEs are included in total file counts. Source alternatives and technical atlases are not additional gameplay objects.

## Integration status

| Group | Current use / limitation |
| --- | --- |
| Astronaut and Chiwis | Native 64×64 frames in eight directions; idle/walk/run SpriteFrames preserved. Sprint gameplay remains deferred. |
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

## Phase 0.8G2 — Interior library

Nine playable isolated compartments cover thirteen functional categories. **27 native prop scenes/Resources** comprise 18 accepted new images and nine reused G1/Pack B/C equipment/props. Existing Pack E floor textures are reused; original native 2D geometry supplies modular walls, doors, cables and open grow-light supports. The normal startup, production room factory/layout and all gameplay services remain unchanged.

| Asset | Category / origin | Canvas / bounds (px) | Footprint / ground pivot | Collision / readiness |
| --- | --- | --- | --- | --- |
| `sleep_bunk` | New furnishing | 96×96 / 5, 11, 86, 74 | 2×1 / 28, 85 | Room-owned occupied-cell collision; READY in preview |
| `galley_station` | New furnishing | 96×96 / 8, 4, 76, 85 | 2×1 / 44, 89 | Room-owned occupied-cell collision; READY in preview |
| `sanitation_station` | New furnishing | 96×96 / 10, 6, 76, 84 | 1×1 / 47, 90 | Room-owned occupied-cell collision; READY in preview |
| `habitat_table` | New furnishing | 96×96 / 10, 14, 76, 69 | 2×1 / 36, 83 | Room-owned occupied-cell collision; READY in preview |
| `eva_rack` | New furnishing | 96×96 / 12, 6, 72, 83 | 2×1 / 48, 89 | Room-owned occupied-cell collision; READY in preview |
| `medical_station` | New furnishing | 96×96 / 10, 4, 79, 82 | 2×1 / 41, 86 | Room-owned occupied-cell collision; READY in preview |
| `sample_bench` | New furnishing | 96×96 / 25, 3, 44, 83 | 2×1 / 49, 86 | Room-owned occupied-cell collision; READY in preview |
| `maintenance_bench` | New furnishing | 96×96 / 17, 13, 61, 64 | 2×1 / 36, 77 | Room-owned occupied-cell collision; READY in preview |
| `storage_rack_empty` | New furnishing | 96×96 / 21, 11, 54, 72 | 2×1 / 48, 83 | Room-owned occupied-cell collision; READY in preview |
| `storage_rack_loaded` | New furnishing | 96×96 / 16, 9, 65, 78 | 2×1 / 37, 87 | Room-owned occupied-cell collision; READY in preview |
| `exercise_station` | New furnishing | 96×96 / 6, 2, 84, 91 | 1×1 / 47, 93 | Room-owned occupied-cell collision; READY in preview |
| `growing_tray_empty` | New furnishing | 96×96 / 6, 7, 84, 81 | 2×1 / 62, 88 | Room-owned occupied-cell collision; READY in preview |
| `water_dispenser` | New furnishing | 64×96 / 9, 7, 46, 85 | 1×1 / 30, 92 | Room-owned occupied-cell collision; READY in preview |
| `greens_germinating` | New plant overlay | 64×64 / 14, 15, 33, 33 | 0×0 / 26, 48 | No extra ground occupancy; READY tray overlay |
| `greens_small` | New plant overlay | 64×64 / 10, 15, 43, 36 | 0×0 / 20, 51 | No extra ground occupancy; READY tray overlay |
| `greens_intermediate` | New plant overlay | 64×64 / 5, 10, 53, 43 | 0×0 / 16, 53 | No extra ground occupancy; READY tray overlay |
| `greens_mature` | New plant overlay | 64×64 / 2, 7, 60, 51 | 0×0 / 51, 58 | No extra ground occupancy; READY tray overlay |
| `habitat_seat` | New furnishing | 64×64 / 12, 3, 39, 56 | 1×1 / 31, 59 | Room-owned occupied-cell collision; READY in preview |
| `work_control_console` | Reused existing equipment | 96×96 / 27, 24, 31, 49 | 1×1 / 43, 73 | Room-owned occupied-cell collision; READY in preview |
| `battery_power_unit` | Reused existing equipment | 96×96 / 20, 21, 47, 54 | 1×1 / 42, 75 | Room-owned occupied-cell collision; READY in preview |
| `eclss_service_cabinet` | Reused existing equipment | 96×96 / 13, 17, 65, 62 | 1×1 / 51, 79 | Room-owned occupied-cell collision; READY in preview |
| `utility_oxygen_tank` | Reused existing equipment | 96×128 / 27, 14, 39, 92 | 1×1 / 45, 106 | Room-owned occupied-cell collision; READY in preview |
| `tool_case` | Reused existing equipment | 64×64 / 7, 16, 50, 37 | 1×1 / 32, 53 | Room-owned occupied-cell collision; READY in preview |
| `supply_pack` | Reused existing equipment | 64×64 / 14, 18, 37, 31 | 1×1 / 32, 49 | Room-owned occupied-cell collision; READY in preview |
| `small_resource_canister` | Reused existing equipment | 64×64 / 22, 10, 18, 44 | 1×1 / 31, 54 | Room-owned occupied-cell collision; READY in preview |
| `small_equipment_box` | Reused existing equipment | 64×64 / 13, 13, 37, 40 | 1×1 / 31, 53 | Room-owned occupied-cell collision; READY in preview |
| `small_connector_utility_box` | Reused existing equipment | 64×64 / 7, 14, 50, 37 | 1×1 / 32, 51 | Room-owned occupied-cell collision; READY in preview |

All complete images retain native scale, transparency and original source bytes. No artwork was cropped, resized, repainted, mirrored or rotated. Plants use a separate measured tray-surface attachment anchor, preserving their full canvases; germination includes a brown starter-medium plug. Bounds, attachment anchors, generation IDs/prompts, per-image static frame metadata, Resources and scenes are recorded in [interior_library.json](../art/imports/interior_library.json) and [interiors_g2.json](../art/imports/interiors_g2.json). Visual review was performed at 960×540 native 1×.

| Asset | Preserved original source | Runtime image |
| --- | --- | --- |
| `sleep_bunk` | `assets/pixellab/source/interiors_g2/sleep_bunk.png` | `assets/environment/interiors_g2/sleep_bunk.png` |
| `galley_station` | `assets/pixellab/source/interiors_g2/galley_station.png` | `assets/environment/interiors_g2/galley_station.png` |
| `sanitation_station` | `assets/pixellab/source/interiors_g2/sanitation_station.png` | `assets/environment/interiors_g2/sanitation_station.png` |
| `habitat_table` | `assets/pixellab/source/interiors_g2/habitat_table.png` | `assets/environment/interiors_g2/habitat_table.png` |
| `eva_rack` | `assets/pixellab/source/interiors_g2/eva_rack.png` | `assets/environment/interiors_g2/eva_rack.png` |
| `medical_station` | `assets/pixellab/source/interiors_g2/medical_station.png` | `assets/environment/interiors_g2/medical_station.png` |
| `sample_bench` | `assets/pixellab/source/interiors_g2/sample_bench.png` | `assets/environment/interiors_g2/sample_bench.png` |
| `maintenance_bench` | `assets/pixellab/source/interiors_g2/maintenance_bench.png` | `assets/environment/interiors_g2/maintenance_bench.png` |
| `storage_rack_empty` | `assets/pixellab/source/interiors_g2/storage_rack_empty.png` | `assets/environment/interiors_g2/storage_rack_empty.png` |
| `storage_rack_loaded` | `assets/pixellab/source/interiors_g2/storage_rack_loaded.png` | `assets/environment/interiors_g2/storage_rack_loaded.png` |
| `exercise_station` | `assets/pixellab/source/interiors_g2/exercise_station.png` | `assets/environment/interiors_g2/exercise_station.png` |
| `growing_tray_empty` | `assets/pixellab/source/interiors_g2/growing_tray_empty.png` | `assets/environment/interiors_g2/growing_tray_empty.png` |
| `water_dispenser` | `assets/pixellab/source/interiors_g2/water_dispenser.png` | `assets/environment/interiors_g2/water_dispenser.png` |
| `greens_germinating` | `assets/pixellab/source/interiors_g2/greens_germinating_v2.png` | `assets/environment/interiors_g2/greens_germinating.png` |
| `greens_small` | `assets/pixellab/source/interiors_g2/greens_small_v2.png` | `assets/environment/interiors_g2/greens_small.png` |
| `greens_intermediate` | `assets/pixellab/source/interiors_g2/greens_intermediate_v2.png` | `assets/environment/interiors_g2/greens_intermediate.png` |
| `greens_mature` | `assets/pixellab/source/interiors_g2/greens_mature_v2.png` | `assets/environment/interiors_g2/greens_mature.png` |
| `habitat_seat` | `assets/pixellab/source/interiors_g2/habitat_seat_v2.png` | `assets/environment/interiors_g2/habitat_seat.png` |
| `work_control_console` | `assets/pixellab/source/base_pack_c/work_control_console.png` | `assets/buildings/base_pack_c/work_control_console.png` |
| `battery_power_unit` | `assets/pixellab/source/base_pack_c/battery_power_unit.png` | `assets/buildings/base_pack_c/battery_power_unit.png` |
| `eclss_service_cabinet` | `assets/pixellab/source/exterior_g1/eclss_service_cabinet.png` | `assets/buildings/exterior_g1/eclss_service_cabinet.png` |
| `utility_oxygen_tank` | `assets/pixellab/source/base_pack_c/utility_oxygen_tank.png` | `assets/buildings/base_pack_c/utility_oxygen_tank.png` |
| `tool_case` | `assets/pixellab/source/props_pack_b/tool_case_v2.png` | `assets/environment/props_pack_b/tool_case.png` |
| `supply_pack` | `assets/pixellab/source/props_pack_b/supply_pack_v2.png` | `assets/environment/props_pack_b/supply_pack.png` |
| `small_resource_canister` | `assets/pixellab/source/props_pack_b/small_resource_canister.png` | `assets/environment/props_pack_b/small_resource_canister.png` |
| `small_equipment_box` | `assets/pixellab/source/props_pack_b/small_equipment_box.png` | `assets/environment/props_pack_b/small_equipment_box.png` |
| `small_connector_utility_box` | `assets/pixellab/source/base_pack_c/small_connector_utility_box.png` | `assets/buildings/base_pack_c/small_connector_utility_box.png` |

### Rooms and functional coverage

| Room | Logical size (including boundary) | Facilities / presentation |
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

Airlock/EVA uses crew_airlock plus equipment_lock; habitation and mission control share hub; sleep, galley and hygiene share living; ECLSS and power share engineering; medical, exercise and science share health_lab. Cargo also provides a decorative maintenance bench; its implemented cargo action remains finite resupply. Greenhouse and shelter retain separate compartments. The production cutaway dimensions are preserved; they do not silently enlarge any exterior footprint. The prototype health/science bench moves its approach to (6,3) and removes the placeholder partition in that isolated variant only.

### States, audit and integration readiness

The greenhouse renders empty, seeded, germinating, small, intermediate and mature states from the existing two DailyLife trays. Lights/pause/yield remain owned by UtilityService/DailyLife; there is no plant death or crop-health field, so wilted/failure sprites are not fabricated. Equipment markers read existing equipment state, and the two airlock leaves read the existing interlock. No new simulation, inventory, companion controller or UI theme exists.

PixelLab: **24 one-candidate jobs / 24 subscription generations**, comprising the planned 19 plus five replacements explicitly approved by the user. Eighteen candidates are READY and six remain NEEDS_REFINEMENT, unintegrated and preserved. USD credits used: $0.00. [Review decisions](../assets/pixellab/source/interiors_g2/review_decisions.json) explain each rejection. [Source audit](../art/imports/interior_source_audit.json) retains source/runtime duplicates as DUPLICATE_CANDIDATE groups without deletion; the previous 162-file exterior/external audit remains intact.

READY means usable in the isolated library. Final cross-room/world assembly, module-to-exterior mapping and final pressure passages remain NEEDS_INTEGRATION for Phase 0.9. Alternate furniture facings and additional polished furniture/window/door variants remain MISSING/noncritical. Walls, doors and lighting supports are original native geometry with correct grid/cutaway interfaces, rather than newly generated texture packs. No claim of flight qualification, shielding effectiveness, biological timing or NASA deployment is made.

Preview: F6 `scenes/development/lunar_interior_preview.tscn`, F1–F9 selects rooms, WASD/E/Tab/I use the existing session. Final screenshots and logs are under ignored tests/output/phase_0_8g2. Rebuild/validation instructions: [tools/interiors/README.md](../tools/interiors/README.md). Full phase record: [phase_0_8G2_lunar_interiors_greenhouse.md](phase_0_8G2_lunar_interiors_greenhouse.md).

<!-- INTERIORS_G2_END -->
