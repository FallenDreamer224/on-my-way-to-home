# Phase 0.8E2 — Greenhouse and Daily Life Systems

Date: 2026-11-15. Engine: Godot 4.7.2. Native 2D, 64x32 terrain and 960x540 logical UI are preserved. Phase 0.8F1 has not begun.

## Implemented architecture

`DailyLife` is a persistent child of the existing UtilityService. It owns two logical growing trays, finite delivered cargo reserves, nutrients, crop state, routine jobs, completion logs and waste counters. `DailyLifePanel` composes native Controls with the existing development theme; no art or audio was created. Existing habitat stations open it through the same validated interaction transaction and PlayerSession modal gate used by utility terminals.

`resources/config/daily_life.json` supplies the crop definition, frame-independent simulation duration, resource costs, yield, environmental setpoints, delivered reserves, activity durations and repeat cooldown. The single astronaut's existing RuntimeInventory registers four stable definitions: Greens Seed, Fresh Greens, Dry Ration and Prepared Meal. No second inventory is created.

The astronaut still starts with the established empty inventory. Collect supplies at the **Cargo** station: six seeds and six dry rations are delivered reserves, transferred only where inventory space permits. Exact remainders stay in cargo; repeated requests cannot duplicate supplies. Nutrient stock starts at twelve abstract supply units in the greenhouse.

UtilityService emits before-step and after-step signals around its existing fixed step. Growing trays request the shared 120 W light/pump device before dispatch, then grow only if the dispatcher actually powered it. Demand never overrides the operator's enabled switch, faults or maintenance. Delivered light/pump electricity enters the existing Wh and J ledgers; no UI-owned power or energy bypass exists.

## Scientific references and abstractions

The Science Bible, Scientific Gameplay Rules, catalog and registry were consulted. Relevant primary sources were checked online on 2026-11-15:

- **NASA-PLANT-VEGGIE / NASA-PLANT-APH:** NASA's [plant hardware reference](https://science.nasa.gov/biological-physical/focus-areas/plant-biology/hardware/) describes Veggie's LEDs, nutrient/water support, and APH's controlled environmental research. These are ISS research references, not proof of an operational lunar hydroponic farm or a complete diet.
- NASA's [Veggie fact sheet](https://www.nasa.gov/wp-content/uploads/2019/04/veggie_fact_sheet_508.pdf) reports the first lettuce crop's **33 days** of growth in 2014. This is a particular experiment, not a universal harvest time.
- **NASA-FOOD-PACKAGED, NASA-HEALTH-SLEEP, NASA-EXERCISE-ARED / T2 / CEVIS, NASA-MED-MONITOR:** NASA's [Living in Space](https://www.nasa.gov/humans-in-space/living-in-space/) reference distinguishes food, exercise, hygiene, research and health monitoring. These inspire routine interactions, without clinical treatment claims.

The research registry and its established evidence classifications remain unchanged. No new TRL, deployment status, NASA equipment rating or medical threshold is asserted.

**Growth time:** the default crop cycle is 1,800 utility seconds (30 running-game minutes), deliberately compressed from biological timelines. Development acceleration is available through the JSON default or `DailyLife.set_growth_multiplier(1..3600)`; tests use 1,800x. It changes crop progress only. Full-cycle water and nutrient charges remain the same, while electrical energy follows actual utility seconds. Accelerated runs therefore do not represent real biological productivity or energy efficiency. It does not fast-forward batteries, the astronaut or the rest of the world.

The leafy-greens profile, temperatures, pressure/CO2/humidity guards, yield and nutrient units are game assumptions. This phase does not solve photosynthesis, carbon uptake, root chemistry, relative humidity, microbial contamination, plant respiration or caloric sufficiency. Crop portions have no asserted kg/calorie equivalence. No oxygen is credited to the cabin. Six seeds support at most six cycles/twelve small portions without separately authorized resupply; mature trays cannot generate repeated yield without replanting.

## Greenhouse lifecycle and accounting

Each tray retains its crop ID, planted state, grow-light switch, progress in seconds, environmental/resource status and remaining harvest.

1. Select a tray at Greenhouse and plant one inventory seed. An occupied tray refuses another seed.
2. Healthy ventilation, configured cabin conditions, light, dispatched power, water and nutrients are required.
3. A complete cycle allocates **0.2 kg potable water and one nutrient unit**, proportionally to accepted progress. Empty inputs or insufficient wastewater capacity pause growth without consuming that step's feed. No negative pool or overflow is permitted.
4. Crop water is explicitly transferred into the existing wastewater pool. This is a conservative allocation/return abstraction; plant-retained water, evapotranspiration and moisture in harvested food are not modeled. It preserves the existing utility mass and elemental balances rather than inventing an untracked water loss.
5. Nutrient consumption remains in the cumulative nutrient-used counter: stock plus used equals the initial twelve units. Nutrients are not automatically regenerated.
6. At maturity, two portions become available once. Harvest uses RuntimeInventory's exact accepted quantity; a full inventory leaves everything in the tray, and partial acceptance retains the exact remainder.
7. An emptied tray can be replanted with a new finite seed. Lights request power only while some planted, immature tray has its switch on.

Environmental status distinguishes empty, growing, ready and pauses for cabin conditions, power/light, nutrients, and water/output capacity. There is no automatic plant death or claimed biological outcome from one threshold.

## Daily activities

| Station | Implemented behavior |
| --- | --- |
| Galley | Prepare a cold ration or a greens portion into one Prepared Meal; consume one actual ingredient and allocate 0.1 kg potable water into the sanitation loop. Output space is checked first. Preparation creates one loose packaging/waste unit. |
| Galley: Drink | Allocate 0.2 kg potable water; two-second routine log. Water returns to wastewater as an immediate bookkeeping abstraction, not digestion timing. |
| Sleeping station | Ten-second rest acknowledgement; no eight-hour time skip or health reset. |
| Hygiene | Allocate 0.3 kg water; five-second wash acknowledgement. |
| Hygiene: Seal waste | Move all loose waste units into retained sealed-waste storage; waste is not deleted or credited as recycled water. |
| Exercise | Eight-second exercise log; no invented strength, cardiac or rehabilitation outcome. |
| Medical | Four-second powered inspection log; no diagnosis, treatment or fabricated vital signs. |
| Mission operations | Five-second powered workstation-maintenance log; no spare parts or automatic equipment-fault repair. E1 equipment maintenance remains separate. |
| Science | Five-second powered examination requiring a Lunar Sample in the existing inventory; the sample's stable identity and quantity are preserved. |
| Cargo | Transfer remaining finite seeds/rations to available inventory capacity. |

Powered routines require the existing habitat-electronics component and pause if it loses power. The cold-preparation action claims no heating work. Activity durations and the sixty-utility-second repeat cooldown are interaction pacing, not real astronaut routine lengths. The generic E1 occupancy load continues separately; these explicit water allocations are additional scenario tasks, not a calibrated human budget.

One timed job runs at a time. The player stays in the existing modal inspector, with movement, inventory and mode changes gated. Closing/Esc interrupts an unfinished job; already allocated water is not refunded. Completed activities remain logged. All detailed physiological effects remain reserved for Phase 1.3.

## Chiwis and persistence

Chiwis retains existing terrain-aware following and full-foot sweeps. Interiors provide reserved access positions for doors/equipment. Near a station, it selects a reachable parking cell 24–48 pixels from the astronaut, at least 24 pixels from every action point. Selection is cached while the player stays in place and invalidated on terrain rebinding. Exterior following is unchanged. These are navigation clearances in game pixels, not engineering dimensions.

Utility service, trays, cargo reserves, activity logs and inventory remain in the same session across rooms and camera modes. `DailyLife.capture_state()/restore_state()` provides a versioned Dictionary, validates quantities/tray bounds/job shape and restores atomically; invalid states are refused. A future whole-game coordinator must restore inventory, utilities, daily state and location together. Disk saves are not added.

Utilities use config ID **moon_utilities_v2** for the new optional equipment entry. Known v1 utility snapshots migrate the missing light/pump from default configuration, preserving other stored quantities and ledgers. Research/scene geometry remain independent from the simulation.

## Files

Created: `scripts/habitat/daily_life.gd`, `scripts/ui/daily_life_panel.gd`, `resources/config/daily_life.json`, `tests/daily_life_test.gd`, corresponding Godot UID files and this report.

Modified: Main composition; HabitatDirector station bindings/reserved access; Chiwis parking; UtilityService fixed-step events; UtilityModel demand request and v1 snapshot migration; UtilityEquipment configurable enabled default; utility JSON's additional light/pump entry; validation runner; habitat regression helper to close the new modal; additive AGENTS instructions. Existing terrain, inventory implementation, pickups, character artwork, rendering settings and input bindings are preserved. No commits or external writes were made.

## Validation

Reproduce:

```powershell
node tools/research/validate_science_catalog.mjs --self-test
node tools/habitat/validate_layout.mjs
./tests/validate.ps1 -IncludeRendering
```

Final complete-suite validation passed with **0 engine errors and 0 engine warnings** in Godot **4.7.2.stable.official.ed1daf0bf**.

| Check | Result |
| --- | --- |
| New daily-life acceptance | **304 headless / 306 rendered checks passed** |
| Crop coverage | Independent trays, finite seeds, light/operator switch/power failure, depleted water/nutrients, unsuitable environment, complete resource cost under acceleration, harvest reentry, full inventory and exact partial remainder |
| Activities/state | Timed completion/reentry guards, preserved science sample, ration/greens preparation, retained waste, JSON state restore and invalid-state rejection, v1 utility migration, actual production station/modal integration |
| Chiwis/rooms | Reachable parking clearance checked at all room action points; **971 headless / 975 rendered habitat checks** passed, including live obstacle following, doors and state preservation |
| Utility regression | **922 conservation/failure checks**, 136 terminal integration / 139 rendered checks passed |
| Existing world | 9,261 lunar-map and 405 EVA checks passed; isometric fixture, terrain, cameras, mode switching, inventory, interactions, props, character/run art and UI suites passed |
| Rendering | Editor/Main, greenhouse screenshot, existing actor/terrain/habitat/UI captures and fullscreen suites passed; greenhouse panel visually inspected at 960x540 |
| Data/document checks | Valid runtime JSON; default 1x acceleration, 1,800-second cycle, positive feed costs and unique power entry verified. Research catalog: 69 entries, 60 official sources, 16 categories, generated-document agreement and 12 invalid-fixture checks passed. Habitat layout remains nine compact rooms / 260 connected floor cells. |

Research warnings, separately: the same **eight existing evidence warnings** remain (six unconfirmed source dates, the recorded CHAPEA date discrepancy and null TRLs rather than invented ratings). No new scientific status or engine warning was introduced.

An earlier rendered astronaut test had timing-sensitive failures at variable rendering cadence. The complete rerun passed; an additional fixed-60-FPS rendering run passed all 244 astronaut checks while still exercising 30/60/120 Hz physics. The runner now specifies that rendering cadence for this existing test, retaining every assertion and leaving movement code unchanged. Earlier development failures in inventory fixtures led to finite Cargo intake rather than changing the established starting inventory or weakening previous acceptance checks.

Evidence: `tests/output/phase_0_8E2_final_retry.log` and `tests/output/daily_life.png`. Input/UI acceptance uses native Godot event/interaction automation; it does not claim a physical-keyboard playtest.

Known limitations: two logical trays share one light/pump bank; existing interior placeholders remain; no new crop sprites, refill production, nutrient synthesis, spoilage, complete diet, physiological model, clinical system or offline growth. Sealed waste is retained as discrete units without a detailed waste logistics model. Unfinished routines are interrupted when leaving the inspector. Science examination records an interaction rather than identifying composition. These are explicit foundations for later authorized phases.

## Manual acceptance

1. Enter the habitat through the established airlock sequence. At Cargo, collect finite supplies; verify repeated collection does not replenish them.
2. At Greenhouse, select each tray and plant. Check seed counts, light switches, resource/status/progress readouts and growth only with actual utility power.
3. Disable the light/pump or distribution at an engineering terminal. Revisit the greenhouse: growth pauses. Restore power and verify it resumes. Development testing can set the multiplier through the documented API without changing production defaults.
4. Harvest with available, full and partially available inventory. Remaining crop must persist until collected; replanting requires another seed.
5. Prepare a ration/greens meal, drink, wash and seal waste. Observe real inventory changes and water/wastewater allocations.
6. Keep each timed station panel open to complete its routine; try Esc mid-routine and verify interruption. Bring a Lunar Sample to Science and confirm its quantity is preserved.
7. Lead Chiwis to equipment and doors, walk around obstacles, change rooms/modes and reopen stations. Confirm access space, retained supplies/crops, existing inventory and both camera behaviors.

Stop at Phase 0.8E2.

