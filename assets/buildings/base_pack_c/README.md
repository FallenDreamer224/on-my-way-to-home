# Moon Base Essentials - Asset Pack C

Ten separate static transparent PNG assets. The habitat is designed around 3 x 2 cells; airlock and solar array around 2 x 2; large storage around 2 x 1; remaining equipment around 1 x 1. Ground tiles remain 64 x 32 pixels. Sprite canvases include height and transparent padding; canvas size never defines a footprint.

Use `art/imports/base_pack_c.json` for native sizes, original prompts, generation IDs, measured base anchors, visible bounds, exact source/runtime hashes, footprint dimensions, explicit occupied cells and grid-reference coordinates. The original outputs and requests are preserved under `assets/pixellab/source/base_pack_c/`.

## Ground anchoring and grid guides

Retain complete canvases at unit scale, nearest filtering and repeat disabled. For a visual Node2D at the recorded front contact/sort point, use `Sprite2D.centered = false` and the record's negative-anchor `sprite2d_offset_px`. The anchor is measured at the lowest occupied base row, with integer X centered on that row's contact pixels. Check asymmetric legs/contact details before final placement.

Occupied cells use the project's column/row order relative to reference cell (0,0). The reference is that cell's diamond center. The proposed front footprint vertex is recorded separately as `sorting_origin_relative_to_reference_cell_px`: ((columns - rows) * 32, (columns + rows - 1) * 16). For future placement, add it to the reference cell's world center to obtain the proposed sort root. The guide preview draws footprint boundaries from these values without changing source pixels.

Footprints are explicit design placement budgets. They are not pixel-derived collision masks or a claim of exact sprite-base perimeter fit. Review the guide preview and actual sprite base before construction integration. Some structures have short feet, overhangs or narrow masts within their allocated area. Multi-cell/tall occlusion may need deliberate scene composition. Do not silently resize, crop or stretch art to force grid fit.

## Rendering and use

Godot imports: lossless compression, mipmaps off, no rescaling, alpha-border RGB rewriting off, no premultiplication. Source PNGs are copied byte-for-byte. These are single-view assets without animations, characters, text, logos or audio. Screen artwork on the console is a blank pane; any labels or operational states belong in future game systems.

This delivery does not add buildings to the production world, construction, power, storage, oxygen, communications or other gameplay. Future scene integration can use the existing native 2D/Y-sort conventions. PixelLab usage terms: https://pixellab.ai/termsofservice . No new license is asserted.
