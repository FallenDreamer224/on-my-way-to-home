extends SceneTree

class Meter extends Node:
	signal finished
	var remaining: int = 0
	var elapsed: float = 0.0
	var observe: Callable
	func _physics_process(delta: float) -> void:
		if observe.is_valid():
			observe.call()
		elapsed += delta
		remaining -= 1
		if remaining <= 0:
			set_physics_process(false)
			finished.emit()

const MAIN: PackedScene = preload("res://scenes/main.tscn")
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	var dog: Chiwis = main.get_node("World/Entities/NPCs/Chiwis")
	var astronaut: Astronaut = main.get_node("World/Entities/Players/Astronaut")
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var modes: GameplayModeCoordinator = main.get_node("Systems/GameplayModes")
	var management: BaseManagementCameraRig = main.get_node("BaseManagementCameraRig")
	await _ticks(2)
	_check(dog.follow_target == astronaut and dog.follow_enabled, "Main wires companion and mode")
	_check(ground.get_used_cells().size() == ground.region.size.x * ground.region.size.y and dog.planner.walkability.is_position_walkable(dog.global_position, dog.footprint_half_extent), "Valid spawn in original lunar terrain")
	_check(dog.state == Chiwis.State.IDLE and dog.velocity == Vector2.ZERO, "Stable close idle")
	_check(dog.footprint_half_extent == Vector2(4, 2) and dog.collision_layer == 1 and dog.collision_mask == 2, "Smaller nonpushing ground collision")
	_check(dog.scale == Vector2.ONE and dog.visual.scale == Vector2.ONE, "Native artwork scale")
	_check(dog.visual.art_profile != null and dog.visual.sprite_frames.get_animation_names().size() == 24, "Real Chiwis idle/walk/run SpriteFrames loaded")
	for facing: StringName in AstronautDirections.NAMES:
		dog.visual.select_state(&"walk", facing)
		_check(dog.visual.animation == StringName("walk_" + facing), "Directional Chiwis walking animation")
	dog.visual.select_state(&"idle", &"s")
	# Isolated stationary target; astronaut remains the player camera's target.
	var target: Node2D = Node2D.new()
	root.add_child(target)
	target.position = Vector2(100, 0)
	dog.global_position = Vector2.ZERO
	dog.set_follow_target(target)
	await _ticks(1)
	_check(dog.state == Chiwis.State.FOLLOWING and dog.velocity.length() > 0, "Follow activation")
	await _ticks(90)
	var distance: float = dog.global_position.distance_to(target.global_position)
	_check(absf(distance - dog.preferred_distance) < 0.1 and dog.state == Chiwis.State.IDLE, "Stops at preferred distance")
	var stopped: Vector2 = dog.global_position
	await _ticks(20)
	_check(dog.global_position == stopped and dog.velocity == Vector2.ZERO, "No idle threshold jitter")
	target.position += Vector2(10, 0)
	await _ticks(2)
	_check(dog.global_position == stopped, "Hysteresis ignores intermediate distance")
	target.position += Vector2(15, 0)
	await _ticks(1)
	_check(dog.state == Chiwis.State.FOLLOWING, "Resumes beyond activation threshold")
	var original_rate: int = Engine.physics_ticks_per_second
	for rate: int in [30, 60, 120]:
		Engine.physics_ticks_per_second = rate
		await _ticks(2)
		var duration: float = await _ticks(6, func() -> void:
			dog.global_position = Vector2.ZERO
			target.position = Vector2(150, 0)
			dog.set_follow_target(target))
		_check(is_equal_approx(dog.global_position.x, dog.movement_speed * duration), "Physics-rate independent follow at %d Hz" % rate)
	Engine.physics_ticks_per_second = original_rate
	# Pause/resume uses the existing coordinator and never resets positions.
	dog.set_follow_target(astronaut)
	dog.global_position = Vector2(-120, 0)
	await _ticks(2)
	modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
	var paused_position: Vector2 = dog.global_position
	var astronaut_position: Vector2 = astronaut.global_position
	await _ticks(10)
	_check(dog.global_position == paused_position and dog.velocity == Vector2.ZERO and dog.visual.state == &"idle", "Management pauses autonomous motion")
	var before_pan: Vector2 = management.pan_position
	modes.route_pan(Vector2.RIGHT, 0.1)
	_check(management.pan_position != before_pan and dog.global_position == paused_position and astronaut.global_position == astronaut_position, "Pan independent of both characters")
	modes.request_mode(GameplayModeCoordinator.Mode.PLAYER)
	await _ticks(2)
	_check(dog.global_position != paused_position and dog.follow_enabled, "Player return resumes following")
	_check(main.get_node("World/Entities/NPCs").get_child_count() == 1, "No companion duplication")
	# Missing/queued/freed targets never dereference stale Object handles.
	dog.set_follow_target(target)
	target.queue_free()
	await _ticks(2)
	_check(dog.state == Chiwis.State.WAITING and dog.velocity == Vector2.ZERO, "Freed target waits safely")
	dog.set_follow_target(null)
	await _ticks(1)
	_check(dog.state == Chiwis.State.WAITING, "Missing target safe")
	dog.set_follow_enabled(false)
	# Work on an isolated logical terrain fixture, then restore it. No generated PNG changes.
	var saved: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	ground.terrain_cells.clear()
	for x: int in range(-3, 4):
		for y: int in range(-3, 4):
			if not (x == 0 and y < 2):
				ground.terrain_cells[Vector2i(x, y)] = TerrainRegion.Kind.REGOLITH
	var start: Vector2 = IsometricGrid.tile_to_world(Vector2i(-2, 0), ground)
	var goal: Vector2 = IsometricGrid.tile_to_world(Vector2i(2, 0), ground)
	var path: PackedVector2Array = dog.planner.route(start, goal)
	_check(path.size() > 2, "Routes around a sparse barrier")
	var cursor: Vector2 = start
	for waypoint: Vector2 in path:
		_check(dog.planner.clear_segment(cursor, waypoint), "Every route segment safe for full foot rectangle")
		cursor = waypoint
	var route_target: Node2D = Node2D.new()
	root.add_child(route_target)
	route_target.global_position = goal
	dog.global_position = start
	dog.set_follow_target(route_target)
	dog.set_follow_enabled(true)
	var route_safety: Array[bool] = [true]
	await _ticks(360, Callable(), func() -> void:
		route_safety[0] = route_safety[0] and dog.planner.walkability.is_position_walkable(dog.global_position, dog.footprint_half_extent))
	_check(route_safety[0], "Actual routed movement keeps the full collision footprint on terrain")
	_check(dog.global_position.distance_to(goal) <= dog.preferred_distance + 0.1 and dog.state == Chiwis.State.IDLE, "Companion traverses sparse barrier and settles by target")
	dog.set_follow_enabled(false)
	route_target.queue_free()
	ground.terrain_cells.clear()
	ground.terrain_cells[Vector2i.ZERO] = 0
	ground.terrain_cells[Vector2i(1, 1)] = 0
	_check(dog.planner.route(Vector2.ZERO, IsometricGrid.tile_to_world(Vector2i(1, 1), ground)).is_empty(), "Cannot cross an unsafe diagonal corner gap")
	var waiting_target: Node2D = Node2D.new()
	root.add_child(waiting_target)
	waiting_target.position = IsometricGrid.tile_to_world(Vector2i(1, 1), ground)
	dog.global_position = Vector2.ZERO
	dog.preferred_distance = 5
	dog.activation_distance = 10
	dog.set_follow_target(waiting_target)
	dog.set_follow_enabled(true)
	await _ticks(30)
	_check(dog.global_position == Vector2.ZERO and dog.state == Chiwis.State.WAITING, "Unreachable target waits without teleport/collision jitter")
	ground.terrain_cells = saved
	dog.preferred_distance = 36
	dog.activation_distance = 56
	waiting_target.position = Vector2(200, 0)
	dog.set_follow_target(waiting_target)
	await _ticks(200)
	_check(dog.planner.walkability.is_position_walkable(dog.global_position, dog.footprint_half_extent), "Following remains on valid terrain")
	# Capture original real actors after restoring normal wiring.
	dog.set_follow_enabled(false)
	astronaut.global_position = Vector2.ZERO
	dog.global_position = IsometricGrid.tile_to_world(Vector2i(0, 1), ground)
	dog.set_follow_target(astronaut)
	dog.set_follow_enabled(true)
	waiting_target.queue_free()
	if "--capture" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		_check(root.get_texture().get_image().save_png("res://tests/output/astronaut_chiwis.png") == OK, "Capture real astronaut and Chiwis")
		modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT)
		await RenderingServer.frame_post_draw
		_check(root.get_texture().get_image().save_png("res://tests/output/chiwis_management.png") == OK, "Capture companion in management")
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d Chiwis checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _ticks(count: int, setup: Callable = Callable(), observe: Callable = Callable()) -> float:
	# Always start the meter outside an in-progress physics callback.
	await process_frame
	if setup.is_valid():
		setup.call()
	var meter: Meter = Meter.new()
	meter.observe = observe
	meter.process_physics_priority = 50
	meter.remaining = count
	root.add_child(meter)
	await meter.finished
	var duration: float = meter.elapsed
	meter.queue_free()
	return duration


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
