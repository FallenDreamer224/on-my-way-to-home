# Phase 0.5 - Astronaut movement and animation foundation

Phase 0.5 is complete and validated in **Godot 4.7.2.stable.official.ed1daf0bf**. The astronaut is directly controllable using keyboard input. Phase 0.6 has not started.

## Inspection and preserved contracts

Read AGENTS, the official Art Bible/standards JSON, Phase 0.4 report, camera/mode implementations, InputMap, temporary target, world/grid code, and existing tests. Preserved the 960 x 540 viewport, nearest filtering, native 2D architecture, 64 x 32 TileMapLayer/TileSet configuration, 12 x 12 lunar terrain, camera APIs, independent management state, and original InputMap. The locked art standards are unchanged. No PixelLab calls, credits, third-party assets, final artwork, audio, plugins, or commits were used.

## Player architecture

```text
Main
  Systems / GameplayModes (existing coordinator)
  World
    Terrain / Ground (unchanged terrain implementation)
    Entities / Players
      Astronaut (CharacterBody2D; root is ground/foot position)
        AnimatedSprite2D (AstronautAnimation)
        CollisionShape2D (RectangleShape2D, 10 x 6)
  CameraRig (existing player rig; follows Astronaut)
  BaseManagementCameraRig (existing independent rig)
  UI / DevelopmentScreen (existing mode indicator)
```

The astronaut is a reusable scene under the pre-existing Players attachment point. Its controller owns velocity, configurable speed, last facing, physical movement and animation requests. It does not own camera implementation, gameplay-mode state, inventory, survival, tutorial state, companions, or world generation. Main configures terrain access, spawns with `IsometricGrid.tile_to_world(Vector2i.ZERO, ground)`, assigns the actor through the unchanged camera follow-target interface, and forwards mode policy through `set_control_enabled()`.

The old runtime TemporaryPlayerTarget node and its Main wiring are removed. Its unused drawing script remains as retired source; it is not instanced, followed, or used as a second simulated position. Regression tests now point to the real Node2D-compatible astronaut instead of the removed Marker2D while retaining their camera/mode assertions.

## Movement and facing

Movement runs in `_physics_process` through `CharacterBody2D.move_and_slide()`. Default `walk_speed` is **80 world pixels/second**, configurable in the scene or at runtime. Existing WASD and arrow actions combine into a vector capped at length one. Diagonals therefore have the same Euclidean speed as cardinal movement. Input operates in screen-aligned world X/Y, independent of logical grid axes; no isometric distance/speed correction, gravity, acceleration, sprinting, jumping, or equipment/fatigue modifiers were added. Future approved systems can supply an explicit effective walk speed or extend `movement_velocity()` without replacing the movement/collision path.

Released input sets velocity to zero on the next physics update, without acceleration tails. Facing updates from nonzero requested movement even when blocked at an edge, then persists during idle. A nearest 45-degree sector maps input to these clockwise names:

| Facing / clip suffix | Screen-space vector |
| --- | --- |
| North / `n` | `(0, -1)` |
| Northeast / `ne` | normalized `(1, -1)` |
| East / `e` | `(1, 0)` |
| Southeast / `se` | normalized `(1, 1)` |
| South / `s` | `(0, 1)` |
| Southwest / `sw` | normalized `(-1, 1)` |
| West / `w` | `(-1, 0)` |
| Northwest / `nw` | normalized `(-1, -1)` |

This uses the Art Bible's screen-facing convention and does not reinterpret grid column/row directions. Zoom and mode changes do not alter facing. There is no sprite flipping substitute for direction coverage.

## Animation and placeholder art

`AstronautAnimation` extends native AnimatedSprite2D. It selects `idle_<direction>` or `walk_<direction>` from SpriteFrames. Walking is selected from actual resulting displacement; release, management mode, or a blocked step selects idle with the last facing. Repeated requests for the same state/direction return immediately without restarting playback or building a new animation resource. Native `speed_scale` provides overall playback control, and SpriteFrames stores per-clip FPS, loop flags, frames and durations.

The development factory creates a shared SpriteFrames resource once per process, with **eight one-frame idle clips at 1 FPS** and **eight four-frame walk clips at 6 FPS**. Forty native **64 x 64 RGBA** frames are generated in memory, with transparent backgrounds, a **50-pixel visible height**, and fixed source foot anchor **`(32, 56)`**. Simple suit/helmet shapes, a direction mark and alternating boot lifts make facing/walking inspectable. These are temporary graphics rather than polished anatomical directional views. No PNG artwork is saved by the factory.

`art/placeholders/astronaut_placeholder.json` records source provenance, standards version, dimensions, visible height, anchor, collision footprint, direction mapping and all sixteen clips with actual counts/FPS/frame indices. Metadata was checked against the values exercised by the runtime tests. The animation selector supports unequal directional counts and different per-clip rates; a replacement fixture with five north-walk frames at 9 FPS and four south-walk frames passed. There is no assumed sheet row/column arrangement.

The actor root and collision remain continuous physics positions. After the camera's priority-100 update, the visual's priority-200 process snaps rendered feet through the current canvas transform to whole logical-screen pixels. The source anchor is then subtracted to place the top-left of the frame. No simulation/collision position is snapped, and no camera implementation reference is required. This complements the existing snapped camera and nearest filtering at 1x, 2x and 3x. Native-size sprite scale stays one; the camera follows the actual CharacterBody2D root, not the visual's render correction. Expected visual quantization is at most half a logical pixel per axis.

## Collision and terrain limits

The actor uses floating top-down CharacterBody2D motion, collision layer **1 (actor convention)**, mask **2 (future world-solid convention)** and safe margin 0.01. The centered **10 x 6 rectangle** is a foot-level physical footprint, independent of helmet, frame dimensions, animation direction and playback. No terrain obstacles, wall nodes, damage, advanced responses, or collision maps were invented for runtime.

`TerrainWalkability` reads the live TerrainLayer cell dictionary; existing terrain generation/rendering is unchanged. Every currently present regolith/dust cell is walkable, while absent cells are not. This supports negative coordinates, different region origins/sizes, sparse authored maps and holes without hardcoded 12 x 12 limits or a screen-space rectangular world clamp.

For a candidate foot rectangle, the helper enumerates the small logical-cell range overlapping its swept extent and checks missing diamonds with separating axes (screen X/Y and the diamond normals). It tests the entire rectangle, not only its center or four corners, so a missing diamond tip cannot enter between sampled corners. Swept contact limits the step before missing terrain; a 0.001-pixel contact clearance protects against roundoff. A simple screen-axis slide is attempted at blocked edges, then the final straight CharacterBody2D displacement is swept again so that slide calculations cannot cut through a concave edge or hole. Missing terrain cannot be jumped merely because the endpoint is valid. Actual physics movement still goes through `move_and_slide()`.

The helper fails closed for missing terrain, invalid inputs, invalid starting positions, or rotated/scaled world transforms. Established world/actor transforms must remain unscaled and unrotated; translated terrain is supported. Invalid positions are not teleported back into the map. Main's current grid-cell-zero spawn is verified with the full footprint. A future map must provide a valid spawn and its own walkable cell set. Obstacles or different walkability rules should extend that data/provider contract in an approved phase, not add map-specific dimensions to the actor.

## Modes, held keys, cameras and sorting

Main subscribes to the existing coordinator. On management entry it disables astronaut controls synchronously, sets velocity to zero, and requests idle while retaining facing and world position. WASD/arrows continue to pan management only. The astronaut remains instanced, visible, and physically present; it is neither hidden nor recreated. Player reentry preserves position and immediately reacquires the real actor through the existing player camera.

If movement keys are held at reentry, all must be released before player walking resumes. Opposing keys that cancel the input vector still count as held. When reentry occurs with neutral keys, a fresh press works on the first physics tick. Focused UI also stops input and requires neutral release after held input. This prevents stale management panning keys or typed input from unexpectedly moving the astronaut.

The actor stays under the existing Y-sorted Players/Entities roots at equal entity Z. Its own Y-sort is disabled, making the art one entity ordered by the root foot point. Terrain remains at Z -10. No global sorter, occlusion manager, transparent buildings, extra camera, or mode coordinator was added. Management zoom/position persistence and the same-world identity tests still pass.

## Future PixelLab replacement procedure

1. Obtain explicit authorization before any PixelLab generation or credit use. Read the Art Bible and standards JSON; preserve provider metadata, license/usage terms, actual direction order and per-clip counts/FPS. There are no generation calls in this phase.
2. Import approved transparent PNGs into `assets/characters/` using lossless compression, no mipmaps, no rescaling, and nearest filtering. Inspect actual frame dimensions and alpha padding. Do not silently resize, crop, stretch or trim frames; report incompatible assets and obtain a decision.
3. Create an external SpriteFrames resource (for example under `resources/player/` when needed). Use explicit AtlasTexture regions or Godot's sheet-frame editor based on actual provider layout. Define all `idle_n/ne/e/se/s/sw/w/nw` and `walk_n/ne/e/se/s/sw/w/nw` clips. Validate each clip's actual frame count, region bounds, positive FPS, loop flag, and frame dimensions. Extra future animations may coexist but no new behaviors are implemented now.
4. Ensure all standard human frames are 64 x 64 and share the measured foot anchor/baseline across every direction and state. The placeholder anchor is `(32, 56)`; set `foot_anchor` to the documented source anchor for approved replacement art. Larger frames require the Art Bible's documented use/exception process. Canvas size does not define physical collision size.
5. Assign the reviewed SpriteFrames to Astronaut/AnimatedSprite2D **before starting the scene** and set per-clip FPS and optional native `speed_scale`. The procedural factory runs only when SpriteFrames is absent. No movement or camera code needs rewriting; this phase does not implement hot-reload tooling or a universal sheet importer. A missing requested clip produces an explicit integration error rather than fabricated replacement artwork.
6. Run all tests and inspect feet, directional changes, edge stops and camera modes. The procedural metadata tests describe the default placeholder; adapt those asset-specific expectations deliberately when integrating approved final art. Keep movement, mode, collision and terrain contract tests.

## Files created or modified

Created:

- `scenes/player/astronaut.tscn`
- `scripts/player/astronaut.gd`
- `scripts/player/astronaut_animation.gd`
- `scripts/player/astronaut_directions.gd`
- `scripts/player/astronaut_placeholder.gd`
- `scripts/world/terrain_walkability.gd`
- `art/placeholders/astronaut_placeholder.json`
- `tests/astronaut_test.gd`
- `docs/phase_0_5_report.md`
- Godot-generated `.gd.uid` sidecars for the five new runtime scripts and new test.

Modified:

- `scenes/world/world.tscn`: instance the astronaut under existing Players; terrain nodes/configuration unchanged.
- `scenes/main.tscn`: retire the temporary marker node and its script reference.
- `scripts/core/main.gd`: grid spawn, terrain/control injection, actual actor camera target, mode handoff and player movement hint.
- `scenes/ui/development_screen.tscn`: player walking hint; existing mode display preserved.
- `tests/player_camera_test.gd`, `tests/gameplay_modes_test.gd`: replace obsolete marker paths/types with the actual Node2D astronaut; original regression assertions retained.
- `tests/validate.ps1`: add astronaut physics/graphical tests and placeholder JSON validation, retain prior suites and fullscreen checks.
- `AGENTS.md`, `README.md`, `docs/architecture.md`, `docs/input_bindings.md`, `scenes/player/README.md`: current scope, controls, architecture, art replacement and phase boundary.

Project settings, InputMap, locked art standards, camera implementations, mode coordinator, terrain scripts/data/TileSet, and previous reports remain unchanged. The retired marker drawing script is unused but preserved. Ignored editor cache, isolated profile, logs and test PNGs are local validation artifacts.

## Actual validation results

Executed `./tests/validate.ps1 -IncludeRendering` using Godot **4.7.2.stable.official.ed1daf0bf**. Profiles/logs/PNGs remain within `tests/output/`; editor certificate-store access was allowed as in prior phases. All initial harness failures (partial-physics-tick timing and an invalid near-edge fixture) were corrected and rerun; no failed assertion was skipped. Physics meters explicitly run after actor updates, flush simulated events, count complete ticks and restore the original physics rate.

| Check | Final result |
| --- | --- |
| Headless editor import | Passed |
| All 21 GDScript check-only parses | Passed |
| Standards/intake/placeholder JSON | Valid syntax; placeholder metadata consistent with tested dimensions, anchors, height, counts and FPS |
| Foundation integration | 211 headless checks; 213 graphical checks passed |
| Existing world suite | 33,961 checks passed |
| Existing player camera suite | 49 checks passed |
| Mode regression | 93 headless, 99 graphical, 93 fullscreen checks passed |
| Astronaut suite | **234 headless checks passed** |
| Graphical astronaut suite | **244 checks passed**, including ten PNG captures |
| Main headless/editor/fullscreen startup | Passed |
| Production architecture/native hierarchy | No obsolete spatial architecture or audio nodes |

Astronaut checks cover reusable initialization, valid full-foot spawn, collision configuration, 16 clips and all 40 frames, transparency/height/baseline, all cardinal/diagonal inputs, facing, equal speed, walk/idle selection, no restart, different replacement counts/FPS, 30/60/120 Hz physics measurements, configurable speed, release/no drift, canvas foot alignment, actual camera follow, full-foot edge stops/retreat, sparse holes/tunneling, a different region origin/size, a final swept-physics-path safety check, management input gating and panning, immediate idle, location preservation, held-key protection, fresh-key first-tick response, UI focus and unchanged terrain data.

The graphical suite dispatches Godot input events in the running renderer and captures all eight facing/walk states, idle, and management view. Physical player movement is briefly frozen **only in the test** while taking each walking snapshot so the released-input idle update cannot replace the intended walking evidence; runtime scenes contain no test movement/freeze mechanism. Screenshots were inspected for visible native-size astronaut art, sharp 2x pixels, consistent feet, lunar tile alignment and management coexistence. No physical keyboard/mouse session is claimed: this is automated input simulation plus visual inspection.

Current evidence under `tests/output/`: `foundation.png`, `astronaut_idle.png`, `astronaut_walk_n/ne/e/se/s/sw/w/nw.png`, `astronaut_management.png`, and retained camera-mode captures. No movie/audio recording was used.

Final errors: **0**. Final warnings: **0**. No unresolved test failures remain.

## Manual test procedure

1. Open `project.godot` in Godot 4.7.2; press F5 or F6 on Main. Expect the astronaut at grid `(0, 0)` with feet at the camera center and body extending above it.
2. Walk with WASD/arrows and combinations. Confirm all eight facing marks, walking boot motion, consistent diagonal speed, immediate idle on release and persistent facing. The camera should follow the actual body at 2x.
3. Walk toward each lunar edge. The entire foot rectangle must stop on terrain; the character must not snap between cells or teleport back from outside. Change direction inward to leave an edge.
4. Hold a movement key and press Tab. Confirm the astronaut stops and idles, while management pans. Change management zoom with the wheel. Return with Tab while still holding the key: the astronaut should remain still until release, then accept a fresh press. Repeat a switch with neutral keys and confirm the next fresh press responds immediately.
5. Confirm management position/zoom and astronaut position persist across switches. Use fullscreen/resize to inspect the established integer presentation rules. No inventory, health, companions, construction, audio, or other gameplay should appear.
6. Inspect `walk_speed`, the centered foot collision shape, SpriteFrames FPS/`speed_scale`, and foot anchor in the scene. Disable only development UI via its existing Resource if desired; the astronaut remains present.
7. Run `./tests/validate.ps1 -IncludeRendering` in PowerShell 7 to reproduce automated validation and captures.

## Limits and Phase 0.6 recommendations

This is a lightweight walking/animation foundation, not final astronaut art or a complete collision/navigation world. The current terrain has no physical obstacles; all present terrain kinds are walkable, with missing cells excluded. Native solid-world collision compatibility is prepared but final environment collision authoring, multiple interacting colliders at terrain edges, ramps/elevation, navigation and pathfinding need their own approved design and regression tests. Keep actor/world transforms unscaled/unrotated; set a valid spawn for any new map. Fail-closed terrain checks do not rescue an externally teleported invalid actor.

No fatigue/gravity/equipment speed formulas, jump/sprint, companions, combat, inventory, collection, construction, survival, emotional state, missions, Mars, multiplayer, audio or final assets were added. Release exports, long-duration movement and every monitor/DPI configuration were not certified. Placeholder direction marks are functional, not polished eight-view astronaut anatomy. Future animation assets should receive motion/anchor QA before use.

Phase 0.6 should be assigned explicitly. Preserve movement/mode ownership, the shared world and native grid adapters; replace art through SpriteFrames and explicit provenance, then add only the next requested gameplay component. No Phase 0.6 work is included here.
