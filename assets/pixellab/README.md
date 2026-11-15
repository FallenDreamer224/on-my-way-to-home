# PixelLab asset intake

This directory prepares an intake pipeline only. **Do not generate assets, submit jobs, or consume PixelLab credits without explicit authorization.** No PixelLab calls are needed to validate Phase 0.1. MCP availability must be checked when a future authorized request actually needs it; this phase makes no connection/credential claim.

1. After an authorized generation, store original output and accompanying metadata under `source/<asset_id>/`. The `source/.gdignore` marker prevents raw exports, duplicate sheets, and metadata from entering Godot's import scan. This does not by itself exclude files from version control or future exports; configure those deliberately when shipping.
2. Copy `import_manifest.example.json` alongside that source and fill it with the actual generation ID, prompt, source/provider, license or usage terms, native size, intended category, and anchors/layout. The example is a template, not an asset record. Never include API keys, credentials, or personal paths.
3. Review projection, palette, native scale, alpha edges, consistent feet, direction mapping, and sheet layout against `docs/isometric_standards.md`.
4. Promote the approved runtime PNG to `assets/characters/`, `terrain/`, `buildings/`, `environment/`, or `ui/`. Use lowercase snake_case names, such as `survivor_idle_south.png`. Keep original provenance with the source.
5. Import in Godot, check lossless/no-mipmap settings and nearest filtering, then add the future SpriteFrames/TileSet/AtlasTexture resource under an appropriate `resources/` domain. Preserve transparent padding and document any texture origin adjustment.
6. Validate the new resource in a small development scene before integrating it into gameplay. Raw staging can be removed from release exports when export presets are introduced.

No generated art, provider SDK, credentials, jobs, or external dependencies are included in Phase 0.1.
