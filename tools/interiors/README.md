# Lunar interior preparation

Read the Art Bible, isometric rules, Science Bible, Phase E1/E2 records and `docs/phase_0_8G2_lunar_base_art.md` first. The earlier G2 batch used 24 generations; the extended assignment used a separate 30, now exhausted. The 24 original candidates are retained under `assets/pixellab/source/interiors_g2/`; six failed quality review and remain excluded. The extension adds seven furnishings without altering those originals. Never repair retained candidates by trimming, scaling or silently editing pixels. No additional generation is authorized.

Reproduce metadata and scenes with Node and Godot 4.7.2:

```powershell
& $GodotPath --headless --path . --script res://tools/exterior/measure_images.gd -- res://tools/interiors/image_paths.json res://art/imports/interior_measurements.json
node tools/interiors/build_library.mjs
node tools/interiors/validate_library.mjs
& $GodotPath --headless --path . --editor --import
& $GodotPath --headless --path . --fixed-fps 60 --script res://tests/lunar_interior_library_test.gd
& $GodotPath --path . --fixed-fps 60 --script res://tests/lunar_interior_library_test.gd -- --capture
```

Keep runtime texture imports lossless, mipmaps/rescaling off and `process/fix_alpha_border=false`. Full raw/imported RGBA equality is tested. The generator copies accepted source bytes unchanged; it refuses inconsistent hashes or partial-alpha records. It writes only the interior library, Resources and scenes. It never rewrites exterior G1 resources, character sources, the production habitat layout, startup, simulation or scientific registry.

Each static prop has a native Sprite2D, measured ground pivot, logical GridOrigin and prepared interaction marker. Room placement snaps GridOrigin to a logical cell. Exact occupied grid cells, rather than the sprite rectangle, govern both TerrainLayer navigation and native room collision. A room's existing HabitatActions remain authoritative interaction points; not every decorative prop has an action. Do not give a floor sprite a gameplay identity.

Nine reusable `InteriorArtRoom` scenes extend HabitatRoom and preserve its state/actions contract. The development preview registers them in a fresh existing HabitatDirector session; the normal game retains its original room factory and entrance network. F1–F9 select rooms only when no modal/transition is active. WASD, E, Tab and I retain normal controls. Use F6 on `scenes/development/lunar_interior_preview.tscn`; it is not the main scene.

Back walls now use detailed original PNG panel/rib/vent art; foreground/partition walls retain eight-pixel cutaways. Forty structural PNGs comprise 33 READY components and seven UNUSED draft exterior supports. The 33 include two orientations of eight wall/door treatments, a corner, fifteen cable masks and one vertical riser. Twelve reusable module scenes cover three native floor components, straight/corner/window/service/support/door and three cable types. The floor TileSet and each room's prepared data are embedded native Resources/scene properties; runtime components do not read provenance JSON. No pre-existing bitmap source is recolored. Door states expose an aligned frame/leaf and update the same threshold used by both actors. Crew-airlock leaves and the equipment-lock inner interface read HabitatDirector.airlock; unbound pressure boundaries default sealed. The existing director still owns inspection, pressure matching and transitions. Ordinary passage state does not create a new pressure or locking system.

The two crop views observe existing DailyLife signals. Empty/seeded/germinating/small/intermediate/mature stages reflect actual planted/progress/yield fields. Seed markers and the open LED support are original native geometry. Plant overlays preserve whole images; a measured attachment base centers them on the tray surface. Germination includes a brown starter-medium plug, not lunar regolith. No crop death, physiology, plant oxygen, free water, unlimited yield or new simulation is supplied. Grow lights indicate actual dispatcher state; pause does not kill or reset plants.

Room dimensions and IDs match the original cutaway layout. There are now 34 prop scenes/Resources. Furniture occupies additional explicit cells. The isolated health/science variant retains its clear (6,3) approach and removes the old placeholder partition. The galley moves away from a new doorway. Extended G2 port overrides and nine room-sized exterior envelopes are recorded in resources/data/lunar_base_art_layout.json; production habitat_layout.json remains unchanged. The old small native facade sprites are attached bays, not enlarged substitutes for these full envelopes. Exact physical sealing, metrics and production placement remain integration work. See tools/exterior/README.md for local construction, base capture, audit and inventory commands. The inventory tool now updates both libraries while preserving historical records.
