# Asset Pack C - Moon Base Essentials

Delivered on 2026-11-15 through PixelLab MCP: **ten separate static transparent PNGs** for a native 2D isometric Moon base. Original outputs are preserved and selected files are copied byte-for-byte for Godot import. No production gameplay integration is included.

- Package: `art/exports/base_pack_c.zip`.
- Native-size preview: `art/exports/base_pack_c_preview.png`.
- Footprint guide: `art/exports/base_pack_c_footprints.png`.
- Completed asset metadata: `art/imports/base_pack_c.json`.

The previews show complete artwork at 1x; labels and guide outlines are preview annotations, not baked into any delivered asset.

## Assets and declared footprints

| Asset | Native canvas | Footprint in grid cells | Measured image ground anchor |
| --- | --- | --- | --- |
| Small Habitat Module | 192 x 192 | 3 x 2 | (93,169) |
| Airlock Module | 160 x 160 | 2 x 2 | (81,154) |
| Solar Panel Array | 160 x 128 | 2 x 2 | (67,118) |
| Battery / Power Unit | 96 x 96 | 1 x 1 | (42,75) |
| Storage Crate Large | 128 x 128 | 2 x 1 | (46,92) |
| Utility / Oxygen Tank | 96 x 128 | 1 x 1 | (45,106) |
| Communications Antenna | 96 x 160 | 1 x 1 | (43,122) |
| Work Terminal / Control Console | 96 x 96 | 1 x 1 | (43,73) |
| Light Beacon / Pole Light | 64 x 128 | 1 x 1 | (41,99) |
| Small Connector / Utility Box | 64 x 64 | 1 x 1 | (32,51) |

Ground tiles remain 64 x 32 pixels. Footprints follow the requested size guidance and are recorded independently from native canvas, visible bounds, height and overhang. Each metadata record enumerates its occupied cells explicitly in column/row order relative to cell (0,0).

## Style and production

The pack uses white/light gray practical survival hardware, restrained navy/blue details, crisp dark outlines, upper-left lighting and single isometric-compatible views. The reference was the existing unscaled 64 x 64 astronaut southeast frame used for Pack B; its sheet region and SHA-256 are recorded. No character artwork was generated. Chiwis and Moon terrain informed the existing shared style conventions. There are no text labels, logos, characters, animation frames or audio outputs.

Ten initial Pro Flash jobs used the shared astronaut style reference. Habitat, airlock and solar-array candidates needed replacements because stray margin pixels made ground anchors unreliable; the initial habitat also read too small against the human-scale brief. Three PixelLab Pixen replacements used the same white/gray/blue material, lighting, projection and pixel-density direction with clearer structure-scale targets. All thirteen generated candidates remain intact under the source archive. No local erasing, repainting, resizing, trimming, cropping or stretching was applied to provider outputs. PixelLab's own native generation/grid-recovery pipeline produced the delivered canvases.

Final cost: **60 subscription generations**, including replacements (initial jobs total 57, three Pixen replacements cost one each). Authentication succeeded. `get_balance` confirmed 4157.55 before and 4097.55 after the pack. No unrelated jobs were submitted.

## Anchoring and grid conventions

Ground anchors are integer image-top-left coordinates. They use the lowest opaque base row plus one in Y, with X centered on that row's visible contact pixels. Each selected base was visually reviewed. Metadata also records the full visible rectangle and negative Sprite2D offset; no source pixels were moved to align a canvas.

For future visual placement, retain the complete PNG, use `Sprite2D.centered = false`, scale `(1,1)` and `offset = -ground_anchor`. Place the visual root at the intended ground/sort contact. Do not use the image center as a foot point or shift interaction/collision coordinates merely to align artwork.

The footprint reference is the center of logical cell (0,0). For a rectangular C-column/R-row budget, the four projected perimeter vertices relative to this reference are `(0,-16)`, `(C*32,(C-1)*16)`, `((C-R)*32,(C+R-1)*16)` and `(-R*32,(R-1)*16)`. The front vertex is stored separately as a proposed sorting-origin offset. The footprint preview places that vertex at the measured image contact and draws the declared budget behind the unchanged sprite.

These are explicit **design placement budgets**, not pixel-derived collision masks or a claim of exact sprite-base perimeter fit. Some feet, roof edges and solar panels overhang; narrow masts/tanks occupy less of their reserved cell. Native canvas dimensions do not define physical footprint. Final placement, contact-center choice, neighboring structures, doorway clearance and tall/multi-cell occlusion require scene review before construction integration. No source modification or standards exception was applied to force a fit.

## Files created or modified

Created:

- `assets/buildings/base_pack_c/`: ten selected PNGs, ten Godot import sidecars and README.
- `assets/pixellab/source/base_pack_c/`: thirteen unchanged provider PNGs, the retained native-frame style reference, and `generation_jobs.json` containing exact prompts, parameters, seeds, provider IDs, completed statuses, source filenames and hashes.
- `art/briefs/base_pack_c.json`: production specification, requested footprints and style-reference provenance.
- `art/imports/base_pack_c.json`: complete selected-asset provenance, dimensions, visible bounds, alpha/color statistics, source/runtime hashes, contact anchors, offsets, occupied cells and projected footprint coordinates.
- `art/exports/base_pack_c.zip`, `base_pack_c_preview.png` and `base_pack_c_footprints.png`: delivery archive and review images. The existing export-folder `.gdignore` excludes them from Godot import.
- `tools/base_pack_c/prepare_pack.ps1`: repeatable source validation, exact copying, metadata, previews and ZIP packaging; it submits no generation jobs and performs no downloads.
- `tests/base_pack_c_test.gd` and its Godot UID sidecar: imported-pixel, footprint and anchor checks.
- `docs/base_pack_c_report.md`: this report.

Modified:

- `AGENTS.md`: adds the authorized Pack C scope, provenance references and integration boundaries while preserving existing instructions.

Production scenes, scripts, item definitions, prop-integration Resources, project settings and existing assets remain unchanged. No construction, power, oxygen, storage, communications, building placement or light-rendering system was added.

## Validation

- Ten unique selected PNGs with exact declared native dimensions.
- Nonempty artwork, transparent margins, no detected canvas-edge clipping, **zero partially transparent pixels** in every selected file.
- All runtime PNG hashes match their selected provider originals.
- Visual review of complete native canvases checked requested subjects, silhouettes, projection, material consistency, empty backgrounds and absence of text/branding.
- Manifest/brief JSON parses; all mandatory asset/provenance fields are present.
- Explicit rectangular footprint dimensions agree with unique occupied-cell lists and 64 x 32 projection coordinates.
- Godot **4.7.2.stable.official.ed1daf0bf** headless import and reimport succeed.
- All ten sidecars use lossless compression, mipmaps off, no rescaling, no alpha-border RGB rewriting and no premultiplication. Existing nearest filtering and integer presentation remain unchanged.
- `tests/base_pack_c_test.gd` passes: exact imported RGBA pixels, dimensions, source hashes, no mipmaps, contact offsets and footprint records.
- Main scene headless smoke check passes, exit 0, retaining Phase 0.8A gameplay.
- Final import, asset-test and main-smoke logs: **0 errors, 0 warnings**.
- ZIP contains exactly ten PNGs, README and completed metadata; PNG bytes checked against selected runtime hashes.

Full gameplay regressions were not repeated for this asset-only delivery. No production world placement or gameplay behavior changed. Validation logs are under ignored `tests/output/base_pack_c_*.log`.

## Review and future use

1. Inspect `base_pack_c_preview.png` at 100% and integer magnification; inspect individual transparent assets on dark and light backgrounds.
2. Review the separate footprint guide before scene placement. Keep logical footprint, canvas, image anchor and reference-cell offset distinct.
3. Open the project in Godot and inspect supplied import settings. Keep nearest filtering and repeat disabled for future Sprite2D instances.
4. Rebuild metadata/previews/ZIP with `./tools/base_pack_c/prepare_pack.ps1` using the preserved sources.
5. After import, run Godot headless with `--script res://tests/base_pack_c_test.gd`.

Assets are static single views, not a connector autotiling kit or an animated building system. The blank console screen and lamp surface contain no operational state; future labels, lighting, power and oxygen behavior belong in separately requested systems. PixelLab usage terms are referenced at `https://pixellab.ai/termsofservice`; no new license is asserted.

No additional asset pack or development phase was started.
