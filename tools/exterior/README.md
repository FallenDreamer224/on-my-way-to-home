# Lunar exterior preparation

## Current extended G2 assembly

Phase 0.9 promotes these assets into normal Main/New Game through LunarBaseWorld and scenes/world/lunar_outpost.tscn. The two original art galleries explicitly retain their independent fixtures. The G2 capture test now writes evidence only under tests/output; `--write-compositions` is an explicit authoring option for a separately authorized art rebuild and must not be used by production regressions. Delivered composition PNGs are preserved.

The G1 instructions below remain the original library contract. The extended G2 adds the modular outpost without changing G1 sources/resources or production startup. Read `docs/phase_0_8G2_lunar_base_art.md` and the current inventory. Its additional 30-generation authorization is exhausted; every command here is local and submits no PixelLab job.

```powershell
# Rebuild local metadata/scenes from retained and reviewed files.
node tools/exterior/build_base.mjs
node tools/interiors/build_library.mjs
node tools/exterior/build_base_resources.mjs
node tools/exterior/validate_base.mjs
node tools/interiors/validate_library.mjs
node tools/exterior/audit_base_sources.mjs
node tools/interiors/update_inventory.mjs
node tools/exterior/validate_base_documents.mjs
& $GodotPath --headless --path . --editor --import
& $GodotPath --headless --path . --fixed-fps 60 --script res://tests/lunar_base_art_test.gd
& $GodotPath --path . --fixed-fps 60 --script res://tests/lunar_base_art_test.gd -- --capture
```

For deliberate source reconstruction only, `paint_structure.gd` bakes 40 original PNGs, `paint_hulls.gd` reproduces retained superseded drafts, and `key_shell_background.gd` reproduces the five native transparent shell images from the complete opaque originals. The alpha recipe floods connected red/purple background and retains the largest subject component. It checks every retained RGBA value against the source and never resizes, crops the canvas or redraws object pixels. Ten provider background-removal masks damaged the vessels and are rejected; do not use them. Technical preparation was authorized by extended G2 sections 24/27 and is recorded explicitly in native_shells.json. This is not permission to alter other artwork.

Repainting/reprocessing resets review status. Inspect current source/output and native captures before running `node tools/exterior/finalize_base_review.mjs --confirm-reviewed`; then rebuild Resources, audit and inventory. Never run that review recorder as a substitute for visual inspection. Lossless imports require mipmaps/rescaling off, nearest filtering and `process/fix_alpha_border=false`; compare decoded raw/imported RGBA, including transparent pixels.

Five illustrated shells are reused for nine room-sized logical envelopes. Their full texture remains shared by 32-pixel depth strips for sorting; the envelope is a conservative grid budget, distinct from visible overhang or a real pressure volume. ExteriorOcclusionGuard caches five alpha bitmaps and applies a cutaway when a shell would conceal an existing actor. There is no per-frame image decoding or runtime image synthesis. The source texture is not modified. Individual passage sprites stay at unit scale; pair ordered route cells along increasing axes so reversed BFS routes do not become repeated junctions. The angular TileMapLayer atlas is hidden technical geometry only. Exact sealed socket/collar placement remains final assembly refinement, not pressure physics.

F6 `scenes/development/lunar_base_preview.tscn` runs a fresh existing Main/HabitatDirector session. F1 entrance, F2 core, F3 greenhouse, F4 power, F5 lander. Tab, WASD, E and I retain existing behavior. The exterior hatch reads the real shared airlock. Enter, seal, inspect and cycle using its original actions to reach prepared rooms with the same astronaut, Chiwis and inventory. All room selectors/modal gates remain intact. The copied 40×40 map retains terrain kinds and uses isolated occupancy; normal world and EVA policy are unchanged. Two 2688×1536 composition exports use a separate native 1× SubViewport and are excluded from runtime scanning. Never flatten the runtime base into one image.

## Original G1 library

This pipeline prepares native artwork and development prefabs. It does not place objects into the production Moon world or change simulation.

1. Read the Art Bible and existing source/import manifests. New generation always requires explicit user authorization.
2. Preserve full native PNGs in the source archive and copy accepted files unchanged to their runtime folder. Complete `art/imports/exterior_g1.json` before adding them to the library. Keep lossless/no-mipmap imports, nearest sampling and alpha-border rewriting off.
3. Measure the runtime images using Godot 4.7.2:

```powershell
& $GodotPath --headless --path . --script res://tools/exterior/measure_images.gd -- res://tools/exterior/image_paths.json res://art/imports/exterior_measurements.json
node tools/exterior/build_library.mjs
node tools/exterior/audit_sources.mjs $ExternalAssetRoot
& $GodotPath --headless --path . --editor --import
& $GodotPath --headless --path . --script res://tests/lunar_exterior_library_test.gd
& $GodotPath --path . --script res://tests/lunar_exterior_library_test.gd -- --capture
```

`$ExternalAssetRoot` is the optional read-only original asset directory; omit it to audit project files only. Do not pass an output directory outside the project. Measurement source lists and output paths are explicit. Inspect new art visually; automatic alpha/size checks cannot approve perspective, physical meaning or scale.

`resources/exterior/` and `scenes/exterior/` are generated from the versioned manifests. Rebuild them through the script, not by hand. Every prefab is a script-free native Node2D with a full Sprite2D canvas, explicit metadata, ground/grid/access/service markers, and an optional blocking body. Equipment adds only an optional read-only status indicator component; it is hidden until a caller deliberately binds real state. No utility service or interaction implementation is added.

The root is the measured front ground/sorting contact. `GridOrigin` is logical reference cell (0,0) relative to that root; the two are not interchangeable. A placer positions GridOrigin on the existing 64×32 grid, then preserves the sprite offset. Footprints are logical design budgets, not pixel-traced hulls. Solid collision adds half a cell of ground-hardware clearance; future route planners must also reserve `navigation_reserved_cells` (the intersected outer cell ring). Access and service points sit outside this envelope. Production placement must check room approach corridors, neighboring clearance and interactions for both actors.

Use the same Y-sort parent and canvas/Z as actors. Ground/decal textures stay below entities. Large structures use one conservative occluder in this phase; split-layer/roof cutaway behavior and fine leg/underbody traversal remain integration work. No arbitrary sprite rotation, mirroring, trimming or resampling is supported.

Run `scenes/development/lunar_exterior_preview.tscn` separately (F6). Keys 1–8 select Habitat, Power, Lander, Science, Props, Safety, Sorting and States. G toggles technical guides. The test runner captures those eight 960×540 bays and one complete 1920×2160 native-pixel showcase using a separate viewport. Neither changes the game's 960×540 setting or normal application entry.

Connecting pressure passages, opened-hatch artwork and continuous cable/support assets remain explicit gaps. A utility box is not a pressure corridor. A reused body shell is not a claim that the entire cutaway interior fits one exterior sprite or that NASA operates the fictional assembly.
