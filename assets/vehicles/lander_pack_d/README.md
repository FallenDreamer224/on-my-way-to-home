# Moon Rocket / Lander - Asset Pack D

Four separate transparent PNGs: 320 x 320 Moon lander, 128 x 128 deployed ramp, 288 x 160 landing marker decal and 64 x 64 support cargo container. All are static, native 2D pixel art. The craft is designed as the player's arrival landmark and a trailer hero object.

`art/imports/lander_pack_d.json` records native dimensions, source/runtime hashes, provider IDs, prompts or exact PixelLab draw recipes, visible bounds, ground anchors, separate footprint dimensions/occupied cells and preview connection coordinates. Original output PNGs are preserved under `assets/pixellab/source/lander_pack_d/`.

## Footprints and grounding

The lander and decal use a 4 x 4-cell budget on the existing 64 x 32 ground grid. This projects to a 256 x 128 diamond; canvases include extra height/padding. Ramp is allocated 2 x 1 cells; cargo 1 x 1. These are presentation/design budgets, not new collision or walkability data.

Keep full PNG canvases, unit scale and nearest filtering. Set `Sprite2D.centered = false` and use the record's negative-anchor offset for a visual root at the ground/sort contact. The craft contact `(160,284)` is the front footpad center, not the canvas bottom. The decal contact `(144,144)` is the exact front diamond vertex. At a common sort root their diamond guides coincide; landing feet may extend beyond the centerline guide.

Footprints enumerate column/row cells relative to reference cell (0,0). The separate proposed sorting-origin offset is ((columns - rows) * 32, (columns + rows - 1) * 16) from that cell's center, following the established projection.

The ramp has upper connection `(34,24)` and front contact `(86,106)`. The preview places that connection at craft threshold `(205,207)`. These are static visual alignment coordinates, not a verified walkable boarding route. The hatch is closed. Review doorway clearance, placement snapping, collision and multi-cell occlusion before gameplay integration.

## Rendering and use

PNG imports are lossless, mipmaps off, no rescaling, alpha-border RGB rewriting off and no premultiplication. Preserve transparent padding. Do not silently resize, trim, crop or distort source art. Use the flat decal as a ground overlay above terrain and below the craft/actors, rather than as a raised Y-sorted object.

At native 1x the complete craft fits comfortably in a 960 x 540 hero shot. At player-camera 2x, its full 320-pixel canvas is 640 screen pixels high; deliberate camera framing is needed. Do not shrink the sprite to force a full-height shot.

This pack adds no production vehicle, boarding, landing, launch, collision, cargo/storage system or audio. The illustrated assembly is review-only. PixelLab usage terms: https://pixellab.ai/termsofservice .
