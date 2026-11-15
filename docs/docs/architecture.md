# Foundation architecture

## Scene composition

```text
Main (Node; scripts/core/main.gd)
  Systems (Node)
    GameplayModes (GameplayModeCoordinator)
    PlayerSession (inventory modal/input policy)
  World (instance: scenes/world/world.tscn)
    Terrain (Node2D; z_index = -10)
      Ground (instance: terrain_layer.tscn; TerrainLayer/TileMapLayer)
    Entities (Node2D; Y-sorting enabled)
      Players (Node2D; Y-sorting enabled)
        Astronaut (CharacterBody2D; foot/root position)
          AnimatedSprite2D (AstronautAnimation)
          CollisionShape2D (10 x 6 foot rectangle)
          Inventory (RuntimeInventory; data only)
          InteractionDetector (Area2D; mask 8)
      NPCs (Node2D; Y-sorting enabled)
        Chiwis (CharacterBody2D; foot/root position)
          AnimatedSprite2D (shared AstronautAnimation)
          CollisionShape2D (8 x 4 foot rectangle)
      Buildings (Node2D; Y-sorting enabled)
      Props (Node2D; Y-sorting enabled)
  CameraRig (instance: scenes/camera/camera_rig.tscn)
    Camera2D
  BaseManagementCameraRig (independent overview rig)
    Camera2D (inactive at startup)
  UI (GameUI scene; CanvasLayer, layer = 10)
    GameHUD (passive full-viewport Control)
      TopBar (identity, active mode, camera hint, expansion slot)
      StatusPanel (six reserved labels)
      Notifications (informational message + one-shot timer)
      BottomBar (inventory/mode hints)
    InteractionPrompt (contextual text)
    InventoryWindow (modal inventory display)
```

World, Terrain, and entity containers retain identity transforms. Ground retains its `(-32, -16)` alignment. Main places Astronaut at the native world center of cell `(0, 0)`, injects terrain walkability, and assigns it to the existing camera rig at 2x. Chiwis starts at cell `(0, 1)` and receives the same terrain and astronaut target. The temporary Marker2D is retired from runtime; its unused drawing script remains historical source. Main forwards mode policy to the actors' independent control/follow interfaces; actors do not own mode state. Terrain initializes exactly as before.

Players, NPCs, buildings, and props have separate organizational roots. Each root participates in Y-sorting so future entity roots can interleave across categories. Keep their position at `(0, 0)`, scale at `(1, 1)`, and `z_index` at zero. Actor scene roots should own the ground/foot point and normally leave their own Y-sorting disabled so internal art draws as one entity. See the isometric standards before adding tall objects or multiple terrain layers.

## Ownership boundaries

Phase 0.8A adds a presentation-only `PropAppearance` Resource (texture and measured ground anchor) and reusable `WorldProp` scene. WorldPickup resolves three stable item IDs to appearance resources without modifying shared ItemDefinitions. Its Visual child renders the full native canvas with a negative Sprite2D anchor offset; interaction roots, shapes and quantities remain independent. Ten appearances live in `resources/props/`; `scenes/development/prop_gallery.tscn` previews the complete pack without changing production placement. See `art/imports/phase_0_8A.json` for the mapping and `docs/phase_0_8A_report.md` for validation.

| Domain | Scene location | Future script location | Responsibility / integration point |
| --- | --- | --- | --- |
| Core | `scenes/main.tscn` | `scripts/core/` | Scene composition, lifecycle, configuration |
| World | `scenes/world/` | `scripts/world/` | TileMapLayer terrain, map metadata; `World/Terrain` |
| Player | `scenes/player/` | `scripts/player/` | Reusable player entity; `World/Entities/Players` |
| NPC | `scenes/npcs/` | `scripts/npcs/` | Reusable NPC entity; `World/Entities/NPCs` |
| Companion | `scenes/companions/` | `scripts/companions/` | Chiwis autonomous movement and terrain route planner; shared NPC attachment root |
| Camera | `scenes/camera/` | `scripts/camera/` | Camera tracking and limits; `Main/CameraRig` |
| Gameplay | `scenes/gameplay/` | `scripts/gameplay/` | Exploration/base modes, placement, interactions; `Main/Systems` |
| UI | `scenes/ui/` | `scripts/ui/` | HUD, menus, feedback; `Main/UI` |
| Persistence | Add when implemented | `scripts/core/` initially | Future save/load service; `Main/Systems` |

Only directories with actual files or immediate scene contracts exist. The scene contracts reserve player/NPC/gameplay ownership without dummy controllers or empty scripts. Add domain scripts and data resources as their first behavior is implemented.

## Extension rules

- Instance reusable scenes; keep Main responsible for wiring dependencies.
- Pass typed resources/references or use focused signals between systems. Do not introduce a global event bus or singleton until a concrete requirement needs one.
- Keep simulation state out of UI nodes. UI presents state and issues requests to future gameplay systems.
- Building placement will coordinate terrain coordinates and entity roots; it must not store state in the camera or UI.
- Save/load will serialize explicit future game-state data rather than the entire live scene tree. No save files are read or written now.
- Keep development options in `DevelopmentSettings`. Add typed exported fields when a real development feature needs them.
- Future subsystem scenes should be independently instantiable and have a small testable interface. Foundation checks run with Godot alone.

## Pixel presentation

The entire scene is native 2D. The logical viewport remains 960 x 540 with integer viewport scaling and letterboxing. PlayerCameraRig defaults to integer 2x zoom with smoothing disabled. Its render center is snapped to `round(center * zoom) / zoom`. Both actor visuals separately snap rendered feet through the current canvas transform after camera updates (priority 200), without changing body positions or colliders. Keep world/actor/rig transforms at unit scale and zero rotation. CharacterArtProfile stores SpriteFrames and measured per-frame source anchors; the shared animation adapter subtracts the current anchor as a visual offset. The retained placeholder uses `(32, 56)`; the real art uses the audited anchors in `art/imports/pixelorama_characters.json`. Do not add competing snapping/interpolation without motion QA. Built-in placeholder UI text is not production pixel-art typography.

## Shared state and future subsystem boundaries

Player Mode and Base Management Mode operate on the same world instance. GameplayModeCoordinator initializes in PLAYER, routes Tab and management pan/zoom, and emits typed mode_changed notifications. It selects the prepared incoming camera before disabling the outgoing one. PlayerCameraRig retains Phase 0.3 behavior. Management owns continuous pan_position and zoom independently; CameraFraming shares pixel alignment and optional bounds policy. No world is reloaded or duplicated. Future actors use CharacterBody2D and AnimatedSprite2D; terrain uses TileMapLayer, cameras use Camera2D, and UI uses CanvasLayer.

Use stable IDs and data definitions for items, resources, structures, companion identities, tutorial/mission steps, and future survival parameters. Runtime quantities and progression belong to explicit state objects, not UI widgets, sprite frames, or camera nodes. Author static definitions as Resources when useful; keep serializable dynamic state separate. Inject references from Main; use typed APIs and focused signals. No autoload is needed now. Save/load will version that explicit state and reference definitions by stable ID rather than serialize rendering nodes.

`scripts/gameplay/README.md` assigns future subsystem ownership without empty script stubs. `resources/data/README.md` defines data/persistence responsibilities. Companion scenes live separately under `scenes/companions/`; the existing NPC container is a generic nonplayer-entity attachment point and does not imply human colonists. Chiwis is implemented; T remains deferred.

Coding conventions: typed GDScript where practical; snake_case files/functions/variables, PascalCase class/node names, one focused responsibility per component, English comments explaining intent, and reusable scenes rather than duplicated node trees. Configuration belongs in typed Resources or Project Settings. Add domain subdirectories only when their first implementation/data file needs them; prefer small integration checks for cross-component contracts. Keep audio and multiplayer out of this phase.

## Phase 0.2 terrain boundaries

TerrainRegion contains logical region origin/size and optional authored cell-kind data. It can create the deterministic lunar test fixture independently of a scene. TerrainLayer duplicates authored data or builds that fixture, then projects each kind into native TileMapLayer cells. Configuration resources remain unchanged during initialization. This is terrain data/render separation, not a complete persistent-world or save system.

PlaceholderTerrain creates four temporary native-size textures and a TileSet. TerrainLayer can accept four approved replacement Texture2Ds in the same stable kind order. IsometricGrid owns pure conceptual math and thin native layer-conversion wrappers; terrain picking always uses native methods. No terrain node processes per frame, no node is allocated per tile, and no camera dependency enters region or renderer code.

Add ground/decorative layers as sibling terrain scene instances sharing the grid basis; decide explicit data/Z ownership before integration. Tall entities remain in the existing Y-sort hierarchy by ground-contact anchor. Elevation, obstacles, buildings, interactions, navigation, region loading, and persistence are future systems, not TileMap metadata guessed during this phase.

## Phase 0.5 actor boundary

Astronaut owns physics velocity, configurable walk speed, facing and animation selection. AstronautAnimation owns SpriteFrames playback/render alignment; AstronautPlaceholder creates immutable shared temporary frames once. TerrainWalkability reads the live cell set and sweeps the complete axis-aligned foot rectangle against missing cell diamonds, so holes and nonrectangular extents are respected without obstacle nodes or hardcoded map dimensions. Ground/terrain scripts remain unchanged.

Mode changes disable/idle the astronaut immediately. Reentry requires neutral movement keys only when keys were held across the transition; fresh presses after a neutral transition work immediately. UI focus also blocks input. Physical updates precede the existing idle camera follow; the visual follows the canvas afterward. No player code depends on camera implementation, inventory, survival, companions, or world generation.

## Phase 0.6 companion and art boundary

The astronaut controller is preserved. Its visual now loads real SpriteFrames through CharacterArtProfile; the same small animation adapter is reused by Chiwis. Artwork and frame offsets never determine body speed, terrain data or collision dimensions. The import pipeline uses the installed Pixelorama resource pack, read-only originals, temporary nonguide working copies and exact RGBA comparison before producing resources. Runtime needs only project-local assets.

Chiwis owns three states (IDLE, FOLLOWING, WAITING), configurable distance hysteresis and physics walking. Main injects target, terrain and mode permission. TerrainRoutePlanner first tests a swept direct connector, then a bounded four-neighbor BFS over existing cells using the same full-foot walkability service as the player. Every actual physics step is swept again. A stationary unreachable target is retried on a timer; no teleport, world edits or per-tile physics nodes are used. This is a terrain-only solution; authored obstacles, advanced navigation, companion commands and persistence remain future work.

Both actors use collision layer 1 and mask 2, so they do not push each other. Management pauses and idles Chiwis immediately, retaining its position, facing and follow intent; returning to player mode resumes autonomous following without replacement instances. Camera implementations and GameplayModeCoordinator remain unchanged. See `phase_0_6_report.md` for validation and limitations.

## Phase 0.7 interaction and inventory boundary

Phase 0.7B subsequently adds eight run clips and matching per-frame anchors to each real character profile. The existing generic AstronautAnimation adapter already selects `state_direction` and therefore needs no source-code change. Import resources are merged additively; all legacy idle/walk clip semantics are fingerprinted and verified. Production controllers, speeds, input and companion policy remain unchanged. Run playback/ground-anchor previews live only in `tests/run_animation_test.gd`. Sprint remains deferred; see `phase_0_7B_report.md`.

Phase 0.7A subsequently replaces only ground presentation: Ground's `terrain_art` references a reusable native Moon TileSet with four existing kind/source IDs and three atlas variants per kind. Stable cell hashing selects atlas coordinates without touching region data or gameplay RNG. Nonempty four-texture overrides still use the legacy replacement path, and unconfigured layers retain their procedural fallback. The 64 x 32 grid, layer offset, walkability and future sibling-overlay contract remain intact. See `phase_0_7A_report.md`; earlier placeholder descriptions are historical.

Main configures the astronaut's RuntimeInventory and InteractionDetector children, UI references and PlayerSession. Existing movement/animation and companion controllers remain unchanged. ItemDefinition Resources contain shared authored IDs, names, descriptions, stack policy, optional icons and tags; slot dictionaries belong only to RuntimeInventory and are exposed as defensive snapshots. UI updates on successful transaction signals and reuses its slot controls. No autoload, global registry, per-frame UI rebuild or disk storage is introduced.

Nonblocking WorldPickup nodes attach to the existing Y-sorted Props root. Their Area2D interaction components use layer 8 (bit 4), mask 0; the astronaut's sensor uses layer 0, mask 8. Actor/obstacle collision stays layer 1/mask 2. Native enter/exit signals maintain candidates. Selection tests world distance, availability and a swept full-foot terrain connector, then breaks equal-distance ties by stable ID/path. Execution revalidates before collecting. Partial acceptance leaves the exact remainder; full collection queues the original node for deletion. Mode changes never reconstruct inventory or pickups.

PlayerSession opens inventory only in Player Mode, disables astronaut movement/interaction through existing interfaces, and sets the mode coordinator's small modal guard. Keyboard/mouse UI operates while world/Chiwis simulation continues. Closing releases focus and restores safe input. Management disables interaction and preserves data. The mode coordinator gains only modal rejection checks; cameras remain unchanged. See `phase_0_7_report.md` for APIs/tests. Earlier phase sections describe historical boundaries.

## Phase 0.7C UI boundary

Phase 0.8 reuses and verifies this existing composition and the Phase 0.7 interaction/inventory APIs. Its acceptance scenario uses real E/I/Esc/Tab input, all three authored item types and the actual player inventory at full capacity. Inventory and partial pickup state stay in the same instances across camera modes; no new runtime manager or alternate inventory was added. See `phase_0_8_report.md` for the complete requirement mapping and current regression results.

`scenes/ui/game_ui.tscn` is the reusable CanvasLayer composition, preserving the existing `UI/InventoryWindow` and `UI/InteractionPrompt` attachment points. GameHUD owns mode/zoom/inventory hints, the passive status panel and the single notification slot. A shared Theme separates colors, spacing and button/panel styles from gameplay. Main injects references and forwards actor mode permission; presentation updates now live in UI scripts rather than Main's old combined footer.

Mode, camera zoom, inventory visibility, interaction target and collection signals update UI on demand. InputHint reads action labels on explicit refresh. GameUI.notify() displays bounded informational text with a one-shot expiry; collection feedback uses that same area. There is no global event bus, per-frame UI refresh or survival state model. The six status values remain literal empty markers. Passive HUD/prompt controls use mouse-ignore/no-focus; inventory retains its existing modal policy and a centered panel.

The gameplay HUD stays visible independently of development configuration. `show_development_screen` retains its stored name and now controls only the optional developer badge. The old DevelopmentScreen scene is retired from runtime and preserved as historical source. Future final art should replace Theme styles or widget visuals while retaining these ownership/input boundaries. See `phase_0_7C_report.md` for public APIs, reserved fields and validation.
