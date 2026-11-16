extends SceneTree
## Real Input.parse_input_event dispatch plus deterministic controller math.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
var _checks: int = 0
var _failures: Array[String] = []
var _notifications: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	var modes: GameplayModeCoordinator = main.get_node("Systems/GameplayModes")
	var player: PlayerCameraRig = main.get_node("CameraRig")
	var management: BaseManagementCameraRig = main.get_node("BaseManagementCameraRig")
	var target: Node2D = main.get_node("World/Entities/Players/Astronaut")
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var world: Node2D = main.get_node("World")
	var footer: Label = main.game_ui.hud.mode_label
	var camera_hint: Label = main.game_ui.hud.controls_hint
	var world_id: int = world.get_instance_id()
	var ground_id: int = ground.get_instance_id()
	var terrain: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	_check(modes.is_player_mode() and modes.current_mode == GameplayModeCoordinator.Mode.PLAYER, "Default PLAYER mode")
	_check(player.is_active() and not management.camera.enabled, "Only player initially active")
	_check(player.zoom_level == 2 and management.zoom_level == 1, "Independent default zooms")
	_check(footer.text.begins_with("PLAYER MODE"), "Initial indicator")
	modes.mode_changed.connect(_on_mode_changed)
	_check(not modes.request_mode(99) and not modes.request_mode(-1), "Invalid transitions rejected")
	_check(not modes.request_mode(GameplayModeCoordinator.Mode.PLAYER), "Duplicate transition rejected")
	_check(not modes.initialize(player, management), "Duplicate initialization rejected")
	var before: Vector2 = management.pan_position
	modes.route_pan(Vector2.RIGHT, 1.0)
	_check(management.pan_position == before, "Pan gated in player mode")
	await _wheel(MOUSE_BUTTON_WHEEL_UP)
	_check(management.zoom_level == 1 and player.zoom_level == 2, "Wheel ignored in player mode")
	target.position = Vector2(32, -16)
	await process_frame
	await process_frame
	await _tab()
	_check(modes.is_management_mode() and management.is_active() and not player.camera.enabled, "Real Tab enters management")
	_check(management.pan_position == target.global_position, "First entry centers on target")
	_check(management.camera.get_screen_center_position().is_equal_approx(target.global_position), "Incoming native viewport center correct")
	_check(footer.text.begins_with("BASE MANAGEMENT MODE"), "Immediate mode indicator")
	_check(_notifications == 1, "Single notification for a press")
	var echo_event: InputEventKey = _key(KEY_TAB, true)
	echo_event.echo = true
	Input.parse_input_event(echo_event)
	await process_frame
	_check(_notifications == 1 and modes.is_management_mode(), "Tab auto-repeat ignored")
	Input.parse_input_event(_key(KEY_TAB, false))
	management.set_pan_position(Vector2.ZERO)
	for step: int in 60:
		modes.route_pan(Vector2.RIGHT, 1.0 / 60.0)
	var at_60: Vector2 = management.pan_position
	management.set_pan_position(Vector2.ZERO)
	for step: int in 30:
		modes.route_pan(Vector2.RIGHT, 1.0 / 30.0)
	_check(management.pan_position.is_equal_approx(at_60), "Frame-rate-independent movement (30/60)")
	_check(is_equal_approx(at_60.x, 360.0) and at_60.y == 0.0, "Screen-axis speed at 1x")
	management.set_pan_position(Vector2.ZERO)
	modes.route_pan(Vector2.ONE, 1.0)
	_check(is_equal_approx(management.pan_position.length(), 360.0), "Diagonal normalized")
	management.set_pan_position(Vector2.ZERO)
	for step: int in 1000:
		management.pan(Vector2.RIGHT, 0.0001)
	_check(is_equal_approx(management.pan_position.x, 36.0), "Subpixel accumulation does not stall")
	_check(management.global_position.x == 36.0, "Accumulated render position snapped")
	var start: Vector2 = management.pan_position
	Input.parse_input_event(_key(KEY_W, true))
	await create_timer(0.05).timeout
	Input.parse_input_event(_key(KEY_W, false))
	await process_frame
	_check(management.pan_position.y < start.y, "Real W input pans upward")
	start = management.pan_position
	Input.parse_input_event(_key(KEY_RIGHT, true))
	await create_timer(0.05).timeout
	Input.parse_input_event(_key(KEY_RIGHT, false))
	await process_frame
	_check(management.pan_position.x > start.x, "Real arrow alternative pans right")
	await _wheel(MOUSE_BUTTON_WHEEL_UP)
	_check(management.zoom_level == 2 and player.zoom_level == 2, "Wheel zoom-in only management")
	_check(camera_hint.text.contains("zoom 2x"), "Zoom indicator updates in dedicated camera hint")
	management.set_pan_position(Vector2.ZERO)
	management.pan(Vector2.RIGHT, 1.0)
	_check(management.pan_position == Vector2(180, 0), "Zoom-adjusted screen panning speed")
	for step: int in 10:
		await _wheel(MOUSE_BUTTON_WHEEL_UP)
	_check(management.zoom_level == 3, "Repeated wheel events bounded at 3x")
	for step: int in 10:
		await _wheel(MOUSE_BUTTON_WHEEL_DOWN)
	_check(management.zoom_level == 1, "Repeated wheel events bounded at 1x")
	_check(not management.set_zoom_level(NAN) and not management.set_zoom_level(INF), "Nonfinite zoom rejected")
	management.set_zoom_level(-10)
	_check(management.zoom_level == 1, "Negative zoom clamped")
	var edit: LineEdit = LineEdit.new()
	main.get_node("UI").add_child(edit)
	edit.grab_focus()
	await process_frame
	before = management.pan_position
	modes.route_pan(Vector2.RIGHT, 1.0)
	_check(management.pan_position == before, "Focused UI blocks pan")
	_check(not modes.route_unhandled_input(_key(KEY_TAB, true)), "Focused UI blocks mode shortcut")
	await _tab()
	_check(modes.is_management_mode(), "Real Tab with focused editor does not switch mode")
	edit.release_focus()
	edit.queue_free()
	await process_frame
	management.bounds_enabled = true
	management.world_bounds = Rect2(-1000, -1000, 2000, 2000)
	management.set_pan_position(Vector2(9999, -9999))
	_check(management.pan_position == Vector2(520, -730), "Future large-map viewport bounds")
	management.pan(Vector2.RIGHT, 10.0)
	management.pan(Vector2.LEFT, 0.1)
	_check(management.pan_position.x < 520.0, "No accumulated overshoot/sticky boundary")
	management.world_bounds = Rect2(-10, -10, 20, 20)
	management.set_pan_position(Vector2(123, 456))
	_check(management.pan_position == Vector2(123, 456), "Small-map bounds do not displace view")
	management.bounds_enabled = false
	management.set_pan_position(Vector2(5000, -4000))
	_check(management.global_position == Vector2(5000, -4000), "Unbounded future world positions")
	management.set_pan_position(Vector2(64, 32))
	management.set_zoom_level(3)
	var saved_position: Vector2 = management.pan_position
	var saved_zoom: int = management.zoom_level
	target.position = Vector2(-32, 16)
	player.set_zoom_level(3)
	await _tab()
	_check(player.is_active() and not management.camera.enabled and modes.is_player_mode(), "Tab restores player")
	_check(player.global_position == target.global_position, "Immediate target reacquisition")
	_check(player.camera.get_screen_center_position().is_equal_approx(target.global_position), "No stale management center after return")
	_check(player.zoom_level == 3, "Player's own configured zoom preserved")
	modes.route_pan(Vector2.RIGHT, 1.0)
	_check(management.pan_position == saved_position, "Inactive pan disabled")
	await _tab()
	_check(management.pan_position == saved_position and management.zoom_level == saved_zoom, "Management state preserved on reentry")
	for step: int in 20:
		await _tab()
		_check(player.is_active() != management.is_active(), "Exactly one current camera after transition")
		_check(player.camera.enabled != management.camera.enabled, "Inactive Camera2D disabled")
	_check(main.get_node("World").get_instance_id() == world_id and main.get_node("World/Terrain/Ground").get_instance_id() == ground_id, "Same world and layer identities")
	_check(ground.terrain_cells == terrain and ground.get_used_cells().size() == ground.region.size.x * ground.region.size.y, "Terrain state and declared map unchanged")
	_check(not paused, "Mode changes never pause simulation")
	if "--capture" in OS.get_cmdline_user_args():
		management.set_pan_position(Vector2.ZERO)
		management.set_zoom_level(1)
		await _capture("management_mode")
		await _wheel(MOUSE_BUTTON_WHEEL_UP)
		await _capture("management_zoom_2x")
		await _tab()
		player.set_zoom_level(2)
		await _capture("player_mode_restored")
	# Invalid dependencies fail safely without a partial transition.
	var stale_rig: Variant = management
	management.queue_free()
	_check(not modes.request_mode(GameplayModeCoordinator.Mode.PLAYER if modes.is_management_mode() else GameplayModeCoordinator.Mode.BASE_MANAGEMENT), "Queued camera transition rejected")
	await process_frame
	_check(not modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT), "Freed camera transition rejected")
	modes.route_pan(Vector2.RIGHT, 1.0)
	target.queue_free()
	await process_frame
	await process_frame
	_check(is_instance_valid(world), "Missing camera/target leaves world intact")
	var invalid: GameplayModeCoordinator = GameplayModeCoordinator.new()
	root.add_child(invalid)
	_check(not invalid.initialize(null, null), "Missing camera initialization rejected")
	_check(not invalid.initialize(stale_rig, null), "Freed camera initialization rejected before typed assignment")
	invalid.queue_free()
	main.queue_free()
	await process_frame
	var fallback_main: Node = MAIN.instantiate()
	root.add_child(fallback_main)
	await process_frame
	var fallback_modes: GameplayModeCoordinator = fallback_main.get_node("Systems/GameplayModes")
	var fallback_player: PlayerCameraRig = fallback_main.get_node("CameraRig")
	var last_view: Vector2 = fallback_player.global_position
	# Isolate target-loss fallback from viewport-bound clamping at the new landing spawn.
	fallback_main.management_camera.bounds_enabled = false
	fallback_main.get_node("World/Entities/Players/Astronaut").queue_free()
	await process_frame
	await process_frame
	_check(fallback_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT), "First entry safe with freed target")
	var fallback_management: BaseManagementCameraRig = fallback_main.get_node("BaseManagementCameraRig")
	_check(fallback_management.pan_position == last_view, "Missing first target uses last player view")
	_check(fallback_modes.request_mode(GameplayModeCoordinator.Mode.PLAYER), "Player return safe with missing target")
	fallback_main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d gameplay mode checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _key(code: Key, pressed: bool) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	return event


func _tab() -> void:
	Input.parse_input_event(_key(KEY_TAB, true))
	await process_frame
	await process_frame
	Input.parse_input_event(_key(KEY_TAB, false))
	await process_frame


func _wheel(button: MouseButton) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame


func _capture(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	_check(image.save_png("res://tests/output/" + filename + ".png") == OK, "Save " + filename)
	await RenderingServer.frame_post_draw
	# Interface transitions and live telemetry intentionally change between frames.
	# Retain the full UI screenshot, then isolate the world for the camera-jitter proof.
	var interface: CanvasLayer = root.get_node("Main/UI")
	var was_visible: bool = interface.visible
	interface.hide()
	await RenderingServer.frame_post_draw
	var world_image: Image = root.get_texture().get_image()
	await RenderingServer.frame_post_draw
	_check(world_image.get_data() == root.get_texture().get_image().get_data(), "Stationary world frames stable with animated UI excluded")
	interface.visible = was_visible


func _on_mode_changed(_mode: GameplayModeCoordinator.Mode) -> void:
	_notifications += 1


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(description)
