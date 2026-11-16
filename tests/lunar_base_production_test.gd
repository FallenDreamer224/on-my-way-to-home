extends "res://tests/demo_d0_test.gd"
## Normal configured menu/New Game journey. Uses real inputs, walking and existing services.

const OUTPUT: String = "res://tests/output/phase_0_9/captures/"
var app: AppRoot

func settle() -> void:
	await physics_frame
	await process_frame

func click(button: Button) -> void:
	check(button.is_visible_in_tree() and not button.disabled, "Actual UI button available: " + button.text)
	var position: Vector2 = root.get_final_transform() * button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = position
	Input.parse_input_event(motion)
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await settle()

func command(text: String) -> void:
	var found: bool = false
	for button: Button in director.daily_panel.commands.get_children():
		if button.text == text:
			await click(button)
			found = true
			break
	check(found, "Supported station command exists: " + text)

func photo(name: String) -> void:
	if not capture: return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image.get_size() == Vector2i(960, 540), "Normal gameplay capture remains 960x540")
	check(image.save_png(OUTPUT + name + ".png") == OK, "Runtime capture: " + name)

func overview() -> void:
	if not capture: return
	# A native large evidence view of the SAME running production World2D, not a preview scene.
	var viewport := SubViewport.new()
	viewport.size = Vector2i(2688, 1536)
	viewport.world_2d = root.world_2d
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	var camera := Camera2D.new()
	camera.position = Vector2(0, -32)
	camera.zoom = Vector2.ONE
	viewport.add_child(camera)
	camera.make_current()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	check(viewport.get_texture().get_image().save_png(OUTPUT + "04_base_overview_native.png") == OK, "Full native overview from the real New Game world")
	viewport.queue_free()
	await settle()

func verify_room() -> void:
	var room: HabitatRoom = director.rooms[director.location]
	check(room is InteriorArtRoom, "Production factory uses actual furnished scene: " + String(director.location))
	check(actor.walkability.is_position_walkable(actor.global_position, actor.footprint_half_extent), "Safe astronaut room arrival")
	check(dog.planner.walkability.is_position_walkable(dog.global_position, dog.footprint_half_extent), "Safe companion room arrival")
	for action: HabitatAction in room.actions.values():
		for other: HabitatAction in room.actions.values():
			if other != action: check(not other.global_position.is_equal_approx(action.global_position), "Production actions have distinct nearest-target positions")
		var route := dog.planner.route(dog.global_position, action.global_position)
		check(not route.is_empty(), "Production station/door reachable by Chiwis: " + String(director.location) + "/" + String(action.action_id))

func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var settings := AppSettings.new("res://tests/output/phase_0_9/preferences.cfg")
	settings.set_display(false, 1, false)
	settings.set_interface(1, false, true)
	AppSettings.replace_shared(settings)
	var entry: String = ProjectSettings.get_setting("application/run/main_scene")
	check(entry == "res://scenes/app_root.tscn", "Test enters the configured application scene")
	app = (load(entry) as PackedScene).instantiate()
	root.add_child(app)
	await settle()
	check(app.menu != null and app.session == null, "Real menu appears before gameplay")
	await photo("01_main_menu")
	await click(app.menu.buttons[&"new_game"])
	for frame: int in 60:
		if app.session != null and not app.busy: break
		await settle()
	check(app.session != null and app.menu == null, "Actual New Game button loads Moon session")
	main = app.session
	# Let physics publish the relocated pickup areas before the first interaction.
	await settle()
	await settle()
	actor = main.astronaut
	dog = main.chiwis
	director = main.get_node("Systems/HabitatDirector")
	inventory = actor.get_node("Inventory")
	var daily: DailyLife = main.get_node("Systems/Utilities/DailyLife")
	var utilities: UtilityService = main.get_node("Systems/Utilities")
	var identities: Array[int] = [actor.get_instance_id(), dog.get_instance_id(), inventory.get_instance_id(), utilities.get_instance_id(), daily.get_instance_id()]
	var base: LunarBaseWorld = main.lunar_base
	check(base != null and base.assembly.is_visible_in_tree() and base.assembly.hulls.size() == 9, "Native modular outpost visible in normal production world")
	check(base.assembly.get_parent() == main.get_node("World/Entities/Buildings"), "Base belongs to the real Y-sorted world")
	check(not main.has_node("LunarBasePreview") and base.assembly.scale == Vector2.ONE, "No preview or flattened-image substitute")
	var ground: TerrainLayer = director.outside_terrain()
	check(ground.terrain_cells == base.original_cells and ground.terrain_cells.size() == 1600, "Existing 40x40 terrain kinds preserved")
	check(not (main.get_node("Systems/EvaSafety") as EvaSafetyMonitor).suspended, "Production EVA guidance stays active outdoors")
	check((load("res://resources/config/lunar_eva_safety.tres") as EvaSafetyLimits).return_cell == Vector2i.ZERO, "Source EVA Resource remains unchanged")
	check(actor.walkability.is_position_walkable(actor.global_position, actor.footprint_half_extent), "Normal production spawn is safe")
	check(ground.is_cell_walkable(base.assembly.entry_cell()), "Real hatch approach is walkable")
	for module: Dictionary in base.assembly.layout.modules:
		check((ground.region as LunarTutorialRegion).eva_limits.allowed_cells.encloses(Rect2i(LunarBaseAssembly.cell(module.origin), LunarBaseAssembly.cell(module.size))), "Every module fits existing mission perimeter")
	await photo("02_initial_moon_spawn")
	await photo("03_base_from_spawn")
	await key(KEY_E)
	check(inventory.get_quantity(&"lunar_sample") == 6, "Nearby sample is collected through normal E input")
	await key(KEY_I)
	check(main.game_ui.inventory_window.visible and not actor.control_enabled, "Existing inventory blocks walking")
	await key(KEY_ESCAPE)
	await key(KEY_TAB)
	check(main.gameplay_modes.is_management_mode() and main.game_ui.dashboard.visible, "Real Base Management camera/dashboard active")
	var stopped: Vector2 = actor.global_position
	for category: Array in ManagementDashboard.CATEGORIES:
		await click(main.game_ui.dashboard.rail_buttons[category[0]])
		await settle()
		check(root.get_visible_rect().encloses(main.game_ui.dashboard.get_global_rect()), "Dashboard category fits normal viewport: " + String(category[0]))
		check(actor.global_position == stopped and root.gui_get_focus_owner() == null, "Dashboard categories preserve gameplay input ownership")
	await click(main.game_ui.dashboard.rail_buttons[&"power"])
	check(actor.global_position == stopped and main.game_ui.dashboard.current == &"power", "Dashboard click selects telemetry without moving astronaut")
	Input.action_press(&"camera_pan_right")
	var before_pan: Vector2 = main.management_camera.pan_position
	for frame: int in 12: await physics_frame
	Input.action_release(&"camera_pan_right")
	check(main.management_camera.pan_position != before_pan, "Existing management pan input works")
	await photo("15_base_management_dashboard")
	await overview()
	await key(KEY_TAB)
	check(main.gameplay_modes.is_player_mode(), "Existing Tab returns to Player Mode")
	await walk_to(IsometricGrid.tile_to_world(Vector2i(-16, 10), ground))
	for frame: int in 120: await physics_frame
	check(dog.global_position.distance_to(actor.global_position) < 120, "Chiwis follows through the real exterior equipment routes")
	await photo("05_astronaut_beside_base")
	await photo("06_chiwis_exterior_following")
	await walk_to(director.exterior_entry.global_position)
	await photo("07_airlock_entrance")
	await use(&"enter")
	verify_room()
	await photo("20_crew_airlock")
	for id: StringName in [&"seal_outer", &"inspection", &"cycle", &"inner"]: await use(id)
	check(director.location == &"equipment_lock", "Normal interlocked entrance reaches furnished interior")
	verify_room()
	await photo("08_interior_entry")
	await use(&"hub")
	verify_room()
	await photo("11_mission_control")
	await photo("14_player_mode_interior_hud")
	await use(&"operations")
	check(director.daily_panel.visible and director.daily_panel.station == "operations", "Existing operations station is connected")
	await key(KEY_ESCAPE)
	await use(&"health")
	verify_room()
	await photo("13_research_area")
	await use(&"science")
	await command("Examine sample")
	for frame: int in 420:
		if daily.completed.get("science", 0) > 0: break
		await physics_frame
	check(daily.completed.get("science", 0) == 1, "Real powered sample examination completes")
	check(main.objectives.is_complete(&"examine_sample"), "Existing mission observes actual completed activity")
	await key(KEY_ESCAPE)
	await use(&"shelter")
	verify_room()
	await photo("17_emergency_shelter")
	await use(&"health")
	await use(&"hub")
	await use(&"cargo")
	verify_room()
	await photo("13_storage_area")
	await use(&"cargo")
	await command("Collect supplies")
	check(inventory.get_quantity(&"greens_seed") == 6 and daily.seed_stock == 0, "Cargo transfers actual finite seeds into existing inventory")
	await key(KEY_ESCAPE)
	await use(&"hub")
	await use(&"greenhouse")
	verify_room()
	var greenhouse: InteriorArtRoom = director.rooms[&"greenhouse"]
	check(greenhouse.crop_views.size() == 2 and greenhouse.crop_views[0].daily == daily, "Actual greenhouse artwork observes the original simulation")
	await photo("12_greenhouse")
	await use(&"greenhouse")
	await command("Plant seed")
	check(daily.trays[0].planted and inventory.get_quantity(&"greens_seed") == 5, "Real greenhouse button consumes one actual seed")
	await key(KEY_ESCAPE)
	for frame: int in 120: await physics_frame
	check(daily.trays[0].growth_s > 0 and daily.water_used_kg > 0 and daily.nutrient_used > 0, "Normal simulation time charges water and nutrients for growth")
	check(greenhouse.crop_views[0].stage == &"seeded" and greenhouse.crop_views[0].light_powered, "Rendered stage/light match the real early crop state")
	await photo("18_greenhouse_planted")
	await use(&"hub")
	await use(&"engineering")
	verify_room()
	await photo("10_engineering_equipment")
	await use(&"power")
	check(director.utility_panel.visible and director.utility_panel.service == utilities, "Existing power terminal reports actual shared utility state")
	await photo("19_actual_utility_terminal")
	await key(KEY_ESCAPE)
	await use(&"water")
	check(director.utility_panel.visible, "Actual water station accessible")
	await key(KEY_ESCAPE)
	await use(&"eclss")
	check(director.utility_panel.visible, "Actual ECLSS station accessible")
	await key(KEY_ESCAPE)
	await use(&"hub")
	await use(&"living")
	verify_room()
	await photo("09_living_area")
	await use(&"galley")
	await command("Prepare ration")
	check(inventory.get_quantity(&"prepared_meal") == 1, "Existing galley consumes delivered ration through real UI")
	await key(KEY_ESCAPE)
	await use(&"sleep")
	check(director.daily_panel.visible and director.daily_panel.station == "sleep", "Existing sleep activity station accessible")
	await key(KEY_ESCAPE)
	for id: StringName in [&"hub", &"lock", &"crew", &"inspection", &"cycle", &"outer", &"outer"]: await use(id)
	check(director.location == &"outside", "Astronaut and Chiwis return through the real airlock to the Moon")
	check(identities == [actor.get_instance_id(), dog.get_instance_id(), inventory.get_instance_id(), utilities.get_instance_id(), daily.get_instance_id()], "One astronaut/Chiwis/inventory and shared utility/crop state survive every transition")
	check(inventory.get_quantity(&"lunar_sample") == 6 and daily.trays[0].planted and director.rooms.size() == 9, "Collected items, crop and all nine furnished rooms persist")
	check(not (director.airlock.outer_open and director.airlock.inner_open), "Pressure boundaries remain interlocked")
	check(not (main.get_node("Systems/EvaSafety") as EvaSafetyMonitor).suspended, "EVA guidance resumes after exit")
	await photo("16_returning_outdoors")
	release_walk()
	app.queue_free()
	await settle()
	for failure: String in failures: printerr("FAIL: " + failure)
	if failures.is_empty(): print("PASS: %d normal menu/New Game lunar-base production checks" % checks)
	quit(0 if failures.is_empty() else 1)
