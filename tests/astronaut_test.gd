extends SceneTree
## Physics-tick-counted input simulation; this is not physical-keyboard testing.

class PhysicsMeter extends Node:
	signal finished
	var ticks: int = 0
	var elapsed: float = 0.0
	func _physics_process(delta: float) -> void:
		elapsed += delta
		ticks -= 1
		if ticks <= 0:
			set_physics_process(false)
			finished.emit()

const MAIN: PackedScene = preload("res://scenes/main.tscn")
var _failures: Array[String] = []
var _checks: int = 0
var actor: Astronaut
var modes: GameplayModeCoordinator


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var original_rate: int = Engine.physics_ticks_per_second
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	actor = main.get_node("World/Entities/Players/Astronaut") as Astronaut
	modes = main.get_node("Systems/GameplayModes") as GameplayModeCoordinator
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var camera: PlayerCameraRig = main.get_node("CameraRig")
	var management: BaseManagementCameraRig = main.get_node("BaseManagementCameraRig")
	await _ticks(2)
	_check(actor is CharacterBody2D and actor.control_enabled, "Initialized controllable native actor")
	_check(not main.has_node("TemporaryPlayerTarget"), "Obsolete runtime marker retired")
	_check(actor.global_position == IsometricGrid.tile_to_world(Vector2i.ZERO, ground), "Grid-derived spawn")
	_check(actor.walkability.is_position_walkable(actor.global_position, actor.footprint_half_extent), "Full spawn footprint valid")
	_check(actor.get_parent().y_sort_enabled and actor.z_index == 0, "Actor in existing foot-based Y-sort hierarchy")
	_check(camera.follow_target == actor and camera.zoom_level == 2, "Player camera follows actual astronaut")
	_check(actor.collision_layer == 1 and actor.collision_mask == 2 and actor.motion_mode == CharacterBody2D.MOTION_MODE_FLOATING, "Top-down actor/world collision configuration")
	_check(actor.footprint_half_extent == Vector2(5, 3) and actor.get_node("CollisionShape2D").position == Vector2.ZERO, "10 x 6 footprint centered at feet")
	_check(actor.visual.foot_anchor == actor.visual.art_profile.default_anchor and not actor.visual.centered, "Explicit imported source foot anchor")
	# Retain Phase 0.5 procedural-art assertions as fallback regression tests.
	var frames: SpriteFrames = AstronautPlaceholder.frames()
	_check(frames.get_animation_names().size() == 16, "Eight idle and eight walk clips")
	for direction: StringName in AstronautDirections.NAMES:
		for state: String in ["idle", "walk"]:
			var clip: StringName = StringName(state + "_" + direction)
			_check(frames.get_frame_count(clip) == (4 if state == "walk" else 1), "Declared placeholder count: " + clip)
			_check(frames.get_animation_speed(clip) == (6.0 if state == "walk" else 1.0), "Per-clip playback rate")
			for frame: int in frames.get_frame_count(clip):
				var image: Image = frames.get_frame_texture(clip, frame).get_image()
				_check(image.get_size() == Vector2i(64, 64) and image.get_pixel(0, 0).a == 0.0, "Native transparent frame")
				var min_y: int = 64
				var max_y: int = -1
				for y: int in 64:
					for x: int in 64:
						if image.get_pixel(x, y).a > 0.0:
							min_y = mini(min_y, y)
							max_y = maxi(max_y, y)
				_check(min_y == 6 and max_y == 55, "Consistent 50px visible height and foot baseline")
	frames = actor.visual.sprite_frames
	var keys: Array[Array] = [[KEY_W], [KEY_W, KEY_D], [KEY_D], [KEY_S, KEY_D], [KEY_S], [KEY_S, KEY_A], [KEY_A], [KEY_W, KEY_A]]
	for index: int in 8:
		actor.global_position = Vector2.ZERO
		var elapsed: float = await _move(keys[index], 6)
		var expected: Vector2 = AstronautDirections.VECTORS[index].normalized() * actor.walk_speed * elapsed
		_check(actor.global_position.is_equal_approx(expected), "Physics displacement %s: actual %s expected %s" % [AstronautDirections.NAMES[index], actor.global_position, expected])
		_check(actor.facing == AstronautDirections.NAMES[index], "Eight-direction facing")
		_check(actor.visual.animation == StringName("walk_" + actor.facing), "Directional walking clip")
		_check(is_equal_approx(actor.velocity.length(), 80.0), "Normalized cardinal/diagonal speed")
		if "--capture" in OS.get_cmdline_user_args():
			actor.set_physics_process(false)
			await _capture("astronaut_walk_" + actor.facing)
			actor.set_physics_process(true)
		var facing: StringName = actor.facing
		var stopped: Vector2 = actor.global_position
		await _ticks(2)
		_check(actor.velocity == Vector2.ZERO and actor.global_position == stopped, "Release stops without drift")
		_check(actor.facing == facing and actor.visual.animation == StringName("idle_" + facing), "Idle retains facing")
		await process_frame
		await process_frame
		_check(camera.global_position.distance_to(actor.global_position) <= 0.36, "Camera follows physics position with pixel quantization")
		var screen_foot: Vector2 = actor.visual.get_canvas_transform() * (actor.visual.global_position + actor.visual.get_frame_anchor())
		_check(screen_foot.is_equal_approx(screen_foot.round()), "Rendered foot lies on logical pixels")
	actor.visual.select_state(&"walk", &"s")
	actor.visual.set_frame_and_progress(2, 0.4)
	actor.visual.select_state(&"walk", &"s")
	_check(actor.visual.frame == 2 and is_equal_approx(actor.visual.frame_progress, 0.4), "Repeated animation request does not restart")
	actor.visual.select_state(&"idle", &"s")
	var alternate: SpriteFrames = frames.duplicate() as SpriteFrames
	alternate.add_frame(&"walk_n", frames.get_frame_texture(&"walk_n", 0))
	alternate.set_animation_speed(&"walk_n", 9.0)
	actor.visual.sprite_frames = alternate
	actor.visual.select_state(&"walk", &"n")
	_check(actor.visual.sprite_frames.get_frame_count(&"walk_n") == frames.get_frame_count(&"walk_n") + 1 and actor.visual.sprite_frames.get_frame_count(&"walk_s") == frames.get_frame_count(&"walk_s"), "Replacement supports unequal directional counts")
	_check(actor.visual.sprite_frames.get_animation_speed(&"walk_n") == 9.0, "Replacement supports per-clip FPS")
	actor.visual.sprite_frames = frames
	actor.visual.select_state(&"idle", &"s")
	for rate: int in [30, 60, 120]:
		Engine.physics_ticks_per_second = rate
		await _ticks(2)
		actor.global_position = Vector2.ZERO
		var elapsed: float = await _move([KEY_D], 6)
		_check(is_equal_approx(actor.global_position.x, 80.0 * elapsed), "Physics-rate independence at %d Hz" % rate)
		await _ticks(1)
	Engine.physics_ticks_per_second = original_rate
	actor.walk_speed = 40.0
	actor.global_position = Vector2.ZERO
	var slow_time: float = await _move([KEY_RIGHT], 6)
	_check(is_equal_approx(actor.global_position.x, 40.0 * slow_time), "Configured speed and arrow input")
	await _ticks(1)
	actor.walk_speed = 80.0
	await process_frame
	actor.global_position = Vector2.ZERO
	actor.set_control_enabled(false)
	actor.set_control_enabled(true)
	Input.parse_input_event(_key(KEY_D, true))
	Input.flush_buffered_events()
	var fresh_time: float = await _ticks(3)
	Input.parse_input_event(_key(KEY_D, false))
	Input.flush_buffered_events()
	_check(is_equal_approx(actor.global_position.x, 80.0 * fresh_time), "Fresh key after neutral mode handoff responds on first physics tick")
	await _ticks(1)
	var footprint: Vector2 = actor.footprint_half_extent
	for direction: Vector2 in AstronautDirections.VECTORS:
		var constrained: Vector2 = actor.walkability.constrain_motion(Vector2.ZERO, direction.normalized() * 2000, footprint)
		_check(actor.walkability.is_position_walkable(constrained, footprint), "Complete footprint within diamond map boundary")
		_check(constrained.length() < 2000, "Long motion cannot escape test region")
		var retreat: Vector2 = actor.walkability.constrain_motion(constrained, -direction.normalized() * 5, footprint)
		_check(retreat.length() > 0.1, "Can retreat from an edge without sticking")
	# Sparse walkability is read live; no terrain renderer rebuild or persistent write.
	var saved: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	ground.terrain_cells.erase(Vector2i(1, 0))
	_check(not actor.walkability.is_position_walkable(Vector2(0, 16), footprint), "Missing tile tip blocks full rectangle even if center is elsewhere")
	var across_hole: Vector2 = actor.walkability.constrain_motion(Vector2.ZERO, Vector2(64, 32), footprint)
	_check(across_hole != Vector2(64, 32), "Swept check prevents tunneling across a missing cell")
	_check(actor.walkability.is_position_walkable(across_hole, footprint), "Hole-constrained footprint remains valid")
	_check(actor.walkability.constrain_motion(Vector2.ZERO, across_hole, footprint).is_equal_approx(across_hole), "Final straight physics displacement cannot cut across a hole")
	ground.terrain_cells.clear()
	for y: int in range(10, 14):
		for x: int in range(-15, -10):
			ground.terrain_cells[Vector2i(x, y)] = TerrainRegion.Kind.REGOLITH
	_check(actor.walkability.is_position_walkable(IsometricGrid.tile_to_world(Vector2i(-13, 12), ground), footprint), "Different map shape/origin supported")
	_check(not actor.walkability.is_position_walkable(Vector2.ZERO, footprint), "No hardcoded old map limits")
	ground.terrain_cells = saved
	actor.global_position = Vector2.ZERO
	await _move([KEY_D], 3)
	await _ticks(1)
	Input.parse_input_event(_key(KEY_D, true))
	await _ticks(2)
	await _tab()
	var management_position: Vector2 = actor.global_position
	_check(modes.is_management_mode() and actor.velocity == Vector2.ZERO and actor.visual.state == &"idle", "Mode transition immediately stops player and idles")
	var before_pan: Vector2 = management.pan_position
	await _ticks(4)
	await process_frame
	await process_frame
	_check(actor.global_position == management_position, "Held movement key cannot move astronaut in management")
	_check(management.pan_position.x > before_pan.x, "Held key routes to management pan")
	await _tab()
	await _ticks(4)
	_check(actor.global_position == management_position and actor.velocity == Vector2.ZERO, "Held key requires neutral before player reentry")
	Input.parse_input_event(_key(KEY_D, false))
	await _ticks(2)
	var resume_time: float = await _move([KEY_D], 3)
	_check(is_equal_approx(actor.global_position.x - management_position.x, 80.0 * resume_time), "Fresh input after release restores control")
	await _ticks(1)
	var edit: LineEdit = LineEdit.new()
	main.get_node("UI").add_child(edit)
	edit.grab_focus()
	var ui_position: Vector2 = actor.global_position
	await _move([KEY_A], 3)
	_check(actor.global_position == ui_position and actor.velocity == Vector2.ZERO, "Focused UI blocks astronaut movement")
	edit.release_focus()
	edit.queue_free()
	await _ticks(2)
	# Real physics movement to a map edge, rather than only testing the geometry helper.
	actor.global_position = Vector2(330, 0)
	_check(actor.walkability.is_position_walkable(actor.global_position, footprint), "Near-edge test start valid")
	await _move([KEY_D], 30)
	await _ticks(1)
	_check(actor.walkability.is_position_walkable(actor.global_position, footprint) and actor.global_position.x < 384, "Physical movement stops before full footprint leaves map")
	_check(actor.velocity == Vector2.ZERO and actor.visual.state == &"idle", "Edge stop selects idle")
	actor.global_position = Vector2.ZERO
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("astronaut_idle")
		await _tab()
		await _capture("astronaut_management")
		await _tab()
	_check(ground.terrain_cells == saved and ground.get_used_cells().size() == ground.region.size.x * ground.region.size.y, "Tests preserve terrain data/rendering")
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d astronaut checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _ticks(count: int) -> float:
	var meter: PhysicsMeter = PhysicsMeter.new()
	meter.process_priority = 50
	meter.process_physics_priority = 50
	meter.ticks = count
	root.add_child(meter)
	await meter.finished
	var elapsed: float = meter.elapsed
	meter.queue_free()
	return elapsed


func _move(keys: Array, count: int) -> float:
	# Begin outside a physics callback so a newly added meter cannot count a partial tick.
	await process_frame
	for code: Key in keys:
		Input.parse_input_event(_key(code, true))
	Input.flush_buffered_events()
	var elapsed: float = await _ticks(count)
	for code: Key in keys:
		Input.parse_input_event(_key(code, false))
	Input.flush_buffered_events()
	return elapsed


func _key(code: Key, pressed: bool) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	return event


func _tab() -> void:
	Input.parse_input_event(_key(KEY_TAB, true))
	Input.flush_buffered_events()
	await process_frame
	Input.parse_input_event(_key(KEY_TAB, false))
	Input.flush_buffered_events()
	await process_frame


func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png("res://tests/output/" + filename + ".png") == OK, "Capture " + filename)


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
