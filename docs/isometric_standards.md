# Isometric standards

## Projection and coordinates

- Projection: **2:1 diamond isometric**, rendered through native 2D nodes.
- A ground tile's diamond bounding box is **64 x 32 pixels**; half extents are `(32, 16)`.
- Grid coordinates are `Vector2i(column, row)`, abbreviated `(i, j)`. Increasing `i` travels down-right; increasing `j` travels down-left. World/screen pixel X grows right and Y grows down.
- World origin `O = (0, 0)` is the **center** of grid cell `(0, 0)`, not its top tip. Camera movement never changes grid/world coordinates.

For future coordinate helpers, the mathematical convention is:

```text
world_x = O.x + (i - j) * 32
world_y = O.y + (i + j) * 16

dx = world_x - O.x
dy = world_y - O.y
fractional_i = (dx / 32 + dy / 16) / 2
fractional_j = (dy / 16 - dx / 32) / 2
```

Phase 0.2 implements these equations in `IsometricGrid`. Examples: `(0, 0) -> (0, 0)`, `(1, 0) -> (32, 16)`, `(0, 1) -> (-32, 16)`, `(1, 1) -> (0, 32)`. Negative grid coordinates are valid. Fractional inverse coordinates do not define an edge tie-break rule by themselves.

The Phase 0.2 TileSet uses **Isometric**, tile size **64 x 32**, tile layout **Diamond Down**, with the horizontal offset axis. Engine integration tests confirm the desired down-right/down-left basis. Godot's raw `map_to_local()` centers include a `(32, 16)` offset:

| Grid cell | TileMapLayer local center | Desired world center |
| --- | --- | --- |
| `(0, 0)` | `(32, 16)` | `(0, 0)` |
| `(1, 0)` | `(64, 32)` | `(32, 16)` |
| `(0, 1)` | `(0, 32)` | `(-32, 16)` |
| `(1, 1)` | `(32, 48)` | `(0, 32)` |

Ground is placed at **`(-32, -16)`** under the identity-transformed Terrain node so cell `(0, 0)` is centered at world origin. Apply this one layer alignment offset consistently; do not also subtract it from coordinate helper results. Keep the organizational World, Terrain, and Entities transforms at identity.

The engine's TileMapLayer `map_to_local()` and `local_to_map()` are authoritative for cell placement and picking, including negative coordinates and exact diamond edges. Convert world input with `terrain_layer.to_local(world_position)` before calling `local_to_map()`, and use `terrain_layer.to_global(terrain_layer.map_to_local(cell))` in the other direction. IsometricGrid's `world_to_tile`/`tile_to_world` wrap these calls. These transforms account for the layer alignment offset. Do not feed window/UI coordinates directly into map picking. If a future TileSet layout yields a different basis, correct its configuration rather than maintaining two incompatible coordinate conventions.

The pure `tile_to_position` helper returns an origin-centered position in the common grid basis, not a camera/window coordinate. `position_to_fractional_tile` returns continuous logical coordinates. `position_to_tile` uses `floor(fractional + 0.5)` on each component: intervals are half-open `[-0.5, 0.5)` around each integer, and exact half ties choose the higher index even for negative coordinates. No epsilon or integer truncation is used. Native exact-edge ties belong to Godot and need not match that pure conceptual tie rule; use native wrappers for all actual terrain picking. Near edges, precision is limited by Vector2 floating-point representation; keep logical cells as Vector2i, and plan region-local rendering before very large coordinates. Neighbor order is +column, +row, -column, -row (four edge-sharing cells), independent of screen-facing character directions.

## Tile origin and alignment

At `(0, 0)` the diamond tips lie at top `(0, -16)`, right `(32, 0)`, bottom `(0, 16)`, and left `(-32, 0)`. For a 64 x 32 top-left image rectangle, the center is `(32, 16)`; matching tiles use that center as the ground origin. Keep source tile cells untrimmed and texture origins consistent. No arbitrary per-tile nudges to repair a mismatched projection.

Ground tiles and entities must share a common unscaled parent coordinate basis. Terrain remains below entities using the reserved ground `z_index = -10`. Decorative terrain overlays can be introduced later with an explicit draw-order purpose. Objects requiring actor occlusion belong in the Y-sorted entity hierarchy or need a deliberate TileMapLayer Y-sort configuration in Phase 0.2; they should not be baked into a flat ground layer.

## Sorting and feet

`World/Entities` and its organizational children have `y_sort_enabled = true`, equal `z_index`, zero offsets, and unit scale. Greater ground Y draws in front. Y-sort only compares items within compatible canvas/Z layers; do not give every building a higher Z value. Keep equal-Y ordering deterministic using stable scene insertion until a specific tie-break requirement exists.

Actor root position is the contact point between the feet and ground. A sprite's artwork extends upward from that point. With a bottom-centered source anchor, a centered Sprite2D can use `offset = Vector2(0, -frame_height / 2)`; otherwise use the measured per-asset anchor. Do not use a collision shape center or the visual sprite center as the entity root. All animation frames and directions share the same canvas, foot anchor, and baseline. Preserve transparent padding when necessary.

Building and environmental sprite roots likewise represent a documented ground contact/sorting point. Record the occupied grid footprint and sprite ground anchor separately; tall pixels do not increase the footprint. Multi-cell buildings may eventually need split artwork for correct occlusion. That policy is deferred until representative assets are available.

## Sprite size and scaling

Author at native pixel resolution and keep gameplay Node2D/Sprite2D scale at `(1, 1)`. A tile always occupies 64 x 32 world pixels. Larger objects use larger source canvases and documented footprints, not arbitrary scene scale. Avoid fractional texture scaling, rotated pixel sprites, and fractional final presentation transforms. Nearest filtering and integer viewport stretch are the project defaults; use integer camera zoom factors only after testing their viewport behavior. Keep simulation precision independent of a future render-only snapping decision.

## PixelLab intake expectations

Request 2:1 diamond isometric, 64 x 32 ground tiles, native 2D pixel art, transparent PNGs for characters/objects, consistent palette, lighting, and scale. Avoid baked perspective backgrounds and cast shadows that disagree with the shared ground plane.

- Characters: use eight named directions `south`, `south_east`, `east`, `north_east`, `north`, `north_west`, `west`, `south_west`. Treat these as screen-facing directions and map provider direction names explicitly. Do not infer array order.
- Animation sheets: record frame size, rows/columns, frame order, direction order, animation names, frame count, FPS, and loop flags. Preserve a shared foot anchor across every frame; never auto-trim individual frames.
- Terrain: record 64 x 32 cell regions and center anchors, atlas margins/separation, and any transparent padding. Disable texture repeat. Author seamless diamond edges.
- Buildings/objects: record native image size, ground anchor in image pixels, footprint in grid cells, orientation, and any occlusion split.
- UI icons: use native integer dimensions and transparent backgrounds where appropriate; they live in screen space.

PixelLab staging and provenance are documented in `assets/pixellab/README.md`. No asset generation or credit-consuming request is authorized by this phase.
