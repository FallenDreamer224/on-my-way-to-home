# Phase 0.1 validation and change report

Historical initial foundation report. The later approved foundation revision changes the viewport to 960 x 540, adds input declarations and Moon-first design context, and replaces movie capture with PNG-only capture. See [current validation and change report](phase_0_1_foundation_revision.md) for the current settings, tests, and manual instructions. The initial results below are retained as history, not current configuration claims.

Validated on November 14, 2026. Phase 0.1 is complete; Phase 0.2 has not started.

## Inspection

The initial project contained `project.godot`, the original Godot icon/import sidecar, `.editorconfig`, `.gitattributes`, `.gitignore`, and the workspace Godot Tools setting. There were no game scenes or scripts. The engine identified itself as **4.7.2.stable.official.ed1daf0bf**. The original configuration selected Forward Plus, Direct3D 12 on Windows, canvas-item stretching with expanding aspect, and a Jolt physics override.

The foundation changes select the Compatibility renderer, native viewport stretching with integer scaling, a 640 x 360 logical resolution, a 1280 x 720 initial window, and nearest canvas texture filtering. The project name is now `On My Way to Home`, the main scene is assigned, and startup language is English. The original icon, editor executable setting, and text-file conventions are preserved. Godot may omit settings equal to engine defaults when saving: preserved aspect ratio (`keep`) and the English fallback remain effective defaults.

## Results

| Check | Result |
| --- | --- |
| Executable version | Godot 4.7.2 stable official, verified with `--version` |
| Headless editor import | Passed; scripts/resources registered and editor initialized |
| Script syntax | Both production scripts and the development test script passed `--check-only` |
| Foundation integration | **83 checks passed** |
| Main scene, headless | Passed; ran for 10 iterations and exited normally |
| Graphical editor | Opened with OpenGL 3.3 Compatibility on the available NVIDIA GPU; exited normally after 120 iterations |
| Graphical main scene | Rendered and captured at 640 x 360; exited normally |
| Visual inspection | Development card is centered, readable, and unclipped; no missing resources |
| Native scene architecture | Entire instantiated hierarchy contains no spatial nodes; native Camera2D and screen-space CanvasLayer verified |
| Legacy configuration scan | No obsolete spatial nodes/types, Forward Plus, Direct3D 12, or Jolt overrides in production scenes/scripts/resources or project configuration |
| Asset staging | Source intake is excluded from import with `.gdignore`; manifest template parses as JSON |
| PixelLab operations | None; no assets generated or credits consumed |

**Final validation errors: 0.**

**Final validation warnings: 0.**

The integration checks exercise resource loading, scene instantiation, the main composition, each future integration point, Y-sort container configuration, camera activation, UI viewport coverage, default settings, disabled settings, hidden-screen settings, and missing-configuration handling. Release-export behavior is guarded in code with `OS.is_debug_build()`; no release export or export-template installation was needed or tested.

Logs and a visual capture are in ignored `tests/output/`. The captured frame is `tests/output/foundation00000000.png`. Use `tests/validate.ps1 -IncludeRendering` to reproduce the checks. The runner rejects a different engine version and reports script errors even when the engine process returns exit code zero.

## Environment diagnostics

The first restricted run could not access the default Godot profile directories or Windows certificate store. Validation now isolates the editor/user profile under `tests/output/profile/`, without changing the parent shell's environment. The successful run additionally had certificate-store read access. Those initial failures were environment errors, not script errors, and are excluded from the final successful run totals above. All requested project edits, profile data, logs, and captures remain inside this project. Future restricted validation may need the same certificate-store access.

## Files created or modified

| Files | Change |
| --- | --- |
| `project.godot` | Display name, main scene, pixel-art display defaults, renderer, locale, clear color; removed unused physics/driver overrides |
| `.gitignore` | Ignore generated `tests/output/` artifacts and isolated profile |
| `README.md` | Run instructions, display/configuration controls, directory map, phase boundary |
| `scenes/main.tscn` | Functional composition root |
| `scenes/world/world.tscn` | Terrain and Y-sorted entity attachment points |
| `scenes/camera/camera_rig.tscn` | Reusable native Camera2D rig |
| `scenes/ui/development_screen.tscn` | Placeholder development screen |
| `scenes/player/README.md`, `scenes/npcs/README.md`, `scenes/gameplay/README.md` | Separate domain scene contracts, without dummy implementations |
| `scripts/core/main.gd` | Typed startup configuration and screen visibility |
| `scripts/core/development_settings.gd` | Typed editable development settings Resource |
| `resources/config/development_settings.tres` | Default configuration instance |
| `docs/architecture.md` | Ownership, composition, extension boundaries |
| `docs/isometric_standards.md` | Projection, coordinates, origins, sorting, foot anchors, scaling, asset expectations |
| `docs/phase_0_1_validation.md` | This validation and change report |
| `assets/README.md` | Runtime import requirements |
| `assets/characters/README.md`, `assets/terrain/README.md`, `assets/buildings/README.md`, `assets/environment/README.md`, `assets/ui/README.md` | Category-specific intake contracts |
| `assets/pixellab/README.md` | Intake, review, provenance, promotion workflow |
| `assets/pixellab/import_manifest.example.json` | Metadata template; no generated asset record |
| `assets/pixellab/source/.gdignore` | Raw export staging import exclusion |
| `tests/foundation_test.gd` | Dependency-free integration checks |
| `tests/validate.ps1` | Reproducible validation, log inspection, optional graphical checks |
| `scripts/core/main.gd.uid`, `scripts/core/development_settings.gd.uid`, `tests/foundation_test.gd.uid` | Godot-generated script identity sidecars; retain with source |

Godot also regenerated its ignored `.godot/` cache and validation output. These are local artifacts rather than source deliverables.

## Phase 0.2 considerations

- Use an Isometric TileSet with 64 x 32 tiles, **Diamond Down** layout, and horizontal offset axis. A temporary engine probe confirmed the raw centers documented in the standards. Place the future layer at `(-32, -16)` so grid cell `(0, 0)` centers on world origin; test picking and negative coordinates through the layer's own transforms.
- Build a small test map before a full world. Verify ground seams, tall-object overlap, actor foot alignment, and Y-sort interleaving across player/NPC/building categories.
- Choose movement presentation and pixel snapping when motion is introduced. The foundation deliberately does not enable competing snapping options or camera smoothing.
- The placeholder uses Godot's built-in font. Production pixel-art typography and the final base resolution should be reviewed with representative approved artwork.
- Lossless import, mipmaps off, and sheet metadata must be checked per future asset. No image-specific imports, TileSets, SpriteFrames, collisions, navigation, saves, or input actions exist yet.
- Confirm PixelLab MCP availability only when a later explicitly authorized asset task needs it. No connection test, generation request, provider dependency, or credential is included here.
- Export presets, release packaging, and raw-source export exclusions should be introduced when a shipping target is chosen.
