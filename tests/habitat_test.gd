extends SceneTree
## Real production portals/actors/inventory with accelerated presentation-only cycles.

var checks: int = 0
var failures: Array[String] = []
var main: Node
var director: HabitatDirector
var actor: Astronaut
var dog: Chiwis
var detector: InteractionDetector
var _capture: bool = false


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)


func _use(id: StringName, through_input: bool = false) -> void:
	var action: HabitatAction = director.exterior_entry if director.location == &"outside" else director.rooms[director.location].actions[id]
	actor.global_position = action.global_position
	var ground := director.active_terrain()
	var at := IsometricGrid.world_to_tile(action.global_position, ground)
	for neighbor: Vector2i in IsometricGrid.neighbors(at):
		var point := IsometricGrid.tile_to_world(neighbor, ground)
		if dog.planner.walkability.is_position_walkable(point, dog.footprint_half_extent):
			dog.global_position = point
			break
	await physics_frame
	await physics_frame
	detector.refresh_target()
	check(detector.target == action, "Existing detector selects actual hatch/station " + id)
	if through_input:
		var down := InputEventKey.new()
		down.physical_keycode = KEY_E
		down.pressed = true
		Input.parse_input_event(down)
		Input.flush_buffered_events()
		await process_frame
		var up := InputEventKey.new()
		up.physical_keycode = KEY_E
		up.pressed = false
		Input.parse_input_event(up)
		Input.flush_buffered_events()
	else:
		check(detector.interact(), "Request accepted through existing interaction API " + id)
	var timeout: int = 0
	while director.busy and timeout < 90:
		await physics_frame
		timeout += 1
	check(not director.busy, "Transaction finishes " + id)
	if director.utility_panel != null and director.utility_panel.visible:
		director.utility_panel.close_panel()
	if director.daily_panel != null and director.daily_panel.visible:
		director.daily_panel.close_panel()
	check(not main.player_session.transition_blocked, "Input gate restored " + id)
	check(not (director.airlock.inner_open and director.airlock.outer_open), "Both airlock doors never open together")
	actor.set_physics_process(false)
	dog.set_physics_process(false)


func _photo(name: String) -> void:
	if not _capture:
		return
	main.camera_rig.refresh_follow()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("res://tests/output/habitat_" + name + ".png") == OK, "Capture " + name)


func _run() -> void:
	_capture = "--capture" in OS.get_cmdline_user_args()
	var lock := HabitatAirlock.new()
	check(not lock.open_inner(), "Vacuum cannot open inner hatch")
	check(lock.open_outer(), "Vacuum outer hatch allowed")
	check(not lock.begin_cycle(HabitatAirlock.Pressure.PRESSURIZED, false), "Open hatch prevents cycle")
	check(not lock.open_inner(), "Open outer excludes inner")
	lock.outer_open = false
	check(not lock.begin_cycle(HabitatAirlock.Pressure.PRESSURIZED, true), "Occupied cycle requires checks")
	lock.inspect()
	check(lock.begin_cycle(HabitatAirlock.Pressure.PRESSURIZED, true), "Checked and sealed chamber may cycle")
	check(not lock.open_inner() and not lock.open_outer(), "Cycling excludes both hatches")
	check(not lock.begin_cycle(HabitatAirlock.Pressure.VACUUM, true), "Cycle cannot reenter")
	check(lock.finish_cycle() and lock.open_inner(), "Matched pressure permits inner hatch")
	check(not lock.open_outer(), "Pressurized chamber excludes outer hatch")
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	director = main.get_node("Systems/HabitatDirector")
	director.cycle_seconds = 0.02
	actor = main.astronaut
	dog = main.chiwis
	detector = actor.get_node("InteractionDetector")
	actor.set_physics_process(false)
	dog.set_physics_process(false)
	var actor_id: int = actor.get_instance_id()
	var dog_id: int = dog.get_instance_id()
	var inventory: RuntimeInventory = actor.get_node("Inventory")
	var inventory_id: int = inventory.get_instance_id()
	var ground := director.outside_terrain()
	var old_cells: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	var pickups: Node = main.get_node("World/Entities/Props")
	var partial: WorldPickup = pickups.get_node("LunarSampleB")
	check(inventory.add_items(&"lunar_sample", inventory.available_quantity_capacity(&"lunar_sample") - 3) > 0, "Fill sample capacity leaving exact partial space")
	check(partial.collect(inventory) == 3 and partial.quantity == 5, "World pickup keeps exact partial remainder before entry")
	var old_quantity: int = inventory.get_quantity(&"lunar_sample")
	var old_pack := pickups.get_node("SupplyPack") as WorldPickup
	inventory.remove_items(&"lunar_sample", 14)
	old_quantity -= 14
	check(old_pack.collect(inventory) == 1, "Acquire supply pack before entering habitat")
	await process_frame
	var pack_count: int = inventory.get_quantity(&"supply_pack")
	main.management_camera.zoom_level = 3
	main.management_camera.set_pan_position(Vector2(100, -50))
	var old_pan: Vector2 = main.management_camera.pan_position
	actor.global_position = director.exterior_entry.global_position
	dog.global_position = Vector2(10000, 10000)
	check(not director.request_action(director.exterior_entry), "No transition strands a distant companion")
	var dog_cell := Vector2i(-8, 1)
	dog.global_position = IsometricGrid.tile_to_world(dog_cell, ground)
	var saved_kind: int = ground.terrain_cells[dog_cell]
	ground.terrain_cells.erase(dog_cell)
	check(not director.request_action(director.exterior_entry), "Unsafe companion cannot be carried through a portal")
	ground.terrain_cells[dog_cell] = saved_kind
	# Empty chamber left at habitat pressure by a prior operation must be matched
	# to vacuum before the exterior hatch can open.
	director.airlock.pressure = HabitatAirlock.Pressure.PRESSURIZED
	# Entry is an actual remappable interaction action, not a test-only transition API.
	await _use(&"enter", true)
	check(director.location == &"crew_airlock" and director.airlock.outer_open, "Exterior leads only to vacuum crew lock")
	check(director.airlock.pressure == HabitatAirlock.Pressure.VACUUM, "Initial crew-lock pressure is vacuum")
	check(main.get_node("Systems/EvaSafety").suspended, "Exterior EVA monitor suspended inside")
	await _use(&"inner")
	check(director.location == &"crew_airlock", "Inner hatch refuses vacuum/open outer")
	await _use(&"cycle")
	check(director.airlock.pressure == HabitatAirlock.Pressure.VACUUM, "Open outer prevents occupied cycling")
	await _use(&"seal_outer")
	await _use(&"cycle")
	check(director.airlock.pressure == HabitatAirlock.Pressure.VACUUM, "Missing inspection prevents cycle")
	await _use(&"inspection")
	check(director.airlock.suit_checked and director.airlock.dust_checked, "Suit/dust acknowledgments recorded")
	# During asynchronous cycling, modal/input actions and reentrant requests are blocked.
	var cycle_action: HabitatAction = director.rooms[&"crew_airlock"].actions[&"cycle"]
	actor.global_position = cycle_action.global_position
	dog.global_position = actor.global_position
	check(director.request_action(cycle_action), "Pressure operation starts")
	check(not director.request_action(cycle_action), "Duplicate operation refused")
	check(not main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT), "Cannot switch modes during transition")
	check(not main.player_session.set_inventory_open(true), "Cannot open inventory during transition")
	await create_timer(0.1).timeout
	check(director.airlock.pressure == HabitatAirlock.Pressure.PRESSURIZED and not director.busy, "Cycle completes with both doors sealed")
	await _photo("airlock")
	await _use(&"outer")
	check(not director.airlock.outer_open and director.location == &"crew_airlock", "Cannot expose pressurized chamber directly to vacuum")
	await _use(&"inner")
	check(director.location == &"equipment_lock" and not director.airlock.inner_open, "Equipment lock reached through pressure boundary; inner hatch closes")
	await _use(&"hub")
	check(director.location == &"hub", "Central corridor reached")
	await _photo("hub")
	main.camera_rig.zoom_level = 3
	main.management_camera.zoom_level = 2
	await _use(&"living")
	main.camera_rig.zoom_level = 1
	main.management_camera.zoom_level = 3
	await _use(&"hub")
	check(main.camera_rig.zoom_level == 3 and main.management_camera.zoom_level == 2, "Room-specific camera settings restored after visiting another room")
	# Inspect every accessible facility, and retain room/door state across return visits.
	var visited_facilities: Dictionary[StringName, bool] = {}
	for id: StringName in director.definitions:
		var room := director.prepare_room(id)
		var floor: TerrainLayer = room.get_node("Floor")
		check(floor.position == Vector2(-32, -16) and floor.tile_set.tile_size == Vector2i(64, 32), "Native floor alignment " + id)
		check(room.get_node("Walls").get_child_count() > 0, "Interior physical wall collision " + id)
		var planner := TerrainRoutePlanner.new(floor, actor.footprint_half_extent)
		var spawn := IsometricGrid.tile_to_world(HabitatRoom.cell(room.definition.spawn), floor)
		for cell: Vector2i in floor.terrain_cells:
			var point := IsometricGrid.tile_to_world(cell, floor)
			if floor.is_cell_walkable(cell):
				check(planner.walkability.is_position_walkable(point, actor.footprint_half_extent), "Complete actor foot on every traversable room cell " + id)
				check(not planner.route(spawn, point).is_empty(), "All advertised interior floor reachable " + id)
			else:
				# Finished floors also render underneath furniture and closed hatches.
				check(not planner.walkability.is_position_walkable(point, actor.footprint_half_extent), "Occupied/closed floor blocks actor " + id)
				check(planner.route(spawn, point).is_empty(), "Occupied/closed floor has no route " + id)
		for blocked: Vector2i in room.region.blocked_cells:
			check(not planner.walkability.is_position_walkable(IsometricGrid.tile_to_world(blocked, floor), actor.footprint_half_extent), "Cabinet/privacy partition blocks path " + id)
		for corner: Vector2 in [Vector2(-2000, -2000), Vector2(2000, -2000), Vector2(2000, 2000), Vector2(-2000, 2000)]:
			var clipped := planner.walkability.constrain_motion(spawn, corner, actor.footprint_half_extent)
			check(clipped.length() < corner.length() and planner.walkability.is_position_walkable(spawn + clipped, actor.footprint_half_extent), "Walls block long diagonal movement " + id)
	# Traverse the pressure-safe graph through real doors in both directions.
	for id: StringName in [&"living", &"engineering", &"greenhouse", &"cargo", &"health_lab"]:
		var hub_door: StringName = &"health" if id == &"health_lab" else id
		await _use(hub_door)
		check(director.location == id, "Enter compartment " + id)
		var first_instance: HabitatRoom = director.rooms[id]
		for facility: Dictionary in first_instance.definition.facilities:
			await _use(StringName(facility.id))
			visited_facilities[StringName(facility.id)] = true
			check(first_instance.state.inspected_facilities.has(StringName(facility.id)), "Station state retained " + String(facility.id))
		if id == &"living":
			await _photo("living")
		if id == &"health_lab":
			await _use(&"shelter")
			check(director.location == &"shelter", "Protected refuge accessible without EVA")
			await _use(&"shelter")
			visited_facilities[&"shelter"] = true
			await _photo("shelter")
			await _use(&"health")
		var visits_before_leaving: int = first_instance.state.visits
		await _use(&"hub")
		check(first_instance == director.rooms[id] and first_instance.state.visits == visits_before_leaving, "Room instance and state survive leaving " + id)
		await _use(hub_door)
		check(first_instance.state.visits == visits_before_leaving + 1 and not first_instance.state.inspected_facilities.is_empty(), "Revisit preserves inspected stations " + id)
		await _use(&"hub")
	for facility: Dictionary in director.rooms[&"hub"].definition.facilities:
		await _use(StringName(facility.id))
		visited_facilities[StringName(facility.id)] = true
	# Actual CharacterBody2D wall collision and live movement/following inside a room.
	var hub_floor := director.active_terrain()
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(3, 2), hub_floor)
	await physics_frame
	await physics_frame
	var to_cabinet := IsometricGrid.tile_to_world(Vector2i(3, 1), hub_floor) - actor.global_position
	check(actor.test_move(actor.global_transform, to_cabinet), "Physical wall/cabinet collider blocks CharacterBody2D")
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(2, 4), hub_floor)
	var start_x: float = actor.global_position.x
	actor.set_physics_process(true)
	await physics_frame
	await physics_frame
	var walk := InputEventKey.new()
	walk.physical_keycode = KEY_D
	walk.keycode = KEY_D
	walk.pressed = true
	Input.parse_input_event(walk)
	Input.flush_buffered_events()
	for tick: int in 8:
		await physics_frame
	walk = walk.duplicate()
	walk.pressed = false
	Input.parse_input_event(walk)
	Input.flush_buffered_events()
	await physics_frame
	check(actor.global_position.x > start_x, "Real movement input walks inside habitat")
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(6, 6), hub_floor)
	dog.global_position = IsometricGrid.tile_to_world(Vector2i(1, 2), hub_floor)
	dog.set_physics_process(true)
	dog.set_follow_enabled(true)
	for tick: int in 120:
		await physics_frame
	check(dog.global_position.distance_to(actor.global_position) < 60, "Chiwis actually follows around interior obstacles")
	check(dog.planner.walkability.is_position_walkable(dog.global_position, dog.footprint_half_extent), "Chiwis remains on safe interior floor")
	actor.set_physics_process(false)
	dog.set_physics_process(false)
	# Modal and focus checks are exercised inside, not only on the lunar surface.
	var room_door: HabitatAction = director.rooms[&"hub"].actions[&"living"]
	actor.global_position = room_door.global_position
	check(main.player_session.set_inventory_open(true), "Interior inventory opens")
	check(not director.request_action(room_door), "Modal prevents traversal")
	main.player_session.set_inventory_open(false)
	var edit := LineEdit.new()
	main.game_ui.add_child(edit)
	edit.grab_focus()
	await process_frame
	check(not director.request_action(room_door), "UI focus prevents traversal")
	edit.release_focus()
	edit.queue_free()
	await process_frame
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
	main.management_camera.set_pan_position(Vector2(100000, -100000))
	check(director.active_terrain().world_rect().has_point(main.management_camera.global_position), "Management camera bounded inside room")
	check(not director.request_action(room_door), "Management mode cannot traverse doors")
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.PLAYER)
	await _use(&"lock")
	for facility: Dictionary in director.rooms[&"equipment_lock"].definition.facilities:
		await _use(StringName(facility.id))
		visited_facilities[StringName(facility.id)] = true
	await _use(&"crew")
	await _use(&"airlock")
	visited_facilities[&"airlock"] = true
	check(visited_facilities.size() == 18, "Every required facility group has a visited interactive station")
	check(not director.airlock.suit_checked, "New EVA requires fresh checks")
	await _use(&"cycle")
	check(director.airlock.pressure == HabitatAirlock.Pressure.PRESSURIZED, "Outbound cycle refuses uninspected suit")
	await _use(&"inspection")
	await _use(&"cycle")
	check(director.airlock.pressure == HabitatAirlock.Pressure.VACUUM, "Outbound pressure match")
	await _use(&"outer")
	check(director.location == &"crew_airlock" and director.airlock.outer_open, "Outer hatch opens before actual exit")
	await _use(&"outer")
	check(director.location == &"outside" and not director.airlock.outer_open, "Exterior reached and hatch closed behind pair")
	check(actor.get_instance_id() == actor_id and dog.get_instance_id() == dog_id and actor.get_node("Inventory").get_instance_id() == inventory_id, "One persistent actor, companion and inventory")
	check(actor.get_parent() == main.get_node("World/Entities/Players") and dog.get_parent() == main.get_node("World/Entities/NPCs"), "Original exterior scene contracts restored")
	check(inventory.get_quantity(&"lunar_sample") == old_quantity and inventory.get_quantity(&"supply_pack") == pack_count, "Acquired items survive all transitions")
	check(is_instance_valid(partial) and partial.quantity == 5 and not pickups.has_node("SupplyPack"), "Partial remainder and collected-object removal persist")
	check(main.management_camera.zoom_level == 3 and main.management_camera.pan_position == old_pan, "Exterior camera settings and continuous pan preserved")
	check(not main.get_node("Systems/EvaSafety").suspended and not main.camera_rig.center_small_bounds, "Exterior safety/camera policies restored")
	check(ground.terrain_cells == old_cells and ground.get_used_cells().size() == 1600, "Exterior terrain state unchanged")
	# An independent new session must not inherit room state from the previous one.
	check(director.states[&"hub"].visits > 1, "Room visits persisted across scene transitions")
	main.queue_free()
	await process_frame
	var fresh: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(fresh)
	await process_frame
	var fresh_director: HabitatDirector = fresh.get_node("Systems/HabitatDirector")
	check(fresh_director.states[&"hub"].visits == 0 and fresh_director.states[&"living"].inspected_facilities.is_empty(), "New session does not inherit another session's room state")
	fresh.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: " + failure)
	if failures.is_empty():
		print("PASS: %d habitat/interior checks" % checks)
	quit(0 if failures.is_empty() else 1)
