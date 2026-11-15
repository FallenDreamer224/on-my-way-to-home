class_name HabitatDirector
extends Node
## Persistent space composition and transactional hatch/room changes. Never respawn actors.

signal location_changed(location: StringName)
signal airlock_changed

const ROOM: PackedScene = preload("res://scenes/habitat/habitat_room.tscn")
var location: StringName = &"outside"
var busy: bool = false
var airlock := HabitatAirlock.new()
var rooms: Dictionary[StringName, HabitatRoom] = {}
var states: Dictionary[StringName, HabitatRoomState] = {}
var definitions: Dictionary[StringName, Dictionary] = {}
var exterior_entry: HabitatAction
var cycle_seconds: float = 1.0
var default_room_zoom: int = 1
var _main: Node
var _spaces: Node2D
var _views: Dictionary[StringName, Dictionary] = {}
var _outside_actor_position: Vector2
var _outside_dog_position: Vector2
var _hud_status: Label
var utilities: UtilityService
var utility_panel: UtilityPanel
var daily_panel: DailyLifePanel


func configure(main: Node) -> void:
	_main = main
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/data/habitat_layout.json"))
	cycle_seconds = float(layout.cycle_presentation_seconds)
	default_room_zoom = int(layout.get("default_room_zoom", 1))
	for data: Dictionary in layout.rooms:
		definitions[StringName(data.id)] = data
		states[StringName(data.id)] = HabitatRoomState.new()
	_spaces = Node2D.new()
	_spaces.name = "HabitatInteriors"
	main.add_child(_spaces)
	_hud_status = Label.new()
	_hud_status.name = "HabitatStatus"
	_hud_status.position = Vector2(252, 80)
	_hud_status.size = Vector2(416, 64)
	_hud_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud_status.add_theme_font_size_override("font_size", 12)
	_hud_status.add_theme_color_override("font_outline_color", Color("0a1118"))
	_hud_status.add_theme_constant_override("outline_size", 2)
	_hud_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hud_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_status.hide()
	main.game_ui.hud.add_child(_hud_status)
	exterior_entry = HabitatRoom.make_action(&"outside", &"enter", "Habitat crew airlock", &"crew_airlock", request_action)
	exterior_entry.position = IsometricGrid.tile_to_world(HabitatRoom.cell(layout.exterior_entry_cell), outside_terrain())
	main.get_node("World/Entities/Buildings").add_child(exterior_entry)
	airlock_changed.connect(_refresh_airlock)


func outside_terrain() -> TerrainLayer:
	return _main.get_node("World/Terrain/Ground")


func active_terrain() -> TerrainLayer:
	return outside_terrain() if location == &"outside" else rooms[location].get_node("Floor")


func prepare_room(id: StringName) -> HabitatRoom:
	if rooms.has(id):
		return rooms[id]
	if not definitions.has(id):
		return null
	var room: HabitatRoom = ROOM.instantiate()
	room.name = String(id)
	room.setup(definitions[id], states[id], request_action)
	room.visible = false
	room.process_mode = Node.PROCESS_MODE_DISABLED
	_spaces.add_child(room)
	rooms[id] = room
	_refresh_airlock()
	return room


func _refresh_airlock() -> void:
	if _hud_status != null:
		_hud_status.visible = location != &"outside"
		if location != &"outside":
			_hud_status.text = String(definitions[location].title).to_upper()
			if location == &"crew_airlock":
				_hud_status.text += "\n%s | Outer %s | Inner %s | Checks %s" % [
					["VACUUM", "HABITAT MATCH", "CYCLING"][airlock.pressure],
					"open" if airlock.outer_open else "sealed", "open" if airlock.inner_open else "sealed",
					"done" if airlock.suit_checked and airlock.dust_checked else "pending"]
	if not rooms.has(&"crew_airlock"):
		return
	var room: HabitatRoom = rooms[&"crew_airlock"]
	room.actions[&"outer"].display_name = "Exit to lunar surface" if airlock.outer_open else "Open outer hatch"
	room.actions[&"cycle"].display_name = "Match habitat pressure" if airlock.pressure == HabitatAirlock.Pressure.VACUUM else "Match exterior vacuum"
	room.actions[&"seal_outer"].available = airlock.outer_open


func request_action(action: HabitatAction) -> bool:
	if (busy or not is_instance_valid(action) or not action.is_available() or action.room_id != location
			or not _main.gameplay_modes.is_player_mode() or _main.gameplay_modes.modal_input_blocked
			or not _main.astronaut.control_enabled or get_viewport().gui_get_focus_owner() != null):
		return false
	var player: Astronaut = _main.astronaut
	if (action != exterior_entry if location == &"outside" else rooms[location].actions.get(action.action_id) != action):
		return false
	var offset: Vector2 = action.global_position - player.global_position
	if offset.length() > player.get_node("InteractionDetector").interaction_range or not player.walkability.constrain_motion(player.global_position, offset, player.footprint_half_extent).is_equal_approx(offset):
		return false
	if action.destination != &"facility" and _main.chiwis.global_position.distance_to(action.global_position) > 160:
		_notice("Wait for Chiwis to reach the hatch.")
		return false
	if action.destination != &"facility" and _main.chiwis.planner.route(_main.chiwis.global_position, action.global_position).is_empty():
		_notice("Chiwis needs a clear route to the hatch.")
		return false
	busy = true
	_main.player_session.set_transition_blocked(true)
	_main.chiwis.set_follow_enabled(false)
	_perform.call_deferred(action)
	return true


func _perform(action: HabitatAction) -> void:
	var success: bool = await _apply(action)
	if success and states.has(action.room_id) and action.destination != &"facility":
		var saved: HabitatRoomState = states[action.room_id]
		saved.door_uses[action.action_id] = saved.door_uses.get(action.action_id, 0) + 1
	busy = false
	_main.player_session.set_transition_blocked(false)
	_main.chiwis.set_follow_enabled(_main.gameplay_modes.is_player_mode())
	_main.astronaut.get_node("InteractionDetector").refresh_target()
	airlock_changed.emit()


func _apply(action: HabitatAction) -> bool:
	var destination: StringName = action.destination
	if destination == &"facility":
		states[location].inspected_facilities[action.action_id] = true
		action.action_label = "Review"
		if daily_panel != null and action.action_id in [&"cargo", &"greenhouse", &"galley", &"hygiene", &"sleep", &"exercise", &"medical", &"operations", &"science"]:
			daily_panel.open_panel(String(action.action_id))
			return true
		if action.action_id in [&"eclss", &"water", &"power"] and utilities != null and utility_panel != null:
			utility_panel.open_panel({&"eclss": "ventilation", &"water": "water_treatment", &"power": "distribution"}[action.action_id])
			return true
		_notice(action.display_name + ": inspection recorded.")
		return true
	if location == &"outside":
		if not await _match_empty_chamber(HabitatAirlock.Pressure.VACUUM):
			return false
		if not airlock.open_outer():
			return _deny("Outer hatch interlock: chamber must match exterior vacuum.")
		_outside_actor_position = _main.astronaut.global_position
		_outside_dog_position = _main.chiwis.global_position
		_switch_space(&"crew_airlock")
		airlock.reset_inspection()
		_notice("Crew airlock: close the outer hatch, inspect suit/dust seals, then cycle pressure.", 7)
		return true
	if location == &"crew_airlock":
		match destination:
			&"seal_outer":
				airlock.outer_open = false
				_notice("Outer hatch sealed. Inspect suit / dust seals before cycling.")
				return true
			&"inspect":
				if not airlock.inspect():
					return _deny("Inspection unavailable while pressure is cycling.")
				_notice("Suit and dust-seal checks acknowledged. Ready for pressure matching.")
				return true
			&"cycle":
				var target: HabitatAirlock.Pressure = HabitatAirlock.Pressure.PRESSURIZED if airlock.pressure == HabitatAirlock.Pressure.VACUUM else HabitatAirlock.Pressure.VACUUM
				return await _cycle(target, true)
			&"outside":
				if not airlock.outer_open:
					if not airlock.open_outer():
						return _deny("Outer hatch locked: seal both hatches, inspect, then cycle to vacuum.")
					_notice("Outer hatch open to vacuum. Use it again to exit with Chiwis.")
					return true
				_switch_space(&"outside")
				airlock.outer_open = false
				airlock.reset_inspection()
				_notice("Back on the lunar surface. Outer hatch closed behind you.")
				return true
			&"equipment_lock":
				if not airlock.open_inner():
					return _deny("Inner hatch locked: close outer hatch and match habitat pressure first.")
				_switch_space(&"equipment_lock")
				airlock.inner_open = false
				_notice("Equipment lock. Dust control and suit maintenance are on the clean side.")
				return true
		return false
	if destination == &"crew_airlock":
		if location != &"equipment_lock" or not await _match_empty_chamber(HabitatAirlock.Pressure.PRESSURIZED):
			return false
		if not airlock.open_inner():
			return _deny("Inner hatch interlock is not ready.")
		_switch_space(&"crew_airlock")
		airlock.inner_open = false
		airlock.reset_inspection()
		_notice("Crew airlock. Inspect suit/dust seals, cycle to vacuum, then use the outer hatch.", 7)
		return true
	# Ordinary compartment links are exclusively inside the assumed pressurized domain.
	if (destination == &"outside" or not definitions.has(destination)
			or definitions[location].pressure_domain != "habitat" or definitions[destination].pressure_domain != "habitat"):
		return _deny("No ordinary compartment door opens directly to vacuum.")
	_switch_space(destination)
	_notice("Entered " + String(definitions[destination].title) + ".")
	return true


func _deny(text: String) -> bool:
	_notice(text)
	return false


func _match_empty_chamber(target: HabitatAirlock.Pressure) -> bool:
	if airlock.outer_open or airlock.inner_open:
		return _deny("Seal both airlock hatches before changing pressure.")
	return true if airlock.pressure == target else await _cycle(target, false)


func _cycle(target: HabitatAirlock.Pressure, occupied: bool) -> bool:
	if not airlock.begin_cycle(target, occupied):
		return _deny("Cycle refused: seal both hatches and complete suit/dust inspection.")
	airlock_changed.emit()
	_notice("Matching airlock pressure. Keep both hatches sealed.")
	await get_tree().create_timer(cycle_seconds).timeout
	if not airlock.finish_cycle():
		return _deny("Airlock pressure interlock was interrupted.")
	_notice("Pressure state: " + ("habitat match" if target == HabitatAirlock.Pressure.PRESSURIZED else "vacuum match") + ".")
	return true


func _save_view() -> void:
	_views[location] = {"player_zoom": _main.camera_rig.zoom_level,
		"management_zoom": _main.management_camera.zoom_level, "pan": _main.management_camera.pan_position}


func _arrival_cells(room: HabitatRoom, source: StringName) -> Array[Vector2i]:
	var floor: TerrainLayer = room.get_node("Floor")
	var player_cell := HabitatRoom.cell(room.definition.spawn)
	var dog_cell := HabitatRoom.cell(room.definition.companion_spawn)
	# Surface ingress uses the explicit close-hatch staging anchors. Internal links
	# arrive just inside the reciprocal doorway, instead of at an unrelated room center.
	if source != &"outside":
		for door: Dictionary in room.definition.doors:
			if StringName(door.destination) != source:
				continue
			var threshold := HabitatRoom.cell(door.point)
			for step: Vector2i in IsometricGrid.CARDINAL_STEPS:
				if floor.is_cell_walkable(threshold + step):
					player_cell = threshold + step
					break
			for step: Vector2i in IsometricGrid.CARDINAL_STEPS:
				if floor.is_cell_walkable(player_cell + step):
					dog_cell = player_cell + step
					break
			break
	return [player_cell, dog_cell]


func _switch_space(destination: StringName) -> void:
	_save_view()
	var old_location: StringName = location
	var player: Astronaut = _main.astronaut
	var dog: Chiwis = _main.chiwis
	var terrain: TerrainLayer
	if destination == &"outside":
		_main.get_node("World").process_mode = Node.PROCESS_MODE_INHERIT
		_main.get_node("World").show()
		player.reparent(_main.get_node("World/Entities/Players"), false)
		dog.reparent(_main.get_node("World/Entities/NPCs"), false)
		terrain = outside_terrain()
		player.global_position = _outside_actor_position
		dog.global_position = _outside_dog_position
	else:
		var room := prepare_room(destination)
		room.process_mode = Node.PROCESS_MODE_INHERIT
		room.show()
		player.reparent(room.get_node("Actors"), false)
		dog.reparent(room.get_node("Actors"), false)
		terrain = room.get_node("Floor")
		var arrival: Array[Vector2i] = _arrival_cells(room, old_location)
		player.global_position = IsometricGrid.tile_to_world(arrival[0], terrain)
		dog.global_position = IsometricGrid.tile_to_world(arrival[1], terrain)
		room.state.visits += 1
	if old_location == &"outside":
		_main.get_node("World").hide()
		_main.get_node("World").process_mode = Node.PROCESS_MODE_DISABLED
	else:
		rooms[old_location].hide()
		rooms[old_location].process_mode = Node.PROCESS_MODE_DISABLED
	player.velocity = Vector2.ZERO
	dog.velocity = Vector2.ZERO
	player.configure_terrain(terrain)
	dog.configure_terrain(terrain)
	dog.reserved_access.clear()
	if destination != &"outside":
		for action: HabitatAction in rooms[destination].actions.values():
			dog.reserved_access.append(action.global_position)
	dog.set_follow_target(player)
	location = destination
	if utilities != null:
		utilities.model.occupied = destination not in [&"outside", &"crew_airlock"]
	_main.get_node("Systems/EvaSafety").suspended = location != &"outside"
	var bounds := terrain.world_rect()
	_main.camera_rig.world_bounds = bounds
	_main.management_camera.world_bounds = bounds
	_main.camera_rig.center_small_bounds = destination != &"outside"
	_main.management_camera.center_small_bounds = destination != &"outside"
	var view: Dictionary = _views.get(location, {"player_zoom": default_room_zoom,
		"management_zoom": default_room_zoom, "pan": player.global_position})
	_main.camera_rig.zoom_level = int(view.player_zoom)
	_main.management_camera.zoom_level = int(view.management_zoom)
	_main.management_camera.set_pan_position(view.pan)
	_main.camera_rig.refresh_follow()
	_refresh_airlock()
	location_changed.emit(location)


func _notice(text: String, duration: float = 5.0) -> void:
	_main.game_ui.notify(text, duration)
