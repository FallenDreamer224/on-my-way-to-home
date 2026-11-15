# Asset Pack B - Moon Props / Pickup Objects

Delivered on 2026-11-15 through PixelLab MCP. Ten separate transparent native **64 x 64 PNG world props**, with preserved originals, measured ground anchors, import settings and provenance. The selected files are in `assets/environment/props_pack_b/`.

- Package: `art/exports/props_pack_b.zip` (ten PNGs, README and completed metadata).
- Preview: `art/exports/props_pack_b_preview.png` (960 x 540, artwork shown at integer 2x with common ground lines; labels belong to the preview only).
- Completed metadata: `art/imports/props_pack_b.json`.

## Contents and ground anchors

All anchors are image-top-left pixel coordinates, measured from the selected native PNG. The root is at ground contact; set `Sprite2D.centered = false`, use the negative anchor as `offset`, and retain scale `(1, 1)`. Preserve the full canvas and padding. The same anchor convention aligns all ten objects without shifting source pixels.

| Prop | Canvas | Ground anchor |
| --- | --- | --- |
| Lunar Sample | 64 x 64 | (32, 52) |
| Metal Scrap | 64 x 64 | (32, 48) |
| Supply Pack | 64 x 64 | (32, 49) |
| Small Equipment Box | 64 x 64 | (31, 53) |
| Tool Case | 64 x 64 | (32, 53) |
| Small Resource Canister | 64 x 64 | (31, 54) |
| Utility Crate | 64 x 64 | (31, 56) |
| Rock Cluster | 64 x 64 | (32, 51) |
| Broken Machine Part | 64 x 64 | (31, 52) |
| Beacon Marker | 64 x 64 | (32, 57) |

Anchor X is the integer center of the visible bounds; anchor Y is the lowest opaque row plus one, including any small contact detail. The generated canvases do not all share a fixed base row. Actual per-asset offsets provide consistent ground placement. Review the desired sorting center for asymmetric scrap or machinery before final scene placement.

## Style and production

The existing astronaut and Chiwis southeast walk sheets were inspected. A single native 64 x 64 astronaut animation frame was extracted from region `(0, 0, 64, 64)` for style guidance without rescaling; the original sheet remains unchanged. This is a reference extraction, not newly generated character art. Its source path, region and hash are recorded in the brief and completed manifest.

Props share crisp dark blue-gray outlines, white/cool gray surfaces, restrained blue details and upper-left lighting. Their single views are compatible with the 2:1 isometric world. They are world sprites, separate from Pack A's 32 x 32 inventory icons. All ten use the user's allowed 64 x 64 canvas size; canvas size is not a ground footprint or physical-size declaration. Visible object bounds are recorded independently.

PixelLab Pro Flash produced the selected mechanical props and lunar sample. The selected rock cluster came from PixelLab Pixen with a matching material/palette brief. Some initial candidates had stray pixels or disconnected marks, so replacement generations were requested. No local erasing, repainting, resizing, trimming, cropping or stretching was applied to provider outputs. All sixteen generated candidates are retained alongside the style reference under `assets/pixellab/source/props_pack_b/`; only the ten selected props are included in the delivery ZIP.

Total use: **76 subscription generations** (fifteen Pro Flash jobs at five each, one Pixen job at one). `get_balance` confirmed 4233.55 before and 4157.55 after generation. Authentication succeeded. No unrelated artwork or audio was generated.

## Files created or modified

- `assets/environment/props_pack_b/`: ten PNGs, ten Godot `.import` sidecars and README.
- `assets/pixellab/source/props_pack_b/`: original provider outputs, native-frame style reference and `generation_jobs.json` with exact prompts, seeds, provider IDs, source hashes and completed status.
- `art/briefs/props_pack_b.json`: production specification and reference provenance.
- `art/imports/props_pack_b.json`: selected per-asset metadata, actual dimensions, bounds, alpha statistics, source/runtime SHA-256 hashes, ground anchors, offsets, orientation and proposed footprint budgets.
- `art/exports/props_pack_b.zip` and `props_pack_b_preview.png`: deliverable archive and preview; the existing export-folder `.gdignore` keeps these out of Godot import.
- `tools/props_pack_b/prepare_pack.ps1`: repeatable native-size, alpha, bounds, exact-copy and anchor checks; builds metadata, preview and ZIP. It submits no jobs and performs no downloads.
- `tests/props_pack_b_test.gd`: Godot texture, hash, dimension, mipmap and anchor/offset verification.
- `AGENTS.md`: adds the authorized pack scope and handoff references, preserving existing rules.
- `docs/props_pack_b_report.md`: this report.

## Validation

- Ten unique selected props; all native dimensions exactly 64 x 64.
- Transparent PNGs with nonempty artwork, fully transparent margins and **zero partially transparent pixels**.
- Visible bounds remain inside each canvas; no edge clipping detected.
- Source and delivered PNGs have identical SHA-256 hashes.
- Visual review checked requested subjects, distinct silhouettes, style against the characters, clean margins, empty backgrounds and absence of baked text.
- Godot **4.7.2.stable.official.ed1daf0bf** import and reimport succeed.
- Lossless compression, mipmaps off, size limit zero, alpha-border RGB rewriting off and no premultiplication verified in all ten sidecars. Existing nearest filtering and integer presentation settings are preserved.
- `tests/props_pack_b_test.gd` passes: imported RGBA pixels exactly match decoded native PNGs; dimensions, hashes, no-mipmap setting and anchor offsets agree with metadata.
- Main scene headless smoke check succeeds, exit 0.
- Final import, texture-test and main-smoke logs: **0 errors, 0 warnings**.
- ZIP structure and PNG hashes checked against the delivery manifest.

No gameplay integration was requested. Existing item definitions, pickup objects, interaction/inventory behavior, terrain, walkability, characters, Chiwis following, cameras, UI and project settings remain unchanged. Full gameplay regression suites were not rerun for this asset-only delivery.

## Integration notes

These are static single-view sprites, not animations or eight-direction sets. They contain no embedded collision shapes. Proposed one-cell footprints are placement budgets only and do not alter terrain data. Final collision, sorting behavior, pickup quantities and trailer staging remain scene-level decisions for an explicitly requested integration.

Keep native pixel proportions. Do not infer physical size from canvas dimensions or silently force props to match the approximate visible-size suggestions in generation prompts. No locked art standard was changed and no exception was applied.

For future integration, place the prop root using the existing grid-to-world conventions and the recorded visual offset; retain the established Y-sort hierarchy. Verify object-to-character scale and occlusion in the target scene at 960 x 540. Review transparent PNGs on both dark and light backgrounds. PixelLab usage terms are referenced at `https://pixellab.ai/termsofservice`; no new license is asserted.

## Reproduction

1. Run `./tools/props_pack_b/prepare_pack.ps1` from the project to recheck preserved sources and rebuild the package.
2. Open Godot and import the selected PNGs with the supplied sidecars.
3. Run Godot headless with `--script res://tests/props_pack_b_test.gd`.
4. Inspect the preview and compare native assets at 100% and integer magnification.

No additional asset pack or development phase was started.
