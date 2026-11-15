extends SceneTree
## Quantitative invariants and failure acceptance; no scene or UI required for the model.

var checks: int = 0
var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)


func close(a: float, b: float, label: String, tolerance: float = 1e-8) -> void:
	check(absf(a-b) <= tolerance, label + " (%.10f vs %.10f)" % [a,b])


func make_model(settings: UtilityConfig = null) -> UtilityModel:
	var result := UtilityModel.new()
	check(result.configure(settings if settings != null else UtilityConfig.load_default()), "Model accepts validated configuration")
	return result


func isolate(model: UtilityModel, ids: Array[String]) -> void:
	for id: String in model.equipment:
		model.equipment[id].enabled = id in ids


func balanced(model: UtilityModel) -> void:
	for key: String in model.conservation_errors():
		close(float(model.conservation_errors()[key]), 0, "Conservation: " + key, 0.1 if key == "thermal_j" else 1e-5)
	for key: String in model.resources:
		check(model.resources[key] >= -1e-10 and model.resources[key] <= float(model.config.data.capacities_kg[key]) + 1e-9, "Finite capacity/nonnegative " + key)
	check(model.battery_wh >= -1e-10 and model.battery_wh <= float(model.config.data.battery_capacity_wh) + 1e-9, "Battery within capacity")


func _run() -> void:
	var config := UtilityConfig.load_default()
	check(config.validation_errors().is_empty(), "Default configuration validates")
	if not config.validation_errors().is_empty():
		printerr("FAIL: " + "; ".join(config.validation_errors()))
		quit(1)
		return
	for invalid_case: int in 8:
		var invalid := UtilityConfig.load_default()
		match invalid_case:
			0: invalid.data.rates.erase("oxygen_load_kg_s")
			1: invalid.data.initial_resources = []
			2: invalid.data.charge_efficiency = 0
			3: invalid.data.equipment[0].priority = "first"
			4: invalid.data.equipment[0].id = "battery"
			5: invalid.data.volume_m3 = NAN
			6: invalid.data.initial_battery_wh = 999999
			7: invalid.data.rates.water_recovery_fraction = 1.1
		check(not invalid.validation_errors().is_empty(), "Malformed configuration rejected case %d" % invalid_case)
	var model := make_model()
	check(model.alarms.is_empty(), "Safe delivered initial resources")
	check(model.pressure_pa() > 90000 and model.pressure_pa() < 110000, "Initial configured cabin pressure range")
	var before := model.capture_state()
	check(not model.step(NAN) and not model.step(-1) and not model.step(0) and not model.step(2), "Invalid or oversized steps rejected")
	check(before == model.capture_state(), "Rejected step leaves state untouched")
	# No-bus carbon/water load uses explicit finite sources; CO2 is not invented mass.
	isolate(model, [])
	model.occupied = true
	model.step(1)
	close(model.resources.cabin_o2_kg, 27 - 0.000005, "O2 consumption")
	close(model.resources.carbon_feed_kg, 1 - 0.000005*12/32, "Finite carbon substrate consumed")
	close(model.resources.cabin_co2_kg, 0.04 + 0.000005*44/32, "Stoichiometric CO2 production")
	close(model.resources.potable_kg, 80 - 0.00003, "Water consumed from potable store")
	close(model.resources.wastewater_kg, 2 + 0.00003*0.75, "Wastewater accumulated")
	close(model.resources.cabin_vapor_kg, 0.8 + 0.00003*0.25, "Humidity water comes from finite feed")
	balanced(model)
	# Charging is bounded by generation, charger and storage losses/capacity.
	model = make_model()
	isolate(model, ["solar", "battery", "distribution"])
	model.step(1)
	close(model.battery_wh, 9000.2, "800 W charge input at 90 percent storage efficiency")
	close(model.ledger.generation_wh, 1200.0/3600, "External solar electrical source")
	close(model.ledger.battery_loss_wh, (800.0/3600)*0.1, "Charging loss recorded")
	close(model.ledger.curtailed_wh, 400.0/3600, "Unused generation curtailed")
	balanced(model)
	model.set_solar_fraction(0)
	model.equipment.housekeeping.enabled = true
	var old_battery: float = model.battery_wh
	model.step(1)
	close(model.battery_wh, old_battery - (30.0/3600)/0.9, "Battery discharge pays conversion loss")
	close(model.last_power.load_w, 30, "Delivered consumer power")
	check(model.last_power.battery_w < 0, "Discharging reported")
	balanced(model)
	var full := UtilityConfig.load_default()
	full.data.initial_battery_wh = full.data.battery_capacity_wh
	model = make_model(full)
	isolate(model, ["solar", "battery", "distribution"])
	model.step(1)
	close(model.battery_wh, 12000, "Full storage cannot overcharge")
	close(model.ledger.curtailed_wh, 1200.0/3600, "Full battery curtails solar")
	balanced(model)
	var empty := UtilityConfig.load_default()
	empty.data.initial_battery_wh = 0
	empty.data.initial_solar_fraction = 0
	model = make_model(empty)
	model.step(1)
	close(model.ledger.load_wh, 0, "No electricity from empty battery and darkness")
	check(not model.equipment.ventilation.powered and "equipment_offline/ventilation" in model.alarms, "Power failure alarm and unpowered life support")
	balanced(model)
	var limited := UtilityConfig.load_default()
	limited.data.initial_solar_fraction = 0
	limited.data.max_discharge_w = 100
	model = make_model(limited)
	model.step(1)
	check(model.equipment.ventilation.powered and not model.equipment.co2_removal.powered, "Brownout preserves higher-priority ventilation")
	check(model.last_power.load_w <= 100, "Brownout never exceeds discharge limit")
	balanced(model)
	var dry := UtilityConfig.load_default()
	for pool: String in dry.data.initial_resources:
		dry.data.initial_resources[pool] = 0
	model = make_model(dry)
	model.occupied = true
	for tick: int in 10: model.step(1)
	close(model.total_mass_kg(), 0, "Empty recovery loops cannot bootstrap material")
	close(model.ledger.chemical_heat_j, 0, "No chemical heat without finite reactants")
	balanced(model)
	model = make_model()
	model.equipment_command("distribution", "fault")
	var old_mass: float = model.total_mass_kg()
	model.step(1)
	close(model.ledger.load_wh, 0, "Distribution fault isolates all loads")
	close(model.battery_wh, 9000, "Isolated bus cannot secretly charge battery")
	close(model.total_mass_kg(), old_mass, "Unoccupied power failure preserves material")
	# Treatment needs power, source, rate capacity, clean/reject storage and healthy equipment.
	model = make_model()
	isolate(model, ["solar", "distribution", "water_treatment"])
	model.step(1)
	close(model.resources.wastewater_kg, 1.9998, "Treatment feed removed")
	close(model.resources.potable_kg, 80.00016, "Configured 80 percent recovery")
	close(model.resources.reject_kg, 0.00004, "Loss remains explicit reject water")
	check(model.ledger.load_wh > 0, "Treatment consumes electricity")
	balanced(model)
	var constrained := UtilityConfig.load_default()
	constrained.data.capacities_kg.potable_kg = 80.00008
	model = make_model(constrained)
	isolate(model, ["solar", "distribution", "water_treatment"])
	model.step(1)
	close(model.resources.potable_kg, 80.00008, "Output capacity bounds batch")
	close(model.resources.wastewater_kg, 1.9999, "Only fitting feed removed")
	balanced(model)
	constrained = UtilityConfig.load_default()
	constrained.data.initial_resources.reject_kg = constrained.data.capacities_kg.reject_kg
	model = make_model(constrained)
	isolate(model, ["solar", "distribution", "water_treatment"])
	model.step(1)
	close(model.resources.wastewater_kg, 2, "Full reject store stops processing")
	model = make_model()
	isolate(model, ["solar", "distribution", "water_treatment"])
	model.equipment_command("water_treatment", "fault")
	model.step(1)
	close(model.resources.wastewater_kg, 2, "Fault stops treatment")
	var resources_before: Dictionary = model.resources.duplicate()
	check(not model.equipment_command("water_treatment", "complete"), "Cannot finish maintenance never started")
	model.equipment_command("water_treatment", "maintain")
	model.equipment_command("water_treatment", "complete")
	check(not model.equipment.water_treatment.fault and model.equipment.water_treatment.service_count == 1, "Repair-state acknowledgment clears isolated fault")
	check(model.resources == resources_before, "Maintenance creates no water, oxygen or materials")
	model.step(1)
	check(model.resources.wastewater_kg < 2, "Healthy treatment resumes")
	balanced(model)
	for yield_value: float in [0.0, 1.0]:
		var endpoint := UtilityConfig.load_default()
		endpoint.data.rates.water_recovery_fraction = yield_value
		model = make_model(endpoint)
		isolate(model, ["solar", "distribution", "water_treatment"])
		model.step(1)
		close(model.resources.potable_kg, 80 + 0.0002 * yield_value, "Recovery endpoint potable output")
		close(model.resources.reject_kg, 0.0002 * (1-yield_value), "Recovery endpoint reject output")
		balanced(model)
	# Gas supply is a transfer, and removal retains carbon/oxygen in captured gas.
	model = make_model()
	isolate(model, ["solar", "distribution", "ventilation", "oxygen_supply", "co2_removal"])
	var gas_total: float = model.resources.oxygen_store_kg + model.resources.cabin_o2_kg
	model.step(1)
	close(model.resources.oxygen_store_kg + model.resources.cabin_o2_kg, gas_total, "Oxygen supply conserves O2")
	check(model.resources.oxygen_store_kg < 12 and model.resources.cabin_o2_kg > 27, "Finite stored gas transferred")
	close(model.resources.cabin_co2_kg + model.resources.captured_co2_kg, 0.04, "CO2 removal conserves captured material")
	check(model.resources.captured_co2_kg > 0, "Captured CO2 increases")
	balanced(model)
	model.equipment_command("ventilation", "toggle")
	var gas_before: Dictionary = model.resources.duplicate()
	model.step(1)
	check(model.resources == gas_before and model.equipment.co2_removal.status == "blocked: ventilation", "Ventilation required by gas processors")
	# Electrical heating is counted once; active cooling rejects tracked heat.
	var cold := UtilityConfig.load_default()
	cold.data.initial_temperature_k = 285
	model = make_model(cold)
	isolate(model, ["solar", "distribution", "heating"])
	model.step(1)
	close(model.ledger.electrical_heat_j, 300, "Heater electricity becomes heat once")
	check(model.temperature_k() > 285, "Powered heater raises thermal state")
	balanced(model)
	var hot := UtilityConfig.load_default()
	hot.data.initial_temperature_k = 300
	model = make_model(hot)
	isolate(model, ["solar", "distribution", "thermal_control"])
	model.step(1)
	check(model.temperature_k() < 300 and model.ledger.active_rejected_j > 0, "Powered loop rejects heat")
	balanced(model)
	# Long mixed load: conservation, stable bounds and JSON-serializable continuation.
	model = make_model()
	model.occupied = true
	for tick: int in 3600:
		if tick == 900: model.set_solar_fraction(0)
		if tick == 1800: model.set_solar_fraction(1)
		model.step(1)
		if tick % 120 == 0: balanced(model)
	check(model.alarms.is_empty(), "Safe tutorial initialization remains within scenario limits after one occupied hour")
	var saved: Dictionary = JSON.parse_string(JSON.stringify(model.capture_state()))
	var restored := make_model()
	check(restored.restore_state(saved), "JSON snapshot restores versioned state")
	var exact := make_model()
	check(exact.restore_state(model.capture_state()), "Native snapshot restores exact state")
	for tick: int in 20:
		model.step(1)
		restored.step(1)
		exact.step(1)
	check(model.capture_state() == exact.capture_state(), "Native restored simulation continues deterministically")
	for key: String in model.resources:
		close(model.resources[key], restored.resources[key], "JSON continuation resource " + key)
	close(model.battery_wh, restored.battery_wh, "JSON continuation battery", 1e-5)
	close(model.thermal_j, restored.thermal_j, "JSON continuation thermal", 0.1)
	for invalid_case: int in 11:
		var invalid: Dictionary = model.capture_state().duplicate(true)
		match invalid_case:
			0: invalid.schema_version = 99
			1: invalid.resources.oxygen_store_kg = -1
			2: invalid.battery_wh += 1
			3: invalid.resources.potable_kg += 1
			4: invalid.elapsed_s = NAN
			5: invalid.equipment.ventilation.powered = "yes"
			6: invalid.ledger.initial_mass_kg += 1
			7: invalid.ledger.carbon_consumed_kg += 1
			8: invalid.equipment.ventilation.fault = true
			9: invalid.last_power.load_w = -10
			10:
				invalid.ledger.carbon_consumed_kg += 0.1
				var invented_j: float = 0.1 * float(config.data.rates.carbon_chemical_wh_per_kg) * 3600.0
				invalid.ledger.chemical_heat_j += invented_j
				invalid.thermal_j += invented_j
		var unchanged: Dictionary = model.capture_state()
		check(not model.restore_state(invalid) and unchanged == model.capture_state(), "Invalid restore is atomic case %d" % invalid_case)
	# A single persistent clock retains fractional time and bounded catch-up debt.
	var service := UtilityService.new()
	root.add_child(service)
	service.set_physics_process(false)
	service.advance(0.4)
	close(service.model.elapsed_s, 0, "Fractional clock does not step early")
	service.advance(0.6)
	close(service.model.elapsed_s, 1, "Fractional inputs produce one fixed step")
	service.advance(20)
	check(service.accumulator_s >= 12, "Bounded catch-up retains debt")
	service.advance(0)
	service.advance(0)
	close(service.model.elapsed_s, 21, "No elapsed simulation time discarded")
	var whole: Dictionary = service.capture_state()
	service.advance(1)
	check(service.restore_state(JSON.parse_string(JSON.stringify(whole))), "Clock/model save boundary round trips")
	service.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: " + failure)
	if failures.is_empty():
		print("PASS: %d utility conservation/failure checks" % checks)
	quit(0 if failures.is_empty() else 1)
