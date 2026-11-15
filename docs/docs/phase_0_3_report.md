# Phase 0.3 - Player-focused isometric camera

Phase 0.3 is implemented and validated in Godot **4.7.2.stable.official.ed1daf0bf**. Phase 0.4 is not started.

## Inspection and preservation

Read AGENTS, the Art Bible, asset standards JSON, main/world scenes, IsometricGrid, the Phase 0.2 report, existing camera scene and validation suites. Extended the existing `scenes/camera/camera_rig.tscn` rather than creating a second competing rig. The original 12 x 12 map, terrain data, TileMapLayer/TileSet, coordinate basis, nearest filtering, 960 x 540 resolution, integer viewport presentation, input declarations, and locked art standards are unchanged.

## Architecture and initialization

```text
Main (composition, development configuration)
  World (existing independent lunar world)
  TemporaryPlayerTarget (Marker2D, removable debug cross)
  CameraRig (PlayerCameraRig : Node2D)
    Camera2D
  UI (existing CanvasLayer and development labels)
```

PlayerCameraRig has no input handlers, player/controller dependencies, world-state writes, global singletons, or terrain queries. Main initializes the temporary target with `IsometricGrid.tile_to_world(Vector2i.ZERO, ground)`, then calls `camera_rig.set_follow_target(temporary_target)`. Cell `(0, 0)` is near the map center; its position is never guessed in screen space. The Camera2D child starts disabled, and the rig explicitly activates it during ready unless `active_on_start` is false. Target injection refreshes the position immediately, before the first presented frame.

The debug cross is code-drawn, not a character sprite or an external asset. It draws only in debug builds; Main hides it when development settings are disabled/missing. It has no movement script or input. The root represents a ground contact position. No player, Chiwis, T, character animation, or final art was created.

## Public camera contract

| Property/method | Behavior |
| --- | --- |
| `follow_target: Node2D` | Inspector-assignable target; normal runtime replacement can use the method below |
| `set_follow_target(target)` | Replace/null the target; refresh immediately when ready and active |
| `follow_offset: Vector2` | Global world-space offset, default zero; applied before presentation snapping |
| `minimum_zoom`, `maximum_zoom` | Integer configurable limits, defaults 1 and 4; runtime edits reclamp current zoom |
| `zoom_level` | Integer zoom, default 2; direct property edits clamp and update Camera2D |
| `set_zoom_level(requested: float) -> bool` | Clamp finite requests and round to integer; reject NaN/infinity without changing zoom |
| `active_on_start` | Default true; false supports initially inactive rigs |
| `activate()` | Enable, refresh follow, explicitly make current, enable processing |
| `deactivate()` | Disable this Camera2D and follow processing; do not explicitly select another camera |
| `is_active()` | True only if requested active, ready, enabled, and actually current |
| `refresh_follow()` | Explicit immediate refresh; normal following also runs each idle frame |
| `bounds_enabled`, `world_bounds: Rect2` | Optional world-space axis-aligned bounds; default disabled |

Minimum zoom is normalized to at least 1; if configured maximum is below minimum, the effective upper bound equals the minimum. The Inspector exposes integer values from 1 through 16 for configuration convenience, with the requested 1-4 defaults. There are no mouse-wheel controls. Changing the project viewport is unnecessary.

Missing, freed, queued-for-deletion, or detached targets leave the last valid view unchanged. Invalid/nonfinite target positions or offsets are ignored. No continuous node lookup, signal reconnection, or target search occurs. Normal follow never calls `make_current`, so it does not steal ownership when another camera becomes current. A future mode coordinator must still explicitly deactivate the old rig.

To replace the temporary target, instance the future player under the world entity hierarchy, place its foot/root position through the world coordinate contract, and pass that Node2D to `set_follow_target`. Remove the temporary marker and its Main wiring when doing so; no camera implementation changes are needed. Changing exported `follow_target` directly is also picked up on the next active frame.

## Follow and pixel rendering

The rig directly follows global target position plus offset, without time integration or interpolation. Its process priority is 100, after ordinary priority-0 target updates; Camera2D uses idle processing. Smoothing stays disabled. For a future controller with a different update ordering, explicitly order target updates before the rig or call refresh after moving it; do not add smoothing to conceal an ordering issue.

The displayed center is `round((target_global + offset) * zoom) / zoom`. At 2x this permits half-world-pixel camera increments, which map to whole logical-screen pixels. Simulation/target positions remain untouched. The maximum centering difference is half a logical-screen pixel per axis; this deliberate quantization avoids subpixel terrain jitter. Integer zoom and nearest filtering preserve uniform pixel edges. Keep the rig, Camera2D child, and their parents unscaled/unrotated, with no extra Camera2D offset, drag, limits, or interpolation. The current scene satisfies those conditions.

No screen shake, cinematic effects, transitions, advanced interpolation, or global snapping settings were added. A 2x view intentionally crops the outer portions of the unchanged map; it is a player-focused close view rather than an overview. Target snapping does not solve future animated-sprite motion alignment; that must be tested with an approved player phase.

## Bounds and future management compatibility

Bounds are disabled by default and are not inferred from the small lunar map. When enabled, each axis clamps the center by half the visible world extent (`viewport_size / (2 * zoom)`), with limits rounded inward to valid render-pixel positions. An axis too small to fit the viewport, or with no representable snapped center, does not clamp. This avoids pulling the target toward an arbitrary center for undersized maps. Invalid/nonfinite or nonpositive rectangles are ignored. Bounds are axis-aligned; they do not model diamond edges, concave terrain, or obstacles.

Future large-region metadata should supply optional bounds independently of camera behavior. Decide whether exposing void near nonrectangular edges is acceptable before adding geometry-specific limits. No streaming or region loading was added.

The rig has independent position, zoom, target, and activation state. A future management rig can coexist and operate on the same world. Phase 0.4 should centralize camera ownership, call deactivate/activate deliberately, and preserve each rig's configuration. There is no management camera, Tab switching, mode state machine, free movement, or interactive zoom in this implementation. A second plain Camera2D exists only transiently inside an isolated ownership test; it is not a gameplay management system.

## Files

Created:

- `scripts/camera/player_camera_rig.gd`
- `scripts/camera/temporary_camera_target.gd`
- `tests/player_camera_test.gd`
- `docs/phase_0_3_report.md`
- Godot-generated `.gd.uid` sidecars for the two scripts and camera test; retain with source.

Modified:

- `scenes/camera/camera_rig.tscn`: attach controller, initialize disabled Camera2D at 2x, select idle callback and late rig priority.
- `scenes/main.tscn`: add temporary Marker2D and remove the previous static camera position.
- `scripts/core/main.gd`: initialize target through the grid API, inject it into the rig, gate marker visibility, update startup log.
- `scenes/ui/development_screen.tscn`: update Phase 0.3 footer.
- `tests/foundation_test.gd`: update the intentional camera default from 1x to 2x; add consecutive-frame image stability check. Other foundation assertions are preserved.
- `tests/validate.ps1`: run camera tests and identify Phase 0.3; retain world and existing startup checks.
- `AGENTS.md`: append current authorized scope, preserving prior instructions.
- `README.md`, `docs/architecture.md`: current camera architecture, close-view expectations, APIs and run instructions.

The world implementation, world tests, terrain fixture, official Art Bible/JSON, project configuration, input bindings, asset pipeline, and existing scene ownership remain unchanged. Earlier phase reports are historical records.

## Actual validation

Ran `./tests/validate.ps1 -IncludeRendering` with the configured Godot 4.7.2 executable. As in prior phases, the editor needed certificate-store read access; all generated profile/log/PNG data remains under `tests/output/` inside the project. No movie writer, audio output asset, external dependency, or PixelLab operation was used.

| Check | Actual result |
| --- | --- |
| Headless editor import | Passed |
| All eleven GDScript check-only parses | Passed |
| Both existing JSON files | Valid syntax |
| Foundation headless integration | 176 checks passed |
| Existing isometric world suite | 33,961 checks passed |
| Player camera suite | 49 checks passed |
| Headless main startup | Passed |
| Graphical editor, OpenGL Compatibility | Passed |
| Graphical main/capture integration | 178 checks passed |
| Fullscreen startup | Passed |
| Native scene/production scan | Passed; no obsolete spatial architecture/audio nodes |

Camera tests cover initial activation/assignment/centering, actual Camera2D viewport centers, automatic follow after frame updates, valid target replacement, offsets, render snapping without target mutation, integer canvas translation, null/queued/freed targets, zoom configuration and finite validation, runtime limit edits, activation/deactivation, missing initial target, bounds at multiple zooms, undersized axes, invalid bounds, another camera's ownership, grid-derived Main target placement, original map dimensions, isometric target movement, and unchanged terrain data. Test targets are freed; no movement mechanism was added to runtime scenes.

The PNG at `tests/output/foundation.png` was visually inspected at 960 x 540: the cross is centered, the lunar terrain is visible at a crisp 2x scale, and labels are readable. Two consecutive stationary rendered frames are byte-identical, providing an automated short static-flicker regression check. This is not an exhaustive long-duration or multi-display motion certification.

Final errors: **0**. Final warnings: **0**. There are no unresolved test failures.

## Manual verification and limits

1. Open `project.godot` in Godot 4.7.2 and run F5 (or F6 on Main). Expect a turquoise cross at viewport center with enlarged lunar terrain and the Phase 0.3 footer.
2. Use the Remote scene inspector to change TemporaryPlayerTarget's position while running. The camera should follow without any keyboard movement system. For exact center comparisons, choose integer or half-pixel positions at 2x. Change CameraRig's `follow_offset` to inspect offset behavior.
3. Change CameraRig's `zoom_level` among 1, 2, 3, and 4. Pixel blocks should remain sharp; the logical viewport stays 960 x 540. Wheel and Tab must not zoom or switch modes.
4. Inspect optional bounds by enabling them and assigning a large world rectangle, then moving the remote target near its edges. Disable them to restore unrestricted follow. Small bounds should not incorrectly move the target off-center on undersized axes.
5. Set the development Resource's `enabled` false before running to hide debug visuals while retaining camera behavior. Restore it for further development if desired.
6. Reproduce automated checks with `./tests/validate.ps1 -IncludeRendering`. Current logs and PNG are in ignored `tests/output/`.

No runtime rebinding, player movement, character art/animation, management controls, mode switching, survival, construction, inventory, missions, companions, Mars, audio, or multiplayer was added. Release export and arbitrary DPI/monitor combinations were not tested. Future target interpolation and animated sprite presentation need their own motion QA. Phase 0.4 needs explicit assignment and must own switching policy without putting world state into either camera.
