extends SceneTree
## Full-map topology, foot sweeps and production integration acceptance.

var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)


func _run() -> void:
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var region := ground.region as LunarTutorialRegion
	var actor: Astronaut = main.astronaut
	var dog: Chiwis = main.chiwis
	check(region.size == Vector2i(40, 40) and ground.get_used_cells().size() == 1600, "40x40 production grid")
	check(region.validation_errors().is_empty(), "Valid configuration")
	check(ground.terrain_cells == region.create_cells(), "Reproducible generation")
	check(ground.world_rect() == Rect2(-1280, -656, 2560, 1280), "Measured world bounds")
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	var seen: Dictionary[Vector2i, bool] = {Vector2i.ZERO: true}
	var cursor: int = 0
	while cursor < queue.size():
		var cell: Vector2i = queue[cursor]
		cursor += 1
		for step: Vector2i in IsometricGrid.CARDINAL_STEPS:
			var next := cell + step
			if not seen.has(next) and ground.is_cell_walkable(next):
				seen[next] = true
				queue.append(next)
	var walkable: int = 0
	var blocked: int = 0
	var counts: Dictionary[int, int] = {}
	for cell: Vector2i in ground.terrain_cells:
		var kind: int = ground.terrain_cells[cell]
		counts[kind] = counts.get(kind, 0) + 1
		var data := region.surface_at(cell, kind)
		check(data.walkable == ground.is_cell_walkable(cell), "Metadata/walkability agreement")
		check(data.occupant_id.is_empty(), "No invented installed footprints")
		check(ground.get_cell_source_id(cell) == kind, "Native source matches logical kind")
		if data.walkable:
			walkable += 1
			check(seen.has(cell), "Every safe cell connected to spawn")
			var point := IsometricGrid.tile_to_world(cell, ground)
			check(actor.walkability.is_position_walkable(point, actor.footprint_half_extent), "Astronaut full foot at cell center")
			check(dog.planner.walkability.is_position_walkable(point, dog.footprint_half_extent), "Chiwis full foot at cell center")
		else:
			blocked += 1
			check(not actor.walkability.is_position_walkable(IsometricGrid.tile_to_world(cell, ground), actor.footprint_half_extent), "Restricted cell really blocks actor")
	for id: StringName in region.zones:
		var rect: Rect2i = region.zones[id]
		var target: Vector2i = rect.position + rect.size / 2
		var point := IsometricGrid.tile_to_world(target, ground)
		var route := dog.planner.route(dog.global_position, point)
		check(not route.is_empty(), "Chiwis route to " + id)
		var previous := dog.global_position
		for waypoint: Vector2 in route:
			check(dog.planner.clear_segment(previous, waypoint), "Chiwis swept segment to " + id)
			check(actor.walkability.constrain_motion(previous, waypoint - previous, actor.footprint_half_extent).is_equal_approx(waypoint - previous), "Astronaut swept route to " + id)
			previous = waypoint
	check(blocked > 156 and walkable == seen.size(), "Restricted perimeter and crater cores; no disconnected safe cells")
	for center: Vector2i in region.crater_centers:
		check(not ground.is_cell_walkable(center), "Crater center is excluded from safe routes")
	var detour_start := IsometricGrid.tile_to_world(Vector2i(10, -4), ground)
	var detour_goal := IsometricGrid.tile_to_world(Vector2i(18, -4), ground)
	check(not dog.planner.clear_segment(detour_start, detour_goal), "Crater blocks straight traversal")
	var detour := dog.planner.route(detour_start, detour_goal)
	check(detour.size() > 1, "Chiwis finds a real crater detour within its existing node budget")
	var last_point := detour_start
	for waypoint: Vector2 in detour:
		check(dog.planner.clear_segment(last_point, waypoint), "Detour respects full-foot collision")
		last_point = waypoint
	check(main.camera_rig.bounds_enabled and main.management_camera.bounds_enabled, "Both cameras bounded")
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
	main.management_camera.set_pan_position(Vector2(100000, -100000))
	check(ground.world_rect().has_point(main.management_camera.global_position), "Management cannot pan beyond region bounds")
	main.management_camera.set_pan_position(Vector2.ZERO)
	if "--capture" in OS.get_cmdline_user_args():
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tests/output/lunar_tutorial_management.png")
		var view := SubViewport.new()
		view.size = Vector2i(ground.world_rect().size)
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var terrain_node := Node2D.new()
		terrain_node.name = "Terrain"
		view.add_child(terrain_node)
		var overview: TerrainLayer = load("res://scenes/world/terrain_layer.tscn").instantiate()
		overview.region = region
		terrain_node.add_child(overview)
		var annotations := Node2D.new()
		annotations.set_script(load("res://scripts/world/lunar_site_layout.gd"))
		view.add_child(annotations)
		var camera := Camera2D.new()
		camera.position = ground.world_rect().get_center()
		view.add_child(camera)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		view.get_texture().get_image().save_png("res://tests/output/lunar_tutorial_full_region.png")
		view.queue_free()
	main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.PLAYER)
	check(main.camera_rig.is_active(), "Return to Player Mode")
	var summary := {"cells": 1600, "walkable": walkable, "blocked": blocked, "kind_counts": counts, "zones": region.zones.size(), "bounds": str(ground.world_rect()), "checks": checks}
	var file := FileAccess.open("res://tests/output/lunar_tutorial_summary.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(summary, "  "))
	file.close()
	print("Lunar tutorial: " + JSON.stringify(summary))
	main.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: " + failure)
	if failures.is_empty():
		print("PASS: %d lunar tutorial checks" % checks)
	quit(0 if failures.is_empty() else 1)
