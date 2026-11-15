# NASA Technology Catalog

Registry version: **1.0.0**. Evidence reviewed through **2026-11-15**.

**69 entries, 16 categories, 60 official sources.**

This is a research inventory, not an implementation plan, a clinical protocol or a list of equipment currently deployed on the Moon. Read the [Science Bible](SCIENCE_BIBLE.md) and [Scientific Gameplay Rules](SCIENTIFIC_GAMEPLAY_RULES.md) alongside it.

The canonical structured records are in [the research registry](../resources/research/nasa_technology_catalog.json). The directory is excluded from Godot scanning with `.gdignore`; gameplay item Resources remain separate. No runtime code loads this registry.

This document is rendered from the JSON. Regenerate with `node tools/research/catalog_documents.mjs --write`, then validate with `node tools/research/validate_science_catalog.mjs`. Default rendering mode is `--check` and never writes.

## Reading the evidence

| Status | Entries | Meaning |
| --- | ---: | --- |
| operational | 29 | Documented operational use or flight heritage in the stated setting; does not imply lunar or Martian deployment. |
| demonstrated | 11 | Bounded test completed in the named environment; scope and duration remain limited. |
| in_development | 13 | Hardware, integration or a capability is still being developed or qualified. Earlier subsystem demonstrations may exist. |
| research | 16 | An evidence area, experiment, analog, standard or environmental reference; not an operational product. |

`entry_kind` distinguishes hardware/system/procedure from research programs, risk references, standards and environmental references. The latter records are included for completeness; they are not all technologies or products.

Every record has its own evidence status, actual test environment, Moon/Mars applicability, limitations, sources and proposed game use. Operational means documented operation or heritage in that stated setting; it does not guarantee present telemetry, uninterrupted service or qualification on another world.

The three fields marked **Design proposal** are project interpretations, not NASA-qualified system recipes. Equipment lists are enabling interfaces, not complete bills of materials; dependency links are research IDs, not in-game items or automatic unlocks. Circular recovery chains require delivered startup reserves and an external energy source.

No achieved numeric TRL is asserted in this edition. A null rating means no configuration-specific achieved rating was transcribed; it never means TRL 0. [NASA defines the readiness framework](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/technology-readiness-levels/), but those definitions do not rate individual entries. Future non-null values require a level, assessment date, evidence source, configuration scope and test environment.

## Coverage

| Category | Entries |
| --- | ---: |
| 1. Habitats, airlocks, pressure control and life support | 4 |
| 2. Oxygen generation and carbon dioxide removal | 4 |
| 3. Water recovery, wastewater and sanitation | 5 |
| 4. Food storage, nutrition and plant-growth research | 4 |
| 5. Power generation, batteries and thermal control | 5 |
| 6. Spacesuits, EVA tools and maintenance | 4 |
| 7. Lunar dust, radiation and environmental hazards | 4 |
| 8. Exercise, sleep, cardiovascular and muscle health | 8 |
| 9. Psychology, isolation and cognitive performance | 3 |
| 10. Medical equipment, diagnostics and emergency procedures | 3 |
| 11. Surface mobility, rovers, robotics and autonomy | 5 |
| 12. Communications, navigation and mission operations | 4 |
| 13. Scientific experiments, geology and sampling | 5 |
| 14. ISRU, mining, excavation and processing | 5 |
| 15. Moon and Mars environmental differences | 2 |
| 16. Technologies being developed or demonstrated | 4 |

## Inventory

## 1. Habitats, airlocks, pressure control and life support

### NASA-HAB-MOONBASE - Moon Base habitation systems

- **Kind / evidence:** system / in_development, reviewed 2026-11-15.
- **Actual function:** Future architecture combines habitation, airlocks, logistics and surface infrastructure.
- **Organization:** NASA.
- **Official evidence:** [SRC-MOONBASE](https://www.nasa.gov/moonbase-systems/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Published lunar architecture and development plans; no complete operational lunar settlement is established.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** An architecture page does not certify an integrated habitat.; Capacity and mission schedules remain design targets.
- **Design proposal - recommended game use:** Use a supplied starter habitat as explicit near-future fiction, with finite reserves and service interfaces.
- **Design proposal - supporting equipment:** Pressure vessel and seals; Air, water, power and heat-rejection interfaces; Delivered spares.
- **Design proposal - dependencies:** NASA-O2-OGA: One possible oxygen supply; delivered reserves are also required. NASA-AIR-CDRA: CO2 control for occupied volume. NASA-THERMAL-LOOPS: Reject crew and equipment heat.

### NASA-AIRLOCK-QUEST - Quest Joint Airlock

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Provides an isolated transition between a pressurized station and EVA vacuum.
- **Organization:** NASA.
- **Official evidence:** [SRC-QUEST](https://www.nasa.gov/international-space-station/quest-airlock/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** International Space Station, low Earth orbit; documented EVA and repressurization use.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Orbital airlock heritage does not establish lunar dust tolerance.; Cycling gas recovery, leakage and operating procedures depend on configuration.
- **Design proposal - recommended game use:** Model interlocked doors, pressure state and suit readiness; never treat opening a door as free oxygen creation.
- **Design proposal - supporting equipment:** Pressure-rated doors and seals; Gas supply, valves and pressure instrumentation; Suit service equipment.
- **Design proposal - dependencies:** NASA-GAS-CONTROL: Manage cabin and lock gas inventories. NASA-EVA-EMU: Historical suit interface reference.

### NASA-GAS-CONTROL - ECLSS atmosphere revitalization and pressure control

- **Kind / evidence:** system / operational, reviewed 2026-11-15.
- **Actual function:** Maintains a habitable atmosphere through gas management, circulation and contaminant control.
- **Organization:** NASA.
- **Official evidence:** [SRC-ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/), [SRC-JSC](https://www.nasa.gov/reference/jsc-life-support-subsystems/), [SRC-ATMOSPHERES-2026](https://ntrs.nasa.gov/citations/20260003925). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS life-support operation; JSC also researches future configurations.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Cabin pressure, oxygen availability and CO2 burden are distinct variables.; A general subsystem listing mixes mature and developmental equipment.; Reduced-pressure exploration atmospheres can require material, airflow and qualification changes; ISS heritage is not a drop-in certification.
- **Design proposal - recommended game use:** Keep separate pressure, oxygen, CO2 and ventilation concerns in future design.
- **Design proposal - supporting equipment:** Gas storage and regulators; Fans, ducts and sensors; Leak detection and isolation.
- **Design proposal - dependencies:** NASA-POWER-SOLAR: One possible electrical source. NASA-AIR-CDRA: Remove crew-generated carbon dioxide.

### NASA-AIR-TRACE - Trace Contaminant Control System

- **Kind / evidence:** system / operational, reviewed 2026-11-15.
- **Actual function:** Removes trace chemical contaminants from a crewed cabin air stream.
- **Organization:** NASA.
- **Official evidence:** [SRC-ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/), [SRC-JSC](https://www.nasa.gov/reference/jsc-life-support-subsystems/), [SRC-ATMOSPHERES-2026](https://ntrs.nasa.gov/citations/20260003925). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS ECLSS heritage described by NASA; detailed future JSC variants remain separate.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** CO2 removal alone does not remove every airborne contaminant.; Media capacity and replacement intervals require configuration-specific evidence.; Reduced-pressure exploration atmospheres can require material, airflow and qualification changes; ISS heritage is not a drop-in certification.
- **Design proposal - recommended game use:** Reserve a maintenance/filter dependency distinct from oxygen production.
- **Design proposal - supporting equipment:** Air circulation; Sorbent/catalytic treatment hardware; Air-quality monitoring.
- **Design proposal - dependencies:** NASA-GAS-CONTROL: Requires an organized cabin airflow path.

## 2. Oxygen generation and carbon dioxide removal

### NASA-O2-OGA - Oxygen Generation Assembly (OGA)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Electrolyzes water to produce oxygen and hydrogen.
- **Organization:** NASA.
- **Official evidence:** [SRC-ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS ECLSS, microgravity low Earth orbit.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Needs water and electricity; hydrogen handling matters.; ISS operation does not demonstrate a lunar factory or unlimited closed loop.
- **Design proposal - recommended game use:** Provide a later oxygen-production reference with water consumption, heat load and an independent reserve.
- **Design proposal - supporting equipment:** Conditioned water feed; Electrical supply; Gas separation, monitoring and storage.
- **Design proposal - dependencies:** NASA-WATER-WPA: A possible source of conditioned feedwater. NASA-POWER-BATTERY: Buffered electrical supply; storage must be charged.

### NASA-AIR-CDRA - Carbon Dioxide Removal Assembly (CDRA)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Uses molecular-sieve beds to separate carbon dioxide from cabin air.
- **Organization:** NASA.
- **Official evidence:** [SRC-ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS atmosphere revitalization in low Earth orbit.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** CO2 separation is not oxygen generation.; Bed cycling, ventilation and maintenance are required.
- **Design proposal - recommended game use:** Keep breathable oxygen and CO2 removal as independent survival dependencies.
- **Design proposal - supporting equipment:** Airflow fans; Sieve beds, valves and regeneration controls; CO2 sensors.
- **Design proposal - dependencies:** NASA-GAS-CONTROL: Requires ventilation through the cabin. NASA-THERMAL-LOOPS: Heat must be managed.

### NASA-CHEM-SABATIER - Sabatier carbon dioxide reduction system

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Reacts hydrogen with carbon dioxide, recovering water and producing methane.
- **Organization:** NASA.
- **Official evidence:** [SRC-ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS regenerative life-support heritage.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** The ISS pathway vents methane; it does not recover all constituent material.; Does not itself produce breathing oxygen.
- **Design proposal - recommended game use:** Use only as a later partial-recovery option with explicit reactants and byproducts.
- **Design proposal - supporting equipment:** Hydrogen supply; CO2 feed; Catalytic reactor, water separation and heat control.
- **Design proposal - dependencies:** NASA-O2-OGA: One possible hydrogen source; cannot start without water/power. NASA-AIR-CDRA: Potential captured CO2 feed. NASA-WATER-WPA: Recovered water needs appropriate processing.

### NASA-ISRU-MOXIE - Mars Oxygen In-Situ Resource Utilization Experiment (MOXIE)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Demonstrated oxygen production from the Martian atmosphere's carbon dioxide.
- **Organization:** NASA / JPL.
- **Official evidence:** [SRC-MOXIE](https://www.nasa.gov/solar-system/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Perseverance rover on Mars; experiment campaign completed in 2023.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Not applicable to unconfined lunar vacuum: no abundant CO2 atmosphere.
- **Mars applicability:** Actual atmospheric oxygen-production demonstration; crew-scale adaptation remains unproven.
- **Limitations / uncertainties:** Small technology demonstration, not a crew supply or propellant factory.; Industrial scale, sustained operation, liquefaction and storage remain additional work.
- **Design proposal - recommended game use:** Support a later Mars atmospheric-processing concept, explicitly scaled beyond demonstrated hardware.
- **Design proposal - supporting equipment:** Atmospheric intake and compression; High-temperature electrolysis reactor; Power, heat rejection, gas analysis and storage.
- **Design proposal - dependencies:** NASA-POWER-SOLAR: Possible source; output and reserves need separate sizing. NASA-THERMAL-LOOPS: Processing and waste heat require management.

## 3. Water recovery, wastewater and sanitation

### NASA-WATER-UPA - Urine Processor Assembly (UPA)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Recovers water from pretreated urine for further purification.
- **Organization:** NASA.
- **Official evidence:** [SRC-WATER](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/), [SRC-ECLSS-2026](https://ntrs.nasa.gov/citations/20260003280). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS microgravity water recovery; operational heritage and current testbed context.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Recovered distillate is not automatically potable.; Residual brine, pretreatment and maintenance remain.
- **Design proposal - recommended game use:** Make wastewater collection, recovery and clean-water qualification separate stages.
- **Design proposal - supporting equipment:** Urine collection and pretreatment; Distillation equipment; Power and residual-brine handling.
- **Design proposal - dependencies:** NASA-WASTE-WHC: One source of collected urine. NASA-WATER-WPA: Further purification before potable use.

### NASA-WATER-WPA - Water Processor Assembly (WPA)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Purifies recovered water using filtration and catalytic processing with quality checks.
- **Organization:** NASA.
- **Official evidence:** [SRC-ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/), [SRC-WATER](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS Water Recovery System.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Off-spec water may need reprocessing.; Filters, energy and makeup water are not eliminated.
- **Design proposal - recommended game use:** Track clean water separately from untreated liquids and reject contaminated output.
- **Design proposal - supporting equipment:** Feed tanks and pumps; Filter beds and catalytic processor; Water-quality instrumentation.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Supply continuity; capacity is finite. NASA-THERMAL-LOOPS: Processing heat must leave the system.

### NASA-WATER-BPA - Brine Processor Assembly (BPA)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Recovers additional water remaining in urine-processing brine.
- **Organization:** NASA.
- **Official evidence:** [SRC-WATER](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS integrated recovery configuration; NASA reported a 98% overall water-recovery milestone in 2023.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** 98% describes the reported system boundary/configuration, not this component's standalone efficiency.; Does not remove all losses or need for resupply.
- **Design proposal - recommended game use:** Offer an optional recovery upgrade with residual waste; do not hardcode a universal 98% yield.
- **Design proposal - supporting equipment:** UPA brine feed; Membrane/evaporation processing; Cabin humidity collection and downstream purification.
- **Design proposal - dependencies:** NASA-WATER-UPA: Provides brine feed. NASA-WATER-WPA: Recovered water still enters treatment.

### NASA-WASTE-WHC - Waste and Hygiene Compartment (WHC)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Collects crew waste and supports sanitation aboard ISS.
- **Organization:** NASA Johnson Space Center / NTRS.
- **Official evidence:** [SRC-ECLSS-2026](https://ntrs.nasa.gov/citations/20260003280). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS Node 3 toilet complement described in the 2026 ECLSS status paper.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Waste collection is separate from making recovered water safe.; Waste handling and hygiene still use consumables and crew time.
- **Design proposal - recommended game use:** Retain sanitation as infrastructure and waste logistics, without implementing body-function minigames now.
- **Design proposal - supporting equipment:** Waste collection interface; Ventilation and sealed waste storage; Cleaning and replacement supplies.
- **Design proposal - dependencies:** NASA-WATER-UPA: Collected urine may feed water recovery. NASA-AIR-TRACE: Cabin air and odor/contaminant management.

### NASA-WASTE-UWMS - Universal Waste Management System (UWMS)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Exploration toilet intended to collect and separate crew waste using airflow.
- **Organization:** NASA Johnson Space Center / NTRS.
- **Official evidence:** [SRC-ECLSS-2026](https://ntrs.nasa.gov/citations/20260003280). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Delivered and installed on ISS; 2026 technical report describes incomplete initial demonstration and ongoing sensor/acoustic redesign.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Installed is not equivalent to fully commissioned.; Planned early/mid-2026 reactivation is not a confirmed successful reactivation.
- **Design proposal - recommended game use:** Reference a development option, never label it a proven trouble-free lunar toilet.
- **Design proposal - supporting equipment:** Airflow separator and fans; Pretreatment monitoring; Waste tanks, interfaces and maintenance.
- **Design proposal - dependencies:** NASA-WATER-UPA: Potential urine-processing interface once qualified.

## 4. Food storage, nutrition and plant-growth research

### NASA-FOOD-PACKAGED - Space Food Systems flight food

- **Kind / evidence:** system / operational, reviewed 2026-11-15.
- **Actual function:** Supplies safe, nutritious, acceptable packaged meals using multiple preservation methods.
- **Organization:** NASA Johnson Space Center.
- **Official evidence:** [SRC-FOOD](https://www.nasa.gov/directorates/esdmd/hhp/space-food-systems/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS and crewed-spaceflight food production and use.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Shelf life depends on food, packaging and storage.; Five-year exploration acceptability is an R&D goal, not a guarantee for every flight meal.
- **Design proposal - recommended game use:** Make delivered food the tutorial baseline; preserve variety and water/preparation dependencies.
- **Design proposal - supporting equipment:** Sealed food packages; Storage inventory and preparation equipment; Potable water for rehydratable meals.
- **Design proposal - dependencies:** NASA-WATER-WPA: Potential potable-water supply; direct reserves may substitute.

### NASA-FOOD-LONGEVITY - Food and Nutrition research gap FN-102

- **Kind / evidence:** research_program / research, reviewed 2026-11-15.
- **Actual function:** Investigates food safety, nutrition and acceptability over extended storage.
- **Organization:** NASA Human Research Roadmap.
- **Official evidence:** [SRC-FOOD-GAP](https://humanresearchroadmap.nasa.gov/gaps/gap.aspx?i=780), [SRC-FOOD](https://www.nasa.gov/directorates/esdmd/hhp/space-food-systems/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** NASA Human Research Roadmap and food storage research, not a validated complete Mars menu.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Open research does not establish a universal expiry date.; Temperature, package integrity and individual intake vary.
- **Design proposal - recommended game use:** Require separately sourced storage assumptions and clearly labeled balancing dates.
- **Design proposal - supporting equipment:** Controlled storage; Food testing and packaging; Nutrient and acceptability assessments.
- **Design proposal - dependencies:** NASA-FOOD-PACKAGED: Applies to actual meal formulations and packages.

### NASA-PLANT-VEGGIE - Vegetable Production System (Veggie)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Supports plant-growth experiments and fresh crop production using controlled lighting and crop support.
- **Organization:** NASA Biological and Physical Sciences.
- **Official evidence:** [SRC-PLANTS](https://science.nasa.gov/biological-physical/focus-areas/plant-biology/hardware/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS microgravity plant research and limited fresh-food use.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Not a complete calorie supply or a demonstrated closed ecological life-support system.; Crop performance depends on species and conditions.
- **Design proposal - recommended game use:** Allow later supplemental crops, with growth time and input costs; no instant complete diet.
- **Design proposal - supporting equipment:** Lighting and electrical supply; Water, nutrients, seeds and root support; Airflow and crop hygiene.
- **Design proposal - dependencies:** NASA-WATER-WPA: Potential treated-water source with crop-specific suitability. NASA-POWER-SOLAR: One possible lighting-energy source.

### NASA-PLANT-APH - Advanced Plant Habitat (APH)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Provides a highly controlled environment for plant research.
- **Organization:** NASA Biological and Physical Sciences.
- **Official evidence:** [SRC-PLANTS](https://science.nasa.gov/biological-physical/focus-areas/plant-biology/hardware/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS experiments with controlled light, atmosphere, temperature and water delivery.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** An experimental growth chamber is not a field farm.; Extrapolation to partial gravity and mission-scale yields needs evidence.
- **Design proposal - recommended game use:** Reference a more controlled later research greenhouse, not free food generation.
- **Design proposal - supporting equipment:** Growth chamber and sensors; Lighting, water and nutrient delivery; Environmental controls.
- **Design proposal - dependencies:** NASA-THERMAL-LOOPS: Lighting and controlled-environment heat loads. NASA-GAS-CONTROL: Atmospheric management interface.

## 5. Power generation, batteries and thermal control

### NASA-POWER-SOLAR - ISS Roll-Out Solar Array (iROSA)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Converts sunlight into electricity to augment station power.
- **Organization:** NASA.
- **Official evidence:** [SRC-SOLAR](https://www.nasa.gov/missions/station/iss-research/power-up-roll-out-solar-arrays-boost-space-station-power-supply/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS low Earth orbit; ROSA demonstration followed by operational array installations.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Orbital flight heritage does not establish a dust-proof lunar installation.; Shadow and illumination geometry constrain generation.
- **Design proposal - recommended game use:** Use solar power as a variable input; distinguish generation from stored energy.
- **Design proposal - supporting equipment:** Solar arrays and deployment structure; Power conversion, cabling and distribution; Illumination access.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Store energy for periods without sufficient generation.

### NASA-POWER-BATTERY - ISS lithium-ion battery system

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Stores solar-generated energy for later station use.
- **Organization:** NASA.
- **Official evidence:** [SRC-BATTERY](https://www.nasa.gov/blogs/spacestation/2021/02/01/spacewalkers-wrap-up-battery-work-and-camera-installations/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS; battery-upgrade campaign completed in February 2021.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** A historical installation milestone is not a live health reading.; Capacity, cycle aging and thermal safety depend on the pack.
- **Design proposal - recommended game use:** Require charge/discharge limits and finite stored energy; batteries do not generate fuel.
- **Design proposal - supporting equipment:** Battery cells and protective electronics; Charge/discharge conversion; Thermal control and monitoring.
- **Design proposal - dependencies:** NASA-POWER-SOLAR: One possible charging source. NASA-THERMAL-LOOPS: Battery temperature management.

### NASA-THERMAL-LOOPS - Spacecraft active thermal control loops and radiators

- **Kind / evidence:** system / operational, reviewed 2026-11-15.
- **Actual function:** Move equipment heat to radiating surfaces for rejection to the environment.
- **Organization:** NASA Johnson Space Center / NTRS.
- **Official evidence:** [SRC-BVAD](https://ntrs.nasa.gov/citations/20210024855). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS flight architecture; water/internal and ammonia/external loop heritage in NASA engineering references.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** ISS coolant architecture is not a ready lunar plumbing recipe.; Radiator view, contamination, freezing and leak behavior require local design.
- **Design proposal - recommended game use:** Track waste heat as a system constraint; electricity consumption must not imply disappearance of heat.
- **Design proposal - supporting equipment:** Coolant loops, pumps and heat exchangers; Radiators and thermal interfaces; Temperature sensors and isolation valves.
- **Design proposal - dependencies:** No other catalog entry is a mandatory prerequisite; the equipment above still applies.

### NASA-THERMAL-PASSIVE - Spacecraft passive thermal control

- **Kind / evidence:** system / operational, reviewed 2026-11-15.
- **Actual function:** Uses insulation, surface properties and conductive paths to limit unwanted heat transfer.
- **Organization:** NASA Johnson Space Center / NTRS.
- **Official evidence:** [SRC-BVAD](https://ntrs.nasa.gov/citations/20210024855). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Spacecraft design heritage described in NASA baseline engineering references.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Insulation is not an inexhaustible cooling source.; External illumination, orientation and equipment dissipation matter.
- **Design proposal - recommended game use:** Use insulation and heaters as support to a thermal budget, with clear local assumptions.
- **Design proposal - supporting equipment:** Insulation, coatings and thermal interfaces; Temperature sensing; Supplemental heaters when needed.
- **Design proposal - dependencies:** NASA-THERMAL-LOOPS: Active heat removal may still be required.

### NASA-POWER-FSP - Fission Surface Power (FSP)

- **Kind / evidence:** system / in_development, reviewed 2026-11-15.
- **Actual function:** Develops nuclear fission power for sustained surface operations independent of sunlight.
- **Organization:** NASA / DOE.
- **Official evidence:** [SRC-FSP-2026](https://www.nasa.gov/news-release/nasa-department-of-energy-to-develop-lunar-surface-reactor-by-2030/), [SRC-FSP](https://www.nasa.gov/exploration-systems-development-mission-directorate/fission-surface-power/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** NASA/DOE/industry design and development; predecessor nuclear ground experiments on Earth.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** January 2026 announcement sets a 2030 development goal, not an achieved lunar reactor.; Older 40-kW-class overview and future program scope must not be treated as a final flight specification.
- **Design proposal - recommended game use:** Reserve for a later, explicitly speculative infrastructure option; not an operational tutorial power source by default.
- **Design proposal - supporting equipment:** Reactor and energy conversion; Radiators, shielding, separation and electrical distribution; Robotic handling and maintenance planning.
- **Design proposal - dependencies:** NASA-THERMAL-LOOPS: Substantial heat rejection remains necessary.

## 6. Spacesuits, EVA tools and maintenance

### NASA-EVA-EMU - Extravehicular Mobility Unit (EMU)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Provides pressure, breathing support, mobility and thermal protection for orbital EVA.
- **Organization:** NASA.
- **Official evidence:** [SRC-SUITS](https://www.nasa.gov/humans-in-space/astronauts/spacesuits/), [SRC-JSC](https://www.nasa.gov/reference/jsc-life-support-subsystems/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS and historical Space Shuttle EVA.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Orbital EVA heritage does not prove lunar walking, dust endurance or indefinite service.; Suit consumables and maintenance are finite.
- **Design proposal - recommended game use:** Base future suit readiness on multiple subsystems, not a single armor number.
- **Design proposal - supporting equipment:** Pressure garment and helmet; Portable life support and cooling; Airlock and recharge/inspection station.
- **Design proposal - dependencies:** NASA-O2-OGA: One possible upstream refill source; reserves can substitute. NASA-AIRLOCK-QUEST: Historical EVA transition reference.

### NASA-EVA-AXEMU - Axiom Extravehicular Mobility Unit (AxEMU)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Develops a lunar EVA suit for pressure, mobility and surface exploration support.
- **Organization:** NASA Johnson Space Center / Axiom Space.
- **Official evidence:** [SRC-AXEMU](https://www.nasa.gov/humans-in-space/nasa-moon-mission-spacesuit-nears-milestone/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Earth pressurized testing, neutral buoyancy and reduced-gravity simulation; contractor internal review reported February 2026.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Internal review and simulated gravity do not establish lunar deployment or completed NASA qualification.; Do not reuse old mission-number schedules as proof of readiness.
- **Design proposal - recommended game use:** Use a clearly fictionalized future surface suit rather than calling EMU lunar-qualified.
- **Design proposal - supporting equipment:** Surface pressure garment and life support; Recharge, cleaning and inspection interfaces; Dust-tolerant seals and mobility provisions.
- **Design proposal - dependencies:** NASA-DUST-EDS: A separate dust-mitigation reference, not proven full-suit protection. NASA-THERMAL-LOOPS: Suit heat management needs an appropriate interface.

### NASA-EVA-TOOLS - Apollo lunar geology sampling tools

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Hand tools collect and handle lunar soil and rock samples.
- **Organization:** NASA.
- **Official evidence:** [SRC-TOOLS](https://www.nasa.gov/suits-and-rovers/spacewalking-tools/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Historical Apollo lunar surface use; newer Artemis tool designs remain developmental.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Historical actual lunar surface heritage; new versions need qualification.
- **Mars applicability:** Possible adaptation only; Mars environmental and contamination requirements differ.
- **Limitations / uncertainties:** Apollo heritage does not qualify every modern tool variant.; Reach, gloves and tool mass affect usability.
- **Design proposal - recommended game use:** Use tool-specific access and sample handling rather than magical pickup of all materials.
- **Design proposal - supporting equipment:** Scoop, tongs, rake or core tool as appropriate; Sample containers; Suit-compatible handling interfaces.
- **Design proposal - dependencies:** NASA-SAMPLE-PROVENANCE: Retain collection context.

### NASA-MAINT-EVA - ISS EVA maintenance and inspection operations

- **Kind / evidence:** procedure / operational, reviewed 2026-11-15.
- **Actual function:** Crew and ground teams plan and execute external repairs, upgrades and equipment checks.
- **Organization:** NASA.
- **Official evidence:** [SRC-BATTERY](https://www.nasa.gov/blogs/spacestation/2021/02/01/spacewalkers-wrap-up-battery-work-and-camera-installations/), [SRC-MEDICAL](https://www.nasa.gov/missions/station/faq-the-real-story-about-astronaut-health-care-in-space/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS EVA operations, including battery replacement.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Two-person/ground-supported operations do not establish safe lone-astronaut equivalence.; Real procedures require mission-specific training and approvals.
- **Design proposal - recommended game use:** Represent planned tasks, spares, isolation and readiness checks at an abstract level; no real repair instructions.
- **Design proposal - supporting equipment:** Task-specific tools and replacement units; Suit support and worksite access; Checklists and ground/robot assistance.
- **Design proposal - dependencies:** NASA-EVA-EMU: Pressure and life-support readiness. NASA-OPS-DELAY: Support availability depends on communications.

## 7. Lunar dust, radiation and environmental hazards

### NASA-DUST-EDS - Electrodynamic Dust Shield (EDS)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Uses electric fields to remove dust from protected surfaces.
- **Organization:** NASA Kennedy Space Center / CLPS.
- **Official evidence:** [SRC-EDS](https://www.nasa.gov/blogs/missions/2025/03/04/blue-ghost-begins-surface-operations-captures-descent-video-sunrise/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Blue Ghost Mission 1 on the Moon in March 2025; dust removal demonstrated on glass and radiator surfaces.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Actual lunar surface demonstration on selected materials.
- **Mars applicability:** Adaptation unproven by this lunar demonstration.
- **Limitations / uncertainties:** Bounded lunar demonstration; not whole-base or whole-suit immunity.; Performance depends on surface/electrode design and dust conditions.
- **Design proposal - recommended game use:** Allow a later surface-specific mitigation choice with power and maintenance costs.
- **Design proposal - supporting equipment:** Electrode-patterned surface; Electrical drive and insulation; Compatible protected hardware.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Supplies electrical energy; finite charge.

### NASA-RADIATION-RAD - Radiation Assessment Detector (RAD)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Measures the energetic radiation environment on Mars.
- **Organization:** NASA / JPL.
- **Official evidence:** [SRC-RAD](https://science.nasa.gov/resource/radiation-measurements-on-mars/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Curiosity rover Mars surface science operations; historical measurements, not a live telemetry feed here.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Detector concept adaptation; cited observations are Martian.
- **Mars applicability:** Actual Mars surface measurements.
- **Limitations / uncertainties:** A detector measures exposure; it does not shield crew.; Local measurements cannot supply a universal personal health outcome.
- **Design proposal - recommended game use:** Use time/location-specific radiation information, preserving uncertainty and separate shielding.
- **Design proposal - supporting equipment:** Detector, calibration and electronics; Power and data storage; Environmental context.
- **Design proposal - dependencies:** NASA-SCIENCE-LOG: Store measurements with location and time.

### NASA-RADIATION-SHELTER - Space Radiation Analysis Group monitoring and shelter guidance

- **Kind / evidence:** procedure / operational, reviewed 2026-11-15.
- **Actual function:** Combines monitoring, mission context and shielding information to support exposure mitigation.
- **Organization:** NASA Johnson Space Center Space Radiation Analysis Group.
- **Official evidence:** [SRC-SRAG](https://srag.jsc.nasa.gov/spaceradiation/how/how.cfm). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** NASA crewed-mission radiation operations and spacecraft shelter planning.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Solar-particle events and galactic cosmic rays have different mitigation constraints.; Shelter reduces exposure; it is not absolute immunity or guaranteed medical prevention.
- **Design proposal - recommended game use:** Plan warnings, sheltered locations and EVA postponement as documented abstractions.
- **Design proposal - supporting equipment:** Dosimetry and radiation monitoring; Known shielding geometry; Mission procedures and protected volume.
- **Design proposal - dependencies:** NASA-GAS-CONTROL: A shelter also needs a habitable atmosphere. NASA-RADIATION-RAD: Reference for environmental measurements, not a crew-certified dosimeter.

### NASA-HAZARDS-FIVE - NASA Human Research Program five spaceflight hazards

- **Kind / evidence:** risk_reference / research, reviewed 2026-11-15.
- **Actual function:** Organizes risks around radiation, isolation, distance, gravity and hostile/closed environments.
- **Organization:** NASA Human Research Program.
- **Official evidence:** [SRC-HAZARDS](https://www.nasa.gov/hrp/hazards/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Human spaceflight evidence and Earth analog research; not a single device test.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Interacting hazards do not imply deterministic disease.; ISS microgravity evidence does not establish long-duration partial-gravity response.
- **Design proposal - recommended game use:** Use as a review checklist for future systems, never as five automatic damage meters.
- **Design proposal - supporting equipment:** Environmental monitoring; Mission design and mitigation resources; Qualified health evidence review.
- **Design proposal - dependencies:** No other catalog entry is a mandatory prerequisite; the equipment above still applies.

## 8. Exercise, sleep, cardiovascular and muscle health

### NASA-EXERCISE-ARED - Advanced Resistive Exercise Device (ARED)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Provides resistance exercise loading for astronauts.
- **Organization:** NASA Office of the Chief Health and Medical Officer.
- **Official evidence:** [SRC-EXERCISE](https://www.nasa.gov/ochmo-tb-031-exercise-overview-2/), [SRC-MEDICAL](https://www.nasa.gov/missions/station/faq-the-real-story-about-astronaut-health-care-in-space/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS microgravity exercise and associated human research.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Countermeasure performance is not perfect prevention.; ISS results cannot define a universal lunar muscle-loss rate.
- **Design proposal - recommended game use:** Reserve exercise time and equipment as a future mitigation option without clinical promises.
- **Design proposal - supporting equipment:** Resistance apparatus and maintenance supplies; Suitable structural support; Schedule and health monitoring.
- **Design proposal - dependencies:** NASA-MED-MONITOR: Individual response requires observation.

### NASA-EXERCISE-T2 - T2 treadmill

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Supports treadmill aerobic exercise with astronaut restraint/loading.
- **Organization:** NASA Office of the Chief Health and Medical Officer.
- **Official evidence:** [SRC-EXERCISE](https://www.nasa.gov/ochmo-tb-031-exercise-overview-2/), [SRC-MEDICAL](https://www.nasa.gov/missions/station/faq-the-real-story-about-astronaut-health-care-in-space/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS microgravity operations and research.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Exercise needs appropriate loading and monitoring.; A game schedule is not a real medical prescription.
- **Design proposal - recommended game use:** Provide one possible future conditioning activity with time and fatigue tradeoffs.
- **Design proposal - supporting equipment:** Treadmill, harness and loading system; Power and vibration control; Maintenance and monitoring.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Energy supply; charging is separate. NASA-MED-MONITOR: Observe individual condition.

### NASA-EXERCISE-CEVIS - Cycle Ergometer with Vibration Isolation and Stabilization (CEVIS)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Enables cycle-based aerobic exercise while limiting transmitted vibration.
- **Organization:** NASA Office of the Chief Health and Medical Officer.
- **Official evidence:** [SRC-EXERCISE](https://www.nasa.gov/ochmo-tb-031-exercise-overview-2/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS microgravity exercise.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Demonstrated use does not prove complete prevention of deconditioning.; Required workload is individual and mission-specific.
- **Design proposal - recommended game use:** Reference compact later exercise equipment; no invented universal exercise dose.
- **Design proposal - supporting equipment:** Ergometer and stabilization; Maintenance and appropriate support; Scheduling and condition monitoring.
- **Design proposal - dependencies:** NASA-MED-MONITOR: Monitor individual response.

### NASA-HEALTH-CV - Cardiovascular Adaptations Risk (CV Risk)

- **Kind / evidence:** risk_reference / research, reviewed 2026-11-15.
- **Actual function:** Assesses cardiovascular deconditioning, performance effects and long-term concerns in spaceflight.
- **Organization:** NASA Human Health and Performance.
- **Official evidence:** [SRC-CV](https://www.nasa.gov/directorates/esdmd/hhp/cv-risk/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Human spaceflight observations and supporting studies; beyond-LEO gravity/radiation interactions remain uncertain.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Cardiac disease is not inevitable at a fixed elapsed time.; Mission phase and individual response matter.
- **Design proposal - recommended game use:** Keep cardiovascular condition distinct from stamina; require explicit uncertainty review before mechanics.
- **Design proposal - supporting equipment:** Appropriate physiological monitoring; Exercise capability; Clinical research interpretation.
- **Design proposal - dependencies:** NASA-EXERCISE-ARED: One countermeasure reference, not a cure. NASA-EXERCISE-CEVIS: Aerobic-conditioning reference.

### NASA-HEALTH-SLEEP - Sleep Loss, Circadian Desynchronization, and Work Overload Risk

- **Kind / evidence:** risk_reference / research, reviewed 2026-11-15.
- **Actual function:** Examines sleep, environmental disruption and fatigue-related performance risks.
- **Organization:** NASA Human Health and Performance.
- **Official evidence:** [SRC-SLEEP](https://www.nasa.gov/directorates/esdmd/hhp/risk-of-performance-decrements-and-adverse-health-outcomes-resulting-from-sleep-loss-circadian-desynchronization-and-work-overload/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Short- and long-duration spaceflight and relevant Earth environments.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** No universal deterministic error, injury or psychiatric outcome follows a single missed sleep period.; Sleep duration alone does not capture quality.
- **Design proposal - recommended game use:** Use protected rest opportunities and workload effects with labeled game timing assumptions.
- **Design proposal - supporting equipment:** Suitable sleep space; Thermal and light control; Work/rest planning.
- **Design proposal - dependencies:** NASA-THERMAL-LOOPS: Comfortable habitat conditions. NASA-BEHAVIOR-HFBP: Workload and human factors interact.

### NASA-HEALTH-IMMUNE - Altered Immune Response Risk

- **Kind / evidence:** risk_reference / research, reviewed 2026-11-15.
- **Actual function:** Studies immune-function changes and associated health concerns during spaceflight.
- **Organization:** NASA Human Health and Performance.
- **Official evidence:** [SRC-IMMUNE](https://www.nasa.gov/directorates/esdmd/hhp/immune-risk/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Crew biological observations and samples, principally orbital missions.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** NASA explicitly notes uncertainty over increased disease susceptibility.; Long-duration exploration outcomes are unresolved.
- **Design proposal - recommended game use:** Do not turn 'defenses' into a NASA-validated immunity percentage or inevitable infection timer.
- **Design proposal - supporting equipment:** Sample collection and analysis; Hygiene and environmental controls; Appropriate clinical interpretation.
- **Design proposal - dependencies:** NASA-WASTE-WHC: Sanitation supports hygiene. NASA-MED-MONITOR: Observation is separate from diagnosis.

### NASA-HEALTH-MUSCLE - Reduced Muscle Size, Strength, and Endurance Risk

- **Kind / evidence:** risk_reference / research, reviewed 2026-11-15.
- **Actual function:** Assesses muscular deconditioning and physical-performance limits during spaceflight.
- **Organization:** NASA Human Health and Performance.
- **Official evidence:** [SRC-MUSCLE](https://www.nasa.gov/directorates/esdmd/hhp/muscle-risk/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Primarily ISS microgravity observations and exercise-countermeasure research.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Average crew outcomes with ISS countermeasures are not universal individual outcomes.; Exploration exercise equipment and partial-gravity exposure differ.
- **Design proposal - recommended game use:** Separate short-term fatigue from longer-term conditioning, without inventing linear Moon/Mars loss rates.
- **Design proposal - supporting equipment:** Suitable exercise equipment; Nutrition and recovery opportunities; Individual monitoring.
- **Design proposal - dependencies:** NASA-EXERCISE-ARED: Resistance-loading reference. NASA-FOOD-PACKAGED: Adequate nutrition remains necessary.

### NASA-HEALTH-BONE - Bone Fracture due to Spaceflight-induced Changes to Bone Risk

- **Kind / evidence:** risk_reference / research, reviewed 2026-11-15.
- **Actual function:** Evaluates altered-gravity skeletal changes and fracture risk in relation to loads and fragility.
- **Organization:** NASA Human Health and Performance.
- **Official evidence:** [SRC-BONE](https://www.nasa.gov/directorates/esdmd/hhp/risk-of-bone-fracture-due-to-spaceflight-induced-changes-to-bone/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Spaceflight evidence and countermeasure research; long-term lunar/interplanetary effects remain uncharacterized.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** A risk is not a guaranteed fracture.; Do not scale ISS measurements linearly by local gravity or mission time.
- **Design proposal - recommended game use:** Keep skeletal health distinct from immediate stamina and injury; any future model needs new evidence.
- **Design proposal - supporting equipment:** Appropriate loading/exercise; Nutrition and individual monitoring; Mission-specific risk assessment.
- **Design proposal - dependencies:** NASA-EXERCISE-ARED: One countermeasure reference. NASA-MED-MONITOR: Observation and assessment.

## 9. Psychology, isolation and cognitive performance

### NASA-BEHAVIOR-HFBP - Human Factors and Behavioral Performance (HFBP)

- **Kind / evidence:** research_program / research, reviewed 2026-11-15.
- **Actual function:** Studies human-system interaction, cognition, behavior and performance under mission constraints.
- **Organization:** NASA Human Research Program.
- **Official evidence:** [SRC-HFBP](https://www.nasa.gov/hrp/human-factors-and-behavioral-performance/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Spaceflight studies, HERA/CHAPEA and other Earth analog environments.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Small teams and analogs do not directly establish lone-human-plus-robot outcomes.; Association is not a guaranteed mental-health event.
- **Design proposal - recommended game use:** Inform workload, autonomy and readable task design; avoid deterministic psychiatric debuffs.
- **Design proposal - supporting equipment:** Human-factors assessments; Workload and schedule records; Behavioral support and privacy.
- **Design proposal - dependencies:** NASA-HEALTH-SLEEP: Sleep and workload are related influences. NASA-OPS-DELAY: Distance changes support interactions.

### NASA-ANALOG-CHAPEA - Crew Health and Performance Exploration Analog (CHAPEA)

- **Kind / evidence:** research_program / research, reviewed 2026-11-15.
- **Actual function:** Studies crew health and performance during simulated Mars surface missions.
- **Organization:** NASA Johnson Space Center.
- **Official evidence:** [SRC-CHAPEA-2026](https://www.nasa.gov/missions/analog-field-testing/chapea/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/), [SRC-CHAPEA-ABOUT](https://www.nasa.gov/humans-in-space/chapea/about-chapea/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Earth, Johnson Space Center; four-person habitat analog. Mission 2 ended October 31, 2026; post-mission evaluation was reported November 9.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Earth gravity and protection do not reproduce Martian radiation or partial gravity.; Completion is not proof of Mars habitat operation; a four-person study does not validate one-human outcomes.
- **Design proposal - recommended game use:** Use resource/workload/communication constraints as research inspiration, with the solo story labeled fiction.
- **Design proposal - supporting equipment:** Earth analog habitat; Research monitoring and study support; Simulated operations and delay.
- **Design proposal - dependencies:** NASA-BEHAVIOR-HFBP: Human-factors interpretation. NASA-FOOD-PACKAGED: Food system is part of resource planning.

### NASA-SLEEP-CIRCADIAN - Circadian Light and sleep-monitoring investigations

- **Kind / evidence:** research_program / research, reviewed 2026-11-15.
- **Actual function:** Investigates lighting and measures sleep-related behavior in space.
- **Organization:** NASA ISS Research.
- **Official evidence:** [SRC-SLEEP-RESEARCH](https://www.nasa.gov/humans-in-space/science-in-space-week-of-sept-15-2023-sleep-on-station/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS experiments, including circadian lighting and wearable monitoring.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Experimental lighting is not a guaranteed cure for fatigue.; Monitoring does not itself improve sleep.
- **Design proposal - recommended game use:** Reserve adjustable habitat lighting and logs as later research features.
- **Design proposal - supporting equipment:** Controllable light sources; Wearable monitoring and data collection; Protected rest schedule.
- **Design proposal - dependencies:** NASA-HEALTH-SLEEP: Use alongside sleep-environment and workload planning.

## 10. Medical equipment, diagnostics and emergency procedures

### NASA-MED-MONITOR - ISS astronaut health monitoring and flight-surgeon support

- **Kind / evidence:** system / operational, reviewed 2026-11-15.
- **Actual function:** Tracks crew health through monitoring, examinations and medical support.
- **Organization:** NASA.
- **Official evidence:** [SRC-MEDICAL](https://www.nasa.gov/missions/station/faq-the-real-story-about-astronaut-health-care-in-space/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Crewed low Earth orbit with extensive ground medical teams and return options.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Earth-supported ISS care cannot be assumed available in real time on Mars.; Symptoms and sensor readings are not diagnoses.
- **Design proposal - recommended game use:** Use observations, uncertainty and referral/contingency concepts; no automatic diagnostic robot.
- **Design proposal - supporting equipment:** Appropriate diagnostic instruments; Medical records and trained procedures; Communications and private data handling.
- **Design proposal - dependencies:** NASA-COMMS-DSN: Deep-space communications is a reference, not real-time care. NASA-OPS-DELAY: Support has latency and outages.

### NASA-MED-ECHO - EchoFinder-2

- **Kind / evidence:** research_program / research, reviewed 2026-11-15.
- **Actual function:** Tests AI/augmented-reality guidance for ultrasound probe placement.
- **Organization:** NASA ISS Research.
- **Official evidence:** [SRC-ECHO](https://www.nasa.gov/blogs/spacestation/2026/09/24/advanced-health-tech-research-continues-to-protect-astronaut-health/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS study reported September 2026 with real-time monitoring by a ground technician.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Guided probe placement is not autonomous medical diagnosis.; The reported test still used Earth support.
- **Design proposal - recommended game use:** Reference a later diagnostic-assistance interface, clearly separate from validated diagnosis.
- **Design proposal - supporting equipment:** Ultrasound instrument and probe; Tablet guidance interface; Trained operator, data and support.
- **Design proposal - dependencies:** NASA-MED-MONITOR: Measurements require interpretation. NASA-OPS-DELAY: A future Mars version must work through delayed support.

### NASA-MED-EMERGENCY - ISS medical contingency planning and emergency support

- **Kind / evidence:** procedure / operational, reviewed 2026-11-15.
- **Actual function:** Combines trained crew, medical supplies, ground expertise and contingency planning.
- **Organization:** NASA.
- **Official evidence:** [SRC-MEDICAL](https://www.nasa.gov/missions/station/faq-the-real-story-about-astronaut-health-care-in-space/), [SRC-AUTONOMY](https://ntrs.nasa.gov/citations/20220002905). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** ISS near-Earth operational context; exploration autonomy is a separate challenge.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Rapid Earth return and continuous support cannot be carried over to Mars.; This catalog contains no medication doses or real emergency treatment instructions.
- **Design proposal - recommended game use:** Design abstract assess/isolate/stabilize/contact sequences only after separate approval and medical evidence review.
- **Design proposal - supporting equipment:** Medical kit and diagnostic tools; Trained checklists and records; Habitable refuge and contingency supplies.
- **Design proposal - dependencies:** NASA-MED-MONITOR: Condition assessment and records. NASA-GAS-CONTROL: Environmental causes must be considered. NASA-OPS-DELAY: Plan for delayed expert help.

## 11. Surface mobility, rovers, robotics and autonomy

### NASA-ROVER-LTV - Lunar Terrain Vehicle (LTV)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Develops crewed and remotely operated lunar surface mobility.
- **Organization:** NASA.
- **Official evidence:** [SRC-LTV-2026](https://www.nasa.gov/missions/moon-base/nasa-provides-progress-update-on-moon-base-rovers/), [SRC-ROVERS](https://www.nasa.gov/suits-and-rovers/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Earth vehicle/mockup and suited-crew testing; October 2026 NASA task orders describe future surface delivery.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Intended lunar use; reviewed evidence remains development on Earth.
- **Mars applicability:** Separate adaptation and qualification required.
- **Limitations / uncertainties:** Commercial lunar component heritage is not a deployed crew-rated LTV.; Delivery targets are not completed missions.
- **Design proposal - recommended game use:** Reserve later transport with charge, route, payload and recovery planning.
- **Design proposal - supporting equipment:** Mobility platform and navigation; Power and thermal management; Crew interfaces and communications.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Energy storage and charging limits. NASA-COMMS-LUNANET: Possible future interoperability reference.

### NASA-ROVER-PRESSURIZED - Pressurized lunar rover

- **Kind / evidence:** system / in_development, reviewed 2026-11-15.
- **Actual function:** Planned mobile habitable capability for longer surface exploration.
- **Organization:** NASA.
- **Official evidence:** [SRC-MOONBASE](https://www.nasa.gov/moonbase-systems/), [SRC-ROVERS](https://www.nasa.gov/suits-and-rovers/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** NASA future Moon Base architecture; no deployed crewed lunar pressurized rover established.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Proposed mission duration and occupancy are targets.; Moving a pressure vessel does not eliminate life-support needs.
- **Design proposal - recommended game use:** Keep as a later integrated vehicle concept, not an already proven starter asset.
- **Design proposal - supporting equipment:** Pressure cabin and airlock/interfaces; Mobility, navigation and communications; Power, water, air and heat rejection.
- **Design proposal - dependencies:** NASA-GAS-CONTROL: Occupied cabin atmosphere. NASA-THERMAL-LOOPS: Heat rejection. NASA-ROVER-LTV: Mobility comparison only; not the same vehicle.

### NASA-ROBOT-CADRE - Cooperative Autonomous Distributed Robotic Exploration (CADRE)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Develops coordinated autonomous rover exploration using distributed measurements.
- **Organization:** NASA JPL.
- **Official evidence:** [SRC-CADRE](https://www.jpl.nasa.gov/missions/cadre/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** JPL mission page still labels the lunar demonstration Future at review; no completed landing is verified.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Planned lunar demonstration; not confirmed deployed by this review.
- **Mars applicability:** Conceptual transfer only, requiring separate environmental qualification.
- **Limitations / uncertainties:** An advertised 2026 arrival does not establish flight completion.; Team autonomy is task-specific, not unrestricted intelligence.
- **Design proposal - recommended game use:** Inform later limited robot coordination; do not grant Chiwis unlimited scouting knowledge.
- **Design proposal - supporting equipment:** Multiple rovers and navigation sensors; Mesh radios and base station; Solar power and scientific instruments.
- **Design proposal - dependencies:** NASA-POWER-SOLAR: Daylight operating energy. NASA-SCIENCE-LOG: Preserve measurements and spatial context.

### NASA-ROBOT-VALKYRIE - Valkyrie

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Humanoid robotics platform for dexterous manipulation and autonomy development.
- **Organization:** NASA Johnson Space Center.
- **Official evidence:** [SRC-ROBOTICS](https://www.nasa.gov/general/reliable-robots-meet-johnsons-dexterous-robotics-team/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Johnson robotics facilities and Earth testing; September 2026 overview distinguishes it from Robonaut flight heritage.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** No demonstrated Mars humanoid worker is established.; Human shape does not imply general human competence or field repair ability.
- **Design proposal - recommended game use:** Use as research inspiration for T on Mars; T remains a fictional, separately specified robot.
- **Design proposal - supporting equipment:** Actuators and manipulators; Perception and control hardware; Power, computing and thermal support.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Finite energy. NASA-OPS-DELAY: Local autonomy must cover delayed supervision.

### NASA-ROBOT-SUBT - Team CoSTAR subterranean autonomy technologies

- **Kind / evidence:** research_program / demonstrated, reviewed 2026-11-15.
- **Actual function:** Demonstrated robot exploration and mapping of challenging underground environments.
- **Organization:** NASA JPL.
- **Official evidence:** [SRC-SUBT](https://www.jpl.nasa.gov/capabilities/robotics/nebula/subt-challenge/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** DARPA Subterranean Challenge Earth caves, mines and built environments.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Ground quadruped/robot autonomy is not vacuum, lunar-dust or radiation qualification.; No NASA lunar robotic dog is implied.
- **Design proposal - recommended game use:** Inspiration for Chiwis sensing and route limitations; artistic form and companion role are game fiction.
- **Design proposal - supporting equipment:** Mobility platform; Range/vision sensors and computing; Power and communication links.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Robot energy budget. NASA-SCIENCE-LOG: Maps require measurements.

## 12. Communications, navigation and mission operations

### NASA-COMMS-DSN - Deep Space Network (DSN)

- **Kind / evidence:** system / operational, reviewed 2026-11-15.
- **Actual function:** Provides deep-space radio tracking and communication through Earth-based antenna complexes.
- **Organization:** NASA Space Communications and Navigation / JPL.
- **Official evidence:** [SRC-DSN](https://www.nasa.gov/communicating-with-missions/dsn/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Earth ground infrastructure supporting interplanetary spacecraft; Goldstone, Madrid and Canberra complexes.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Shared network schedules, line of sight and link budgets constrain service.; Network presence does not provide continuous high-bandwidth personal coverage.
- **Design proposal - recommended game use:** Make communication depend on antennas, access and scheduled links; no instant unlimited uplink.
- **Design proposal - supporting equipment:** Surface radio, antenna and power; Compatible relay or direct link; Ground network access.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Communications uses energy. NASA-OPS-DELAY: Radio signals have finite propagation time.

### NASA-COMMS-LUNANET - LunaNet Interoperability Specification

- **Kind / evidence:** standard / research, reviewed 2026-11-15.
- **Actual function:** Defines interoperable lunar communication and position/navigation/timing service interfaces.
- **Organization:** NASA / ESA / JAXA.
- **Official evidence:** [SRC-LUNANET](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/lunanet-interoperability-specification/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Published NASA/ESA/JAXA specification; not evidence of a completed operational lunar constellation.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Designed for lunar interoperability; deployment is a separate question.
- **Mars applicability:** Not a ready-made Mars network; a different architecture is required.
- **Limitations / uncertainties:** A standard is not deployed coverage or a certified rover navigation solution.; Service availability depends on actual providers and geometry.
- **Design proposal - recommended game use:** Reference future interface design; label assumed game relay coverage as scenario infrastructure.
- **Design proposal - supporting equipment:** Compatible terminals and protocols; Deployed service provider infrastructure; Time and navigation data interfaces.
- **Design proposal - dependencies:** NASA-COMMS-DSN: Earth connectivity may be an upstream service.

### NASA-NAV-LUGRE - Lunar GNSS Receiver Experiment (LuGRE)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Demonstrated reception and navigation use of Earth GNSS signals at the Moon.
- **Organization:** NASA / Italian Space Agency.
- **Official evidence:** [SRC-LUGRE](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/nasa-successfully-acquires-gps-signals-on-moon/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Blue Ghost Mission 1 lunar surface, March 2025; dedicated NASA report records a navigation fix on March 3.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Actual bounded lunar GNSS demonstration.
- **Mars applicability:** Earth GNSS lunar demonstration does not establish Mars GNSS service.
- **Limitations / uncertainties:** A receiver demonstration is not ubiquitous lunar GPS coverage.; Signal strength, geometry and antenna design remain constraints.
- **Design proposal - recommended game use:** Inform specialized navigation research; ordinary lunar map coordinates remain a game abstraction.
- **Design proposal - supporting equipment:** Sensitive receiver and antenna; GNSS signal visibility; Power and navigation processing.
- **Design proposal - dependencies:** NASA-POWER-BATTERY: Receiver energy supply.

### NASA-OPS-DELAY - Earth-independent operations under communication delay

- **Kind / evidence:** procedure / research, reviewed 2026-11-15.
- **Actual function:** Plans local decisions and asynchronous support when deep-space communications are delayed or interrupted.
- **Organization:** NASA Engineering and Safety Center / NTRS.
- **Official evidence:** [SRC-AUTONOMY](https://ntrs.nasa.gov/citations/20220002905), [SRC-CHAPEA-2026](https://www.nasa.gov/missions/analog-field-testing/chapea/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** NASA technical assessment, mission operations analysis and Earth analogs.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Mars latency varies with geometry; outages and scheduling are separate from light time.; CHAPEA imposed delays do not prove complete autonomous medicine.
- **Design proposal - recommended game use:** Queue messages and procedures on Mars; prohibit instant Earth piloting or instant remote clinical intervention.
- **Design proposal - supporting equipment:** Onboard procedures and data storage; Local decision support; Communication buffers and trained operator.
- **Design proposal - dependencies:** NASA-COMMS-DSN: Physical link infrastructure. NASA-MED-MONITOR: Local observation informs delayed consultation.

## 13. Scientific experiments, geology and sampling

### NASA-SCIENCE-LOG - Apollo lunar sample field documentation

- **Kind / evidence:** procedure / operational, reviewed 2026-11-15.
- **Actual function:** Records samples with photographs, descriptions and collection context.
- **Organization:** NASA / USGS / NTRS.
- **Official evidence:** [SRC-SAMPLE](https://ntrs.nasa.gov/citations/19720021173). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Historical Apollo lunar sampling and subsequent documentation.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Some historical sample locations were approximate or reconstructed.; An observation is not automatically a verified resource deposit.
- **Design proposal - recommended game use:** Keep stable sample IDs, collection location/time and observation confidence in future scientific records.
- **Design proposal - supporting equipment:** Camera and location record; Sample identifiers and notebook/data storage; Collection tools.
- **Design proposal - dependencies:** NASA-EVA-TOOLS: Physical collection tools.

### NASA-SAMPLE-PROVENANCE - Apollo sample preliminary examination and curation

- **Kind / evidence:** procedure / operational, reviewed 2026-11-15.
- **Actual function:** Catalogs returned material using identifiers, mass, photographs and physical descriptions.
- **Organization:** NASA Johnson Space Center Astromaterials Acquisition and Curation / NTRS.
- **Official evidence:** [SRC-CURATION](https://ntrs.nasa.gov/citations/20240009312). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** NASA terrestrial lunar-sample curation and examination.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Earth laboratories and contamination controls are not automatically portable to a starter habitat.; Cataloging a rock does not identify every constituent.
- **Design proposal - recommended game use:** Keep specimen identity separate from generic sale/resource quantities; preserve contamination context.
- **Design proposal - supporting equipment:** Labeled containers; Appropriate handling/storage controls; Measurement and documentation equipment.
- **Design proposal - dependencies:** NASA-SCIENCE-LOG: Preserve collection context.

### NASA-SCIENCE-PIXL - Planetary Instrument for X-ray Lithochemistry (PIXL)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Measures fine-scale elemental composition using X-ray fluorescence.
- **Organization:** NASA / JPL.
- **Official evidence:** [SRC-INSTRUMENTS](https://science.nasa.gov/mission/mars-2020-perseverance/science-instruments/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Perseverance rover Mars instrument operations described by NASA.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Possible adaptation; this evidence concerns a Mars instrument.
- **Mars applicability:** Actual Mars rover instrument heritage; not human handheld qualification.
- **Limitations / uncertainties:** Elemental measurements are not direct proof of biological life or industrially recoverable ore.; Sampling geometry, calibration and interpretation matter.
- **Design proposal - recommended game use:** Reserve later composition analysis with confidence and instrument limits; not omniscient scanning.
- **Design proposal - supporting equipment:** X-ray instrument and positioning; Power, calibration and data processing; Suitable target access.
- **Design proposal - dependencies:** NASA-SCIENCE-LOG: Archive target and measurement context.

### NASA-SCIENCE-SHERLOC - Scanning Habitable Environments with Raman and Luminescence for Organics and Chemicals (SHERLOC)

- **Kind / evidence:** hardware / operational, reviewed 2026-11-15.
- **Actual function:** Maps minerals and organic-related signatures using Raman and fluorescence measurements.
- **Organization:** NASA / JPL.
- **Official evidence:** [SRC-INSTRUMENTS](https://science.nasa.gov/mission/mars-2020-perseverance/science-instruments/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Perseverance rover Mars science-instrument heritage; not an assertion of uninterrupted instrument availability.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Organic signatures do not by themselves establish life.; Instrument maintenance history and specific performance need a new review before use.
- **Design proposal - recommended game use:** Enable later bounded analysis, with ambiguous results rather than automatic life detection.
- **Design proposal - supporting equipment:** Spectrometer, positioning and imaging; Power and calibration; Scientific interpretation and data storage.
- **Design proposal - dependencies:** NASA-SCIENCE-LOG: Preserve spatial and measurement context.

### NASA-SCIENCE-LCROSS - Lunar Crater Observation and Sensing Satellite (LCROSS)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Used an impact and remote measurements to investigate material in a permanently shadowed lunar crater.
- **Organization:** NASA Ames Research Center.
- **Official evidence:** [SRC-LCROSS](https://science.nasa.gov/mission/lcross/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Cabeus crater on the Moon, historical October 2009 impact mission.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Actual lunar evidence at a specific site.
- **Mars applicability:** No direct Mars resource validation from this mission.
- **Limitations / uncertainties:** Evidence for water at a particular site does not establish uniform surface ice.; Detection is not excavation or recoverable production yield.
- **Design proposal - recommended game use:** Require prospecting before siting ice extraction; separate confirmed evidence from mapped estimates.
- **Design proposal - supporting equipment:** Prospecting measurements and interpretation; Access to target region; Geologic and illumination context.
- **Design proposal - dependencies:** NASA-ENV-MOON: Site-dependent lunar conditions.

## 14. ISRU, mining, excavation and processing

### NASA-ISRU-IPEX - Infrastructure Pilot Excavator (IPEx)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Develops regolith excavation and transport using counter-rotating bucket drums.
- **Organization:** NASA Kennedy Space Center.
- **Official evidence:** [SRC-IPEX](https://www.nasa.gov/infrastructure-pilot-excavator/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Kennedy Earth testbeds, including lighting/rock-hazard autonomy simulations; project page updated November 9, 2026.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Intended lunar excavation; reviewed tests are terrestrial.
- **Mars applicability:** Requires separate adaptation; low-gravity excavation lessons are not Mars qualification.
- **Limitations / uncertainties:** No deployed lunar mining operation is established.; Published throughput statements are design goals; source pages differ and are not gameplay constants.
- **Design proposal - recommended game use:** Reference a later excavator with energy, route, wear, storage and feed constraints.
- **Design proposal - supporting equipment:** Excavator mobility and bucket drums; Navigation sensors and dust protection; Power, thermal control and material delivery interfaces.
- **Design proposal - dependencies:** NASA-DUST-EDS: Candidate surface dust mitigation reference. NASA-POWER-BATTERY: Finite electrical energy. NASA-ISRU-CARD: One possible downstream processing reference.

### NASA-ISRU-CARD - Carbothermal Reduction Demonstration (CaRD)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Tests solar-driven extraction chemistry with regolith simulant, confirming carbon monoxide production.
- **Organization:** NASA Johnson / Glenn / Kennedy / Sierra Space.
- **Official evidence:** [SRC-CARD](https://www.nasa.gov/centers-and-facilities/johnson/sunlight-extracts-oxygen-from-regolith-using-solar-chemistry/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Integrated Earth prototype with solar concentrator, reactor, mirrors, control and gas analysis; February 2026 report.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Intended lunar application; actual test used Earth simulant.
- **Mars applicability:** Some downstream chemistry may transfer, but a Mars plant is not established.
- **Limitations / uncertainties:** Carbon monoxide confirmation is not delivered breathable oxygen storage.; Downstream conversion and complete plant reliability remain distinct from the integrated prototype.
- **Design proposal - recommended game use:** Reference a later high-energy processing chain with explicit reactants, gas handling and intermediate products.
- **Design proposal - supporting equipment:** Solar concentrator and tracking mirrors; Carbothermal reactor and process feed; Gas analysis, downstream conversion, storage and thermal control.
- **Design proposal - dependencies:** NASA-ISRU-IPEX: Possible material feed. NASA-THERMAL-LOOPS: High-temperature processing requires thermal design.

### NASA-ISRU-MRE - Molten Regolith Electrolysis (MRE)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Extracts oxygen and metal products through electrolysis of molten regolith simulant.
- **Organization:** NASA Kennedy Space Center / Lunar Resources.
- **Official evidence:** [SRC-MRE](https://www.nasa.gov/centers-and-facilities/kennedy/nasa-kennedy-breathes-life-into-moon-soil-testing/), [SRC-SURFACE](https://www.nasa.gov/lunar-surface-technology/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Kennedy Earth vacuum-chamber tests with Lunar Resources, reported May 2025.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Ground simulant/vacuum testing is not a continuous lunar oxygen-and-metal factory.; Reactor life, feeding, power and product qualification need further work.
- **Design proposal - recommended game use:** Offer a later distinct processing route; separate oxygen output, hot metal/slag and safe usable products.
- **Design proposal - supporting equipment:** High-temperature electrolysis reactor; Electrical power and feed handling; Gas separation, product collection and heat management.
- **Design proposal - dependencies:** NASA-ISRU-IPEX: Possible regolith feed. NASA-POWER-FSP: Possible future power option, itself developmental.

### NASA-ISRU-TRIDENT - The Regolith and Ice Drill for Exploring New Terrain (TRIDENT)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Designed to drill and thermally investigate subsurface material in the PRIME-1 payload.
- **Organization:** NASA / Honeybee Robotics.
- **Official evidence:** [SRC-DRILL](https://www.nasa.gov/missions/artemis/nasas-lunar-drill-technology-passes-tests-on-the-moon/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Partial mechanical/heater function tests on IM-2 lunar mission in March 2025.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Actual partial lunar hardware tests; extraction goals not fully established.
- **Mars applicability:** Possible drilling lessons only; this payload was not a Mars mining demonstration.
- **Limitations / uncertainties:** Short, constrained mission did not demonstrate a complete ice-mining chain.; Do not equate actuator checks with extraction of usable native water.
- **Design proposal - recommended game use:** Use as bounded drilling evidence; future drilling needs site knowledge and material handling.
- **Design proposal - supporting equipment:** Drill, auger/percussion system and heater; Power and thermal support; Gas/sample analysis and positioning.
- **Design proposal - dependencies:** NASA-ISRU-MSOLO: Associated gas-analysis instrument. NASA-SCIENCE-LCROSS: Prospecting evidence is separate from extraction.

### NASA-ISRU-MSOLO - Mass Spectrometer Observing Lunar Operations (MSOLO)

- **Kind / evidence:** hardware / demonstrated, reviewed 2026-11-15.
- **Actual function:** Measures gases near lunar surface operations.
- **Organization:** NASA / Honeybee Robotics.
- **Official evidence:** [SRC-DRILL](https://www.nasa.gov/missions/artemis/nasas-lunar-drill-technology-passes-tests-on-the-moon/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** IM-2 / PRIME-1 lunar operations in March 2025; early gas measurements included spacecraft/Earth contamination.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Detected gas is not automatically native lunar water.; Contamination attribution and incomplete mission scope constrain conclusions.
- **Design proposal - recommended game use:** Require sample provenance and contamination flags before declaring a usable deposit.
- **Design proposal - supporting equipment:** Mass spectrometer and inlet; Power, calibration and data processing; Operational context and contamination assessment.
- **Design proposal - dependencies:** NASA-ISRU-TRIDENT: Associated drilling investigation, not a proven refinery. NASA-SCIENCE-LOG: Retain observation context.

## 15. Moon and Mars environmental differences

### NASA-ENV-MOON - Moon surface environment

- **Kind / evidence:** environment_reference / research, reviewed 2026-11-15.
- **Actual function:** Provides the planetary context for lunar surface engineering.
- **Organization:** NASA Science.
- **Official evidence:** [SRC-MOON](https://science.nasa.gov/moon/facts/), [SRC-MOON-WEATHER](https://science.nasa.gov/moon/weather-on-the-moon/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Lunar observations, missions and NASA planetary reference synthesis.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Direct lunar environmental reference; surface gravity about one sixth of Earth's.
- **Mars applicability:** Comparison only; lunar conditions must not be copied to Mars.
- **Limitations / uncertainties:** Near-vacuum/exosphere is not breathable air; there is no ordinary atmospheric wind.; Temperature and sunlight depend on location, terrain and time; polar shadow is a distinct case.
- **Design proposal - recommended game use:** Use a site-specific scenario: vacuum operations, shadow/illumination and abrasive dust; tutorial ease comes from supplied support.
- **Design proposal - supporting equipment:** Site illumination and terrain data; Pressure protection; Power and thermal planning.
- **Design proposal - dependencies:** NASA-HAZARDS-FIVE: Risk review framework.

### NASA-ENV-MARS - Mars surface environment

- **Kind / evidence:** environment_reference / research, reviewed 2026-11-15.
- **Actual function:** Provides planetary atmosphere, dust and terrain context for Mars engineering.
- **Organization:** NASA Science.
- **Official evidence:** [SRC-MARS](https://science.nasa.gov/mars/facts/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Robotic Mars observations and NASA planetary reference synthesis.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Comparison only; no comparable lunar CO2 intake supply.
- **Mars applicability:** Direct Mars environmental reference; human partial-gravity health remains uncertain.
- **Limitations / uncertainties:** Thin CO2-rich atmosphere is not breathable and is not equivalent to lunar vacuum.; Dust and site/season variability affect operations; no settled seasonal liquid-water claim is adopted.
- **Design proposal - recommended game use:** Make later Mars atmospheric processing, dust and autonomy constraints explicit; no Earthlike outdoor breathing.
- **Design proposal - supporting equipment:** Atmospheric and site measurements; Pressure protection and filtration; Power/thermal planning and communication buffers.
- **Design proposal - dependencies:** NASA-ISRU-MOXIE: Atmospheric oxygen-production evidence. NASA-OPS-DELAY: Distant operations support.

## 16. Technologies being developed or demonstrated

### NASA-TECH-ARMADAS - Automated Reconfigurable Mission Adaptive Digital Assembly Systems (ARMADAS)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Develops robots and modular elements for automated structural assembly.
- **Organization:** NASA Ames Research Center.
- **Official evidence:** [SRC-ARMADAS](https://www.nasa.gov/automated-reconfigurable-mission-adaptive-digital-assembly-systems-armadas/), [SRC-ISAM-2026](https://assets.science.nasa.gov/content/dam/science/missions/isam/ISAM_State_of_Play_2026.pdf). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Earth robotic assembly demonstrations; 2026 ISAM status matrix lists ARMADAS capabilities as developing.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** An assembled test structure is not a pressure-qualified lunar habitat.; Joint strength, interfaces and full-system qualification remain distinct.
- **Design proposal - recommended game use:** Inform later modular construction concepts; do not equate blocks with instant habitable rooms.
- **Design proposal - supporting equipment:** Assembly robots and prepared components; Positioning, fasteners and control; Power and inspection equipment.
- **Design proposal - dependencies:** NASA-ROBOT-VALKYRIE: Manipulation research comparison only; not a specified ARMADAS component. NASA-POWER-BATTERY: Power support. NASA-HAB-MOONBASE: Habitation qualification remains separate.

### NASA-TECH-BLUE-ALCHEMIST - Blue Alchemist

- **Kind / evidence:** system / in_development, reviewed 2026-11-15.
- **Actual function:** Develops linked regolith processing and solar-cell/material production technologies.
- **Organization:** NASA Space Technology Mission Directorate.
- **Official evidence:** [SRC-SURFACE](https://www.nasa.gov/lunar-surface-technology/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** NASA-supported commercial development and ground demonstrations described by the surface-technology program.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Not an operational lunar solar-panel factory.; Integrated throughput and lifetime cannot be inferred from a technology overview.
- **Design proposal - recommended game use:** Keep as a later speculative manufacturing reference with multiple processing stages and qualification.
- **Design proposal - supporting equipment:** Regolith processing and electrolysis hardware; Material refinement and fabrication; Energy, controls and product testing.
- **Design proposal - dependencies:** NASA-ISRU-MRE: Related processing approach; not the identical reactor. NASA-POWER-SOLAR: Solar generation is an output application, not free startup energy.

### NASA-TECH-VIPER - Volatiles Investigating Polar Exploration Rover (VIPER)

- **Kind / evidence:** hardware / in_development, reviewed 2026-11-15.
- **Actual function:** Designed to prospect lunar polar volatiles and characterize resource context.
- **Organization:** NASA.
- **Official evidence:** [SRC-LTV-2026](https://www.nasa.gov/missions/moon-base/nasa-provides-progress-update-on-moon-base-rovers/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** October 2026 NASA update describes fully built hardware at Johnson undergoing final testing; no lunar deployment established.
- **Published TRL:** Not assigned. No explicit achieved configuration-specific TRL was transcribed from the cited evidence.
- **Moon applicability:** Intended polar survey, still Earth hardware in the reviewed update.
- **Mars applicability:** No direct Mars qualification.
- **Limitations / uncertainties:** Built hardware and delivery plans do not equal completed lunar prospecting.; Previous cancellation/replanning headlines alone do not describe the latest configuration.
- **Design proposal - recommended game use:** Reference future prospecting capability; no resource map should be declared verified by an unflown rover.
- **Design proposal - supporting equipment:** Rover, instruments and navigation; Power, thermal support and communications; Delivery and surface access.
- **Design proposal - dependencies:** NASA-SCIENCE-LCROSS: Earlier site-specific water evidence motivates prospecting. NASA-SCIENCE-LOG: Survey measurements need context.

### NASA-TECH-TRL - NASA Technology Readiness Levels framework

- **Kind / evidence:** standard / research, reviewed 2026-11-15.
- **Actual function:** Defines nine levels for describing maturity of a scoped technology.
- **Organization:** NASA Space Communications and Navigation.
- **Official evidence:** [SRC-TRL](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/technology-readiness-levels/). Source publication/update dates appear in the source index and JSON source_dates.
- **Actual testing or operation:** Assessment framework spanning laboratory, relevant and operational environments; not a hardware test itself.
- **Published TRL:** Not assigned. Not applicable as a single hardware readiness rating; no TRL assigned.
- **Moon applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Mars applicability:** Potential adaptation; surface qualification is not established by this entry.
- **Limitations / uncertainties:** Definitions do not assign ratings to catalog entries.; A flight-proven component does not automatically make a redesigned surface plant TRL 9.
- **Design proposal - recommended game use:** Use readiness only as evidence metadata; do not convert this registry into an automatic game unlock tree.
- **Design proposal - supporting equipment:** Scoped configuration and requirements; Documented test evidence; Authorized readiness assessment.
- **Design proposal - dependencies:** No other catalog entry is a mandatory prerequisite; the equipment above still applies.

## Evidence issues and status reconciliations

| ID | Evidence issue | Handling | Sources |
| --- | --- | --- | --- |
| ISSUE-WATER-BOUNDARY | Overview states about 90% water recovery, whereas a 2023 integrated BPA milestone reports 98%. | Preserve source/configuration boundaries; do not adopt either as a universal component efficiency. | [SRC-ECLSS](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/), [SRC-WATER](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/) |
| ISSUE-CHAPEA-STATUS | About page describes the Mission-2 start; newer article records completion on October 31, 2026. | Use the later completion report for status. Preserve publication Nov 9 / Details update Nov 5 discrepancy without guessing. | [SRC-CHAPEA-ABOUT](https://www.nasa.gov/humans-in-space/chapea/about-chapea/), [SRC-CHAPEA-2026](https://www.nasa.gov/missions/analog-field-testing/chapea/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/) |
| ISSUE-FSP-SCHEDULE | Older overview targets early 2030s; 2026 announcement describes development by 2030. | Treat the newer announcement as the newer stated goal, not achieved delivery; no fixed gameplay launch year or guaranteed power rating. | [SRC-FSP](https://www.nasa.gov/exploration-systems-development-mission-directorate/fission-surface-power/), [SRC-FSP-2026](https://www.nasa.gov/news-release/nasa-department-of-energy-to-develop-lunar-surface-reactor-by-2030/) |
| ISSUE-UWMS-COMMISSIONING | Installation and planned 2026 reactivation can be mistaken for demonstrated routine operation. | Record unresolved commissioning in the July 2026 report; no successful reactivation inferred from elapsed time. | [SRC-ECLSS-2026](https://ntrs.nasa.gov/citations/20260003280) |
| ISSUE-CADRE-SCHEDULE | Page contains an arrival year of 2026 but still labels mission Future. | Keep in_development; landing status is not independently confirmed by this evidence. | [SRC-CADRE](https://www.jpl.nasa.gov/missions/cadre/) |
| ISSUE-IPEX-TARGET | Excavation throughput targets differ across overview/project descriptions; TRL5 appears in a design-document title. | Omit numeric production rates and attained TRL; require scoped test/assessment evidence before using either. | [SRC-IPEX](https://www.nasa.gov/infrastructure-pilot-excavator/), [SRC-SURFACE](https://www.nasa.gov/lunar-surface-technology/) |
| ISSUE-MARS-WATER | General facts page includes an older seasonal briny-flow interpretation. | Exclude that interpretation from accepted claims; the registry supplies no settled present-day liquid-water yield. | [SRC-MARS](https://science.nasa.gov/mars/facts/) |
| ISSUE-CARD-INTERMEDIATE | Oxygen-extraction wording can obscure that the reported integrated prototype specifically confirmed carbon monoxide. | Distinguish reaction evidence, downstream oxygen conversion and stored breathable product. | [SRC-CARD](https://www.nasa.gov/centers-and-facilities/johnson/sunlight-extracts-oxygen-from-regolith-using-solar-chemistry/), [SRC-SURFACE](https://www.nasa.gov/lunar-surface-technology/) |

## Official source index

All sources were accessed on the review date. A missing date is an acknowledged evidence gap, not a fabricated publication date. Dates belong to the source, while an entry may describe an earlier event. Hub pages can mix future plans with historical results; linked specific reports take precedence for status. The twelve requested starting pages are retained, including context-only hubs.

| Source ID / official reference | Organization | Publication | Update | Date/context note |
| --- | --- | --- | --- | --- |
| [SRC-MOONBASE - Moon Base Systems](https://www.nasa.gov/moonbase-systems/) | NASA | not confirmed | 2026-06-11 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-ECLSS - Environmental Control and Life Support Systems (ECLSS)](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/) | NASA | not confirmed | 2025-04-04 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-JSC - JSC Life Support Subsystems](https://www.nasa.gov/reference/jsc-life-support-subsystems/) | NASA Johnson Space Center | not confirmed | 2026-01-22 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-SUITS - Spacesuits](https://www.nasa.gov/humans-in-space/astronauts/spacesuits/) | NASA | not confirmed | 2026-03-27 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-ROVERS - Suits and Rovers](https://www.nasa.gov/suits-and-rovers/) | NASA | not confirmed | 2026-07-09 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-SURFACE - Lunar Surface Technology](https://www.nasa.gov/lunar-surface-technology/) | NASA Space Technology Mission Directorate | not confirmed | 2026-11-05 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-HAZARDS - The Human Body in Space: Five Hazards](https://www.nasa.gov/hrp/hazards/) | NASA Human Research Program | not confirmed | 2026-06-12 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-RISKS - Human System Risks](https://www.nasa.gov/hhp/human-system-risks/) | NASA Human Health and Performance | not confirmed | 2025-03-20 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-PLANTS - Plant Biology Program / Hardware](https://science.nasa.gov/biological-physical/focus-areas/plant-biology/hardware/) | NASA Biological and Physical Sciences | not confirmed | 2023-08-15 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-CHAPEA-ABOUT - About CHAPEA](https://www.nasa.gov/humans-in-space/chapea/about-chapea/) | NASA Johnson Space Center | not confirmed | 2025-11-18 | Mission-2 start information is superseded by SRC-CHAPEA-2026 for completion status. |
| [SRC-MOXIE - NASA's Oxygen-Generating Experiment MOXIE Completes Mars Mission](https://www.nasa.gov/solar-system/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/) | NASA / JPL | 2023-09-06 | 2026-06-22 | Mission completion is a 2023 event; the 2026 page update is not another oxygen-production campaign. |
| [SRC-TRL - Technology Readiness Levels](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/technology-readiness-levels/) | NASA Space Communications and Navigation | 2023-09-27 | 2026-06-25 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-WATER - NASA Achieves Water Recovery Milestone on International Space Station](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/) | NASA | 2023-06-20 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-ECLSS-2026 - ISS as a Testbed for Exploration ECLSS: 2026 Status (ICES-2026-379)](https://ntrs.nasa.gov/citations/20260003280) | NASA Johnson Space Center / NTRS | 2026-07-12 | not confirmed | NTRS publication date, not its April acquisition or September metadata modification date. Planned reactivation is not confirmation of reactivation. |
| [SRC-QUEST - Quest Airlock](https://www.nasa.gov/international-space-station/quest-airlock/) | NASA | not confirmed | 2023-09-27 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-BVAD - Life Support Baseline Values and Assumptions Document](https://ntrs.nasa.gov/citations/20210024855) | NASA Johnson Space Center / NTRS | 2022-02-01 | not confirmed | Use report publication date; citation identifier starts with 2021 and repository metadata was modified in 2026. |
| [SRC-FOOD - Space Food Systems](https://www.nasa.gov/directorates/esdmd/hhp/space-food-systems/) | NASA Johnson Space Center | 2023-03-16 | 2026-03-10 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-FOOD-GAP - FN-102: Food shelf-life research gap](https://humanresearchroadmap.nasa.gov/gaps/gap.aspx?i=780) | NASA Human Research Roadmap | not confirmed | 2025-05-13 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-SOLAR - Power Up: Roll-Out Solar Arrays Boost Space Station Power Supply](https://www.nasa.gov/missions/station/iss-research/power-up-roll-out-solar-arrays-boost-space-station-power-supply/) | NASA | 2026-10-15 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-BATTERY - Spacewalkers Wrap Up Battery Work and Camera Installations](https://www.nasa.gov/blogs/spacestation/2021/02/01/spacewalkers-wrap-up-battery-work-and-camera-installations/) | NASA | 2021-02-01 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-FSP - Fission Surface Power](https://www.nasa.gov/exploration-systems-development-mission-directorate/fission-surface-power/) | NASA Glenn Research Center / DOE | not confirmed | 2025-09-08 | Older overview includes an early-2030s target; SRC-FSP-2026 records a newer 2030 development goal. Neither is deployment evidence. |
| [SRC-FSP-2026 - NASA, Department of Energy to Develop Lunar Surface Reactor by 2030](https://www.nasa.gov/news-release/nasa-department-of-energy-to-develop-lunar-surface-reactor-by-2030/) | NASA / DOE | 2026-01-13 | 2026-02-02 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-AXEMU - NASA Moon Mission Spacesuit Nears Milestone](https://www.nasa.gov/humans-in-space/nasa-moon-mission-spacesuit-nears-milestone/) | NASA Johnson Space Center / Axiom Space | 2026-02-12 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-TOOLS - Spacewalking Tools](https://www.nasa.gov/suits-and-rovers/spacewalking-tools/) | NASA | not confirmed | 2025-04-18 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-EDS - Blue Ghost Begins Surface Operations, Captures Descent Video, Sunrise](https://www.nasa.gov/blogs/missions/2025/03/04/blue-ghost-begins-surface-operations-captures-descent-video-sunrise/) | NASA Kennedy Space Center / CLPS | 2025-03-04 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-RAD - Radiation Measurements on Mars](https://science.nasa.gov/resource/radiation-measurements-on-mars/) | NASA / JPL | not confirmed | 2024-11-02 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-SRAG - How NASA Protects Astronauts from Space Radiation](https://srag.jsc.nasa.gov/spaceradiation/how/how.cfm) | NASA Johnson Space Center Space Radiation Analysis Group | not confirmed | not confirmed | No publication/update date was confirmed in the inspected page; null is intentional. |
| [SRC-EXERCISE - OCHMO-TB-031 Exercise Overview](https://www.nasa.gov/ochmo-tb-031-exercise-overview-2/) | NASA Office of the Chief Health and Medical Officer | not confirmed | 2026-04-02 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-CV - Risk of Cardiovascular Adaptations (CV Risk)](https://www.nasa.gov/directorates/esdmd/hhp/cv-risk/) | NASA Human Health and Performance | 2025-03-11 | 2025-06-13 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-SLEEP - Sleep Loss, Circadian Desynchronization, and Work Overload Risk](https://www.nasa.gov/directorates/esdmd/hhp/risk-of-performance-decrements-and-adverse-health-outcomes-resulting-from-sleep-loss-circadian-desynchronization-and-work-overload/) | NASA Human Health and Performance | 2025-03-11 | 2025-09-16 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-SLEEP-RESEARCH - Science in Space: Sleep on Station](https://www.nasa.gov/humans-in-space/science-in-space-week-of-sept-15-2023-sleep-on-station/) | NASA ISS Research | 2023-09-15 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-IMMUNE - Altered Immune Response Risk](https://www.nasa.gov/directorates/esdmd/hhp/immune-risk/) | NASA Human Health and Performance | 2025-03-11 | 2025-09-10 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-HFBP - Human Factors and Behavioral Performance](https://www.nasa.gov/hrp/human-factors-and-behavioral-performance/) | NASA Human Research Program | not confirmed | 2026-09-03 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-CHAPEA-2026 - CHAPEA Mission 2 Crew Reflects After 378 Days on Simulated Mars](https://www.nasa.gov/missions/analog-field-testing/chapea/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/) | NASA Johnson Space Center | 2026-11-09 | 2026-11-05 | Page labels publication Nov 9 but Details last-updated Nov 5. Preserve both as displayed; mission egress Oct 31, 2026. |
| [SRC-MEDICAL - FAQ: The Real Story About Astronaut Health Care in Space](https://www.nasa.gov/missions/station/faq-the-real-story-about-astronaut-health-care-in-space/) | NASA | 2024-11-21 | 2025-03-17 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-ECHO - Advanced Health Tech Research Continues to Protect Astronaut Health](https://www.nasa.gov/blogs/spacestation/2026/09/24/advanced-health-tech-research-continues-to-protect-astronaut-health/) | NASA ISS Research | 2026-09-24 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-LTV-2026 - NASA Provides Progress Update on Moon Base Rovers](https://www.nasa.gov/missions/moon-base/nasa-provides-progress-update-on-moon-base-rovers/) | NASA | 2026-10-20 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-CADRE - Cooperative Autonomous Distributed Robotic Exploration (CADRE)](https://www.jpl.nasa.gov/missions/cadre/) | NASA JPL | not confirmed | not confirmed | Page status is Future; its stated 2026 arrival is a schedule, not evidence of landing. |
| [SRC-ROBOTICS - Reliable Robots: Meet Johnson's Dexterous Robotics Team](https://www.nasa.gov/general/reliable-robots-meet-johnsons-dexterous-robotics-team/) | NASA Johnson Space Center | 2026-09-28 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-SUBT - Team CoSTAR: DARPA Subterranean Challenge](https://www.jpl.nasa.gov/capabilities/robotics/nebula/subt-challenge/) | NASA JPL | not confirmed | not confirmed | No publication/update date was confirmed in the inspected page; null is intentional. |
| [SRC-DSN - Deep Space Network](https://www.nasa.gov/communicating-with-missions/dsn/) | NASA Space Communications and Navigation / JPL | not confirmed | 2026-10-15 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-LUNANET - LunaNet Interoperability Specification](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/lunanet-interoperability-specification/) | NASA / ESA / JAXA | not confirmed | 2025-02-10 | Version 5 is dated February 7, 2025; that is a specification version date, not necessarily page publication. |
| [SRC-LUGRE - NASA Successfully Acquires GPS Signals on Moon](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/nasa-successfully-acquires-gps-signals-on-moon/) | NASA / Italian Space Agency | 2025-03-04 | not confirmed | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-AUTONOMY - Safe Human Expeditions Beyond Low Earth Orbit (LEO)](https://ntrs.nasa.gov/citations/20220002905) | NASA Engineering and Safety Center / NTRS | 2022-02-01 | not confirmed | NTRS publication date; acquisition date is February 18, 2022. Technical assessment, not a flight qualification. |
| [SRC-DRILL - NASA's Lunar Drill Technology Passes Tests on the Moon](https://www.nasa.gov/missions/artemis/nasas-lunar-drill-technology-passes-tests-on-the-moon/) | NASA / Honeybee Robotics | 2025-04-29 | 2026-06-22 | Describes partial PRIME-1 / IM-2 tests in March 2025, not a new 2026 lunar drilling campaign. |
| [SRC-LCROSS - LCROSS](https://science.nasa.gov/mission/lcross/) | NASA Ames Research Center | not confirmed | 2024-11-03 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-IPEX - Infrastructure Pilot Excavator](https://www.nasa.gov/infrastructure-pilot-excavator/) | NASA Kennedy Space Center | not confirmed | 2026-11-09 | A TRL5 Design Overview title is not treated as a published attained TRL for the complete current vehicle. |
| [SRC-CARD - Sunlight Extracts Oxygen From Regolith Using Solar Chemistry](https://www.nasa.gov/centers-and-facilities/johnson/sunlight-extracts-oxygen-from-regolith-using-solar-chemistry/) | NASA Johnson / Glenn / Kennedy / Sierra Space | 2026-02-13 | 2026-06-22 | Dates refer to the article or report, not necessarily the hardware event. |
| [SRC-MOON - Moon Facts](https://science.nasa.gov/moon/facts/) | NASA Science | not confirmed | 2026-02-12 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-MOON-WEATHER - Weather on the Moon](https://science.nasa.gov/moon/weather-on-the-moon/) | NASA Science | not confirmed | 2026-02-12 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-MARS - Mars Facts](https://science.nasa.gov/mars/facts/) | NASA Science | not confirmed | 2026-07-10 | Only atmosphere, dust and planetary-context claims are used. Do not adopt the page's older seasonal liquid-water interpretation as settled evidence. |
| [SRC-SAMPLE - Documentation of Apollo 15 samples](https://ntrs.nasa.gov/citations/19720021173) | NASA / USGS / NTRS | not confirmed | not confirmed | Official NTRS indexed abstract inspected; direct record fetch timed out. No exact publication day confirmed; historical 1972 citation is not a full date. |
| [SRC-CURATION - The Collection, Usage, and Preliminary Examination of the Apollo Sample Suite: Lessons for Artemis](https://ntrs.nasa.gov/citations/20240009312) | NASA Johnson Space Center Astromaterials Acquisition and Curation / NTRS | not confirmed | not confirmed | NTRS provides July 22, 2024 acquisition and a July 29-August 2 conference, but no explicit publication day; those dates are not substituted. |
| [SRC-INSTRUMENTS - Perseverance Science Instruments](https://science.nasa.gov/mission/mars-2020-perseverance/science-instruments/) | NASA / JPL | not confirmed | 2026-10-27 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-MRE - NASA Kennedy Breathes Life into Moon Soil Testing](https://www.nasa.gov/centers-and-facilities/kennedy/nasa-kennedy-breathes-life-into-moon-soil-testing/) | NASA Kennedy Space Center / Lunar Resources | 2025-05-05 | not confirmed | Dates describe the source, not necessarily the experiment. |
| [SRC-ARMADAS - Automated Reconfigurable Mission Adaptive Digital Assembly Systems (ARMADAS)](https://www.nasa.gov/automated-reconfigurable-mission-adaptive-digital-assembly-systems-armadas/) | NASA Ames Research Center | not confirmed | 2026-07-14 | Page update verified separately from hardware event dates; original publication day was not confirmed. |
| [SRC-ISAM-2026 - 2026 ISAM State of Play](https://assets.science.nasa.gov/content/dam/science/missions/isam/ISAM_State_of_Play_2026.pdf) | NASA | not confirmed | not confirmed | 2026 edition inspected through indexed report text; exact publication day not confirmed. |
| [SRC-MUSCLE - Reduced Muscle Size, Strength, and Endurance Risk](https://www.nasa.gov/directorates/esdmd/hhp/muscle-risk/) | NASA Human Health and Performance | 2025-03-11 | 2025-08-20 | Dates describe the source; cited observations concern primarily microgravity missions. |
| [SRC-BONE - Bone Fracture due to Spaceflight-induced Changes to Bone Risk](https://www.nasa.gov/directorates/esdmd/hhp/risk-of-bone-fracture-due-to-spaceflight-induced-changes-to-bone/) | NASA Human Health and Performance | 2025-03-11 | 2025-11-13 | Dates describe the source; partial-gravity long-term outcomes remain uncertain. |
| [SRC-ATMOSPHERES-2026 - Impacts of Reduced Pressure Atmospheres on Environmental Control and Life Support Systems (ECLSS) Architectures](https://ntrs.nasa.gov/citations/20260003925) | NASA Engineering and Safety Center / Langley / Johnson / NTRS | 2026-05-01 | not confirmed | NTRS publication date, not acquisition May 6 or metadata modification September 21. Assessment addresses adaptation and recertification, not lunar deployment. |

## Maintenance contract

Never repurpose or recycle a stable entry ID. Update evidence with a dated rationale; retire a record explicitly rather than silently assigning its ID to different hardware. Preserve source publication dates separately from page updates. Search for newer primary milestone evidence before changing development status; an expired target year or a repository project-end field is insufficient.

This edition is a documented public-source baseline as of November 15, 2026, not an exhaustive NASA procurement database, live program-status service or medical standard. Missing dates, incomplete qualification evidence and unconfirmed current service remain explicit limitations. No system implementation, asset generation, audio or Phase 0.8B work is authorized by this catalog.
