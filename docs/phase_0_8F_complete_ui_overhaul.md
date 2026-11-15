# Phase 0.8F — UI recovery and completion

Date: 2026-11-15. Outcome: **COMPLETE WITH LIMITATIONS**.

The inherited interface is operational, the application now starts at its existing title menu, and all requested regression areas have passing final results. No gameplay system was rebuilt. Continue cannot resume a saved session because the project has no disk-save format or loader; its disabled state is intentional. Two failed provider icon jobs use explicit existing-art fallbacks. No new generation, export, publication, commit or Phase 0.8G work was performed.

## Takeover and preservation

- Branch: `dev/phase-0.8f-ui-overhaul`.
- Inherited HEAD: `b4f00e10384fdde97423ba90fa7481dbbee03e1d`; the tracked working tree was clean at takeover. The handover implementation was already present in this checkout, rather than an uncommitted patch needing reconstruction.
- Protected demo reference: lightweight tag `Alpha` → `2942b0502d1a53a78651044319bbd86392497198`. Both HEAD and tag remain unchanged. No branch switch, reset, commit, push or tag modification occurred.
- No release files were present under `builds/` in this takeover snapshot. This continuation did not recreate, delete or overwrite demo binaries. Source preservation is verified against the existing tag; availability of an external/distributed demo was not checked.
- No `CLAUDE.md` exists. Read `AGENTS.md`, `docs/CLAUDE_DEVELOPMENT_HANDOVER.md`, existing implementation/tests and the dated scientific/art references.
- Godot was open with this project. The saved scene tab showed no unsaved marker; the user saved and closed the editor before configuration changes. No editor was killed and no unsaved state was discarded. Four Claude processes were present, but repeated critical-file hashes showed no concurrent source writes during takeover. These processes were left alone.
- `scenes/main.tscn` retains its exact takeover SHA-256. All **199 pre-existing PNG/font files** retain their exact takeover hashes, including character animations, terrain, Packs A–E and inherited Pack F textures/fonts. External originals were not modified.

Private evidence: `tests/output/phase_0_8f_recovery/baseline.json` and `preservation.json`. These contain local diagnostics and are not release content.

## Inherited implementation

The following was present before Codex edits, consistent with the handover:

| Area | Inherited implementation |
| --- | --- |
| UI kit | UiKit, UiMotion, MissionPanel, KeyHint, TelemetryIndicator, standard/high-contrast Mission OS themes |
| Fonts | Departure Mono regular, Silkscreen regular/bold, import settings and OFL notices |
| HUD | Location/mode chips, actual utility/safety telemetry, explicitly unavailable suit/physiology fields, objective card, prompts and notifications |
| Companion | ChiwisDialogue queue/history and ChiwisCommentary adapters; portrait/dialogue card and comms log |
| Management | Read-only categorized dashboard, equipment inspection and bindings to existing utilities/greenhouse/inventory/objectives |
| Inventory | Updated slots, icons, selection/detail panel and filters using the existing RuntimeInventory |
| Application | AppRoot, MainMenu, animated lunar diorama/starfield, settings, credits, mission menu and confirmation dialog |
| Research UI | EquipmentRecord/EquipmentDatabase, curated map/generator and 26-record resource from the existing 69-entry registry |
| Objectives | Definition Resources and tracker observing the existing sample → habitat → examination route and optional interactions |
| Artwork | Fifteen selected Pack F icons and two menu illustrations, plus metadata for eleven unresolved icon selections |
| Tests | The 290-line `ui_foundation_test.gd` and `phase_0_8f_capture.gd`, alongside the earlier regression suites |

The first newly executed UI foundation run parsed and initialized successfully but failed its dashboard-wheel isolation assertion. The previous capture result was treated as historical evidence, not proof of completion.

## Work completed by Codex

1. **Repaired actual startup wiring.** `project.godot` still targeted gameplay Main. It now targets the already-implemented `scenes/app_root.tscn`. Main remains the unchanged reusable gameplay session. No replacement menu was created.
2. **Stopped dashboard scroll leakage.** Disabled forced scroll propagation on ManagementDashboard so an unconsumed wheel event cannot zoom the world behind the dock. Added ellipsis/tooltips for long equipment names while preserving full inspection details.
3. **Bounded urgent dialogue interruption.** When a full queue is interrupted, remove the weakest waiting line before retaining interrupted tutorial guidance. Boundary notices now outrank preliminary warnings, so the boundary explanation appears immediately instead of waiting behind the earlier caution. Existing static perimeter/cooldowns remain intact.
4. **Repaired duplicate preference bindings.** Conflicting loaded keys are reassigned from unused defaults, preserving unique controls and the reserved Escape exit path.
5. **Applied reduced motion to an already-running title scene.** The diorama subtree and its bound patrol/twinkle tweens stop processing when the preference changes; menu/settings controls remain responsive as siblings. Gameplay animations were not changed.
6. **Recovered nine existing icon candidates.** Native PNGs were reviewed and copied unchanged; completed jobs were retrieved, never regenerated. Added explicit fallbacks for the two provider failures.
7. **Completed Pack F provenance/import validation.** Added an official import manifest and source mirrors. Disabled Godot alpha-border rewriting on its 26 texture imports after exact RGBA comparisons exposed hidden-pixel changes. Source PNGs were preserved; final imported images now match exactly.
8. **Completed regression coverage.** Added focused menu/settings/dialogue/database tests and integrated them, Pack F validation, database consistency and the capture runner into `tests/validate.ps1`.
9. **Updated intentional UI test contracts.** Old HUD paths now use the exposed HUD bindings; EVA assertions check the new companion dialogue sink; TileSet integrity ignores only editor-added UID annotations while hashing all remaining content. World-jitter checks retain full UI captures and compare world pixels with animated UI excluded. Fullscreen synthetic mouse events now convert logical control positions to native window pixels. Meaningful movement, collision, inventory, mode, source-pixel and input-isolation assertions remain.
10. **Restored scientific reference paths.** Copied the three science documents and their 0.8R report byte-for-byte from `docs/docs/` to their existing required canonical paths. The originals remain. Added `.gdignore` only to the archived subtree to prevent duplicated screenshot UIDs from entering Godot's scan.

## Assets and provenance

See [ASSET_INVENTORY.md](ASSET_INVENTORY.md) for the complete local PNG list, native canvases, actual character clip counts/FPS, font notices, usage and source records.

| Pack F accounting | Count |
| --- | ---: |
| Registered icon jobs | 26 |
| Selected icons inherited | 15 |
| Completed icon candidates recovered in this continuation | 9 |
| Unique Pack F runtime icon PNGs now integrated | **24** |
| Inherited menu illustrations retained | 2 |
| Failed jobs with explicit approved-art fallback | 2 |
| New generation jobs / paid transformations requested | **0** |

Recovered candidate zero for Pressure, Solar, Habitat, Greens Seed, Fresh Greens, Dry Ration, Completed Objective, Database and Communications. The contact sheet and in-game views were inspected. Each icon is 32×32 with binary alpha and transparent padding. Helmet's old job and Prepared Meal's old job returned provider failures; Helmet resolves to Pack A `health`, Prepared Meal to Pack A `supply_tool`. These aliases are not falsely counted as newly generated unique icons.

`art/imports/ui_pack_f.json` identifies all 26 real textures, job/candidate IDs, prompt/request records, native dimensions, source/runtime paths and hashes. Inherited runtime selections have byte-identical source mirrors explicitly labeled as such; remote original encoding was not independently re-downloaded for those selections. Existing generation request records remain with their historical authorization/cost information. Reading a completed result did not submit another job.

Existing character sheets, ground atlas, props/base/lander images, UI Pack A and font binaries were reused. Main-menu composition is presentation only; it creates no new exterior building/vehicle gameplay. No original Pixelorama art or external asset file was changed.

## Scientific data integrity

- Canonical registry remains unchanged: version 1.0.0, 69 entries, 60 source records, 16 categories, evidence cutoff 2026-11-15.
- Runtime subset remains 26 records relevant to the represented Moon tutorial. No Mars equipment/gameplay expansion was added.
- Generator `--check` and focused tests compare IDs, evidence statuses, testing environments, functions, limitations, official source URLs, catalog version and review date with the registry. Authored `game_usage` text remains separate from factual fields and resource-balancing JSON.
- UI distinguishes operational heritage, bounded demonstrations, development and research. The operational disclaimer explicitly rejects an inference of lunar deployment. TRLs are not invented.
- Restored science documents remain byte-identical to their archived copies. No source status, scientific date or NASA specification was revised or re-researched in this UI recovery.
- Registry/document consistency and twelve invalid-fixture rejection checks pass. Eight existing evidence warnings remain: six unconfirmed source dates, one publication/update date discrepancy and null achieved TRLs. These uncertainties remain visible rather than being filled with guesses.

## Validation executed

Engine: **Godot 4.7.2.stable.official.ed1daf0bf**. Graphical checks used OpenGL 3.3 Compatibility on NVIDIA GeForce RTX 3050 Laptop GPU. Isolated profiles and logs stayed under project `tests/output/`.

The standard `tests/validate.ps1 -IncludeRendering` run passed import, script parsing, all headless suites and the early rendered suites, then stopped at the obsolete whole-frame stationary assertion in `modes_rendered`. After correcting that test, its affected step and the entire remaining rendered tail were run explicitly. A fullscreen synthetic-coordinate defect in the test was then corrected and rerun in both display modes. Passed expensive suites were not restarted unnecessarily. Thus the first monolithic run's nonzero exit is preserved in its log; it is not mislabeled as a clean uninterrupted pass. The combined final checkpoint covers **162 distinct scheduled engine steps, including 112 script-parse steps, with zero remaining failures**. Final corrected Godot runs report no warnings. All 35 JSON files under art/resources/assets parse successfully. The science check's eight evidence warnings are separate from engine warnings.

| Validation area | Final result |
| --- | --- |
| All runtime/test GDScript parse steps | PASS |
| Cache-free copied-source import/editor/class/startup | PASS: four steps, exit 0, no errors/warnings |
| Main class-resolution / complete scene composition | PASS: 23 checks |
| Foundation | PASS: 2,213 headless / 2,215 rendered checks |
| Astronaut | PASS: 234 headless / 244 rendered |
| Chiwis | PASS: 44 headless / 46 rendered |
| Run clips | PASS: 903 headless / 911 rendered |
| Isometric world | PASS: 33,961 |
| Moon terrain | PASS: 3,250 headless / 3,254 rendered; raster reports zero gaps/overlaps |
| Lunar tutorial | PASS: 9,261 headless and rendered |
| Player camera / gameplay modes | PASS: 49 camera checks; 93 headless / 99 rendered / 93 fullscreen mode checks |
| Inventory / interaction integration | PASS: 38 data checks; 95 headless / 101 rendered integration checks |
| Props integration | PASS: 108 headless / 112 rendered; Pack B source/import checks pass |
| EVA safety | PASS: 405 headless and rendered |
| Habitat | PASS: 971 headless / 975 rendered |
| Utility conservation / integration | PASS: 922 model checks; 136 headless / 139 rendered / 136 fullscreen terminal checks |
| Daily life / greenhouse | PASS: 304 headless / 306 rendered |
| UI foundation | PASS: 331 headless / **351 windowed / 335 fullscreen** |
| New Phase F focused suite | PASS: **170 headless / 172 rendered**, including actual fullscreen/windowed settings |
| Phase F graphical capture runner | PASS: **65 checks**, 26 native 960×540 captures; baseline count retained |
| Art Packs A–E / Pixelorama | PASS: all existing source/import suites; 696 Pixelorama and 3,778 terrain-expansion checks |
| Pack F | PASS: 24 icons, two illustrations, two resolvable fallbacks; exact RGBA, hash, dimensions, alpha and no mipmaps |
| Equipment database generator | PASS: exact 26-record match |
| Science registry/docs | PASS: 69/60/16 totals; 12 invalid-fixture checks; eight documented evidence warnings |
| Settings process restart | PASS: saved in one Godot process and restored in another, including display/accessibility/binding preferences |
| Actual configured menu Quit action | PASS: native Enter press/release exits the configured application normally |

The new focused suite covers UI initialization, unavailable telemetry through the foundation suite, conflicting settings, unique keybindings, persistence, reduced motion, dialogue priority/capacity/cooldown/hold/history, database facts/statuses, all icon resolutions, main-menu native New Game, duplicate-session protection, settings/credits pages, modal pause/resume, UI scale bounds, fresh inventory, invalid save-like files and return flow. Notice priority and inventory/dashboard focus/input isolation remain exercised by the expanded foundation suite. No manual physical-keyboard playthrough is implied by synthesized input tests.

Evidence: `tests/output/phase_0_8f_recovery/final_validation_summary.json`, `full_validation.log`, `results.jsonl`, `clean_start.log`, `science_validation.log` and per-step logs; normal validator logs also remain in `tests/output/`. Capture files remain in `tests/output/phase_0_8f/`.

### Images inspected

Inspected full-size captures 03 (expanded status), 04 (inventory), 05 (Chiwis caution), 07 (management equipment), 13 (settings controls), 14 (database), 15 (comms), 17 (utility terminal), 18 (greenhouse), 19 (high contrast), 20 (125% interface), 21 (main menu), 22 (menu settings), 23 (credits) and 26 (confirmation). The menu/diorama, astronaut, Chiwis, native pixel edges, telemetry labeling, modal bounds and text layout are readable at 960×540. Long names intentionally use ellipsis, tooltips and detail panels. Off-screen database/credits/controls content is in scroll containers. Final capture generation was rerun after the motion fix.

## Files created or changed

| Files / group | Change |
| --- | --- |
| `project.godot` | Only startup scene changed to existing AppRoot |
| `scripts/ui/management_dashboard.gd` | Scroll isolation and name ellipsis/tooltips |
| `scripts/companions/chiwis_dialogue.gd` | Bounded interruption path |
| `scripts/companions/chiwis_commentary.gd` | Boundary-warning priority escalation |
| `scripts/core/app_settings.gd` | Unique loaded bindings |
| `scripts/menu/main_menu.gd` | Live reduced-motion handling for inherited backdrop |
| `scripts/ui/kit/ui_icons.gd` | Explicit failed-job fallback aliases |
| `tests/phase_0_8f_test.gd` and UID | New focused integration coverage |
| `tests/ui_foundation_test.gd` | Fullscreen synthetic-pointer transform |
| `tests/gameplay_modes_test.gd` | Current HUD access and isolated world stability check |
| `tests/eva_safety_test.gd` | Current companion sink and warning visibility assertions |
| `tests/terrain_pack_e_test.gd` | Hash all authored TileSet content while ignoring only saved UIDs |
| `tests/foundation_test.gd` | Expected application startup scene |
| `tests/validate.ps1` | New focused/asset/database/capture steps |
| `tools/ui/validate_pack_f.gd` and UID | Reusable import/provenance checker |
| `art/imports/ui_pack_f.json` | 26 complete texture records and two fallback records |
| `assets/pixellab/source/ui_pack_f/generation_jobs.json` | Recovered selections and failed-job status/fallback records |
| Nine `assets/ui/ui_pack_f/icon_*.png` files and imports | Pressure, Solar, Habitat, Greens Seed, Fresh Greens, Dry Ration, Check, Database, Comms |
| 26 Pack F `.png.import` files | Disable alpha-border pixel rewriting; retain native lossless imports |
| 26 `assets/pixellab/source/ui_pack_f/*_candidate_*.png` files | Original recovered candidate copies and inherited native selection mirrors; all listed in import manifest/inventory |
| `docs/SCIENCE_BIBLE.md`, `NASA_TECHNOLOGY_CATALOG.md`, `SCIENTIFIC_GAMEPLAY_RULES.md`, `phase_0_8R_report.md` | Byte-identical canonical copies of archived documents |
| `docs/docs/.gdignore` | Exclude archived duplicate screenshot imports, preserve archived documents |
| `docs/ASSET_INVENTORY.md`, this report | Asset list and completion evidence |
| `AGENTS.md` | Current Phase F entry point, preservation, fallbacks and phase boundary instructions |
| Ignored `tests/output/phase_0_8f_recovery/` | Baseline, diagnostic probes/helpers, candidate review, logs and final summaries |

## Remaining limitations and next-phase readiness

- **Continue/load:** no compatible save format or loader exists. Continue is disabled; an invalid save-like file cannot enable it. A valid-save resume path was not tested or implemented. Implementing whole-game persistence is a separately scoped system, not a menu repair.
- **Artwork:** Helmet and Prepared Meal have suitable functional aliases rather than unique generated art. No outstanding PixelLab job was restarted. Public code/art licensing decisions remain separate.
- **Scientific scope:** six suit/physiology fields remain explicitly unavailable; cabin values are model estimates. The interface adds no medicine, suit supplies, new NASA hardware or planetary gameplay. Historical science references mentioning later concepts do not activate them.
- **Presentation:** interiors remain placeholders, the management dashboard is read-only, and long equipment/reference names use accessible scrolling/ellipsis/details. The non-default 125%/150% accessibility UI scales retain nearest filtering but change displayed pixel proportions; native 100% is the sharpness reference.
- **Testing:** validation was on the present Windows/GPU setup, with synthesized input and inspected captures. No fresh standalone distribution was built, no remote publication state was queried and no broad hardware-support claim is made.

There are no remaining known P0/P1 UI regressions in the executed checks. The continuation is ready for review and a separately authorized next assignment. Phase 0.8G was not started.
