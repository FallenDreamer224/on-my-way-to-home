# Claude Development Handover — Full-Development Resumption Audit

Audit date: 2026-11-15. Engine verified: **Godot 4.7.2.stable.official.ed1daf0bf**. Scope: an audit only. This document records what exists, what was executed and what remains. **No features, artwork, PixelLab jobs, commits, branches, tags or pushes were created, and no existing file was changed.** This file is the only tracked-tree addition. Running the validators regenerated only ignored output under `tests/output/` and the `.godot` import cache.

Baseline: roadmap completed through **Phase 0.8E2**, followed by the startup repair, demo phases D0, D2.5 and D3 (Windows x64 RC `0.1.0-rc.1`). The main roadmap has been suspended since 0.8E2. Its next named boundary, "Phase 0.8F1", was never defined beyond its name.

---

## 1. Repository and demo preservation

### Git state

| Item | Finding |
| --- | --- |
| Branches | `main` only (local), tracking `origin/main` |
| Local HEAD | `2942b05` (merge), **one commit behind** `origin/main` (`9dd8aa9`, a README-only edit: "Remove tested environment and limitations section") |
| Tags | `Alpha`, a lightweight tag on `2942b05` |
| History | 8 commits. The earliest is `9529b2a Initial commit`. Development before the public repository has no Git history. |
| Uncommitted | `M export_presets.cfg`, `M project.godot`, untracked `docs/docs/`, untracked `docs/project_file_inventory.*` |

### Where the completed demo lives

- **Source snapshot:** tag `Alpha` (`2942b05`) contains the D3 configuration. It has `config/version="0.1.0-rc.1"`, the `Windows Demo RC` preset and `tools/release/fetch_windows_template.mjs`. This is the de facto demo-release commit. It is a *lightweight* tag with no annotation identifying it as D3.
- **Release binaries** are in ignored `builds/windows/`. Hashes were verified in this audit:

| File | Recorded D3 SHA-256 | Current | Status |
| --- | --- | --- | --- |
| `On-My-Way-to-Home-Demo.exe` | `b60b63a4…0796` | `b60b63a4…0796` | **Intact** |
| `On-My-Way-to-Home-Demo.pck` | `b05cc6b6…009a` | `b05cc6b6…009a` | **Intact** |
| `On-My-Way-to-Home-Demo-Windows-x64.zip` | `ae072098…e238` (8 files, 39,588,412 B) | `aa248635…1eba` (7 files, 37,359,324 B) | **Replaced at 09:23. Does not match the recorded RC.** |

  The current ZIP has no `CREDITS.txt` and no `RELEASE_NOTES.txt`. Its `README.txt` and `SHA256SUMS.txt` differ from the RC, and the stale `.zip.sha256` file still lists the old hash. **The exact original eight-file package is intact** in ignored `tests/output/release_d3_private/package/` (and `extracted/`), so the RC ZIP can be rebuilt byte-for-byte from those files.
- An unrelated **Linux export** (`builds/windows/On My Way To Home.x86_64` + `.pck`, 1.9 MB PCK, 09:38) was produced from the modified, unfiltered preset. It sits in the Windows folder. It is not part of the RC.

### Uncommitted changes that affect the demo

1. **`export_presets.cfg`**: the D3 `Windows Demo RC` preset has been **overwritten** in the working tree. It is now a generic `On My Way To Home-Test` preset with no include/exclude filters, no custom template, no version or product metadata and no icon. A Linux preset was also added. An export from this preset would pack research, docs, tests and raw PixelLab sources, which D3 explicitly excluded. The original preset is still recoverable from `Alpha`.
2. **`project.godot`**: `config/version="0.1.0-rc.1"` was removed.

These look like editor-side test-export experiments. They were **left untouched**. Their owner has to decide whether to keep them.

### Documentation relocation (important)

Commit `c0213f8` deleted 33 documents from `docs/`: all phase reports, demo reports, the Science Bible, the NASA Technology Catalog, the Scientific Gameplay Rules and the asset-pack reports. Byte-identical copies of every one of them now exist in the **untracked** `docs/docs/` folder, verified with `cmp` against `c0213f8^`. Nothing is lost, but:

- `AGENTS.md`, `README.md`, `art/` manifests and validators reference the original `docs/…` paths. Those references are now broken.
- `node tools/research/validate_science_catalog.mjs --self-test` **fails** because of this (see §4).
- `docs/docs/images/*.png.import` duplicate the UIDs of `docs/images/*`. This produces Godot **UID duplicate warnings** (see §4).
- `docs/DEMO_GITHUB_CLEANUP_REPORT.md`, which AGENTS.md and README require reading, **does not exist** in the tree, in `docs/docs/` or anywhere in Git history.
- `docs/project_file_inventory.csv` was auto-imported by Godot as a **translation CSV**, which generated three untracked `.translation` files. Godot will also try to include them in exports.

### Recommended preservation actions (not performed; each needs authorization)

1. Rebuild the exact RC ZIP from `tests/output/release_d3_private/package/`, or at least rename the current ZIP so it is not mistaken for the RC. Copy the EXE, PCK and ZIP to durable storage outside ignored folders, or attach them to a private GitHub release. Ignored folders are one clean-up away from deletion.
2. Create an **annotated** tag, for example `demo-d3-rc1`, on `2942b05`. Optionally create a `release/demo-d3` branch there too.
3. Do resumed development on a separate branch (for example `develop`, or one branch per phase) after pulling `origin/main`. Keep `main` or the tag as the demo reference.
4. Decide where the docs should live. Either restore them to `docs/` (simplest, and it fixes every reference) or keep them out of the public repository. In the second case, update AGENTS.md and the validators, and add a `.gdignore` to whichever docs folder holds images or CSVs.
5. Decide whether the working-tree `export_presets.cfg` and `project.godot` changes are intentional. If not, restore them from `Alpha`.

---

## 2. PixelLab MCP

`get_balance` **succeeded**. Authentication works.

- Subscription: **active, Tier 2 (Pixel Artisan)**.
- Generations: **4,073.55 remaining** of 5,000 this cycle (926.45 used). The cycle resets on **2026-12-14**.
- Credits (USD fallback): **$0.00**.

No generation, job or other billable call was made.

---

## 3. Functional audit

Status labels: **Complete** means it works as its scoped phase defined it and is validated. **Partial** means a usable foundation with explicit gaps. **Missing** means nothing is implemented. **Broken** means it exists but fails. No runtime gameplay system is broken. The broken items are all repository or tooling items.

| System | Status | Actual implementation | Gaps |
| --- | --- | --- | --- |
| Astronaut | **Complete** | `CharacterBody2D`, normalized 8-direction walking, full-foot terrain sweep, modal/mode input gating, reparenting between rooms (`scripts/player/`) | No sprint, health or suit state |
| Chiwis | **Complete** (basic) | IDLE/FOLLOWING/WAITING, direct sweep + BFS terrain routing, interior parking clear of stations, retained across portals (`scripts/companions/`) | No commands; does not auto-select run clips |
| Walk animations | **Complete** | 8 idle + 8 walk clips per character from the original Pixelorama sources, measured anchors (`resources/characters/`) | — |
| Run animations | **Partial** | 8 run clips per character imported and validated (911 rendered checks) | **No sprint input or gameplay**; clips are unused at runtime |
| Lunar terrain | **Complete** | 40×40 `LunarTutorialRegion`, 1,600 native 64×32 cells, regolith atlas with render-only variants, logical kinds separate from art. The 12×12 fixture is retained. | Terrain Pack E overlays/floors (13 components) are imported but **not used at runtime** |
| Moon exploration | **Partial** | Walkable perimeter, static EVA warning/boundary zones with Chiwis notices, 4 authored pickups | Small content set; zone reservations are outlines and labels only |
| Player / Base Management modes | **Complete** (camera layer) | Tab switching, pixel-snapped player camera, management pan and discrete zoom, bounds per location | Management *gameplay* (construction, inspection overlays) is **missing** |
| Inventory & interactions | **Complete** | Astronaut-owned 20-slot `RuntimeInventory`, stacking, exact partial pickup, nearest-target detector, E/left-click, modal window | No item use, crafting or equipment |
| Moon base exteriors | **Partial** | Habitat entry marker at cell (-8, 0), annotated reservations (`LunarSiteLayout`) | Base Pack C (10 structures) and Lander Pack D (4 images) are imported and validated but **not placed in the map**; no exterior hull art in production |
| Base interiors | **Partial** | 9 reusable cutaway rooms, 260 connected cells, 18 stations, walls, collision, retained room state (`resources/data/habitat_layout.json`) | All visuals are development placeholders |
| Airlock transitions | **Partial** | Two-hatch interlock: seal, suit/dust inspection, pressure match, `PlayerSession.transition_blocked` gating, same actors reparented | Pressure is a discrete presentation state; no gas volume or energy coupling to utilities |
| Greenhouse & daily life | **Partial** | 2 trays, finite cargo seeds and rations, utility-dispatched lights, water to wastewater, partial harvest, timed routines including the powered science exam | Growth/portion values are game abstractions; no plant O₂, diet or physiology; placeholder visuals |
| Habitat utilities | **Partial** | `UtilityModel` with finite kg stores, C/O/H/N balance, Wh/J ledgers, priorities, alarms, terminals, versioned in-memory snapshot/restore | Solar is a configured scenario source; dev **Test fault / sunlight** controls are still reachable by players |
| Main menu | **Missing** | Only the `GameEntry.new_game()` construction boundary exists. Main is the direct startup scene. | No menu, New Game, restart, quit, settings or completion screen. Roadmap item 2 is "create", not "improve". |
| UI / HUD | **Partial** | `GameUI`/`GameHUD` with mode/hint/prompt/notifications, inventory, utility and daily-life panels, shared development theme | Six **status fields are empty placeholders**; no objective tracker; UI Pack A (23 textures) is imported but **not integrated**; no final typography |
| Scientific equipment | **Partial** | Science station runs a powered sample examination; utility stations (ECLSS/water/power) are inspectable. The research registry has 69 entries, 60 sources and 16 categories (research-only, excluded from runtime). | No equipment art; no data-unlock or research gameplay. The README's "unlock NASA data" premise is **not implemented**. |
| Save/load | **Missing** (foundation only) | `UtilityModel`/`UtilityService`/`DailyLife.restore_state()` provide versioned, validated **in-memory** snapshots | No disk save, no `user://` files, no inventory/world/room serialization |
| Audio | **Missing** (by rule) | — | Prohibited until authorized |

### Broken (repository/tooling level)

1. `validate_science_catalog.mjs` fails because the science docs were relocated to `docs/docs/`.
2. Godot UID duplicate warnings come from `docs/docs/images/*.import`.
3. The D3 ZIP no longer matches its recorded hash.
4. The working-tree export preset no longer reproduces the RC.
5. AGENTS.md/README links and the required `DEMO_GITHUB_CLEANUP_REPORT.md` are missing.

---

## 4. Validation executed in this audit

Everything below was actually run on 2026-11-15 on this machine (Windows 11, NVIDIA RTX 3050 Laptop GPU, OpenGL 3.3 Compatibility).

### `tests/validate.ps1 -IncludeRendering`

**126 engine invocations, all exit code 0. Errors: 0. Warnings: 6. Final line: `PASS: Project validation complete.`**

- Every production and test GDScript passed `--check-only` parsing.
- All 6 warnings are the same two `UID duplicate detected between res://docs/images/… and res://docs/docs/images/…` messages, repeated in the import, headless-editor and graphical-editor steps. They are **caused by the untracked `docs/docs/` copy, not by game code**. D0 recorded 0 warnings, so this is a regression in the working tree.

| Suite | Headless | Rendered / fullscreen |
| --- | ---: | ---: |
| Class resolution / startup | 23 | — |
| D0 demo route + fresh session | 115 | 119 |
| Foundation / Main | 640 | 642 |
| Isometric world | 33,961 | — |
| Moon terrain | 3,250 | 3,254 |
| Lunar tutorial region | 9,261 | 9,261 |
| EVA safety | 405 | 405 |
| Player camera | 49 | — |
| Gameplay modes | 93 | 99 / 93 |
| Astronaut | 234 | 244 |
| Chiwis | 44 | 46 |
| Pixelorama assets | 696 | — |
| Run animations | 903 | 911 |
| Inventory | 38 | — |
| Interaction/inventory | 95 | 101 |
| Props Pack B | pass (10 props, exact RGBA) | — |
| Prop integration | 108 | 112 |
| UI foundation | 148 | 170 / 152 |
| Habitat/interiors | 971 | 975 |
| Utilities (conservation/failure) | 922 | — |
| Utility integration | 136 | 139 / 136 |
| Daily life | 304 | 306 |

### Asset-pack tests (run separately; `validate.ps1` only parses them)

| Test | Exit | Result |
| --- | --- | --- |
| `base_pack_c_test.gd` | 0 | PASS: ten base assets, exact native RGBA, valid contact offsets and footprints |
| `lander_pack_d_test.gd` | 0 | PASS: four PNGs, anchors, ramp connection, 4×4 guides |
| `terrain_pack_e_test.gd` | 0 | PASS: 3,778 checks |
| `ui_pack_a_test.gd` | 0 | PASS: 23 textures, exact RGBA, native dimensions |

Logs are in `tests/output/handover_audit/`. Consider adding these four tests to `validate.ps1`. It currently never executes them.

### `tests/validate_clean_start.ps1`

**PASS.** Four steps (uncached import, editor quit, class resolution, Main), each with exit 0, no errors and 0 warnings. Evidence: `tests/output/clean_start_20261115_163954_368/`.

### Node tools

| Command | Result |
| --- | --- |
| `node tools/habitat/validate_layout.mjs` | **PASS**: 9 rooms, 16 facility groups, 18 stations, 260 connected cells |
| `node tools/research/validate_science_catalog.mjs --self-test` | **FAIL (exit 1)**: `Missing docs/SCIENCE_BIBLE.md`, `NASA_TECHNOLOGY_CATALOG.md`, `SCIENTIFIC_GAMEPLAY_RULES.md`, `phase_0_8R_report.md`; "Generated catalog differs from JSON"; "Phase report totals differ from the registry". The cause is the relocation. The JSON registry itself is unchanged and the relocated documents are byte-identical to their last committed versions (which passed in D0), but this audit did not re-run the validator against restored paths. It also printed the 8 expected evidence warnings (7 unconfirmed source dates or the CHAPEA discrepancy, plus null TRLs). |

Not run: `tools/release/audit_repository.mjs` and `public_manifest.mjs` (publication-only), and a Windows re-export (not authorized).

---

## 5. Remaining roadmap, mapped to the existing code

| # | Roadmap item | Existing work to reuse (do not redo) | Actually outstanding |
| --- | --- | --- | --- |
| 1 | Professional UI/HUD redesign | GameUI/GameHUD composition, theme separation, modal policy, **UI Pack A (23 validated textures)** | Integrate final frames/states; production pixel font; objective tracker; meaningful status fields (only from existing data); gating of dev utility controls |
| 2 | Cinematic main menu | `GameEntry.new_game()` boundary | Build the menu from scratch: New Game, restart, quit, settings, session teardown |
| 3 | Lunar base exterior art | **Base Pack C (10) + Lander Pack D (4)** imported and validated | Scene placement with explicit footprints, collision and occupancy decisions; replace reservation outlines |
| 4 | Interior and greenhouse art | Room/floor/wall scene contracts, placeholder specs | Art for 9 rooms, 18 stations and trays (PixelLab, needs authorization) |
| 5 | NASA technology/equipment assets | 69-entry research registry with status classes | Asset briefs citing research IDs; operational vs. prototype labeling |
| 6 | UI and menu artwork | UI Pack A | Menu backgrounds, icons, item icons |
| 7 | Environmental artwork | Props Pack B (integrated), **Terrain Pack E (not integrated)** | Overlay layer integration; additional props |
| 8 | Full Moon base visual integration | Items 3–7 | Assembly pass |
| 9 | Construction & maintenance | Management camera, `LunarSiteLayout` reservations, resource-neutral maintenance placeholders | Placement system, build costs, maintenance gameplay |
| 10 | Advanced environmental life support | `UtilityModel` ledgers | Airlock gas coupling, more equipment; must follow the Science Bible |
| 11 | Spacesuit & EVA | Static `EvaSafetyLimits`, `EvaRangeProvider` interface | Suit consumables model (no invented NASA thresholds) |
| 12 | Physical & psychological survival | Empty status fields, daily routines | Entirely new; highest scientific-claim risk |
| 13 | Moon tutorial missions | D0 frozen route and success facts (`DailyLife.completed["science"]`) | Mission/objective controller |
| 14 | Save/load improvements | In-memory snapshots for utilities and daily life | **Disk save/load does not exist.** This item is "implement", not "improve". |
| 15 | Testing & optimization | 126-invocation validator, clean-start validator | Add the pack tests; profiling |
| 16 | Trailer | — | After visuals |
| 17 | Mars campaign | — | Locked until the Moon tutorial is ready |

Ordering notes: items 3, 4, 5, 6 and 7 will consume PixelLab generations. About 4,073 remain this cycle, and each pack needs explicit authorization. Save/load (14) gets more expensive the more state types exist before it. Consider introducing the versioned save service no later than right after construction (9), well before item 14's position.

---

## 6. Recommended first development phase

### Prerequisite: Phase 0.9-R, repository realignment (small, needs user decisions)

This is not a feature phase, but resumed work should not start on a tree that fails its own validators.

1. Decide where the docs live and restore the references (§1). Then confirm `validate_science_catalog.mjs --self-test` passes and the UID warnings are gone.
2. Decide on the modified `export_presets.cfg` and `project.godot`.
3. Rebuild or quarantine the RC ZIP. Create an annotated demo tag or branch. Choose the development branch.
4. Stop Godot importing `docs/project_file_inventory.csv` as a translation (move it, or add a `.gdignore`).
5. Optionally add the four asset-pack tests to `validate.ps1`.
6. Pull `origin/main` (one README commit).

### Phase 0.9A, professional UI/HUD redesign (roadmap item 1)

Why this is first: it is the roadmap's first item. It reuses fully validated, unintegrated assets (UI Pack A), so it needs **little or no new PixelLab spend**. It also fixes the most visible demo gaps: empty status fields, dev-labeled panels and player-reachable fault controls.

Proposed scope, pending your approval:

- Measure UI Pack A frame content areas and states (as its report requires). Restyle the existing theme, HUD, prompt, notifications and the inventory, utility and daily-life panels at 960×540. Keep the ownership, input and modal boundaries.
- Fill status fields **only from existing systems**, such as mode, location/room, utility power/battery and alarms. Do **not** invent health or suit values.
- Gate or hide the development utility fault and scenario controls behind `DevelopmentSettings`.
- Add a passive objective/hint line for the existing frozen route, reusing existing success facts. Do not add a mission system.
- Keep the menu out of this phase (that is 0.9B) and add no audio.
- Validate with `validate.ps1 -IncludeRendering`, extending the UI tests and inspecting rendered captures.

Open question for that phase: is a production pixel font needed? If so, it is a new asset (PixelLab `create_font` or a licensed font). That is a licensing and authorization decision.

---

## 7. Locked rules carried forward

Native 2D 2:1 isometric, 64×32 tiles, 64×64 standard character frames, 960×540 logical resolution, nearest filtering. English only, with snake_case asset names. Art Bible and `art/asset_standards.json` are at standards version **1.0.0**. Original Pixelorama artwork is read-only. Never resize or crop generated art silently. PixelLab is used only with explicit per-job authorization. NASA content follows the Science Bible and registry: operational, demonstration, development and research are distinct, and no invented TRLs, efficiencies or medical thresholds are allowed. One human, Chiwis, T later on Mars, and the Moon first. No audio. One phase at a time. No commits or pushes without authorization.

Release blockers still open from D2.5/D3: no project license, character and regolith art redistribution rights unconfirmed, temporary Godot icon and branding, unsigned EXE, and no clean-machine human playthrough.
