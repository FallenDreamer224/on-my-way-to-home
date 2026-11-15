# Phase 0.4 - Base management camera and mode switching

Phase 0.4 is complete. Phase 0.5 has not started. There are two camera perspectives over the original world, with input routing and development feedback; no management gameplay or playable character has been implemented.

## Inspection and preserved systems

Inspected AGENTS, the Art Bible, standards JSON, Phase 0.3 report, player rig/temporary target, main/world scenes, input declarations, and existing validation. Preserved Godot **4.7.2**, GDScript, native 2D, 2:1 projection, 64 x 32 tiles, 960 x 540 logical viewport, nearest filtering and integer scaling. The locked art documents, original 12 x 12 region, terrain renderer/data, TileSet configuration, isometric math, Input Map, and temporary target remain unchanged.

## Camera and coordinator architecture

```text
Main (dependency wiring and development feedback)
  Systems
    GameplayModes (GameplayModeCoordinator)
  World (the original single instance)
  TemporaryPlayerTarget (existing Marker2D)
  CameraRig (existing PlayerCameraRig)
    Camera2D
  BaseManagementCameraRig
    Camera2D
  UI / DevelopmentScreen (mode footer and noninteractive backdrops)
```

`GameplayModeCoordinator` is a small local Node, not a singleton or general state-machine framework. Its enum has PLAYER and BASE_MANAGEMENT. `initialize(player, management)` validates both ready rigs, initializes in PLAYER, and emits `mode_changed(mode)`. Public queries `is_player_mode()`, `is_management_mode()`, and read-only `current_mode` expose policy for future controllers. `request_mode(int)` rejects unknown modes, duplicate requests, reentrant transitions, and missing/queued/freed camera references without partial state changes. Reinitialization is rejected.

Camera references are stored once; there are no per-frame tree searches, terrain refreshes, camera creation, or scene reloads. Variant arguments at lifecycle-validation boundaries deliberately permit checking freed Godot Object handles before typed assignment; stored references remain typed. A disposed camera does not get recreated automatically: transitions return false safely and the world remains intact. Lifetime recovery policy belongs to future scene lifecycle work.

Normal transitions first prepare/activate/select the incoming Camera2D, then disable the outgoing rig. Godot's supported `enabled`/`make_current()` APIs give one current viewport camera; no rendered iteration occurs between these synchronous calls. This ordering avoids relying on fallback camera selection. Camera nodes persist throughout normal switching. The game is never paused by a transition.

## Independent camera state

The player rig retains its Phase 0.3 API, target following, offsets, safe target loss, optional bounds, default 2x zoom and 1-4 configured range. Reactivation refreshes target position immediately and preserves its own zoom. It never inherits management pan offsets. The player tests remain unchanged and pass.

The separate management rig starts disabled, at **1x**, with configurable minimum 1x and maximum 3x. It owns continuous world-space `pan_position`, `zoom_level`, `movement_speed`, and optional bounds independently. The first management entry uses the player target's global position; if unavailable, it uses the last player-camera view. Later entries never reset management position or zoom. `set_pan_position(Vector2)`, `pan(Vector2, delta)`, `set_zoom_level(float)`, `activate()`, `deactivate()`, and `is_active()` provide reusable interfaces without input or terrain dependencies. Call activation interfaces after the rig is ready; the coordinator validates readiness.

`set_zoom_level` rejects nonfinite requests and quantizes/clamps finite requests. Integer property setters enforce a positive effective range. `zoom_changed(level)` updates the development footer. No cursor-centered zoom or camera animation is implemented.

`CameraFraming` shares the existing player rig's pixel snapping and viewport-aware bounds math with management. This extraction preserves player behavior and prevents policy drift without adding a camera inheritance framework. It has no input, world, or scene dependency.

## Input routing and panning

No InputMap actions or defaults were changed. The coordinator routes the existing `mode_switch` action through unhandled input; Tab presses toggle modes, key repeats are ignored, and releases do not transition. GUI event consumption takes precedence.

During management only, the coordinator combines `player_move_*` (WASD) and `camera_pan_*` (arrows), caps combined vector length at one, and routes it to management `pan`. This reuses existing action definitions without duplicate key bindings. Movement is screen-aligned, not transformed through isometric grid axes. The temporary target never moves through these controls. Future player movement must query `is_player_mode()` before reading those same actions.

Default speed is **360 logical-screen pixels/second**, configurable on BaseManagementCameraRig. World displacement is normalized direction times speed times delta divided by zoom, so apparent screen panning speed remains comfortable across zoom levels. Logical pan accumulation is not rounded every frame; only rendering is snapped, so very small frame displacements accumulate instead of stalling. Bounds clamp accumulated state before rendering, preventing large hidden overshoot and sticky edges.

Wheel up/down uses the existing camera zoom actions in management only. Each unhandled press moves one integer level, clamped to 1, 2, or 3. Releases do nothing, and repeated events saturate at the limits. Player zoom is never changed by the wheel. Zoom is centered on the viewport, not the cursor.

A focused UI Control blocks keyboard pan and mode shortcuts; unhandled wheel events are also blocked while a Control owns focus. This conservative policy protects editors and future UI. A modal UI without a keyboard focus owner should consume its events and establish an explicit input block/focus contract when introduced. There are no focusable runtime HUD controls in this phase. Closing a future panel must release or transfer focus intentionally.

## Pixel presentation and bounds

Both rigs keep smoothing/rotation off and share `round(center * zoom) / zoom` render-center snapping. Camera world positions may have fractions that correspond to whole logical-screen pixels at integer zoom; simulation/terrain data is not quantized. Keep rig parents and Camera2D children unscaled/unrotated, with zero extra child offsets. Nearest textures, integer viewport scaling, and the 960 x 540 logical resolution remain unchanged.

Bounds are optional and disabled by default, independent of the small test map. Viewport half-extents are accounted for at each zoom. Axes smaller than the visible world extent do not clamp and force an incorrect center. Invalid/nonfinite rectangles are ignored. Management clamps its continuous position without snapping, then snaps and bounds the rendered center. Unbounded panning can intentionally expose void beyond the test terrain. Bounds are rectangular; they do not model diamond outlines or world collision.

## Shared world and development UI

Both cameras view the same World/TileMapLayer instance. The coordinator never references terrain-generation functions or creates simulation instances. Tests retain the world's/layer's instance IDs and a copy of logical terrain cells across transitions; identity and data remain unchanged. A complete persistent save system is still deferred.

The existing development screen displays PLAYER MODE or BASE MANAGEMENT MODE, controls, and current management zoom. Mode signals update it synchronously; wheel zoom signals update the displayed level. Dark, mouse-ignoring header/footer backdrops keep labels readable over terrain. Hiding the screen with `show_development_screen` hides all labels/backdrops. Disabling development settings also hides the existing cross; camera operation remains enabled. This is not a final HUD.

## Files created and modified

Created:

- `scripts/camera/base_management_camera_rig.gd`
- `scripts/camera/camera_framing.gd`
- `scripts/gameplay/gameplay_mode_coordinator.gd`
- `scenes/camera/base_management_camera_rig.tscn`
- `tests/gameplay_modes_test.gd`
- `docs/phase_0_4_report.md`
- Godot-generated `.gd.uid` sidecars for the three new runtime scripts and new test; retain with source.

Modified:

- `scripts/camera/player_camera_rig.gd`: delegate identical snapping/bounds policy to CameraFraming; preserve public API and activation/follow behavior.
- `scenes/main.tscn`: instance management rig and local coordinator.
- `scripts/core/main.gd`: initialize coordinator with both rigs; connect development indicator signals; update startup message.
- `scenes/ui/development_screen.tscn`: initial mode label and noninteractive contrast backdrops.
- `tests/validate.ps1`: include new headless mode tests and graphical/windowed/fullscreen input tests.
- `AGENTS.md`: current authorized scope and Phase 0.5 boundary; preserve art instructions and prior scope history.
- `README.md`, `docs/architecture.md`, `docs/input_bindings.md`, `scripts/gameplay/README.md`: current camera/mode/input ownership and manual instructions.

All existing foundation, world, and player-camera test scripts remain unchanged. Dynamic foundation check counts grow because the existing hierarchy/resource checks inspect the new nodes/files. No project settings, terrain resources, locked art standards, third-party assets, dependencies, audio, commits, or PixelLab generation were added or changed. Godot regenerates only ignored cache/profile/log/capture output during validation.

## Actual automated and graphical results

Ran `./tests/validate.ps1 -IncludeRendering` with **4.7.2.stable.official.ed1daf0bf**. Profiles, logs, and PNGs stay under `tests/output/`; as in previous phases, this restricted environment requires certificate-store read access for editor initialization. The runner checks logged script errors as well as exit codes. An initial freed-reference typing error was caught by this check, corrected, and rerun successfully; it is not an unresolved failure.

| Check | Final actual result |
| --- | --- |
| Headless editor import | Passed |
| All 15 GDScript check-only parses | Passed |
| Both existing JSON files | Valid |
| Foundation integration, headless | 194 checks passed |
| Original isometric world suite | 33,961 checks passed |
| Original player-camera suite | 49 checks passed |
| Mode integration, headless | 93 checks passed |
| Main headless startup | Passed |
| Graphical editor / main startup | Passed, OpenGL Compatibility |
| Graphical foundation capture | 196 checks passed |
| Windowed graphical mode/input suite | 99 checks passed |
| Fullscreen startup | Passed |
| Fullscreen mode/input suite | 93 checks passed |
| Production/native hierarchy scans | Passed; no obsolete spatial architecture/audio nodes |

Mode tests use real `Input.parse_input_event` dispatch for Tab, echoed Tab, W, arrow keys, wheel presses/releases, and focused-UI behavior. Deterministic controller calls additionally check 30/60-step frame independence, normalized diagonal speed, zoom-adjusted speed, tiny-step accumulation, bounds and edge recovery, and gating while inactive. Tests cover initial modes/cameras, invalid/duplicate requests, repeated transitions, native viewport centers, player reacquisition, independent zoom/state, notification/label updates, shared-world identity/data, target loss on first entry, and missing/queued/freed camera references including initialization. All temporary objects/input state are cleaned up; nothing is saved to world data.

Graphical tests dispatch the same inputs in a running renderer, not just direct method calls; they also run fullscreen. This reliably automates the requested interactive paths, but no manual physical-keyboard/mouse session is claimed. PNGs were visually inspected for correct mode labels, sharp pixels, visible terrain and restored player framing. Consecutive stationary captures in both modes are byte-identical in the regression check, providing a short static-jitter/flicker check.

Captures in `tests/output/`:

- `foundation.png`: initial player view.
- `management_mode.png`: overview at 1x.
- `management_zoom_2x.png`: management wheel zoom at 2x.
- `player_mode_restored.png`: return to the target-following player view.

Final errors: **0**. Final warnings: **0**. No failed test is skipped. Multi-monitor/DPI combinations, release exports, long-duration motion, and physical-device-specific wheel behavior were not certified.

## Manual procedure

1. Open `project.godot` with Godot 4.7.2 and press F5 (or F6 on Main). Confirm PLAYER MODE, a centered target cross, and 2x terrain pixels.
2. Press Tab once. Confirm BASE MANAGEMENT MODE, 1x zoom, and the same lunar terrain. Holding Tab should not repeatedly switch.
3. Pan with WASD or arrows, including diagonals. Use wheel up/down for 1x/2x/3x. The footer should reflect management zoom; no player movement is expected.
4. Return with Tab. Confirm immediate target framing at the player camera's own zoom. Reenter management and confirm its pan and zoom are restored rather than reset.
5. Optionally move TemporaryPlayerTarget in the Remote inspector while managing; it should not pull management around. Return to player view to verify target reacquisition.
6. Test resize and fullscreen (`--path <project-directory> --fullscreen`) and repeat the controls. Check sharp pixels and letterboxing. Close normally (Alt+F4 on Windows).
7. Inspect independent `movement_speed`, zoom limits, `bounds_enabled`, and `world_bounds` in the rigs. Bounds remain off by default. Do not interpret the small test-map outline as a final world limit.
8. Reproduce all automated checks with `./tests/validate.ps1 -IncludeRendering` in PowerShell 7. Current captures and logs are in ignored `tests/output/`.

## Phase 0.5 considerations only

Introduce actual player behavior only when explicitly assigned. Reuse the coordinator's mode queries so WASD moves the player only in PLAYER and pans only in BASE_MANAGEMENT. Replace the temporary target through the existing player-camera API, retain a ground/foot anchor, and add motion/animation pixel QA with the approved assets. Define UI/modal focus and held-key handoff policy with that controller; this phase deliberately does not implement player controls. Keep any future resource, infrastructure, equipment, power, and survival state outside both cameras and the presentation coordinator. There are no human-worker/colonist systems planned. Phase 0.5 has not begun.
