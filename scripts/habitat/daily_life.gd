class_name DailyLife
extends Node
## Resource-backed research trays and routine logs. No physiological outcomes.
signal changed
var utilities: UtilityService
var inventory: RuntimeInventory
var settings: Dictionary
var trays: Array[Dictionary] = []
var nutrients: float = 0
var nutrient_used: float = 0
var water_used_kg: float = 0
var seed_used: int = 0
var harvested: int = 0
var seed_stock: int = 0
var ration_stock: int = 0
var completed: Dictionary = {}
var last_completed: Dictionary = {}
var job: Dictionary = {}
var loose_waste: int = 0
var sealed_waste: int = 0
var message: String = "Ready."
var development_growth_multiplier: float = 1


func configure(source: UtilityService, items: RuntimeInventory) -> void:
	utilities = source
	inventory = items
	settings = JSON.parse_string(FileAccess.get_file_as_string("res://resources/config/daily_life.json"))
	development_growth_multiplier = float(settings.development_growth_multiplier)
	nutrients = float(settings.initial_nutrients)
	for id: String in ["greens_seed", "fresh_greens", "dry_ration", "prepared_meal"]:
		var item := ItemDefinition.new()
		item.item_id = StringName(id)
		item.display_name = {"greens_seed":"Greens Seed", "fresh_greens":"Fresh Greens", "dry_ration":"Dry Ration", "prepared_meal":"Prepared Meal"}[id]
		item.description = {"greens_seed":"Leafy-greens seed. One seed plants one growing tray.", "fresh_greens":"A harvested portion of leafy greens. The galley can prepare it.", "dry_ration":"A packaged dry ration from the cargo delivery. The galley can prepare it.", "prepared_meal":"A cold prepared meal. Eating is not simulated yet."}[id]
		item.maximum_stack = 20
		if inventory.definition(item.item_id) == null: inventory.register_definition(item)
	seed_stock = int(settings.initial_seeds)
	ration_stock = int(settings.initial_rations)
	for i: int in int(settings.tray_count):
		trays.append({"crop_id":settings.crop.id, "planted":false, "light":true, "growth_s":0.0, "remaining_yield":0, "status":"Empty"})
	utilities.before_step.connect(prepare_step)
	utilities.stepped.connect(step)


func notify(text: String) -> bool:
	message = text
	changed.emit()
	return false


func environment_ok() -> bool:
	var m: UtilityModel = utilities.model
	return (m.equipment.ventilation.powered and m.temperature_k() >= float(settings.crop.min_temperature_k)
		and m.temperature_k() <= float(settings.crop.max_temperature_k) and m.pressure_pa() >= float(settings.crop.min_pressure_pa)
		and m.partial_pressure_pa("cabin_co2_kg") >= 1 and m.partial_pressure_pa("cabin_co2_kg") <= float(settings.crop.max_co2_pa)
		and m.humidity_g_m3() >= 3 and m.humidity_g_m3() <= 16)


func move_water(amount: float) -> bool:
	var m: UtilityModel = utilities.model
	if m.resources.potable_kg < amount or m.free_capacity("wastewater_kg") < amount: return false
	m.resources.potable_kg -= amount
	m.resources.wastewater_kg += amount
	water_used_kg += amount
	m._update_alarms()
	m.changed.emit()
	return true


func plant(index: int) -> bool:
	if index < 0 or index >= trays.size() or trays[index].planted: return notify("Tray unavailable.")
	if inventory.remove_items(StringName(settings.crop.seed_item), 1) != 1: return notify("No seeds available.")
	trays[index].planted = true
	trays[index].growth_s = 0.0
	trays[index].remaining_yield = 0
	seed_used += 1
	message = "Seed planted. Growth needs light, power, water, nutrients and cabin conditions."
	changed.emit()
	return true


func harvest(index: int) -> bool:
	if index < 0 or index >= trays.size() or trays[index].remaining_yield <= 0: return notify("Crop is not ready.")
	var accepted: int = inventory.add_items(StringName(settings.crop.yield_item), int(trays[index].remaining_yield))
	trays[index].remaining_yield -= accepted
	harvested += accepted
	if trays[index].remaining_yield == 0: trays[index].planted = false
	message = "Collected %d portions. %d remain in tray." % [accepted, trays[index].remaining_yield]
	changed.emit()
	return accepted > 0


func prepare_step(_seconds: float) -> void:
	var wanted: bool = false
	for tray: Dictionary in trays:
		if tray.planted and tray.remaining_yield == 0 and tray.light: wanted = true
	# This is a request; the utility dispatcher alone decides whether power is delivered.
	utilities.model.process_requests["greenhouse_lights"] = wanted


func step(seconds: float) -> void:
	var c: Dictionary = settings.crop
	for tray: Dictionary in trays:
		if not tray.planted:
			tray.status = "Empty"
			continue
		if tray.remaining_yield > 0:
			tray.status = "Harvest ready"
			continue
		tray.status = "Paused: cabin conditions"
		if not environment_ok(): continue
		tray.status = "Paused: light / power"
		if not tray.light or not utilities.model.equipment.greenhouse_lights.powered: continue
		var grow: float = minf(seconds * development_growth_multiplier, float(c.growth_s) - float(tray.growth_s))
		var fraction: float = grow / float(c.growth_s)
		var feed: float = fraction * float(c.nutrient_units_per_cycle)
		tray.status = "Paused: nutrients"
		if nutrients + 1e-12 < feed: continue
		tray.status = "Paused: water / wastewater capacity"
		if not move_water(fraction * float(c.water_kg_per_cycle)): continue
		nutrients = maxf(0, nutrients - feed)
		nutrient_used += feed
		tray.growth_s = minf(float(c.growth_s), float(tray.growth_s) + grow)
		tray.status = "Growing"
		if tray.growth_s >= float(c.growth_s):
			tray.remaining_yield = int(c.yield_count)
			tray.status = "Harvest ready"
	if not job.is_empty():
		if not bool(job.power) or utilities.model.equipment.housekeeping.powered:
			job.remaining_s = maxf(0, float(job.remaining_s) - seconds)
			if job.remaining_s == 0:
				var id: String = job.id
				completed[id] = int(completed.get(id, 0)) + 1
				last_completed[id] = utilities.model.elapsed_s
				message = id.capitalize() + " recorded. Detailed physiological effects are deferred."
				job = {}
	changed.emit()


func act(id: String) -> bool:
	if id == "resupply":
		seed_stock -= inventory.add_items(&"greens_seed", seed_stock)
		ration_stock -= inventory.add_items(&"dry_ration", ration_stock)
		message = "Delivered cargo transferred where inventory space permits. Remainders stay in cargo."
		changed.emit()
		return true
	if not job.is_empty(): return notify("Finish the current activity first.")
	if utilities.model.elapsed_s - float(last_completed.get(id, -1000)) < float(settings.cooldown_s): return notify("Activity recently completed.")
	if id in ["prepare_food", "prepare_greens"]:
		var ingredient: StringName = &"fresh_greens" if id == "prepare_greens" else &"dry_ration"
		if inventory.get_quantity(ingredient) < 1 or inventory.available_quantity_capacity(&"prepared_meal") < 1: return notify("Need the selected ingredient and inventory space.")
		if not move_water(0.1): return notify("Need potable water and wastewater capacity.")
		inventory.remove_items(ingredient, 1)
		inventory.add_items(&"prepared_meal", 1)
		loose_waste += 1
		completed[id] = int(completed.get(id, 0)) + 1
		last_completed[id] = utilities.model.elapsed_s
		message = "Cold meal prepared; water allocation returned to the sanitation loop abstraction."
	elif id == "dispose":
		if loose_waste == 0: return notify("No loose waste.")
		sealed_waste += loose_waste
		loose_waste = 0
		message = "Waste sealed and retained for later logistics."
	else:
		if not settings.activities.has(id): return notify("Unknown activity.")
		if id == "science" and inventory.get_quantity(&"lunar_sample") == 0: return notify("Bring a Lunar Sample; examination preserves it.")
		var definition: Dictionary = settings.activities[id]
		if bool(definition.power) and not utilities.model.equipment.housekeeping.powered: return notify("Workstation has no power.")
		if not move_water(float(definition.water_kg)): return notify("Need water and wastewater capacity.")
		job = {"id":id, "remaining_s":float(definition.duration_s), "power":bool(definition.power)}
		message = id.capitalize() + " started."
	changed.emit()
	return true


func capture_state() -> Dictionary:
	return {"schema_version":1, "seed_stock":seed_stock, "ration_stock":ration_stock, "trays":trays.duplicate(true), "nutrients":nutrients, "nutrient_used":nutrient_used,
		"water_used_kg":water_used_kg, "seed_used":seed_used, "harvested":harvested,
		"completed":completed.duplicate(), "last_completed":last_completed.duplicate(), "job":job.duplicate(),
		"loose_waste":loose_waste, "sealed_waste":sealed_waste, "development_growth_multiplier":development_growth_multiplier}


func set_growth_multiplier(value: float) -> bool:
	if not is_finite(value) or value < 1 or value > 3600: return false
	development_growth_multiplier = value
	changed.emit()
	return true


func restore_state(saved: Dictionary) -> bool:
	if saved.get("schema_version") != 1 or not saved.get("trays") is Array or saved.trays.size() != trays.size(): return false
	for key: String in ["seed_stock", "ration_stock", "nutrients", "nutrient_used", "water_used_kg", "seed_used", "harvested", "loose_waste", "sealed_waste", "development_growth_multiplier"]:
		if not UtilityConfig.finite_number(saved.get(key)) or float(saved[key]) < 0: return false
	for key: String in ["seed_stock", "ration_stock", "seed_used", "harvested", "loose_waste", "sealed_waste"]:
		if float(saved[key]) != floorf(float(saved[key])): return false
	if saved.development_growth_multiplier < 1 or saved.development_growth_multiplier > 3600: return false
	if saved.seed_stock > settings.initial_seeds or saved.ration_stock > settings.initial_rations: return false
	if absf(float(saved.nutrients) + float(saved.nutrient_used) - float(settings.initial_nutrients)) > 1e-6: return false
	for t: Variant in saved.trays:
		if not t is Dictionary or t.get("crop_id") != settings.crop.id or not t.get("planted") is bool or not t.get("light") is bool or not t.get("status") is String: return false
		for key: String in ["growth_s", "remaining_yield"]:
			if not UtilityConfig.finite_number(t.get(key)) or float(t[key]) < 0: return false
		if t.growth_s > settings.crop.growth_s or t.remaining_yield > settings.crop.yield_count or float(t.remaining_yield) != floorf(float(t.remaining_yield)): return false
		if t.remaining_yield > 0 and (not t.planted or t.growth_s != settings.crop.growth_s): return false
	for key: String in ["completed", "last_completed", "job"]:
		if not saved.get(key) is Dictionary: return false
	for key: String in saved.completed:
		if not UtilityConfig.finite_number(saved.completed[key]) or float(saved.completed[key]) < 0 or float(saved.completed[key]) != floorf(float(saved.completed[key])): return false
	for key: String in saved.last_completed:
		if not UtilityConfig.finite_number(saved.last_completed[key]) or float(saved.last_completed[key]) < 0: return false
	if not saved.job.is_empty():
		if not settings.activities.has(saved.job.get("id")) or not saved.job.get("power") is bool or not UtilityConfig.finite_number(saved.job.get("remaining_s")): return false
		if saved.job.remaining_s < 0 or saved.job.remaining_s > settings.activities[saved.job.id].duration_s: return false
		if saved.job.power != settings.activities[saved.job.id].power: return false
	trays.assign(saved.trays.duplicate(true))
	nutrients = float(saved.nutrients)
	seed_stock = int(saved.seed_stock)
	ration_stock = int(saved.ration_stock)
	nutrient_used = float(saved.nutrient_used)
	water_used_kg = float(saved.water_used_kg)
	seed_used = int(saved.seed_used)
	harvested = int(saved.harvested)
	loose_waste = int(saved.loose_waste)
	sealed_waste = int(saved.sealed_waste)
	development_growth_multiplier = float(saved.development_growth_multiplier)
	completed = saved.completed.duplicate()
	last_completed = saved.last_completed.duplicate()
	job = saved.job.duplicate()
	changed.emit()
	return true

