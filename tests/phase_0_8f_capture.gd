extends SceneTree
## Phase 0.8F graphical validation: drives the real session through its interface states and
## saves 960 x 540 captures under tests/output/phase_0_8f/. Requires a rendering driver.
## Optional user arguments: shot names to capture (default: all gameplay shots).

const OUTPUT: String = "res://tests/output/phase_0_8f/"
var main: Node
var ui: GameUI
var checks: int = 0
var failures: PackedStringArray = []
var wanted: PackedStringArray = []


func _initialize() -> void:
	_run.call_deferred()


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)


func settle(frames: int = 4) -> void:
	for index: int in frames:
		await physics_frame
	await process_frame


func key(code: Key) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		await settle(1)


func shot(name: String) -> void:
	if not wanted.is_empty() and name not in wanted:
		return
	# Let transitions finish so captures show the resting presentation.
	await create_timer(0.45).timeout
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	check(image.save_png(OUTPUT + name + ".png") == OK, "Capture " + name)
	check(image.get_size() == Vector2i(960, 540), "Native 960 x 540 capture " + name)


## Title screen, its windows, and the New Game / return flow through the application root.
func _menu_shots() -> void:
	var app: AppRoot = load("res://scenes/app_root.tscn").instantiate()
	root.add_child(app)
	await settle(4)
	check(app.menu != null and app.session == null, "Application starts on the title screen")
	await create_timer(1.6).timeout
	await shot("21_main_menu")
	check(app.menu.buttons[&"continue"].disabled, "Continue is disabled without a save")
	app.menu.open_settings()
	await shot("22_menu_settings")
	app.menu.close_window()
	app.menu.open_credits()
	await shot("23_menu_credits")
	app.menu.close_window()
	app.menu.buttons[&"new_game"].pressed.emit()
	for frame: int in 90:
		if is_instance_valid(app.session) and not app.busy:
			break
		await process_frame
	check(is_instance_valid(app.session) and app.menu == null, "New Game builds one session and leaves the menu")
	await create_timer(1.4).timeout
	await shot("24_new_game_session")
	var session_ui: GameUI = app.session.get_node("UI")
	check(session_ui.hosted and session_ui.open_system_menu(), "Hosted session offers the mission menu")
	check(session_ui.system_menu.return_button.visible, "Return to main menu is offered when hosted")
	await shot("25_hosted_mission_menu")
	session_ui.system_menu.confirm.ask("RETURN TO MAIN MENU", "The current session is not saved and will end.", "End session")
	await shot("26_confirm_dialog")
	session_ui.system_menu.confirm.cancel()
	session_ui.system_menu.return_to_menu_requested.emit()
	for frame: int in 120:
		if app.menu != null and not app.busy:
			break
		await process_frame
	check(app.menu != null and not is_instance_valid(app.session) and not paused, "Returning ends the session and shows the menu unpaused")
	app.queue_free()
	await process_frame


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	for argument: String in OS.get_cmdline_user_args():
		if not argument.begins_with("--"):
			wanted.append(argument)
	main = GameEntry.new_game()
	root.add_child(main)
	await settle(6)
	ui = main.game_ui
	var actor: Astronaut = main.astronaut
	var director: HabitatDirector = main.get_node("Systems/HabitatDirector")
	var utilities: UtilityService = main.get_node("Systems/Utilities")
	var dialogue: ChiwisDialogue = main.companion_dialogue
	var inventory: RuntimeInventory = actor.get_node("Inventory")
	# 1. Player HUD at spawn: location, mode, telemetry, objective, prompt and greeting.
	await create_timer(1.6).timeout
	await shot("01_hud_player")
	# 2. Collect the sample through the real interaction; companion reacts, objective advances.
	await key(KEY_E)
	check(inventory.get_quantity(&"lunar_sample") > 0, "Sample collected through E")
	await shot("02_hud_after_pickup")
	# 3. Expanded status details.
	await key(KEY_H)
	check(ui.hud.status.expanded, "Status details expanded")
	await shot("03_hud_status_details")
	await key(KEY_H)
	# 4. Inventory with all three authored item types.
	inventory.add_items(&"metal_scrap", 3)
	inventory.add_items(&"supply_pack", 1)
	await key(KEY_I)
	check(ui.inventory_window.visible, "Inventory open")
	ui.inventory_window.slot_buttons[0].grab_focus()
	await shot("04_inventory")
	await key(KEY_ESCAPE)
	# 5. Chiwis safety dialogue at the mission boundary.
	dialogue.clear()
	var ground: TerrainLayer = main.get_node("World/Terrain/Ground")
	var home: Vector2 = actor.global_position
	actor.global_position = IsometricGrid.tile_to_world(Vector2i(17, 0), ground)
	main.chiwis.global_position = IsometricGrid.tile_to_world(Vector2i(16, 1), ground)
	await settle(8)
	check(dialogue.is_speaking(), "Boundary warning spoken by Chiwis")
	await shot("05_chiwis_dialogue")
	actor.global_position = home
	main.chiwis.global_position = home + Vector2(-32, 16)
	await settle(8)
	dialogue.clear()
	# 6. Base Management dashboard: overview and equipment inspection.
	await key(KEY_TAB)
	check(main.gameplay_modes.is_management_mode() and ui.dashboard.visible, "Dashboard open in management mode")
	await shot("06_management_overview")
	ui.dashboard.show_category(&"equipment")
	await shot("07_management_equipment")
	ui.dashboard.show_category(&"life_support")
	await shot("08_management_life_support")
	ui.dashboard.show_category(&"mission")
	await shot("09_management_mission")
	await key(KEY_TAB)
	# 7. Mission menu pages.
	check(ui.open_system_menu(), "Mission menu opens")
	await shot("10_mission_menu")
	ui.system_menu.show_page(&"settings")
	await shot("11_settings_display")
	ui.system_menu.settings_panel.tabs.current_tab = 1
	await shot("12_settings_interface")
	ui.system_menu.settings_panel.tabs.current_tab = 2
	await shot("13_settings_controls")
	ui.system_menu.show_page(&"database")
	await shot("14_equipment_database")
	ui.system_menu.show_page(&"comms")
	await shot("15_comms_log")
	ui.close_system_menu()
	check(not paused, "Session resumes after the mission menu")
	# 8. Habitat interior: utility terminal and greenhouse station.
	director._switch_space(&"engineering")
	await settle(6)
	await shot("16_interior_hud")
	director.utility_panel.open_panel("distribution")
	utilities.advance(1)
	await shot("17_utility_terminal")
	director.utility_panel.close_panel()
	director.daily_panel.open_panel("greenhouse")
	await shot("18_greenhouse_station")
	director.daily_panel.close_panel()
	# 9. High-contrast theme and 125% interface scale.
	var settings: AppSettings = AppSettings.shared()
	settings.set_interface(1.0, true, false)
	await settle(4)
	await shot("19_high_contrast")
	settings.set_interface(1.25, false, false)
	await settle(4)
	await shot("20_ui_scale_125")
	settings.set_interface(1.0, false, false)
	main.queue_free()
	await process_frame
	await _menu_shots()
	for failure: String in failures:
		printerr("FAIL: " + failure)
	if failures.is_empty():
		print("PASS: %d Phase 0.8F capture checks" % checks)
	quit(0 if failures.is_empty() else 1)
