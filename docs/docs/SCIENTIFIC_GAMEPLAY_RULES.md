# Scientific Gameplay Rules

Science baseline version: **1.0.0**. Evidence cutoff: **2026-11-15**.

These are project design constraints for future approved phases. They implement no gameplay and establish no clinical thresholds or balancing coefficients. Read the [Science Bible](SCIENCE_BIBLE.md), [NASA Technology Catalog](NASA_TECHNOLOGY_CATALOG.md) and [canonical research registry](../resources/research/nasa_technology_catalog.json) before applying them. A catalog recommendation is a proposal, not a promise of implementation.

## Evidence-to-design contract

Each future scientific system needs a short design record containing:

1. Research IDs and the exact verified capability being used, including its actual test environment.
2. Assumptions beyond that evidence: scale-up, automation, lone-crew operation, surface qualification or fictional hardware.
3. Inputs, outputs, byproducts, units, operating conditions, capacities, startup reserves and supporting equipment.
4. Uncertainties and intentionally simplified behavior, with separate scientific and game-time scales.
5. Acceptance scenarios for nominal operation, depleted inputs, full outputs, power interruption, damaged equipment and recovery.

Do not promote research to operation by changing a label. Future targets, funding, a completed review and hardware delivered to a lab are not successful lunar deployment. Numeric TRLs require published achieved ratings with scope and date; they do not automatically become game progression tiers. [NASA's framework](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/technology-readiness-levels/) is the reference.

## Resources and conservation

Every future production step must have explicit material inputs and outputs. Recovery cannot create mass. Track losses, unusable waste, stored intermediate products and contamination. Energy supply, storage, distribution and waste heat are separate. A chain can simplify chemistry for readability only when its design record says what was omitted.

Do not let recovery loops bootstrap from empty tanks. Delivered startup inventories and an external energy source must exist. A processing component cannot run without its feed, power, operating conditions and output capacity. Full storage should stop or deliberately vent/discard production according to a documented rule; overflow must not silently duplicate inventory. Research dependencies illustrate interfaces and are not complete equipment recipes.

| Future concern | Required distinction | Research references |
| --- | --- | --- |
| Habitat atmosphere | Pressure, oxygen, CO2, contamination and circulation | NASA-GAS-CONTROL, NASA-AIR-CDRA, NASA-AIR-TRACE |
| Oxygen electrolysis | Water/electricity inputs; oxygen/hydrogen outputs | NASA-O2-OGA |
| Sabatier recovery | Hydrogen and CO2 input; water and methane output; incomplete closure | NASA-CHEM-SABATIER |
| Water processing | Wastewater, intermediate recovered water, potable water and residual waste | NASA-WATER-UPA, NASA-WATER-WPA, NASA-WATER-BPA |
| Food | Delivered meals, storage integrity, preparation water and dietary adequacy | NASA-FOOD-PACKAGED, NASA-FOOD-LONGEVITY |
| Crops | Seeds, nutrients, water, lighting energy, time and controlled conditions | NASA-PLANT-VEGGIE, NASA-PLANT-APH |
| Electrical supply | Generation rate versus stored energy and discharge limits | NASA-POWER-SOLAR, NASA-POWER-BATTERY |
| Thermal management | Heat generation, transfer, rejection, insulation and heating | NASA-THERMAL-LOOPS, NASA-THERMAL-PASSIVE |
| Mining / ISRU | Prospecting, excavation, transport, processing, qualification and storage | NASA-SCIENCE-LCROSS, NASA-ISRU-IPEX, NASA-ISRU-CARD, NASA-ISRU-MRE |

These distinctions follow NASA's [ECLSS overview](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/), [water recovery demonstration](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/) and [engineering baseline](https://ntrs.nasa.gov/citations/20210024855); exact game quantities remain future design choices. Never copy the integrated 98% recovery milestone into every filter or ignore consumables.

## Habitat and EVA boundaries

A rendered habitat, floor, oxygen tank or solar array is not functional infrastructure just because artwork exists. Future behavior must be separate from sprite canvas, anchor, tile footprint and visual state. A module becomes habitable only through explicitly modeled or declared supporting services.

Airlock transitions must preserve gas accounting and readiness. Door/interlock and pressure states should be understandable, while real decompression/prebreathe timings remain outside this phase. Suit oxygen, CO2 treatment, power, thermal control, integrity and maintenance are distinct concerns. Neither the astronaut's inventory window nor a camera change should refill any reserve.

Dust can contaminate selected interfaces and impair equipment according to a documented model. EDS is surface-specific mitigation, not a global dust-disable switch. Radiation sensors provide information; shielding changes exposure and cannot promise a particular health outcome. Use [EDS's actual lunar demonstration](https://www.nasa.gov/blogs/missions/2025/03/04/blue-ghost-begins-surface-operations-captures-descent-video-sunrise/) and [NASA radiation guidance](https://srag.jsc.nasa.gov/spaceradiation/how/how.cfm) within their stated limits.

## Human condition and medical uncertainty

Keep short-term fatigue, longer-term conditioning, injury, cardiovascular condition, sleep, emotion, immune changes and radiation exposure distinct in future design. An indicator may aggregate information for readability, but its label must not imply a NASA-validated clinical quantity. 'Defense/body condition' is currently reserved UI language, not a measured immunity percentage.

Do not assign guaranteed heart attacks, infections, fractures, psychiatric disorders or cancer to fixed timers or a single meter threshold. Exposure and risk are different from diagnosis. The [cardiovascular](https://www.nasa.gov/directorates/esdmd/hhp/cv-risk/), [immune](https://www.nasa.gov/directorates/esdmd/hhp/immune-risk/) and [bone](https://www.nasa.gov/directorates/esdmd/hhp/risk-of-bone-fracture-due-to-spaceflight-induced-changes-to-bone/) records retain important uncertainty. Avoid linear extrapolation from selected ISS populations to a solitary astronaut in partial gravity.

Rest, exercise, hygiene and adequate nutrition may be represented as risk mitigation and performance support. They are not universal cures. Do not claim that a fixed exercise minigame guarantees preserved muscle or that one sleep restores every long-term condition. Separate game time compression from evidence about biological timescales. No clinical doses, real emergency treatment instructions or unreviewed numerical health thresholds are established here.

Medical sensors produce observations with limits. They do not automatically identify a disease or authorize treatment. A later emergency interaction may abstract environment assessment, protective actions and contacting support, but must be separately approved and sourced. [EchoFinder-2](https://www.nasa.gov/blogs/spacestation/2026/09/24/advanced-health-tech-research-continues-to-protect-astronaut-health/) demonstrates a research direction for assistance, not an autonomous robotic physician.

Psychology should reflect workload, rest, isolation and meaningful activity without guaranteeing mental illness. One protagonist with Chiwis and T is a fictional mission configuration. Robot companionship is not an established substitute for all human relationships or behavioral care. [CHAPEA](https://www.nasa.gov/missions/analog-field-testing/chapea/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/) is a four-person Earth analog, not direct evidence for this narrative.

## Moon tutorial and Mars campaign

The Moon tutorial teaches dependencies through finite delivered supplies, short excursions, clear equipment states and forgiving scenario margins. It must not teach outdoor breathing, wind-driven lunar weather, limitless solar generation in darkness, globally available ice or a ready-made lunar industrial economy.

Mars should expand logistics, autonomous operation and uncertainty. Its thin CO2 atmosphere can be a processing feedstock, not breathable air. MOXIE-like oxygen production still needs intake/compression, energy, thermal control, product handling and scale-up; it cannot be placed unchanged in lunar vacuum. [MOXIE's completed demonstration](https://www.nasa.gov/solar-system/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/) does not prove crew-scale propellant production or liquid-oxygen storage.

Illumination, dust and terrain are site-dependent. Do not reuse one planetary temperature, solar supply or ore yield for every tile. No deterministic health multiplier is derived from gravity. The [Moon](https://science.nasa.gov/moon/facts/) and [Mars](https://science.nasa.gov/mars/facts/) references support different environments; graphical isometric coordinates remain the existing 64x32 native 2D grid.

## Robots, communications and scientific work

Chiwis is a robotic dog on the Moon and Mars. T is the later humanoid Mars robot. Their later capabilities must specify sensing range/uncertainty, tools, access, energy, heat, wear and failure boundaries. They cannot teleport samples, work outside their tools' capabilities, reveal unsurveyed deposits or provide guaranteed clinical care. Current companion behavior stays unchanged in this phase.

Mars support is asynchronous and may be unavailable. Do not show instantaneous Earth teleoperation, medical consultation or omnipresent navigation service unless explicitly labeled a fiction. DSN is a network with access constraints; LunaNet is a specification; LuGRE's lunar fix is a bounded demonstration, not proof of universal lunar GPS. Use NASA-COMMS-DSN, NASA-COMMS-LUNANET, NASA-NAV-LUGRE and NASA-OPS-DELAY when designing these systems. Communication delay depends on geometry; no single fixed Mars latency is locked here.

Scientific collection preserves sample identity, location, context and contamination. A composition reading is not automatically recoverable ore, and an organic signature is not proof of life. Excavation is not chemical processing. The brief PRIME-1 test must not be displayed as a demonstrated water refinery. NASA-SCIENCE-LOG, NASA-SAMPLE-PROVENANCE, NASA-SCIENCE-PIXL, NASA-SCIENCE-SHERLOC and NASA-ISRU-MSOLO establish these boundaries.

## Data ownership and future acceptance

The research registry is excluded from Godot scanning and never replaces ItemDefinition, RuntimeInventory, terrain kinds or other runtime state. Research IDs belong in design records, developer documentation and optional future reference material; ordinary item descriptions can remain concise English game text. A future gameplay definition may refer to evidence in accompanying design metadata without embedding citations into the player-facing description.

Preserve the existing same-world state across Player/Base Management modes, stable IDs, partial pickup remainders, modal safety, cameras, terrain and character systems. No future resource system may hide authoritative quantities in HUD widgets, animation frames or camera nodes. Continue typed GDScript and modular components when implementation is separately authorized.

For a future approved resource system, verify depleted input, power loss, contaminated feed, output capacity, restart reserves and conservation. For a health abstraction, verify that UI distinguishes observations from risk and diagnosis, uncertainty remains visible where needed, and neither a threshold nor RNG presents an unestablished medical outcome as scientific certainty. These are future acceptance requirements, not new tests or runtime systems added now.

This phase ends with research, documentation, registry validation and project instructions. No gameplay, PixelLab generation, audio, commits or Phase 0.8B begins automatically.
