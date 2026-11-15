extends SceneTree
var checks: int = 0
var failures: Array[String] = []
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label)
func run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	var service: UtilityService = main.get_node("Systems/Utilities")
	service.set_physics_process(false)
	var daily: DailyLife = service.get_node("DailyLife")
	var inventory: RuntimeInventory = main.astronaut.get_node("Inventory")
	daily.act("resupply")
	check(inventory.get_quantity(&"greens_seed") == 6, "Delivered seeds")
	check(daily.plant(0) and daily.plant(1), "Two independent trays")
	check(not daily.plant(0), "No double planting")
	check(not daily.set_growth_multiplier(NAN) and not daily.set_growth_multiplier(0), "Invalid acceleration refused")
	daily.set_growth_multiplier(1800)
	var before_water: float = daily.water_used_kg
	var before_oxygen: float = service.model.resources.oxygen_store_kg + service.model.resources.cabin_o2_kg
	service.advance(1)
	check(daily.trays[0].remaining_yield == 2 and daily.trays[1].remaining_yield == 2, "Accelerated complete cycles")
	check(absf(daily.water_used_kg - before_water - 0.4) < 1e-8 and absf(daily.nutrient_used - 2) < 1e-8, "Full cycle costs even during acceleration")
	check(service.model.equipment.greenhouse_lights.powered, "Grow lights pay dispatched power")
	check(service.model.resources.oxygen_store_kg + service.model.resources.cabin_o2_kg == before_oxygen, "No plant oxygen credited")
	for residual: float in service.model.conservation_errors().values(): check(absf(residual) < 0.1, "Utility ledger conserved")
	check(daily.harvest(0) and inventory.get_quantity(&"fresh_greens") == 2, "Harvest to existing inventory")
	check(not daily.harvest(0), "No duplicate harvest")
	check(daily.plant(0), "Replant consumes another seed")
	service.model.equipment_command("distribution", "fault")
	service.advance(1)
	check(daily.trays[0].growth_s == 0, "Power loss pauses crop")
	service.model.equipment_command("distribution", "maintain")
	service.model.equipment_command("distribution", "complete")
	daily.trays[0].light = false
	service.advance(1)
	check(daily.trays[0].growth_s == 0, "Light switch pauses crop")
	daily.trays[0].light = true
	service.model.equipment_command("greenhouse_lights", "toggle")
	service.advance(1)
	check(daily.trays[0].growth_s == 0, "Operator power switch overrides crop request")
	service.model.equipment_command("greenhouse_lights", "toggle")
	var nutrient_backup: float = daily.nutrients
	daily.nutrients = 0
	service.advance(1)
	check(daily.trays[0].growth_s == 0, "Nutrient depletion pauses crop")
	daily.nutrients = nutrient_backup
	var water_backup: float = service.model.resources.potable_kg
	service.model.resources.potable_kg = 0
	service.model.equipment.water_treatment.enabled = false
	service.advance(1)
	check(daily.trays[0].growth_s == 0, "Water depletion pauses crop")
	service.model.resources.potable_kg = water_backup
	var heat_backup: float = service.model.thermal_j
	service.model.thermal_j = 310 * float(service.model.config.data.heat_capacity_j_per_k)
	service.advance(1)
	check(daily.trays[0].growth_s == 0, "Environment pauses crop")
	service.model.thermal_j = heat_backup
	service.advance(1)
	check(daily.trays[0].remaining_yield == 2, "Conditions restored resumes growth")
	# Fill all inventory capacity, retain exact uncollected crop.
	inventory.add_items(&"fresh_greens", inventory.available_quantity_capacity(&"fresh_greens"))
	for id: StringName in [&"lunar_sample", &"metal_scrap", &"supply_pack"]:
		inventory.add_items(id, inventory.available_quantity_capacity(id))
	check(not daily.harvest(1) and daily.trays[1].remaining_yield == 2, "Full inventory retains crop")
	inventory.remove_items(&"fresh_greens", 1)
	check(daily.harvest(1) and daily.trays[1].remaining_yield == 1, "Partial harvest retains exact remainder")
	# Independent routine model uses existing stores and preserved sample identity.
	inventory.remove_items(&"fresh_greens", 20)
	inventory.add_items(&"lunar_sample", 1)
	service.advance(1)
	var sample: int = inventory.get_quantity(&"lunar_sample")
	for id: String in ["drink", "hygiene", "sleep", "exercise", "medical", "maintenance", "science"]:
		check(daily.act(id), "Activity starts " + id)
		check(not daily.act(id), "Activity excludes reentry " + id)
		for tick: int in 12: service.advance(1)
		check(daily.completed.get(id, 0) == 1, "Activity completes " + id)
	check(inventory.get_quantity(&"lunar_sample") == sample, "Science preserves sample")
	inventory.remove_items(&"lunar_sample", 20)
	check(daily.act("prepare_food") and inventory.get_quantity(&"prepared_meal") == 1, "Finite cold meal preparation")
	check(daily.act("dispose") and daily.sealed_waste == 1 and daily.loose_waste == 0, "Waste retained in sealed storage")
	check(daily.act("prepare_greens") and inventory.get_quantity(&"prepared_meal") == 2, "Harvest has a finite food preparation use")
	var saved: Dictionary = daily.capture_state()
	check(daily.restore_state(JSON.parse_string(JSON.stringify(saved))), "Daily state JSON restore")
	var bad: Dictionary = saved.duplicate(true)
	bad.nutrients = -1
	check(not daily.restore_state(bad), "Bad state rejected")
	var migration_model := UtilityModel.new()
	migration_model.configure(UtilityConfig.load_default())
	var legacy: Dictionary = migration_model.capture_state()
	legacy.config_id = "moon_utilities_v1"
	legacy.equipment.erase("greenhouse_lights")
	check(migration_model.restore_state(legacy), "Previous utility snapshot migrates new optional load")
	var director: HabitatDirector = main.get_node("Systems/HabitatDirector")
	var panel: DailyLifePanel = director.daily_panel
	for id: String in ["greenhouse","galley","hygiene","sleep","exercise","medical","operations","science"]:
		panel.open_panel(id)
		await process_frame
		check(main.player_session.inspection_blocked and not main.astronaut.control_enabled, "Modal permissions " + id)
		check(Rect2(Vector2.ZERO, Vector2(960,540)).encloses(panel.get_global_rect()), "Panel fits viewport " + id)
		panel.close_panel()
	check(not main.player_session.inspection_blocked, "Modal close restores permissions")
	# Every room/action has a reachable parking position away from access points.
	var dog: Chiwis = main.chiwis
	for id: StringName in director.definitions:
		var room: HabitatRoom = director.prepare_room(id)
		dog.configure_terrain(room.get_node("Floor"))
		dog.global_position = IsometricGrid.tile_to_world(HabitatRoom.cell(room.definition.companion_spawn), room.get_node("Floor"))
		dog.reserved_access.clear()
		for action: HabitatAction in room.actions.values(): dog.reserved_access.append(action.global_position)
		for action: HabitatAction in room.actions.values():
			var goal: Vector2 = dog.parking_goal(action.global_position)
			check(not dog.planner.route(dog.global_position, goal).is_empty(), "Parking reachable " + id)
			for access: Vector2 in dog.reserved_access: check(goal.distance_to(access) >= 24, "Parking clears equipment/door " + id)
	if "--capture" in OS.get_cmdline_user_args():
		director._switch_space(&"greenhouse")
		main.astronaut.set_physics_process(false)
		dog.set_physics_process(false)
		var station: HabitatAction = director.rooms[&"greenhouse"].actions[&"greenhouse"]
		main.astronaut.global_position = station.global_position
		main.player_session.apply_permissions()
		await physics_frame
		await physics_frame
		main.astronaut.get_node("InteractionDetector").refresh_target()
		check(main.astronaut.get_node("InteractionDetector").interact(), "Production greenhouse station accepts interaction")
		for frame: int in 5: await process_frame
		check(panel.visible and main.player_session.inspection_blocked, "Station opens actual modal")
		panel.open_panel("greenhouse")
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/output/daily_life.png")
	main.queue_free()
	await process_frame
	for failure: String in failures: printerr("FAIL: " + failure)
	if failures.is_empty(): print("PASS: %d daily-life checks" % checks)
	quit(0 if failures.is_empty() else 1)

