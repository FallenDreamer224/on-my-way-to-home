# Phase 0.8E1 — Habitat Utilities Foundation

Completed: 2026-11-15. Engine: Godot 4.7.2. Scope: the fictional Moon tutorial's first utility state, equipment interactions and inspection UI. No Phase 0.8E2 work is included.

## Result and architecture

The habitat has one persistent utility service under `Main/Systems/Utilities`. It continues running while the exterior world or an inactive room is disabled, in both camera modes and while a modal is open. It is independent of artwork, TileMapLayer cells and room geometry.

- `UtilityConfig` reads and validates the versioned JSON configuration. Initial stores, capacities, rates, power priorities, setpoints and alarm thresholds are data.
- `UtilityEquipment` owns enabled, fault, maintenance, powered, status, runtime and inspection-count state.
- `UtilityModel` is a scene-independent RefCounted model with material, electrical and thermal ledgers. It owns quantities and emits changes.
- `UtilityService` supplies a fixed one-second simulation clock. Fractional time and catch-up debt are retained; each call processes at most eight steps. There is no gameplay time acceleration or offline progression.
- `UtilityPanel` is a text-only, event-driven inspector using the existing development theme. It reads the model and sends commands; it owns no resource quantities.
- `HabitatDirector` supplies cabin occupancy and connects the existing ECLSS, water and power stations in Engineering to this inspector. There are no duplicate stations, inventories or actors.

The single astronaut, Chiwis, rooms, original pickups, inventory, terrain, cameras and resolution remain in place. Inspected-station flags still use existing room state. The terminal shares PlayerSession's modal permissions: movement, interaction, inventory opening, door transactions and mode switching are blocked until Close or Esc. Chiwis and the utility clock continue running.

## Verified scientific basis

Read the Science Bible, scientific gameplay rules, catalog and research registry before implementation. The following primary sources were checked online on **2026-11-15**. These describe real reference technology; this fictional surface installation is not claimed to be deployed NASA hardware. No numeric TRL or NASA equipment rating has been assigned to the model.

| Registry references | Verified capability and source | Game interpretation |
| --- | --- | --- |
| NASA-GAS-CONTROL, NASA-AIR-CDRA, NASA-WATER-WPA | NASA's [ECLSS overview](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/), updated 2025-04-04, distinguishes pressure/O2 control, circulating-air treatment and water processing with quality checks. | One well-mixed cabin; powered gas handling; abstract treatment equipment. Trace contaminants, fire suppression and water chemistry are deferred. |
| NASA-WATER-UPA, NASA-WATER-WPA, NASA-WATER-BPA | The [2023-06-20 water-recovery report](https://www.nasa.gov/missions/station/nasa-achieves-water-recovery-milestone-on-international-space-station/) describes the integrated ISS demonstration reaching 98% with BPA support. | The configuration uses an explicitly fictional **80%** treatment yield. The integrated milestone is not a rating for an individual filter or every configuration. The overview's broader approximately 90% statement is not substituted for that demonstration. |
| NASA-O2-OGA | The [ECLSS overview](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/) describes oxygen generation by water electrolysis, with hydrogen as another output. | **Electrolysis is not implemented.** Oxygen supply transfers delivered gas from a finite tank. There is no oxygen creation, hidden water conversion or omitted hydrogen stream. |
| NASA-POWER-SOLAR, NASA-POWER-BATTERY | NASA's [solar-array article](https://www.nasa.gov/missions/station/iss-research/power-up-roll-out-solar-arrays-boost-space-station-power-supply/), published/updated 2026-10-15, describes ISS electrical generation/distribution. The [2021-02-01 battery-operation report](https://www.nasa.gov/blogs/spacestation/2021/02/01/spacewalkers-wrap-up-battery-work-and-camera-installations/) documents the lithium-ion battery upgrade. | Explicit solar input, finite battery energy, conversion losses and a rated distribution bus. These are not ISS-sized or lunar-qualified component specifications. |
| NASA-THERMAL-LOOPS, NASA-THERMAL-PASSIVE | [NTRS 20110023292](https://ntrs.nasa.gov/citations/20110023292) documents ISS pumped heat transport and radiator rejection. Its publication field is 2011-01-01; its meeting field is July 2012, so those dates are not treated as a new 2026 deployment milestone. | Lumped heating and bounded passive/active heat rejection. No ammonia, coolant plumbing or radiator geometry is simulated. |
| Physical model supplement | [NASA Glenn's ideal-gas teaching reference](https://www.grc.nasa.gov/www/k-12/Numbers/Math/Mathematical_Thinking/ideal_gases_under_constant.htm) gives pV = nRT and rounded R = 8.3144 J/(mol K). No page publication date was confirmed. | Pressure and partial pressures are estimates from stored gas masses, configured volume and temperature. |

The research baseline remains separate from gameplay data and unchanged. Citations stay in documentation rather than ordinary item descriptions. Operational ISS heritage does not establish deployed lunar habitat capability.

## Units, stores and nominal configuration

All numbers below are **tutorial assumptions**, not NASA performance data, human requirements or clinical limits. Source quantities are delivered initial reserves. One simulation second corresponds to one accumulated running-game second.

| Quantity | Initial / configured value |
| --- | --- |
| Aggregate pressurized volume | 100 m3, independent of sprite dimensions and floor area |
| Temperature / effective thermal capacity | 293.15 K (20 C); 2,000,000 J/K |
| Battery stored energy / capacity | 9,000 / 12,000 Wh |
| Solar electrical availability | 1,200 W at source fraction 1 |
| Charge input / delivered discharge limits | 800 W / 1,000 W |
| Charge / discharge efficiency | 0.90 / 0.90 |
| Distribution bus | 2,000 W |
| Cabin O2 / N2 / CO2 / vapor | 27 / 93 / 0.04 / 0.8 kg |
| Oxygen storage / capacity | 12 / 20 kg |
| Potable / wastewater / reject water | 80 / 2 / 0 kg; capacities 100 / 50 / 20 kg |
| Captured CO2 / capacity | 0 / 10 kg |
| Surrogate carbon substrate | 1 kg, finite; not an inventory food item |
| Computed startup atmosphere | Approximately 102.63 kPa total; 20.57 kPa O2; 22.2 Pa CO2; 8 g/m3 vapor |

Mass is kg; rates kg/s; power W; electrical energy Wh; heat J; temperature K internally and C in the inspector; pressure Pa internally and kPa where labeled. Humidity is **absolute vapor concentration in g/m3**, not relative humidity. Internal counters use seconds.

The initial state raises no configured alarms. A one-hour occupied scenario, including fifteen minutes without solar input, remains within the configured tutorial limits. This acceptance criterion makes no medical safety guarantee.

## System behavior and conservation

### Power

Eleven equipment records include generation, battery and distribution plus eight consumers. Consumers are dispatched by ascending priority, then stable ID. Their full rated load must fit available source/battery power and the bus. A brownout sheds lower-priority loads rather than granting partial-powered operation.

Solar availability and a manual source fraction are explicit external inputs. Surplus charges the battery subject to charger, bus and capacity limits. Unused potential generation is curtailed. Darkness discharges storage, including discharge losses; an empty battery cannot supply energy. A failed/disabled/maintained distribution bus supplies no load and cannot charge storage.

The cumulative identity is:

```text
battery_Wh = initial_battery_Wh + generation_Wh
             - curtailment_Wh - load_Wh - battery_loss_Wh
```

Battery conversion losses are an explicitly external battery heat sink, recorded in Wh, outside the cabin thermal model. Internal battery net W in the inspector is the rate of change of stored energy; it includes conversion losses. Generation/load/net readings describe the last completed fixed step, so a command changes equipment flags immediately and power readings on the next step.

### Atmosphere and occupancy loads

Cabin O2, N2, CO2 and vapor are finite pools. Partial pressures use mass / molar mass × R × T / volume, and their sum is total cabin pressure. The O2 supply valve transfers stored gas toward the configured partial-pressure target; there is no automatic nitrogen replenishment, leak patching or total-pressure reset.

The occupied-cabin load is a documented **carbon-oxidation surrogate**, not a full physiological or nutritional simulation:

```text
32 mass units O2 + 12 mass units carbon -> 44 mass units CO2
```

The configured O2 load is 0.000005 kg/s and uses finite carbon substrate. Chemical heat is charged against that consumed substrate at the fictional 9,000 Wh/kg setting. Exhausted reactants or a full CO2 output pool limit the reaction; this does not imply that a person could survive those conditions.

Powered, healthy ventilation is required for the O2 valve, CO2 removal and humidity recovery to move material. CO2 removal transfers at up to 0.00001 kg/s into a finite captured-gas store. It does not delete carbon or claim a complete regenerative CDRA cycle. The valve can supply at most 0.00002 kg/s. Ventilation has an 80 W load; no spatial air-flow or mixing delay is modeled.

Occupancy is true in pressurized rooms and false outside and in the abstract crew chamber. Equipment keeps running when the astronaut leaves. Chiwis has no human metabolic load. Suit/EVA consumables and compartment-specific atmosphere are deferred.

### Water and humidity

Occupied use transfers up to 0.00003 kg/s of potable water: 75% to wastewater, 25% to cabin vapor. No water is invented. Humidity recovery transfers up to 0.00002 kg/s of vapor to wastewater when above its setpoint and ventilation is powered.

Healthy, powered treatment processes at most 0.0002 kg/s of wastewater: 80% becomes potable and 20% becomes retained reject water. Feed, clean-water capacity and reject capacity bound production. Empty feed, full required outputs or faults stop throughput. Yield endpoints 0 and 1 are also handled without division by zero. Reject is a recovery loss, not vanished mass.

The treatment abstraction assumes acceptable product quality whenever healthy. Purity sensors, contaminant mass, microbial growth, individual filter consumables, UPA/BPA subchains and latent heat are not implemented. This is not a validated potable-water process.

### Thermal control

The effective cabin thermal store follows:

```text
thermal_J = initial_thermal_J + electrical_heat_J + external_heat_J
            + chemical_heat_J - passive_rejected_J - active_rejected_J
temperature_K = thermal_J / heat_capacity_J_per_K
```

Every delivered electrical load becomes cabin heat exactly once, including the heater. The configuration has a 100 W external heat input, 180 W maximum passive rejection toward an effective 100 K sink, and 1,200 W maximum powered active rejection. Heater demand is below 293.15 K; active cooling demand is above 293.65 K and cannot cool below the heating target during that step. These are lumped scenario coefficients, not lunar surface temperatures, radiator qualification or full radiative/phase-change physics.

Material tests check total modeled mass and C/O/H/N element balances. Electrical and thermal ledgers have separate residual checks; thermal input is not credited as free electrical energy.

## Equipment, alarms and inspection

Engineering's existing **ECLSS**, **Water** and **Power** stations open the shared inspector with the relevant component selected. It shows actual stores, battery charge/discharge, last-step power, calculated atmosphere/temperature, component status, runtime, maintenance count and all active alarms. Readings and alarms scroll independently within the fixed 960x540 layout; no final UI art is required.

- Toggle power changes the enabled flag.
- Test fault isolates the selected device.
- Start maintenance takes it offline.
- Finish inspection clears a placeholder fault only after maintenance has started and increments the inspection counter. It grants no water, O2, energy, inventory or new parts.
- Sunlight 100% / 0% changes a declared scenario input to exercise charging/discharging. It is not a solar-position simulation.
- Close or Esc releases focus and restores existing input permissions.

Equipment faults and maintenance are placeholders: no repair minigame, wear probability, spare-part consumption or inspection duration is claimed. The eight consumer ratings/priorities are in JSON, not in the UI.

The model emits pressure, O2, CO2, humidity, temperature, water-reserve, oxygen-reserve, battery-reserve and critical-equipment alarms. Thresholds in JSON are gameplay triggers, not medical diagnoses. All current alarms remain in the inspector. New alarms use the existing HUD notice area with per-ID and aggregate thirty-simulation-second cooldowns so one bus failure does not generate a burst of notices.

## Persistence and extension contract

`UtilityModel.capture_state()/restore_state()` and `UtilityService.capture_state()/restore_state()` expose plain, versioned Dictionaries suitable for a future save coordinator. They contain stores, ledgers, energy, temperature, source fraction, occupancy, equipment state/counters, last-step power, elapsed time and the service's fractional/catch-up time.

Restore rejects unknown schema/config IDs, missing/invalid quantities, non-finite or negative values, exceeded capacities, invalid equipment fields, changed initial accounting baselines and conservation violations. It validates a temporary candidate before changing live state. Native snapshots continue exactly; JSON snapshots continue within tested floating-point tolerances.

Whole-game disk save/load is not added. A future coordinator must restore the matching room/location, airlock, actors, inventory and utility context together; restoring only this service does not teleport the astronaut or reconstruct rooms. Keep the configuration ID/schema version intentional when changing saved-state semantics. HUD notification cooldown history is presentation state and is reset on service restore, with a thirty-second suppression interval.

Important retained abstraction: the **Phase 0.8D airlock remains an interlocked discrete presentation state**. It has no modeled chamber volume/gas quantity and neither withdraws gas from nor replenishes this cabin ledger. Its pressure-match label is not a quantitative simulation. Chamber gas stores, pump energy, loss/recovery and supply-dependent cycling must be designed together in a separately authorized phase; no free oxygen is credited to any utility pool during current transitions.

Solar-array geometry, exterior tanks and other art do not drive capacities or production. No full survival/medical simulation, crop production, electrolysis, Sabatier chain, Mars system, audio, final artwork or asset generation is included.

## Files created or modified

Created:

- `resources/config/habitat_utilities.json`.
- `scripts/utilities/utility_config.gd`, `utility_equipment.gd`, `utility_model.gd`, `utility_service.gd`.
- `scripts/ui/utility_panel.gd`.
- `tests/utilities_test.gd`, `tests/utility_integration_test.gd`.
- Godot UID companions for the new scripts and this report.

Modified:

- `scenes/main.tscn`, `scripts/core/main.gd`: persistent service and panel composition.
- `scripts/habitat/habitat_director.gd`: existing terminal binding and occupancy context.
- `scripts/gameplay/player_session.gd`: shared inspection-modal input gate.
- `tests/habitat_test.gd`: close the new inspection modal after testing a station; retain previous habitat assertions.
- `tests/ui_foundation_test.gd`: include the authorized utility service in the existing system assertion.
- `tests/validate.ps1`: configuration JSON, utility suites, rendering and fullscreen checks.
- `AGENTS.md`: additive Phase 0.8E1 contract.

Project rendering settings, original art, input bindings, terrain and inventory data are unchanged. No files outside the project were written and no commit was made. This workspace has no Git repository metadata; the files are ready for the user's version-control workflow.

## Validation

Reproduce:

```powershell
node tools/habitat/validate_layout.mjs
node tools/research/validate_science_catalog.mjs --self-test
./tests/validate.ps1 -IncludeRendering
```

The complete headless, graphical and fullscreen suite passed in **4.7.2.stable.official.ed1daf0bf** with **0 engine errors and 0 engine warnings**. Graphical captures were visually inspected at 960x540. Final targeted checks also passed after refining inspector wording and strengthening corrupt-snapshot rejection.

| Acceptance | Result |
| --- | --- |
| Import and script syntax | All production/test GDScript parsed; Main/editor launched successfully |
| Utility quantities, energy and failure scenarios | **922 final targeted checks passed** (the preceding full-suite run contained 920, before two additional corrupt-snapshot cases) |
| Production terminal integration | **136 headless / 139 rendered / 136 fullscreen checks passed**; final headless/rendered passes also confirmed the final UI text |
| Conservation coverage | C/O/H/N and total mass; electrical Wh and thermal J; one occupied hour; darkness/recovery; finite empty loops; no double-counted heater energy |
| Capacity/failure coverage | Priority brownout, empty/full battery, failed bus, gas-flow ventilation dependency, finite reactants, full clean/reject stores, treatment faults, 0%/100% yield endpoints |
| State/UI coverage | Native and JSON snapshot continuation, atomic corrupt-state rejection, fixed/fractional clock, room/mode persistence, real E/Esc/Tab/movement events, actual model readings, repair controls, charging/discharging controls, bounded simultaneous-alarm display and notice cooldowns |
| Existing habitat / exterior / EVA | 971 headless / 975 rendered habitat checks; 9,261 map checks; 405 EVA checks passed |
| Other regressions | Foundation, 33,961-check isometric fixture, Moon terrain, cameras/modes, astronaut/Chiwis, source/run art, inventory/interactions, props and UI all passed |
| Habitat layout | Nine compact rooms, eighteen stations, all sixteen facility groups and 260 connected floor cells; valid doors/arrivals |
| Research JSON / documentation | 69 entries, 60 official sources, 16 categories; all dependency/source references and generated documents agree; 12 invalid-fixture checks passed |
| Runtime configuration JSON | Valid JSON; GDScript validates required fields, numeric domains, unique equipment IDs, capacities and ordered thresholds; malformed configuration fixtures rejected |

Warnings, separately: **eight existing research-evidence warnings** remain: six sources have unconfirmed publication/update days (SRC-SRAG, SRC-CADRE, SRC-SUBT, SRC-SAMPLE, SRC-CURATION, SRC-ISAM-2026); SRC-CHAPEA-2026 retains its published/update-date discrepancy; 69 entries have null TRLs rather than invented achieved ratings. None is a new engine warning. No scientific source status or historical decision was silently replaced.

Evidence: `tests/output/phase_0_8E1_validation.log`, `utilities_targeted.log`, `utility_integration_targeted.log`, `utility_integration_rendered_targeted.log`, `utilities_nominal.png`, `utilities_fault.png` and `utilities_multiple_alarms.png`. Early targeted checks exposed a configuration field-name mismatch, unsupported test-number formatting, JSON floating-point equality assumptions and cascading notice bursts; these were corrected and the acceptance checks were rerun without weakening conservation requirements.

Logs, isolated profiles and captures are under ignored `tests/output`. Engine execution uses the existing configured executable and project-local APPDATA/LOCALAPPDATA; Windows certificate-store read access requires the established outside-sandbox engine run. No trust-store, renderer or profile configuration was changed.

## Manual acceptance

1. Launch Main. Enter the habitat through the existing seal / suit inspection / pressure-match / inner-hatch sequence. Reach Hub, then Engineering.
2. Use E at ECLSS, Water and Power. Confirm different equipment selections, actual changing quantities and the model-state versus estimate headings. Scroll to see all readings.
3. Try moving, I, Tab and a door while inspecting. These must not act. Close with Esc, then verify movement, inventory and both cameras resume.
4. At Power, set sunlight to 0%. Observe negative battery net W and falling Wh; return to 100% and observe charging when spare power/storage capacity permit.
5. Select Power distribution and Test fault. After the next simulation second, load is zero and critical warnings appear. Inspect other equipment's unpowered state. Start maintenance, then Finish inspection; healthy power resumes. Repeating faults rapidly must not spam the HUD.
6. Inspect water treatment; note the finite potable, wastewater and reject quantities. A treatment fault stops its flow; recovery does not erase reject.
7. Leave Engineering, revisit it, change modes and exit to the surface. Battery/resources, equipment flags and maintenance counters must remain. Inventory and the original astronaut/Chiwis remain intact.
8. For reproducible depletion/capacity/thermal acceptance, run the automated suites; their isolated configurations avoid changing production startup reserves. No clinical outcomes or real EVA operating procedure should be inferred.

Stop here. Phase 0.8E2 has not begun.

