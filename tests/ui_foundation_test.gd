extends SceneTree
## Native input/layout tests for the Mission OS HUD. No physical keyboard/mouse session is implied.

const MAIN: PackedScene = preload("res://scenes/main.tscn")
const DEFERRED: Array[StringName] = [&"physical", &"fatigue", &"sleep", &"suit_oxygen", &"suit_battery", &"radiation"]
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
	var utilities: UtilityService = main.get_node("Systems/Utilities")
	var saved_terrain: Dictionary[Vector2i, int] = ground.terrain_cells.duplicate()
	_check(ui.layer == 10 and not ui.follow_viewport_enabled, "Screen-space UI composition retains CanvasLayer policy")
	_check(hud.visible and hud.mode_label.text == "PLAYER MODE", "Active mode has a dedicated visible indicator")
	_check(hud.inventory_hint.plain_text() == "[I] Inventory" and hud.mode_hint.plain_text().contains("Tab"), "Dedicated inventory and mode hints")
	_check(hud.details_hint.plain_text() == "[H] Status" and hud.menu_hint.plain_text() == "[Escape] Menu", "Status and menu hints name their bindings")
	_check(ui.interaction_prompt.prompt.text == "[E] Collect Lunar Sample", "Existing contextual interaction ready and visible")
	_check(not hud.notifications.visible and hud.notifications.message.text == "No new messages" and hud.notifications.expiry.is_stopped(), "Quiet notice card is hidden without active polling")
	_check(hud.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and ui.inventory_window.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "UI nearest filtering retained")
	_check(hud.theme == ui.inventory_window.theme and hud.theme == ui.interaction_prompt.theme and hud.theme == AppSettings.shared().theme(), "HUD, prompt and inventory share the replaceable Mission OS theme")
	_check(hud.theme.default_font_size == 11 and hud.theme.default_font != null, "Theme supplies the pixel typeface at its native size")
	_check(not hud.is_processing() and not ui.is_processing(), "HUD has no per-frame refresh")
	_passive_controls(hud)
	_passive_controls(ui.interaction_prompt)
	# Readouts without an implemented mechanic are dimmed and labelled, never given numbers.
	for id: StringName in DEFERRED:
		var deferred: TelemetryIndicator = hud.status.indicators[id]
		_check(not deferred.available and deferred.value_text() == HudStatusPanel.NOT_SIMULATED, "Status has no invented gameplay quantity: " + id)
		_check(deferred.caption_text().length() > 0, "Deferred status field named in English: " + id)
	var eva: TelemetryIndicator = hud.status.indicators[&"eva_range"]
	_check(eva.visible and eva.available and eva.value_text() == "Inside mission area" and eva.state == UiKit.State.OK, "EVA range reads the real safety zone")
	for id: StringName in [&"cabin_oxygen", &"cabin_co2", &"cabin_pressure", &"airlock", &"alarms"]:
		_check(not hud.status.indicators[id].visible, "Cabin and airlock readouts stay hidden on the surface: " + id)
	var battery: TelemetryIndicator = hud.status.indicators[&"habitat_battery"]
	var expected_battery: String = "%d%%  %+.0f W" % [roundi(100.0 * utilities.model.battery_wh / float(utilities.model.config.data.battery_capacity_wh)), utilities.model.last_power.battery_w]
	_check(battery.visible and battery.available and battery.value_text() == expected_battery, "Battery readout mirrors the utility model")
	_check(hud.location_title.text == "LUNAR SURFACE", "Location chip names the current space")
	_check(hud.objectives.visible and hud.objectives.objective_title.text == "Collect a Lunar Sample" and hud.objectives.progress_label.text == "0 / 3", "Objective card shows the first tutorial objective")
	var system_names: PackedStringArray = []
	for child: Node in main.get_node("Systems").get_children():
		system_names.append(child.name)
	system_names.sort()
	_check(system_names == PackedStringArray(["ChiwisCommentary", "ChiwisDialogue", "EvaSafety", "GameplayModes", "HabitatDirector", "Objectives", "PlayerSession", "Utilities"]),
		"Only approved orchestration and presentation adapters; no medical manager")
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
	_check(hud.inventory_hint.plain_text() == "[J] Inventory" and hud.mode_hint.plain_text().contains("M"), "Hints respect remapped actions")
	_check(ui.interaction_prompt.prompt.text.begins_with("[F]"), "Prompt shares binding label helper")
	InputMap.action_erase_events(&"interact_primary")
	ui.refresh_bindings()
	_check(ui.interaction_prompt.prompt.text.begins_with("[Unbound]"), "Unbound interaction represented safely")
	for action: StringName in originals:
		InputMap.action_erase_events(action)
		for event: InputEvent in originals[action]:
			InputMap.action_add_event(action, event)
	ui.refresh_bindings()
	_check(hud.inventory_hint.plain_text() == "[I] Inventory", "Original InputMap restored")
	# Native mouse event over the HUD must still reach the existing world action.
	await _click(Vector2(48, 32))
	_check(inventory.get_quantity(&"lunar_sample") == 6, "Passive location chip does not swallow world interaction")
	_check(hud.notifications.visible and hud.notifications.message.text == "Collected", "Existing collection feedback reaches the notice card")
	_check(root.gui_get_focus_owner() == null and actor.control_enabled, "Passive UI never takes focus or blocks movement permission")
	_check(hud.objectives.objective_title.text.begins_with("Enter the outpost") and hud.objectives.progress_label.text == "1 / 3", "Collecting the sample advances the objective card")
	_check(hud.dialogue.is_showing() and hud.dialogue.text.text.begins_with("Sample secured"), "Companion remark appears in the dialogue card")
	var notice_nodes: int = hud.notifications.get_child_count()
	_check(ui.notify("Moon system link ready", 0.06), "Explicit system notification accepted")
	_check(hud.notifications.message.text == "Moon system link ready", "Notification text displayed")
	await create_timer(0.4).timeout
	_check(hud.notifications.message.text == "No new messages" and not hud.notifications.is_active(), "One-shot expiry returns to the quiet state")
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
	# Severity: an alert stays up; the newest lesser notice follows it instead of replacing it.
	ui.notify("Habitat alarm: test", 0.2, NotificationArea.Level.CRITICAL)
	ui.notify("Routine notice", 0.2)
	_check(hud.notifications.message.text == "Habitat alarm: test" and hud.notifications.title.text == "ALERT", "Lesser notice does not replace an active alert")
	await create_timer(0.35).timeout
	_check(hud.notifications.message.text == "Routine notice" and hud.notifications.title.text == "SYSTEM NOTICE", "Deferred notice follows the alert")
	ui.notify("System notice: lunar interface online. Cabin readouts appear inside the habitat.")
	await _settle()
	_check_layout(ui)
	_check(not paused and dog.follow_enabled and root.gui_get_focus_owner() == null, "Informational messages leave world and companion simulation active")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("ui_notice")
	hud.notifications.clear_message()
	# Status details and message dismissal are interface-only shortcuts.
	await _press(KEY_H)
	_check(hud.status.expanded and hud.details_hint.plain_text() == "[H] Hide status" and actor.control_enabled, "Status key expands details without blocking movement")
	_check_layout(ui)
	await _press(KEY_H)
	_check(not hud.status.expanded, "Status key collapses details")
	_check(main.companion_dialogue.is_speaking(), "Companion line still showing before dismissal")
	var spoken: String = hud.dialogue.text.text
	await _press(KEY_SPACE)
	_check(hud.dialogue.text.text != spoken or not main.companion_dialogue.is_speaking(), "Dismiss key advances the companion dialogue")
	main.companion_dialogue.clear()
	# Real I/Esc/Tab keep the existing modal contract.
	await _press(KEY_I)
	_check(ui.inventory_window.visible and hud.inventory_hint.plain_text() == "[I] Close inventory", "Inventory visibility updates dedicated hint")
	_check(hud.controls_hint.text == "Inventory open" and hud.mode_hint.caption.contains("Close inventory"), "Modal UI explains existing input policy")
	_check(ui.scrim.visible and ui.is_modal_open(), "Shared scrim dims the world behind a modal window")
	var held_position: Vector2 = actor.global_position
	await _press(KEY_TAB)
	_check(modes.is_player_mode() and actor.global_position == held_position and actor.velocity == Vector2.ZERO, "New HUD does not bypass inventory mode/movement gate")
	ui.notify("Inventory notice")
	_check(root.gui_get_focus_owner() != null, "Notice does not steal existing inventory focus")
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("ui_inventory")
	await _press(KEY_ESCAPE)
	_check(not ui.inventory_window.visible and hud.inventory_hint.plain_text() == "[I] Inventory" and actor.control_enabled, "Esc closes existing modal and restores HUD/control")
	_check(not ui.scrim.visible and not ui.system_menu.visible, "Closing the inventory leaves no scrim and does not open the mission menu")
	await _press(KEY_TAB)
	_check(hud.mode_label.text == "BASE MANAGEMENT MODE" and modes.is_management_mode(), "Mode signal updates exact management indicator")
	_check(hud.inventory_hint.caption.contains("Player Mode only") and ui.interaction_prompt.prompt.text.is_empty(), "Management hint/prompt policy accurate")
	_check(ui.dashboard.visible and not hud.objectives.visible, "Management view shows the dashboard in place of the objective card")
	var top_before: Rect2 = (hud.get_node("LeftColumn/TopBar") as Control).get_global_rect()
	var actor_before: Vector2 = actor.global_position
	var dog_before: Vector2 = dog.global_position
	management.set_pan_position(Vector2(75, -24))
	management.set_zoom_level(3)
	await _settle()
	_check(hud.controls_hint.text.contains("zoom 3x"), "Zoom signal updates independent camera hint")
	_check((hud.get_node("LeftColumn/TopBar") as Control).get_global_rect() == top_before, "Camera pan/zoom does not move screen-space HUD")
	_check(actor.global_position == actor_before and dog.global_position == dog_before, "HUD mode changes preserve both actors")
	var previous_zoom: int = management.zoom_level
	await _wheel(Vector2(48, 32), MOUSE_BUTTON_WHEEL_DOWN)
	_check(management.zoom_level == previous_zoom - 1, "Passive HUD also passes management wheel input")
	# Dashboard input never leaks into the camera, and never takes keyboard focus from it.
	var dock: Rect2 = ui.dashboard.get_global_rect()
	previous_zoom = management.zoom_level
	await _wheel(dock.get_center(), MOUSE_BUTTON_WHEEL_UP)
	_check(management.zoom_level == previous_zoom, "Wheel over the dashboard does not zoom the camera")
	await _click((ui.dashboard.rail_buttons[&"power"] as Control).get_global_rect().get_center())
	_check(ui.dashboard.current == &"power" and root.gui_get_focus_owner() == null and modes.keyboard_input_available(), "Dashboard click selects a category without taking keyboard focus")
	await _press(KEY_X)
	_check(ui.dashboard.current == &"battery", "Next-category key steps the dashboard")
	await _press(KEY_Z)
	_check(ui.dashboard.current == &"power", "Previous-category key steps the dashboard")
	_check_layout(ui)
	hud.notifications.clear_message()
	if "--capture" in OS.get_cmdline_user_args():
		await _capture("ui_management")
	await _press(KEY_TAB)
	_check(root.get_camera_2d() == player_camera.camera and player_camera.follow_target == actor, "Existing player camera restored")
	_check(not ui.dashboard.visible or ui.dashboard.modulate.a < 1.0, "Dashboard leaves with management mode")
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
	_check(inventory.get_quantity(&"lunar_sample") == 6 and not hud.status.indicators[&"physical"].available, "Inventory data preserved; deferred status remains unavailable")
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
	var panels: Dictionary[String, Control] = {}
	for path: String in ["LeftColumn/TopBar", "LeftColumn/StatusPanel", "BottomBar", "Objectives"]:
		var panel: Control = ui.hud.get_node(path)
		panels[path] = panel
		if not panel.is_visible_in_tree():
			continue
		_check(viewport.encloses(panel.get_global_rect()), "HUD panel fits visible viewport: " + path)
		_check(panel.global_position == panel.global_position.round(), "Panel has integer logical coordinates: " + path)
	for indicator: TelemetryIndicator in ui.hud.status.indicators.values():
		if indicator.is_visible_in_tree():
			_check(indicator.size.x <= ui.hud.status.size.x + 0.01, "Status readout fits its column: " + indicator.name)
	var top: Rect2 = panels["LeftColumn/TopBar"].get_global_rect()
	var status: Rect2 = panels["LeftColumn/StatusPanel"].get_global_rect()
	_check(top.end.y <= status.position.y, "Top chips and status panel do not overlap")
	_check(not status.intersects(panels["BottomBar"].get_global_rect()), "Status panel clears the hint bar")
	if panels["Objectives"].is_visible_in_tree():
		_check(not panels["Objectives"].get_global_rect().intersects(top) and not panels["Objectives"].get_global_rect().intersects(status), "Objective card clears the left column")


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
	# Native input arrives in window pixels; Godot applies the viewport stretch.
	# The controls above report logical coordinates, including in 2x fullscreen.
	var window_position: Vector2 = root.get_final_transform() * position
	event.position = window_position
	event.global_position = window_position
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
