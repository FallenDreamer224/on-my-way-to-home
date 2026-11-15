# Phase 0.8C - Chiwis EVA Safety Perimeter

## Implemented behavior

The Moon tutorial now has a shared, data-driven mission safety perimeter. Chiwis presents text guidance in the existing notification area as the astronaut approaches its edge. The explanation is mission clearance, finite supplies, navigation and a safe return route. This is an authored tutorial restriction, not a calculated suit-endurance limit or a NASA-approved EVA distance. No audio or new art is added.

The existing 40x40 ground, nine reservations, two crater features, spawn locations, pickup IDs/positions/quantities, actor graphics, inventory, cameras and 960x540 resolution are preserved. The allowed mission footprint matches Phase 0.8B's existing inner region; this phase does not shrink the exploration map or disconnect its safe routes. Terrain remains 1,600 rendered cells with 1,402 walkable cells and 198 blocked perimeter/crater cells.

## Policy and zones

Edit `resources/config/lunar_eva_safety.tres` through its exported `EvaSafetyLimits` fields. Coordinates are logical grid cells, not meters. Rectangle ends are exclusive.

| Setting | Default and meaning |
| --- | --- |
| Allowed cells | Rect2i(-19, -19, 38, 38): cell indices -19 through 18 on both axes |
| Normal exploration | Edge clearance of at least 3 cells: indices -16 through 15, 1,024 geometric cells |
| Warning | Edge clearance of 1 or 2 cells: 272 geometric cells |
| Restricted-boundary approach | Last permitted cell beside any edge: 148 geometric cells; further outward movement is blocked |
| Outside allowed cells | Restricted as well: the 156-cell outer rendered ring plus any position beyond the map |
| Return cell | (0, 0), the mission staging point in the landing/unloading area |
| Dialogue cooldown | 6 seconds between notices, including warning-to-boundary escalation |
| Rearming | 3 continuous active seconds back in normal exploration |
| Notice duration | 5 seconds |

Zone counts describe mission clearance geometry, not physical walkability; crater cores remain blocked independently. `RESTRICTED_BOUNDARY` includes both the last permitted approach band and forbidden cells. The approach band allows a timely explanation without first requiring the player to cross the boundary.

Warning and boundary triggers have independent enable switches. Their text, safety explanation, durations, insets, allowed rectangle and return cell are configurable. Disabling dialogue does not disable movement protection. Invalid band ordering, nonpositive/nonfinite timing, missing dialogue or an out-of-area return cell is rejected. The region validates that mission limits fit the map and preserve its zone reservations; the monitor also requires a walkable return point.

Default warning: "We're nearing our mission limit. Keep reserves and a known route back."

Default boundary message: "Our mission area ends here. We should turn back." This is followed by: "Keep reserves for return."

Messages carry the `Chiwis:` prefix and, when a traversable return route exists, a screen-facing eight-direction hint such as `Return: NW.` Default text fits the existing 180-character slot. The staging point is used deliberately: the habitat remains a planning reservation rather than an implemented pressurized installation.

## Dialogue state and input safety

`EvaSafetyMonitor` observes the astronaut after actor physics updates. It reads neither camera position nor Chiwis position. It emits `zone_changed` and `notice_requested` only when appropriate; Main routes notices into `GameUI.notify()` without adding UI widgets, input handlers or gameplay quantities.

Each severity is announced at most once per excursion. Boundary guidance also counts as the milder warning on retreat. Standing at the edge never repeats a message. Rapid boundary escalation waits for the global cooldown; leaving that zone cancels the deferred severity, so stale boundary warnings do not play after returning. A brief normal-zone crossing does not rearm messages; a sustained safe return does. Cooldown can elapse in another mode, but switching modes cannot clear the excursion's issued-message flags.

Assessment and rearming pause while Base Management Mode, an inventory modal, disabled player control or keyboard focus prevents exploration. Panning/zooming the management camera therefore cannot trigger warnings. Returning to permitted Player Mode assesses the astronaut's actual location. World simulation, companion behavior and inventory state remain owned by their existing systems.

## Shared movement boundary and return direction

`LunarTutorialRegion.eva_limits` supplies the same allowed cells used by the monitor. `TerrainLayer` caches this walkability policy on rebuild; both `TerrainWalkability` and `TerrainRoutePlanner` already consume it. Chiwis and the astronaut therefore agree on where the mission ends, while existing crater and missing-cell restrictions remain effective. Changing authored limits requires validation and a terrain rebuild; runtime area editing is not implemented.

Blocked motion now additionally tests projections along both diamond-edge tangents. The closest safe displacement is selected only after sweeping the complete foot rectangle along the final straight displacement. This allows progress alongside an isometric boundary while pressing outward, retains smooth retreat and prevents tunneling through corners, sparse holes or crater cells. Ordinary unobstructed walking, speed and animation remain unchanged. The UI does not enforce collision and no fake physical force field or hazard damage is introduced; movement restrictions represent the mission's authorized area.

`return_direction(from)` queries a terrain-aware route to the configured return cell using the astronaut's complete foot footprint. It returns a normalized direction toward the next traversable waypoint, not a blind vector through a crater. `safe_return_direction` retains the last cell-based assessment for future consumers. At the destination, outside valid terrain or when no route exists, the direction is zero and no direction hint is invented. The monitor does not issue movement commands or take control away for a forced return.

## Future EVA range interface

`EvaRangeProvider.assess(remaining_supplies: Dictionary, estimated_return_seconds: float) -> EvaSafetyLimits` is a typed extension point. The base provider returns null, meaning unavailable. `EvaSafetyMonitor.assess_future_range()` forwards explicit future inputs to an injected provider and rejects invalid return-time inputs. No provider is installed in production and no oxygen, battery, cooling, communications, hazard or return-time model is implemented.

A future implementation may propose validated limits. This interface deliberately does not automatically adopt a proposal: a future approved system must reconcile the map, return point, full-foot safety, Chiwis routes and actor positions and rebuild the shared policy atomically. Applying range only to a UI meter or the astronaut would create inconsistent navigation. No formula, reserve quantity, travel distance or physiological threshold is locked by this phase.

## Scientific basis and abstractions

Consulted `SCIENCE_BIBLE.md`, `SCIENTIFIC_GAMEPLAY_RULES.md`, `NASA_TECHNOLOGY_CATALOG.md` and the research registry. Relevant evidence records are NASA-EVA-EMU, NASA-EVA-AXEMU, NASA-MAINT-EVA, NASA-HAZARDS-FIVE and NASA-OPS-DELAY. Suit support is finite and EVA planning/maintenance needs equipment, procedures and contingency support; hardware heritage and mission hazards do not establish a universal solo lunar walking radius. The research registry and its evidence cutoff remain unchanged.

The static grid footprint, warning bands, dialogue timers, mission clearance and single-human/robot story are game design choices. They are not measured lunar conditions or real operating procedures. Messages do not claim that live suit telemetry or a communications-range calculation exists. The system adds no survival, medical, radiation, thermal or power simulation.

## Files

Created:

- `scripts/gameplay/eva_safety_limits.gd`, `eva_safety_monitor.gd`, `eva_range_provider.gd` and their Godot UID companions.
- `resources/config/lunar_eva_safety.tres`.
- `tests/eva_safety_test.gd` and UID.
- `docs/phase_0_8C_report.md`.

Modified:

- `scripts/world/lunar_tutorial_region.gd` and `resources/data/lunar_tutorial_region.tres`: shared mission limits and configuration validation.
- `scripts/world/terrain_walkability.gd`: safe tangent sliding at diagonal edges.
- `scripts/core/main.gd` and `scenes/main.tscn`: monitor composition and existing UI notification connection.
- `tests/ui_foundation_test.gd`: recognizes the explicitly authorized third system node while continuing to reject additional survival/status systems.
- `tests/validate.ps1`: headless/rendered safety acceptance checks.
- `AGENTS.md`: additive Phase 0.8C workflow and boundary instructions.

No source artwork, import settings, TileSet, item definitions, camera controllers, inventory implementation or project rendering/input settings changed.

## Validation

Run `./tests/validate.ps1 -IncludeRendering` with the existing configured Godot 4.7.2 executable. The runner isolates its profiles and outputs under `tests/output`. The validation process requires Windows certificate-store read access outside the restricted sandbox, as in Phase 0.8B; no project settings or Windows trust settings are changed.

The complete headless/graphical/fullscreen regression suite passed with **0 errors and 0 warnings**. It included 403 safety acceptance checks in both modes and the unchanged 9,261-check map suite. Visual inspection then found that the initial long explanation was clipped by the existing four-line notice panel. Defaults were shortened, and two explicit line-fit checks were added. The final safety suite passed **405 checks headless and graphically**, with the full explanation and return hint visibly readable at 960x540.

The first full regression attempt identified the old UI assertion that Systems must contain exactly two nodes; that assertion was updated for the authorized monitor, then the suite was rerun. No gameplay assertion was removed.

| Check | Result |
| --- | --- |
| Godot version, editor import and script parsing | Passed: 4.7.2.stable.official.ed1daf0bf |
| Final safety acceptance | 405 checks passed headless and graphically |
| Zone policy | All rendered cells classified; every side/corner tested for warning entry, boundary escalation and normal return |
| Message behavior | Single notice per severity/excursion; cooldown, rearm, jitter, cancellation and disabled triggers passed |
| Movement | Long/diagonal swept moves, full feet, map sides/corners, tangent progress and non-sticking retreat passed |
| Companion | Safe routes to boundary contacts and the existing Chiwis follow/crater-detour suites passed |
| Input/modes | Management pan, mode return, inventory suppression and existing modal/input regressions passed |
| Existing suites | Foundation, isometric fixture, Moon atlas/raster, cameras, modes, astronaut, character/run art, inventory/interactions, props and UI passed |
| Graphical/fullscreen regressions | Existing editor, main, terrain, modes, actors, UI and fullscreen checks passed |
| Terrain preservation | 1,600 rendered / 1,402 walkable / 198 blocked cells; zero raster gaps or overlaps; all nine zones connected |
| Research registry | Consistency check passed with zero errors; its eight existing evidence-warning lines remain separate from engine warnings |

Evidence: `tests/output/phase_0_8C_validation.log` (complete suite), `eva_targeted.log` (final targeted run), `eva_safety.png` (visually inspected), `lunar_tutorial_summary.json` and `phase_0_8C_science_validation.log`. Outputs and isolated engine profiles remain inside the project's ignored `tests/output` directory. Warnings: zero engine warnings in the successful complete run; no scientific evidence warnings were silently removed.

## Manual review and limitations

1. Walk from the staging point toward each map edge. Confirm one warning, then boundary guidance after cooldown, with a return hint and visible `Chiwis:` attribution.
2. Hold outward and diagonal movement at each side/corner. Confirm no crossing, smooth movement along sides and immediate retreat.
3. Stay in the warning/boundary bands; verify messages do not repeat. Briefly step inward and back; verify no rearming. Stay in normal exploration for the configured duration; verify a new excursion can warn again.
4. Switch to Base Management Mode and pan to the perimeter; verify no warning. Open inventory in Player Mode and confirm movement/modal safety remains intact.
5. Lead Chiwis near the edge and around the existing crater; verify both use the same permitted terrain and existing follow behavior.

The notification area remains a single latest-message slot, so other system/pickup notices may replace guidance. There is no persistent dialogue log, queue or waypoint arrow. Direction hints use screen-facing compass codes and a traversable route, not compass instrumentation. Deliberate script/editor teleports into invalid terrain are not a supported gameplay action and are not silently corrected; future relocation/save-load features must choose a safe spawn. Dynamic policy adoption, return-time estimation and consumable integration remain future work.

No audio, artwork generation, PixelLab credits, commits or Phase 0.8D work is included.
