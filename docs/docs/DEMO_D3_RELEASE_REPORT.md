# Demo D3 — Windows release candidate

Date: 2026-11-15. Version: **0.1.0-rc.1**. Status: **Windows x64 candidate built, packaged and tested locally; not published. Public artwork redistribution clearance remains pending.** No D4 work was started.

## Deliverables

| Artifact | Project-relative path | Bytes |
| --- | --- | ---: |
| Windows GUI release executable | `builds/windows/On-My-Way-to-Home-Demo.exe` | 109,168,640 |
| Required companion data | `builds/windows/On-My-Way-to-Home-Demo.pck` | 470,676 |
| Distribution archive | `builds/windows/On-My-Way-to-Home-Demo-Windows-x64.zip` | **39,588,412** |
| Archive checksum | `builds/windows/On-My-Way-to-Home-Demo-Windows-x64.zip.sha256` | — |
| Proposed release text | `docs/DEMO_D3_RELEASE_NOTES.md` | — |

ZIP SHA-256:

```text
ae07209805ed8e26cb15b728895f837271f220ede155e4eb170a9f2cc754e238
```

EXE SHA-256: `b60b63a49d85c93c11047f48b63034dffca65df67c21257804b695c4099a0796`.

PCK SHA-256: `b05cc6b6bc462d71b2a6231aecc4d8fbc768d81f265897b6b8e35b503cd5009a`.

The archive has exactly eight root files: the matching EXE/PCK, README.txt, RELEASE_NOTES.txt, CREDITS.txt, GODOT_LICENSE.txt, GODOT_COPYRIGHT.txt and SHA256SUMS.txt. Each was extracted and compared with its staging hash. No source repository, loose scripts, test screenshots, private configuration, logs or authoring tools are included. Compiled scripts and engine-required imported texture/class/UID data inside the PCK are runtime resources, not a copied editor cache.

## Export configuration and minimal fixes

- Engine/editor and official template: **4.7.2.stable.official.ed1daf0bf**. Windows x86_64 release template, separate PCK, GUI subsystem, no console wrapper, no code signing and no baked-in development startup arguments.
- Global export-template directory was empty. `tools/release/fetch_windows_template.mjs` fetched only the official Windows release entry and version file from the matching multi-platform template archive using HTTPS byte ranges. ZIP entry sizes and CRC32 were verified; the full 1.28 GB archive digest was not verified. No global Godot settings or template directories were changed.
- Official archive: https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz. Selected entry: `templates/windows_release_x86_64.exe`; original template SHA-256 `d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562`.
- Created `export_presets.cfg` with the project-local custom template. Explicitly included `resources/config/daily_life.json`, `resources/config/habitat_utilities.json` and `resources/data/habitat_layout.json`: these are runtime inputs that ordinary resource scanning must not omit. Excluded research, raw PixelLab sources, tests, tools, documentation and private/editor configuration.
- Added application version `0.1.0-rc.1` to `project.godot`; PE file/product version is `0.1.0.0`. Product name is On My Way to Home. Preserved Main, renderer, 960×540 integer viewport stretch, nearest filtering and 64×32 terrain.
- No gameplay or source-art repair was needed for export. No unresolved class reference was reproduced. There is no menu/New Game UI; Main remains the intentional direct entry and `GameEntry.new_game()` remains the future construction boundary. Menu-navigation and New Game button tests are **not applicable**, not passed features.
- Existing unrelated `On My Way To Home.exe/.pck` files in the Windows output folder were preserved and excluded from this ZIP.

## Validation

All checks below were executed. Private logs and staging live in ignored `tests/output/release_d3_private/`; they are not shipped.

### Source and headless checks

| Check | Result / evidence |
| --- | --- |
| Focused actual Main/class-resolution preflight | **PASS, 23 checks**; `preflight_startup.log` |
| Existing full source validation immediately preceding D3 | **PASS, 126 engine invocations, 0 errors and 0 warnings**, including rendered regressions; `tests/output/release_d2_5_private/godot_validation.log`. Not repeated after export-only changes. |
| Source-only isolated-copy import/editor/Main and high-value tests | **PASS**; `tests/output/release_d2_5_private/public_source_validation.json` |
| Release export | **PASS, exit 0**, no reported errors/warnings; `export.log` |
| Actual EXE in separate EXE/PCK-only folder | **PASS, exit 0**, headless startup and bounded shutdown; `standalone_startup.log` |
| Existing D0 test against the exported PCK | **PASS, 115 checks, exit 0**; `packed_route.log` |
| Packed-file audit | **PASS, 387 files, no forbidden paths**, all three required JSON inputs present; `packed_audit.json`. Application version and direct Main entry verified. Bundled fallback font: Open Sans SemiBold. |
| ZIP integrity | **PASS**, exact eight-file allowlist and all extracted SHA-256 hashes match; `package_validation.json` |
| Actual final ZIP's extracted EXE | **PASS, exit 0, 0 errors, 0 warnings**; `extracted_startup.log` and `extracted_validation.json` |
| Executable headers | **PASS**, PE machine `0x8664` (x64), subsystem `2` (Windows GUI) |

The PCK route uses the matching Godot executable as a test harness with `--main-pack`; it is not misrepresented as an external script executed by the release EXE. The release template did not execute `--script` probes, so those attempted probes are not counted as passed tests. Initial sandboxed helper attempts also timed out or could not create a log; rerunning the actual executable with the permitted process access succeeded. These harness failures were not fixed by changing game code.

### Graphical checks

- Actual standalone **release EXE**, no development startup arguments: Moon terrain, astronaut, Chiwis, HUD and interaction prompt rendered at the default 960×540 window. A mouse interaction collected a sample and removed its world pickup. Closing the window exited its process normally.
- Actual standalone **release EXE with `--fullscreen`**: 1920×1080 presentation showed integer 2× scaling and sharp pixels. Alt+F4 exited normally. Fullscreen is available through a shortcut argument; no in-game display-settings screen/hotkey was added.
- Existing D0 route against the **exported PCK with OpenGL rendering**: **PASS, 115 checks, exit 0**, NVIDIA GeForce RTX 3050 Laptop GPU / OpenGL 3.3 compatibility; `packed_rendered_route.log`. This covers controller movement, companion routing, both modes, inventory, real airlock portals, interior state, powered science activity and fresh-session ownership. The prior source screenshot-capture run had 119 checks; the packed run did not enable capture and correctly reports 115.
- Desktop activity interrupted some key-injection attempts, and letter/Tab injection did not establish a reliable manual keyboard result. Do not claim a complete human keyboard playthrough of the release EXE. Controller/key behavior is supported by the packed automated route; a final human playthrough on a clean second Windows machine is recommended before publication.

## Included scope and limitations

Existing Moon-only exploration, astronaut/Chiwis, Player/Management cameras, static safety perimeter, resource pickups/inventory, placeholder rooms, interlocked airlock, utilities and daily-life/greenhouse prototypes remain intact. The short suggested activity is collect a Lunar Sample, enter the habitat safely, then complete the powered science examination. The existing routine can complete, but there is no objective tracker, ending screen or main menu. No new gameplay systems, source artwork, PixelLab jobs, audio or Mars content were added.

There is no disk save/load or sprint input. Several exterior areas are reservations rather than assembled final buildings. Interiors and status readouts remain development placeholders. Airlock/utility/growth models are explicit game abstractions, not complete validated NASA hardware simulations or medical predictions. NASA/JPL do not endorse the project. Windows compatibility is tested on the present machine only; broad minimum hardware/OS claims are not established. The executable is unsigned and retains the temporary Godot icon.

## Publication readiness

**Technical local RC: produced. GitHub publication: on hold.** The package contains matching official Godot license/third-party notices and credits, but public redistribution rights for the independently supplied character and regolith artwork remain unconfirmed in existing provenance. Resolve that existing art-clearance issue, review temporary logo use/branding and perform the final clean-machine human playthrough before public upload. See `CREDITS.md` and `docs/THIRD_PARTY_REVIEW.md`. A project-wide source license has not been chosen; source publication is a separate decision. No GitHub upload, Git initialization, commit, tag or history modification was performed.

## Files changed for D3

- Created `export_presets.cfg`, `tools/release/fetch_windows_template.mjs`, `docs/DEMO_D3_RELEASE_NOTES.md` and this report.
- Updated only the application version in `project.godot`; updated `AGENTS.md`, README.md and CHANGELOG.md for the local RC.
- Created ignored EXE/PCK/ZIP/checksum outputs under `builds/windows/`, plus project-local private template, probe, audit, staging and validation artifacts under `tests/output/release_d3_private/`.
- D2.5 documentation/ignore/audit/test changes already present were preserved; no additional unrelated cleanup was performed in D3.

## Reproduce the export

Run `node tools/release/fetch_windows_template.mjs` from the project root if the local template is absent. Then use the Godot 4.7.2 executable:

```powershell
& $GodotPath --headless --path . --export-release 'Windows Demo RC' 'builds/windows/On-My-Way-to-Home-Demo.exe'
```

The template helper records provenance in ignored output. Preserve the matching EXE/PCK together. Use an explicit package allowlist, include the exact engine notices, extract and hash-check every file, and retest the extracted EXE. Developer flags used for bounded validation are not embedded in the player package.
