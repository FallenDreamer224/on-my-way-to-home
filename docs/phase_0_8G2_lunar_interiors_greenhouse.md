# Phase 0.8G2 — Lunar interiors, daily-life environments and greenhouse art

Date: 2026-11-15. Engine: **Godot 4.7.2.stable.official.ed1daf0bf**. Result: **COMPLETE WITH LIMITATIONS**.

Delivered a usable isolated interior library: **nine playable room scenes covering thirteen functional areas, 27 static prop scenes and metadata Resources, one native floor TileSet, twelve floor/construction modules, and live read-only greenhouse/utility/airlock presentation**. The normal game retains its original startup, room factory and Moon entrance network. Final world assembly remains Phase 0.9; neither that phase nor 0.8G3 was started.

## Inspection and preservation

Reviewed AGENTS, README, Art Bible/JSON, isometric/intake standards, the Science Bible/catalog/registry/gameplay rules, E1/E2 and habitat records, F/G1 reports, asset inventory, existing scenes, source manifests and tests. The older E1/E2/D implementation reports are currently under `docs/docs/`; this phase did not move or rewrite them. No CLAUDE.md exists.

Stayed on `dev/phase-0.8f-ui-overhaul`, HEAD `b4f00e10384fdde97423ba90fa7481dbbee03e1d`. Alpha remains `2942b0502d1a53a78651044319bbd86392497198`. Existing F/G1 uncommitted work was preserved. A pre-edit baseline records **914 existing project files and 64 external originals**. Only three inherited files were intentionally extended: AGENTS.md, ASSET_INVENTORY.md and tests/validate.ps1. Production scripts/scenes/configuration, original PNG/PXO/font files, G1 prefabs/resources and the scientific registry remain unchanged. No commit, push, reset, export or publication occurred.

The 40×40 Moon region, twelve regolith variants, 64×32 grid, 960×540 presentation, original 64×64 eight-direction character artwork, inventory and both cameras remain intact. No demo binaries were present at takeover; none were created or overwritten.

## Asset audit and production

Rechecked the external originals: character/run/walk PXO projects and Moon terrain sources, with no unused interior furniture/plant pack. Reviewed all **99 existing PixelLab gallery image records and eight object records**, plus the G1 source/library audit, before generation. Relevant existing equipment and cargo were reused; no suitable asset was regenerated.

| Reused component | Interior use |
| --- | --- |
| Work/control console | Mission operations, greenhouse monitoring and shelter |
| Battery/power unit | Existing electrical service representation |
| G1 ECLSS service cabinet | Environmental engineering and dust-service representation |
| Utility/oxygen tank | Delivered reserve/storage representation |
| Tool case, supply pack, resource canister, equipment box | Maintenance, emergency supplies, nutrients and cargo |
| Connector/utility box | Junction and tray-service connection |
| Existing Pack E base floor, utility pad and hazard stripe | General/sealed service floors and marked thresholds |

**PixelLab accounting:** read-only authentication succeeded. The initial controlled batch was 19 one-candidate Pixen jobs. After six quality failures, the user explicitly approved up to five additional generations for four plant overlays and one chair replacement. Final usage was **24 subscription generations**, balance **3763.15 → 3739.15**, USD credits **$0.00**.

**Eighteen candidates were accepted; six rejected originals remain archived and unintegrated.** The first chair read as a desk; initial plant outputs contained figures/complete scenes; the light-frame output contained mature plants. No candidate was cropped, enlarged, repainted or otherwise altered to force acceptance. The replacement germination sprite includes a small brown starter-medium plug, retained whole inside the controlled growing tray; it does not depict exposed lunar soil or add a substrate simulation.

| Accepted new art | Native canvas | Logical footprint |
| --- | --- | --- |
| Sleep bunk, galley, table, EVA rack, medical station, sample bench, maintenance bench, empty/loaded storage racks, empty growing tray | 96×96 each | 2×1 each |
| Sanitation and exercise stations | 96×96 each | 1×1 each |
| Water dispenser | 64×96 | 1×1 |
| Chair replacement | 64×64 | 1×1 |
| Germinating, small, intermediate, mature greens | 64×64 each | Overlay; no extra ground occupancy |

Full measured bounds, actual anchors, static frame regions/counts, prompts, seeds, generation/image IDs, selected candidate and source/runtime hashes are recorded in [interiors_g2.json](../art/imports/interiors_g2.json), the source [job records](../assets/pixellab/source/interiors_g2/generation_jobs.json), and [review decisions](../assets/pixellab/source/interiors_g2/review_decisions.json). Runtime copies preserve exact source bytes and imported RGBA. All accepted new PNGs have binary alpha, lossless imports, no mipmaps/rescaling and alpha-border rewriting disabled.

[ASSET_INVENTORY.md](ASSET_INVENTORY.md) lists each asset's dimensions, bounds, footprint, pivot, origin, source/runtime paths, collision policy and readiness. The new source audit contains **60 unique source/runtime files: 54 READY and six NEEDS_REFINEMENT**, plus **27 intentional DUPLICATE_CANDIDATE groups**. No duplicate/unused artwork was deleted. The existing 162-file exterior/external audit remains intact.

## Compact room architecture

| Reusable room | Logical dimensions | Functional coverage |
| --- | --- | --- |
| crew_airlock | 8×7 | Airlock chamber, inspection/cycle controls, emergency supplies |
| equipment_lock | 8×7 | EVA equipment, helmet/suit servicing and dust-control representation |
| hub | 8×9 | Main habitation/circulation, table/seating, operations/communications |
| living | 8×8 | Sleeping, packaged-food preparation/water, partitioned hygiene/sanitation |
| engineering | 8×8 | ECLSS, water storage/processing, electrical control and reserves |
| health_lab | 8×8 | Medical monitoring, exercise and scientific sample work |
| greenhouse | 8×7 | Two existing growing trays, lights, monitoring and supply connections |
| cargo | 8×7 | Loaded/empty storage, tools and maintenance workbench |
| shelter | 6×6 | Reinforced visual compartment, monitoring, supplies and seating |

The thirteen requested categories share these existing nine room identities. No new building network was forced into the base. Dimensions match the original cutaway maps, including their boundary ring. The gallery health/science variant explicitly moves the science approach to (6,3) and removes its placeholder partition to accommodate the native bench; production layout JSON remains unchanged. Furniture reserves its complete authored footprint rather than inheriting a one-cell placeholder obstacle.

`InteriorArtRoom` extends the existing HabitatRoom contract. Native floor, collision, Actors Y-sort parent, construction, interaction actions, spawn/door/navigation markers and persistent room-state references are composed per scene. Static prop roots have no custom gameplay scripts. Their ground pivots and GridOrigin differ deliberately; placement snaps GridOrigin to the established grid and offsets the unmodified full sprite canvas.

The same occupied cells drive TerrainLayer/full-foot routing and native Physics2D collision. Both actors therefore respect furniture and closed thresholds. Full back walls use original native 2D geometry; foreground/partition sections use low eight-pixel cutaways. There is no opaque roof over the player. Floor modules reuse existing textures; wall/corner/window/service/support/door/cable components and open LED supports are original native geometry, not edited source art. Geometry uses sharp non-antialiased lines, unit scale and nearest textures.

Prepared runtime scenes embed their data, and crop views preload typed Resources. They do not read the raw provenance archive. The room JSON/import manifests remain reproducible tooling inputs; research citations and generation prompts do not enter ordinary gameplay descriptions.

### Existing system bindings

- **Airlock:** inner/outer leaves and both sides of the inner interface observe HabitatDirector.airlock. Unbound pressure boundaries default sealed. The existing director still validates suit/dust checks, pressure matching, modal gates and transitions. Visuals do not bypass that interlock or simulate gas physics.
- **Daily life:** original HabitatActions open the existing DailyLifePanel. Galley, sleep, hygiene, medical, exercise, operations, science and cargo remain their existing actions; decorative seating/workshop surfaces do not invent sitting/crafting/repair mechanics.
- **Utilities:** the original engineering actions open UtilityPanel. Optional service markers reuse G1's read-only equipment-state adapter; no additional utility manager, resource quantity or equipment command is created by the artwork.
- **Persistence and navigation:** the preview retains one astronaut, one Chiwis and the same RuntimeInventory/state references across real director transitions. Existing companion routing and action-point parking are reused. F-key room selection is a development teleport only and refuses modal/transition states; production entrance routing is unchanged.

### Greenhouse

Both existing DailyLife trays have a native research tray, open LED support and separate whole-image plant overlay. Stages are empty, seeded, germinating, small, intermediate and mature. Their thresholds are presentation choices based on actual planted/progress/remaining-yield fields; they are not biological claims. The measured foliage attachment base is centered on the tray surface. Native source canvases remain unchanged across stages.

The existing utility dispatcher controls light/pump availability. Water/nutrients, seed consumption, development acceleration, environmental pauses, finite yield, exact partial harvest and inventory capacity remain owned by E1/E2. Visual refreshes cannot mutate them. Mature art persists while any harvest remainder exists; complete harvest clears it. Power interruption pauses progress without killing/resetting the crop. Crop health/death is absent from the model, so no wilted/failure state is fabricated.

The existing default 1,800-second crop cycle and test acceleration are game abstractions. Full-cycle water/nutrient charges are retained during accelerated tests; electrical energy still follows utility time. No plant oxygen, full-diet support or unlimited production is implied.

## Preview and validation

Run [lunar_interior_preview.tscn](../scenes/development/lunar_interior_preview.tscn) with F6. **F1–F9** selects rooms; WASD, E, Tab and I retain existing controls. The existing HUD/modal interface is used unchanged. The art-inspection caption is shown only in captures with the HUD hidden, avoiding overlap with the Mission OS interface.

| Executed validation | Result |
| --- | --- |
| Complete existing validator with rendering | **178 steps passed**, zero engine errors/warnings |
| Final new library headless | **534 checks passed** |
| Final new library graphical/captures | **600 checks passed** |
| New library fullscreen | **534 checks passed** |
| Native Resources/editor import | Exit 0; zero errors/warnings |
| Cache-free startup | Import, editor exit, class resolution and configured Main all pass; four steps, zero errors/warnings |
| Interior JSON/path/hash/dimension/footprint checks | **431 checks passed** |
| Scientific registry/document consistency | 69 entries/60 sources valid; zero errors; **eight existing evidence warnings retained** |

The 178-step run includes script parsing, startup, native terrain/character resources, movement/Chiwis, both cameras, inventory/interactions, HUD/menu, airlock, greenhouse/daily life, utilities, G1 prefabs and rendered/fullscreen regressions. After the native runtime-data packaging cleanup, affected room/asset/navigation/service suites were rerun and the uncached startup fixture passed. The initial new navigation test accessed the wrong TerrainWalkability field; this test error was corrected, and affected checks rerun. Initial diagnostic logs remain retained rather than represented as successful runs.

The final new suite checks standalone scenes, native imported RGBA, metadata and markers, actual collision hits, actor input movement, Chiwis following, full-foot routes to every station/door, closed/open thresholds, existing interlock transitions, modal safety, read-only crop updates, power failure, conservation and full/partial harvesting. It does not claim finished full-world assembly or scientific certification.

**32 final 960×540 screenshots** cover the nine rooms, thirteen functional categories, character navigation, wall cutaways, real door transition, six crop stages and existing galley/utility panels. Every distinct room, crop stage and navigation/transition/UI view was inspected; shared-function category captures repeat their room view. Inspection corrected foliage placement, a capture-frame latency that showed the prior growth stage, and development-caption overlap with the existing HUD. No source PNG was edited to fix those defects.

Screenshots and logs are under ignored `tests/output/phase_0_8g2/`. Representative files: `living.png`, `airlock.png`, `engineering.png`, `medical.png`, `storage_workshop.png`, `greenhouse_mature.png`, `navigation.png`, `wall_occlusion.png`, `doorway_transition.png`, `existing_galley_ui.png`, `existing_utility_ui.png`. Preservation evidence is `baseline.json` / `preservation.json`; the full workflow log is `full_validation.log`.

## Scientific context

NASA-GAS-CONTROL, NASA-AIR-CDRA, NASA-WATER-WPA, NASA-PLANT-VEGGIE/APH, NASA-FOOD-PACKAGED and the existing health/habitat reference records informed room purpose. NASA's [ECLSS reference](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/) and [plant hardware reference](https://science.nasa.gov/biological-physical/focus-areas/plant-biology/hardware/) were rechecked for visual context. Their actual spacecraft/research settings do not qualify these fictional lunar cabinets, trays or rooms. No technology status, TRL, equipment rating or medical outcome was changed or invented. The registry's missing source dates, documented CHAPEA date discrepancy and null achieved TRLs remain explicit warnings.

## Files and remaining limitations

New files include 18 runtime PNGs/imports; 24 retained source PNGs and job/review records; four interior import/audit/measurement JSON files; 27 prop Resources and scenes; the floor TileSet; nine room scenes and room-library JSON; twelve floor/construction modules; five scripts under scripts/interiors; the development preview script/scene; build/audit/inventory tools; the new test/UIDs; and this report. AGENTS, inventory and validator entries were extended. See [pipeline instructions](../tools/interiors/README.md) for reproducible commands.

The library is **ready for separately authorized Phase 0.9 assembly with limitations**:

1. Production still uses the existing placeholder room factory. Final module count, exterior/interior correspondence, pressure passages and global entrance placement remain unassembled. Nine abstract cutaways are not asserted to fit one small exterior shell; G1 footprints were not enlarged or reinterpreted.
2. Native wall/door/light geometry is usable prepared art; additional polished texture variants, alternative furniture facings and detailed exterior hatch/passage artwork remain future art work. Supplied sprites are never interpolated or rotated into missing directions.
3. Furniture footprints are authored gameplay budgets, not physical certification. Final placements require route/clearance review, especially at compound doors and equipment service areas. No new door-locking or pressure model was implemented.
4. Greenhouse growth, health and shielding remain the existing explicit abstractions. No wilt/failure biology, new survival simulation, medical diagnosis/treatment, crafting, free food/water or new equipment functionality was added.

No final world assembly, additional character, other planetary content, audio, commit or publication was performed. Phase 0.8G3 and Phase 0.9 remain unstarted.
