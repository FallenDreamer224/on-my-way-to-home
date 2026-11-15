extends SceneTree
## Production terminal, modal, transition and persistence acceptance using native input.
var checks: int = 0
var failures: Array[String] = []
var main: Node
var director: HabitatDirector
var service: UtilityService
var panel: UtilityPanel
var actor: Astronaut
var dog: Chiwis
var capture: bool = false
var notices: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures.append(label)


func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	await process_frame


func use_action(id: StringName, via_key: bool = false) -> void:
	var action: HabitatAction = director.exterior_entry if director.location == &"outside" else director.rooms[director.location].actions[id]
	actor.global_position = action.global_position
	dog.global_position = actor.global_position
	await physics_frame
	await physics_frame
	var detector: InteractionDetector = actor.get_node("InteractionDetector")
	detector.refresh_target()
	check(detector.target == action, "Nearest production action " + id)
	if via_key:
		await key(KEY_E, true)
		await key(KEY_E, false)
	else:
		check(detector.interact(), "Accepted action " + id)
	for tick: int in 90:
		if not director.busy:
			break
		await physics_frame
	check(not director.busy, "Action completed " + id)
	actor.set_physics_process(false)
	dog.set_physics_process(false)


func photo(name: String) -> void:
	if not capture:
		return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png("res://tests/output/utilities_" + name + ".png") == OK, "Capture " + name)


func _run() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	director = main.get_node("Systems/HabitatDirector")
	service = main.get_node("Systems/Utilities")
	service.set_physics_process(false)
	panel = director.utility_panel
	actor = main.astronaut
	dog = main.chiwis
	actor.set_physics_process(false)
	dog.set_physics_process(false)
	director.cycle_seconds = 0.02
	service.critical_notice.connect(func(text: String) -> void: notices.append(text))
	var service_id: int = service.get_instance_id()
	var actor_id: int = actor.get_instance_id()
	var dog_id: int = dog.get_instance_id()
	var inventory: RuntimeInventory = actor.get_node("Inventory")
	inventory.add_items(&"metal_scrap", 3)
	var quantity: int = inventory.get_quantity(&"metal_scrap")
	check(not service.model.occupied and not panel.visible, "Outside context starts safely with closed terminal")
	check(service.model.alarms.is_empty(), "Production configuration starts without alarms")
	await use_action(&"enter")
	await use_action(&"seal_outer")
	await use_action(&"inspection")
	await use_action(&"cycle")
	await use_action(&"inner")
	check(service.model.occupied, "Pressurized cabin occupancy set at equipment lock")
	await use_action(&"hub")
	await use_action(&"engineering")
	var engineering: HabitatRoom = director.rooms[&"engineering"]
	for station: StringName in [&"eclss", &"water", &"power"]:
		await use_action(station, true)
		check(panel.visible and main.player_session.inspection_blocked, "E opens utility terminal " + station)
		check(not actor.control_enabled and not actor.get_node("InteractionDetector").enabled, "Terminal blocks astronaut and detector")
		check(main.gameplay_modes.modal_input_blocked, "Terminal shares existing mode input gate")
		var expected: String = {&"eclss": "ventilation", &"water": "water_treatment", &"power": "distribution"}[station]
		check(panel._selection.get_item_metadata(panel._selection.selected) == expected, "Station selects relevant equipment")
		check(not main.player_session.set_inventory_open(true), "Terminal cannot overlap inventory modal")
		check(not director.request_action(engineering.actions[&"hub"]), "Terminal prevents door transaction")
		await key(KEY_TAB, true)
		await key(KEY_TAB, false)
		check(main.gameplay_modes.is_player_mode(), "Tab cannot switch mode under terminal")
		await process_frame
		var view := Rect2(Vector2.ZERO, Vector2(root.content_scale_size))
		check(view.encloses(panel.get_global_rect()), "Terminal fits 960x540 logical viewport")
		check(panel.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Terminal uses nearest filtering")
		service.advance(1)
		check(panel._values.text.contains("Battery: %.2f" % service.model.battery_wh), "Battery text reports actual model")
		check(panel._values.text.contains("Potable: %.4f" % service.model.resources.potable_kg), "Water text reports actual model")
		check(panel._values.text.contains("Cabin pressure: %.2f" % (service.model.pressure_pa()/1000)), "Pressure text reports model estimate")
		if station == &"power":
			await photo("nominal")
		var before: Vector2 = actor.global_position
		actor.set_physics_process(true)
		await key(KEY_D, true)
		for tick: int in 5:
			await physics_frame
		await key(KEY_D, false)
		check(actor.global_position == before, "Held movement cannot move astronaut under terminal")
		actor.set_physics_process(false)
		await key(KEY_ESCAPE, true)
		await key(KEY_ESCAPE, false)
		check(not panel.visible and not main.player_session.inspection_blocked and actor.control_enabled, "Esc releases terminal permissions")
		check(root.gui_get_focus_owner() == null, "Closing terminal releases UI focus")
		check(engineering.state.inspected_facilities.has(station), "Existing station inspection retained")
	await use_action(&"power")
	# Exercise actual UI command buttons; quantities remain exclusively in the model.
	panel._selection.select(UtilityConfig.DEVICE_IDS.find("distribution"))
	var buttons: Array[Node] = panel.find_children("*", "Button", true, false)
	for button: Button in buttons:
		if button.text == "Sunlight 100% / 0%": button.pressed.emit()
	var old_battery: float = service.model.battery_wh
	service.advance(1)
	check(service.model.solar_fraction == 0 and service.model.battery_wh < old_battery, "Scenario control produces real battery discharge")
	for button: Button in buttons:
		if button.text == "Sunlight 100% / 0%": button.pressed.emit()
	service.advance(1)
	check(service.model.solar_fraction == 1 and service.model.last_power.battery_w > 0, "Restored source charges battery")
	var normal: Dictionary = service.capture_state()
	for id: String in service.model.equipment:
		service.model.equipment_command(id, "fault")
	await process_frame
	check(Rect2(Vector2.ZERO, Vector2(root.content_scale_size)).encloses(panel.get_global_rect()), "Multiple alarms cannot enlarge modal beyond viewport")
	await photo("multiple_alarms")
	check(service.restore_state(normal), "Restore after isolated multi-alarm display check")
	notices.clear()
	service._last_notice_s = -1000
	service._announced_at.clear()
	for button: Button in buttons:
		if button.text == "Test fault":
			button.pressed.emit()
	service.advance(1)
	check(service.model.equipment.distribution.fault and service.model.last_power.load_w == 0, "Terminal fault stops distribution")
	check(panel._equipment.text.contains("Power distribution: fault"), "Fault shown from actual equipment")
	check(panel._alarms.text.contains("equipment offline: distribution"), "Critical alarm displayed persistently")
	check(notices.size() == 1 and main.game_ui.hud.notifications.message.text.begins_with("Habitat alarm:"), "One event-driven notice reaches existing HUD")
	service.advance(2)
	check(notices.size() == 1, "Ongoing alarms do not spam")
	await photo("fault")
	for caption: String in ["Start maintenance", "Finish inspection"]:
		for button: Button in buttons:
			if button.text == caption: button.pressed.emit()
	service.advance(1)
	check(service.model.equipment.distribution.available() and service.model.last_power.load_w > 0, "Terminal repair placeholder restores equipment")
	check(service.model.equipment.distribution.service_count == 1, "Maintenance count persists")
	service.model.equipment_command("distribution", "fault")
	check(notices.size() == 1, "Rapid repeat alarm observes cooldown")
	service.model.equipment_command("distribution", "maintain")
	service.model.equipment_command("distribution", "complete")
	for tick: int in 31:
		service.advance(1)
	service.model.equipment_command("distribution", "fault")
	check(notices.size() == 2, "Rearmed alarm after configured cooldown can notify")
	service.model.equipment_command("distribution", "maintain")
	service.model.equipment_command("distribution", "complete")
	var closed_buttons: bool = false
	for button: Button in buttons:
		if button.text == "Close [Esc]":
			button.pressed.emit()
			closed_buttons = true
	check(closed_buttons and not panel.visible and not main.player_session.inspection_blocked, "Close button releases modal gate")
	var saved: Dictionary = service.capture_state()
	var model_id: int = service.model.get_instance_id()
	check(main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.BASE_MANAGEMENT), "Management mode restored after closing")
	check(service.model.get_instance_id() == model_id and service.capture_state() == saved, "Camera switch does not refill or reset utilities")
	service.advance(1)
	check(service.model.elapsed_s == float(saved.model.elapsed_s) + 1, "Utilities keep running in management mode")
	check(main.gameplay_modes.request_mode(GameplayModeCoordinator.Mode.PLAYER), "Player mode remains functional")
	await use_action(&"hub")
	await use_action(&"living")
	service.advance(1)
	check(service.get_instance_id() == service_id and service.model.equipment.distribution.service_count == 3, "Room changes retain utility model and repairs")
	await use_action(&"hub")
	await use_action(&"lock")
	await use_action(&"crew")
	check(not service.model.occupied, "Abstract crew chamber excluded from cabin occupancy")
	await use_action(&"inspection")
	await use_action(&"cycle")
	await use_action(&"outer")
	await use_action(&"outer")
	check(director.location == &"outside" and service.is_inside_tree(), "Utility service survives exterior return")
	var outside_resources: Dictionary = service.model.resources.duplicate()
	service.advance(1)
	check(service.model.resources.carbon_feed_kg == outside_resources.carbon_feed_kg, "Cabin occupant load stops outside; suit consumption deferred")
	check(service.model.elapsed_s > float(saved.model.elapsed_s), "Utility clock runs in retained world/rooms")
	check(actor.get_instance_id() == actor_id and dog.get_instance_id() == dog_id, "Original astronaut and Chiwis retained")
	check(inventory.get_quantity(&"metal_scrap") == quantity, "Inventory unchanged by utility integration")
	check(service.restore_state(JSON.parse_string(JSON.stringify(saved))), "Production service restores versioned JSON snapshot")
	# Restore a whole session's location separately; utility snapshot owns no scene geometry.
	check(service.model.equipment.distribution.service_count == 3, "Snapshot restores maintenance counters")
	service.restore_state(saved)
	check(service.capture_state() == saved, "Native service snapshot roundtrip exact")
	main.queue_free()
	await process_frame
	for failure: String in failures:
		printerr("FAIL: " + failure)
	if failures.is_empty():
		print("PASS: %d utility terminal/integration checks" % checks)
	quit(0 if failures.is_empty() else 1)

