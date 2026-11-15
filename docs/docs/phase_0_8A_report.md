# Phase 0.8A - Prop Integration

Completed with Godot **4.7.2.stable.official.ed1daf0bf**, native 2D, GDScript, 960 x 540 and the existing nearest/integer presentation settings.

## Result

The four authored pickups now render the finished Pack B Lunar Sample, Metal Scrap and Supply Pack sprites. Their ground positions, item references, quantities, IDs, interaction areas and collection logic are unchanged. The procedural marker drawing was removed from WorldPickup. Item definitions and inventory icons remain unchanged.

All ten Pack B assets have reusable appearance Resources. The seven assets without existing item/world-object instances are available through the reusable WorldProp scene and a standalone F6 development gallery. They were not assigned invented item identities or added as new production gameplay objects. The existing four-pickup layout remains intact.

No new assets were generated, no credits were consumed and no source artwork was edited in this phase. Existing imported Pack B PNGs and sidecars were validated and reused. No subsequent phase was started.

## Asset mapping

Every appearance below lives under `resources/props/`, uses the corresponding unchanged PNG under `assets/environment/props_pack_b/`, and is available in the development gallery.

| Appearance | Production mapping / intended world object | Native canvas | Ground anchor |
| --- | --- | --- | --- |
| lunar_sample.tres | Item ID `lunar_sample`; LunarSampleA quantity 6 at (32,16), LunarSampleB quantity 8 at (64,32) | 64 x 64 | (32,52) |
| metal_scrap.tres | Item ID `metal_scrap`; MetalScrap quantity 3 at (-32,48) | 64 x 64 | (32,48) |
| supply_pack.tres | Item ID `supply_pack`; SupplyPack quantity 1 at (-64,-32) | 64 x 64 | (32,49) |
| small_equipment_box.tres | Static equipment-box visual | 64 x 64 | (31,53) |
| tool_case.tres | Static tool-case visual | 64 x 64 | (32,53) |
| small_resource_canister.tres | Static canister visual | 64 x 64 | (31,54) |
| utility_crate.tres | Static utility-crate visual | 64 x 64 | (31,56) |
| rock_cluster.tres | Static rock-cluster visual | 64 x 64 | (32,51) |
| broken_machine_part.tres | Static broken-machine-part visual | 64 x 64 | (31,52) |
| beacon_marker.tres | Static beacon-marker visual | 64 x 64 | (32,57) |

These are world sprites, not resized inventory icons. Actual visible bounds, hashes and provenance remain in `art/imports/props_pack_b.json`. The integration mapping is recorded separately in `art/imports/phase_0_8A.json` so the original pack delivery record remains intact.

## Architecture and alignment

`PropAppearance` is a typed Resource holding only a Texture2D and integer ground anchor. `WorldProp` is a reusable native Node2D with a Sprite2D. It uses the full source canvas, unit scale, `centered = false`, nearest filtering, repeat disabled and `offset = -ground_anchor`. The appearance can be assigned in the Inspector; its tool script previews the assigned resource when the scene is loaded.

WorldPickup composes WorldProp as its `Visual` child. Three stable item IDs resolve to their appearance Resources through `WorldPickup.ITEM_APPEARANCES`. An optional pickup-local appearance override supports future presentation reuse without changing an ItemDefinition. The mapping runs at initialization; changing a pickup's item identity during play is not a new feature of this phase.

Only the Sprite2D drawing offset changes. Pickup/interaction roots stay at the original ground contacts, so range checks, nearest-target selection, native detection shapes and entity Y-sorting retain their original coordinate basis. WorldProp has no collider or interaction behavior. Source footprint budgets remain proposals, not new walkability or collision data.

`collect()` is unchanged: inventory accepts what fits, the pickup subtracts exactly that quantity, and only zero remainder disables interaction and queues the entire pickup/visual for deletion. Partial acceptance and capacity rejection keep the same visible texture and exact world remainder. Prompts continue reading existing item names through the same Interactable adapter.

## Files created

- `scripts/world/prop_appearance.gd` and `scripts/world/world_prop.gd`, with Godot UID sidecars.
- `scenes/world/world_prop.tscn`.
- Ten appearance Resources under `resources/props/` listed above.
- `scenes/development/prop_gallery.tscn`: ten nonblocking visuals on the existing lunar terrain, with a standalone 2x Camera2D. This is a development scene, not production world expansion.
- `tests/prop_integration_test.gd`, with Godot UID sidecar.
- `art/imports/phase_0_8A.json`.
- `docs/phase_0_8A_report.md`.

## Files modified

- `scripts/world/world_pickup.gd`: adds presentation lookup/override and Visual binding; removes procedural marker drawing. Collection logic remains unchanged.
- `scenes/world/world_pickup.tscn`: instances the WorldProp Visual child; the existing Area2D and radius-2 detection shape are unchanged.
- `tests/validate.ps1`: validates Pack B and integration JSON, runs native prop import and integration tests, adds graphical prop captures, and labels the completed Phase 0.8A run.
- `AGENTS.md`, `README.md`, `docs/architecture.md`: current scope, finished pickup description and presentation/ownership contract.

Before/after SHA-256 comparisons confirmed that `scenes/world/world.tscn`, all three item Resources, inventory/interaction/player/companion/camera scripts, Pack B PNGs/import sidecars and `project.godot` stayed unchanged. The only changed files in the captured production/test baseline were WorldPickup script/scene and the validation runner. The new appearance resources are additive. No dependencies, audio, generation jobs, commits or repository initialization were introduced.

## Validation executed

Ran the focused graphical prop test, followed by the complete **`./tests/validate.ps1 -IncludeRendering`** suite. Engine profiles, logs and captures remain inside ignored `tests/output/`.

| Validation | Final result |
| --- | --- |
| Editor import, Pack B/integration JSON | Passed |
| Runtime/test GDScript check-only parses | 50 passed |
| Prop import integrity | Ten exact 64 x 64 RGBA imports, matching PNG hashes, no mipmaps, valid anchor/offset records |
| Prop integration | **108 headless / 112 graphical checks passed** |
| Foundation/native hierarchy | 506 headless / 508 graphical checks passed |
| Isometric world | 33,961 checks passed |
| Moon terrain | 338 headless / 342 graphical checks passed; native raster gaps/overlaps remain zero |
| Player camera | 49 checks passed |
| Gameplay modes | 93 headless / 99 graphical / 93 fullscreen checks passed |
| Astronaut movement/animation | 234 headless / 244 graphical checks passed |
| Original character assets | 696 checks passed |
| Run animation | 903 headless / 911 graphical checks passed |
| Chiwis following/routing | 44 headless / 46 graphical checks passed |
| Inventory unit tests | 38 checks passed |
| Interaction/inventory integration | **95 headless / 101 graphical checks passed** |
| UI foundation | 147 headless / 169 graphical / 151 fullscreen checks passed |
| Main headless, graphical editor, fullscreen startup and obsolete-architecture scan | Passed |

**Errors: 0. Warnings: 0** in the final full-suite run. An initial focused alignment assertion omitted Sprite2D's drawing offset when converting the anchor to world space. The assertion was corrected to include that offset; all original ground-alignment checks then passed. No failed assertion was skipped and no source image was adjusted to satisfy a test.

New tests verify all ten texture mappings, manifest anchors, unit scaling, filtering, nonblocking composition and native bounds; unchanged production positions/interaction layers; prompt and nearest target; mode switching; visible sprite retention after partial/rejected collection; and deletion only after accepting the final remainder. Existing integration suites also exercise real E input, all three item types, full 20-slot capacity, exact remainders, item conservation and persistence across camera modes.

Graphical captures were inspected at 960 x 540. All ten assets are visible and distinct at native 1x in the gallery, and at player-view 2x. The four production pickups are readable alongside the astronaut and Chiwis; ground placement, prompts and HUD remain clear in both player and management views. This is automated native rendering/input validation with screenshot review, not a physical keyboard play session.

## Evidence

- `tests/output/phase_0_8A/full_validation.log`: complete suite with final error/warning totals.
- `tests/output/prop_integration.log` and `prop_integration_rendered.log`: final prop checks.
- `tests/output/phase_0_8A_player.png`: finished production pickups, actors and contextual prompt.
- `tests/output/phase_0_8A_management.png`: same world in management at 1x.
- `tests/output/phase_0_8A_prop_gallery.png`: complete pack on lunar terrain at 2x.
- `tests/output/phase_0_8A_prop_gallery_1x.png`: complete pack at native 1x.
- Existing interaction/inventory regression captures show collection, full capacity and mode persistence with the new visuals.

## Manual test steps

1. Run F5. Confirm the two lunar samples, scrap and supply pack use distinct finished art with no old colored markers.
2. Approach a sample. Check `[E] Collect Lunar Sample`, press E once and verify the fully collected sprite disappears. Collect the remaining authored items and open I: samples should stack as 10/4, scrap as 3 and Supply Pack as 1.
3. Use `./tests/validate.ps1 -IncludeRendering` for the real full-inventory acceptance fixture. Partial collection must retain a visible pickup and exact remainder; another attempt while full must leave it unchanged. Free capacity and collect the final remainder to remove it.
4. Move around the pickups with Chiwis following. Switch Tab to management and back; confirm routing, pan/zoom, world state and inventory contents remain intact. Inventory still blocks movement and mode switching while open.
5. Open `scenes/development/prop_gallery.tscn` and press F6 to inspect the other seven reusable visuals without changing the production world. Assign any `resources/props/*.tres` appearance to a WorldProp instance for future level composition.

## Limits

Only the three existing item types are collectibles. The other seven props have no invented storage, beacon signaling, tools, harvesting, damage or processing behavior. Inventory icons remain their existing separate presentation. No item balancing, new occupancy/collision, movement logic, save/load or next phase is included. Source art and locked art standards remain unchanged.
