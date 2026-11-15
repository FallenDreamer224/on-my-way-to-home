extends SceneTree
## Native asset/room contracts, real actors, closed thresholds and existing service bindings.

var checks: int = 0
var failures: PackedStringArray = []
var preview: Node
var main: Node
var capture: bool = false
var capture_path: String = "res://tests/output/phase_0_8g2/captures/"

func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message)

func settle() -> void:
	await physics_frame
	await process_frame

func screenshot(name: String, with_ui: bool = false) -> void:
	if not capture: return
	if not with_ui: main.game_ui.hide()
	preview.caption.visible = not with_ui
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	check(image.get_size() == Vector2i(960, 540), "Native capture resolution " + name)
	check(image.save_png(capture_path + name + ".png") == OK, "Capture saved " + name)
	main.game_ui.show()
	preview.caption.hide()

func release_movement() -> void:
	for action: StringName in Astronaut.MOVEMENT_ACTIONS: Input.action_release(action)

func walk_to(goal: Vector2) -> void:
	var actor: Astronaut = main.astronaut
	var planner := TerrainRoutePlanner.new(preview.director.active_terrain(), actor.footprint_half_extent)
	var route := planner.route(actor.global_position, goal)
	check(not route.is_empty(), "Existing actor planner reaches goal")
	for waypoint: Vector2 in route:
		var frames: int = 0
		while actor.global_position.distance_to(waypoint) > 2 and frames < 360:
			var direction := actor.global_position.direction_to(waypoint)
			Input.action_press(&"player_move_right", maxf(direction.x, 0))
			Input.action_press(&"player_move_left", maxf(-direction.x, 0))
			Input.action_press(&"player_move_down", maxf(direction.y, 0))
			Input.action_press(&"player_move_up", maxf(-direction.y, 0))
			await physics_frame
			frames += 1
		check(actor.global_position.distance_to(waypoint) <= 3, "Real Astronaut input reaches waypoint")
		release_movement()
	await physics_frame

func run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless"
	if capture: DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(capture_path))
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/imports/interior_library.json"))
	for record: Dictionary in catalog.assets:
		var spec: InteriorPropDefinition = load("res://" + String(record.resource_path))
		check(spec != null and spec.validation_errors().is_empty(), "Valid prop metadata " + String(record.asset_id))
		var scene: Node2D = (load("res://" + String(record.scene_path)) as PackedScene).instantiate()
		var sprite: Sprite2D = scene.get_node("Sprite2D")
		check(scene.get_script() == null and sprite.scale == Vector2.ONE and scene.scale == Vector2.ONE and sprite.rotation == 0, "Static native prefab " + String(record.asset_id))
		check(not sprite.centered and sprite.offset == -Vector2(spec.ground_anchor), "Exact measured pivot")
		check(scene.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Nearest filter")
		var raw := Image.new()
		raw.load_png_from_buffer(FileAccess.get_file_as_bytes("res://" + String(record.runtime_files[0])))
		raw.convert(Image.FORMAT_RGBA8)
		var imported := spec.texture.get_image()
		imported.convert(Image.FORMAT_RGBA8)
		check(raw.get_data() == imported.get_data() and not imported.has_mipmaps(), "Exact native imported pixels " + String(record.asset_id))
		if not record.reused:
			check(FileAccess.get_sha256("res://" + String(record.source_files[0])) == FileAccess.get_sha256("res://" + String(record.runtime_files[0])), "Source/runtime bytes equal")
		scene.free()
	var room_catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/interiors/room_library.json"))
	for entry: Dictionary in room_catalog.rooms:
		var standalone: InteriorArtRoom = (load("res://" + String(entry.scene_path)) as PackedScene).instantiate()
		root.add_child(standalone)
		await settle()
		check(standalone.definition.id == entry.id and standalone.state != null and standalone.props.size() == entry.props.size(), "Room scene works standalone from embedded native data")
		for portal: Dictionary in entry.portals:
			if portal.pressure_boundary: check(standalone.door_views[StringName(portal.id)].closed, "Unbound pressure boundary defaults sealed")
		standalone.queue_free()
		await settle()
	for name: String in ["wall", "corner", "window", "service", "support", "door", "cable_straight", "cable_corner", "cable_vertical", "floor_0", "floor_1", "floor_2"]:
		var module: Node2D = (load("res://scenes/interiors/modules/" + name + ".tscn") as PackedScene).instantiate()
		check(module.scale == Vector2.ONE and module.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Native construction module " + name)
		module.free()
	preview = load("res://scenes/development/lunar_interior_preview.tscn").instantiate()
	root.add_child(preview)
	await settle()
	main = preview.main
	var director: HabitatDirector = preview.director
	var actor: Astronaut = main.astronaut
	var dog: Chiwis = main.chiwis
	var actor_id: int = actor.get_instance_id()
	var dog_id: int = dog.get_instance_id()
	var inventory: RuntimeInventory = actor.get_node("Inventory")
	var inventory_id: int = inventory.get_instance_id()
	inventory.add_items(&"lunar_sample", 3)
	check(director.rooms.size() == 9, "Nine shared-function room scenes")
	for entry: Dictionary in preview.library.rooms:
		check(preview.select_room(StringName(entry.id)), "Select isolated room " + String(entry.id))
		await settle()
		var room: InteriorArtRoom = director.rooms[StringName(entry.id)]
		var floor_layer: TerrainLayer = room.get_node("Floor")
		check(floor_layer.tile_set.tile_size == Vector2i(64, 32) and floor_layer.position == Vector2(-32, -16), "Native grid alignment")
		check(room.region.size == HabitatRoom.cell(entry.original_size_cells), "Original room dimensions preserved")
		check(room.get_node("Actors").y_sort_enabled and actor.get_parent() == room.get_node("Actors") and dog.get_parent() == actor.get_parent(), "Shared actor/scenery Y sort")
		var start: Vector2 = IsometricGrid.tile_to_world(HabitatRoom.cell(entry.layout.spawn), floor_layer)
		actor.global_position = start
		dog.global_position = IsometricGrid.tile_to_world(HabitatRoom.cell(entry.layout.companion_spawn), floor_layer)
		var actor_planner := TerrainRoutePlanner.new(floor_layer, actor.footprint_half_extent)
		var dog_planner := TerrainRoutePlanner.new(floor_layer, dog.footprint_half_extent)
		for action: HabitatAction in room.actions.values():
			check(not actor_planner.route(start, action.global_position).is_empty(), "Actor can reach action " + String(entry.id) + "/" + String(action.action_id))
			check(not dog_planner.route(dog.global_position, action.global_position).is_empty(), "Chiwis can reach action " + String(entry.id) + "/" + String(action.action_id))
		for prop: Dictionary in entry.props:
			var origin := HabitatRoom.cell(prop.cell)
			var size := HabitatRoom.cell(prop.footprint)
			for y: int in size.y:
				for x: int in size.x:
					var at := origin + Vector2i(x, y)
					check(not floor_layer.is_cell_walkable(at), "Furniture occupies navigation cell")
					var query := PhysicsPointQueryParameters2D.new()
					query.position = IsometricGrid.tile_to_world(at, floor_layer)
					query.collision_mask = 2
					check(not root.world_2d.direct_space_state.intersect_point(query).is_empty(), "Furniture has real ground collision")
		var target: HabitatAction = room.actions.values()[0]
		await walk_to(target.global_position)
		for i: int in 60: await physics_frame
		check(dog.planner.walkability.is_position_walkable(dog.global_position, dog.footprint_half_extent), "Companion stays on safe room floor")
		check(dog.global_position.distance_to(actor.global_position) < 100, "Existing Chiwis follows in room")
		actor.set_physics_process(false)
		dog.set_physics_process(false)
		preview.refresh_caption()
		await screenshot(String(entry.id))
		var categories: Dictionary = {"crew_airlock":["airlock"], "hub":["habitation", "mission_control"], "living":["sleeping", "food_preparation", "hygiene"], "engineering":["life_support", "power_control"], "health_lab":["medical", "research_laboratory", "navigation"], "cargo":["storage_workshop"], "shelter":["emergency_shelter"]}
		for category: String in categories.get(String(entry.id), []):
			preview.refresh_caption(category + " / " + String(entry.title))
			await screenshot(category)
		for portal: Dictionary in entry.portals:
			var id := StringName(portal.id)
			var threshold := HabitatRoom.cell(portal.threshold)
			room.set_door_closed(id, true)
			await settle()
			check(not floor_layer.is_cell_walkable(threshold), "Closed door blocks shared navigation")
			check(actor_planner.route(start, IsometricGrid.tile_to_world(threshold, floor_layer)).is_empty() and dog_planner.route(start, IsometricGrid.tile_to_world(threshold, floor_layer)).is_empty(), "Both full-foot planners respect closed door")
			room.set_door_closed(id, false)
			await settle()
			check(floor_layer.is_cell_walkable(threshold), "Open threshold restored")
		actor.set_physics_process(true)
		dog.set_physics_process(true)
		check(actor.get_instance_id() == actor_id and dog.get_instance_id() == dog_id and inventory.get_instance_id() == inventory_id and inventory.get_quantity(&"lunar_sample") == 3, "Persistent unique actors and inventory across rooms")
	await greenhouse(director)
	await bindings(director)
	preview.select_room(&"living")
	await settle()
	var room: InteriorArtRoom = director.rooms[&"living"]
	actor.set_physics_process(false)
	dog.set_physics_process(false)
	actor.global_position = room.actions[&"hub"].global_position
	dog.global_position = actor.global_position + Vector2(0, 32)
	director.cycle_seconds = 0.01
	check(director.request_action(room.actions[&"hub"]), "Existing director accepts actual room portal")
	await settle()
	var waited: int = 0
	while director.busy and waited < 90:
		await physics_frame
		waited += 1
	check(director.location == &"hub" and not director.busy, "Existing room transition reaches prepared destination")
	await screenshot("doorway_transition")
	check(str(ProjectSettings.get_setting("application/run/main_scene")).contains("app_root"), "Normal startup unchanged")
	release_movement()
	preview.queue_free()
	await settle()
	if failures.is_empty(): print("PASS: %d lunar interior asset/navigation/service checks" % checks)
	else:
		for failure: String in failures: printerr("FAIL: " + failure)
	quit(0 if failures.is_empty() else 1)

func greenhouse(director: HabitatDirector) -> void:
	preview.select_room(&"greenhouse")
	await settle()
	main.astronaut.set_physics_process(false)
	main.chiwis.set_physics_process(false)
	var room: InteriorArtRoom = director.rooms[&"greenhouse"]
	var daily: DailyLife = preview.daily
	var service: UtilityService = main.get_node("Systems/Utilities")
	service.set_physics_process(false)
	check(room.crop_views.size() == 2, "Both existing trays have live read-only views")
	var snapshot := daily.capture_state()
	for view: InteriorCropView in room.crop_views: view.refresh()
	check(daily.capture_state() == snapshot, "View refresh does not mutate crop state")
	preview.refresh_caption("Greenhouse / empty / actual tray state")
	await screenshot("greenhouse_empty")
	daily.act("resupply")
	check(daily.plant(0) and daily.plant(1), "Actual finite inventory seeds plant both trays")
	preview.refresh_caption("Greenhouse / seeded / actual tray state")
	await screenshot("greenhouse_seeded")
	check(room.crop_views[0].stage == &"seeded", "Seeded visual reads actual state")
	daily.set_growth_multiplier(100)
	for pair: Array in [[1, "germinating"], [3, "small"], [6, "intermediate"], [9, "mature"]]:
		service.advance(float(pair[0]))
		# UtilityService bounds catch-up to eight steps per call.
		service.advance(0)
		check(room.crop_views[0].stage == StringName(pair[1]), "Crop visual progress " + String(pair[1]))
		preview.refresh_caption("Greenhouse / " + String(pair[1]) + " / " + String(daily.trays[0].status))
		await screenshot("greenhouse_" + String(pair[1]))
	check(daily.trays[0].remaining_yield == 2, "Real resource-backed harvest readiness")
	check(daily.water_used_kg >= 0.4 - 1e-7 and daily.nutrient_used >= 2 - 1e-7, "Full tray cycle water/nutrient costs retained")
	check(daily.harvest(0) and room.crop_views[0].stage == &"empty", "Actual harvest clears visual without duplicate yield")
	preview.refresh_caption("Greenhouse / existing crop service")
	await screenshot("greenhouse")
	check(daily.plant(0), "Replant uses another actual seed")
	var progress_before: float = daily.trays[0].growth_s
	service.model.equipment_command("distribution", "fault")
	service.advance(1)
	check(daily.trays[0].growth_s == progress_before and room.crop_views[0].stage == &"seeded" and not room.crop_views[0].light_powered, "Power failure pauses real tray without fake crop death")
	service.model.equipment_command("distribution", "maintain")
	service.model.equipment_command("distribution", "complete")
	var inventory: RuntimeInventory = main.astronaut.get_node("Inventory")
	inventory.add_items(&"fresh_greens", inventory.available_quantity_capacity(&"fresh_greens"))
	check(not daily.harvest(1) and daily.trays[1].remaining_yield == 2 and room.crop_views[1].stage == &"mature", "Full inventory preserves mature visual and exact crop remainder")
	inventory.remove_items(&"fresh_greens", 1)
	check(daily.harvest(1) and daily.trays[1].remaining_yield == 1 and room.crop_views[1].stage == &"mature", "Partial harvest keeps remaining crop visible")
	for residual: float in service.model.conservation_errors().values(): check(absf(residual) < 0.1, "Views preserve existing resource conservation")

func use_action(director: HabitatDirector, id: StringName) -> void:
	var room: InteriorArtRoom = director.rooms[director.location]
	var action: HabitatAction = room.actions[id]
	main.astronaut.set_physics_process(false)
	main.chiwis.set_physics_process(false)
	main.astronaut.global_position = action.global_position
	var floor_layer: TerrainLayer = director.active_terrain()
	var at := IsometricGrid.world_to_tile(action.global_position, floor_layer)
	for neighbor: Vector2i in IsometricGrid.neighbors(at):
		var point := IsometricGrid.tile_to_world(neighbor, floor_layer)
		if main.chiwis.planner.walkability.is_position_walkable(point, main.chiwis.footprint_half_extent):
			main.chiwis.global_position = point
			break
	await settle()
	check(director.request_action(action), "Existing interaction accepts prepared station " + String(id))
	var frames: int = 0
	while director.busy and frames < 120:
		await physics_frame
		frames += 1
	check(not director.busy and not main.player_session.transition_blocked, "Prepared-room interaction transaction finishes")
	check(not (director.airlock.inner_open and director.airlock.outer_open), "Prepared doors never bypass shared airlock interlock")

func bindings(director: HabitatDirector) -> void:
	preview.select_room(&"crew_airlock")
	await settle()
	director.cycle_seconds = 0.02
	director.airlock_changed.emit()
	var room: InteriorArtRoom = director.rooms[&"crew_airlock"]
	check(room.door_views[&"outer"].closed and room.door_views[&"inner"].closed, "Both visual leaves read actual sealed hatches")
	await use_action(director, &"inner")
	check(director.location == &"crew_airlock" and room.door_views[&"inner"].closed, "Vacuum chamber cannot enter pressure habitat")
	await use_action(director, &"inspection")
	await use_action(director, &"cycle")
	check(director.airlock.pressure == HabitatAirlock.Pressure.PRESSURIZED, "Existing inspection/cycle controls actual chamber state")
	await use_action(director, &"inner")
	check(director.location == &"equipment_lock", "Existing interlocked transition enters prepared equipment lock")
	await screenshot("wall_occlusion")
	preview.select_room(&"living")
	await settle()
	await use_action(director, &"galley")
	check(director.daily_panel.visible and main.gameplay_modes.modal_input_blocked, "Prepared galley opens original modal")
	check(not preview.select_room(&"hub"), "Gallery selection respects original modal gate")
	await screenshot("existing_galley_ui", true)
	director.daily_panel.close_panel()
	preview.select_room(&"engineering")
	await settle()
	await use_action(director, &"power")
	check(director.utility_panel.visible and main.gameplay_modes.modal_input_blocked, "Prepared engineering opens existing utility inspector")
	await screenshot("existing_utility_ui", true)
	director.utility_panel.close_panel()
