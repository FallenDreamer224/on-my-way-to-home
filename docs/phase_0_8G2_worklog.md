# Phase 0.8G2 extended base-art worklog

## Checkpoint A — recovered context

- Current branch dev/phase-0.8f-ui-overhaul; HEAD 7aca5b2 (Less), following 148df51 (More). Working tree clean at takeover. Alpha 2942b0502d1a53a78651044319bbd86392497198 is protected.
- Previous G2 code, 18 accepted furnishings/plant images, 27 prop scenes, nine rooms, native modules and tests are present. They are reused rather than regenerated.
- The Less commit removed the Markdown standards/inventory/reports. Restored only required authoritative art/science references and the explicitly requested inventory, byte-identically from 148df51. Prior reports were read from history; no history change or checkout.
- Fresh baseline and read-only hashes of 64 external originals saved in tests/output/phase_0_8g2_base/baseline.json. External sources contain characters and terrain, not missing interior construction art.
- New request authorizes at most 30 additional subscription generations. Read-only balance: 3739.15; USD credits $0. No new job submitted at this checkpoint.

## Initial implementation plan (completed; see final checkpoint below)

1. Author/import actual modular PNG construction art, aligned door states, passage and utility components; preserve source pixels and all accepted furnishing art.
2. Create a spatial plan whose native hull envelopes accommodate the existing nine room footprints. Protected small facade modules retain original scale/footprints; do not pretend they contain larger rooms.
3. Assemble a cohesive modular exterior in an isolated navigable preview; export native transparent composition and terrain showcase.
4. Replace prepared interior geometry rendering with detailed PNG structural modules; keep collision/routing, existing airlock/utility/crop state and normal startup intact.
5. Render/inspect, test seams/state alignment/navigation/regressions, update inventory and final A–G report. No G3/0.9, audio, new simulation or commits.

## Checkpoint B — produced art and spatial plan

- PixelLab: 13 one-candidate jobs completed, 11 accepted and two retained rejects; no more jobs needed currently. Used 13/30 authorized generations. Original PNGs/receipts under assets/pixellab/source/base_g2. Accepted record art/imports/base_g2.json. Replacement passage is a complete sealed tube; hatch pair shares exact 64x96 canvas, bounds (5,18,54,61) and ground anchor (31,79).
- Baked original detailed pixel-painted wall/window/service/support/corner/open/closed-door/cable/roof PNGs with tools/interiors/paint_structure.gd. Original source art is not recolored or resized. Indoor renderer now draws these inspectable PNGs instead of placeholder polygons.
- resources/data/lunar_base_art_layout.json maps all nine original room dimensions to native hull envelopes and eight BFS-routed pressure links (31 corridor cells at initial plan). Explicit room-port overrides prepare physical correspondence without editing production habitat_layout.json. Three supplied small sprites remain native facade/entry bays, not imaginary containers for larger cutaways.
- tools/exterior/paint_hulls.gd bakes full-size hull images plus independent roof images and a 16-cell pressure-passage atlas. Roof/front-wall split is being integrated for character occlusion safety.
- Existing interior builder now adds seven accepted technical/greenhouse/storage furnishings and applies isolated port changes. Normal startup/world and all simulation services remain untouched.
- Next: finish reusable exterior scene and actual existing-actor preview, render/inspect the unified outpost, fix geometry/navigation, run regressions and report exact final counts. Current imports/painting commands have zero engine errors/warnings.

## Checkpoint C — full visual review and shell recovery

- Unified base preview and existing-controller transition test pass 752 headless / 776 rendered checks. PNG-furnished interiors pass 582 headless / 648 rendered checks. Initial full exterior image failed the visual quality gate (repeated blockout-like surfaces); draft hull PNGs are retained but superseded.
- Five native full-size PixelLab shell designs generated (5 additional generations). Originals are saved under source/base_g2/shell_raw. They replace the blockout exteriors at unit scale, never resized. Native depth strips provide per-region sorting; structural full-image copies are not the sole runtime representation.
- Ten provider background-removal jobs (10 generations) produced destructive masks. They are preserved under shell_cutouts and rejected, not integrated. Recovered transparency with tools/exterior/key_shell_background.gd: connected red/purple background mask and largest subject; all retained RGB values verified exactly equal to originals. No sampling/resizing. art/imports/native_shells.json records dimensions, anchors, masks and depth strips.
- New complete native compositions are present under assets/buildings/base_g2/compositions and excluded from runtime scanning. Current illustrated outpost passes 776 graphical checks. Remaining visual issue: angular corridor pieces and actor overlap near large shells.
- Final two authorized generations queued for down-left straight passage and curved elbow. Total planned expenditure is now exactly 30/30 for this extended assignment (previous milestone's 24 excluded). Do not submit any further paid request. Finalize these results, improve actor occlusion/connection rendering, then validation/documentation only.

## Checkpoint D — frozen delivery and final validation

- All 30 authorized operations completed; read-only balance confirmed 3739.15 → 3709.15, $0.00 USD. Fifteen small image requests produced 13 accepted images and two retained rejects; five shell requests produced five accepted native shell designs; all ten provider masks were rejected. No further paid jobs are authorized.
- The final source audit covers 125 new PNG files, including provenance/mirrors/drafts and two compositions. Exactly 51 unique finished components: 18 accepted PixelLab images plus 33 original structural PNGs. Seven additional structural supports and 35 exterior draft PNGs remain preserved outside the finished count. Seventeen duplicate groups are intentional and retained.
- Nine unchanged room-size envelopes, eight logical links and 31 corridor cells form the isolated outpost. Final visible connections use native rounded pipe PNGs. Reversed BFS ordering initially overused junction sprites; sorted pairing fixes it, with a dedicated regression assertion. Native hull depth strips and cached-alpha cutaway keep existing actors visible at the entrance. The new Vector2i dot parser error was fixed, not hidden.
- Interior library is now 34 prop scenes/Resources, nine room scenes, twelve floor/construction scenes, and 40 structural PNG records (33 READY, seven UNUSED). Furnishings, crop stages, existing interlock and service bindings remain native/state-driven. Production startup, map, original prefabs/art/controllers and simulation are unchanged.
- Final targeted base checks: 847 headless / 871 graphical. Furnished interiors: 582 headless / 648 graphical. Base JSON/provenance/dimensions/budget: 1,509 checks; interior JSON/source audit: 507 checks. Two native 2688×1536 compositions and eight native 960×540 exterior captures are delivered, plus 32 furnished-room/state capture files.
- Full regression workflow passed 185 steps (160 headless/import/parse, 25 graphical), zero Godot errors. The first full run had zero warnings; the final code-freeze run recorded one `Scan thread aborted...` warning at graphical editor shutdown. Final evidence is in final_full_validation.log; uncached final startup passes four steps with zero errors/warnings in final_clean_start.log. The focused editor rescan with 600 quit frames passes with zero errors/warnings. All 97 tracked/new nonignored JSON files parse; 30 current report/inventory count/link checks pass. Do not discard earlier failed logs.
- Scientific registry itself passes (69 entries/60 sources and 12 invalid fixtures). Its standalone historical-document validator still reports two errors because Less removed docs/phase_0_8R_report.md; eight prior date/null-TRL warnings are preserved. No scientific data or old validator was changed to conceal this.
- Report: docs/phase_0_8G2_lunar_base_art.md; inventory refreshed through the reproducible inventory tool. Current report/inventory data and links checked separately from historical removed-report links. Five mandatory art/science/inventory documents were restored; four authoritative reference texts remain byte-identical to 148df51. No unrelated old phase reports were restored.
- Final status: COMPLETE WITH LIMITATIONS. Normal-world placement, exact sealed socket/collar correspondence, alternate facings and optional secondary accessories remain explicitly listed. No Phase G3/0.9, new gameplay/simulation, audio, additional generations, commits, push, export or publication.
