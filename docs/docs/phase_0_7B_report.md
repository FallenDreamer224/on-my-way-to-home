# Phase 0.7B - Run Animation Integration

Integrated the supplied astronaut and Chiwis run artwork using **Godot 4.7.2.stable.official.ed1daf0bf** and the existing Pixelorama export/verification pipeline. Each real character now has **24 clips: eight idle, eight walk and eight run**. All existing walk PNGs and the complete timing, order, looping and anchor behavior of all 32 legacy idle/walk clips are preserved.

**Sprint input and sprint gameplay are deferred.** The astronaut still walks at 80 world pixels/second, and Chiwis follows at 90. Production controllers continue selecting idle/walk. No player, companion, animation-adapter, camera, terrain, mode, input, interaction or inventory runtime script was changed. No source artwork edits, new art generation, PixelLab calls/credits, audio or subsequent phase work occurred.

## Inspected and imported files

The authorized external `assets/animations/` folder currently contains **32 relevant PXO v8 projects**: 16 run and 16 walk files. Actual names were discovered rather than inferred from the old manifest. All have **64 x 64 RGBA canvases**, normal visible artwork layers, transparent padding and a hidden Skeleton guide layer. Some Chiwis files also have an empty visible `Capa 1` layer; the importer composites all visible nonguide layers in source order.

All 88 run frames are nonempty and have existing generated-cel provenance; their content/orientation was reviewed in contact sheets. No reference-only/unfinished frame was substituted, no Skeleton layer was exported and no direction was simulated with flipping. Original frame order and all duration multipliers were preserved. Every current run frame has duration multiplier 1.0.

| Direction | Astronaut run source | Frames / FPS | Chiwis run source | Frames / FPS |
| --- | --- | --- | --- | --- |
| N | astronaut_run_north.pxo | 7 / 6 | chiwis_run_north.pxo | 4 / 6 |
| NE | astronaut_run_north_east.pxo | 7 / 6 | chiwis_run_north_east.pxo | 4 / 6 |
| E | astronaut_run_east.pxo | 7 / 6 | chiwis_run_east.pxo | 4 / 6 |
| SE | astronaut_run_south_east.pxo | 7 / 6 | chiwis_run_south_east.pxo | 4 / 6 |
| S | astronaut_run_south.pxo | 7 / 6 | chiwis_run_south.pxo | 4 / 6 |
| SW | astronaut_run_south_west.pxo | 7 / 3 | chiwis_run_south_west.pxo | 4 / 6 |
| W | astronaut_run_west.pxo | 7 / 3 | chiwis_run_west.pxo | 4 / 6 |
| NW | astronaut_run_north_west.pxo | 7 / 6 | chiwis_run_north_west.pxo | 4 / 6 |

Thus six astronaut directions and all Chiwis directions use 1/6 second per frame; astronaut SW/W use 1/3 second. The slower source rates are deliberately preserved rather than normalized or made dependent on movement speed. There are **56 astronaut run frames and 32 Chiwis run frames**, verified individually rather than obtained by dividing an assumed equal sheet count.

The 16 new runtime PNGs are:

- `assets/characters/astronaut/run/{n,ne,e,se,s,sw,w,nw}.png`: each 448 x 64, containing seven 64 x 64 regions.
- `assets/characters/chiwis/run/{n,ne,e,se,s,sw,w,nw}.png`: each 256 x 64, containing four 64 x 64 regions.

Each sheet has one row, no margin/separation and original source frames 1..N left to right. PNGs use lossless import, no mipmaps, no import rescaling, no alpha premultiplication and no alpha-border modification. Native nearest-filtered character presentation and unit scale are unchanged. Imported frame RGBA matches the source audit byte for byte, including alpha edges.

`art/imports/pixelorama_runs.json` records the 16 run source hashes, per-frame bounds/alpha/timing/anchors/pixel hashes, explicit direction mapping, output PNG hashes and export diagnostics. Its separate walk inventory audits the 16 current walk sources without exporting them. All 32 source file hashes still match the before-import snapshot; no original file was modified, renamed, moved or deleted.

## Walk and idle preservation

The current walk files still contain seven frames per astronaut direction and four per Chiwis direction. The current Chiwis filenames consistently use `chiwis_walk_*`; some historical Phase 0.6 source entries used `chiwi_walk_*`. All 16 current walk sources render **exactly the same native nonguide pixels** as the existing runtime walk PNGs. Those PNGs were neither replaced nor re-exported. The original `pixelorama_characters.json` remains unchanged as historical provenance; the new manifest records current filenames/hashes.

Before adding runs, the merger fingerprints every legacy clip's name, FPS, loop flag, source texture path, frame regions, order, per-frame durations and foot anchors. It verifies those 32 fingerprints after merging and saves them for independent regression checks. Runtime tests then reload the saved resources and verify them again. Existing provisional idle clips still hold their original corresponding walking frame; no idle state was rebuilt from run artwork. Default south anchors remain astronaut (32, 61) and Chiwis (32, 53).

The existing procedural astronaut fallback remains the original 16-clip idle/walk fixture and retains its tests. Run support belongs to the real character resources; no run placeholder artwork was invented.

## Architecture and import workflow

No new animation framework was introduced. The existing `AstronautAnimation.select_state(state, facing)` adapter already resolves `state_direction` and uses CharacterArtProfile's per-frame anchors. The new states are:

`run_n`, `run_ne`, `run_e`, `run_se`, `run_s`, `run_sw`, `run_w`, `run_nw`.

Both existing SpriteFrames resources gain these eight looping clips. Both existing art profiles gain their eight anchor arrays. Existing scenes, controllers, body collisions and facing logic remain unchanged. A future explicitly approved sprint policy can select `visual.select_state(&"run", facing)` through this API; it must own locomotion-state selection, since the current controllers intentionally continue selecting idle/walk each physics tick.

The Pixelorama tooling now accepts an animation type and merges only that selected state. The wrapper defaults to **run** to make the current workflow additive and preserve walks/idles:

```powershell
.\tools\pixelorama\build_imports.ps1 -AnimationType run
# Explicit paths when defaults differ:
.\tools\pixelorama\build_imports.ps1 -AnimationType run -SourceRoot 'C:\path\to\assets' -PixeloramaPack 'C:\path\to\Pixelorama.pck' -GodotPath 'C:\path\to\Godot_v4.7.2-stable_win64.exe'
# Verify existing run PNGs and rebuild only run metadata/resources:
.\tools\pixelorama\build_imports.ps1 -AnimationType run -SkipExport
.\tests\validate.ps1 -IncludeRendering
```

PowerShell 7, the existing Godot executable and installed Pixelorama 1.2.4 resource pack are used. Run mode reads only the authorized animations folder, discovers both walk/run source names, exports only runs, and never reads/re-exports the character reference sheets. As before, the installed Pixelorama pack is executed through Godot using project-local working copies/profiles, native scale 1, horizontal sheets and explicit source frame range. Skeleton visibility changes occur only in ignored working copies. No dependency was installed.

The verifier independently reconstructs original nonguide RGBA cels and rejects changed source hashes, empty frames, incompatible output dimensions, missing provenance or any exported pixel/order mismatch. Newly created PNG import sidecars are processed again after alpha-border modification is disabled. Only verified runs are merged into existing SpriteFrames/profiles; other states and profile defaults remain in place. Contacts, audit images, source working copies and console logs remain under ignored `tests/output/`.

Explicit `-AnimationType walk` retains the earlier walk/idle refresh path and now retains other registered states rather than recreating a 16-clip resource. It is a separate authorized replacement workflow; **it was not run in this phase**. Do not refresh walk/idle as a side effect of run integration. Reinspect future source changes and review manifests before accepting replacements. Runtime play and normal tests need only the project-local PNGs/resources, not Pixelorama or external source access.

## Ground alignment and scale

The existing adapter applies reviewed per-frame visual offsets independently from the body/collider. Run source X anchors remain 32. Source Y anchors are measured from the lowest opaque foot row plus one: astronaut **52-62**, Chiwis **49-60**. Every frame's recorded anchor is verified against its imported pixels. The adapter places that ground point at the pixel-snapped body root through the active canvas, with no body displacement caused by animation changes. The same rule already serves walking; its source code was not changed.

Run visible heights are astronaut **49-60 pixels**, Chiwis **42-55 pixels**, excluding transparent padding. Some astronaut run poses exceed the official recommended 48-56 human height range; that range is a recommendation, while the actual mandatory frame size remains 64 x 64. These supplied poses are kept intact and reported rather than cropped, stretched, scaled or used to revise locked standards. Original character proportions/pixel density remain unchanged, and Chiwis is not enlarged to fill its canvas.

All 88 frames pass screen-ground-anchor checks. Rendered previews show correct directional poses, sharp native pixels and a stable ground reference. Authored limb/posture motion remains present; the tests distinguish that from unintended movement of the body/collider. No run-specific physical movement, collision offset, camera adjustment or world-coordinate rule was added.

## Files created or modified

Created:

- Sixteen run PNG sheets and their sixteen Godot `.png.import` sidecars at the paths above.
- `art/imports/pixelorama_runs.json`.
- `tools/pixelorama/animation_fingerprint.gd` and `.gd.uid`.
- `tests/run_animation_test.gd` and `.gd.uid`.
- This report.

Modified:

- `resources/characters/astronaut_frames.tres`, `chiwis_frames.tres`: additive run clips.
- `resources/characters/astronaut_art.tres`, `chiwis_art.tres`: additive run anchor arrays, preserved defaults/legacy metadata.
- `tools/pixelorama/export_characters.ps1`: selected-type exports, actual filename/direction mapping, separate run manifest and audit-only current walk inventory.
- `tools/pixelorama/build_imports.ps1`: selected type/default run, new-sidecar reimport and additive verifier arguments.
- `tools/pixelorama/verify_exports.gd`: exact selected-state verification/merge, legacy fingerprints and current walk pixel audit.
- `tools/pixelorama/inspect_pxo.gd`: optional animations-only read mode.
- `tests/pixelorama_assets_test.gd`, `chiwis_test.gd`, `interaction_inventory_test.gd`: retain all legacy assertions while expecting eight additional run clips in real profiles.
- `tests/validate.ps1`: run manifest validation and headless/graphical run suite, preserving all previous suites.
- `AGENTS.md`, `README.md`, `assets/characters/README.md`, `scenes/player/README.md`, `docs/architecture.md`: current state, safe import workflow and deferred sprint scope.

Godot also reprocessed character import sidecars with the same established pixel-preserving parameters. A before/after hash comparison of existing production scripts/scenes/resources/PNG assets/art JSON found changes only in the four intended character resources. Existing walk PNGs, original character manifest, Moon terrain assets/data, project settings, InputMap, runtime scripts and scenes remain unchanged. No source assets or files outside the project were written. No Git commit or repository initialization was performed.

## Executed validation

Executed source inspection, all 16 Pixelorama exports, independent RGBA verification/merge, a focused graphical run test, and the full `./tests/validate.ps1 -IncludeRendering` regression run with Godot **4.7.2**.

| Check | Actual final result |
| --- | --- |
| External run/walk originals | All 32 before/after hashes match |
| New run sheets | All 16 / 88 frames verified against original nonguide RGBA and order |
| Current walk sources | All 16 match preserved runtime walk PNG pixels; none re-exported |
| Legacy clip semantics | All 32 fingerprints unchanged after save/reload |
| JSON syntax / editor import | Passed, including run manifest |
| Runtime/test GDScript check-only parses | All 40 passed; import/fingerprint tools also executed successfully |
| Foundation | 380 headless / 382 graphical checks passed |
| Isometric world | 33,961 checks passed |
| Moon terrain | 338 headless / 342 graphical checks passed; raster coverage remains gap/overlap free |
| Player camera | 49 checks passed |
| Gameplay modes | 93 headless / 99 graphical / 93 fullscreen checks passed |
| Astronaut movement/animation | 234 headless / 244 graphical checks passed |
| Original walk asset suite | 696 checks passed |
| New run animation suite | **903 headless / 911 graphical checks passed** |
| Chiwis movement/routing | 44 headless / 46 graphical checks passed |
| Inventory | 38 checks passed |
| Interaction/inventory integration | 64 headless / 67 graphical checks passed |
| Main headless, graphical editor and fullscreen startup | Passed |

The run suite verifies every source record, eight distinct directions per character, actual textures/regions, original FPS/duration/loop flags, all imported frame pixel hashes, no flipping/scaling, transparent nonguide content, import settings, per-frame anchors, snapped world ground contact and zero animation-induced body movement. Native animation clocks advance, repeated state requests do not restart playback, and run can return to preserved walk/idle. It verifies no sprint action/speed change and normal controller/companion behavior after previews. All previous movement, terrain, routing, camera, inventory/modal and character tests ran again.

**Final game validation: 0 errors, 0 warnings.** A temporary typed-array inspection harness issue was corrected before exports; the final read-only inspection completed for all 32 files. No failed assertion was skipped.

**Exporter diagnostics are separate:** each successful Pixelorama run export emitted four `custom_samplers` shader errors and two duplicate Timeline keyframe signal errors: **six vendor-tool error lines per file, 96 total**, with no Pixelorama WARNING lines in these final export records. The wrapper emits a summary warning about them. They are recorded per source in the run manifest/console logs, not mislabeled as a clean export-tool run. Unknown tool errors abort the pipeline; acceptance of these known nonfatal diagnostics requires successful process/output checks and exact source-pixel verification, which passed. The vendor installation was not modified.

## Graphical evidence and manual checks

The renderer ran with the existing Compatibility/OpenGL backend. Contact sheets and in-world previews were inspected for all eight orientations, crisp pixels, original proportions and stable ground placement. The run suite freezes only body physics inside the test while displaying run states, then restores normal controllers. Production scenes contain no preview key, movement override or automatic run activation.

Evidence in `tests/output/`:

- `astronaut_run_source_contact.png`, `chiwis_run_source_contact.png`: original frames left to right, direction rows N/NE/E/SE/S/SW/W/NW.
- `run_n.png`, `run_ne.png`, `run_e.png`, `run_se.png`, `run_s.png`, `run_sw.png`, `run_w.png`, `run_nw.png`: both real characters on the Moon, previewing the same facing.
- `run_animation.log`, `run_animation_rendered.log`, all prior regression logs/captures and per-export logs under `pixelorama_export/`.

This is automated playback/input/physics/rendering plus screenshot inspection, not a physical keyboard/mouse sprint play session. The 3 FPS astronaut SW/W clips and recommended-height variance are source-art notes for later review, not engine errors or instructions to alter the artwork.

Manual validation:

1. Run F5 and walk in all eight directions. Verify the same walk/idle poses, movement speed, camera following, collision and terrain boundaries. Let Chiwis follow and settle. Run must not activate automatically or through a new key.
2. Switch with Tab, pan/zoom management and return. Verify the existing actor/input rules, terrain, pickups and inventory remain functional. I/Esc and modal behavior are unchanged.
3. Open each `resources/characters/*_frames.tres` in Godot's SpriteFrames editor. Confirm 24 clips and inspect all `run_*` source directions, seven astronaut/four Chiwis frames, original order and recorded FPS. Run SW/W astronaut clips should remain slower.
4. Run `./tests/validate.ps1 -IncludeRendering` to preview proper runtime anchoring and regenerate all eight run screenshots. Editor canvas previews alone do not apply CharacterArtProfile's runtime offsets.
5. Inspect the art profiles' new run anchors separately from existing idle/walk anchors and collision shapes. Do not adjust physical footprints or stretch artwork to alter run presentation.

Future sprint input, speed policy and locomotion-state arbitration require an explicitly assigned gameplay phase. Before enabling them, review the intentionally preserved per-direction run timing and authored poses. **No next phase was started.**
