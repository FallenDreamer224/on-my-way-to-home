class_name UtilityModel
extends RefCounted
## One well-mixed cabin, explicit finite stores and conserved electrical/material ledgers.
## All tuning values are scenario assumptions. This is not a clinical or ISS simulator.

signal changed
signal alarms_changed(active: PackedStringArray)

const R: float = 8.3144 # J/(mol K), rounded ideal-gas constant used by NASA Glenn reference.
const MOLAR_KG: Dictionary[String, float] = {"cabin_o2_kg": 0.032, "cabin_co2_kg": 0.044, "cabin_n2_kg": 0.028, "cabin_vapor_kg": 0.018}
var config: UtilityConfig
var resources: Dictionary[String, float] = {}
var equipment: Dictionary[String, UtilityEquipment] = {}
var ledger: Dictionary[String, float] = {}
var elapsed_s: float = 0.0
var battery_wh: float = 0.0
var thermal_j: float = 0.0
var solar_fraction: float = 1.0
var occupied: bool = false
var process_requests: Dictionary[String, bool] = {}
var alarms: PackedStringArray = []
var last_power: Dictionary = {"generation_w": 0.0, "load_w": 0.0, "battery_w": 0.0, "curtailed_w": 0.0}


func configure(settings: UtilityConfig) -> bool:
	if settings == null or not settings.validation_errors().is_empty():
		return false
	config = settings
	resources.clear()
	for key: String in config.data.initial_resources:
		resources[key] = float(config.data.initial_resources[key])
	equipment.clear()
	for definition: Dictionary in config.data.equipment:
		equipment[definition.id] = UtilityEquipment.new(definition)
	elapsed_s = 0
	battery_wh = float(config.data.initial_battery_wh)
	thermal_j = float(config.data.heat_capacity_j_per_k) * float(config.data.initial_temperature_k)
	solar_fraction = float(config.data.initial_solar_fraction)
	occupied = false
	process_requests.clear()
	ledger = {"initial_mass_kg": total_mass_kg(), "initial_battery_wh": battery_wh,
		"generation_wh": 0, "curtailed_wh": 0, "load_wh": 0, "battery_loss_wh": 0,
		"initial_thermal_j": thermal_j, "electrical_heat_j": 0, "external_heat_j": 0,
		"chemical_heat_j": 0, "passive_rejected_j": 0, "active_rejected_j": 0,
		"carbon_consumed_kg": 0, "water_treated_kg": 0}
	for key: String in element_masses_kg():
		ledger["initial_" + key] = element_masses_kg()[key]
	alarms = []
	last_power = {"generation_w": 0.0, "load_w": 0.0, "battery_w": 0.0, "curtailed_w": 0.0}
	_update_alarms()
	return true


func total_mass_kg() -> float:
	var result: float = 0
	for value: float in resources.values():
		result += value
	return result


func element_masses_kg() -> Dictionary[String, float]:
	var water: float = resources.potable_kg + resources.wastewater_kg + resources.reject_kg + resources.cabin_vapor_kg
	var co2: float = resources.cabin_co2_kg + resources.captured_co2_kg
	return {"carbon_kg": resources.carbon_feed_kg + co2 * 12.0 / 44.0,
		"oxygen_element_kg": resources.cabin_o2_kg + resources.oxygen_store_kg + co2 * 32.0 / 44.0 + water * 16.0 / 18.0,
		"hydrogen_kg": water * 2.0 / 18.0, "nitrogen_kg": resources.cabin_n2_kg}


func temperature_k() -> float:
	return thermal_j / float(config.data.heat_capacity_j_per_k)


func partial_pressure_pa(pool: String) -> float:
	return resources[pool] / MOLAR_KG[pool] * R * temperature_k() / float(config.data.volume_m3)


func pressure_pa() -> float:
	var result: float = 0
	for pool: String in MOLAR_KG:
		result += partial_pressure_pa(pool)
	return result


func humidity_g_m3() -> float:
	return resources.cabin_vapor_kg * 1000.0 / float(config.data.volume_m3)


func free_capacity(pool: String) -> float:
	return maxf(0, float(config.data.capacities_kg[pool]) - resources[pool])


func _demand(id: String) -> bool:
	var target: Dictionary = config.data.targets
	match id:
		"greenhouse_lights": return process_requests.get(id, false)
		"oxygen_supply": return partial_pressure_pa("cabin_o2_kg") < float(target.oxygen_partial_pa)
		"co2_removal": return resources.cabin_co2_kg > float(target.co2_kg)
		"water_treatment":
			var recovery: float = float(config.data.rates.water_recovery_fraction)
			return resources.wastewater_kg > 0 and (recovery == 0 or free_capacity("potable_kg") > 0) and (recovery == 1 or free_capacity("reject_kg") > 0)
		"dehumidifier": return humidity_g_m3() > float(target.humidity_g_m3)
		"heating": return temperature_k() < float(target.heat_k)
		"thermal_control": return temperature_k() > float(target.cool_k)
		_: return true


func step(seconds: float) -> bool:
	if config == null or not is_finite(seconds) or seconds <= 0 or seconds > float(config.data.fixed_step_s):
		return false
	var c: Dictionary = config.data
	var old_battery: float = battery_wh
	var generated_wh: float = float(c.solar_available_w) * solar_fraction * seconds / 3600.0 if equipment.solar.available() else 0.0
	var bus_wh: float = float(c.bus_capacity_w) * seconds / 3600.0 if equipment.distribution.available() else 0.0
	var available_battery_wh: float = minf(battery_wh * float(c.discharge_efficiency), float(c.max_discharge_w) * seconds / 3600.0) if equipment.battery.available() else 0.0
	var supply: float = minf(bus_wh, generated_wh + available_battery_wh)
	var load_wh: float = 0.0
	var ordered: Array[UtilityEquipment] = []
	for device: UtilityEquipment in equipment.values():
		device.powered = false
		if device.id not in ["solar", "battery", "distribution"]:
			ordered.append(device)
	ordered.sort_custom(func(a: UtilityEquipment, b: UtilityEquipment) -> bool: return a.priority < b.priority or (a.priority == b.priority and a.id < b.id))
	for device: UtilityEquipment in ordered:
		if not device.available():
			device.status = "maintenance" if device.maintenance else "fault" if device.fault else "disabled"
			continue
		if not _demand(device.id):
			device.status = "standby"
			continue
		var demand_wh: float = device.watts * seconds / 3600.0
		if demand_wh <= supply:
			device.powered = true
			device.status = "powered"
			device.runtime_s += seconds
			supply = maxf(0.0, supply - demand_wh)
			load_wh += demand_wh
		else:
			device.status = "unpowered"
	var deficit_wh: float = maxf(0, load_wh - generated_wh)
	var discharge_wh: float = minf(battery_wh, deficit_wh / float(c.discharge_efficiency))
	battery_wh -= discharge_wh
	var remaining_solar: float = maxf(0, generated_wh - load_wh)
	var charge_input_wh: float = 0.0
	if equipment.battery.available() and equipment.distribution.available():
		charge_input_wh = minf(remaining_solar, minf(float(c.max_charge_w) * seconds / 3600.0,
			minf(maxf(0, bus_wh - load_wh), maxf(0, float(c.battery_capacity_wh) - battery_wh) / float(c.charge_efficiency))))
	battery_wh += charge_input_wh * float(c.charge_efficiency)
	var losses_wh: float = discharge_wh - deficit_wh + charge_input_wh * (1.0 - float(c.charge_efficiency))
	var curtailed_wh: float = maxf(0, remaining_solar - charge_input_wh)
	ledger.generation_wh += generated_wh
	ledger.load_wh += load_wh
	ledger.curtailed_wh += curtailed_wh
	ledger.battery_loss_wh += losses_wh
	last_power = {"generation_w": generated_wh * 3600.0 / seconds, "load_w": load_wh * 3600.0 / seconds,
		"battery_w": (battery_wh - old_battery) * 3600.0 / seconds, "curtailed_w": curtailed_wh * 3600.0 / seconds}
	_update_infrastructure_status(seconds, charge_input_wh, discharge_wh, generated_wh)
	_process_materials(seconds)
	_process_thermal(seconds, load_wh)
	elapsed_s += seconds
	_update_alarms()
	changed.emit()
	return true


func _update_infrastructure_status(seconds: float, charge_wh: float, discharge_wh: float, generation_wh: float) -> void:
	for id: String in ["solar", "battery", "distribution"]:
		var device: UtilityEquipment = equipment[id]
		device.powered = device.available()
		device.status = ("generating" if generation_wh > 0 else "no sunlight") if id == "solar" else ("charging" if charge_wh > 0 else "discharging" if discharge_wh > 0 else "idle") if id == "battery" else "online"
		if not device.available():
			device.status = "maintenance" if device.maintenance else "fault" if device.fault else "disabled"
		elif device.powered:
			device.runtime_s += seconds


func _process_materials(seconds: float) -> void:
	var rates: Dictionary = config.data.rates
	if occupied:
		# Explicit carbon-oxidation surrogate: 32 kg O2 + 12 kg carbon -> 44 kg CO2.
		# Not a complete human metabolism or nutritional model.
		var oxygen_used: float = minf(float(rates.oxygen_load_kg_s) * seconds,
			minf(resources.cabin_o2_kg, minf(resources.carbon_feed_kg * 32.0 / 12.0, free_capacity("cabin_co2_kg") * 32.0 / 44.0)))
		var carbon_used: float = oxygen_used * 12.0 / 32.0
		resources.cabin_o2_kg -= oxygen_used
		resources.carbon_feed_kg -= carbon_used
		resources.cabin_co2_kg += oxygen_used + carbon_used
		ledger.carbon_consumed_kg += carbon_used
		var fraction: float = float(rates.water_to_vapor_fraction)
		var water_used: float = minf(float(rates.water_use_kg_s) * seconds, resources.potable_kg)
		if fraction < 1:
			water_used = minf(water_used, free_capacity("wastewater_kg") / (1 - fraction))
		if fraction > 0:
			water_used = minf(water_used, free_capacity("cabin_vapor_kg") / fraction)
		resources.potable_kg -= water_used
		resources.wastewater_kg += water_used * (1 - fraction)
		resources.cabin_vapor_kg += water_used * fraction
	var ventilation: bool = equipment.ventilation.powered
	if equipment.oxygen_supply.powered and ventilation:
		var target_mass: float = float(config.data.targets.oxygen_partial_pa) * float(config.data.volume_m3) * 0.032 / (R * temperature_k())
		_transfer("oxygen_store_kg", "cabin_o2_kg", minf(float(rates.oxygen_supply_kg_s) * seconds, maxf(0, target_mass - resources.cabin_o2_kg)))
	if equipment.co2_removal.powered and ventilation:
		_transfer("cabin_co2_kg", "captured_co2_kg", minf(float(rates.co2_removal_kg_s) * seconds, maxf(0, resources.cabin_co2_kg - float(config.data.targets.co2_kg))))
	if equipment.dehumidifier.powered and ventilation:
		var target_vapor: float = float(config.data.targets.humidity_g_m3) * float(config.data.volume_m3) / 1000.0
		_transfer("cabin_vapor_kg", "wastewater_kg", minf(float(rates.dehumidify_kg_s) * seconds, maxf(0, resources.cabin_vapor_kg - target_vapor)))
	if equipment.water_treatment.powered:
		var recovery: float = float(rates.water_recovery_fraction)
		var feed: float = minf(float(rates.water_treatment_kg_s) * seconds, resources.wastewater_kg)
		if recovery > 0:
			feed = minf(feed, free_capacity("potable_kg") / recovery)
		if recovery < 1:
			feed = minf(feed, free_capacity("reject_kg") / (1.0 - recovery))
		resources.wastewater_kg -= feed
		resources.potable_kg += feed * recovery
		resources.reject_kg += feed * (1.0 - recovery)
		ledger.water_treated_kg += feed
	for id: String in ["oxygen_supply", "co2_removal", "dehumidifier"]:
		if equipment[id].powered and not ventilation:
			equipment[id].status = "blocked: ventilation"


func _transfer(source: String, target: String, requested: float) -> void:
	var amount: float = minf(maxf(0, requested), minf(resources[source], free_capacity(target)))
	resources[source] -= amount
	resources[target] += amount


func _process_thermal(seconds: float, load_wh: float) -> void:
	var thermal: Dictionary = config.data.thermal
	var electric_j: float = load_wh * 3600.0
	var external_j: float = float(thermal.external_input_w) * seconds
	var chemical_j: float = (ledger.carbon_consumed_kg * float(config.data.rates.carbon_chemical_wh_per_kg) * 3600.0) - ledger.chemical_heat_j
	thermal_j += electric_j + external_j + chemical_j
	ledger.electrical_heat_j += electric_j
	ledger.external_heat_j += external_j
	ledger.chemical_heat_j += chemical_j
	var floor_energy: float = float(thermal.effective_sink_k) * float(config.data.heat_capacity_j_per_k)
	var passive_j: float = minf(float(thermal.passive_rejection_w) * seconds, maxf(0, thermal_j - floor_energy))
	thermal_j -= passive_j
	ledger.passive_rejected_j += passive_j
	if equipment.thermal_control.powered:
		var target_energy: float = float(config.data.targets.heat_k) * float(config.data.heat_capacity_j_per_k)
		var active_j: float = minf(float(thermal.active_rejection_w) * seconds, maxf(0, thermal_j - target_energy))
		thermal_j -= active_j
		ledger.active_rejected_j += active_j


func conservation_errors() -> Dictionary:
	var result: Dictionary = {"mass_kg": total_mass_kg() - ledger.initial_mass_kg,
		"electrical_wh": battery_wh - (ledger.initial_battery_wh + ledger.generation_wh - ledger.curtailed_wh - ledger.load_wh - ledger.battery_loss_wh),
		"thermal_j": thermal_j - (ledger.initial_thermal_j + ledger.electrical_heat_j + ledger.external_heat_j + ledger.chemical_heat_j - ledger.passive_rejected_j - ledger.active_rejected_j)}
	for key: String in element_masses_kg():
		result[key] = element_masses_kg()[key] - ledger["initial_" + key]
	return result


func _update_alarms() -> void:
	var next: PackedStringArray = []
	var a: Dictionary = config.data.alarms
	if pressure_pa() < float(a.pressure_min_pa): next.append("cabin_pressure_low")
	if pressure_pa() > float(a.pressure_max_pa): next.append("cabin_pressure_high")
	if partial_pressure_pa("cabin_o2_kg") < float(a.oxygen_min_pa): next.append("cabin_oxygen_low")
	if partial_pressure_pa("cabin_o2_kg") > float(a.oxygen_max_pa): next.append("cabin_oxygen_high")
	if partial_pressure_pa("cabin_co2_kg") > float(a.co2_max_pa): next.append("cabin_co2_high")
	if humidity_g_m3() < float(a.humidity_min_g_m3): next.append("cabin_humidity_low")
	if humidity_g_m3() > float(a.humidity_max_g_m3): next.append("cabin_humidity_high")
	if temperature_k() < float(a.temperature_min_k): next.append("cabin_temperature_low")
	if temperature_k() > float(a.temperature_max_k): next.append("cabin_temperature_high")
	if resources.potable_kg < float(a.water_reserve_kg): next.append("potable_water_low")
	if resources.oxygen_store_kg < float(a.oxygen_reserve_kg): next.append("stored_oxygen_low")
	if battery_wh < float(a.battery_reserve_wh): next.append("battery_reserve_low")
	for device: UtilityEquipment in equipment.values():
		if device.critical and (not device.available() or (elapsed_s > 0 and device.status == "unpowered")):
			next.append("equipment_offline/" + device.id)
	next.sort()
	if next != alarms:
		alarms = next
		alarms_changed.emit(alarms)


func set_solar_fraction(value: float) -> bool:
	if not is_finite(value) or value < 0 or value > 1:
		return false
	solar_fraction = value
	changed.emit()
	return true


func equipment_command(id: String, command: String) -> bool:
	if not equipment.has(id):
		return false
	var device: UtilityEquipment = equipment[id]
	match command:
		"toggle": device.enabled = not device.enabled
		"fault": device.fault = true
		"maintain": device.maintenance = true
		"complete":
			if not device.maintenance: return false
			device.maintenance = false
			device.fault = false
			device.service_count += 1
		_: return false
	if not device.available():
		device.powered = false
	device.status = "maintenance" if device.maintenance else "fault" if device.fault else "disabled" if not device.enabled else "ready"
	_update_alarms()
	changed.emit()
	return true


func capture_state() -> Dictionary:
	var devices: Dictionary = {}
	for id: String in equipment:
		devices[id] = equipment[id].snapshot()
	return {"schema_version": 1, "config_id": config.data.config_id, "resources": resources.duplicate(),
		"ledger": ledger.duplicate(), "elapsed_s": elapsed_s, "battery_wh": battery_wh, "thermal_j": thermal_j,
		"solar_fraction": solar_fraction, "occupied": occupied, "equipment": devices, "last_power": last_power.duplicate()}


func restore_state(saved: Dictionary) -> bool:
	# Validate on a temporary model; failure never mutates the running state.
	if config != null and config.data.config_id == "moon_utilities_v2" and saved.get("config_id") == "moon_utilities_v1" and saved.get("equipment") is Dictionary and not saved.equipment.has("greenhouse_lights"):
		saved = saved.duplicate(true)
		saved.config_id = "moon_utilities_v2"
		for definition: Dictionary in config.data.equipment:
			if definition.id == "greenhouse_lights":
				saved.equipment.greenhouse_lights = UtilityEquipment.new(definition).snapshot()
	if config == null or saved.get("schema_version") != 1 or saved.get("config_id") != config.data.config_id:
		return false
	for key: String in ["resources", "ledger", "equipment", "last_power"]:
		if not saved.get(key) is Dictionary:
			return false
	for key: String in ["elapsed_s", "battery_wh", "thermal_j", "solar_fraction"]:
		if not UtilityConfig.finite_number(saved.get(key)) or float(saved[key]) < 0:
			return false
	if (not saved.get("occupied") is bool or float(saved.solar_fraction) > 1
			or float(saved.battery_wh) > float(config.data.battery_capacity_wh) or float(saved.thermal_j) <= 0):
		return false
	if saved.resources.size() != resources.size() or saved.ledger.size() != ledger.size() or saved.equipment.size() != equipment.size():
		return false
	for key: String in resources:
		if not UtilityConfig.finite_number(saved.resources.get(key)) or float(saved.resources[key]) < 0 or float(saved.resources[key]) > float(config.data.capacities_kg[key]):
			return false
	for key: String in ledger:
		if not UtilityConfig.finite_number(saved.ledger.get(key)) or float(saved.ledger[key]) < 0:
			return false
		if key.begins_with("initial_") and absf(float(saved.ledger[key]) - ledger[key]) > (0.1 if key.ends_with("_j") else 1e-6):
			return false
	if absf(float(saved.ledger.chemical_heat_j) - float(saved.ledger.carbon_consumed_kg) * float(config.data.rates.carbon_chemical_wh_per_kg) * 3600.0) > 0.1:
		return false
	if absf(float(saved.ledger.carbon_consumed_kg) - (float(config.data.initial_resources.carbon_feed_kg) - float(saved.resources.carbon_feed_kg))) > 1e-6:
		return false
	if absf(float(saved.ledger.electrical_heat_j) - float(saved.ledger.load_wh) * 3600.0) > 0.1:
		return false
	for key: String in last_power:
		if not UtilityConfig.finite_number(saved.last_power.get(key)):
			return false
		if key != "battery_w" and float(saved.last_power[key]) < 0:
			return false
	for id: String in equipment:
		var device: Variant = saved.equipment.get(id)
		if not device is Dictionary:
			return false
		for flag: String in ["enabled", "fault", "maintenance", "powered"]:
			if not device.get(flag) is bool: return false
		if device.powered and (not device.enabled or device.fault or device.maintenance):
			return false
		if (not UtilityConfig.finite_number(device.get("runtime_s")) or float(device.runtime_s) < 0 or float(device.runtime_s) > float(saved.elapsed_s) + 1e-6
				or not UtilityConfig.finite_number(device.get("service_count")) or float(device.service_count) < 0 or float(device.service_count) != floorf(float(device.service_count))
				or not device.get("status") is String):
			return false
	var candidate := UtilityModel.new()
	candidate.configure(config)
	candidate._assign(saved)
	var residuals := candidate.conservation_errors()
	for key: String in residuals:
		if absf(float(residuals[key])) > (0.1 if key == "thermal_j" else 1e-5 if key == "electrical_wh" else 1e-6):
			return false
	_assign(saved)
	_update_alarms()
	changed.emit()
	return true


func _assign(saved: Dictionary) -> void:
	for key: String in resources: resources[key] = float(saved.resources[key])
	for key: String in ledger: ledger[key] = float(saved.ledger[key])
	elapsed_s = float(saved.elapsed_s)
	battery_wh = float(saved.battery_wh)
	thermal_j = float(saved.thermal_j)
	solar_fraction = float(saved.solar_fraction)
	occupied = bool(saved.occupied)
	last_power = saved.last_power.duplicate()
	for id: String in equipment:
		var data: Dictionary = saved.equipment[id]
		var device: UtilityEquipment = equipment[id]
		device.enabled = data.enabled
		device.fault = data.fault
		device.maintenance = data.maintenance
		device.powered = data.powered
		device.runtime_s = float(data.runtime_s)
		device.service_count = int(data.service_count)
		device.status = data.status
