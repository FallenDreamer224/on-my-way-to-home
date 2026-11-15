# Initial input contract

All actions are declared in `project.godot`, configurable in Project Settings > Input Map. Phase 0.7 reuses existing actions and adds E to primary interaction while preserving left-click. Tab toggles modes; WASD/arrows move the astronaut in Player Mode or pan in management. Wheel zoom is management-only. I toggles the Player Mode inventory; Esc closes it. Global pause remains unimplemented. Keyboard defaults use physical key positions; built-in `ui_*` actions retain their defaults.

| Action | Default | Purpose |
| --- | --- | --- |
| `player_move_up` | W | Movement up |
| `player_move_down` | S | Movement down |
| `player_move_left` | A | Movement left |
| `player_move_right` | D | Movement right |
| `interact_primary` | E, left mouse | Collect nearest valid target within configured world range |
| `interact_secondary` | Right mouse | Secondary world interaction |
| `mode_switch` | Tab | Player / Base Management mode |
| `camera_pan_up` | Up arrow | Overview pan up |
| `camera_pan_down` | Down arrow | Overview pan down |
| `camera_pan_left` | Left arrow | Overview pan left |
| `camera_pan_right` | Right arrow | Overview pan right |
| `camera_zoom_in` | Wheel up | Overview zoom in |
| `camera_zoom_out` | Wheel down | Overview zoom out |
| `inventory_toggle` | I | Inventory |
| `game_pause` | Escape | Close inventory; future global pause is unimplemented |

Both controllers combine WASD and arrows and cap vector length at one. Astronaut moves at 80 world pixels/second by default in screen-aligned directions, with physics updates and normalized diagonals. The coordinator routes camera panning at 360 logical-screen pixels/second divided by zoom only in management. Main forwards mode policy to the astronaut, which stops velocity and idles immediately when disabled. Held movement keys across a return to Player Mode must all be released before walking; fresh presses after a neutral handoff respond immediately. Focused UI also blocks movement and protects against stale held input. Tab/wheel use unhandled input, ignore echoed Tab and wheel releases, and wheel changes one level clamped to 1-3.

Future controls must use mode queries and respect UI focus. No runtime rebinding menu, input persistence, pause behavior, or fullscreen key handler is implemented. Engine fullscreen can be tested with `--fullscreen`. Future rebinding must validate collisions in active contexts, including UI/modal actions.

PlayerSession handles I/Esc before GUI dispatch so the window can close while a slot owns focus. While open, Tab is consumed and the mode coordinator's modal guard rejects direct mode-change requests and camera input. Native inventory buttons receive mouse/arrow focus input. Closing releases owned focus and uses the astronaut's existing neutral-input handoff; Chiwis/world simulation is not paused.

InteractionDetector uses unhandled primary input, revalidates permissions/focus/range/terrain, ignores echo and latches one action per press. Mode/modal reentry samples held primary input and requires release before another collection. The prompt and HUD hints derive binding labels from InputMap; after runtime remapping, call `GameUI.refresh_bindings()` as part of the future settings UI. E is only the initial binding.

Phase 0.7C adds no shortcuts. The passive GameHUD, status fields, notifications and prompt ignore mouse events and keyboard focus, so world clicks and management wheel input pass through. Only the existing inventory window intentionally captures UI input and blocks gameplay/mode switching. Notification presentation never pauses the world or takes focus.
