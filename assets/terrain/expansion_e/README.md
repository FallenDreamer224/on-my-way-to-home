# Moon Terrain Expansion - Asset Pack E

Thirteen separate native **64 x 32** PNGs cover the ten requested categories. Four orientations of the floor-edge strip are included so boundaries and corners can be assembled without rotating artwork. A **256 x 128** optional atlas packs the same pixels into four columns/four rows; the final three atlas cells are empty. Native tile dimensions, zero margin/separation, region coordinates, center anchors and source hashes are in `art/imports/terrain_pack_e.json`.

The existing Moon regolith PNG, TileSet, map and terrain logic remain unchanged. This pack supplies artwork only; no production layer or terrain-kind change is made.

## Contents and composition

- Transparent natural features: small crater, rocky patch, dark basalt patch and small dust/debris. Place above the existing regolith; surrounding ground remains visible.
- Worn footpath: a straight transparent dust strip along +column/-column. Repeat in that axis; turn/junction/end-cap variants are not included.
- Opaque ground surfaces: base floor panel, utility floor/pad, landing-marked ground and optional hazard-stripe panel. Each fills the exact canonical diamond with 1,024 opaque pixels.
- Transparent floor-edge strips: `base_floor_edge_tile.png` faces SE (+column); `_sw` faces SW (+row); `_nw` faces NW (-column); `_ne` faces NE (-row). Composite above floor panels only on exterior boundaries. Combine two strips at a corner using separate overlay layers, or pre-compose approved variants later. These are flush visual borders, not walls or collision.

All images retain transparent pixels outside the canonical diamond. Sparse overlays also preserve transparent pixels inside it. Alpha is binary; there are no interpolated edge pixels, text labels, characters or audio.

## Godot placement

Use native isometric TileMapLayer: tile size `(64,32)`, Diamond Down layout, horizontal offset axis, texture origin `(0,0)`, nearest filtering and repeat disabled. Share the existing ground basis and `(-32,-16)` layer alignment; image center `(32,16)` is the cell ground origin. Never apply that layer offset twice. Keep floor/feature layers above regolith and below raised actors/props. Do not assign their art indices as gameplay terrain kinds.

For a standalone Sprite2D, retain the complete PNG, use `centered = false`, native unit scale and offset `(-32,-16)` relative to a cell-center root. Do not resize, trim, rotate or crop the delivered art to force alignment.

Imports are lossless, mipmaps off, no rescaling, no premultiplication and no alpha-border RGB rewriting. Atlas cells are exact native blits; individual PNGs remain byte-identical to their selected PixelLab outputs.

## Production records

The selected art was authored from scratch through PixelLab's exact pixel tools using the sampled regolith grays and restrained floor colors. Four earlier AI candidates returned full ground diamonds instead of transparent natural features; they remain in the source archive and are not in this delivery. Valid draw recipes are embedded once in the manifest under `recipes`, with each asset naming its recipe/view. PixelLab draw IDs are recorded as production IDs; they are not paid AI generation counts.

Run `./tools/terrain_pack_e/prepare_pack.ps1` to verify preserved sources and rebuild metadata, preview, atlas and ZIP. Run Godot headless with `--script res://tests/terrain_pack_e_test.gd`; add `-- --capture` with a graphical renderer for isolated assembly captures. This test does not alter the production world.

The collection is a small assembly kit, not a full Wang/autotile terrain transition system. Floor art does not add walkability, construction, hazards, landing behavior or other gameplay. PixelLab usage terms: https://pixellab.ai/termsofservice .
