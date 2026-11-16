# Science Bible

Science baseline version: **1.0.0**. Evidence cutoff: **2026-11-15**.

This is the permanent scientific reference policy for On My Way to Home. It supports future design decisions; it implements no survival, construction, medical, production or robot systems. The game remains fully native 2D isometric pixel art. Existing art dimensions and rendering standards remain unchanged.

Use the [NASA Technology Catalog](NASA_TECHNOLOGY_CATALOG.md) for individual records and sources, the [research JSON](../resources/research/nasa_technology_catalog.json) for structured evidence, and the [Scientific Gameplay Rules](SCIENTIFIC_GAMEPLAY_RULES.md) for project interpretations. All three must be consulted before implementing scientific systems.

## Evidence and maturity

Prioritize NASA, JPL, NASA NTRS and NASA center publications. Search for later primary milestone reports before carrying a schedule or development claim forward. A source's publication, page update, repository acquisition and actual test date are different. This edition checks evidence available through November 15, 2026, not the remainder of November. Missing confirmed dates remain null.

Every catalog record identifies function, organization, official references and dates, evidence status, actual test environment, applicability, limitations, proposed game use, supporting equipment and dependencies. Hardware, procedures, risk references, standards and analog studies have distinct entry kinds. A risk category is not a purchasable technology.

Operational means documented operation or flight heritage in the stated setting. Demonstrated means a bounded test; in_development means remaining development or qualification; research includes analogs, investigations and reference frameworks. Historical operation does not guarantee uninterrupted availability today. Neither an Earth prototype nor an artist's Moon-base concept establishes deployed lunar infrastructure.

Assign a numeric TRL only when a primary source explicitly reports an achieved level for a defined configuration. Preserve the assessment date, source, scope and environment. Never infer TRL from a success headline, a design-review title, an institution's capability list or a future target. This baseline transcribes no achieved numeric TRLs; null is not zero. The [NASA readiness definitions](https://www.nasa.gov/directorates/somd/space-communications-navigation-program/technology-readiness-levels/) define the framework rather than rating our entries.

## Human and robot premise

There is one human protagonist, no human colonists, Chiwis the robotic dog, and T the later humanoid Mars robot. Moon tutorial comes before the harder Mars campaign. This is a narrative constraint, not NASA validation of a lone-person expedition. Real crew/ground-supported operations cannot automatically be assigned to one astronaut.

Chiwis and T need explicit energy, thermal, sensing, communication, tooling and maintenance capabilities in future designs. They do not consume human food or breathing oxygen merely because they have animal/human forms. Task autonomy is bounded; a robot cannot know unsurveyed terrain or diagnose every disease. Earth robotics research inspires their capabilities; it does not establish lunar-qualified robotic dogs or operational Mars humanoids. See NASA's [2026 Johnson robotics overview](https://www.nasa.gov/general/reliable-robots-meet-johnsons-dexterous-robotics-team/) and JPL's [Earth subterranean robotics demonstrations](https://www.jpl.nasa.gov/capabilities/robotics/nebula/subt-challenge/).

The tutorial is easier through curated supplies, short tasks, conservative margins and nearby support assumptions. That is game design; the Moon itself is hazardous. Mars difficulty should arise from longer support delays, greater autonomy and tighter logistics rather than invented guaranteed diseases.

## Atmosphere, pressure and oxygen

Treat cabin pressure, oxygen, CO2, trace contaminants, humidity and circulation as related but different concerns. Oxygen production does not remove all contaminants. CO2 removal does not generate oxygen. Airlocks need an isolated pressure transition and gas inventory; recycling cannot make every opening lossless. NASA's [ECLSS overview](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/) describes ISS oxygen electrolysis, molecular-sieve CO2 removal and partial water recovery through Sabatier chemistry.

Do not describe the complete habitat as a closed, self-sufficient ecosystem. ISS flight heritage does not establish a fully operational lunar habitat. NASA's [Moon Base systems](https://www.nasa.gov/moonbase-systems/) are future architecture and development context. Delivered startup gas, water, food, power capability and spare parts remain explicit scenario assumptions.

Cabin pressure and oxygen fraction also affect material compatibility and fire risk. A [May 2026 NASA engineering assessment](https://ntrs.nasa.gov/citations/20260003925) identifies redesign, testing and recertification needs when adapting ISS hardware to reduced-pressure exploration atmospheres. Do not treat heritage equipment as qualified merely by matching an oxygen inventory; no operating pressure/composition recipe is selected here.

## Water, sanitation and food

Keep potable water, untreated wastewater, intermediate recovery products and residual waste distinct. Recovery requires processing, quality checks, consumables and energy. The generic ECLSS overview's roughly 90% recovery statement and the [2023 integrated 98% milestone](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/) describe different configurations/boundaries; neither is a universal component efficiency. A percentage never implies zero makeup water.

Installation is not commissioning: the [2026 exploration ECLSS status paper](https://ntrs.nasa.gov/citations/20260003280) still describes UWMS demonstration issues and planned reactivation. Do not infer successful reactivation just because its planned date has passed.

Delivered meals are the baseline food source. Storage condition, packaging, acceptability and nutrient retention matter; NASA's [Space Food Systems](https://www.nasa.gov/directorates/esdmd/hhp/space-food-systems/) distinguishes flight food from longer-duration research. Five-year food capability is a research goal, not a blanket warranty. [Veggie and APH](https://science.nasa.gov/biological-physical/focus-areas/plant-biology/hardware/) support plant research; neither proves a complete calorie supply or a closed oxygen/food loop. Future crops need light, time, nutrients, water, environmental control and hygiene.

## Power and thermal control

Keep power generation, energy storage and electrical distribution separate. A battery stores energy; it is not a generator. Shadow, illumination and local installation constrain solar supply. Flight heritage for [ISS roll-out arrays](https://www.nasa.gov/missions/station/iss-research/power-up-roll-out-solar-arrays-boost-space-station-power-supply/) does not prove an unattended lunar array can ignore dust or night.

Equipment and people produce heat. Cooling requires a heat path and a sink; insulation is not infinite refrigeration. Treat radiator placement, coolant integrity and freezing/overheating as distinct design concerns. NASA's [life-support engineering baseline](https://ntrs.nasa.gov/citations/20210024855) supplies context, not ready-to-copy game coefficients.

Fission surface power remains development. The [January 2026 NASA/DOE announcement](https://www.nasa.gov/news-release/nasa-department-of-energy-to-develop-lunar-surface-reactor-by-2030/) sets a 2030 development goal; the older overview says early 2030s. Neither establishes an installed Moon reactor, a final plant rating or a guaranteed delivery date.

## Suits, dust and exposure

Suits provide a pressure boundary and life support, with limited consumables and maintenance. Orbital EMU heritage does not establish lunar dust endurance. [AxEMU's February 2026 milestone](https://www.nasa.gov/humans-in-space/nasa-moon-mission-spacesuit-nears-milestone/) concerns Earth testing and review, not deployed lunar operation.

Dust mitigation is surface-specific. The [March 2025 EDS demonstration](https://www.nasa.gov/blogs/missions/2025/03/04/blue-ghost-begins-surface-operations-captures-descent-video-sunrise/) established real lunar removal on selected surfaces; it did not make all seals, optics and suits immune. Radiation monitoring is not shielding. [NASA radiation operations](https://srag.jsc.nasa.gov/spaceradiation/how/how.cfm) use location, shielding and event information; mitigation reduces exposure without guaranteeing medical outcomes.

## Health, sleep and psychology

Separate fatigue, conditioning, injury, cardiovascular health, sleep, psychological state, immune response and radiation exposure. They interact but are not interchangeable values. Existing HUD labels reserve presentation space; they do not establish scientific units or clinical diagnoses.

ISS evidence primarily concerns microgravity, selected crews and specific countermeasures. Long-term partial-gravity health effects cannot be obtained by multiplying an ISS rate by local gravity. NASA's [muscle](https://www.nasa.gov/directorates/esdmd/hhp/muscle-risk/), [bone](https://www.nasa.gov/directorates/esdmd/hhp/risk-of-bone-fracture-due-to-spaceflight-induced-changes-to-bone/) and [cardiovascular](https://www.nasa.gov/directorates/esdmd/hhp/cv-risk/) risk records preserve important remaining uncertainties.

Sleep and workload influence performance, but one missed rest period does not guarantee an accident or disease. Immune changes are not equivalent to a known numerical loss of disease resistance: NASA explicitly notes uncertainty about susceptibility in its [immune-risk evidence](https://www.nasa.gov/directorates/esdmd/hhp/immune-risk/). Do not portray emotional distress as inevitable psychiatric illness or robot companionship as a validated cure.

CHAPEA is an Earth analog. [Mission 2 ended October 31, 2026](https://www.nasa.gov/missions/analog-field-testing/chapea/chapea-mission-2-crew-reflects-after-378-days-on-simulated-mars/); completion does not establish a Mars habitat or reproduce Mars gravity/radiation. Its four-person study cannot validate this game's one-human premise. Medical monitoring and assisted imaging are not omniscient diagnosis; [EchoFinder-2's 2026 ISS study](https://www.nasa.gov/blogs/spacestation/2026/09/24/advanced-health-tech-research-continues-to-protect-astronaut-health/) still used real-time ground monitoring. This project provides no real treatment, drug-dosing or emergency-care instructions.

## Planet-specific constraints

| Concern | Moon | Mars | Design implication |
| --- | --- | --- | --- |
| Ambient atmosphere | Near-vacuum, tenuous exosphere; not breathable | Thin, CO2-rich; not breathable | Both need pressure protection; MOXIE-like atmospheric intake is a Mars pathway |
| Illumination / dust | Terrain and polar shadow matter; no ordinary atmospheric wind | Atmospheric dust, storms and season/site variation matter | Separate site/season assumptions and solar budgets |
| Resources | Ice evidence is localized, especially relevant to cold polar terrain | Atmospheric CO2 is demonstrated feedstock for experimental oxygen production | Prospect and characterize; do not assume universal accessible water |
| Gravity evidence | Reduced gravity, about one sixth of Earth's | Reduced gravity, different from Moon and ISS microgravity | Separate movement abstraction from unresolved long-term health effects |
| Support | Shorter Earth distance, still constrained by geometry and infrastructure | Geometry-dependent communication delay and limited rapid return | Local procedures and autonomy become more important on Mars |

Environmental basis: [Moon facts](https://science.nasa.gov/moon/facts/), [lunar weather](https://science.nasa.gov/moon/weather-on-the-moon/), [Mars facts](https://science.nasa.gov/mars/facts/) and [NASA Earth-independent operations assessment](https://ntrs.nasa.gov/citations/20220002905). The catalog excludes the Mars facts page's older seasonal briny-flow interpretation; no current liquid-water production assumption follows from it.

## Science, ISRU and future changes

Keep measurement, geological interpretation, resource estimate and industrial product separate. Samples need provenance and contamination context. Organic signatures do not alone prove life. Prospecting evidence at one crater is not a global ore map.

[MOXIE](https://www.nasa.gov/solar-system/nasas-oxygen-generating-experiment-moxie-completes-mars-mission/) is a completed small Mars oxygen demonstration. [CaRD](https://www.nasa.gov/centers-and-facilities/johnson/sunlight-extracts-oxygen-from-regolith-using-solar-chemistry/) is an Earth integrated prototype confirming carbon monoxide chemistry; downstream oxygen production/storage must remain explicit. [MRE vacuum testing](https://www.nasa.gov/centers-and-facilities/kennedy/nasa-kennedy-breathes-life-into-moon-soil-testing/) used simulant. [PRIME-1's brief lunar tests](https://www.nasa.gov/missions/artemis/nasas-lunar-drill-technology-passes-tests-on-the-moon/) do not establish a working water mine. No complete lunar oxygen factory is declared operational here.

Before implementing a future scientific feature, record its research IDs, accepted facts, unresolved evidence, proposed abstractions, units, dependencies, reserves and failure boundaries in that phase's design/report. Recheck development status and numerical claims against newer primary evidence. Version the registry and update its generated catalog together. Keep citations in research/design records, separate from ordinary item descriptions. Changing this reference does not authorize gameplay, audio, PixelLab jobs or Phase 0.8B.
