# Phase 0.8 - Interaction and Inventory Foundation

Completed and validated the required Moon interaction/inventory foundation with **Godot 4.7.2.stable.official.ed1daf0bf**. Inspection confirmed that the required runtime features already existed from Phase 0.7 and were integrated into the Phase 0.7C interface. This phase reuses that implementation, adds end-to-end capacity/item acceptance coverage, and documents the current contracts and results.

The astronaut can select nearby valid pickups, collect with E, store stackable/nonstackable items, open/close inventory and inspect names, quantities and descriptions. Inventory and pickup remainders survive camera changes in the same world. Movement is disabled while the inventory modal is open. All ten required features are present. Existing runtime scripts, scenes, resources, assets, art metadata and project settings remain **byte-identical** to the before-phase snapshot.

No crafting, processing, equipment, item use, survival, audio, final HUD art, asset generation, disk persistence or subsequent phase work was added.

## Required feature mapping

| Requirement | Existing implementation verified in this phase |
| --- | --- |
| Nearby detection | Astronaut child InteractionDetector, native Area2D with configurable 48-world-pixel range |
| Nearest valid target | World-distance selection, availability/range/terrain checks and deterministic ID/path tie-breaking |
| Context prompt | Existing `UI/InteractionPrompt` and GameUI; target-dependent E/key label, hidden without a valid permitted target |
| Interact action | Remappable `interact_primary`, default E and retained left-click; one action per press, echo/held-input safeguards |
| Runtime inventory | Astronaut-owned RuntimeInventory, default 20 configurable slots, stable item IDs, stacking and tested add/remove/query APIs |
| Inventory window | Existing centered 20-slot modal with keyboard/mouse inspection and immediate event-driven quantity updates |
| Item definitions | Three shared ItemDefinition Resources, separate from runtime quantities |
| World pickups | Reusable WorldPickup scene and interaction adapter; four authored lunar pickups |
| Persistence across modes | Same inventory/world instances retained; fully collected objects stay removed and partial quantities remain |
| Modal movement restriction | Existing PlayerSession stops/idles the astronaut and gates interaction/mode changes until inventory closes |

The astronaut, Chiwis, native TileMapLayer terrain, player/management cameras, run/walk/idle resources, UI theme and input map were preserved. Runtime implementation reuse avoids creating competing inventories, catalogs, interaction detectors or HUD components.

## Architecture and ownership

Main composes existing references. The astronaut owns RuntimeInventory and InteractionDetector. ItemDefinition holds authored data; inventory slots hold runtime IDs/quantities; WorldPickup holds its remaining world quantity. UI only presents that state and sends existing input requests. No singleton or new manager was introduced.

The detector maintains nearby candidates through native area enter/exit signals, rather than repeated scene-tree searches. It checks the target's world ground point against the exact configured range and the existing full-foot terrain sweep. Missing cells and unsafe diagonal gaps cannot be interacted across. Removed/unavailable objects are discarded, and execution validates the target again before mutating inventory. Chiwis has no collectible interaction component.

Pickups use a separate detection layer and no actor/obstacle mask, so they do not obstruct astronaut movement or Chiwis routing. Stable pickup IDs provide deterministic selection. The four authored placements are valid existing lunar cells and do not overlap the initial actors.

GameUI composes the contextual prompt and modal inventory at the existing attachment points. Successful/rejected collection results reach its notification area. Inventory updates only after successful data transactions; rejected/full pickups produce no false inventory refresh. The passive HUD continues passing gameplay input through. The inventory remains the intentional modal, with the established focus and neutral-input handoff.

## Development items and pickup layout

| Resource under resources/items/ | Stable ID | Stack policy | Authored world quantity |
| --- | --- | --- | --- |
| lunar_sample.tres | lunar_sample | 10 per slot | 6 at cell (1, 0), 8 at cell (2, 0) |
| metal_scrap.tres | metal_scrap | 5 per slot | 3 at cell (1, 2) |
| supply_pack.tres | supply_pack | Nonstackable, 1 per slot | 1 at cell (-2, 0) |

All definitions already contain the required English name, description, stackable flag, maximum stack, optional icon and tags. They are shared authored Resources, treated as immutable during play. Their quantities are not stored in the definitions. No speculative items or final balance changes were added.

Existing temporary world indicators and cached native 32 x 32 inventory icons remain in use. No final art was required or generated. Collecting the complete authored fixture produces **14 Lunar Samples in stacks of 10 and 4, 3 Metal Scrap, and 1 Supply Pack**, occupying four slots.

## Inventory and full-capacity contract

The existing API provides `add_items`, `remove_items`, `get_quantity`, `available_quantity_capacity`, `free_slot_count`, `slot_count`, defensive `slot_snapshot` queries and registered `definition` lookup. Successful mutations emit one `changed` signal; zero/negative quantities, unknown IDs and invalid definitions safely fail without mutation. Nonstackable copies occupy separate slots. The removal API returns the actual available amount removed and frees empty slots; it does not implement item consumption behavior.

**Partial acceptance remains the selected pickup policy.** The world object subtracts only the quantity actually accepted by inventory, then disappears only at zero. A full inventory leaves both sides unchanged and reports failure through GameUI. Excess is never silently destroyed.

The new application-level acceptance case tests this through the actual player inventory, E input, UI and mode coordinator:

1. Fill the real 20-slot inventory using its public API: 19 nonstackable Supply Packs and an 8/10 sample stack. This setup exists only inside the test.
2. Approach a temporary quantity-5 sample pickup and press E. Exactly two samples fit; inventory reaches 10 and that pickup remains with three. The existing prompt remains valid and the HUD reports collection.
3. Press E again while full. Inventory remains at 10, the pickup remains at three, GameUI reports “Inventory full or item unavailable,” and no inventory transaction refresh occurs.
4. Open inventory with I. Its UI displays 20/20 used slots and the exact final sample stack, while movement/interaction are disabled.
5. Close with Esc, enter management with Tab and verify the same world/inventory/pickup instances, sample quantity 10, Supply Pack quantity 19 and world remainder three. Both actors stay stationary there.
6. Return to Player Mode, remove three samples through the tested API, then press E. The final world remainder is collected and the pickup disappears. Item conservation is checked: initial eight plus world five equals final ten plus the explicitly removed three.

The fixture does not add pickups, items or balancing changes to the production map. The normal four-pickup scene remains unchanged.

## Controls and mode behavior

- **E or left-click:** collect the nearest valid target in Player Mode. Held/echoed input does not repeatedly collect, and mode/modal reentry requires a fresh interaction after release.
- **I:** open/close inventory in Player Mode. Native arrows and mouse inspect items.
- **Esc or Close:** dismiss the existing inventory modal.
- **Tab:** switch the existing cameras while inventory is closed. Management retains pan/zoom and disables player interaction.
- **WASD/arrows:** existing movement or management pan. Inventory stops player movement; held movement remains safely gated after close until release.

The world is not globally paused by inventory. Chiwis remains autonomous in Player Mode, pauses in management as before, and resumes after return. Inventory and collected-object state persist across camera switches. Restarting a session creates fresh runtime state; long-term disk persistence is deferred.

## Changes made in Phase 0.8

Created:

- `docs/phase_0_8_report.md`.

Modified:

- `tests/interaction_inventory_test.gd`: added a fresh authored-item acceptance scenario, actual E collection of Metal Scrap/Supply Pack as well as both sample pickups, all-three-item UI assertions, real 20-slot capacity/remainder/failure-notice tests, same-instance camera persistence, remainder recovery and conservation checks, and three new screenshots.
- The same test now explicitly focuses its starting slot before native arrow navigation and aligns focus with inspected slots for acceptance captures. This fixes ambiguous test setup without changing inventory behavior or removing the keyboard-navigation assertion.
- `tests/validate.ps1`: retain all suites and report the current Phase 0.8 validation scope.
- `AGENTS.md`, `README.md`, `docs/architecture.md`: current phase boundary, reuse/ownership contract and acceptance coverage.

No production script, scene, item Resource, terrain/character/UI resource, asset PNG, art manifest, project setting or input binding was changed. This was verified by hashing the before/after production file set. Existing historical reports remain unchanged. No external assets were modified, no new dependencies installed, and no commits or repository initialization performed.

## Executed validation

Ran focused graphical acceptance and the complete **`./tests/validate.ps1 -IncludeRendering`** suite with Godot **4.7.2.stable.official.ed1daf0bf**. Engine user/editor profiles remain inside ignored project output; the established certificate-store permission was allowed for engine startup.

| Validation | Actual final result |
| --- | --- |
| Editor import / existing JSON | Passed |
| Runtime/test GDScript check-only parses | 45 passed |
| Inventory unit tests | 38 checks passed |
| Interaction/inventory integration | **95 headless / 101 graphical checks passed** |
| UI foundation | 147 headless / 169 graphical / 151 fullscreen checks passed |
| Foundation/native hierarchy | 470 headless / 472 graphical checks passed |
| Isometric world | 33,961 checks passed |
| Moon terrain | 338 headless / 342 graphical checks passed; raster gaps/overlaps remain zero |
| Player camera | 49 checks passed |
| Gameplay modes | 93 headless / 99 graphical / 93 fullscreen checks passed |
| Astronaut movement/animation | 234 headless / 244 graphical checks passed |
| Original character assets | 696 checks passed |
| Run animation | 903 headless / 911 graphical checks passed |
| Chiwis following/routing | 44 headless / 46 graphical checks passed |
| Main headless, graphical editor and fullscreen startup | Passed |

Existing tests continue covering exact range, nearest/tied/invalid targets, unsafe terrain reach, E press/hold/echo, all stack boundaries, zero/negative/unknown quantities and invalid references, add/remove APIs, inventory focus/input restrictions, camera-mode handoffs, stale-input protection and event-driven UI. The new acceptance flow adds full-capacity behavior through the actual integrated player/UI input path, beyond the existing isolated capacity model test.

**Final errors: 0. Final warnings: 0.** An initial native arrow-navigation check exposed an ambiguous focus setup; the test now explicitly establishes focus and retains the real navigation assertion. The focused test and entire final suite were rerun successfully. No failed assertion was skipped.

## Graphical evidence

Godot ran with the existing Compatibility/OpenGL renderer. Captures were inspected for correct prompts, item icons/names/descriptions, capped stack quantities, full capacity, modal state, matching selection focus, readable HUD feedback and the preserved lunar actors/map. This is automated native keyboard/mouse/physics/rendering plus screenshot inspection, not a physical keyboard/mouse play session.

Evidence under `tests/output/`:

- `interaction_prompt.png`: existing nearby sample prompt in the current UI.
- `phase_0_8_inventory.png`: all authored items, sample stacks 10/4, scrap stack 3, Supply Pack 1, four used slots and Supply Pack details.
- `phase_0_8_full_inventory.png`: test-only 20/20 capacity fixture and the exact last sample stack.
- `phase_0_8_management.png`: the same world/actors and partial world pickup after the capacity rejection and camera switch.
- `interaction_inventory.log`, `interaction_inventory_rendered.log`, inventory/unit logs and all prior regression/UI/fullscreen captures.

## Manual checks and limits

1. Run F5 in Godot 4.7.2. Approach the lunar markers and check contextual prompts. Press E once per pickup; holding it must not repeatedly collect.
2. Collect both samples, Metal Scrap and Supply Pack. Open I: expect stacks 10/4, 3 and 1 respectively. Inspect with arrows/mouse and verify names/descriptions; no crafting/equipment/item-use interface should appear.
3. Open inventory while moving. Confirm immediate idle, blocked E/Tab, preserved position and focus in the modal. Close using I/Esc/Close, release held input and resume normally.
4. Switch to management and back with the inventory closed. Verify pan/zoom, paused/resumed actor behavior, the same inventory contents and no collected pickups respawning.
5. Run `./tests/validate.ps1 -IncludeRendering` for the full-capacity fixture and conservation proof. That fixture is test-only; the production map remains the original small four-pickup setup.

The existing lightweight foundation intentionally has no crafting, processing, equipment, item consumption, containers/transfers, resource respawning or disk save/load. Capacity is configured before inventory initialization; runtime resizing is not implemented. Item art remains placeholder presentation. No subsequent phase was started.
