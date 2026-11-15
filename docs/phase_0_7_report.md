# Phase 0.7 - Interaction and Inventory Foundation

Implemented and validated with **Godot 4.7.2.stable.official.ed1daf0bf**, GDScript and native 2D. The astronaut can collect nearby development pickups, stack items, open a keyboard/mouse inventory and inspect names, quantities and descriptions. Inventory and collected objects survive camera-mode changes in the same world. Phase 0.8 was not started.

The original astronaut/Chiwis movement and animation controllers, real character art, foot collisions, camera implementations, terrain data/code, 64 x 32 grid, 960 x 540 presentation and locked art standards are preserved. No audio, artwork generation, PixelLab tools/credits, crafting, construction, survival, companion commands, T, Mars gameplay or disk persistence was added. All 18 original external PXO source hashes still match the Phase 0.6 manifest; the 696 real-asset checks also pass without re-exporting artwork.

## Interaction architecture

`Interactable` is a small reusable Area2D contract with display name, action label, availability, stable selection key and an overridable `execute(inventory)` method. The default execution does nothing. `PickupInteraction` adapts that interface to its parent WorldPickup. Future terminal/door/storage components can implement their own availability/execution without changing the player movement controller; none are implemented now.

The astronaut's child `InteractionDetector` is a native Area2D with a configurable **48-world-pixel** radius. Native `area_entered`/`area_exited` signals maintain a small candidate array. There is no scene-tree search per physics frame. The sensor uses collision layer **0**, mask **8**; interaction components use layer **8** (bit 4), mask **0**, with monitoring off and monitorability on. Existing actors keep layer 1/mask 2, so pickups neither block movement nor disturb Chiwis routing. Chiwis has no collectible interaction component.

Selection prefers the nearest available world-space ground point. Equal distances within a small floating-point tolerance use lexical selection ID, then unique node path, so native overlap notification order cannot change the choice. Invalid/freed/queued targets and unavailable objects are discarded. The selected target updates the contextual prompt; leaving range, UI focus, management and modal inventory clear the prompt. The actual distance check excludes broadphase shape margins beyond the configured radius.

Each candidate must also have valid terrain under a complete astronaut foot rectangle and a clear swept foot connector from the astronaut. This rejects sparse holes, boundaries and unsafe diagonal corner gaps even when both endpoints are close. Execution refreshes and revalidates the target, range, terrain and input permission before acting. This is direct terrain reach, not pathfinding around an obstacle to interact remotely. Physical door/wall line-of-sight and future object-specific reach policies remain later work.

The minimal screen-space prompt reads the InputMap binding, for example **`[E] Collect Lunar Sample`**, above the existing footer. It shows the current object's name and action. Successful/full interactions produce short timed feedback. Text and colors are development UI, replaceable independently of interaction data.

## Item definitions and inventory data

`ItemDefinition` is a shared authored Resource containing a stable `item_id`, English name/description, stackable flag, positive maximum stack, optional Texture2D icon, tags and temporary indicator color. Treat definitions as immutable during runtime; no quantities are stored in them. Only the following development test definitions exist:

| File under resources/items/ | ID | Name | Stack rule |
| --- | --- | --- | --- |
| lunar_sample.tres | lunar_sample | Lunar Sample | 10 per slot |
| metal_scrap.tres | metal_scrap | Metal Scrap | 5 per slot |
| supply_pack.tres | supply_pack | Supply Pack | Nonstackable; 1 per slot |

These values exercise the foundation and do not establish final resource balance or pack contents. The `development` tags identify the fixture items. There are no speculative oxygen, food, tool or medical definitions. Tags/optional icons are the lightweight extension points for future approved categories.

`RuntimeInventory` is a Node owned by the astronaut, default **20 slots**. Inspector capacity is configured before the node enters the tree; runtime slot resizing is not implemented. Each inventory has its own catalog and private slot dictionaries, while definitions are shared Resources. The API uses stable identifiers, never UI widgets or sprite names. Slots keep stable order. Defensive slot snapshots cannot mutate the authoritative quantities.

| API | Result and behavior |
| --- | --- |
| `register_definition(item)` | Validates type/reference, nonblank ID/name and positive maximum; rejects duplicate IDs and invalid references |
| `definition(id)` | Shared ItemDefinition, or null for an unknown ID |
| `slot_count()` / `free_slot_count()` | Current configured slot count / number of completely empty slots |
| `slot_snapshot(index)` | Copy of ID/quantity, or empty dictionary for an invalid index |
| `get_quantity(id)` | Total available quantity; unknown IDs return zero |
| `available_quantity_capacity(id)` | Space in item units, including matching partial stacks and empty slots; unknown IDs return zero |
| `add_items(id, quantity)` | Returns the actual quantity accepted; fills existing matching stacks before empty slots |
| `remove_items(id, quantity)` | Returns the actual quantity removed, capped to availability, clearing emptied slots |
| `changed` | One notification per successful add/remove transaction; none for no-op/rejected calls |

Nonstackable items always use one slot per copy regardless of their authored maximum. Zero/negative quantities, unknown identifiers and malformed definitions safely fail without mutation. Removal supports quantities spanning several stacks; over-removal returns only what existed. There is no item consumption behavior or UI removal command in this phase; the tested removal API is available for future systems.

## Collection and world state

The selected policy is **partial acceptance with exact world remainder**. A pickup asks the inventory to add its quantity, subtracts only the returned accepted amount, and disappears only when its remaining quantity becomes zero. If nothing fits, inventory/world quantities remain unchanged and UI reports failure. Example verified in tests: a one-slot sample inventory containing 8/10 accepts 2 from a quantity-5 pickup; the same pickup remains with 3. Another attempt while full leaves those 3 untouched. After space is freed, collecting the final 3 removes that original object. No excess is silently destroyed.

`WorldPickup` is a nonblocking Node2D scene containing item reference, quantity, stable pickup ID, interaction child and a simple ground-anchored visual indicator. The indicator is drawn with small native CanvasItem primitives; no environment image is generated. The optional inventory icons use a cached, transparent **32 x 32** procedural square indicator at native scale when no authored icon is supplied. Both forms are intentionally temporary, and no final artwork or character resources were changed.

The production test fixture contains only four reusable pickup instances under the existing Y-sorted `World/Entities/Props` root:

| Node | Grid cell | World position | Contents |
| --- | --- | --- | --- |
| LunarSampleA | (1, 0) | (32, 16) | 6 Lunar Samples |
| LunarSampleB | (2, 0) | (64, 32) | 8 Lunar Samples |
| MetalScrap | (1, 2) | (-32, 48) | 3 Metal Scrap |
| SupplyPack | (-2, 0) | (-64, -32) | 1 Supply Pack |

Tests verify valid full-foot terrain placement and separation from initial astronaut/Chiwis positions. They are accessible on the existing lunar map and have no actor/obstacle collision. These are fixed authored fixture positions, not a procedural spawning or resource-deposit system. New map layouts must validate their own placements. There is no respawn timer or terrain rebuild on collection.

Pickup collection requires the same registered ItemDefinition reference as the inventory catalog, preventing an unregistered Resource with a spoofed matching ID from silently entering the inventory. Invalid/missing definitions and nonpositive quantities remain unavailable. A full inventory never deletes a pickup.

## UI, input and gameplay modes

`InventoryWindow` is a separate reusable full-viewport Control under `Main/UI`, with a dim backdrop, close button, 20 native slot buttons, used-slot count and item details. Slots display cached icons and exact stack quantities; empty slots remain visible. Native arrows/focus and mouse clicks inspect items. Name, description, selected stack quantity and maximum stack appear in the details column. Item presentation comes from Resources rather than hardcoded UI item lists.

Controls are allocated when the UI is configured, then reused. Inventory transaction signals update their contents immediately, whether the window is open or closed. No per-frame refresh or tree reconstruction is used. Tests observe the refresh counter staying unchanged across idle frames and increasing only once for an actual transaction. Native button events consume inventory clicks before the primary world action can see them.

`PlayerSession`, composed under Main/Systems, owns the small modal/input handoff. Main wires existing actor, mode coordinator, detector, inventory data and UI. It does not replace the player/companion controllers or introduce global managers.

| Context | Input and simulation policy |
| --- | --- |
| Player Mode, inventory closed | Existing WASD/arrows movement and camera follow; E/left-click interact; I opens inventory; Chiwis follows |
| Inventory open | Player stops/idles immediately; interaction and mode switching disabled; UI handles keyboard/mouse; world and Chiwis continue simulating |
| Inventory closes | Owned UI focus released; existing neutral-movement handoff restores control safely; held primary interaction requires release |
| Base Management | Existing stationary actors, pan/zoom and world visibility preserved; interaction/prompt and inventory opening disabled |

The only InputMap addition is **E** as a second binding on the existing `interact_primary` action; its left mouse binding remains. I reuses `inventory_toggle`; Esc reuses `game_pause` solely to close inventory. Global pause and input rebinding menus are not implemented. Left-click in world space interacts with the nearest valid target, rather than selecting an object under the cursor. Right-click remains reserved.

Primary interaction is handled in unhandled input, with echo rejection and one-press latching. Mode/modal transitions sample held primary input and require release before another collection, preventing stale E/click actions. Focused external UI blocks interaction and opening inventory. Inventory I/Esc handling happens before GUI dispatch so the focused slot does not trap the close key. Tab is consumed while modal; the existing mode coordinator also rejects direct `request_mode` calls and pan/zoom routing via `modal_input_blocked`. This small guard is its only behavior extension; camera code is unchanged. Actual keyboard/mouse events test these paths.

Future input remapping continues through Project Settings > Input Map. The prompt selects its key label from that action; a future runtime settings screen should call `InteractionPrompt.refresh_prompt()` after changing bindings. No hardcoded E handler was introduced. New bindings must avoid active UI/mode conflicts.

Mode switches preserve the same world, astronaut, Chiwis and RuntimeInventory instances. No separate management inventory exists, and removed pickups do not reappear. A game restart deliberately resets runtime contents and the development fixture; long-term save/load remains deferred.

## New and modified files

Created:

- `scripts/inventory/item_definition.gd`, `runtime_inventory.gd`.
- `scripts/interaction/interactable.gd`, `interaction_detector.gd`, `pickup_interaction.gd`.
- `scripts/world/world_pickup.gd` and `scenes/world/world_pickup.tscn`.
- `scripts/gameplay/player_session.gd`.
- `scripts/ui/inventory_window.gd`, `interaction_prompt.gd`, `item_placeholder.gd`.
- `scenes/ui/inventory_window.tscn`, `interaction_prompt.tscn`.
- `resources/items/lunar_sample.tres`, `metal_scrap.tres`, `supply_pack.tres`.
- `tests/inventory_test.gd`, `interaction_inventory_test.gd`.
- Twelve Godot `.gd.uid` sidecars for the ten runtime scripts and two tests.
- This report.

Modified:

- `project.godot`: E binding on primary interaction only; renderer, resolution and other bindings preserved.
- `scenes/player/astronaut.tscn`: inventory/sensor child components and definition references.
- `scenes/world/world.tscn`: four pickup instances under Props.
- `scenes/main.tscn`: PlayerSession, prompt and inventory UI instances.
- `scripts/core/main.gd`: component/UI wiring, phase log and initial control hints.
- `scripts/gameplay/gameplay_mode_coordinator.gd`: modal input/mode guard.
- `tests/foundation_test.gd`: validate E plus original mouse binding while retaining existing assertions.
- `tests/validate.ps1`: add inventory/unit and native integration suites plus graphical captures; preserve all prior regressions.
- `AGENTS.md`, `README.md`, `docs/architecture.md`, `docs/input_bindings.md`, `scenes/player/README.md`, `scripts/gameplay/README.md`, `scenes/gameplay/README.md`, `resources/data/README.md`: current contracts/locations and phase boundary, with older phase scopes identified as historical.

All original character PNGs, SpriteFrames/art profiles, Pixelorama sources, locked Art Bible/JSON, camera implementations, astronaut/Chiwis controllers, terrain scripts/data and prior phase reports remain unchanged. No Git commit or repository initialization was performed. Logs/captures and isolated engine profiles stay under ignored `tests/output/`.

## Executed automated validation

Command: `./tests/validate.ps1 -IncludeRendering` in PowerShell 7 with the existing configured Godot 4.7.2 executable. Engine user/editor data remains project-local; the established certificate-store permission was allowed for engine startup. No new package/dependency was installed. Early development parse/resource-cycle issues were fixed before the successful complete run; no failed assertion was skipped.

| Validation | Actual final result |
| --- | --- |
| Engine version | 4.7.2.stable.official.ed1daf0bf |
| Headless editor import | Passed |
| All runtime/test GDScript check-only parses | 38 passed |
| Existing standards/intake/placeholder/import JSON | Valid |
| Foundation/native hierarchy | 378 headless / 380 graphical checks passed |
| Isometric terrain/coordinate suite | 33,961 checks passed |
| Player camera suite | 49 checks passed |
| Gameplay modes | 93 headless / 99 graphical / 93 fullscreen checks passed |
| Astronaut movement/animation | 234 headless / 244 graphical checks passed |
| Existing real character assets | 696 checks passed |
| Chiwis physics/routing | 44 headless / 46 graphical checks passed |
| Inventory unit suite | 38 checks passed |
| Native interaction/inventory integration | 64 headless / 67 graphical checks passed |
| Main headless, editor graphical and main fullscreen startup | Passed |
| Production architecture scan | No obsolete spatial architecture references |
| External original artwork | All 18 source hashes unchanged |

The unit suite tests Resource loading, catalog validity/duplicates/freed references, default/custom/zero capacity, zero/negative/unknown quantities, stacking/splitting, maximum enforcement, matching-stack capacity in otherwise full inventories, partial/full adds, cross-stack and excessive removal, independent inventories, immutable snapshots, change notifications and cached native 32 x 32 indicators.

The integration suite uses the real native physics broadphase and input dispatch. It tests initial pickup placement, layer separation, nearest/tied/disabled/removed targets, exact range boundary and live range changes, prompt updates, hole/diagonal reach rejection, E press/hold/echo, repeated item collection, partial/full remainder preservation, invalid/spoofed item references, removal, immediate UI updates, actual I/Esc handling, real arrow selection and mouse-button clicks, movement stop/neutral resume, blocked world clicks/interaction/Tab/direct mode APIs while modal, external keyboard focus, ongoing world/Chiwis simulation, management state preservation, stale interaction across modes and unchanged terrain/real character animation contracts. All Phase 0.1-0.6 suites ran again.

**Final game validation: 0 errors, 0 warnings.** There are no unresolved validation failures. Phase 0.6 Pixelorama export-tool diagnostics are historical; no export or generation tool was run in this phase and no source-art correction was attempted.

## Graphical validation

Godot ran with the existing Compatibility/OpenGL renderer on the available NVIDIA adapter. Automated input collected samples into stacks, opened inventory, moved focus with arrows, clicked a slot, closed the window and switched camera modes. Screenshots were inspected at the 960 x 540 logical resolution: the real astronaut/Chiwis and colored pickup markers remain sharp, the contextual prompt is readable above the footer, all 20 slots fit, and item descriptions wrap without clipping. The 1x management view preserves remaining pickups/actors and collected state. The existing fullscreen/movement/camera suites also pass.

Evidence under `tests/output/`:

- `interaction_prompt.png`: real actors, four pickup indicators and `[E] Collect Lunar Sample`.
- `inventory_open.png`: 20 slots, sample stacks of 10 and 4, Metal Scrap stack of 2, selected name/quantity/description.
- `inventory_management.png`: same world and remaining pickups in management after collection.
- Updated existing camera/astronaut/Chiwis captures and per-suite `.log`/`.console.log` files.

This is **automated graphical execution and screenshot inspection**, not a physical keyboard/mouse play session. No audio/movie capture was used. Built-in Godot fonts/native controls are temporary development presentation, not final pixel-art typography. Timed collection feedback may finish displaying after a mode switch; the actionable prompt is hidden and interactions are disabled in management.

## Manual test procedure

1. Open `project.godot` in Godot 4.7.2 and run F5. Expect one astronaut, one Chiwis and four small colored pickup markers on the lunar grid. The nearest sample starts in interaction range; verify the E prompt.
2. Press E once, or left-click world space. The first sample disappears and six samples enter inventory. Hold E: no second collection should occur. Move toward the next sample and press again after release; collecting all samples should yield stacks of 10 and 4.
3. Press I. Confirm 20 slots, used-slot count, quantities and item details. Use arrows/mouse to inspect stacks, then collect Metal Scrap/Supply Pack after closing. Their names, descriptions and authored stack policies should be distinct. No equipment/item-use controls should appear.
4. Open inventory while walking. Movement must stop immediately, E/world clicks must not collect, and Tab must not change mode. Inventory clicks/arrows inspect slots. Close using I, Esc or Close; release held movement/interaction keys before pressing again. Verify no stale movement or collection. Chiwis may continue approaching the stationary astronaut because the world is not paused.
5. With inventory closed, enter management. Confirm astronaut/Chiwis stop, the actionable prompt disappears, inventory cannot open, and pan/zoom still works. Return to player view; collected samples must stay removed and the inventory must contain the same stacks. No actor or inventory instance should be duplicated.
6. Walk away from pickups, approach map edges and inspect all existing real character directions. Prompts must respect configured world distance and valid terrain. The automated suite supplies temporary sparse-hole fixtures; the production map remains unchanged.
7. Reproduce full/partial capacity through `RuntimeInventory` in a test fixture or the provided integration test. A one-slot 8/10 sample inventory collecting quantity 5 must accept exactly 2 and retain 3 in that original pickup. Test removal frees space before collecting the remainder.
8. Run `./tests/validate.ps1 -IncludeRendering` to reproduce all regressions and captures. Resize/fullscreen and inspect the established integer presentation. Restarting should reset runtime test contents, since save/load is not implemented.

## Limits and recommendations for an assigned Phase 0.8

The fixture is small and development-only. Capacity is configured before initialization; there is no hot resizing, drag/drop, sorting, equipment, transfers, weight, durability, crafting or item consumption. Item definitions are immutable by contract, not a runtime editing feature. Interaction checks terrain reach, without authored obstacle occlusion or remote object-specific range rules. Slot layout is a simple five-column scrollable development view; final assets, accessibility presentation and broader controller support need explicit scope. Disk persistence, release exports, every monitor/DPI setup and long-session performance are not certified by these tests.

An explicitly assigned Phase 0.8 can build on stable item IDs, returned accepted/removed quantities, Resource definitions, transaction signals and the small Interactable contract. Choose its concrete feature first; if storage or save/load is approved, define authoritative inventory/pickup IDs and state serialization without making UI/cameras own data. Add obstacle-aware interaction tests when actual walls/doors exist. Preserve existing art, modes and terrain; request authorization before any asset generation. **No Phase 0.8 feature was implemented.**
