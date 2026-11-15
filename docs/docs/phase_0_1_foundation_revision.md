# Current Phase 0.1 foundation report

This report covers the updated Phase 0.1 request, following the original foundation and Phase 0.1A art lock. Phase 0.2 remains unimplemented.

## Inspection and decisions

- The executable configured by the existing VS Code setting reports **4.7.2.stable.official.ed1daf0bf**. The project already used GL Compatibility, native 2D scenes, nearest canvas texture filtering, English startup locale, and an assigned main scene. These choices are preserved.
- The original foundation used 640 x 360 logical pixels. The updated request proposes **960 x 540**; there is no implemented gameplay or final artwork requiring the smaller viewport, so this revision adopts 960 x 540 for logical, initial, and minimum window size. No art sizes change.
- Viewport stretch, preserved aspect ratio, integer scaling, and resizing remain enabled. Some default-valued settings are omitted when the editor saves; `keep` aspect and resizable windows remain effective engine defaults.
- `AGENTS.md`, the Art Bible, machine-readable standards, and asset-intake rules were inspected. Art standards version **1.0.0** remains unchanged. AGENTS retains its art instructions and now identifies the newly authorized foundation scope and Moon-first design context.
- `git rev-parse --show-toplevel` confirmed there is no Git repository here or in its parents. Existing `.gitignore` already excludes `.godot/`, `/android/`, and `/tests/output/`; it is preserved. No repository, history, or commits were created.
- Main/world/UI scenes already worked. The original static Camera2D rig is retained without follow, pan, zoom, or mode-controller behavior. No gameplay camera was implemented. Existing support directories and user files were preserved.

## Directory responsibilities

```text
project.godot             Display, locale, startup scene, configurable input actions
AGENTS.md                Project and mandatory asset-workflow instructions
scenes/
  main.tscn              Composition root
  world/                 Terrain/entity attachment points, no playable map
  player/                Future player contract
  npcs/                  Generic future nonplayer entity contract
  companions/            Chiwis/T contract
  camera/                Existing static Camera2D placeholder
  gameplay/              Future coordinator scene contract
  ui/                    Development screen on a CanvasLayer
scripts/
  core/                  Startup lifecycle and typed development settings
  gameplay/              Ownership map for deferred subsystems
resources/
  config/                Editable typed configuration
  data/                  Definition/state/persistence contract
art/                     Machine-readable art standards
assets/                  Characters, terrain, buildings, environment, UI
  pixellab/              Intake template, instructions, ignored raw-source staging
docs/                    Architecture, direction, controls, standards, reports
tests/                   Foundation checks and validation runner
  output/                Ignored logs, PNG capture, isolated editor profile
```

Do not create empty implementation directories for every future feature. `scripts/gameplay/README.md` explicitly assigns modes, interactions, inventory, resource management, construction, survival, tutorials/missions to future modules. `resources/data/README.md` separates static definitions from dynamic persistent state. Companion ownership is separate from generic NPC terminology; there are no human colonists. Scene/script/resource separation is retained without dummy classes.

## Confirmed standards and architecture

World projection is 2:1 diamond isometric, ground tiles are 64 x 32, and default human frames are 64 x 64 with recommended visible height 48-56 pixels. Use eight directions with explicit provider mapping, consistent feet, transparent padding, unit sprite scale, and nearest filtering. Inventory icons are 32 x 32. Buildings declare ground footprints independently of canvas dimensions. The Art Bible and JSON remain authoritative; dimensions, animation metadata, and documented exceptions must be reviewed before asset integration. No generation is authorized here.

The existing grid basis, centered origin, future Diamond Down TileSet/layer alignment, Y-sorting, and occlusion rules remain documented in `isometric_standards.md`. Future terrain uses TileMapLayer; player/actor visuals use CharacterBody2D and AnimatedSprite2D, cameras use Camera2D, and UI uses CanvasLayer. No grid helper, terrain, actor, or new camera behavior was implemented.

Player and Base Management modes will use the same persistent world state. Main composes dependencies; future mode controllers select input/camera/UI policy rather than own game state. Static data definitions use stable IDs; future save/load serializes versioned explicit state, separate from rendering nodes. There are no new autoloads. The approved Moon/Mars order, protagonist, robot companions, and unimplemented survival topics are recorded in `game_direction.md` without speculative formulas.

Fifteen distinct input actions are declared with physical-key/mouse defaults. They cover WASD movement, mouse interactions, Tab mode switching, arrow panning, wheel zoom, I inventory, and Escape pause. They have no behavior. `input_bindings.md` documents remapping and future UI/mode event handling.

## Changed files

Modified:

- `project.godot`: 960 x 540 logical/initial/minimum resolution; 15 input declarations. Renderer and main scene preserved. Godot normalized serialization of input events.
- `AGENTS.md`: preserve art rules; update current scope and approved design context.
- `README.md`: purpose, Moon-first context, standards links, layout, display limits, run/validation/manual checks.
- `docs/architecture.md`: shared state, mode separation, data ownership, coding conventions, updated viewport.
- `docs/phase_0_1_validation.md`: mark the initial results as historical and link this report.
- `tests/foundation_test.gd`: updated viewport expectations; named input/default/uniqueness checks; no-audio-node checks; optional PNG-only capture.
- `tests/validate.ps1`: validate both JSON files; dummy audio backend for validation; replace movie capture with PNG-only scene capture; fullscreen startup check.

Created:

- `docs/game_direction.md`
- `docs/input_bindings.md`
- `docs/phase_0_1_foundation_revision.md`
- `scripts/gameplay/README.md`
- `scenes/companions/README.md`
- `resources/data/README.md`

The existing Art Bible, asset JSON, isometric standards, scenes, production scripts, development Resource, icon, editor setting, and ignore rules remain unchanged. Godot updates its ignored cache/profile/log files during validation.

## Validation

The reproducible command is `./tests/validate.ps1 -IncludeRendering` in PowerShell 7, using the existing executable setting or explicit `-GodotPath`.

| Check | Result |
| --- | --- |
| Executable | Godot 4.7.2 stable official verified |
| JSON | Both standards JSON and PixelLab intake template parse successfully |
| Headless editor import | Passed |
| Syntax | Both production scripts and the test script passed check-only parsing |
| Integration | 167 headless checks passed |
| Input configuration | All 15 actions present; expected physical keys/buttons; one default binding each; no custom binding duplicates |
| Headless main scene | Startup and normal exit passed |
| Graphical editor | OpenGL Compatibility initialization and normal exit passed |
| Graphical main | 168 checks passed, including PNG capture of the instantiated main scene |
| Fullscreen main | Startup and normal exit passed |
| Visual inspection | 960 x 540 capture: centered, readable development card with no clipping |
| Production architecture scan | No obsolete spatial node/type/renderer/physics references |
| Scene hierarchy | Native 2D; no audio nodes |

Errors: **0**. Warnings: **0** in the final validation run. Logs and the current capture are in `tests/output/`; the capture is `foundation.png`. Validation profiles and logs remain inside the project. The environment requires certificate-store read access for Godot editor initialization; successful automated validation uses that access. No plugins or dependencies were installed.

No new audio files are produced. An ignored `tests/output/foundation.wav` from the earlier movie-based validation already existed before this revision and was preserved as an existing file; it is not a runtime asset or part of the scene. The new workflow never uses movie/audio recording.

## Manual testing and limitations

1. Open `project.godot` in Godot 4.7.2; run F5. Confirm the development screen appears. F6 also works with `scenes/main.tscn` open.
2. Use a standalone game window to resize it. Confirm the card stays centered and pixels stay uniformly scaled. Intermediate sizes deliberately have borders. At 1920 x 1080, content can fill the display at 2x; smaller displays than the 960 x 540 minimum are not supported initially.
3. Launch Godot with `--path <project-directory> --fullscreen` to check fullscreen presentation on the target display. Close normally with Alt+F4 on Windows. There is no in-game fullscreen toggle yet.
4. Inspect Project Settings > Input Map. Confirm all controls can be edited. They intentionally do nothing in this phase; built-in UI actions remain unchanged.
5. Run the validation command above after future changes. Errors fail validation even if the engine exit code is zero.

Arbitrary resize dimensions and display/DPI combinations still require manual visual checks on target hardware. No release export, runtime rebinding menu, localization, gamepad mapping, or final pixel font is included. No playable terrain, movement, camera switching, inventory, resources, construction, Chiwis/T behavior, survival, missions, audio, multiplayer, artwork generation, or PixelLab credit use was added.

## Phase 0.2 considerations only

Start with a small Moon test map and verify TileSet basis/origin, negative-coordinate picking, grid/world separation, actor foot placement, Y-sort interleaving, and multi-tile footprints. Keep state independent from views. Decide motion/pixel snapping with actual moving placeholders before selecting camera behavior. Respect the Art Bible for future authorized assets, including per-direction animation counts. Phase 0.2 must be assigned separately; no work on it is included here.
