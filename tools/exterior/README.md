# Lunar exterior preparation

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
