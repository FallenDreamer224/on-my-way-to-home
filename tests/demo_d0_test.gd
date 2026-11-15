extends SceneTree
## D0 route acceptance: real controller walking, existing portals and actual panel buttons.
## No teleportation, accelerated crop growth, room transfer shortcuts or simulated science.
var checks: int = 0
var failures: PackedStringArray = []
var main: Node
var actor: Astronaut
var dog: Chiwis
var director: HabitatDirector
var inventory: RuntimeInventory
var capture: bool = false
const MOVEMENT: PackedStringArray = ["player_move_left","player_move_right","player_move_up","player_move_down"]


func _initialize() -> void: run.call_deferred()


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures.append(label)


func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await process_frame


func release_walk() -> void:
	for action: String in MOVEMENT: Input.action_release(action)


func walk_to(point: Vector2) -> bool:
	var planner := TerrainRoutePlanner.new(director.active_terrain(), actor.footprint_half_extent)
	var route := planner.route(actor.global_position, point)
	check(not route.is_empty(), "Full-foot route exists")
	if route.is_empty(): return false
	var frames: int = 0
	for waypoint: Vector2 in route:
		while actor.global_position.distance_to(waypoint) > 2 and frames < 1200:
			var offset: Vector2 = waypoint - actor.global_position
			release_walk()
			if absf(offset.x) > 0.5 and absf(offset.x) >= absf(offset.y)*0.5:
				Input.action_press("player_move_right" if offset.x > 0 else "player_move_left")
			if absf(offset.y) > 0.5 and absf(offset.y) >= absf(offset.x)*0.5:
				Input.action_press("player_move_down" if offset.y > 0 else "player_move_up")
			await physics_frame
			frames += 1
	release_walk()
	await physics_frame
	check(actor.global_position.distance_to(point) < 4, "Real astronaut reaches route endpoint in %s: actual %s target %s route %s" % [director.location,actor.global_position,point,route])
	check(actor.walkability.is_position_walkable(actor.global_position, actor.footprint_half_extent), "Walking remains on valid floor")
	return actor.global_position.distance_to(point) < 4


func use(id: StringName) -> void:
	var action: HabitatAction = director.exterior_entry if director.location == &"outside" else director.rooms[director.location].actions[id]
	if not await walk_to(action.global_position): return
	# Let the actual companion follow into range; never carry it by moving its transform.
	for frame: int in 240:
		if dog.global_position.distance_to(action.global_position) < 100: break
		await physics_frame
	check(dog.global_position.distance_to(action.global_position) < 160, "Companion reaches portal safely")
	await physics_frame
	await physics_frame
	actor.get_node("InteractionDetector").refresh_target()
	check(actor.get_node("InteractionDetector").target == action, "Nearest target is intended station/hatch")
	await key(KEY_E)
	for frame: int in 180:
		if not director.busy: break
		await physics_frame
	check(not director.busy, "Portal or station transaction completes")


func photo(name: String) -> void:
	if not capture: return
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("res://tests/output/demo_d0_" + name + ".png") == OK, "Capture " + name)


func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	main = GameEntry.new_game()
	check(main != null, "Future New Game boundary creates existing Main")
	root.add_child(main)
	await process_frame
	await physics_frame
	await physics_frame
	actor = main.astronaut
	dog = main.chiwis
	director = main.get_node("Systems/HabitatDirector")
	inventory = actor.get_node("Inventory")
	var daily: DailyLife = main.get_node("Systems/Utilities/DailyLife")
	var old_actor: int = actor.get_instance_id()
	var old_dog: int = dog.get_instance_id()
	check(inventory.free_slot_count() == 20 and daily.completed.is_empty(), "Fresh session retains original initial state")
	check(main.get_node("World/Terrain/Ground").get_used_cells().size() == 1600, "Real 40x40 Moon loaded")
	check(main.get_node("Systems/EvaSafety").limits == main.get_node("World/Terrain/Ground").region.eva_limits, "Real EVA policy initialized")
	await photo("spawn")
	await key(KEY_E)
	check(inventory.get_quantity(&"lunar_sample") == 6, "Existing E interaction collects starting sample")
	await key(KEY_I)
	check(main.game_ui.inventory_window.visible and not actor.control_enabled, "Inventory displays collected resource and gates movement")
	await key(KEY_ESCAPE)
	check(not main.game_ui.inventory_window.visible and actor.control_enabled, "Inventory close releases movement")
	await key(KEY_TAB)
	check(main.gameplay_modes.is_management_mode(), "Real Tab input enters management mode")
	await photo("management")
	await key(KEY_TAB)
	check(main.gameplay_modes.is_player_mode(), "Tab returns to player")
	for id: StringName in [&"enter",&"seal_outer",&"inspection",&"cycle",&"inner",&"hub",&"health",&"science"]:
		await use(id)
	check(director.location == &"health_lab", "Walkable demonstration route reaches science compartment")
	var panel: DailyLifePanel = director.daily_panel
	check(panel.visible and panel.station == "science", "Existing science station opens real panel")
	var clicked: bool = false
	for button: Button in panel.commands.get_children():
		if button.text == "Examine sample":
			button.pressed.emit()
			clicked = true
	check(clicked and daily.job.get("id") == "science", "Actual panel button starts sample examination")
	for frame: int in 420:
		if daily.completed.get("science",0) == 1: break
		await physics_frame
	check(daily.completed.get("science",0) == 1 and daily.job.is_empty(), "Existing five-second examination completes")
	check(inventory.get_quantity(&"lunar_sample") == 6, "Examination preserves collected sample")
	check(main.get_node("Systems/Utilities").model.equipment.housekeeping.powered, "Station is powered by real utility dispatch")
	await photo("science_complete")
	await key(KEY_ESCAPE)
	check(not panel.visible and actor.control_enabled, "Routine panel closes without leaving modal input locked")
	check(actor.get_instance_id() == old_actor and dog.get_instance_id() == old_dog, "One astronaut and Chiwis retained through the route")
	for id: StringName in [&"hub",&"lock",&"crew",&"inspection",&"cycle",&"outer",&"outer"]:
		await use(id)
	check(director.location == &"outside", "Return to surface remains accessible")
	check(inventory.get_quantity(&"lunar_sample") == 6, "Inventory survives complete round trip")
	await photo("return")
	# Menu/New Game compatibility: dispose session, then build the same scene from scratch.
	main.queue_free()
	await process_frame
	main = GameEntry.new_game()
	root.add_child(main)
	await process_frame
	await physics_frame
	check(main.astronaut.get_instance_id() != old_actor and main.chiwis.get_instance_id() != old_dog, "Fresh game creates new actor ownership")
	check(main.astronaut.get_node("Inventory").get_quantity(&"lunar_sample") == 0, "New Game does not inherit prior inventory")
	check(main.get_node("World/Entities/Props").has_node("LunarSampleA"), "Fresh game restores original world pickups")
	check(main.get_node("Systems/Utilities/DailyLife").completed.is_empty(), "Fresh game has no prior objective/routine completion")
	check(main.get_node("Systems/HabitatDirector").location == &"outside", "Fresh game starts at original Moon entry")
	check(main.get_node("Systems/Utilities").model.alarms.is_empty(), "Fresh game restores nominal utility reserves")
	main.queue_free()
	await process_frame
	for failure: String in failures: printerr("FAIL: " + failure)
	if failures.is_empty(): print("PASS: %d D0 route/entry checks" % checks)
	quit(0 if failures.is_empty() else 1)

