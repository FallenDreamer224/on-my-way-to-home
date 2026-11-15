class_name UtilityConfig
extends RefCounted

const PATH: String = "res://resources/config/habitat_utilities.json"
const POOLS: PackedStringArray = ["cabin_o2_kg", "cabin_co2_kg", "cabin_n2_kg", "cabin_vapor_kg", "oxygen_store_kg", "captured_co2_kg", "potable_kg", "wastewater_kg", "reject_kg", "carbon_feed_kg"]
const DEVICE_IDS: PackedStringArray = ["solar", "battery", "distribution", "ventilation", "oxygen_supply", "co2_removal", "housekeeping", "heating", "thermal_control", "dehumidifier", "water_treatment"]
const SECTIONS: Dictionary = {
	"initial_resources": POOLS,
	"capacities_kg": POOLS,
	"rates": ["oxygen_load_kg_s", "water_use_kg_s", "water_to_vapor_fraction", "oxygen_supply_kg_s", "co2_removal_kg_s", "water_treatment_kg_s", "water_recovery_fraction", "dehumidify_kg_s", "carbon_chemical_wh_per_kg"],
	"targets": ["oxygen_partial_pa", "co2_kg", "humidity_g_m3", "heat_k", "cool_k"],
	"thermal": ["external_input_w", "passive_rejection_w", "active_rejection_w", "effective_sink_k"],
	"alarms": ["pressure_min_pa", "pressure_max_pa", "oxygen_min_pa", "oxygen_max_pa", "co2_max_pa", "humidity_min_g_m3", "humidity_max_g_m3", "temperature_min_k", "temperature_max_k", "water_reserve_kg", "oxygen_reserve_kg", "battery_reserve_wh"]
}
var data: Dictionary = {}


static func load_default() -> UtilityConfig:
	var result := UtilityConfig.new()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		result.data = parsed
	return result


static func finite_number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))


func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	for key: String in ["schema_version", "config_id", "fixed_step_s", "volume_m3", "heat_capacity_j_per_k", "initial_temperature_k", "initial_battery_wh", "battery_capacity_wh", "charge_efficiency", "discharge_efficiency", "max_charge_w", "max_discharge_w", "bus_capacity_w", "solar_available_w", "initial_solar_fraction", "initial_resources", "capacities_kg", "rates", "targets", "thermal", "alarms", "equipment"]:
		if not data.has(key):
			errors.append("Missing utility configuration field: " + key)
	if not errors.is_empty():
		return errors
	if data.schema_version != 1 or not data.config_id is String or String(data.config_id).is_empty():
		errors.append("Unsupported utility configuration version/id.")
	# Validate structure before indexing nested fields or converting any value.
	for section: String in SECTIONS:
		if not data[section] is Dictionary:
			errors.append("Utility configuration section must be a dictionary: " + section)
			continue
		for key: String in SECTIONS[section]:
			if not data[section].has(key):
				errors.append("Missing utility setting: " + section + "/" + key)
		if section in ["initial_resources", "capacities_kg"] and data[section].size() != POOLS.size():
			errors.append("Resource pools must match the schema version: " + section)
	if not data.equipment is Array:
		errors.append("Utility equipment must be an array.")
	if not errors.is_empty():
		return errors
	for key: String in ["fixed_step_s", "volume_m3", "heat_capacity_j_per_k", "initial_temperature_k", "battery_capacity_wh", "max_charge_w", "max_discharge_w", "bus_capacity_w", "solar_available_w"]:
		if not finite_number(data[key]) or float(data[key]) <= 0:
			errors.append("Utility configuration requires positive finite " + key)
	for key: String in ["charge_efficiency", "discharge_efficiency", "initial_solar_fraction"]:
		if not finite_number(data[key]) or float(data[key]) < 0 or float(data[key]) > 1 or (key != "initial_solar_fraction" and float(data[key]) == 0):
			errors.append("Invalid utility efficiency/fraction: " + key)
	if not finite_number(data.initial_battery_wh) or float(data.initial_battery_wh) < 0:
		errors.append("Invalid initial battery energy.")
	for section: String in ["initial_resources", "capacities_kg", "rates", "targets", "thermal", "alarms"]:
		for key: String in data[section]:
			if not finite_number(data[section][key]) or float(data[section][key]) < 0:
				errors.append("Invalid nonnegative utility setting: " + section + "/" + key)
	if not errors.is_empty():
		return errors
	if float(data.initial_battery_wh) > float(data.battery_capacity_wh):
		errors.append("Initial battery exceeds capacity.")
	for key: String in data.initial_resources:
		if not data.capacities_kg.has(key) or float(data.initial_resources[key]) > float(data.capacities_kg[key]):
			errors.append("Initial resource exceeds declared capacity: " + key)
	if float(data.rates.get("water_recovery_fraction", -1)) < 0 or float(data.rates.get("water_recovery_fraction", 2)) > 1:
		errors.append("Water recovery fraction must be in [0,1].")
	if float(data.rates.get("water_to_vapor_fraction", -1)) < 0 or float(data.rates.get("water_to_vapor_fraction", 2)) > 1:
		errors.append("Water/vapor split must be in [0,1].")
	if float(data.targets.heat_k) <= 0 or float(data.targets.cool_k) < float(data.targets.heat_k) or float(data.thermal.effective_sink_k) <= 0:
		errors.append("Invalid thermal targets/sink.")
	for pair: Array in [["pressure_min_pa", "pressure_max_pa"], ["oxygen_min_pa", "oxygen_max_pa"], ["humidity_min_g_m3", "humidity_max_g_m3"], ["temperature_min_k", "temperature_max_k"]]:
		if float(data.alarms[pair[0]]) >= float(data.alarms[pair[1]]):
			errors.append("Alarm minimum must be below maximum: " + String(pair[0]))
	var ids: Dictionary[String, bool] = {}
	for definition: Variant in data.equipment:
		if not definition is Dictionary:
			errors.append("Equipment entry must be a dictionary.")
			continue
		if (not definition.get("id") is String or String(definition.get("id", "")).is_empty()
				or not definition.get("name") is String or String(definition.get("name", "")).is_empty()
				or not finite_number(definition.get("watts")) or float(definition.get("watts", -1)) < 0
				or not finite_number(definition.get("priority")) or float(definition.get("priority", -1)) < 0
				or float(definition.get("priority", -1)) != floorf(float(definition.get("priority", -1)))
				or not definition.get("critical") is bool):
			errors.append("Invalid utility equipment fields.")
			continue
		if ids.has(definition.id):
			errors.append("Invalid/duplicate utility equipment definition.")
		ids[definition.id] = true
	for id: String in DEVICE_IDS:
		if not ids.has(id):
			errors.append("Missing required utility equipment: " + id)
	return errors
