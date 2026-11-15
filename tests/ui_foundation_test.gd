extends SceneTree
## Native input/layout tests. No physical keyboard/mouse session is implied.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
var _checks: int = 0
var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var main: Node = MAIN.instantiate()
	root.add_child(main)
	await _settle()
	var ui: GameUI = main.get_node("UI")
	var hud: GameHUD = ui.hud
	var modes: GameplayModeCoordinator = main.get_node("Systems/GameplayModes")
	var management: BaseManagementCameraRig = main.get_node("BaseManagementCameraRig")
	var player_camera: PlayerCameraRig = main.get_node("CameraRig")
	var actor: Astronaut = main.get_node("World/Entities/Players/Astronaut")
	var inventory: RuntimeInventory = actor.get_node("Inventory")
	var dog: Chiwis = main.get_node("World/Entities/NPCs/Chiwis")
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var saved_terrain: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	_check(ui.layer == 10 and not ui.follow_viewport_enabled, "Screen-space UI composition retains CanvasLayer policy")
	_check(hud.visible and hud.mode_label.text == "PLAYER MODE", "Active mode has a dedicated visible indicator")
	_check(hud.inventory_hint.text == "[I] Inventory" and hud.mode_hint.text.contains("Tab"), "Dedicated inventory and mode hints")
	_check(ui.interaction_prompt.prompt.text == "[E] Collect Lunar Sample", "Existing contextual interaction ready and visible")
	_check(hud.notifications.message.text == "No new messages" and hud.notifications.expiry.is_stopped(), "Quiet notification placeholder without active polling")
	_check(hud.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and ui.inventory_window.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "UI nearest filtering retained")
	_check(hud.theme == ui.inventory_window.theme and hud.theme == ui.interaction_prompt.theme, "HUD, prompt and inventory share replaceable theme")
	_check(not hud.is_processing() and not ui.is_processing(), "HUD has no per-frame refresh")
	_passive_controls(hud)
	_passive_controls(ui.interaction_prompt)
	var rows: Node = hud.get_node("StatusPanel/Content/Rows")
	_check(rows.get_child_count() == 6, "Exactly six reserved future status fields")
	for row: Node in rows.get_children():
		_check((row.get_node("Value") as Label).text == "-", "Status has no invented gameplay quantity")
		_check((row.get_node("Name") as Label).text.length() > 0, "Reserved status field named in English")
	_check(main.get_node("Systems").get_child_count() == 5 and main.get_node("Systems/EvaSafety") is EvaSafetyMonitor and main.get_node("Systems/HabitatDirector") is HabitatDirector and main.get_node("Systems/Utilities") is UtilityService, "Only approved EVA/habitat/utility orchestration; no medical manager")
	_check_layout(ui)
	var originally_fullscreen: bool = root.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("ui_fullscreen" if originally_fullscreen else "ui_player")
	# Bindings are updated explicitly, with original InputMap events restored afterward.
	var originals: Dictionary[StringName, Array] = {}
	var remaps: Dictionary[StringName, Key] = {&"inventory_toggle": KEY_J, &"interact_primary": KEY_F, &"mode_switch": KEY_M}
	for action: StringName in remaps:
		originals[action] = InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, _key(remaps[action], false))
	ui.refresh_bindings()
	_check(hud.inventory_hint.text == "[J] Inventory" and hud.mode_hint.text.contains("M"), "Hints respect remapped actions")
	_check(ui.interaction_prompt.prompt.text.begins_with("[F]"), "Prompt shares binding label helper")
	InputMap.action_erase_events(&"interact_primary")
	ui.refresh_bindings()
	_check(ui.interaction_prompt.prompt.text.begins_with("[Unbound]"), "Unbound interaction represented safely")
	for action: StringName in originals:
		InputMap.action_erase_events(action)
		for event: InputEvent in originals[action]:
			InputMap.action_add_event(action, event)
	ui.refresh_bindings()
	_check(hud.inventory_hint.text == "[I] Inventory", "Original InputMap restored")
	# Native mouse event over the HUD must still reach the existing world action.
	await _click(Vector2(48, 32))
	_check(inventory.get_quantity(&"lunar_sample") == 6, "Passive top-bar click does not swallow world interaction")
	_check(hud.notifications.message.text == "Collected", "Existing collection feedback reaches reusable notification area")
	_check(root.gui_get_focus_owner() == null and actor.control_enabled, "Passive UI never takes focus or blocks movement permission")
	var notice_nodes: int = hud.notifications.get_child_count()
	_check(ui.notify("Moon system link ready", 0.06), "Explicit system notification accepted")
	_check(hud.notifications.message.text == "Moon system link ready", "Notification text displayed")
	await create_timer(0.14).timeout
	_check(hud.notifications.message.text == "No new messages", "One-shot expiry returns to quiet placeholder")
	ui.notify("First message")
	ui.notify("Latest message")
	_check(hud.notifications.message.text == "Latest message" and hud.notifications.get_child_count() == notice_nodes, "Latest notice replaces old text without allocating controls")
	for duration: float in [0.0, -1.0, NAN, INF]:
		_check(not ui.notify("Invalid duration", duration) and hud.notifications.message.text == "Latest message", "Invalid notification duration rejected without mutation")
	_check(not ui.notify("  "), "Empty notice ignored")
	ui.notify("A very long system message. ".repeat(30))
	_check(hud.notifications.message.text.length() <= hud.notifications.maximum_characters and hud.notifications.message.text.ends_with("…"), "Notification text bounded and truncated")
	hud.notifications.maximum_characters = 0
	ui.notify("Safe clamped limit")
	_check(hud.notifications.message.text.length() == 1, "Invalid configured text limit clamped safely")
	hud.notifications.maximum_characters = 180
	ui.notify("System notice: lunar interface online. Status readouts are reserved for future equipment.")
	await _settle()
	_check_layout(ui)
	_check(not paused and dog.follow_enabled and root.gui_get_focus_owner() == null, "Informational messages leave world and companion simulation active")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("ui_notice")
	hud.notifications.clear_message()
	# Real I/Esc/Tab keep the existing modal contract. No extra shortcut is introduced.
	await _press(KEY_I)
	_check(ui.inventory_window.visible and hud.inventory_hint.text == "[I] Close inventory", "Inventory visibility updates dedicated hint")
	_check(hud.controls_hint.text == "Inventory open" and hud.mode_hint.text.contains("Close inventory"), "Modal UI explains existing input policy")
	var held_position: Vector2 = actor.global_position
	await _press(KEY_TAB)
	_check(modes.is_player_mode() and actor.global_position == held_position and actor.velocity == Vector2.ZERO, "New HUD does not bypass inventory mode/movement gate")
	ui.notify("Inventory notice")
	_check(root.gui_get_focus_owner() != null, "Notice does not steal existing inventory focus")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("ui_inventory")
	await _press(KEY_ESCAPE)
	_check(not ui.inventory_window.visible and hud.inventory_hint.text == "[I] Inventory" and actor.control_enabled, "Esc closes existing modal and restores HUD/control")
	await _press(KEY_TAB)
	_check(hud.mode_label.text == "BASE MANAGEMENT MODE" and modes.is_management_mode(), "Mode signal updates exact management indicator")
	_check(hud.inventory_hint.text.contains("Player Mode only") and ui.interaction_prompt.prompt.text.is_empty(), "Management hint/prompt policy accurate")
	var top_before: Rect2 = (hud.get_node("TopBar") as Control).get_global_rect()
	var actor_before: Vector2 = actor.global_position
	var dog_before: Vector2 = dog.global_position
	management.set_pan_position(Vector2(75, -24))
	management.set_zoom_level(3)
	await _settle()
	_check(hud.controls_hint.text.contains("zoom 3x"), "Zoom signal updates independent camera hint")
	_check((hud.get_node("TopBar") as Control).get_global_rect() == top_before, "Camera pan/zoom does not move screen-space HUD")
	_check(actor.global_position == actor_before and dog.global_position == dog_before, "HUD mode changes preserve both actors")
	var previous_zoom: int = management.zoom_level
	await _wheel(Vector2(48, 32), MOUSE_BUTTON_WHEEL_DOWN)
	_check(management.zoom_level == previous_zoom - 1, "Passive HUD also passes management wheel input")
	_check_layout(ui)
	hud.notifications.clear_message()
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("ui_management")
	await _press(KEY_TAB)
	_check(root.get_camera_2d() == player_camera.camera and player_camera.follow_target == actor, "Existing player camera restored")
	# Check native resize without changing project settings; restore the original window size.
	if DisplayServer.get_name() != "headless" and not originally_fullscreen:
		var original_size: Vector2i = root.size
		root.size = Vector2i(1280, 720)
		await _settle(5)
		_check_layout(ui)
		_check(root.get_camera_2d() == player_camera.camera, "Resizing UI does not replace active camera")
		if "--capture" in OS.get_cmdline_user_args():
			await _capture("ui_resized")
		root.size = original_size
		await _settle()
	_check(ground.terrain_cells == saved_terrain and ground.get_used_cells().size() == ground.region.size.x * ground.region.size.y, "UI never rebuilds or changes lunar map data")
	_check(inventory.get_quantity(&"lunar_sample") == 6 and rows.get_node("Physical/Value").text == "-", "Inventory data preserved; reserved status remains empty")
	main.queue_free()
	await process_frame
	if _failures.is_empty():
		print("PASS: %d UI foundation checks" % _checks)
		quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		quit(1)


func _passive_controls(node: Node) -> void:
	if node is Control:
		_check(node.mouse_filter == Control.MOUSE_FILTER_IGNORE and node.focus_mode == Control.FOCUS_NONE, "Passive HUD/prompt control ignores pointer and keyboard focus: " + node.name)
	for child: Node in node.get_children():
		_passive_controls(child)


func _check_layout(ui: GameUI) -> void:
	var viewport: Rect2 = root.get_visible_rect()
	_check(ui.hud.get_global_rect() == viewport, "HUD fills logical viewport after layout/resize")
	for name: String in ["TopBar", "StatusPanel", "Notifications", "BottomBar"]:
		var panel: Control = ui.hud.get_node(name)
		_check(viewport.encloses(panel.get_global_rect()), "HUD panel fits visible viewport: " + name)
		_check(panel.global_position == panel.global_position.round(), "Panel has integer logical coordinates")
	for row: Node in ui.hud.get_node("StatusPanel/Content/Rows").get_children():
		var label: Label = row.get_node("Name")
		_check(label.get_minimum_size().x <= label.size.x + 0.01, "Reserved status name fits without clipping")
	_check((ui.hud.get_node("TopBar") as Control).get_global_rect().end.y < (ui.hud.get_node("StatusPanel") as Control).global_position.y, "Top bar and status panel do not overlap")


func _key(code: Key, pressed: bool) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	return event


func _press(code: Key) -> void:
	Input.parse_input_event(_key(code, true))
	Input.flush_buffered_events()
	await _settle(1)
	Input.parse_input_event(_key(code, false))
	Input.flush_buffered_events()
	await _settle(1)


func _click(position: Vector2) -> void:
	await _mouse(position, MOUSE_BUTTON_LEFT)


func _wheel(position: Vector2, button: MouseButton) -> void:
	await _mouse(position, button)


func _mouse(position: Vector2, button: MouseButton) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = button
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _settle(1)
	event = event.duplicate() as InputEventMouseButton
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await _settle(1)


func _settle(count: int = 3) -> void:
	for index: int in count:
		await physics_frame
	await process_frame


func _capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	_check(root.get_texture().get_image().save_png("res://tests/output/" + name + ".png") == OK, "Capture " + name)


func _check(value: bool, label: String) -> void:
	_checks += 1
	if not value:
		_failures.append(label)
