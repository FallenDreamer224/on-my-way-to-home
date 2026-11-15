# Moon Props / Pickup Objects - Pack B

Ten separate native 64 x 64 transparent PNG world sprites. All are static, single-view props. They share the astronaut/Chiwis white, cool gray and blue pixel-art style; rocks and scrap use matching muted materials. Text, logos, characters and audio are not part of this pack.

The complete metadata is in `art/imports/props_pack_b.json`: native dimensions, visible bounds, source/runtime hashes, generation IDs, prompts, measured ground anchors and Sprite2D offsets. The same records are included in the ZIP. Canvas dimensions include padding and do not determine an object's physical footprint.

## Ground placement

Keep the full PNG, native scale `(1, 1)`, nearest filtering and repeat disabled. Set `Sprite2D.centered = false` and use the record's `sprite2d_offset_px` (the negative ground anchor). Place the parent Node2D at the desired world ground contact. Use the existing Y-sorted entity hierarchy with the root at that contact point. This puts every sprite's lowest visible contact at the same ground Y without moving source pixels.

Anchors are measured integer positions from image top-left: center of visible bounds in X, lowest opaque row + 1 in Y. They differ between canvases because PixelLab did not place every object on the requested exact baseline. The preview uses these anchors to align all objects to horizontal ground lines. Check the visual center before final placement of asymmetric scrap/machine parts. No automatic trimming, scaling, cropping or repainting was applied.

One-cell footprints in metadata are proposed placement budgets, not collision masks or walkability changes. Define collision/occlusion behavior during a separately authorized gameplay integration. These world sprites are distinct from the 32 x 32 inventory icons in UI Pack A.

Godot imports use lossless compression, mipmaps off, no rescaling and no alpha-border pixel rewriting. Current gameplay pickups, item resources, scenes and character systems remain unchanged.

PixelLab usage terms: https://pixellab.ai/termsofservice . Original provider outputs, requests and the native-frame style reference are retained under `assets/pixellab/source/props_pack_b/`. Only the ten selected prop PNGs are included in the delivery archive.
