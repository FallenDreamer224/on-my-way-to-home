# Phase 0.6 - Pixelorama Character Integration and Chiwis

Implemented for **Godot 4.7.2.stable.official.ed1daf0bf**, native 2D, GDScript. The real supplied astronaut and Chiwis artwork replaces runtime placeholders. Chiwis follows with distance hysteresis, full-foot terrain safety and lightweight routing. The Phase 0.5 astronaut controller, terrain, cameras, mode coordinator, InputMap, 960 x 540 viewport and locked art standards remain unchanged. No Phase 0.7 work, artwork generation, PixelLab requests, credit use or audio was added.

## Source inventory and audit

The authorized external `characters/` and `animations/` folders contain **18 PXO v8 ZIP projects**, all **64 x 64 RGBA**. The manifest is [pixelorama_characters.json](../art/imports/pixelorama_characters.json). It records relative source names, SHA-256, original layers/visibility, canvas, frame counts, duration units/seconds, rendered bounds, alpha, original frame indices, measured anchors and exact exported pixel hashes. No personal source paths or credentials are stored.

`characters/astronaut.pxo` and `characters/chiwis.pxo` each contain eight directional reference poses. They were inspected but excluded from runtime walking/idle imports. Their stored rates are 3.5 and 6 FPS respectively; those reference-sheet rates are not used for gameplay. No dedicated idle animations exist in this supplied set.

| Direction | Astronaut source under animations/ | Frames / FPS | Chiwis source under animations/ | Frames / FPS |
| --- | --- | --- | --- | --- |
| N | astronaut_walk_north.pxo | 7 / 6 | chiwis_walk_north.pxo | 4 / 6 |
| NE | astronaut_walk_north_east.pxo | 7 / 6 | chiwi_walk_north_east.pxo | 4 / 6 |
| E | astronaut_walk_east.pxo | 7 / 6 | chiwi_walk_east.pxo | 4 / 6 |
| SE | astronaut_walk_south_east.pxo | 7 / 3.4 | chiwis_walk_south_east.pxo | 4 / 6 |
| S | astronaut_walk_south.pxo | 7 / 6 | chiwis_walk_south.pxo | 4 / 6 |
| SW | astronaut_walk_south_west.pxo | 7 / 6 | chiwi_walk_south_west.pxo | 4 / 6 |
| W | astronaut_walk_west.pxo | 7 / 3.9 | chiwis_walk_west.pxo | 4 / 6 |
| NW | astronaut_walk_north_west.pxo | 7 / 6 | chiwis_walk_north_west.pxo | 4 / 6 |

These are individually verified counts for the current source snapshot, not a uniform-count assumption. The sixteen animation projects contain **88 completed rendered frames** (56 astronaut, 32 Chiwis). All animation frames have existing generated-cel provenance, nonempty nonguide pixels and transparent padding. Content and orientation were reviewed in contact sheets; provenance alone is not treated as proof of artistic completeness. There are no separate reference-only or empty frames in the current animation projects. Their `reference_images` arrays are empty. The two character reference projects are the excluded references.

All current frame duration multipliers are 1.0. Playback therefore uses 1/6 second for most frames, 1/3.4 second for astronaut SE and 1/3.9 second for astronaut W. Durations and per-direction FPS are preserved, including the visibly slower SE/W clips. Future files must be reinspected rather than coerced to these counts/speeds.

Sources include visible **Skeleton** guide layers, empty layers and multiple visible generation layers. Skeleton guides are always excluded, even when visible in the original. Other visible normal layers are composited in original order, including artwork split across generation layers. No source file was renamed, moved, deleted or rewritten. All **18 original SHA-256 hashes matched** after export and verification.

## Export procedure

Pixelorama **1.2.4-stable** is installed under `%APPDATA%/Orama Interactive/Pixelorama/`. CLI option behavior was checked against its help output and the [official Pixelorama CLI manual](https://pixelorama.org/user_manual/cli/). The installed executable did not reliably complete the bounded automated probes in this environment. Running its installed `Pixelorama.pck` through the already configured Godot 4.7.2 executable successfully performed all sixteen exports; no additional dependency was installed.

Use PowerShell 7 from the project root:

```powershell
.\tools\pixelorama\build_imports.ps1
# Explicit locations when defaults differ:
.\tools\pixelorama\build_imports.ps1 -SourceRoot 'C:\path\to\assets' -PixeloramaPack 'C:\path\to\Pixelorama.pck' -GodotPath 'C:\path\to\Godot_v4.7.2-stable_win64.exe'
# Reverify existing PNGs and regenerate resources, without exporting again:
.\tools\pixelorama\build_imports.ps1 -SkipExport -SourceRoot 'C:\path\to\assets'
```

The wrapper performs these steps:

1. Read and hash all 18 external originals. Discover actual `chiwi`/`chiwis` filenames and map long direction names explicitly.
2. Create animation working copies under ignored `tests/output/pixelorama_export/`. Change only Skeleton visibility in those copies. External originals stay read-only.
3. Invoke Pixelorama's CLI using the installed resource pack, `--export --spritesheet --scale 1 --direction 0 --frames 1-N`, an absolute project-local PNG path and bounded process lifetime. Store per-file console logs and tool diagnostics; unknown errors fail the pipeline.
4. Import project PNGs. Preserve lossless compression, no mipmaps, no size limit/rescaling, no alpha premultiplication and `fix_alpha_border=false`. The last setting prevents the importer from changing transparent-edge RGB values; nearest filtering remains the established scene/project policy.
5. Independently reconstruct every original nonguide frame from its raw RGBA cels and offsets. Reject unsupported composition, empty frames, changed source hashes, wrong sheet dimensions or any pixel/order mismatch. This validates all exported RGBA bytes, including alpha, against the original artwork.
6. Build native SpriteFrames and CharacterArtProfile resources, update the verified manifest, and write contact sheets. Recheck original hashes. Successful export alone is not accepted as completed integration.

`inspect_pxo.gd` provides separate read-only inventory/contact output when needed; it accepts `-- --source-root <directory>`. Source inspection supports the current v8 RGBA normal-layer, full-opacity, no-effects projects. Other formats/blends/effects must receive explicit compatibility work rather than approximate conversion. Manual fallback, if the installed pack becomes unavailable: open a source copy in Pixelorama, hide Skeleton, select completed nonguide animation frames in original order, export a horizontal native 64 x 64 PNG sheet at scale 1, preserve the original timing in metadata, then run verification. Never overwrite originals or accept output without the source comparison.

Runtime play and regular regression tests require only project-local PNGs/resources; Pixelorama and the external source folders are needed only for re-export/source verification. Test output, profiles and working copies remain ignored. No external PXO originals or tool executables are runtime dependencies.

## Runtime files and animation setup

The **16 PNGs** are:

- `assets/characters/astronaut/walk/{n,ne,e,se,s,sw,w,nw}.png`: each **448 x 64**, seven 64 x 64 regions.
- `assets/characters/chiwis/walk/{n,ne,e,se,s,sw,w,nw}.png`: each **256 x 64**, four 64 x 64 regions.

Each sheet has one row, zero margin/separation and original source frames 1..N left to right. Every character has **exactly eight distinct `walk_*` clips and eight `idle_*` clips**, with no duplicated `walk_e`. `idle_*` holds frame 1 of its corresponding direction as a provisional stationary pose; it creates no new artwork or redundant PNG. Directional artwork is used directly, with no simulated flipping.

`resources/characters/astronaut_frames.tres` and `chiwis_frames.tres` contain looping clips, AtlasTexture regions, original FPS and individual frame durations. `astronaut_art.tres` and `chiwis_art.tres` reference those resources and their source anchor arrays. These small typed profiles keep art replacement independent from movement/collision. The original astronaut controller is untouched; its scene supplies the real profile to the existing animation adapter. The procedural factory remains only as fallback/test coverage.

## Sprite scale and ground anchors

Both characters and visuals remain at **unit scale**. Original 64 x 64 canvases, proportions, transparency and pixels are preserved. Astronaut visible height is **51-57 pixels**, so a few frames exceed the Art Bible's recommended 56-pixel height by one pixel. That range is explicitly a recommendation, not a hard dimension limit; this is reported without changing the standard or distorting the supplied art. Chiwis visible height is **44-55 pixels** depending on orientation, with a long quadruped silhouette. Its body is visibly shorter than the astronaut in player/management screenshots; its canvas is never enlarged or forced to match human height.

The existing actor root remains the ground point. Sprite canvas X=32 is retained; the inspected lowest opaque foot row plus one supplies each frame's Y anchor. Recorded Y anchors vary **55-61** for astronaut and **51-60** for Chiwis. The shared adapter subtracts the current measured anchor only from the visual, then snaps the ground point through the active canvas after camera updates. Thus source baseline differences do not move the body, collider or world foot point. Default south-idle anchors are **(32, 61)** and **(32, 53)** respectively. This is the explicitly requested visual-offset correction, not cropping, padding, scaling or editing the artwork. No dimensional exception is required; locked standards remain version 1.0.0.

Original gait/body motion and unequal playback rates remain present. Dedicated authored idle poses, horizontal sway and artistic gait polish are future review topics. Current ground-anchor measurement is appropriate to these inspected foot silhouettes; future shadows/effects/low-hanging appendages require reviewed anchors rather than blindly treating their lowest pixel as a foot.

## Chiwis architecture and behavior

`scenes/companions/chiwis.tscn` instances under `World/Entities/NPCs/Chiwis`, inside the existing Y-sort hierarchy. It is a floating CharacterBody2D with a centered **8 x 4 ground rectangle**, smaller than the astronaut's unchanged 10 x 6 rectangle. Both use layer **1**, mask **2**, and therefore do not collide with/push each other. Visual offsets do not move collision. Main spawns Chiwis at native cell **(0, 1)**, world **(-32, 16)**, near the astronaut's cell (0, 0), and injects terrain, target and mode permission.

The lightweight state model is **IDLE / FOLLOWING / WAITING**. Inspector configuration defaults to preferred distance **36 px**, activation distance **56 px**, movement speed **90 px/s**, retry interval **0.35 s**. Once activated, following continues until the preferred distance is reached. Between the two thresholds, an idle dog stays idle and an active dog continues approaching. Capped physics displacement prevents overshooting the stopping distance. Missing, queued/freed, out-of-tree or nonfinite targets safely wait with zero velocity.

TerrainRoutePlanner first sweeps a direct connector using the existing complete-foot TerrainWalkability service. If blocked, a bounded **four-neighbor BFS** over existing terrain cells tests every cell-center connector and endpoint against that same foot rectangle. There are no diagonal cell jumps. A 2,048-node expansion budget bounds searches; there is no navigation framework, obstacle-node spawning or per-frame terrain rebuild. Plans refresh on target cell changes or the retry timer. Each actual physics displacement is swept again; unsafe/unreachable movement enters WAITING instead of teleporting or repeatedly pushing into holes. Tests include actual travel around a sparse barrier and complete-foot observations throughout that traversal.

Main forwards the existing coordinator's mode state. Management immediately stops/idles both actors and retains their positions. Chiwis retains facing/follow intent while paused, clears stale routing and resumes in Player Mode. No world reload or new character instance occurs. Existing management pan/zoom, player camera following, input-neutral handoff and UI input gating remain intact. Chiwis does not depend on a camera or read player movement keys.

Routing is terrain-only, intended for this small lunar foundation. All existing terrain kinds are walkable; missing cells are excluded. Physical obstacles on layer 2 can block native motion, but routes do not yet model dynamic obstacles. Unreachable goals, insufficient clearance and budget exhaustion wait safely. Arbitrarily transformed worlds, invalid external teleports, obstacle navigation, persistence and long-session optimization require future approved work.

## Files created or modified

Created:

- The 16 character PNGs above and their 16 Godot `.png.import` sidecars.
- `resources/characters/{astronaut_frames,astronaut_art,chiwis_frames,chiwis_art}.tres`.
- `art/imports/pixelorama_characters.json`.
- `tools/pixelorama/{export_characters.ps1,build_imports.ps1,inspect_pxo.gd,verify_exports.gd}`.
- `scripts/player/character_art_profile.gd`.
- `scripts/companions/{chiwis.gd,terrain_route_planner.gd}` and `scenes/companions/chiwis.tscn`.
- `tests/{pixelorama_assets_test.gd,chiwis_test.gd}`.
- Godot-generated `.gd.uid` sidecars for the seven new GDScript files.
- This report.

Modified:

- `scripts/player/astronaut_animation.gd`: optional real-art profile, shared per-frame ground-anchor rendering; existing clip selection/fallback preserved.
- `scenes/player/astronaut.tscn`: real art profile only; original movement/collider preserved.
- `scenes/world/world.tscn`: Chiwis instance under the existing NPC root.
- `scripts/core/main.gd`: companion spawn, dependency/mode wiring and phase log.
- `tests/astronaut_test.gd`: retain placeholder factory checks, validate actual runtime frames and measured anchors, preserve all movement regressions.
- `tests/validate.ps1`: add source manifest JSON validation, asset/companion suites and rendered companion checks; retain prior suites/fullscreen checks.
- `AGENTS.md`, `README.md`, `docs/architecture.md`, `assets/characters/README.md`, `scenes/player/README.md`, `scenes/companions/README.md`: current scope, import/replacement procedure, ownership and phase boundary.

Project settings, locked Art Bible/JSON, terrain code/data, camera implementations, mode coordinator and earlier phase reports were preserved. Old reports describe historical phase scopes; current instructions explicitly supersede their old companion/art prohibitions. No conflicting hard art standard was found. Git metadata was not present in this workspace; no commits or repository initialization were performed.

## Automated validation

Ran the complete reproducible export/import pipeline, then `./tests/validate.ps1 -IncludeRendering` using Godot **4.7.2**. Engine processes isolate user/editor data within ignored project output. The configured Windows certificate-store access required for engine startup was allowed; no network service was used for exports or gameplay.

| Check | Result |
| --- | --- |
| External originals | All 18 source hashes match; no originals changed |
| PNG/source comparison | All 16 sheets / 88 animation frames match nonguide source RGBA and ordering exactly |
| JSON | Standards, intake template, placeholder and actual source manifest parse successfully |
| Headless editor import | Passed |
| Runtime/test GDScript check-only parses | All 26 passed; import tools also executed successfully |
| Foundation | 231 headless / 233 graphical checks passed |
| Isometric world | 33,961 checks passed |
| Player camera | 49 checks passed |
| Gameplay modes | 93 headless / 99 graphical / 93 fullscreen checks passed |
| Astronaut | 234 headless / 244 graphical checks passed |
| Real asset metadata/textures | 696 checks passed |
| Chiwis | 44 headless / 46 graphical checks passed |
| Main/editor/fullscreen startup | Passed |
| Production architecture scan | No obsolete spatial architecture references |

Asset tests cover every source record, counts, real PNG hashes/textures, frame regions/order, FPS/duration, eight unique directions, provisional idle frames and measured anchors. Astronaut regressions retain physics/input/camera/mode/boundary behavior. Companion tests cover configuration/spawn, native scale, eight clip selections, activation/settling, hysteresis/no idle jitter, measured displacement at **30/60/120 Hz**, pause/resume/pan independence, no duplicate dog, invalid targets, a barrier detour, full-foot safety during actual traversal, impossible diagonal-gap waiting and restored valid terrain. Test meters count complete physics updates after actor processing; rate setup occurs before the first measured physics tick.

## Graphical validation

The renderer ran using Compatibility/OpenGL on the available NVIDIA adapter. Automated Godot input simulation exercised real player directional animation, camera/mode handoff and companion physics. Captures/contact sheets were inspected for correct actual artwork/orientations, crisp native pixels, shorter dog proportions, terrain alignment and simultaneous visibility in both modes. Ground anchoring also has automated screen-foot checks. This is automated graphical execution plus screenshot inspection; a physical keyboard/mouse play session and subjective long-duration animation polish are not claimed.

Evidence remains in `tests/output/`:

- `astronaut_chiwis.png`: both real actors in Player Mode at 2x.
- `chiwis_management.png`: both actors in the same world at 1x management view.
- `astronaut_source_contact.png`, `chiwis_source_contact.png`: all eight direction rows in N, NE, E, SE, S, SW, W, NW order, original frame sequence left to right.
- `astronaut_idle.png`, eight `astronaut_walk_*.png` captures, `astronaut_management.png`, and existing camera-mode captures.
- Per-suite `.log`/`.console.log` files; export-specific diagnostics under `pixelorama_export/`.

## Errors, warnings and limitations

**Final game validation: 0 errors, 0 warnings.** No unresolved game test failure remains.

**Pixelorama tool diagnostics are separate:** the successful final exports each emitted four `custom_samplers` shader errors and two duplicate Timeline keyframe signal errors. Console output additionally reported two shutdown resource/RID errors and one ObjectDB leak warning per invocation: **8 error lines and 1 warning line per animation export**, recorded in the manifest. These vendor-runtime diagnostics are not game errors and are not described as a clean tool run. Unknown errors abort the exporter. Acceptance of these known diagnostics is conditional on successful exit/output checks and independent exact-pixel/source-hash verification, which passed for all sixteen sheets. No vendor installation was patched.

Initial bounded executable/probe attempts also encountered restricted certificate/cache access and did not establish reliable exports. The documented installed-pack workflow and authorized engine validation resolved the export/startup path. Probe logs remain local development evidence. No source/output failure is being substituted with fabricated art.

The astronaut height recommendation variance, differing SE/W speed, provisional idle poses, per-frame source baseline corrections and terrain-only routing are explicit limitations. Original embedded generation history remains in PXO files; this phase did not issue generation requests or invent missing prompts/IDs. User-supplied integration permission does not establish a separate third-party redistribution license. Release exports, every monitor/DPI setup, animated obstacle navigation and long-session performance are not certified by these tests.

## Manual test instructions

1. Open `project.godot` with Godot 4.7.2 and run F5. Expect one real astronaut and one robotic dog on lunar tiles, with no extra characters or gameplay systems.
2. Walk with WASD/arrows in all eight directions. Check directional source art, animation order, camera following, crisp pixels, steady feet and unchanged player collision. Release input: the astronaut holds its corresponding provisional idle pose. Expect source SE/W walks to play slower.
3. Walk far enough to exceed Chiwis's 56-pixel activation distance. Stop and watch it approach to about 36 pixels and idle. Move less than the activation gap, then farther; verify stable hysteresis without threshold jitter. Chiwis should remain on terrain at map edges.
4. While walking/following, press Tab. Both actors must immediately stop while management WASD/arrows pan and wheel zoom works. Return to Player Mode and verify the same two instances/positions. Release movement keys held across the transition before issuing a fresh walk; Chiwis resumes autonomously.
5. Resize/fullscreen and inspect both modes. Inspect the 10 x 6 and 8 x 4 collision shapes independently of sprite canvases. Do not resize art to adjust collision or follow distance.
6. Run `./tests/validate.ps1 -IncludeRendering`. Sparse holes, barrier traversal and impossible diagonal gaps are temporary isolated fixtures inside the Chiwis test; the production 12 x 12 terrain is restored/preserved. Review test logs and captures separately from manual observations.
7. For source replacements, read the locked standards, inspect current source content, run `tools/pixelorama/build_imports.ps1`, review tool diagnostics and manifest, then rerun validation. Report incompatible source changes before modifying artwork or adopting an exception.

## Recommendations for an explicitly assigned Phase 0.7

Review dedicated idle art, source gait/anchor consistency and the intentionally preserved unequal walk speeds before requesting new art. Keep the current profile/metadata replacement contract. If future scope adds authored obstacles or larger maps, extend terrain-only routing with explicit obstacle data and appropriate path/collision tests; profile before selecting a broader navigation framework. Continue preserving one human protagonist, camera/mode ownership and original sources. T, Mars gameplay, advanced commands, inventory, construction, survival, missions, audio and multiplayer remain deferred. **Phase 0.7 was not started.**
