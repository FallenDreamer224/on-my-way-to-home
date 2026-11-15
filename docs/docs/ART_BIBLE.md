# Official Art Bible

Standards version: **1.0.0**. Project: **On My Way to Home**. Engine: **Godot 4.7.2**, native 2D, GDScript. These production standards apply to manually created assets and future PixelLab.ai MCP requests. The machine-readable counterpart is [asset_standards.json](../art/asset_standards.json). Change these two files together through an explicit standards revision; do not silently reinterpret an established decision.

## Isometric world

- Use **2:1 diamond isometric** projection and **64 x 32 pixel** ground tiles.
- Preserve the established grid: `(i, j)` means `(column, row)`; increasing `i` moves down-right and increasing `j` moves down-left. World pixel X grows right and Y grows down. Grid cell `(0, 0)` is centered at world `(0, 0)`.
- Cell centers follow `x = (i - j) * 32`, `y = (i + j) * 16`. Preserve the alignment and Godot coordinate-transform conventions in [isometric_standards.md](isometric_standards.md), including the planned Diamond Down layout and `(-32, -16)` layer alignment offset. This phase does not implement terrain.
- Larger environmental objects align to this ground grid. Multi-tile structures declare their logical ground footprint in grid cells separately from sprite canvas dimensions and ground anchor in image pixels. Record occupied cells when a rectangular width/height is insufficient.
- Canvas dimensions include transparent padding; they do not by themselves determine physical size or occupied ground cells.

## Characters

| Property | Official standard |
| --- | --- |
| Standard human frame | **64 x 64 pixels** |
| Recommended visible human height | **48-56 pixels**, excluding transparent padding |
| Directional coverage | **8 directions**: N, NE, E, SE, S, SW, W, NW |
| Initial walking target | **4-8 frames per direction** |
| Larger character frames when necessary | **96 x 96** or **128 x 128 pixels** |

The walking range is an initial production target, not a claim that all clips have the same length. Record actual per-direction counts and flag deviations for review. The visible-height range is a recommendation for standard humans, not an instruction to stretch artwork to fit it. Larger-character sizes are permitted when justified by the character's intended use; document their dimensions and rationale.

All frames in a character's animation set must retain a consistent frame canvas, foot anchor, and baseline across directions and animations. Transparent padding is permitted. Record the measured foot anchor from the frame's top-left corner; do not assume it is automatically the bottom edge or center of the canvas. The actor root remains at the ground contact point. Do not independently trim frames or stretch them.

Directions are screen-facing, independent of grid-axis movement. Existing long names remain compatible aliases:

| Code | Existing metadata/provider alias |
| --- | --- |
| N | `north` |
| NE | `north_east` |
| E | `east` |
| SE | `south_east` |
| S | `south` |
| SW | `south_west` |
| W | `west` |
| NW | `north_west` |

The code list is a coverage list, not an implied sheet row order. Existing documentation lists directions starting at south. Keep that decision intact: explicitly record sheet direction order, frame order, and provider-to-project mapping instead of inferring them from either list.

## Environment

| Category | Canvas rule | Required scale/alignment information |
| --- | --- | --- |
| Terrain | 64 x 32 pixels per ground tile | Diamond center, atlas region, margins/separation |
| Buildings | Variable sprite dimensions | Explicit logical ground footprint and ground anchor |
| Vegetation | Variable sprite dimensions | Ground anchor and physical scale; footprint where applicable |
| Props | Variable dimensions appropriate to physical/gameplay scale | Ground anchor and physical scale; footprint where applicable |

Maintain consistent pixel density relative to the standard human and ground tiles. Larger canvases may contain tall art, padding, or effects without implying a larger physical object. Author larger physical objects at the same pixel density; do not compensate with arbitrary scene scaling. Keep ground contact and occlusion requirements distinct from the artwork's bounding rectangle.

## Items

Standard inventory icons are **32 x 32 pixels**. Preserve transparent backgrounds where applicable. Avoid unnecessary antialiasing, blurred outlines, and interpolated edges. Record native canvas dimensions. These dimensions specify inventory icons, not the dimensions of a corresponding world sprite. UI icons that are not inventory items retain their documented native dimensions under the existing UI asset contract.

## Rendering and scaling

Use nearest-neighbor texture filtering, native-size pixel art, unit gameplay sprite scale `(1, 1)`, and consistent pixel proportions. Avoid blurry or interpolated pixel edges, fractional texture scaling, and stretching. Preserve the existing integer viewport presentation convention; any integer camera zoom requires a presentation check. These standards do not change project rendering settings.

Future runtime PNG imports use lossless compression, mipmaps off, no import rescaling, and texture repeat disabled unless specifically justified. Preserve transparent padding and alpha edges. Never silently resize, stretch, crop, or distort artwork to force compliance. Report incompatibility and obtain a decision before altering it; preserve original source files.

## Animation and metadata

Keep consistent sprite origins and character foot positions. Do not assume identical frame counts across directions; validate each clip against its actual sheet regions. Never stretch individual frames.

Every asset record must identify its asset ID, standards version, category, source/provider, source and runtime files, usage terms, native canvas size, physical-scale intent, review status, and any exception. PixelLab records additionally preserve generation ID and prompt. Do not store credentials or personal paths.

World sprites additionally record ground anchor and logical footprint where applicable; buildings and multi-tile structures always require an explicit footprint. Character records include visible height and a consistent foot anchor. Directional records declare coverage, explicit direction order, and provider mapping when applicable.

Animation metadata must include sheet frame size, rows/columns, margins/separation, and explicit frame order. Store each clip separately with **animation type/name, direction, actual frame count, frame indices or regions, FPS, and loop flag**. Validate that every referenced frame exists and that its dimensions and anchor match the declared set. Do not derive per-direction counts by dividing a total sheet count equally.

The existing PixelLab manifest is a generic intake template, not a completed asset record or an automation schema. Fill its animation entries with these per-clip fields and add standards-version/exception information when real assets are introduced. Do not integrate records containing unresolved placeholder values.

## Exceptions and approval

Document exceptions for bosses, oversized props, buildings, effects, and special animations. Variable building/vegetation/prop canvases are already permitted; deviations from other rules still require documentation. The allowed larger character frames also require a recorded intended use and rationale.

Every exception record includes asset ID, affected rule, actual dimensions, intended use, reason, footprint/anchor implications where applicable, approval status, and the user's decision or approval reference. A nonconforming asset remains unintegrated until the user chooses an approved exception, authorized modification, or replacement. No modification is implied by reporting a mismatch.

## Workflow and compatibility review

Before creating, requesting, or importing visual assets, read this Art Bible and follow `art/asset_standards.json`. Apply the standards to PixelLab prompts and manual briefs, validate dimensions and animation metadata before Godot integration, and keep gameplay logic independent of final artwork wherever practical. Asset names, documentation, and comments remain English; use lowercase snake_case asset names.

No artwork generation, PixelLab job submission, or credit consumption is authorized without explicit user authorization. This standards phase creates no assets, changes no rendering settings, and starts no gameplay work.

Existing documentation was checked: tile dimensions, projection, native scale, feet, imports, and ground footprints agree. Direction naming/list order is a notation difference resolved by the alias table and explicit sheet order, not a changed orientation convention. Constant frame canvas dimensions do not imply equal frame counts. The new human-frame, visible-height, walking-target, and inventory-icon sizes fill previously unspecified details. No conflicting established numeric standards were found; existing documents remain unchanged. Report any future contradiction and request a decision rather than silently replacing either rule.
