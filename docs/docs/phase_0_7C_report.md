# Phase 0.7C - UI Foundation

Implemented a lightweight, reusable Moon interface for **Godot 4.7.2.stable.official.ed1daf0bf**, using native Control nodes, a shared Theme and the existing screen-space CanvasLayer. It works at the established **960 x 540** logical resolution with unchanged integer viewport scaling and nearest texture filtering.

The project already contained functional inventory and interaction systems from Phase 0.7. Those features were preserved and composed into the new interface. No survival calculations, tutorial missions, fake status quantities, new gameplay controls, audio, artwork generation or subsequent phase work was added. Existing terrain, character assets/animations, movement, Chiwis following, cameras and inventory data remain intact.

## UI architecture

`scenes/ui/game_ui.tscn` is the reusable composition scene instanced at `Main/UI`:

```text
UI (GameUI / CanvasLayer, layer 10)
  GameHUD (passive full-viewport Control)
    TopBar
      Identity / optional developer badge
      ExpansionSlot
      ActiveMode / Controls
    StatusPanel
      Six reserved named readouts
    Notifications
      Informational message / one-shot expiry timer
    BottomBar
      InventoryHint / ModeHint
  InteractionPrompt
    PromptPanel / Text
  InventoryWindow (existing modal interface)
```

Main supplies existing inventory, interaction, mode and camera references. GameUI composes presentation, GameHUD handles mode/zoom/window hints, and existing systems remain the owners of gameplay state. `UI/InventoryWindow` and `UI/InteractionPrompt` retain their existing attachment points. The old `UI/DevelopmentScreen` instance and combined footer were replaced by the new HUD; the unused source scene is preserved as historical material.

| UI element | Current implementation |
| --- | --- |
| Active mode | Dedicated label showing exactly **PLAYER MODE** or **BASE MANAGEMENT MODE** |
| Camera/control help | Separate mode-aware walk/pan hint, with current management zoom |
| Interaction area | Reusable scene-authored panel, showing the existing contextual `[E] Collect Lunar Sample` or other target label |
| Inventory hint | Shows binding/open-close state and clarifies Player Mode availability |
| Future status panel | Six named rows with empty `-` values and “Readouts unavailable” |
| Expansion structure | Top bar with a flexible expansion/spacer container and separate side panel |
| Notifications | One bounded informational message slot, shared by system/tutorial presentation and existing collection feedback |
| Inventory modal | Existing 20-slot interface retained, themed consistently and centered with anchors |

The HUD/prompt are passive: every Control uses mouse-ignore and no keyboard focus. Actual mouse clicks through the top bar still reach the existing world action, and management wheel events pass through it. Only the existing inventory intentionally captures input and disables movement/interactions/mode changes. No new shortcut, pause mechanism or global UI/input manager was introduced.

## Reserved future sections

The status scene contains these explicitly named rows:

1. Physical condition.
2. Emotional state.
3. Sleep.
4. Radiation.
5. Cardiac state.
6. Defenses / body condition.

Every current value is a static empty marker. There is no health/stamina percentage, deterioration, damage, radiation accumulation, emotional simulation, sleep processing, cardiac model, defense calculation or status manager behind these labels. Future approved systems can provide explicit data to their view without moving simulation into UI scripts. The top bar's expansion slot and notification API reserve presentation space without creating time, mission or resource systems.

## Event-driven updates and APIs

GameHUD listens to the existing mode, management zoom and inventory visibility signals. The prompt listens to the existing target/interaction signals and clears safely if its detector leaves the tree. Collection results now use the reusable notification area rather than a second inline feedback label/timer. This preserves feedback while consolidating its presentation.

The interface exposes:

- `GameUI.configure(...)`: composition-root wiring of existing references and optional developer-badge visibility.
- `GameUI.notify(text, duration = 3.5) -> bool`: informational text only; never pauses the world, changes mode or takes focus.
- `GameUI.refresh_bindings()`: refreshes inventory/mode key labels and the contextual prompt after intentional InputMap changes.
- `NotificationArea.clear_message()`: stops expiry and restores “No new messages.”

Notifications use a single latest-message slot. A new message replaces the old one, resets one one-shot timer and reuses the same controls. Text is trimmed, line breaks normalized, and length limited to 180 characters by default, with an ellipsis when truncated. Invalid/empty text or nonpositive/nonfinite durations are rejected without changing the active message. The configured text limit is safely bounded. Expiry restores the quiet placeholder. There is no queue, history store, severity framework or tutorial progression logic.

InputHint reads existing InputMap actions on UI events or explicit refresh, without per-frame polling. No action was rebound or added. Movement/pan help describes the established WASD/arrow defaults; the existing I/Esc/Tab/E/mouse behavior remains. Native keyboard/mouse focus and modal restrictions remain owned by PlayerSession and InventoryWindow.

There is no per-frame HUD refresh, continuous tree search or repeated control creation. Static status rows have no script. Inventory remains driven by its existing transaction signals. UI composition does not create a second inventory, duplicate the world or alter data during mode changes.

## Theme, layout and development settings

`resources/ui/development_theme.tres` centralizes the temporary panel/button colors, borders, focus indication and default font size. GameHUD, interaction prompt and inventory share it. Panels have square edges and integer logical coordinates; character/item textures retain nearest presentation. No final UI PNG, icon generation or font dependency was introduced. Existing native item placeholders remain unchanged.

The top bar, side status panel, top-right notification area, bottom hints and bottom-center prompt use viewport anchors/containers. The inventory panel now centers through anchors while preserving its original 784 x 388 logical dimensions and default 960 x 540 placement. All six status names fit without clipping. Notification text wraps within its bounded panel, and the central player-focused region remains clear in normal Player Mode.

Final artwork can replace Theme style boxes or widget visuals while retaining named containers, public APIs and state ownership. Passive HUD controls are deliberately noninteractive. A future interactive HUD element must receive an explicit input policy in an approved task rather than silently consuming world input.

The gameplay HUD remains visible independently of debug configuration. The existing `DevelopmentSettings.show_development_screen` field keeps its stored name and now controls only the optional **MOON / DEVELOPMENT** badge. Disabled/missing configuration or a release build hides that badge while preserving mode, prompt, inventory hints and other game UI. Existing startup-log gating is preserved. Tests cover the revised badge behavior instead of hiding the entire game interface.

## Files created or modified

Created scenes:

- `scenes/ui/game_ui.tscn`: reusable CanvasLayer composition.
- `scenes/ui/game_hud.tscn`: anchored top/bottom bars and passive widget layout.
- `scenes/ui/status_panel.tscn`: six reserved readouts.
- `scenes/ui/notification_area.tscn`: message slot and one-shot timer.

Created resource/scripts/tests:

- `resources/ui/development_theme.tres`.
- `scripts/ui/game_ui.gd`, `game_hud.gd`, `notification_area.gd`, `input_hint.gd`.
- `tests/ui_foundation_test.gd`.
- Five Godot `.gd.uid` sidecars for the four new runtime scripts and test.
- This report.

Modified:

- `scenes/main.tscn`: instance GameUI instead of separately composing the retired development overlay/prompt/inventory.
- `scripts/core/main.gd`: inject UI references/configuration and keep actor mode permission separate from presentation.
- `scenes/ui/interaction_prompt.tscn`, `scripts/ui/interaction_prompt.gd`: reusable anchored prompt panel, shared binding helper, safe clearing and notification signal.
- `scripts/ui/inventory_window.gd`: center the existing modal through anchors; inventory behavior and slot/data APIs unchanged.
- `tests/foundation_test.gd`: validate the current HUD path and optional badge while keeping resource/hierarchy/configuration checks.
- `tests/gameplay_modes_test.gd`: read the dedicated mode and zoom labels instead of the retired combined footer; all mode assertions retained.
- `tests/validate.ps1`: add headless, graphical, resize and fullscreen UI checks while retaining every previous suite.
- `AGENTS.md`, `README.md`, `docs/architecture.md`, `docs/input_bindings.md`: current composition, passive-input contract, developer-badge setting and APIs.

A before/after production-file hash comparison found changes only in the intended Main/UI scripts and scenes listed above. Project settings/InputMap, all terrain resources/data/scripts, character PNGs/SpriteFrames/art profiles, movement/companion/animation/camera/mode/session controllers, interaction/inventory data systems and prior reports remain unchanged. No external artwork was read or written, and no commits or repository initialization were performed. Engine profiles, logs and screenshots remain under ignored `tests/output/`.

## Executed validation

Ran focused native graphical UI checks, then the complete **`./tests/validate.ps1 -IncludeRendering`** suite using Godot 4.7.2. The new suite also runs headless and fullscreen; the graphical windowed pass resizes to **1280 x 720**, checks logical bounds and restores the original size. Existing editor/main fullscreen startup checks remain. Engine user/editor data stays project-local, with the established certificate-store access allowed for engine startup. No dependency was installed.

| Validation | Actual final result |
| --- | --- |
| Editor import / existing JSON files | Passed |
| All runtime/test GDScript check-only parses | **45 passed** |
| Foundation/native hierarchy | 470 headless / 472 graphical checks passed |
| New UI foundation | **147 headless / 169 graphical / 151 fullscreen checks passed** |
| Isometric world | 33,961 checks passed |
| Moon terrain | 338 headless / 342 graphical checks passed; zero raster gaps/overlaps |
| Player camera | 49 checks passed |
| Gameplay modes | 93 headless / 99 graphical / 93 fullscreen checks passed |
| Astronaut movement/animation | 234 headless / 244 graphical checks passed |
| Original character asset checks | 696 passed |
| Run animation | 903 headless / 911 graphical checks passed |
| Chiwis following/routing | 44 headless / 46 graphical checks passed |
| Inventory | 38 checks passed |
| Interaction/inventory integration | 64 headless / 67 graphical checks passed |
| Main headless / graphical editor / main fullscreen startup | Passed |

The new UI suite verifies all required widgets, six empty readouts, shared theme/nearest filtering, passive mouse/focus policy recursively, quiet/event-driven behavior, source-action remapping and restoration, actual click/wheel pass-through, notification replacement/expiry/limits/invalid inputs, existing collection feedback, modal hints and Tab/movement restrictions, camera-independent screen position, mode/zoom updates, panel/text bounds, integer positions, resize behavior, preserved inventory/map data and no survival manager. The prior mode suite was updated to assert the relocated zoom text; the initial old-footer assertion mismatch was corrected and the full suite rerun without skipping checks.

**Final errors: 0. Final warnings: 0.** All new and existing suites passed. No asset exporter or generation service was run in this phase.

## Graphical evidence and manual checks

Native graphical execution used the existing Compatibility/OpenGL renderer. Screenshots were inspected at the logical 960 x 540 output: mode labels, all six status names, hints, message wrapping and inventory text are readable; panels fit; controls retain sharp pixel textures; the modal overlays the HUD correctly. Fullscreen and resized captures retain the same logical presentation. This is automated keyboard/mouse/physics/rendering plus screenshot inspection, not a physical keyboard/mouse session.

Evidence under `tests/output/`:

- `ui_player.png`: complete default Player Mode UI and contextual collection prompt.
- `ui_management.png`: management mode/zoom/availability hints, preserved world.
- `ui_notice.png`: wrapped system notice in the reusable message area.
- `ui_inventory.png`: existing inventory above the dimmed HUD.
- `ui_resized.png`: native window resize validation.
- `ui_fullscreen.png`: fullscreen UI validation.
- `ui_foundation.log`, `ui_foundation_rendered.log`, `ui_foundation_fullscreen.log`, plus all previous regression logs/captures.

Manual procedure:

1. Open `project.godot` with Godot 4.7.2 and run F5. Confirm the mode indicator, inventory hint, six empty status readouts and quiet system-message area. Expect the existing contextual prompt near the first lunar sample.
2. Walk and let Chiwis follow. Click through passive HUD panels or press E to collect a nearby valid pickup. Confirm collection feedback appears in the notice area and expires; the HUD must not take focus or stop walking.
3. Press Tab, pan with WASD/arrows and use the wheel to change zoom. Confirm the exact management indicator, zoom hint and Player Mode inventory restriction. The HUD stays fixed while the world camera moves. Return with Tab.
4. Press I. Confirm the same inventory contents and keyboard/mouse inspection, a centered modal and updated close hint. Movement/interaction/Tab remain blocked until I/Esc/Close dismisses it. Release held inputs before resuming as before.
5. Resize the window or launch with `--fullscreen`; inspect panel bounds, text and integer pixel presentation. Displays below the existing 960 x 540 minimum remain outside the supported setup.
6. Toggle the legacy `show_development_screen` setting or disable development configuration. Only the developer badge should disappear; the gameplay interface and actors remain visible.
7. Run `./tests/validate.ps1 -IncludeRendering` to reproduce all checks/captures. Future approved callers can use `GameUI.notify()` for informational text and `GameUI.refresh_bindings()` after remapping the corresponding actions.

## Known limits and phase boundary

The theme and built-in typography are development presentation; final pixel fonts/art are deferred. Status fields intentionally have no live data. Notifications are informational, latest-message-only, with no queue/history, severity/actions or mission progression. No runtime rebinding menu, controller-specific glyph system or new shortcut was added. HUD panels overlay the world rather than reserving a separate gameplay viewport; they remain passive and keep the normal player-centered area clear.

Future status systems and tutorial logic must remain independent from these views and require explicit authorization. The already working interaction/inventory features remain available for future extension. **Phase 0.8 and every other subsequent phase were not started.**
