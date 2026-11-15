# Phase 0.8R - NASA Scientific Reference and Technology Database

Completed research baseline **1.0.0**, reviewed through **November 15, 2026**. The cutoff is the current review date, not the end of November. This phase creates documentation and research tooling only; it does not implement scientific gameplay or start Phase 0.8B.

## Delivered files

| File | Change and purpose |
| --- | --- |
| [SCIENCE_BIBLE.md](SCIENCE_BIBLE.md) | New scientific evidence policy, systems foundation, uncertainty boundaries and Moon/Mars context |
| [NASA_TECHNOLOGY_CATALOG.md](NASA_TECHNOLOGY_CATALOG.md) | New generated, detailed human-readable inventory and official source index |
| [SCIENTIFIC_GAMEPLAY_RULES.md](SCIENTIFIC_GAMEPLAY_RULES.md) | New evidence-to-design contract, resource dependencies, medical uncertainty and future acceptance rules |
| [nasa_technology_catalog.json](../resources/research/nasa_technology_catalog.json) | New versioned research registry, separate from gameplay data |
| [.gdignore](../resources/research/.gdignore) | Excludes the research directory from Godot resource scanning |
| [AGENTS.md](../AGENTS.md) | Adds mandatory scientific workflow and Phase 0.8R boundary; retains earlier visual/phase instructions |
| [catalog_documents.mjs](../tools/research/catalog_documents.mjs) | New dependency-free Node generator/checker for the catalog Markdown |
| [validate_science_catalog.mjs](../tools/research/validate_science_catalog.mjs) | New registry/document validation and in-memory invalid-fixture checks |
| [phase_0_8R_report.md](phase_0_8R_report.md) | This report |

## Inventory and evidence

The registry contains **69 entries across all 16 requested categories**, supported by **60 official NASA-domain sources**. The source index retains all twelve requested starting pages. Specific NASA/JPL articles, NTRS technical papers and center publications supplement the general hubs. Records distinguish hardware, systems, procedures, risk references, research programs, environmental references and standards rather than presenting every entry as operational equipment. Status counts are 29 operational/heritage, 11 demonstrated, 13 in development and 16 research/reference records; 117 dependency links resolve to stable research IDs.

Registry totals: **69 entries; 60 sources; 16 categories; 117 dependency links**.

Every record includes a stable ID, official name, actual function, primary organization/URL, evidence references and source dates, status/review date, actual test environment, published-TRL field, Moon/Mars applicability, limitations, proposed game use, supporting equipment and research dependency links. Source/date copies are checked against the canonical source registry. Proposed design fields are explicitly marked as interpretations, not NASA-qualified recipes.

No numeric TRL is asserted. Null means no achieved configuration-specific rating was transcribed, or a hardware readiness rating is inapplicable; it does not mean zero. Readiness definitions, design review titles and increased-TRL statements without a number are not converted into invented ratings.

The catalog covers habitation/airlocks, atmosphere and oxygen, water/sanitation, food/crops, power/thermal control, suits/tools, dust/radiation, exercise/physical health, behavior/isolation, medicine, rovers/robotics, communications/navigation, sampling, ISRU, planetary differences and current development. NASA research does not validate the game's solitary-human mission. Chiwis and T remain fictional robot companions informed by bounded robotics research.

## Status checks and source discrepancies

The registry and catalog preserve eight explicit evidence issues rather than silently selecting convenient numbers or dates:

- ECLSS overview water recovery and the 2023 integrated 98% milestone use different configurations/boundaries; no universal efficiency is locked.
- The newer [CHAPEA completion report](https://www.nasa.gov/missions/analog-field-testing/chapea/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/) supersedes an about page's Mission-2 start information. Mission 2 ended October 31, 2026 on Earth. Its publication/update labels also differ and are preserved.
- The older fission overview's early-2030s schedule differs from the [2026 NASA/DOE development goal](https://www.nasa.gov/news-release/nasa-department-of-energy-to-develop-lunar-surface-reactor-by-2030/). Neither establishes an installed lunar reactor.
- The [2026 ISS ECLSS paper](https://ntrs.nasa.gov/citations/20260003280) still describes UWMS commissioning problems and a reactivation plan. Elapsed target dates are not successful commissioning evidence.
- CADRE's mission page still labels the mission Future; its printed 2026 arrival year is not accepted as proof of a landing.
- IPEx throughput targets differ across descriptions. Neither throughput nor a TRL is assigned from those targets or a document title.
- The general Mars facts page's older seasonal briny-flow interpretation is excluded from accepted claims.
- CaRD oxygen-extraction wording is distinguished from actual integrated-test confirmation of carbon monoxide and from downstream oxygen conversion/storage.

Other important boundaries are recorded per entry: EDS has an actual bounded lunar demonstration; PRIME-1 has partial lunar hardware tests, not a proven water mine; MOXIE completed a small Mars experiment, not a crew-scale oxygen factory; AxEMU and crewed surface rovers remain development in the reviewed evidence; Earth-tested humanoid/quadruped autonomy does not establish operational Mars companions.

## Existing project consistency

Reviewed root instructions, game direction, architecture, Phase 0.8 system contracts and the existing asset-pack reports. No conflicting numerical medical model, scientific production efficiency or operational lunar-habitat commitment was established by those documents. Reserved HUD health labels and artwork names are presentation/design placeholders, not clinical units or functioning infrastructure. Earlier reports' historical phase prohibitions and implementation snapshots remain intact; the new research-only boundary explicitly scopes this task.

The new rules preserve one human protagonist, Chiwis, later T, Moon-first progression, native 2D isometric rendering and existing art standards. Camera modes remain views of the same world. No changes to item definitions, inventory, pickups, actor movement, companion routing, terrain logic, cameras, UI, assets, project settings or existing tests are required.

## Validation

Reproduce from the project root with Node.js (validated using v24.21.0):

```powershell
node --check tools/research/catalog_documents.mjs
node --check tools/research/validate_science_catalog.mjs
node tools/research/catalog_documents.mjs --check
node tools/research/validate_science_catalog.mjs --self-test
```

The checker parses JSON; verifies required metadata, valid dates/cutoff, official source domains, ID uniqueness, all category coverage, status/kind enums, source/date agreement, dependency resolution and TRL evidence requirements; compares the generated catalog byte-for-byte; resolves local documentation links/research IDs; checks baseline versions/cutoffs and required AGENTS references; and requires research exclusion from Godot scanning. Twelve in-memory invalid fixtures exercise rejection of missing evidence, unresolved references, duplicate IDs, an impostor source domain, future/invalid dates, unsupported TRL data, category omission and evidence/design conflation.

| Validation | Result |
| --- | --- |
| Independent PowerShell JSON parse | Passed: 69 entries, 60 sources, 16 categories |
| Node syntax checks for both tools | Passed |
| Registry metadata, dates, enums, references and TRL evidence rules | Passed; 0 errors |
| Generated Markdown / canonical JSON agreement | Passed |
| Documentation versions, research IDs, local links and AGENTS references | Passed |
| Invalid-fixture rejection checks | 12 passed; fixtures stayed in memory |
| Existing project preservation | SHA-256 checks passed for all 478 pre-existing scripts, scenes, Resources, assets, art metadata, tests outside tests/output, and project.godot |
| Production references to research registry | None in scripts, scenes or project.godot; research directory has .gdignore |

These checks validate structure and internal agreement; scientific source interpretation additionally required the manual primary-source review. They do not independently establish NASA hardware qualification or live program telemetry. Warning output is separate from errors: six undated sources, one conflicting source-date ordering and one aggregate null-TRL notice (eight warning lines, zero errors).

## Warnings and limitations

- Six sources have no confirmed publication/update day in this edition; their dates remain null with notes. Publication days also remain null where only a page-update date was verified. Repository acquisition/metadata timestamps are not substituted for report publication.
- CHAPEA's displayed update precedes its publication label; both are preserved as a source discrepancy.
- All 69 published-TRL fields are null for the reasons above. Unknown readiness is not a validation error.
- Some evidence is bounded historical flight heritage or indexed technical-report text. Not every source is a live hardware-status record. A public page target is never treated as an achieved milestone; CADRE's landing/current qualification and UWMS reactivation remain unconfirmed.
- This is a detailed curated baseline, not an exhaustive NASA database, mission certification, clinical protocol or complete bill of materials. Throughput, reserves, physiological thresholds, deployment year and game balance need separate evidence and design approval.
- No gameplay or engine changes are introduced, so Godot graphical/headless/regression suites are not rerun for this documentation-only phase. File-preservation checks provide the relevant regression boundary; no new engine-run success is claimed.

No PixelLab tools or credits, artwork generation, audio, commits or subsequent phase work are part of this delivery. Future Codex scientific workflows must consult the three science documents and registry through the additive root instructions.
